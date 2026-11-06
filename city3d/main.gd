extends Node3D

const WORLD_LIMIT := 158.0
var town = preload("res://town.gd").new()
var human_visual: Node3D
var dashboard: Control
var vehicle_kind := 0
var character_kind := 0
var character_button: Button
var fleet=preload("res://fleet.gd").new()
var horn_down := false
var features=preload("res://infrastructure.gd").new()
var architecture = preload("res://architecture.gd").new()
var garage_panel: Panel
var garage_status: Label
var garage_paused_game := false
var paint_index := 0
var daylight := 0
var headlights := false
var sun: DirectionalLight3D
var sky: Environment
var distance_driven := 0.0
var top_speed := 0.0
var discovered: Array[String] = []
var autosave_time := 0.0
var legacy_progress: Dictionary = {}
const PAINTS := [Color("245b87"),Color("a52c28"),Color("d2d0c6"),Color("30343b"),Color("2c654d")]
const PAINT_NAMES := ["Ocean blue","Crimson","Pearl","Graphite","Forest green"]
var landmarks := [
    {"name":"Canal Bend","position":Vector3(-120,0,100)},
    {"name":"Market Junction","position":Vector3(0,0,0)},
    {"name":"Palm Avenue","position":Vector3(85,0,-85)},
    {"name":"South Promenade","position":Vector3(65,0,145)}
]

var player: CharacterBody3D
var car: Node3D
var camera: Camera3D
var info: Label
var mode: Label
var paused := false
var boosting := false
var camera_angle := 0.0
var camera_pitch := 0.45
var camera_turn := 0.0
var camera_touch := -1
var car_speed := 0.0
var accelerator := false
var braking := false
var handbrake := false
var horn: AudioStreamPlayer
var engine_audio: AudioStreamPlayer
var kerala_map: Control
var map_paused_game := false
var reversing := false
var steering := 0.0
var touch_buttons: Array[Button] = []
var active_touches := {}
var foot_controls: Array[Button] = []
var drive_controls: Array[Button] = []
var fire_button: Button
var speed_label: Label
var traffic: Array[Node3D] = []
var pause_button: Button
var boost_button: Button
var health := 100.0
var wanted_time := 0.0
var shot_cooldown := 0.0
var police_damage_cooldown := 0.0
var rivals: Array[Node3D] = []
var police: Node3D
var in_car := false
var input_dir := Vector2.ZERO
var money := 0
var car_pos := Vector3(4, 0, 3)


func _ready():
    for place in landmarks: place.position=town.nearest(place.position)
    _environment()
    _world()
    _actors()
    _make_traffic()
    _make_combatants()
    _hud()
    _load_progress()
    _apply_daylight()
    _paint_car()
    _vehicle_lights()
    _update_info()

func _environment():
    var env := WorldEnvironment.new()
    var settings := Environment.new()
    sky=settings
    settings.background_mode = Environment.BG_SKY
    var atmosphere:=Sky.new()
    var gradient:=ProceduralSkyMaterial.new()
    gradient.sky_top_color=Color("5284a0")
    gradient.sky_horizon_color=Color("c2cacc")
    gradient.ground_horizon_color=Color("c2cacc")
    gradient.ground_bottom_color=Color("62685c")
    atmosphere.sky_material=gradient
    settings.sky=atmosphere
    settings.background_color = Color("91b9d4")
    settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    settings.ambient_light_color = Color("d6e3e9")
    settings.ambient_light_energy = 0.5
    env.environment = settings
    add_child(env)
    sun = DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-52, -25, 0)
    sun.light_energy = 0.85
    sun.shadow_enabled = true
    sun.directional_shadow_max_distance = 65.0
    add_child(sun)

func _material(col: Color) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = col
    m.roughness = 0.85
    return m

func _box(parent: Node3D, pos: Vector3, size: Vector3, color: Color, collision := false):
    var mesh := MeshInstance3D.new()
    var cube := BoxMesh.new()
    cube.size = size
    mesh.mesh = cube
    mesh.material_override = _material(color)
    mesh.position = pos
    parent.add_child(mesh)
    if collision:
        var body := StaticBody3D.new()
        body.position = pos
        var shape := CollisionShape3D.new()
        var box := BoxShape3D.new()
        box.size = size
        shape.shape = box
        body.add_child(shape)
        parent.add_child(body)
    return mesh

