"""Extract Kerala districts from geoBoundaries IND ADM2 simplified GeoJSON.

Download https://github.com/wmgeolab/geoBoundaries/raw/9469f09/releaseData/gbOpen/IND/ADM2/geoBoundaries-IND-ADM2_simplified.geojson
then run `python prepare_districts.py path/to/source.geojson` in this directory.
"""
import json
import sys
from pathlib import Path

NAMES = ['Kasaragod', 'Kannur', 'Wayanad', 'Kozhikode', 'Malappuram', 'Palakkad', 'Thrissur', 'Ernakulam', 'Idukki', 'Kottayam', 'Alappuzha', 'Pathanamthitta', 'Kollam', 'Thiruvananthapuram']
features = [f for f in json.loads(Path(sys.argv[1]).read_text())['features'] if f['properties']['shapeName'] in NAMES]
if len(features) != 14 or {f['properties']['shapeName'] for f in features} != set(NAMES):
    raise ValueError('Expected exactly the 14 Kerala districts')
features.sort(key=lambda f: NAMES.index(f['properties']['shapeName']))
Path('districts.json').write_text(json.dumps({'type': 'FeatureCollection', 'features': features}, separators=(',', ':')))
