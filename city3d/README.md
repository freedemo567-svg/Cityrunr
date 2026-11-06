<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:467ddfe2bb179d58b94f38272e06b41b55c9bcd49760be18ff283041bd4476c7 -->

<!-- coderabbit-ai-generated-section:v1:a2bcbd6f83adc3f210c528bdf039f562572408791085d43ae56c387926e7067e -->

<!-- coderabbit-ai-generated-section:v1:18e3423ad9066d47bbe72dcf0e5639bd3e681a24b4440c9c60bb5f532b360066 -->

<!-- coderabbit-ai-generated-section:v1:defe11322fb1e47bd6c2c57d2ab8f0201085a8e82efee1d46cdbb9ae3cc186c6 -->

# City Run 3D — current project

An offline Godot 4.3 Standard driving game with one shared Kerala geographic world for driving and on-foot exploration. The fictional Town scene has been removed. The geographic world has flat terrain and illustrative scenery; it is not a complete or photorealistic reconstruction of Kerala.

## Files and startup

Open this `city3d` folder in Godot or VS Code. `project.godot` starts `geodrive.tscn` directly. Assets, licences, tests and tools belong to this project.

From the repository root, with `GODOT_BIN` pointing to Godot 4.3 Standard:

```sh
"$GODOT_BIN" --headless --path city3d --editor --import
node city3d/tools/project.mjs run
```

Read [BUILD_GUIDE_ML.md](BUILD_GUIDE_ML.md) for Windows and Android setup. Build requirements are Godot 4.3 Standard with matching export templates, Node 24, JDK 17, Android SDK 34 and a local signing key. The ARM64 preset uses Godot's Android exporter. `node city3d/tools/project.mjs build` writes `city3d/build/city-run-3d.apk`.

## Controls and features

- Walk or drive freely, discover nearby Kerala place labels and save distance, top speed and discovered places. Existing optional FIRE/police interactions remain available on foot.
- Approach the car and use ENTER / EXIT. Stop before exiting or opening the garage.
- Drag the circular wheel horizontally for analog steering. Accelerator and brake support simultaneous touch; reverse, handbrake and horn have separate controls. Desktop uses arrow keys, R to toggle D/R while stopped and Space for braking.
- Drag open space to orbit the camera; desktop uses right mouse drag. The driving camera follows behind the vehicle with a saved orbit offset. The on-foot camera has independent orbit behavior.
- Garage → VEHICLE selects sports car, motorcycle, auto rickshaw, city bus, cargo van or lorry. Selection, five paint colours, daylight and headlights persist in Kerala saves.
- Garage → CHARACTER switches male/female presentations. They share the animated body and scanned head; the female presentation adds a different outfit and hairstyle. On-foot play and character selection are available throughout the loaded Kerala world.
- Horn repeats while held and stops on release, pause or exit. Pitch varies by type; engine audio is synthesized.

<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:038f40515f5c4e1d7d494ff6c057a16512347d9d3cc1d77846aeff13d554c2d0 -->

Traffic follows nearby mapped road segments, with a cap of eight cars. Illustrative signal cycles are placed at mapped junction candidates, and barriers close near mapped road/rail crossings when the train approaches. These are generated controls, not surveyed signal locations or a road network routing simulator. The train uses connected mapped railway and bridge tags generate barriers. The district overview pauses the shared world. Optional FIRE/police interactions remain available on foot; buildings block shots. Fictional Town landmarks, road layouts and canals have been retired; real mapped geometry remains authoritative. Traffic moves away when it approaches the player; backing away from a red signal or closed gate is possible. Building collisions follow the visible footprint, so empty corners of a bounding rectangle do not block roads. Search selects an unblocked nearby road position when one is available.

<!-- /coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:277a5d06576eda5647e8ffe68fb1f982ca9e431ee3e71e33a9ef2a625703b8fe -->

### Physical driving controls

The driving overlay uses a stitched leather wheel, metal spokes, recessed rubber/metal pedals, moving D/R selector, handbrake lever and speedometer. Pedal faces depress and return; accelerator/brake bars show demand and applied brake pressure. The original touch locations are retained.

Press a pedal for full demand. While holding it, slide down to ease pressure or back up to increase it. Steering, brake and accelerator each own an independent touch, so releasing one does not cancel the others. Leaving a pedal's expanded hit area releases that pedal and consumes that finger until release, avoiding accidental camera movement. Mouse press/drag also works. Keyboard arrows retain full accelerator/brake input. Pause, backgrounding and exit clear held controls. D/R can still only change when stopped; this is a driving overlay rather than an interior cockpit simulation.