func _world():
    var ground_visual: MeshInstance3D=_box(self,Vector3(0,-0.3,0),Vector3(320,0.6,320),Color("697756"),true)
    ground_visual.material_override=preload("res://surface_materials.gd").ground()
    _box(self,Vector3(-155,0.01,0),Vector3(10,0.02,320),Color("39868d"))
    for road_index in range(town.roads.size()):
        var road: PackedVector3Array=town.roads[road_index]
        var road_height:=0.04+road_index*0.005
        var surface:=SurfaceTool.new()
        surface.begin(Mesh.PRIMITIVE_TRIANGLES)
        for i in range(road.size()-1):
            var a: Vector3=road[i]+Vector3(0,road_height,0)
            var b: Vector3=road[i+1]+Vector3(0,road_height,0)
            var side_a: Vector3=(road[i+1]-road[maxi(0,i-1)]).normalized().cross(Vector3.UP)*6
            var side_b: Vector3=(road[mini(road.size()-1,i+2)]-road[i]).normalized().cross(Vector3.UP)*6
            for vertex in [a-side_a,a+side_a,b+side_b,a-side_a,b+side_b,b-side_b]:
                surface.set_uv(Vector2(vertex.x,vertex.z))
                surface.add_vertex(vertex)
            if i%4==0:
                var dash=_box(self,(a+b)/2+Vector3(0,0.02,0),Vector3(0.14,0.03,minf(a.distance_to(b),2.5)),Color("f2e8c2"))
                dash.rotation.y=atan2(b.x-a.x,b.z-a.z)
        surface.generate_normals()
        var mesh:=MeshInstance3D.new()
        mesh.mesh=surface.commit()
        mesh.material_override=preload("res://surface_materials.gd").road(true)
        add_child(mesh)
    add_child(architecture)
    for place in landmarks:
        var sign:=Label3D.new()
        sign.text=place.name
        sign.position=place.position+Vector3(0,3,0)
        sign.font_size=48
        sign.pixel_size=0.012
        add_child(sign)
    add_child(features)
    features.setup(self)
    for i in range(town.buildings.size()):
        architecture.build(town.buildings[i],i)
        if i%3==0: _palm(town.buildings[i].position+Vector3(town.buildings[i].size.x/2+2,0,0))

func _palm(pos: Vector3):
    var tree: Node3D=preload("res://assets/vegetation/island-tree.glb").instantiate()
    tree.position=pos
    tree.scale=Vector3.ONE*1.8
    for visual in tree.find_children("*","GeometryInstance3D",true,false):
        visual.visibility_range_end=100
        visual.visibility_range_end_margin=10
    add_child(tree)

func _car_model(parent: Node3D):
    var kind: int=vehicle_kind if parent==car else int(parent.get_meta("kind",0))
    fleet.build(parent,kind,parent==car)
    if parent==car: _vehicle_accessories(parent)

func _vehicle_accessories(parent: Node3D):
    for side in [-1,1]:
        var beam:=SpotLight3D.new()
        beam.name="BeamLeft" if side<0 else "BeamRight"
        beam.position=Vector3(side*fleet.WIDTHS[vehicle_kind]*0.35,0.55 if vehicle_kind==0 else 0.85,1.9 if vehicle_kind==0 else fleet.LENGTHS[vehicle_kind]/2)
        beam.rotation.y=PI
        beam.spot_range=30
        beam.spot_angle=32
        beam.light_color=Color("fff1cf")
        beam.light_energy=2.5
        parent.add_child(beam)
        var reverse_lamp=_box(parent,Vector3(side*fleet.WIDTHS[vehicle_kind]*0.3,0.36 if vehicle_kind==0 else 0.7,-1.6 if vehicle_kind==0 else -fleet.LENGTHS[vehicle_kind]/2),Vector3(0.18,0.12,0.04),Color("edede3"))
        reverse_lamp.name="ReverseLeft" if side<0 else "ReverseRight"
        reverse_lamp.material_override.emission_enabled=true
func _actors():
    player = CharacterBody3D.new()
    add_child(player)
    player.position = Vector3(0, 0.9, 3)
    var shape := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.4
    capsule.height = 1.8
    shape.shape = capsule
    player.add_child(shape)
    human_visual=Node3D.new()
    human_visual.set_script(preload("res://human.gd"))
    human_visual.name="HumanVisual"
    human_visual.position.y=-0.9
    player.add_child(human_visual)
    car = Node3D.new()
    add_child(car)
    car.position = car_pos
    _car_model(car)
    _make_engine_sound()
    horn=AudioStreamPlayer.new()
    horn.stream=preload("res://assets/audio/horn.wav")
    horn.volume_db=-10
    add_child(horn)
    camera = Camera3D.new()
    add_child(camera)
    camera.current = true

