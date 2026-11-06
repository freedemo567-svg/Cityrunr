<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:1e08958c132e1df006158643fe3e2abe93baf1c7b5159ccd54d6687d0b7f64da -->

# City Run 3D v0.10 — മലയാളം setup guide

## ഈ പതിപ്പിലെ മാറ്റങ്ങൾ

- **GARAGE → VEHICLE:** sports car, motorcycle, auto, city bus, cargo van, lorry എന്നീ ആറു വിഭാഗങ്ങളിൽ നിന്ന് തിരഞ്ഞെടുക്കാം. വാഹനം നിർത്തിയശേഷം മാറ്റുക. Selection save ചെയ്യും. ഇവ എല്ലാ യഥാർത്ഥ models-ഉം ഉൾപ്പെടുന്ന collection അല്ല; പുതിയ അഞ്ചു models ലളിതമായ procedural geometry ആണ്.
- **HORN:** CC0 Car signal sample ഉപയോഗിക്കുന്നു. Button പിടിച്ചാൽ ആവർത്തിക്കും; വിട്ടാൽ/pause/exit ചെയ്താൽ നിൽക്കും. വാഹനമനുസരിച്ച് pitch മാറും. ഓരോ വാഹനത്തിന്റെയും പ്രത്യേകം recording അല്ല. Engine sound ഇപ്പോഴും synthesized ആണ്.
- **GARAGE → REAL MAP DRIVE:** OpenStreetMap road geometry ഉപയോഗിച്ചുള്ള Kerala geographic prototype. Search box-ൽ നഗരമോ ഗ്രാമമോ type ചെയ്ത് അടുത്തുള്ള dropdown-ൽ തിരഞ്ഞെടുക്കുക. അതിനടുത്തുള്ള mapped road-ലേക്ക് വാഹനം മാറ്റും. വാഹനം നീങ്ങുമ്പോൾ സമീപത്തെ 2km map tiles load ചെയ്യും. **VEHICLE** ഉപയോഗിച്ച് വാഹനം മാറ്റാം; **TOWN** പഴയ town-ലേക്ക് മടങ്ങും.
- Geographic mode-ൽ terrain flat ആണ്; buildings footprint-ന്റെ approximate boxes ആണ്. യഥാർത്ഥ elevation, എല്ലാ bridges/signals/beaches-ന്റെയും detailed models, photorealistic textures എന്നിവ പൂർത്തിയായിട്ടില്ല. OSM-ൽ ഇല്ലാത്തതോ തെറ്റായതോ ആയ വിവരങ്ങൾ ഇവിടെ സ്വയം പൂർണ്ണമാകില്ല. ഇത് navigation app അല്ല. Geographic position ഇപ്പോൾ save ചെയ്യുന്നില്ല; പഴയ town save നിലനിൽക്കും.

## Source-ഉം Kerala data pack-ഉം സജ്ജമാക്കുക

1. Source ZIP download ചെയ്ത് **Extract All** ചെയ്യുക. അതിനുള്ളിലെ **CityRun3D** folder കണ്ടെത്തുക.
2. Kerala data pack-ന്റെ എല്ലാ ZIP parts-ഉം download ചെയ്യുക. ഓരോ ZIP-ഉം source extract ചെയ്ത **അതേ parent folder**-ലേക്ക് extract ചെയ്യുക. രണ്ടിലും `CityRun3D` folder merge ആകണം. <!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:f9b4e5fcdafbe31799402505926d2f14c0123b6df29f2bbea2043b74037e966d -->

Data pack parts സ്വതന്ത്ര ZIP files ആണ്; എല്ലാം extract ചെയ്യണം. Extract ചെയ്ത map JSON data ഏകദേശം 706 MiB ആണ്; build-നും അധിക disk space വേണം.

<!-- /coderabbit-ai-generated:v1 -->
3. അവസാനമായി `CityRun3D/assets/kerala/tiles/manifest.json` file-ഉം map tile JSON files-ഉം ഉണ്ടെന്ന് ഉറപ്പാക്കുക. `CityRun3D/CityRun3D` എന്ന nested folder ഉണ്ടെങ്കിൽ data തെറ്റായിടത്താണ് extract ചെയ്തത്; ഉള്ളിലെ `assets/kerala/tiles` ശരിയായ project-ലേക്ക് മാറ്റുക.
4. Godot-ൽ project വീണ്ടും import ചെയ്യുക; തുടർന്ന് **City: Build APK** task പ്രവർത്തിപ്പിക്കുക. Map data export-ൽ ഉൾപ്പെടാൻ build വീണ്ടും വേണം. Internet തുടക്കത്തിലെ software/data downloads-ന് വേണം; installed game-ൽ local data ഉപയോഗിക്കുന്നു.
5. Data pack ചേർക്കാതെ പഴയ fictional town കളിക്കാം. Geographic mode-ൽ data ആവശ്യമാണ് എന്ന message കാണും.
6. APK/signing key ഈ package-ൽ ഇല്ല. താഴെയുള്ള setup steps പിന്തുടർന്ന് VS Code-ൽ APK സ്വയം നിർമ്മിക്കാം. Source models/texture/audio/data licences README.md-ൽ ഉണ്ട്.