### Vehicle response

<!-- /coderabbit-ai-generated:v1 -->

Brake pressure builds over time rather than instantly removing 22 m/s of speed per second. The service brake approaches 7.8 m/s² at full pressure; coasting uses rolling resistance and speed-dependent drag. Handbrake applies a separate braking force. Select D/R only when stopped, then press the accelerator to move. Steering uses a smoothed bicycle model and reduced lock at higher speed. Body pitch and roll react to braking and cornering. This is a simplified handling model without simulated tyre slip, suspension or ABS.

## Current vehicles

Kerala players share the detailed concept-car renderer; traffic uses a lighter source mesh within the loaded neighbourhood. Fresh clearcoat paint materials remove imported normal/AO artifacts. Tinted alpha glazing exposes the existing cabin. Each vehicle owns its paint and lamp overrides.

Uniform scaling preserves model proportions. Four wheel groups are recovered from the imported combined meshes; the source axle pose is neutralized before live steering. Wheel spin follows signed travel divided by tyre radius; calipers steer without spinning. Brake lamps brighten on braking. The sports car has rear lamp fascia, diffuser trim and a fictional CITY RUN plate.

The detailed and traffic source models contain about 213,000 and 44,000 triangles respectively. Supporting vehicles use original rounded procedural bodies, torus tyres, two-sided rims, mirrors, grilles, wipers and fittings. The rickshaw has open sides, roof pillars and a passenger bench. These categories remain stylized. A soft underbody plane approximates contact shading.

## Buildings and environment

The shared batched facade renderer adds framed glazing, sills, mullions, sunshades, panelled entrances, steps, floor bands, roof parapets, downpipes, selected balconies and shop shutters. Window interior mapping depicts virtual rooms and curtains; interiors are not playable. Each facade has up to three material surfaces and a 640-box geometry budget.

Geographic mode details at most 24 buildings within 110 metres, measured from the footprint boundary, with per-wall budgets proportional to length. Mapped outlines and source heights are preserved. Small rectangular buildings receive illustrative tile roofs or roof tanks. Flat roofs use weathered concrete.

Roads use scanned asphalt, ground uses grass maps and sloping roofs use clay tile maps. Geographic sky uses an HDR panorama. Sixteen nearby tree instances and at most 12 shrub candidates are permitted; generated planting avoids loaded buildings and transport corridors. Curbs, vegetation and architecture illustrate local appearance and are not surveyed designs.

<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:13d80245295ef71b55aa7f85e0aac6490c1bd787eb4125b7972d16cf14967358 -->

### Searchable example buildings

Search by building type and select an `Example:` result, then press **GO** while stopped. The catalog covers all 100 requested types, distributed across seven Kerala city areas. These are fictional, procedurally rendered exterior examples placed beside mapped roads, not real OSM business names or actual facilities. Their footprints and collision are separate from mapped buildings. They are illustrative models with shared category styles and selected type-specific details; they are not photorealistic reconstructions, and there are no functional interiors. An underground bunker is represented by a surface entrance building; larger facilities are compact landmarks, not full sites. The search result and building sign identify each as an example.

The catalog was placed by testing clearances against source building footprints and roads/rail; terrain remains flat and does not include surveyed land, coastline or land use. The original mapped buildings retain their source footprints and heights. At most 24 nearby buildings receive extra facade detail, with examples near the player given priority.

## Kerala geographic mode and data

<!-- /coderabbit-ai-generated:v1 -->

The game opens directly in Kerala. Search a city, town or village and select a result to move near a mapped road. A 3×3 neighbourhood of 2km tiles streams around the vehicle. Stop before using VEHICLE or GARAGE. ENTER / EXIT (desktop E) switches between walking and driving near the vehicle. Walking uses arrows or touch controls; hold SPRINT or Shift to run. G opens the garage; F fires on foot. Geographic progress saves automatically.

This checkout includes the tiles under `assets/kerala/tiles/`; no separate ZIP parts are needed. The dataset contains 3,721 place/admin-seat labels, roads, rail segments and building footprints/heights, clipped to the simplified 14-district union. It comes from the Geofabrik Southern Zone extract, snapshot 2026-11-04T21:21:03Z. Source details and checksums are in `tiles/manifest.json`.

