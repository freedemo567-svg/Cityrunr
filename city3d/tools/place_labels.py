"""Include OSM administrative seats which have no place tag on their node."""
import json
import pathlib
import sys
import osmium
from shapely.geometry import Point, shape
from shapely.ops import unary_union
from shapely.prepared import prep

def add_admin_centres(pbf, region, places):
    seats = {}
    for relation in osmium.FileProcessor(str(pbf), entities=osmium.osm.RELATION).with_filter(osmium.filter.KeyFilter('boundary')):
        if relation.tags.get('admin_level') not in ('5', '6', '8'):
            continue
        name = relation.tags.get('name:en', relation.tags.get('name', ''))
        if not name:
            continue
        for member in relation.members:
            if member.type == 'n' and member.role == 'admin_centre':
                seats.setdefault(member.ref, []).append((name, relation.id))
    known = {p['name'].casefold() for p in places}
    for node in osmium.FileProcessor(str(pbf), entities=osmium.osm.NODE).with_filter(osmium.filter.IdFilter(seats)):
        lon, lat = node.location.lon, node.location.lat
        if not region.contains(Point(lon, lat)):
            continue
        for name, relation_id in seats[node.id]:
            if name.casefold() in known:
                continue
            known.add(name.casefold())
            places.append({'name': name, 'lon': lon, 'lat': lat,
                           'point': [round((lon-76)*109628.3, 1), round((10-lat)*111320, 1)],
                           'source_relation': relation_id, 'source_node': node.id})
    places.sort(key=lambda p: p['name'])

if __name__ == '__main__':
    pbf, districts, manifest = map(pathlib.Path, sys.argv[1:])
    geometry = unary_union([shape(f['geometry']) for f in json.loads(districts.read_text())['features']])
    data = json.loads(manifest.read_text())
    before = len(data['places'])
    add_admin_centres(pbf, prep(geometry), data['places'])
    manifest.write_text(json.dumps(data, separators=(',', ':'), ensure_ascii=False))
    print('Added administrative seat labels:', len(data['places'])-before, '; places:', len(data['places']))