func _hud():
    var layer := CanvasLayer.new()
    add_child(layer)
    info = Label.new()
    info.position = Vector2(24, 18)
    info.add_theme_font_size_override("font_size", 25)
    layer.add_child(info)
    mode = Label.new()
    mode.position = Vector2(24, 52)
    mode.add_theme_font_size_override("font_size", 20)
    layer.add_child(mode)
    foot_controls.append(_button(layer,"UP",Vector2(110,510),Vector2(90,70),func(): input_dir.y=-1,func(): input_dir.y=0))
    foot_controls.append(_button(layer,"DOWN",Vector2(110,590),Vector2(90,70),func(): input_dir.y=1,func(): input_dir.y=0))
    foot_controls.append(_button(layer,"LEFT",Vector2(10,590),Vector2(90,70),func(): input_dir.x=-1,func(): input_dir.x=0))
    foot_controls.append(_button(layer,"RIGHT",Vector2(210,590),Vector2(90,70),func(): input_dir.x=1,func(): input_dir.x=0))
    _button(layer,"ENTER / EXIT",Vector2(1020,675),Vector2(220,40),_toggle_car,func(): pass)
    boost_button = _button(layer,"SPRINT / BOOST",Vector2(1020,510),Vector2(220,70),func(): boosting=true,func(): boosting=false)
    pause_button = _button(layer,"PAUSE",Vector2(1040,240),Vector2(200,55),_toggle_pause,func(): pass)
    fire_button = _button(layer,"FIRE",Vector2(1020,365),Vector2(220,60),_fire,func(): pass)
    _button(layer,"CAM LEFT",Vector2(1020,440),Vector2(105,55),func(): camera_turn=-1,func(): camera_turn=0)
    _button(layer,"CAM RIGHT",Vector2(1135,440),Vector2(105,55),func(): camera_turn=1,func(): camera_turn=0)
    _button(layer,"GARAGE",Vector2(1040,300),Vector2(200,50),_toggle_garage,func(): pass)
    _make_garage(layer)
    drive_controls.append(_button(layer,"STEER LEFT",Vector2(10,590),Vector2(140,70),func(): steering=-1,func(): steering=0))
    drive_controls.append(_button(layer,"STEER RIGHT",Vector2(160,590),Vector2(140,70),func(): steering=1,func(): steering=0))
    drive_controls.append(_button(layer,"ACCELERATOR",Vector2(1020,510),Vector2(220,70),func(): accelerator=true,func(): accelerator=false))
    drive_controls.append(_button(layer,"BRAKE",Vector2(1020,365),Vector2(220,60),func(): braking=true,func(): braking=false))
    drive_controls.append(_button(layer,"REVERSE",Vector2(1020,680),Vector2(220,38),func(): reversing=true,func(): reversing=false))
    drive_controls.append(_button(layer,"HANDBRAKE",Vector2(10,510),Vector2(140,65),func(): handbrake=true,func(): handbrake=false))
    drive_controls.append(_button(layer,"HORN",Vector2(160,510),Vector2(140,65),_start_horn,_stop_horn))
    for control in drive_controls:
        var icon_names={"STEER LEFT":"left","STEER RIGHT":"right","ACCELERATOR":"accelerator","BRAKE":"brake","REVERSE":"reverse","HANDBRAKE":"handbrake","HORN":"horn"}
        control.icon=load("res://assets/icons/"+icon_names[control.text]+".svg")
        control.expand_icon=true
        control.add_theme_constant_override("icon_max_width",38)
        control.icon_alignment=HORIZONTAL_ALIGNMENT_LEFT
        control.add_theme_font_size_override("font_size",14)
    var layouts={"STEER LEFT":Rect2(10,675,120,40),"STEER RIGHT":Rect2(180,675,120,40),"ACCELERATOR":Rect2(1160,495,85,160),"BRAKE":Rect2(1045,520,100,130),"REVERSE":Rect2(920,590,100,65),"HANDBRAKE":Rect2(10,420,140,65),"HORN":Rect2(160,420,140,65)}
    for control in drive_controls:
        control.set_meta("role",control.text)
        var layout: Rect2=layouts[control.text]
        control.position=layout.position
        control.size=layout.size
        if control.text in ["ACCELERATOR","BRAKE"]:
            control.vertical_icon_alignment=VERTICAL_ALIGNMENT_BOTTOM
            control.icon_alignment=HORIZONTAL_ALIGNMENT_CENTER
            control.alignment=HORIZONTAL_ALIGNMENT_CENTER
            control.text="ACCEL" if control.text=="ACCELERATOR" else "BRAKE"
            control.add_theme_font_size_override("font_size",12)
        var pedal_style:=StyleBoxFlat.new()
        pedal_style.bg_color=Color("28343b")
        pedal_style.border_color=Color("86959a")
        pedal_style.set_border_width_all(2)
        pedal_style.set_corner_radius_all(9)
        control.add_theme_stylebox_override("normal",pedal_style)
    dashboard=Control.new()
    dashboard.set_script(preload("res://driving_dashboard.gd"))
    dashboard.world=self
    layer.add_child(dashboard)
    _button(layer,"KERALA MAP",Vector2(800,240),Vector2(210,55),_toggle_kerala_map,func(): pass)
    kerala_map=Control.new()
    kerala_map.set_script(load("res://kerala_map.gd"))
    kerala_map.position=Vector2(160,45)
    kerala_map.size=Vector2(960,630)
    kerala_map.z_index=50
    kerala_map.visible=false
    layer.add_child(kerala_map)
    speed_label=Label.new()
    speed_label.position=Vector2(350,660)
    speed_label.add_theme_font_size_override("font_size",22)
    layer.add_child(speed_label)
    _update_controls()
    var map := Control.new()
    map.set_script(load("res://minimap.gd"))
    map.world = self
    map.position=Vector2(1040,20)
    map.size=Vector2(200,200)
    map.mouse_filter=Control.MOUSE_FILTER_IGNORE
    layer.add_child(map)

