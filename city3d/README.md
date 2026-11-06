<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:c1a66f9f24337532027aad02b2061bbcd142451fdd9489b28053afca3d2e4064 -->

# City Run 3D — current project

An offline Godot 4.3 Standard driving game with two active modes: fictional Kadavu Town and geographic Kerala drive. Both use the latest vehicle and environment rendering. The geographic world has flat terrain and illustrative scenery; it is not a complete or photorealistic reconstruction of Kerala.

## Files and startup

Open this `city3d` folder in Godot or VS Code. `project.godot` starts `main.tscn`; Garage → REAL MAP DRIVE opens `geodrive.tscn`. Assets, licences, tests and tools belong to this project.

From the repository root, with `GODOT_BIN` pointing to Godot 4.3 Standard:

```sh
"$GODOT_BIN" --headless --path city3d --editor --import
node city3d/tools/project.mjs run
```

Read [BUILD_GUIDE_ML.md](BUILD_GUIDE_ML.md) for Windows and Android setup. Build requirements are Godot 4.3 Standard with matching export templates, Node 24, JDK 17, Android SDK 34 and a local signing key. The ARM64 preset uses Godot's Android exporter. `node city3d/tools/project.mjs build` writes `city3d/build/city-run-3d.apk`.

## Controls and features

- Walk or drive freely, discover four landmarks and save distance, top speed and discovered places. Existing optional FIRE/police interactions remain available on foot.
- Approach the car and use ENTER / EXIT. Stop before exiting or opening the garage.
- Drag the circular wheel horizontally for analog steering. Accelerator and brake support simultaneous touch; reverse, handbrake and horn have separate controls. Desktop uses arrow keys, R for reverse and Space for braking.
- Drag open space to orbit the camera; desktop uses right mouse drag. The driving camera follows behind the vehicle with a saved orbit offset. The on-foot camera has independent orbit behavior.
- Garage → VEHICLE selects sports car, motorcycle, auto rickshaw, city bus, cargo van or lorry. Selection, five paint colours, daylight and headlights persist in Town saves.
- Garage → CHARACTER switches male/female presentations. They share the animated body and scanned head; the female presentation adds a different outfit and hairstyle. On-foot play and character selection are available in Town.
- Horn repeats while held and stops on release, pause or exit. Pitch varies by type; engine audio is synthesized.

Town contains signal junctions, traffic, canals, bridges, a beach, a moving train and crossing gates. Collision prevents entering water away from bridges, the train or closed gates. These are fictional placements. Driving uses arcade physics, conservative building bounds and simplified vehicle/train collision.

## Current vehicles

Town and geographic players share the detailed concept-car renderer; traffic uses a lighter source mesh culled at 90 metres. Fresh clearcoat paint materials remove imported normal/AO artifacts. Tinted alpha glazing exposes the existing cabin. Each vehicle owns its paint and lamp overrides.

Uniform scaling preserves model proportions. Four wheel groups are recovered from the imported combined meshes; the source axle pose is neutralized before live steering. Wheel spin follows signed travel divided by tyre radius; calipers steer without spinning. Brake lamps brighten on braking. The sports car has rear lamp fascia, diffuser trim and a fictional CITY RUN plate.

The detailed and traffic source models contain about 213,000 and 44,000 triangles respectively. Supporting vehicles use original rounded procedural bodies, torus tyres, two-sided rims, mirrors, grilles, wipers and fittings. The rickshaw has open sides, roof pillars and a passenger bench. These categories remain stylized. A soft underbody plane approximates contact shading.

## Buildings and environment

The shared batched facade renderer adds framed glazing, sills, mullions, sunshades, panelled entrances, steps, floor bands, roof parapets, downpipes, selected balconies and shop shutters. Window interior mapping depicts virtual rooms and curtains; interiors are not playable. Each facade has up to three material surfaces and a 640-box geometry budget.

Geographic mode details at most 24 buildings within 110 metres, measured from the footprint boundary, with per-wall budgets proportional to length. Mapped outlines and source heights are preserved. Small rectangular buildings receive illustrative tile roofs or roof tanks. Flat roofs use weathered concrete. Town buildings also have verandas, tile roofs and roof tanks.

Roads use scanned asphalt, ground uses grass maps and sloping roofs use clay tile maps. Geographic sky uses an HDR panorama. Sixteen nearby tree instances and at most 12 shrub candidates are permitted; generated planting avoids loaded buildings and transport corridors. Curbs, vegetation and architecture illustrate local appearance and are not surveyed designs.

## Kerala geographic mode and data

Garage → REAL MAP DRIVE opens geographic drive. Search a city, town or village and select a result to move near a mapped road. A 3×3 neighbourhood of 2km tiles streams around the vehicle. VEHICLE switches category; TOWN returns to the other active game mode. Geographic position is not persisted and does not overwrite Town saves.

This checkout includes the tiles under `assets/kerala/tiles/`; no separate ZIP parts are needed. The dataset contains 3,721 place/admin-seat labels, roads, rail segments and building footprints/heights, clipped to the simplified 14-district union. It comes from the Geofabrik Southern Zone extract, snapshot 2026-11-04T21:21:03Z. Source details and checksums are in `tiles/manifest.json`.

OSM data can be incomplete or outdated. Roads have approximate widths; bridge tags add generic barriers. A generic train follows nearby connected mapped rail without a timetable or articulated coach curves. Coastlines, terrain elevation, detailed bridge structures and signals are not reconstructed. Private/restricted roads are not filtered for legal driving access; this is an exploratory game visualization, not navigation guidance.

