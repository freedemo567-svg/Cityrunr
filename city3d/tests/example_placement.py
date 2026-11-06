"""Audit the fictional building catalog against source tiles and the requested inventory."""
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TILES = ROOT / 'assets/kerala/tiles'
expected = '''Safehouse|Apartment|Mansion|Penthouse|Villa|Cottage|Motel|Hotel|Skyscraper|Office|Corporate HQ|Bank|ATM Kiosk|Police Station|Fire Station|Hospital|Clinic|City Hall|Courthouse|Prison|Military Base|Airport Terminal|Hangar|Helipad|Train Station|Subway Station|Bus Depot|Gas Station|Car Dealership|Mechanic Shop|Car Wash|Tuning Garage|Parking Garage|Supermarket|Convenience Store|Clothing Store|Ammu-Nation|Barber Shop|Tattoo Parlor|Restaurant|Fast Food Joint|Cafe|Bar|Nightclub|Strip Club|Casino|Movie Theater|Bowling Alley|Arcade|Gym|Stadium|Racetrack|Golf Club|Yacht Club|Marina|Warehouse|Factory|Power Plant|Oil Refinery|Construction Site|Salvage Yard|Junk Yard|Port Terminal|Cargo Depot|Farm House|Barn|Silo|Greenhouse|Windmill|Lighthouse|Observatory|Planetarium|Museum|Art Gallery|Library|University Hall|School|Church|Cathedral|Temple|Mosque|Cemetery Chapel|Morgue|TV Station|Radio Station|News Bureau|Billboard Tower|Water Tower|Radio Mast|Substation|Sewage Treatment Plant|Landfill Facility|Fire Watchtower|Ranger Station|Abandoned Mine|Bunkhouse|Cargo Warehouse|Smuggling Den|Secret Laboratory|Underground Bunker'''.split('|')
examples = json.loads((ROOT / 'assets/kerala/illustrative_buildings.json').read_text())['buildings']
assert len(examples) == len(expected) == 100
assert {x['name'] for x in examples} == set(expected)
assert len({x['id'] for x in examples}) == 100
cache = {}
def tile(x, z):
    key = (x, z)
    if key not in cache:
        path = TILES / f'{x}_{z}.json'
        cache[key] = json.loads(path.read_text()) if path.exists() else {'buildings': [], 'roads': [], 'rail': []}
    return cache[key]
def intersects(rect, other):
    return rect[0] < other[2] and rect[2] > other[0] and rect[1] < other[3] and rect[3] > other[1]
def segment_hits(a, b, r):
    # Clip a segment against a rectangular clearance area.
    lo, hi = 0.0, 1.0
    dx, dz = b[0]-a[0], b[1]-a[1]
    for p, q in [(-dx, a[0]-r[0]), (dx, r[2]-a[0]), (-dz, a[1]-r[1]), (dz, r[3]-a[1])]:
        if abs(p) < 1e-9:
            if q < 0:return False
        else:
            t = q/p
            if p < 0:lo = max(lo, t)
            else:hi = min(hi, t)
            if lo > hi:return False
    return True
def distance(point, a, b):
    dx, dz = b[0]-a[0], b[1]-a[1]
    t = max(0, min(1, ((point[0]-a[0])*dx+(point[1]-a[1])*dz)/(dx*dx+dz*dz))) if dx*dx+dz*dz else 0
    return math.hypot(point[0]-(a[0]+t*dx),point[1]-(a[1]+t*dz))
rects = []
for item in examples:
    x, z = item['center']; w, d = item['width']/2, item['depth']/2
    assert item['id'] < 0 and all(math.isfinite(n) for n in [x,z,w,d,item['height'],*item['point']])
    assert math.floor((x-w-3)/2000) == math.floor((x+w+3)/2000)
    assert math.floor((z-d-3)/2000) == math.floor((z+d+3)/2000)
    margin = 2.8 if item['name'] == 'Gas Station' else 1.3
    footprint = (x-w-margin,z-d-margin,x+w+margin,z+d+margin)
    assert not any(intersects(footprint, rect) for rect in rects), item['name']
    rects.append(footprint)
    near_road = False
    for gx in range(math.floor(x/2000)-1,math.floor(x/2000)+2):
        for gz in range(math.floor(z/2000)-1,math.floor(z/2000)+2):
            data = tile(gx,gz)
            for b in data['buildings']:
                bx = [p[0] for p in b[1]]; bz = [p[1] for p in b[1]]
                assert not intersects(footprint,(min(bx),min(bz),max(bx),max(bz))),item['name']
            for group in ('roads','rail'):
                for r in data[group]:
                    assert not segment_hits(r[0],r[1],footprint), item['name']
                    if group == 'roads' and r[2] not in ('footway','path','steps','pedestrian','cycleway') and distance(item['point'],r[0],r[1]) < 0.3:near_road=True
    assert near_road,item['name']
print('100 requested names: unique, on streamed tiles, near mapped roads and clear of mapped buildings, roads, rail and each other')