func _button(layer: Node, title: String, pos: Vector2, size: Vector2, down: Callable, up: Callable):
    var b := Button.new()
    b.text=title
    b.position=pos
    b.size=size
    b.set_meta("touch_down",down)
    b.set_meta("touch_up",up)
    touch_buttons.append(b)
    b.button_down.connect(down)
    b.button_up.connect(up)
    layer.add_child(b)
    return b

func _toggle_car():
    if paused: return
    if in_car:
        if absf(car_speed)>1:
            mode.text="Brake to stop before exiting."
            return
        var exit_position := Vector3.ZERO
        var found_exit := false
        for offset in [Vector3(3,0,0),Vector3(-3,0,0),Vector3(0,0,3),Vector3(0,0,-3)]:
            var candidate: Vector3 = car.position + offset
            if abs(candidate.x)<WORLD_LIMIT and abs(candidate.z)<WORLD_LIMIT and not _inside_block(candidate):
                exit_position = candidate + Vector3(0,0.9,0)
                found_exit = true
                break
        if found_exit:
            in_car=false
            player.position = exit_position
            player.visible=true
    elif player.position.distance_to(car.position) < 6:
        in_car=true
        player.visible=false
    _update_controls()
    _save_progress()
    _update_info()

func _physics_process(delta):
    if paused: return
    var previous_car_position:=car.position
    features.tick(delta)
    _move_traffic(delta)
    _update_combat(delta)
    var keys := Input.get_vector("ui_left","ui_right","ui_up","ui_down")
    var motion := input_dir if input_dir.length()>0 else keys
    motion=motion.limit_length(1)
    var speed_multiplier := 1.65 if boosting else 1.0
    if in_car:
        _drive(delta,steering if steering!=0 else motion.x,1.0 if accelerator else maxf(0,-motion.y),braking or handbrake or motion.y>0 or Input.is_physical_key_pressed(KEY_SPACE),reversing or Input.is_physical_key_pressed(KEY_R))
    else:
        player.velocity = Vector3(motion.x*5*speed_multiplier, -2, motion.y*5*speed_multiplier)
        if _traffic_blocked(player.position + player.velocity*delta,2.2):
            player.velocity.x=0
            player.velocity.z=0
        if features.blocks_vehicle(player.position,player.position+player.velocity*delta):
            player.velocity.x=0
            player.velocity.z=0
        player.move_and_slide()
        player.position.x=clampf(player.position.x,-WORLD_LIMIT,WORLD_LIMIT)
        player.position.z=clampf(player.position.z,-WORLD_LIMIT,WORLD_LIMIT)
    human_visual.set_motion(Vector3(player.velocity.x,0,player.velocity.z) if not in_car else Vector3.ZERO)
    _sync_engine()
    var focus := car.position if in_car else player.position
    _update_camera(focus,delta)
    speed_label.text=("%d km/h  |  %s" % [int(absf(car_speed)*3.6),"REVERSE" if car_speed<0 else "DRIVE"]) if in_car else "Drag open space to orbit camera 360 degrees"
    if in_car: _record_drive(previous_car_position.distance_to(car.position),absf(car_speed)*3.6)
    if horn_down and not horn.playing: horn.play()
    for place in landmarks:
        if focus.distance_to(place.position)<10 and not discovered.has(place.name):
            discovered.append(place.name)
            _save_progress()
    autosave_time+=delta
    if autosave_time>=10:
        autosave_time=0
        _save_progress()
    _vehicle_lights()
    _update_info()

func _inside_block(pos: Vector3) -> bool:
    return town.blocked(pos)

func _update_info():
    info.text="KADAVU DRIVE   |   FREE ROAM"
    mode.text="%.2f km explored   |   Top %d km/h   |   Places %d/%d" % [distance_driven/1000,int(top_speed),discovered.size(),landmarks.size()]
    if wanted_time>0: mode.text+="   |   WANTED  HP %d" % int(health)

func _record_drive(distance: float, speed: float):
    if is_finite(distance) and distance>=0: distance_driven+=distance
    if is_finite(speed): top_speed=maxf(top_speed,speed)

func _save_progress():
    var data:=legacy_progress.duplicate(true)
    data.merge({"format":3,"vehicle":vehicle_kind,"character":character_kind,"paint":paint_index,"daylight":daylight,"headlights":headlights,"distance":distance_driven,"top_speed":top_speed,"discovered":discovered,"camera_angle":camera_angle,"camera_pitch":camera_pitch,"money":money,"player":[player.position.x,player.position.z],"car":[car.position.x,car.position.z],"car_yaw":car.rotation.y,"driving":in_car},true)
    var f := FileAccess.open("user://city_save.json",FileAccess.WRITE)
    if f: f.store_string(JSON.stringify(data))

