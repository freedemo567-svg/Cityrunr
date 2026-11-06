extends Node3D
# Geographic vector prototype. Buildings are approximate boxes, terrain is flat.
const DATA := "res://assets/kerala/tiles/"
var manifest: Dictionary={}
var fleet=preload("res://fleet.gd").new()
var car: Node3D
var camera: Camera3D
var in_car := true
var paused := false
var steering := 0.0
var speed := 0.0
var pedal := false
var brake := false
var reverse := false
var handbrake := false
var horn_down := false
var kind := 0
var info: Label
var picker: OptionButton
var matches: Array=[]
var loaded: Dictionary={}
var tile_center:=Vector2i(99999,99999)
var dashboard: Control
var buttons: Array[Button]=[]
var touches: Dictionary={}
var engine_audio: AudioStreamPlayer
var horn: AudioStreamPlayer
var yaw := 0.0
var road_count := 0
var ground: MeshInstance3D
func mat(color: Color) -> StandardMaterial3D:
    var m:=StandardMaterial3D.new()
    m.albedo_color=color
    m.roughness=0.9
    m.cull_mode=BaseMaterial3D.CULL_DISABLED
    return m
func _ready():
    var sun:=DirectionalLight3D.new()
    sun.rotation_degrees=Vector3(-50,-30,0)
    sun.light_energy=1.1
    add_child(sun)
    var env:=WorldEnvironment.new()
    var settings:=Environment.new()
    settings.background_mode=Environment.BG_COLOR
    settings.background_color=Color("a4c1ce")
    settings.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
    settings.ambient_light_color=Color("c7d0ca")
    settings.ambient_light_energy=0.7
    env.environment=settings
    add_child(env)
    ground=MeshInstance3D.new()
    var plane:=PlaneMesh.new()
    plane.size=Vector2(12000,12000)
    ground.mesh=plane
    ground.material_override=mat(Color("6c805d"))
    ground.position.y=-0.05
    add_child(ground)
    car=Node3D.new()
    add_child(car)
    _vehicle()
    camera=Camera3D.new()
    add_child(camera)
    camera.current=true
    engine_audio=AudioStreamPlayer.new()
    engine_audio.stream=preload("res://vehicle_audio.gd").new().engine()
    engine_audio.volume_db=-16
    add_child(engine_audio)
    engine_audio.play()
    horn=AudioStreamPlayer.new()
    horn.stream=preload("res://assets/audio/horn.wav")
    horn.volume_db=-10
    add_child(horn)
    var layer:=CanvasLayer.new()
    add_child(layer)
    info=Label.new()
    info.position=Vector2(20,16)
    info.add_theme_font_size_override("font_size",20)
    layer.add_child(info)
    var search:=LineEdit.new()
    search.placeholder_text="Search Kerala city, town or village"
    search.position=Vector2(20,100)
    search.size=Vector2(360,45)
    search.text_changed.connect(_search)
    layer.add_child(search)
    picker=OptionButton.new()
    picker.position=Vector2(390,100)
    picker.size=Vector2(340,45)
    picker.item_selected.connect(func(index):
        if index<matches.size(): _go(matches[index].point))
    layer.add_child(picker)
    _button(layer,"TOWN",Vector2(1090,30),Vector2(150,45),func(): get_tree().change_scene_to_file("res://main.tscn"),func(): pass)
    _button(layer,"VEHICLE",Vector2(1090,90),Vector2(150,45),func():
        if absf(speed)<0.1:
            kind=(kind+1)%fleet.NAMES.size()
            _vehicle(),func(): pass)
    _button(layer,"PAUSE",Vector2(1090,150),Vector2(150,45),func():
        paused=not paused
        speed=0
        pedal=false
        brake=false
        steering=0
        dashboard.reset()
        reverse=false
        handbrake=false
        horn_down=false
        for button in touches.values():button.get_meta("up").call()
        touches.clear()
        horn.stop()
        if paused: engine_audio.stop()
        else: engine_audio.play(),func(): pass)
    _button(layer,"ACCEL",Vector2(1160,495),Vector2(85,160),func(): pedal=not paused,func(): pedal=false)
    _button(layer,"BRAKE",Vector2(1045,520),Vector2(100,130),func(): brake=not paused,func(): brake=false)
    _button(layer,"REVERSE",Vector2(920,590),Vector2(100,65),func(): reverse=not paused,func(): reverse=false)
    _button(layer,"HANDBRAKE",Vector2(900,510),Vector2(130,65),func(): handbrake=not paused,func(): handbrake=false)
    _button(layer,"HORN",Vector2(20,420),Vector2(130,60),func():
        if not paused:
            horn_down=true
            horn.play(),func():
        horn_down=false
        horn.stop())
    dashboard=Control.new()
    dashboard.set_script(preload("res://driving_dashboard.gd"))
    dashboard.world=self
    layer.add_child(dashboard)
    if FileAccess.file_exists(DATA+"manifest.json"):
        manifest=JSON.parse_string(FileAccess.get_file_as_string(DATA+"manifest.json"))
        _search("Kochi")
        if matches.is_empty(): _search("")
        if not matches.is_empty(): _go(matches[0].point)
        camera.position=car.position+Vector3(0,6,12)
    else:
        camera.position=Vector3(0,6,12)
        camera.look_at(Vector3.ZERO,Vector3.UP)
        info.text="Install Kerala data pack into assets/kerala/tiles. See BUILD_GUIDE_ML.md."
