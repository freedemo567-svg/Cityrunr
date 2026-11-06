<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:cf541cb8eb1870513b904deafd4de61b2aab16953423d98a4b44e816a96c8ac1 -->

<!-- coderabbit-ai-generated-section:v1:2986e7fdfc2abc3133dad903f522edd54749eb8b5fc7e8a81f3c88330ba14727 -->

<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:75329970faf437b8561e7a7009e895a3362cbf11c3af6a2135640fe2d2cb86c2 -->

# City Run 3D — Kadavu Drive 0.10

<!-- /coderabbit-ai-generated:v1 -->

An offline Godot 4.3 Android prototype for free driving around a fictional Kochi-inspired town. The game is stylized; it is not a photorealistic recreation or an accurate playable map of Kerala.

<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:fb90d8642c8213263658b984b4c9d3ec75407492ca6bd72b24467324a8a23b65 -->

<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:05e77626e7cd4ee313c6ab80e456f4c8b11cee5bd6b5ec608e58fe6d3bfd1b76 -->

## Version 0.10: fleet and geographic drive

Garage → VEHICLE cycles six supported categories: sports car, motorcycle, auto rickshaw, city bus, cargo van and lorry. Stop before changing. Each has a different size, top speed, wheel configuration and front/rear lights; traffic uses a mixture of types. Selection persists in existing saves; old saves default to the sports car. These are six categories, not all real vehicles or branded production models. The five new types are original simple procedural geometry and remain visibly stylized.