func _load_progress():
    if not FileAccess.file_exists("user://city_save.json"): return
    var f := FileAccess.open("user://city_save.json",FileAccess.READ)
    if not f: return
    var data = JSON.parse_string(f.get_as_text())
    if data is Dictionary:
        legacy_progress=data.duplicate(true)
        money=maxi(int(data.get("money",0)),0)
        var saved_character=data.get("character",0)
        _set_character(clampi(int(saved_character),0,1) if (saved_character is int or saved_character is float) and is_finite(float(saved_character)) else 0)
        _set_vehicle(clampi(int(data.get("vehicle",0)),0,fleet.NAMES.size()-1))
        paint_index=clampi(int(data.get("paint",0)),0,PAINTS.size()-1)
        daylight=clampi(int(data.get("daylight",0)),0,2)
        headlights=bool(data.get("headlights",false))
        distance_driven=_safe_number(data.get("distance",0),0,1e12)
        top_speed=_safe_number(data.get("top_speed",0),0,300)
        discovered.clear()
        var stored_places=data.get("discovered",[])
        if stored_places is Array:
            for place in landmarks:
                if stored_places.has(place.name): discovered.append(place.name)
        car.rotation.y=_safe_number(data.get("car_yaw",0),-TAU,TAU)
        _apply_daylight()
        _paint_car()
        _vehicle_lights()
        player.position = _restore_position(data.get("player"),player.position)
        car.position = _restore_position(data.get("car"),car.position)
        in_car=bool(data.get("driving",false))
        player.visible=not in_car
        var yaw=data.get("camera_angle",0.0)
        var pitch=data.get("camera_pitch",0.45)
        if (yaw is int or yaw is float) and is_finite(float(yaw)): camera_angle=wrapf(float(yaw),-PI,PI)
        if (pitch is int or pitch is float) and is_finite(float(pitch)): camera_pitch=clampf(float(pitch),0.18,1.1)
        _update_controls()

func _restore_position(data, fallback: Vector3) -> Vector3:
    if not data is Array or data.size()!=2: return fallback
    if not (data[0] is float or data[0] is int) or not (data[1] is float or data[1] is int): return fallback
    var value := Vector3(float(data[0]),fallback.y,float(data[1]))
    if not value.is_finite() or abs(value.x)>WORLD_LIMIT or abs(value.z)>WORLD_LIMIT or _inside_block(value): return fallback
    return value

func _toggle_pause():
    _stop_horn()
    if is_instance_valid(garage_panel) and garage_panel.visible: return
    _clear_touches()
    paused=not paused
    input_dir=Vector2.ZERO
    boosting=false
    accelerator=false
    braking=false
    reversing=false
    steering=0
    handbrake=false
    camera_turn=0
    camera_touch=-1
    pause_button.text="RESUME" if paused else "PAUSE"
    if paused:
        human_visual.set_motion(Vector3.ZERO)
        _save_progress()
    _sync_engine()

func _notification(what):
    if what==NOTIFICATION_APPLICATION_PAUSED and is_instance_valid(pause_button) and not paused:
        _toggle_pause()

func _make_traffic():
    for i in range(12):
        var vehicle := Node3D.new()
        add_child(vehicle)
        var route: PackedVector3Array=town.roads[2]
        vehicle.position=route[i*8%route.size()]
        vehicle.set_meta("progress",float(i*8))
        vehicle.set_meta("kind",i%fleet.NAMES.size())
        _car_model(vehicle)
        traffic.append(vehicle)

func _traffic_blocked(pos: Vector3, radius: float) -> bool:
    for vehicle in traffic:
        if Vector2(pos.x-vehicle.position.x,pos.z-vehicle.position.z).length()<radius: return true
    return false

func _move_traffic(delta: float):
    var route: PackedVector3Array=town.roads[2]
    for vehicle in traffic:
        var progress: float=vehicle.get_meta("progress")
        var index:=int(progress)%(route.size()-1)
        var length:=maxf(0.1,route[index].distance_to(route[index+1]))
        var next_progress:=fposmod(progress+6*delta/length,route.size()-1)
        var next_index:=int(next_progress)
        var next:=route[next_index].lerp(route[next_index+1],fposmod(next_progress,1.0))
        var focus: Vector3=car.position if in_car else player.position
        if Vector2(next.x-focus.x,next.z-focus.z).length()>4 and not features.stop_traffic(progress,next):
            fleet.animate(vehicle,vehicle.position.distance_to(next),0)
            vehicle.position=next
            vehicle.set_meta("progress",next_progress)
        var direction:=route[next_index+1]-route[next_index]
        vehicle.rotation.y=atan2(direction.x,direction.z)


