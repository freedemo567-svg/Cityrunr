"""Build projected, 2 km streaming tiles from OSM PBF and district polygons.
Requires osmium 4.3+ and shapely 2.x. Run with --help. Data: ODbL 1.0.
"""
import argparse, json, math, pathlib, collections, hashlib
import osmium
from shapely.geometry import shape, Point, LineString
from shapely.ops import unary_union
from shapely.prepared import prep
from place_labels import add_admin_centres
parser=argparse.ArgumentParser()
parser.add_argument('pbf',type=pathlib.Path)
parser.add_argument('districts',type=pathlib.Path)
parser.add_argument('output',type=pathlib.Path)
args=parser.parse_args()
geometry=unary_union([shape(f['geometry']) for f in json.loads(args.districts.read_text())['features']])
region=prep(geometry)
bounds=geometry.bounds
tiles=collections.defaultdict(lambda:{'roads':[],'buildings':[],'rail':[]})
places=[]
counts=collections.Counter()
def project(lon,lat):return [round((lon-76)*109628.3,1),round((10-lat)*111320,1)]
def key(p):return (math.floor(p[0]/2000),math.floor(p[1]/2000))
class Extract(osmium.SimpleHandler):
 def node(self,n):
  if n.tags.get('place') in ('city','town','village','suburb') and n.tags.get('name') and bounds[0]<=n.location.lon<=bounds[2] and bounds[1]<=n.location.lat<=bounds[3] and region.contains(Point(n.location.lon,n.location.lat)):
   places.append({'name':n.tags.get('name:en',n.tags.get('name')),'lon':n.location.lon,'lat':n.location.lat,'point':project(n.location.lon,n.location.lat)})
 def way(self,w):
  highway=w.tags.get('highway');building=w.tags.get('building');rail=w.tags.get('railway')
  if not highway and not building and rail not in ('rail','light_rail'):return
  try:coords=[(n.lon,n.lat) for n in w.nodes]
  except osmium.InvalidLocationError:return
  if len(coords)<2:return
  if not any(bounds[0]<=x<=bounds[2] and bounds[1]<=y<=bounds[3] for x,y in coords):return
  # Clip to the actual state boundary, retaining crossings into border districts.
  line=LineString(coords)
  if not region.intersects(line):return
  if not region.contains(line):
   clipped=line.intersection(geometry)
   lines=list(clipped.geoms) if clipped.geom_type=='MultiLineString' else [clipped]
  else:lines=[line]
  for part in lines:
   if part.geom_type!='LineString' or len(part.coords)<2:continue
   points=[project(x,y) for x,y in part.coords]
   if building:
    # A centroid-indexed footprint is rendered once, at the tile containing its center.
    xs=[p[0] for p in points];zs=[p[1] for p in points]
    center=[(min(xs)+max(xs))/2,(min(zs)+max(zs))/2]
    try:height=float(w.tags.get('height',str(float(w.tags.get('building:levels','2'))*3)))
    except ValueError:height=6
    if max(xs)-min(xs)>1 and max(zs)-min(zs)>1:
     tiles[key(center)]['buildings'].append([w.id,points,round(min(80,max(3,height)),1)])
     counts['buildings']+=1
   else:
    category='roads' if highway else 'rail'
    # Individual segments are indexed in every crossed cell to avoid tile-edge gaps.
    for a,b in zip(points,points[1:]):
     cells=set();steps=max(1,math.ceil(math.dist(a,b)/500))
     for i in range(steps+1):cells.add(key([a[0]+(b[0]-a[0])*i/steps,a[1]+(b[1]-a[1])*i/steps]))
     for cell in cells:tiles[cell][category].append([a,b,highway or rail,w.tags.get('name:en',w.tags.get('name','')),w.tags.get('bridge','no')])
    counts[category]+=1
Extract().apply_file(str(args.pbf),locations=True,idx='flex_mem')
add_admin_centres(args.pbf, region, places)
args.output.mkdir(parents=True,exist_ok=True)
for (x,z),data in sorted(tiles.items()):(args.output/f'{x}_{z}.json').write_text(json.dumps(data,separators=(',',':'),ensure_ascii=False))
manifest={'source':'OpenStreetMap contributors via Geofabrik southern-zone-261104.osm.pbf','license':'ODbL-1.0','projection':{'origin_lon':76,'origin_lat':10,'x_per_degree':109628.3,'z_per_degree':-111320},'tile_size':2000,'counts':dict(counts),'tiles':[f'{x}_{z}' for x,z in sorted(tiles)],'places':sorted(places,key=lambda p:p['name']),'pbf_sha256':hashlib.sha256(args.pbf.read_bytes()).hexdigest()}
(args.output/'manifest.json').write_text(json.dumps(manifest,separators=(',',':'),ensure_ascii=False))
print(json.dumps({'counts':dict(counts),'tiles':len(tiles),'places':len(places)}),flush=True)