func _button(parent: Node, title: String, pos: Vector2, dimensions: Vector2, down: Callable, up: Callable):
    var b:=Button.new()
    b.text=title
    b.position=pos
    b.size=dimensions
    b.button_down.connect(down)
    b.button_up.connect(up)
    b.set_meta("down",down)
    b.set_meta("up",up)
    buttons.append(b)
    parent.add_child(b)
func _search(query: String):
    picker.clear()
    matches=[]
    var others: Array=[]
    for place in manifest.get("places",[]):
        var name:=str(place.name).to_lower()
        if name==query.to_lower():matches.append(place)
        elif query.to_lower() in name and others.size()<100:others.append(place)
    matches.append_array(others)
    matches=matches.slice(0,100)
    for place in matches:picker.add_item(place.name)
func _go(point: Array):
    car.position=Vector3(point[0],0,point[1])
    speed=0
    tile_center=Vector2i(99999,99999)
    _stream()
    # Spawn at the nearest loaded mapped road instead of a town label inside a building.
    var best:=INF
    var nearest:=car.position
    for tile in loaded.values():
        for segment in tile.roads:
            var closest:=Geometry3D.get_closest_point_to_segment(car.position,segment[0],segment[1])
            var distance:=closest.distance_squared_to(car.position)
            if distance<best:best=distance;nearest=closest
    car.position=nearest
    camera.position=car.position+Vector3(0,6,12)
func _vehicle():
    for node in car.get_children():car.remove_child(node);node.queue_free()
    if kind==0:
        var visual: Node3D=preload("res://assets/car/car-concept.glb").instantiate()
        visual.scale=Vector3(0.72,0.85,0.85)
        visual.position.y=0.135
        car.add_child(visual)
    else:fleet.build(car,kind)
    if is_instance_valid(horn):horn.pitch_scale=[1.0,1.18,1.1,0.7,0.9,0.65][kind]
func _stream():
    var center:=Vector2i(floori(car.position.x/2000),floori(car.position.z/2000))
    if center==tile_center:return
    tile_center=center
    ground.position.x=car.position.x
    ground.position.z=car.position.z
    for key in loaded.keys():
        if absi(key.x-center.x)>1 or absi(key.y-center.y)>1:
            loaded[key].node.queue_free()
            loaded.erase(key)
    for x in range(center.x-1,center.x+2):
        for z in range(center.y-1,center.y+2):
            var key:=Vector2i(x,z)
            if not loaded.has(key):_load_tile(key)