func _make_combatants():
    for pos in [Vector3(0,0,-15), Vector3(40,0,15), Vector3(-40,0,-50)]:
        var rival := Node3D.new()
        add_child(rival)
        rival.position = town.nearest(pos)
        var person:=Node3D.new()
        person.set_script(preload("res://human.gd"))
        rival.add_child(person)
        rival.set_meta("hp", 3)
        rivals.append(rival)
    police = Node3D.new()
    add_child(police)
    police.position = town.nearest(Vector3(-40,0,0))
    var officer:=Node3D.new()
    officer.set_script(preload("res://human.gd"))
    police.add_child(officer)
    police.visible = false

# Aim at the closest visible rival within range. Buildings block shots.
func _fire():
    if paused or in_car or shot_cooldown > 0: return
    shot_cooldown = 0.4
    var target: Node3D = null
    var best := 16.0
    for rival in rivals:
        if not rival.visible: continue
        var distance := player.position.distance_to(rival.position + Vector3(0,0.9,0))
        if distance < best and _clear_shot(player.position, rival.position):
            best = distance
            target = rival
    wanted_time = 25.0
    if target:
        target.set_meta("hp", int(target.get_meta("hp")) - 1)
        if int(target.get_meta("hp")) <= 0:
            target.visible = false
            money += 50
            _save_progress()
    _update_info()

func _clear_shot(from: Vector3, to: Vector3) -> bool:
    for i in range(1, 20):
        if _inside_block(from.lerp(to, i / 20.0)): return false
    return true

func _update_combat(delta: float):
    shot_cooldown = maxf(0.0, shot_cooldown - delta)
    police_damage_cooldown = maxf(0.0, police_damage_cooldown - delta)
    if wanted_time <= 0:
        police.visible = false
        return
    wanted_time = maxf(0.0, wanted_time - delta)
    if wanted_time <= 0:
        police.visible = false
        _update_info()
        return
    police.visible = true
    var focus: Vector3 = car.position if in_car else player.position
    var diff := Vector2(focus.x - police.position.x, focus.z - police.position.z)
    if diff.length() > 2:
        var step := diff.normalized() * minf(4.0 * delta, diff.length())
        var next := police.position + Vector3(step.x, 0, step.y)
        if not _inside_block(next):
            police.position = next
        else:
            var x_only := police.position + Vector3(step.x, 0, 0)
            var z_only := police.position + Vector3(0, 0, step.y)
            if not _inside_block(x_only): police.position = x_only
            elif not _inside_block(z_only): police.position = z_only
    elif police_damage_cooldown <= 0:
        police_damage_cooldown = 1.0
        health -= 15.0
        if health <= 0:
            _respawn()
        _update_info()

func _respawn():
    health = 100.0
    wanted_time = 0.0
    police.visible = false
    money = maxi(0, money - 100)
    in_car = false
    player.visible = true
    player.position = Vector3(0,0.9,3)
    player.velocity = Vector3.ZERO
    _update_controls()
    _save_progress()


func _drive(delta: float, steering: float, throttle: float, braking: bool, reversing: bool):
    var remaining:=minf(delta,0.25)
    while remaining>0:
        var step:=minf(remaining,1.0/60.0)
        remaining-=step
        if braking:
            car_speed=move_toward(car_speed,0,22*step)
        elif reversing:
            car_speed=move_toward(car_speed,-7,7*step)
        elif throttle>0:
            car_speed=move_toward(car_speed,fleet.SPEEDS[vehicle_kind],9*throttle*step)
        else:
            car_speed=move_toward(car_speed,0,3*step)
        var offroad:=town.nearest(car.position).distance_to(car.position)>6
        if offroad: car_speed=clampf(car_speed,-4,6)
        car.rotation.y-=steering*1.4*step*clampf(car_speed/8,-1,1)
        var forward:=Vector3(sin(car.rotation.y),0,cos(car.rotation.y))
        var next:=car.position+forward*car_speed*step
        if abs(next.x)>WORLD_LIMIT or abs(next.z)>WORLD_LIMIT or town.blocked(next,2 if vehicle_kind==0 else maxf(1,fleet.LENGTHS[vehicle_kind]/2)) or _traffic_blocked(next,3.4) or features.blocks_vehicle(car.position,next):
            car_speed=0
            break
        car.position=next
        fleet.animate(car,car_speed*step,steering)

func _update_controls():
    _stop_horn()
    _clear_touches()
    for control in foot_controls: control.visible=not in_car
    for control in drive_controls: control.visible=in_car
    boost_button.visible=not in_car
    fire_button.visible=not in_car
    input_dir=Vector2.ZERO
    accelerator=false
    braking=false
    reversing=false
    car_speed=0
    steering=0
    handbrake=false
    _sync_engine()

func _orbit(yaw: float, pitch: float):
    camera_angle=wrapf(camera_angle+yaw,-PI,PI)
    camera_pitch=clampf(camera_pitch+pitch,0.18,1.1)

func _unhandled_input(event):
    if paused: return
    if event is InputEventScreenTouch:
        if event.pressed and camera_touch==-1: camera_touch=event.index
        elif not event.pressed and event.index==camera_touch: camera_touch=-1
    elif event is InputEventScreenDrag and event.index==camera_touch:
        _orbit(-event.relative.x*0.008,event.relative.y*0.006)
    elif event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_RIGHT:
        _orbit(-event.relative.x*0.008,event.relative.y*0.006)