HORN uses the CC0 **Car signal** audio by Yaroslav_Novikov from [OpenGameArt](https://opengameart.org/content/car-signal), replacing the synthesized single beep. It repeats while held, stops on release/pause/exit and varies pitch by type. It is one source sample with pitch variations, not independently recorded horns from every vehicle. Engine audio remains synthesized. Actual audible output on a phone has not been verified.

Garage → REAL MAP DRIVE opens a separate geographic prototype based on OpenStreetMap geometry from the Geofabrik Southern Zone extract, snapshot 2026-11-04T21:21:03Z. Search for a mapped city/town/village and choose it to relocate near a mapped road. A 3×3 neighborhood of 2km tiles is loaded around the vehicle; leaving it loads adjacent tiles. Car/bike/auto/bus/van/lorry controls also work here. TOWN returns to the existing fictional scene. Geographic mode does not change the old town save. Geographic position is not persisted yet.

<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:69291617897cc83f984d323819eb7ea5d6645458888e638a61ee1d25acb21b89 -->

Install the separate Kerala data pack before opening this mode. The extracted JSON data is approximately 706 MiB. It supplies 3,721 searchable place/admin-seat labels; seats referenced by OSM relations are included even when their label node has no place tag.

<!-- /coderabbit-ai-generated:v1 --> <!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:2fce0428da158aca5b034b93e51b3391f37eba6aef3121a0ca0883e7b6782ded -->

It contains projected roads, railway segments, building footprints/heights and mapped place labels clipped to the existing simplified district union. OSM coverage may be incomplete or outdated; private or restricted roads are not filtered for legal driving access. Geographic mode is an exploratory game visualization, not navigation guidance. Buildings follow mapped outlines, with fallback shapes for invalid outlines and default heights where missing. Facades and windows are illustrative. Roads have approximate widths, bridge tags add generic barriers, and railway segments have rails and sleepers. A generic train follows nearby connected mapped track; it has no real timetable and its rigid coaches do not model curves. The plane remains flat: coastlines, terrain elevation, detailed bridge structures and signals are not reconstructed. Collision uses conservative building bounds and simplified train geometry; speed is capped by vehicle type. The world is not a complete or photorealistic reproduction of Kerala.

<!-- /coderabbit-ai-generated:v1 -->

### Geographic data licence and reproduction

Data: © [OpenStreetMap contributors](https://www.openstreetmap.org/copyright), [ODbL 1.0](https://opendatacommons.org/licenses/odbl/1-0/), via [Geofabrik Southern Zone](https://download.geofabrik.de/asia/india/southern-zone.html), combined with the existing ODbL district subset. The derived database is supplied in the data pack with its manifest/source checksum and existing ODbL licence. The game shows attribution. It uses a local equirectangular projection centered at 76E,10N: x=(lon−76)×109628.3; z=(10−lat)×111320. Units approximate meters. This is not a surveyed reconstruction.

`tools/import_kerala.py` reproduces tiles using Python3.13, osmium4.3.2 and shapely2.2.0. Example from repository root:

```sh
python city3d/tools/import_kerala.py southern-zone.osm.pbf city3d/assets/kerala/districts.json city3d/assets/kerala/tiles
```

<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:ac95fffc2dc677bddeaef052ff7d65b061d103ffdd10b52023cf417e3c926eaa -->

The importer also runs `tools/place_labels.py` to resolve OSM administrative-seat relation members. Use the exact source checksum in the manifest for reproducibility; the `latest` download URL changes.

<!-- /coderabbit-ai-generated:v1 --> <!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:b25c4abc0e4386da56960bfac7040051be790db8b19b7711f253508820d5b605 -->

Distribution retains source attribution and the ODbL licence. Facade details and ground cover are illustrative; surveyed terrain and building details, mobile optimization and physical-device verification remain outstanding.

<!-- /coderabbit-ai-generated:v1 -->

## Version 0.9: people, controls and infrastructure

<!-- /coderabbit-ai-generated:v1 -->

Player, rivals and officer use an animated humanoid body with a scanned human head attached to its neck bone. Clothing uses a plain navy material. Walking follows movement direction and pauses at rest or when the game pauses. This improves anatomy and the face; the complete character and environment remain stylized, not photorealistic.

While driving, the left circular wheel supports analog steering: drag horizontally from its center, release to center. Accelerator and brake are tall ribbed pedal controls; pedals and steering support simultaneous fingers. Reverse, handbrake and horn have separate controls. Small left/right buttons remain accessible below the wheel. Desktop supports left mouse dragging on the wheel as well as the existing keys. ENTER / EXIT is now at the bottom right.

<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:b07b0c966962bca105475580c9c0756568af765586d955244a38c2bd7eab7b1c -->

The fictional town has two signal junctions (12s green, 3s amber, 17s red), AI cars waiting for red/amber, canal crossings with bridge decks/rails, a beach/ocean at its western edge and a moving four-car train on a railway. Crossing gates close before the locomotive arrives and reopen after the coaches clear. Driving collision checks prevent crossing a closed gate, entering the train, driving into canal water away from bridges or entering the sea. The player can walk over the bridges and visit the beach. Signals, train and human animation freeze while paused. These are original town features, not real Kerala infrastructure locations. Version 0.10 adds separate geographic road/rail data; it does not reconstruct those real-world infrastructure details.

<!-- /coderabbit-ai-generated:v1 -->



<!-- /coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:a626c34609d1354542fb40760cd762ff358a8208c59f5effd9938168608d0549 -->

## Play

Story chapters

<!-- /coderabbit-ai-generated:v1 --> and delivery jobs have been removed at the user's request. Drive or walk freely, discover four named local landmarks, and keep saved distance, top speed and discovery statistics. There are no required routes, timers, job payouts or campaign ending. The small gold dots on the minimap mark undiscovered landmarks; green dots mark discoveries. Existing optional FIRE/police interactions remain available on foot.

Approach the car and press ENTER / EXIT. Driving controls have icons and English labels: ACCELERATOR, BRAKE, REVERSE, STEER LEFT/RIGHT, HANDBRAKE and HORN. Stop before exiting or opening GARAGE. Desktop: arrow keys, R for reverse, Space for braking. Drag open space to orbit 360 degrees; on desktop hold the right mouse button. Camera pitch is limited.

GARAGE pauses the world. PAINT cycles five colors; TIME OF DAY cycles day, sunset and evening; HEADLIGHTS switches two projected beams and headlamp emission. Brake lights brighten while the brake/handbrake is pressed, and reverse lamps light while moving backwards. Changes save immediately. BACK TO DRIVE restores the prior pause state. Car sound is synthesized and changes pitch with speed; pause/exit stops it. Driving uses arcade physics, not a full vehicle simulation.

<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:19107cd294739781b815af5d405e42913da37e176caa2b325e2f18ac5c03d855 -->

## Visuals

GARAGE → CHARACTER switches between male and female presentations and saves the selection. Both use the existing animated body and scanned head; the female presentation adds a different outfit and hairstyle rather than a separate scanned model. Character selection applies to the town scene, where on-foot play is available. Geographic mode remains driving-only.

<!-- /coderabbit-ai-generated:v1 -->

The player uses a higher detail version of the existing concept car; traffic uses a simplified mesh with 90 meter visibility. Metallic paint removes the strong flake normal, and tinted reflective glass replaces unsupported glTF transmission in the compatibility renderer. The player mesh has about 213,000 triangles; traffic meshes have about 44,000 each. This is a generic concept model, not a licensed production vehicle. Four building types use shared textured plaster, scanned windows and doors, tiled sloping roofs, verandas, shop shutters, balconies, parapets and roof water tanks. Buildings use varied dimensions and colors. Geometry is generated at runtime; these are original Kerala-inspired arrangements, not scans of actual Kerala buildings. Far building visuals are culled at 160 meters. Mobile frame rate remains unverified.

## Saves

Local `user://city_save.json` records positions, car heading, camera, paint, lighting and driving statistics. Autosave occurs every 10 seconds of active gameplay, on discoveries and when entering/exiting, changing garage settings or pausing/backgrounding. Old story/job fields and cash are retained in the save as legacy data without activating their old game loops. Invalid saved positions fall back safely; vehicle speed resets on load.

## Kerala map

<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:57d574ef735ca9a3b0d6da91c4bb821f55996dbc9d0db7e1589e7eb86bd1038e -->

KERALA MAP opens a selectable overview of the 14 district boundaries, pausing the world. This overview is not the playable 3D world and does not include every Kerala place or road. The main scene remains fictional Kadavu Town. GARAGE → REAL MAP DRIVE opens the separate v0.10 geographic scene described above.

<!-- /coderabbit-ai-generated:v1 -->

`assets/kerala/districts.json` is a derived subset of [geoBoundaries India ADM2 simplified](https://github.com/wmgeolab/geoBoundaries/tree/9469f09/releaseData/gbOpen/IND/ADM2), built 2023-12-12, representing 2021. Source: Pathways Data Pvt. Ltd. and lgdirectory.gov.in via geoBoundaries. Licensed under [ODbL 1.0](https://opendatacommons.org/licenses/odbl/1-0/). `prepare_districts.py` reproduces extraction; `ODbL-1.0.txt` contains the licence. Simplified boundaries are not an authoritative survey. Attribution is also displayed in game.

## Build with VS Code

Read **BUILD_GUIDE_ML.md** for the Windows Malayalam walkthrough. Required: Godot 4.3 Standard, matching export templates, Node 24, JDK 17, Android SDK 34 and a local debug signing key. Set GODOT_BIN and JAVA_HOME, open this folder in VS Code and run Terminal → Run Task → City: Build APK. Output: `build/city-run-3d.apk`. The included preset uses ARM64 and no Gradle build.

From the repository root:

```sh
GODOT_BIN=/path/to/godot node city3d/tools/project.mjs check
GODOT_BIN=/path/to/godot node city3d/tools/project.mjs test
JAVA_HOME=/path/to/jdk17 GODOT_BIN=/path/to/godot node city3d/tools/project.mjs build
```

Linux desktop tests need a display (or xvfb-run). Tests use an isolated save directory. Smoke covers driving/collision, independent multitouch, traffic, camera, district map, sound lifecycle, garage, lights, exploration and legacy save migration. <!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:ef19f36f23b3939c4402992a13c8528c67d5507f3c928c4cd56c9db4577f7cda -->

Device audio/touch/GPU and Windows execution require separate verification. After importing the data pack, run `godot --path city3d --script res://tests/geographic.gd` from the repository root (or `godot --path . --script res://tests/geographic.gd` inside the standalone source folder) for geographic search, fleet, controls/audio lifecycle and streaming checks.

<!-- /coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:902b611a68217f2fbc32bdab75fdcb159ce98fb01422acbe41c07f11aa085daf -->

### Human asset credits

`assets/human/human.glb` derives from [Cesium Man](https://github.com/KhronosGroup/glTF-Sample-Assets/tree/main/Models/CesiumMan), ©2017 Cesium, [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). The original logo is subject to the included `Cesium-trademark.txt`. Modifications remove the mascot head triangles and replace the clothing material; the original skeleton/walk animation remains. The source mesh still embeds its original texture for provenance; it is not shown on the modified body.

`assets/human/head.glb` and `head-color.jpg` are the Lee Perry-Smith head scan by Infinite-Realities / I-R Entertainment Ltd., [CC BY 3.0](https://creativecommons.org/licenses/by/3.0/), obtained from the [three.js example assets](https://github.com/mrdoob/three.js/tree/dev/examples/models/gltf/LeePerrySmith). The [McGuire Computer Graphics Archive](https://casual-effects.com/data/) records the author and license (LPS Head). The head is rescaled, textured and attached to the walk rig at runtime. Morgan McGuire, Computer Graphics Archive, July2017, https://casual-effects.com/data. The archive credits Morgan McGuire and Guedis Cardenas for material/texture conversions. No endorsement by the scanned person or original authors is implied.

## Asset attribution

<!-- /coderabbit-ai-generated:v1 -->

`assets/facade` contains the 1K modular urban apartments facade from [Poly Haven](https://polyhaven.com/a/modular_urban_apartments_facade), published under [CC0](https://polyhaven.com/license). Version 0.8 reuses its plaster textures and scanned window/door modules inside original generated architecture.

`assets/car/car-concept.glb` and `assets/car/car-detail.glb` are modified versions of [Car Concept](https://github.com/KhronosGroup/glTF-Sample-Assets/tree/main/Models/CarConcept) by Eric Chadwick, © 2024 Darmstadt Graphics Group GmbH, licensed [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). They were flattened, welded and resized to 512px textures; the traffic model was further simplified. Version 0.8 changes paint and lamp materials at runtime. The original includes Khronos logos, subject to the [Khronos trademark notice](https://github.com/KhronosGroup/glTF-Sample-Assets/blob/main/LICENSES/LicenseRef-LegalMark-Khronos.txt).


<!-- /coderabbit-ai-generated:v1 -->