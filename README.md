<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:28b251c3260b085ae28e01f29b122cbbbf378e5081d4ab53707f43d65e326312 -->

<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:3a56b7a24bfe7b0fa076433e50886121e51cddca455be9862e4b98f555eb6c95 -->

<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:836acbc4fd8411c90108e96b4f11e868a74debb565c6cd8474f49475a0777ae6 -->

# City Run

## City Run 3D

The current Kerala driving prototype is in [`city3d/`](city3d/README.md). The repository includes its Kerala map tiles; when cloning this repository, the separate data ZIPs mentioned in the guide are not needed. For a Windows setup and Android APK build, open `city3d` in VS Code and follow [the Malayalam guide](city3d/BUILD_GUIDE_ML.md) from “ഘട്ടം 1”. The geographic world and vehicle models are still a prototype; see the 3D README for their limitations and data credits.

## Original Android project

<!-- /coderabbit-ai-generated:v1 -->

City Run is an offline top-down Android city game. Explore on foot or enter the red car, follow the minimap to pick up packages and deliver them for cash. Three delivery routes repeat. Buildings block movement, and progress is stored on the device.

## Build

Use JDK 17 and Android SDK platform 35, then run `./gradlew assembleDebug`. The debug APK is generated at `app/build/outputs/apk/debug/app-debug.apk`. Android 7.0 (API 24) or later is required.

## Game rule tests

Run `mkdir -p /tmp/city-test && javac -d /tmp/city-test app/src/main/java/com/jungletrail/game/GameModel.java tests/GameModelTest.java && java -cp /tmp/city-test GameModelTest`.


<!-- /coderabbit-ai-generated:v1 -->

<!-- /coderabbit-ai-generated:v1 -->