func _update_camera(focus: Vector3, delta: float):
    _orbit(camera_turn*delta*1.5,0)
    var distance: float=8.0+maxf(0,fleet.LENGTHS[vehicle_kind]-4.2)*0.5 if in_car else 9.0
    var heading: float=camera_angle+car.rotation.y+PI if in_car else camera_angle
    var offset:=Vector3(sin(heading)*cos(camera_pitch),sin(camera_pitch),cos(heading)*cos(camera_pitch))*distance
    var origin:=focus+Vector3(0,1.4,0)
    var desired:=origin+offset
    var query:=PhysicsRayQueryParameters3D.create(origin,desired)
    query.exclude=[player.get_rid()]
    var hit=get_world_3d().direct_space_state.intersect_ray(query)
    if not hit.is_empty(): desired=hit.position+hit.normal*0.6
    camera.position=camera.position.lerp(desired,minf(delta*9,1))
    if camera.position.distance_to(origin)>0.1: camera.look_at(origin,Vector3.UP)

func _input(event):
    if is_instance_valid(garage_panel) and garage_panel.visible:
        if (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT):
            for button in touch_buttons:
                if garage_panel.is_ancestor_of(button) and button.get_global_rect().has_point(event.position):
                    button.get_meta("touch_down").call()
                    break
        get_viewport().set_input_as_handled()
        return

    if is_instance_valid(kerala_map) and kerala_map.visible:
        if (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT):
            if kerala_map.select_at(event.position-kerala_map.position): _toggle_kerala_map()
        get_viewport().set_input_as_handled()
        return
    if dashboard.handle(event):
        get_viewport().set_input_as_handled()
        return
    if event is InputEventScreenTouch:
        if event.pressed:
            for button in touch_buttons:
                if button.is_visible_in_tree() and button.get_global_rect().has_point(event.position):
                    active_touches[event.index]=button
                    button.modulate=Color(0.75,1,0.75)
                    button.get_meta("touch_down").call()
                    get_viewport().set_input_as_handled()
                    return
        else:
            if active_touches.has(event.index):
                var button: Button=active_touches[event.index]
                active_touches.erase(event.index)
                button.modulate=Color.WHITE
                button.get_meta("touch_up").call()
                get_viewport().set_input_as_handled()
            if event.index==camera_touch: camera_touch=-1
    elif event is InputEventScreenDrag and event.index==camera_touch and not paused:
        _orbit(-event.relative.x*0.008,event.relative.y*0.006)
        get_viewport().set_input_as_handled()

func _clear_touches():
    if is_instance_valid(dashboard): dashboard.reset()
    for button in active_touches.values():
        button.modulate=Color.WHITE
        button.get_meta("touch_up").call()
    active_touches.clear()

func _make_engine_sound():
    engine_audio=AudioStreamPlayer.new()
    engine_audio.stream=preload("res://vehicle_audio.gd").new().engine()
    engine_audio.volume_db=-16
    add_child(engine_audio)

func _sync_engine():
    if not is_instance_valid(engine_audio): return
    if in_car and not paused:
        if not engine_audio.playing: engine_audio.play()
        engine_audio.pitch_scale=clampf(0.85+absf(car_speed)/22.0*1.0+(0.15 if accelerator else 0.0),0.85,2.0)
    elif engine_audio.playing: engine_audio.stop()

func _toggle_kerala_map():
    if kerala_map.visible:
        kerala_map.visible=false
        if map_paused_game: _toggle_pause()
        map_paused_game=false
    else:
        map_paused_game=not paused
        if map_paused_game: _toggle_pause()
        kerala_map.visible=true
    _sync_engine()

func _safe_number(value, minimum: float, maximum: float) -> float:
    if not (value is int or value is float) or not is_finite(float(value)): return minimum
    return clampf(float(value),minimum,maximum)

func _paint_car():
    for paint in car.get_meta("paints",[]):
        paint.albedo_color=PAINTS[paint_index].darkened(0.35) if paint.resource_name.begins_with("Paint 2") else PAINTS[paint_index]

func _vehicle_lights():
    var lamps: Dictionary=car.get_meta("lamps",{})
    if lamps.has("Headlight"): lamps.Headlight.emission_energy_multiplier=3.0 if headlights else 0.1
    if lamps.has("Brakelight"): lamps.Brakelight.emission_energy_multiplier=4.0 if in_car and (braking or handbrake) else 0.2
    for side in ["Left","Right"]:
        car.get_node("Beam"+side).visible=headlights
        var lamp: MeshInstance3D=car.get_node("Reverse"+side)
        lamp.material_override.emission=Color.WHITE if in_car and car_speed<0 else Color.BLACK