func _load_tile(key: Vector2i):
    var path:=DATA+"%d_%d.json"%[key.x,key.y]
    if not FileAccess.file_exists(path):return
    var data=JSON.parse_string(FileAccess.get_file_as_string(path))
    var node:=Node3D.new()
    node.position=Vector3(key.x*2000,0,key.y*2000)
    add_child(node)
    var roads: Array=[]
    var boxes: Array=[]
    var grid: Dictionary={}
    var surface:=SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)
    for segment in data.roads+data.rail:
        var a:=Vector3(segment[0][0],0.02,segment[0][1])
        var b:=Vector3(segment[1][0],0.02,segment[1][1])
        if a.distance_to(b)<0.01:continue
        var half:=4.0 if segment[2] in ["motorway","trunk","primary","secondary"] else 2.5
        if segment[2] in ["rail","light_rail"]: half=1.0
        surface.set_color(Color("ad9271") if segment[2] in ["rail","light_rail"] else Color.WHITE)
        var side: Vector3=(b-a).normalized().cross(Vector3.UP)*half
        for vertex in [a-side,a+side,b+side,a-side,b+side,b-side]:surface.add_vertex(vertex-node.position)
        if segment[2] not in ["footway","path","steps","pedestrian","cycleway","rail","light_rail"]:roads.append([a,b])
    if not data.roads.is_empty() or not data.rail.is_empty():
        surface.generate_normals()
        var mesh:=MeshInstance3D.new()
        mesh.mesh=surface.commit()
        mesh.material_override=mat(Color("424b4d"))
        mesh.material_override.vertex_color_use_as_albedo=true
        node.add_child(mesh)
    var multimesh:=MultiMesh.new()
    multimesh.transform_format=MultiMesh.TRANSFORM_3D
    multimesh.mesh=BoxMesh.new()
    multimesh.instance_count=data.buildings.size()
    for i in range(data.buildings.size()):
        var points: Array=data.buildings[i][1]
        var minimum:=Vector2(INF,INF)
        var maximum:=Vector2(-INF,-INF)
        for point in points:
            minimum=minimum.min(Vector2(point[0],point[1]))
            maximum=maximum.max(Vector2(point[0],point[1]))
        var dimensions:=maximum-minimum
        var center: Vector2=(minimum+maximum)/2
        var height: float=data.buildings[i][2]
        var transform:=Transform3D(Basis.from_scale(Vector3(maxf(1,dimensions.x),height,maxf(1,dimensions.y))),Vector3(center.x-node.position.x,height/2,center.y-node.position.z))
        multimesh.set_instance_transform(i,transform)
        var bounds:=Rect2(minimum,dimensions).grow(1.3)
        boxes.append(bounds)
        for gx in range(floori(bounds.position.x/32),floori(bounds.end.x/32)+1):
            for gz in range(floori(bounds.position.y/32),floori(bounds.end.y/32)+1):
                var cell:=Vector2i(gx,gz)
                if not grid.has(cell):grid[cell]=[]
                grid[cell].append(bounds)
    var buildings:=MultiMeshInstance3D.new()
    buildings.multimesh=multimesh
    buildings.material_override=mat(Color("b4b3a4"))
    node.add_child(buildings)
    loaded[key]={"node":node,"roads":roads,"boxes":boxes,"grid":grid}
func _blocked(next: Vector3) -> bool:
    var cell:=Vector2i(floori(next.x/32),floori(next.z/32))
    for tile in loaded.values():
        for bounds in tile.grid.get(cell,[]):
            if bounds.has_point(Vector2(next.x,next.z)):return true
    return false
func _physics_process(delta):
    if manifest.is_empty() or paused:return
    var keys:=Input.get_vector("ui_left","ui_right","ui_up","ui_down")
    var throttle:=pedal or keys.y<0
    var stopping:=brake or handbrake or keys.y>0 or Input.is_physical_key_pressed(KEY_SPACE)
    if stopping:speed=move_toward(speed,0,22*delta)
    elif reverse or Input.is_physical_key_pressed(KEY_R):speed=move_toward(speed,-6,7*delta)
    else:speed=move_toward(speed,fleet.SPEEDS[kind] if throttle else 0,(8 if throttle else 3)*delta)
    car.rotation.y+=(steering if steering!=0 else keys.x)*delta*clampf(speed/8,-1,1)
    var next:=car.position+Vector3(sin(car.rotation.y),0,cos(car.rotation.y))*speed*minf(delta,0.1)
    if _blocked(next):speed=0
    else:car.position=next
    _stream()
    engine_audio.pitch_scale=clampf(0.85+absf(speed)/22,0.85,2.0)
    if horn_down and not horn.playing:horn.play()
    camera.position=car.position+Vector3(sin(yaw)*12,6,cos(yaw)*12)
    camera.look_at(car.position+Vector3(0,1,0),Vector3.UP)
    info.text="KERALA GEOGRAPHIC DRIVE   |   %s   |   %d km/h\n%.5f N  %.5f E   |   OSM contributors / ODbL 1.0\nFlat terrain; approximate building boxes. Real road geometry; not photorealistic."%[fleet.NAMES[kind],int(absf(speed)*3.6),10-car.position.z/111320,76+car.position.x/109628.3]
func _input(event):
    if is_instance_valid(dashboard) and dashboard.handle(event):get_viewport().set_input_as_handled();return
    if event is InputEventScreenTouch:
        if event.pressed:
            for button in buttons:
                if button.get_global_rect().has_point(event.position):
                    touches[event.index]=button
                    button.get_meta("down").call()
                    get_viewport().set_input_as_handled()
                    return
        elif touches.has(event.index):
            touches[event.index].get_meta("up").call()
            touches.erase(event.index)
            get_viewport().set_input_as_handled()
    if event is InputEventScreenDrag and not touches.has(event.index) and not paused:yaw-=event.relative.x*0.008
    if event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_RIGHT:yaw-=event.relative.x*0.008
func _notification(what):
    if what==NOTIFICATION_APPLICATION_PAUSED:
        paused=true
        speed=0
        pedal=false
        brake=false
        reverse=false
        handbrake=false
        horn_down=false
        steering=0
        for button in touches.values():button.get_meta("up").call()
        touches.clear()
        if is_instance_valid(horn):horn.stop()
        if is_instance_valid(engine_audio):engine_audio.stop()
        if is_instance_valid(dashboard):dashboard.reset()