OSM data can be incomplete or outdated. Roads have approximate widths; bridge tags add generic barriers. A generic train follows nearby connected mapped rail without a timetable or articulated coach curves. Coastlines, terrain elevation, detailed bridge structures and signals are not reconstructed. Private/restricted roads are not filtered for legal driving access; this is an exploratory game visualization, not navigation guidance.

KERALA MAP shows selectable district boundaries while pausing the world. Close it to continue at the same location. Coordinates use x=(lon−76)×109628.3 and z=(10−lat)×111320 in approximate metres.

### Data attribution and reproduction

Data: © [OpenStreetMap contributors](https://www.openstreetmap.org/copyright), [ODbL 1.0](https://opendatacommons.org/licenses/odbl/1-0/), via [Geofabrik Southern Zone](https://download.geofabrik.de/asia/india/southern-zone.html). `assets/kerala/ODbL-1.0.txt` contains the licence.

`districts.json` derives from [geoBoundaries India ADM2 simplified](https://github.com/wmgeolab/geoBoundaries/tree/9469f09/releaseData/gbOpen/IND/ADM2), built 2023-12-12, representing 2021. Source: Pathways Data Pvt. Ltd. and lgdirectory.gov.in via geoBoundaries, under ODbL 1.0. `assets/kerala/prepare_districts.py` reproduces the subset. Simplified boundaries are not an authoritative survey. Attribution is displayed in game.

The tile importer uses Python 3.13, osmium 4.3.2 and shapely 2.2.0:

```sh
python city3d/tools/import_kerala.py southern-zone.osm.pbf city3d/assets/kerala/districts.json city3d/assets/kerala/tiles
```

The importer calls `tools/place_labels.py` for OSM administrative-seat relation members. Use the source checksum from the manifest for reproducibility; the provider's latest download URL changes.

## Saves

`user://kerala_save.json` stores geographic car/player positions, vehicle heading, orbit, driving state, character, paint, headlights, daylight, distance, top speed, discovered places and cash. Writes use a temporary file followed by rename. Saves occur every 10 active seconds, on garage/entry changes, backgrounding and window close. Invalid values are bounded, speed resets, and car positions respawn on the nearest loaded road. Walking resumes near the parked car if safe.

On first launch without a Kerala save, personalisation/statistics are read from the old `city_save.json`. Fictional Town coordinates and landmark names are not migrated. The old save is retained for recovery. The game has no Town entry point.

## Checks

Linux desktop checks need a display or `xvfb-run`. From the repository root:

```sh
node city3d/tools/project.mjs test
"$GODOT_BIN" --path city3d --script res://tests/geographic.gd
"$GODOT_BIN" --path city3d --script res://tests/vehicles.gd
<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:b468dca2847293d6280cb634b993fe1a95ff284a1affc7c6bfd086b4c85479a6 -->

"$GODOT_BIN" --headless --path city3d --script res://tests/driving.gd
"$GODOT_BIN" --headless --path city3d --script res://tests/controls.gd

<!-- /coderabbit-ai-generated:v1 -->
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


<!-- /coderabbit-ai-generated:v1 -->
## Nearby services, audio and collision marks

POLICE and FUEL take a stopped vehicle to the roadside near the local service. Two khaki-clad officers and a marked patrol car stand at the police station; the fuel station has separate PETROL and DIESEL pump labels. These are fictional game outposts, not real station locations. Clear mapped roadside sites are searched within 600 m of the player; police/fuel placement refreshes after 2 km/3 km, with retries after moving 250 m. This keeps service within the requested 5 km/8 km radius in covered areas. Empty map areas or areas without a clear roadside site cannot guarantee coverage. Placement reserves space away from mapped roads, rail and buildings; the forecourt remains walkable.

Driving sound combines synthesized combustion, vehicle-specific pulses, speed/load pitch, tyre rolling noise and a collision transient. These are not recorded engine samples. Pause, background and leaving the vehicle stop driving audio. Physical impacts above 2 m/s add localized metal scratches to painted surfaces, with a short repeat cooldown and up to 12 marks per vehicle type. Marks persist in saves; red signals do not cause damage. Scratches are cosmetic: there is no body deformation or mechanical damage.

Native integration check: `"$GODOT_BIN" --path city3d --script res://tests/services_damage.gd` (use an isolated XDG_DATA_HOME for a disposable save). Android device audio remains to be checked.


<!-- /coderabbit-ai-generated:v1 -->