**പരിധി:** ഇത് പൂർണ്ണ photorealistic Kerala game ആയി പൂർത്തിയായിട്ടില്ല. Real road geometry import/streaming-ഉം vehicle fleet-ഉം ചേർത്ത പതിപ്പാണ്. കേരളത്തിലെ എല്ലാ യഥാർത്ഥ വസ്തുക്കളും വാഹനങ്ങളും ഉൾപ്പെടുത്തിയതായി കരുതരുത്. Windows-ലും ഫോണിലും performance നേരിട്ട് പരിശോധിച്ചിട്ടില്ല.

## തുടങ്ങുന്നതിന് മുമ്പ്

<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:0eb7a8eac3711f3e29378936066e403e5260c715e2344a8ea767ed7599e83e03 -->

1. ഈ guide-നൊപ്പം നൽകിയ **City Run 3D source ZIP** download ചെയ്യുക.

<!-- /coderabbit-ai-generated:v1 -->
2. Downloads folder-ൽ ZIP-ൽ right-click → **Extract All** → **Extract** തിരഞ്ഞെടുക്കുക.
3. Extract ചെയ്ത folder തുറന്ന് അതിനുള്ളിലെ **CityRun3D** folder കണ്ടെത്തുക. അതിനുള്ളിൽ `project.godot`, `tools`, `assets`, `.vscode` എന്നിവ കാണണം. ZIP-നുള്ളിൽ നിന്നുതന്നെ project പ്രവർത്തിപ്പിക്കരുത്.

## ഘട്ടം 1: ആവശ്യമായ software install ചെയ്യുക

താഴെയുള്ള ഓരോ link-ഉം തുറന്ന് Windows installer തിരഞ്ഞെടുക്കുക. Installation കഴിഞ്ഞ് program തുറക്കാൻ കഴിയുന്നുണ്ടെന്ന് ഉറപ്പാക്കുക.