KERALA MAP shows selectable district boundaries while pausing Town. This overview is distinct from the playable geographic scene. Coordinates use x=(lon−76)×109628.3 and z=(10−lat)×111320 in approximate metres.

### Data attribution and reproduction

Data: © [OpenStreetMap contributors](https://www.openstreetmap.org/copyright), [ODbL 1.0](https://opendatacommons.org/licenses/odbl/1-0/), via [Geofabrik Southern Zone](https://download.geofabrik.de/asia/india/southern-zone.html). `assets/kerala/ODbL-1.0.txt` contains the licence.

`districts.json` derives from [geoBoundaries India ADM2 simplified](https://github.com/wmgeolab/geoBoundaries/tree/9469f09/releaseData/gbOpen/IND/ADM2), built 2023-12-12, representing 2021. Source: Pathways Data Pvt. Ltd. and lgdirectory.gov.in via geoBoundaries, under ODbL 1.0. `assets/kerala/prepare_districts.py` reproduces the subset. Simplified boundaries are not an authoritative survey. Attribution is displayed in game.

The tile importer uses Python 3.13, osmium 4.3.2 and shapely 2.2.0:

```sh
python city3d/tools/import_kerala.py southern-zone.osm.pbf city3d/assets/kerala/districts.json city3d/assets/kerala/tiles
```

The importer calls `tools/place_labels.py` for OSM administrative-seat relation members. Use the source checksum from the manifest for reproducibility; the provider's latest download URL changes.

## Saves

Town `user://city_save.json` stores positions, heading, orbit, paint, lighting, character/vehicle selection and exploration statistics. It saves every 10 seconds of active play and on relevant actions/backgrounding. Invalid positions fall back safely and speed resets on load. Existing story/job fields and cash are preserved only as legacy save data; they do not activate removed game loops. Driving orbit angles are relative to vehicle heading; the save format is unchanged.

## Checks

Linux desktop checks need a display or `xvfb-run`. From the repository root:

```sh
node city3d/tools/project.mjs test
"$GODOT_BIN" --path city3d --script res://tests/geographic.gd
"$GODOT_BIN" --path city3d --script res://tests/vehicles.gd
```

Use isolated `XDG_DATA_HOME`/`APPDATA` directories for direct gameplay tests. `--audio-driver Dummy` supports environments without an audio device. Tests cover gameplay, collision, saves, garage, multitouch, camera, map streaming, trains, building geometry and vehicle rendering invariants. Windows execution, phone touch/GPU/frame rate and audible audio need separate verification.

## Asset attribution

- `assets/car/car-concept.glb` and `car-detail.glb`: modified [Car Concept](https://github.com/KhronosGroup/glTF-Sample-Assets/tree/main/Models/CarConcept) by Eric Chadwick, ©2024 Darmstadt Graphics Group GmbH, [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). Flattened, welded, textures resized to 512px; traffic further simplified. Runtime paint, glass, lamps, wheel rig and rear detail are modified. Khronos logos remain subject to the [Khronos trademark notice](https://github.com/KhronosGroup/glTF-Sample-Assets/blob/main/LICENSES/LicenseRef-LegalMark-Khronos.txt).
- `assets/human/human.glb`: derived from [Cesium Man](https://github.com/KhronosGroup/glTF-Sample-Assets/tree/main/Models/CesiumMan), ©2017 Cesium, [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). Mascot head triangles removed and clothing material replaced; original skeleton/walk animation remains. Embedded source texture is retained for provenance. Original logo is subject to `Cesium-trademark.txt`.
- `assets/human/head.glb` and `head-color.jpg`: Lee Perry-Smith head scan by Infinite-Realities / I-R Entertainment Ltd., [CC BY 3.0](https://creativecommons.org/licenses/by/3.0/), from [three.js assets](https://github.com/mrdoob/three.js/tree/dev/examples/models/gltf/LeePerrySmith). Rescaled, textured and attached to the neck bone. [Morgan McGuire, Computer Graphics Archive, July 2017](https://casual-effects.com/data/) records author/licence and credits Morgan McGuire and Guedis Cardenas for material/texture conversions. No endorsement is implied.
- `assets/facade/textures/`: retained plaster colour/normal maps from [Poly Haven Modular Urban Apartments Facade](https://polyhaven.com/a/modular_urban_apartments_facade), [CC0](https://polyhaven.com/license). Facade geometry is generated by the current renderer.
- `assets/surfaces/`: [Asphalt 02](https://polyhaven.com/a/asphalt_02), [Leafy Grass](https://polyhaven.com/a/leafy_grass) and [Clay Roof Tiles](https://polyhaven.com/a/clay_roof_tiles), Poly Haven CC0. Source URLs/checksums are in `sources.json`.
- `assets/vegetation/`: [Shrub 01](https://polyhaven.com/a/shrub_01) and [Island Tree 02](https://polyhaven.com/a/island_tree_02), Poly Haven CC0. The tree was simplified with gltfpack 0.22 to 41,930 triangles, three material draws and an 8.3 MiB GLB. Source/generated checksums are stored alongside the assets.
- `assets/atmosphere/`: [Kloppenheim 06 Pure Sky](https://polyhaven.com/a/kloppenheim_06_puresky), Poly Haven CC0; source/checksum in `sources.json`.
- Horn: **Car signal** by Yaroslav_Novikov, [OpenGameArt](https://opengameart.org/content/car-signal), CC0. One recording is reused with pitch variations.


<!-- /coderabbit-ai-generated:v1 -->