func _apply_daylight():
    sun.rotation_degrees=Vector3([-52,-12,-7][daylight],-25,0)
    sun.light_color=[Color("fff5df"),Color("ffb56e"),Color("8eaacb")][daylight]
    sun.light_energy=[0.85,0.65,0.12][daylight]
    sky.background_color=[Color("91b9d4"),Color("c69a83"),Color("253549")][daylight]
    var gradient: ProceduralSkyMaterial=sky.sky.sky_material
    gradient.sky_top_color=[Color("5284a0"),Color("6b7589"),Color("101b35")][daylight]
    gradient.sky_horizon_color=[Color("c2cacc"),Color("d8a27f"),Color("4b5f77")][daylight]
    gradient.ground_horizon_color=gradient.sky_horizon_color
    sky.ambient_light_energy=[0.5,0.4,0.25][daylight]

func _make_garage(layer: CanvasLayer):
    garage_panel=Panel.new()
    garage_panel.position=Vector2(260,110)
    garage_panel.size=Vector2(760,450)
    garage_panel.z_index=60
    var backdrop:=StyleBoxFlat.new()
    backdrop.bg_color=Color("202f36")
    backdrop.corner_radius_top_left=12
    backdrop.corner_radius_top_right=12
    backdrop.corner_radius_bottom_left=12
    backdrop.corner_radius_bottom_right=12
    garage_panel.add_theme_stylebox_override("panel",backdrop)
    layer.add_child(garage_panel)
    var title:=Label.new()
    title.text="GARAGE & FREE DRIVE"
    title.position=Vector2(32,25)
    title.add_theme_font_size_override("font_size",30)
    garage_panel.add_child(title)
    garage_status=Label.new()
    garage_status.position=Vector2(32,83)
    garage_status.add_theme_font_size_override("font_size",22)
    garage_panel.add_child(garage_status)
    _button(garage_panel,"PAINT",Vector2(32,150),Vector2(210,65),func():
        paint_index=(paint_index+1)%PAINTS.size()
        _paint_car()
        _garage_update(),func(): pass)
    _button(garage_panel,"TIME OF DAY",Vector2(270,150),Vector2(210,65),func():
        daylight=(daylight+1)%3
        _apply_daylight()
        _garage_update(),func(): pass)
    _button(garage_panel,"HEADLIGHTS",Vector2(508,150),Vector2(210,65),func():
        headlights=not headlights
        _vehicle_lights()
        _garage_update(),func(): pass)
    var help:=Label.new()
    help.text="Roam freely and find four town landmarks.\nYour progress saves automatically.\nStop the car before opening the garage."
    help.position=Vector2(32,250)
    help.add_theme_font_size_override("font_size",17)
    garage_panel.add_child(help)
    character_button=_button(garage_panel,"CHARACTER: MALE",Vector2(508,245),Vector2(210,65),func():
        _set_character(1-character_kind)
        _garage_update(),func(): pass)
    _button(garage_panel,"VEHICLE",Vector2(32,360),Vector2(190,60),func():
        _set_vehicle((vehicle_kind+1)%fleet.NAMES.size())
        _garage_update(),func(): pass)
    _button(garage_panel,"REAL MAP DRIVE",Vector2(540,360),Vector2(200,60),func():
        _save_progress()
        get_tree().change_scene_to_file("res://geodrive.tscn"),func(): pass)
    _button(garage_panel,"BACK TO DRIVE",Vector2(240,360),Vector2(280,60),_toggle_garage,func(): pass)
    garage_panel.visible=false

func _garage_update():
    garage_status.text="%s / %s  |  %s  |  Lights %s" % [fleet.NAMES[vehicle_kind],PAINT_NAMES[paint_index],["Day","Sunset","Evening"][daylight],"ON" if headlights else "OFF"]
    character_button.text="CHARACTER: %s" % ["MALE","FEMALE"][character_kind]
    _save_progress()

func _set_character(kind: int):
    character_kind=clampi(kind,0,1)
    human_visual.set_appearance(character_kind)

func _toggle_garage():
    if garage_panel.visible:
        garage_panel.visible=false
        if garage_paused_game: _toggle_pause()
        garage_paused_game=false
    else:
        if absf(car_speed)>1:
            mode.text="Brake to stop before opening the garage."
            return
        garage_paused_game=not paused
        if garage_paused_game: _toggle_pause()
        garage_panel.visible=true
        _garage_update()

func _set_vehicle(kind: int):
    if kind==vehicle_kind and car.has_node("CarVisual"): return
    _stop_horn()
    vehicle_kind=kind
    for child in car.get_children():
        car.remove_child(child)
        child.queue_free()
    car.set_meta("wheel_nodes",[])
    _car_model(car)
    _paint_car()
    _vehicle_lights()
    car_speed=0

func _start_horn():
    if paused or not in_car: return
    horn_down=true
    horn.pitch_scale=[1.0,1.18,1.1,0.7,0.9,0.65][vehicle_kind]
    horn.play()

func _stop_horn():
    horn_down=false
    if is_instance_valid(horn): horn.stop()