1. [Visual Studio Code](https://code.visualstudio.com/download) install ചെയ്യുക.
2. [Node.js](https://nodejs.org/en/download) ൽ നിന്ന് **Node.js 24** install ചെയ്യുക. Installer-ലെ സാധാരണ options സ്വീകരിക്കുക.
3. [JDK 17 (Temurin)](https://adoptium.net/temurin/releases/?version=17) ൽ നിന്ന് Windows-ന് അനുയോജ്യമായ **JDK 17** installer download ചെയ്ത് install ചെയ്യുക. JDK folder എവിടെയാണെന്ന് ശ്രദ്ധിക്കുക; ഉദാഹരണം `C:\Program Files\Eclipse Adoptium\jdk-17.0.x.x-hotspot`. നിങ്ങളുടെ PC-യിലെ പേര് വ്യത്യസ്തമായിരിക്കും.
4. [Godot 4.3 Stable](https://godotengine.org/download/archive/4.3-stable/) ൽ നിന്ന് Windows **Standard** (non-.NET) version download ചെയ്യുക. ZIP മുഴുവനായി extract ചെയ്യുക; ഉദാഹരണത്തിന് `C:\Godot43` എന്ന folder-ലേക്ക്. Godot executable-ന്റെ സ്ഥലം ഓർത്തുവയ്ക്കുക. ZIP-ൽ console executable ഉണ്ടെങ്കിൽ command-കൾക്കായി അതും അതിന്റെ അടുത്തുള്ള സാധാരണ executable-ഉം ഒരേ folder-ൽ സൂക്ഷിക്കുക.
5. [Android Studio](https://developer.android.com/studio) install ചെയ്യുക. ആദ്യമായി തുറന്ന് Setup Wizard പൂർത്തിയാക്കുക; SDK download ചെയ്യാൻ അനുവദിക്കുക.

## ഘട്ടം 2: Android SDK packages install ചെയ്യുക

1. Android Studio welcome screen-ൽ **More Actions → SDK Manager** തുറക്കുക. Project തുറന്നിരിക്കുകയാണെങ്കിൽ **File → Settings → Languages & Frameworks → Android SDK** തിരഞ്ഞെടുക്കുക.
2. മുകളിലെ **Android SDK Location** എന്ന path കുറിച്ചുവയ്ക്കുക. സാധാരണ `C:\Users\നിങ്ങളുടെ-പേര്\AppData\Local\Android\Sdk` ആയിരിക്കും; നിങ്ങളുടെ screen-ൽ കാണുന്ന path ആണ് ഉപയോഗിക്കേണ്ടത്.
3. **SDK Platforms** tab-ൽ **Android 14.0 (API 34)** തിരഞ്ഞെടുക്കുക.
4. **SDK Tools** tab തുറന്ന് **Show Package Details** tick ചെയ്യുക. താഴെയുള്ളവ തിരഞ്ഞെടുക്കുക:
   - Android SDK Build-Tools **34.0.0**
   - Android SDK Platform-Tools **34.0.0 അല്ലെങ്കിൽ പുതിയത്**
   - Android SDK Command-line Tools (latest)
   - NDK (Side by side) **23.2.8568313**
   - CMake **3.10.2.4988404**
5. **Apply → OK** അമർത്തുക. Licenses കാണിച്ചാൽ സ്വീകരിക്കുക. Download/install പൂർത്തിയാകുന്നതുവരെ കാത്തിരിക്കുക. ഈ പട്ടിക [Godot 4.3 Android setup](https://github.com/godotengine/godot-docs/blob/4.3/tutorials/export/exporting_for_android.rst) അനുസരിച്ചാണ്.

## ഘട്ടം 3: Godot, Java paths Windows-ൽ സജ്ജമാക്കുക

1. Windows **Start** തുറന്ന് `environment variables` എന്ന് search ചെയ്യുക. **Edit environment variables for your account** തുറക്കുക.
2. മുകളിലെ **User variables** വിഭാഗത്തിൽ **New** അമർത്തുക. നേരത്തെ ഇതേ പേരുള്ള variable ഉണ്ടെങ്കിൽ അത് തിരഞ്ഞെടുത്ത് **Edit** ഉപയോഗിക്കുക.
3. Variable name: `JAVA_HOME`. Variable value: JDK 17 folder-ന്റെ പൂർണ്ണ path. ആ folder-നുള്ളിൽ `bin\java.exe` ഉണ്ടാകണം; `bin` വരെ ചേർക്കരുത്. ഉദാഹരണം `C:\Program Files\Eclipse Adoptium\jdk-17.0.x.x-hotspot` — ഈ ഉദാഹരണത്തിലെ `x` നിങ്ങളുടെ യഥാർത്ഥ version ഉപയോഗിച്ച് മാറ്റണം.
4. മറ്റൊരു user variable ചേർക്കുക: name `GODOT_BIN`; value Godot executable-ന്റെ **പൂർണ്ണ file path**. ഉദാഹരണം `C:\Godot43\Godot_v4.3-stable_win64_console.exe`. ഈ പേര് PC-യിൽ വ്യത്യസ്തമാണെങ്കിൽ യഥാർത്ഥ പേര് നൽകുക. Console executable ഇല്ലെങ്കിൽ extract ചെയ്ത standard Godot executable ഉപയോഗിച്ച് താഴെയുള്ള version check നടത്തുക. File Explorer-ൽ file-ൽ right-click → **Copy as path** ഉപയോഗിക്കാം; variable value-യിൽ ചുറ്റുമുള്ള quote marks ഉണ്ടെങ്കിൽ നീക്കുക.
5. എല്ലാ windows-ലും **OK** അമർത്തുക. എല്ലാ VS Code windows-ഉം അടച്ച് വീണ്ടും തുറക്കുക. പുതിയ variables പഴയ terminal-ൽ ലഭ്യമാകില്ല.

## ഘട്ടം 4: VS Code-ൽ source project തുറക്കുക

1. VS Code → **File → Open Folder** → extract ചെയ്ത **CityRun3D** folder തിരഞ്ഞെടുക്കുക → **Select Folder**. Trust ചോദിച്ചാൽ source നിങ്ങൾ download ചെയ്തതാണെന്ന് ഉറപ്പാക്കിയശേഷം trust തിരഞ്ഞെടുക്കുക.
2. ഇടതുവശത്തെ Explorer-ൽ `project.godot` നേരിട്ട് കാണുന്നുണ്ടെന്ന് ഉറപ്പാക്കുക. അത് മറ്റൊരു folder-നുള്ളിലാണെങ്കിൽ തെറ്റായ folder ആണ് തുറന്നത്; അകത്തെ CityRun3D folder തുറക്കുക.
3. **Terminal → New Terminal** തുറക്കുക. Terminal PowerShell ആണെന്ന് ഉറപ്പാക്കി ഓരോ command-ഉം വേറെയായി നൽകുക:

```powershell
node --version
$env:JAVA_HOME
& "$env:JAVA_HOME\bin\java.exe" -version
$env:GODOT_BIN
& $env:GODOT_BIN --version
```

Node 24, Java 17, Godot **4.3.stable** കാണണം. Path ശൂന്യമാണെങ്കിൽ ഘട്ടം 3 പരിശോധിച്ച് VS Code പൂർണ്ണമായി restart ചെയ്യുക. `java.exe` അല്ലെങ്കിൽ Godot file കണ്ടെത്താനാകുന്നില്ലെങ്കിൽ path തിരുത്തുക.

## ഘട്ടം 5: Godot-ൽ project, export templates സജ്ജമാക്കുക

1. Godot സാധാരണ executable തുറക്കുക. Project Manager-ൽ **Import** അമർത്തുക.
2. Extract ചെയ്ത `CityRun3D\project.godot` file തിരഞ്ഞെടുക്കുക → **Import & Edit**. ആദ്യ import പൂർത്തിയാകുന്നതുവരെ കാത്തിരിക്കുക.
3. Godot editor-ൽ **Editor → Manage Export Templates** തുറക്കുക. Godot **4.3.stable** templates install ചെയ്യുക. `Download and Install` ലഭ്യമല്ലെങ്കിൽ official archive-ൽ നിന്നുള്ള matching templates `.tpz` file അതേ window-യിൽ നിന്ന് install ചെയ്യുക.
4. **Editor → Editor Settings → Export → Android** തുറക്കുക.
5. **Java SDK Path**-ൽ ഘട്ടം 3-ലെ JDK folder നൽകുക. **Android SDK Path**-ൽ ഘട്ടം 2-ൽ കുറിച്ച SDK Location നൽകുക. File picker-ൽ folder തിരഞ്ഞെടുക്കുമ്പോൾ `bin` തിരഞ്ഞെടുക്കരുത്.
6. **Project → Export** തുറന്ന് `Android` preset ഉണ്ടെന്ന് പരിശോധിക്കുക. ഇത് ARM64 preset ആണ്; Gradle Build enable ചെയ്യേണ്ടതില്ല.

## ഘട്ടം 6: Debug signing key

APK install ചെയ്യാൻ debug key വേണം. Android Studio നേരത്തേ ഉണ്ടാക്കിയ debug keystore ഉണ്ടെങ്കിൽ അത് ഉപയോഗിക്കാം; പുതിയ key കൊണ്ട് overwrite ചെയ്യരുത്.

1. VS Code-ലെ PowerShell terminal-ൽ പരിശോധിക്കുക:

```powershell
Test-Path "$env:USERPROFILE\.android\debug.keystore"
```

2. `False` ആണെങ്കിൽ മാത്രം താഴെയുള്ള രണ്ട് commands ഓരോന്നായി പ്രവർത്തിപ്പിക്കുക:

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.android" | Out-Null
& "$env:JAVA_HOME\bin\keytool.exe" -genkeypair -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000 -storepass android -keypass android -dname "CN=Android Debug,O=Android,C=US"
```

3. Godot-ൽ **Editor Settings → Export → Android** തുറന്ന് debug keystore path ആയി `%USERPROFILE%\.android\debug.keystore`-ന്റെ യഥാർത്ഥ path നൽകുക. Debug user/alias `androiddebugkey`, debug password `android` നൽകുക. നിലവിലുള്ള key-ക്ക് വേറൊരു alias/password ആണെങ്കിൽ അതിന്റെ യഥാർത്ഥ details ഉപയോഗിക്കുക. ഈ debug key testing-നുള്ളതാണ്.

## ഘട്ടം 7: Build ചെയ്ത് APK കണ്ടെത്തുക

1. VS Code-ൽ CityRun3D folder തുറന്നിരിക്കെ **Terminal → Run Task** തിരഞ്ഞെടുക്കുക.
2. **City: Check Setup** തിരഞ്ഞെടുക്കുക. `Godot and project found` കണ്ടാൽ engine path ശരിയാണ്. ഈ check SDK, template, signing എന്നിവ പരിശോധിക്കില്ല.
3. വീണ്ടും **Terminal → Run Task → City: Build APK** തിരഞ്ഞെടുക്കുക. പകരം **Ctrl+Shift+B** അമർത്താം.
4. Terminal-ൽ build പൂർത്തിയാകുന്നതുവരെ കാത്തിരിക്കുക. `APK ready:` എന്ന് കാണുമ്പോൾ VS Code Explorer-ൽ **build → city-run-3d.apk** തുറക്കുക. ഉദാഹരണ path: `CityRun3D\build\city-run-3d.apk`.
5. File Explorer-ൽ APK കണ്ടെത്താൻ VS Code Explorer-ലെ file-ൽ right-click → **Reveal in File Explorer** ഉപയോഗിക്കുക. ഈ APK USB വഴി ഫോണിലേക്ക് copy ചെയ്ത് തുറക്കുക. ചോദിച്ചാൽ file തുറക്കുന്ന app-ന് Android-ന്റെ **Install unknown apps** permission നൽകുക.

<!-- coderabbit-ai-generated:v1 -->

<!-- coderabbit-ai-generated-section:v1:2777b7e766fcb490fef8f41ffc36a333546bf62b327fe121d65645d0684a58da -->

ഐച്ഛികമായി **Terminal → Run Task → City: Run Game** വഴി desktop-ൽ game കാണാം; **City: Gameplay Test** ഒരു smoke test നടത്തും. Data pack import ചെയ്തശേഷം geographic mode പരിശോധിക്കാൻ PowerShell-ൽ `& $env:GODOT_BIN --path . --script res://tests/geographic.gd` പ്രവർത്തിപ്പിക്കാം. ഇത് search, vehicles, driving, handbrake, horn, background reset, map streaming എന്നിവ പരിശോധിക്കും.

<!-- /coderabbit-ai-generated:v1 -->

## പ്രശ്നം വന്നാൽ

- **`node` not recognized:** Node.js install ചെയ്ത ശേഷം VS Code അടച്ച് വീണ്ടും തുറക്കുക.
- **Cannot run Godot / Godot 4.3 required:** `GODOT_BIN` യഥാർത്ഥ executable file-ലേക്കാണോ എന്നും ഘട്ടം 4-ലെ `--version` 4.3 കാണിക്കുന്നുണ്ടോ എന്നും പരിശോധിക്കുക. ZIP മുഴുവൻ extract ചെയ്തിരിക്കണം.
- **Set JAVA_HOME:** അത് JDK 17-ന്റെ folder ആണോ എന്നും `bin\java.exe` ഉണ്ടോ എന്നും പരിശോധിക്കുക; VS Code restart ചെയ്യുക.
- **Export template / SDK error:** Godot 4.3 templates, SDK packages, SDK/JDK paths എന്നിവ ഘട്ടം 2, 5 അനുസരിച്ച് പരിശോധിക്കുക.
- **Signing/keystore error:** ഘട്ടം 6-ലെ keystore path, alias, password പരിശോധിക്കുക. മുൻപ് ഉണ്ടായ keystore overwrite ചെയ്യരുത്.
- **App not installed / different signature:** മുൻപ് install ചെയ്ത City Run 3D മറ്റൊരു key ഉപയോഗിച്ച് sign ചെയ്തതാകാം. പഴയ app uninstall ചെയ്താൽ അതിന്റെ save നഷ്ടപ്പെടും; പിന്നീട് പുതിയ APK install ചെയ്യാം.
- **ഫോണിൽ തുറക്കുന്നില്ല:** ഈ preset ARM64 ആണ്; 32-bit-only device-ൽ പ്രവർത്തിക്കില്ല. Terminal-ലെ മുഴുവൻ error message അയച്ചാൽ പ്രശ്നം പരിശോധിക്കാം.

## പരിശോധനയുടെ പരിധി

ഈ project Linux-ൽ gameplay smoke test, Android build, signature verification എന്നിവയിൽ വിജയിച്ചിട്ടുണ്ട്. Windows-ലും Android ഫോണിലും ഈ ഘട്ടങ്ങൾ നേരിട്ട് പരിശോധിച്ചിട്ടില്ല. Build വിജയിച്ചാലും ഫോണിലെ touch controls, graphics, performance എന്നിവ ഫോണിൽ പരീക്ഷിക്കണം.


<!-- /coderabbit-ai-generated:v1 -->