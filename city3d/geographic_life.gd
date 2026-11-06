extends Node
const PAINTS=[Color("245b87"),Color("a52c28"),Color("d2d0c6"),Color("30343b"),Color("2c654d")]
var crossings: Node3D
var world: Node3D
var player: Node3D
var human: Node3D
var garage: Panel
var overview: Control
var sun: DirectionalLight3D
var environment: Environment
var character:=0
var paint:=0
var daylight:=0
var headlights:=false
var distance_driven:=0.0
var top_speed:=0.0
var discovered: Array=[]
var input_dir:=Vector2.ZERO
var sprint:=false
var autosave:=0.0
var discovery_tick:=0.0
var traffic: Array=[]
var traffic_origin:=Vector3(INF,0,0)
var health:=100.0
var money:=0
var wanted:=0.0
var shot_cooldown:=0.0
var rivals: Array=[]
var police: Node3D
var menu_was_paused:=false
func setup(w: Node3D, layer: CanvasLayer, light: DirectionalLight3D, env: Environment):
    world=w
    crossings=Node3D.new()
    crossings.set_script(preload("res://geographic_crossings.gd"))
    world.add_child(crossings)
    sun=light
    environment=env
    player=Node3D.new()
    world.add_child(player)
    human=Node3D.new()
    human.set_script(preload("res://human.gd"))
    player.add_child(human)
    player.visible=false
    w._button(layer,"ENTER / EXIT",Vector2(750,30),Vector2(170,45),toggle_car,func():pass)
    w._button(layer,"GARAGE",Vector2(1090,30),Vector2(150,45),toggle_garage,func():pass)
    w._button(layer,"KERALA MAP",Vector2(750,90),Vector2(170,45),toggle_map,func():pass)
    for entry in [["WALK ↑",Vector2(150,490),Vector2(0,-1)],["WALK ↓",Vector2(150,620),Vector2(0,1)],["WALK ←",Vector2(30,555),Vector2(-1,0)],["WALK →",Vector2(270,555),Vector2(1,0)]]:
        var direction: Vector2=entry[2]
        w._button(layer,entry[0],entry[1],Vector2(110,60),func():input_dir+=direction,func():input_dir-=direction)
    w._button(layer,"SPRINT",Vector2(1130,610),Vector2(110,60),func():sprint=true,func():sprint=false)
    w._button(layer,"FIRE",Vector2(1000,610),Vector2(110,60),fire,func():pass)
    garage=Panel.new()
    garage.position=Vector2(250,180)
    garage.size=Vector2(770,310)
    garage.z_index=60
    layer.add_child(garage)
    var title:=Label.new()
    title.text="KERALA GARAGE — changes save automatically"
    title.position=Vector2(25,20)
    garage.add_child(title)
    for entry in [["CHARACTER",Vector2(25,75),func():character=1-character;human.set_appearance(character);save()],["PAINT",Vector2(265,75),func():paint=(paint+1)%PAINTS.size();apply_vehicle();save()],["HEADLIGHTS",Vector2(505,75),func():headlights=not headlights;apply_vehicle();save()],["TIME OF DAY",Vector2(25,170),func():daylight=(daylight+1)%3;apply_daylight();save()],["VEHICLE",Vector2(265,170),func():world.kind=(world.kind+1)%6;world._vehicle();save()],["BACK",Vector2(505,170),toggle_garage]]:
        w._button(garage,entry[0],entry[1],Vector2(220,65),entry[2],func():pass)
    garage.hide()
    overview=Control.new()
    overview.set_script(preload("res://kerala_map.gd"))
    overview.position=Vector2(180,40)
    overview.size=Vector2(920,640)
    overview.z_index=70
    layer.add_child(overview)
    overview.hide()
    for i in range(3):
        var rival:=Node3D.new()
        var model:=Node3D.new()
        model.set_script(preload("res://human.gd"))
        rival.add_child(model)
        world.add_child(rival)
        rival.set_meta("hp",3)
        rivals.append(rival)
    police=Node3D.new()
    var officer:=Node3D.new()
    officer.set_script(preload("res://human.gd"))
    police.add_child(officer)
    world.add_child(police)
    police.hide()
    apply_vehicle()
    apply_daylight()
func nearest_road(point: Vector3) -> Vector3:
    var best:=INF
    var result:=point
    for tile in world.loaded.values():
        for segment in tile.roads:
            var candidate:=Geometry3D.get_closest_point_to_segment(point,segment[0],segment[1])
            var distance:=candidate.distance_squared_to(point)
            if distance<best:best=distance;result=candidate
    return Vector3(result.x,0,result.z)
func relocate():
    if not is_instance_valid(player):return
    player.position=world.car.position
    for i in range(rivals.size()):
        rivals[i].position=nearest_road(world.car.position+Vector3(8+i*8,0,10))
        rivals[i].show()
        rivals[i].set_meta("hp",3)
    if is_instance_valid(police):police.position=nearest_road(world.car.position+Vector3(35,0,0))
    traffic_origin=Vector3(INF,0,0)
func toggle_car():
    if world.paused or absf(world.speed)>0.3:return
    input_dir=Vector2.ZERO
    sprint=false
    if world.in_car:
        var found:=false
        for offset in [Vector3(2.5,0,0),Vector3(-2.5,0,0),Vector3(0,0,-4),Vector3(0,0,4)]:
            var point: Vector3=world.car.position+world.car.basis*offset
            if not world._blocked(point) and not world.train.blocks(point):
                player.position=point;found=true;break
        if not found:return
    elif player.position.distance_to(world.car.position)>5:return
    world.in_car=not world.in_car
    player.visible=not world.in_car
    update_controls()
    world.pedal=false;world.brake=false;world.steering=0
    world.horn_down=false;world.horn.stop()
    world.dashboard.reset()
    if world.in_car:world.engine_audio.play()
    else:world.engine_audio.stop()
    save()
func traffic_blocks(point: Vector3) -> bool:
    if crossings.blocks(point):return true
    for item in traffic:
        if item.node.position.distance_to(point)<2.3:return true
    return false
func toggle_garage():
    if overview.visible:return
    if garage.visible:
        garage.hide();world.paused=menu_was_paused
        if not world.paused and world.in_car:world.engine_audio.play()
    elif absf(world.speed)<0.3:
        menu_was_paused=world.paused
        world._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
        garage.show()
    save()
func toggle_map():
    if garage.visible:return
    if overview.visible:
        overview.hide();world.paused=menu_was_paused
        if not world.paused and world.in_car:world.engine_audio.play()
    else:
        menu_was_paused=world.paused
        world._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
        overview.show()
func handle(event: InputEvent) -> bool:
    if overview.visible:
        if event is InputEventScreenTouch and event.pressed:
            if overview.select_at(event.position-overview.position):toggle_map()
        elif event is InputEventMouseButton and event.pressed:
            if overview.select_at(event.position-overview.position):toggle_map()
        return true
    if event is InputEventKey and event.pressed and not event.echo:
        if event.physical_keycode==KEY_E:toggle_car();return true
        if event.physical_keycode==KEY_G:toggle_garage();return true
        if event.physical_keycode==KEY_F:fire();return true
    return false
func apply_vehicle():
    for material in world.car.get_meta("paints",[]):material.albedo_color=PAINTS[paint]
    var lamps: Dictionary=world.car.get_meta("lamps",{})
    if lamps.has("Headlight"):lamps.Headlight.emission_energy_multiplier=3.0 if headlights else 0.1
    for side in [-1,1]:
        var beam:=SpotLight3D.new()
        beam.name="Headlamp%d"%side
        beam.position=Vector3(side*0.65,0.65,world.fleet.LENGTHS[world.kind]*0.4)
        beam.rotation.y=PI
        beam.spot_range=35
        beam.spot_angle=35
        beam.light_energy=2
        beam.visible=headlights
        var previous=world.car.get_node_or_null(NodePath(beam.name))
        if previous:world.car.remove_child(previous);previous.queue_free()
        world.car.add_child(beam)
func apply_daylight():
    sun.rotation_degrees=Vector3([-50,-12,-7][daylight],-30,0)
    sun.light_color=[Color("fff5df"),Color("ffb56e"),Color("8eaacb")][daylight]
    sun.light_energy=[0.85,0.65,0.12][daylight]
    environment.ambient_light_energy=[0.45,0.35,0.15][daylight]
    environment.sky.sky_material.energy_multiplier=[0.6,0.3,0.06][daylight]
func tick(delta: float):
    var focus: Vector3=world.car.position if world.in_car else player.position
    crossings.refresh(world.loaded.values(),focus)
    crossings.tick(delta,world.train)
    if not world.in_car:
        var movement:=input_dir+Input.get_vector("ui_left","ui_right","ui_up","ui_down")
        movement=movement.limit_length()
        var step:=Vector3(movement.x,0,movement.y).rotated(Vector3.UP,world.yaw)*(6 if sprint or Input.is_physical_key_pressed(KEY_SHIFT) else 3)*minf(delta,0.1)
        var next:=player.position+step
        if not world._path_blocked(player.position,next):player.position=next
        human.set_motion(step/maxf(delta,0.001))
        if step.length()>0.001:human.rotation.y=atan2(step.x,step.z)
        world.info.text="KERALA EXPLORATION | E: enter car | G: garage | F: fire\nHealth %d | Cash %d | %.1f km explored | %d places"%[health,money,distance_driven/1000,discovered.size()]
        world.train.tick(delta,focus)
    update_controls()
    discovery_tick+=delta
    if discovery_tick>=1:
        discovery_tick=0
        for place in world.manifest.get("places",[]):
            var point:=Vector3(place.point[0],0,place.point[1])
            if focus.distance_squared_to(point)<22500 and not discovered.has(place.name):discovered.append(place.name)
    if focus.distance_to(traffic_origin)>500:spawn_traffic(focus)
    for item in traffic:
        var node: Node3D=item.node
        var target: Vector3=item.b if item.forward else item.a
        var displacement:=target-node.position
        var advance:=displacement.normalized()*minf(displacement.length(),5*delta)
        if node.position.distance_to(focus)>9 and not world.train.blocks(node.position+advance) and not crossings.blocks(node.position+advance):
            node.position+=advance
            node.rotation.y=atan2(displacement.x,displacement.z)
            world.fleet.animate(node,advance.length(),0)
        if displacement.length()<1:item.forward=not item.forward
    shot_cooldown=maxf(0,shot_cooldown-delta)
    wanted=maxf(0,wanted-delta)
    police.visible=wanted>0
    if police.visible:
        var next:=police.position+police.position.direction_to(focus)*minf(delta*4,police.position.distance_to(focus))
        if not world._blocked(next):police.position=next
        if police.position.distance_to(focus)<2:
            health-=15*delta
            if health<=0:
                health=100;wanted=0;money=maxi(0,money-100)
                player.position=nearest_road(world.car.position+Vector3(4,0,0))
    autosave+=delta
    if autosave>=10:autosave=0;save()
func spawn_traffic(focus: Vector3):
    for item in traffic:item.node.queue_free()
    traffic.clear()
    traffic_origin=focus
    for tile in world.loaded.values():
        for segment in tile.roads:
            if traffic.size()>=8:return
            if segment[0].distance_to(focus)>160 or segment[0].distance_to(segment[1])<25:continue
            var node:=Node3D.new()
            world.add_child(node)
            world.fleet.build(node,0,false)
            node.position=segment[0]
            traffic.append({"node":node,"a":segment[0],"b":segment[1],"forward":true})
func fire():
    if world.paused or world.in_car or shot_cooldown>0:return
    shot_cooldown=0.4;wanted=25
    for rival in rivals:
        if not rival.visible or rival.position.distance_to(player.position)>16:continue
        var clear:=true
        for i in range(1,20):
            if world._blocked(player.position.lerp(rival.position,i/20.0)):clear=false
        if not clear:continue
        rival.set_meta("hp",rival.get_meta("hp")-1)
        if rival.get_meta("hp")<=0:rival.hide();money+=50;save()
        break
func save():
    update_garage()
    if world.manifest.is_empty():return
    var data={"format":1,"car":[world.car.position.x,world.car.position.z],"player":[player.position.x,player.position.z],"yaw":world.car.rotation.y,"orbit":world.yaw,"driving":world.in_car,"vehicle":world.kind,"character":character,"paint":paint,"daylight":daylight,"headlights":headlights,"distance":distance_driven,"top_speed":top_speed,"discovered":discovered,"money":money}
    var file:=FileAccess.open("user://kerala_save.tmp",FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(data));file.close()
        DirAccess.rename_absolute("user://kerala_save.tmp","user://kerala_save.json")
func number(value, low: float, high: float, fallback: float=0) -> float:
    if (value is float or value is int) and is_finite(float(value)):return clampf(float(value),low,high)
    return fallback
func restore():
    var path:="user://kerala_save.json"
    if not FileAccess.file_exists(path):
        # Carry over personalisation/statistics, never fictional Town coordinates.
        path="user://city_save.json"
    var data=JSON.parse_string(FileAccess.get_file_as_string(path)) if FileAccess.file_exists(path) else null
    if not data is Dictionary:return
    character=int(number(data.get("character"),0,1));paint=int(number(data.get("paint"),0,4))
    daylight=int(number(data.get("daylight"),0,2));headlights=data.get("headlights",false)==true
    world.kind=int(number(data.get("vehicle"),0,5));world._vehicle()
    human.set_appearance(character);apply_daylight()
    distance_driven=number(data.get("distance"),0,1e12);top_speed=number(data.get("top_speed"),0,300)
    money=int(number(data.get("money"),0,1e9))
    if path.ends_with("kerala_save.json"):
        var pos=data.get("car")
        if pos is Array and pos.size()==2 and pos[0] is float and pos[1] is float and is_finite(pos[0]) and is_finite(pos[1]) and absf(pos[0])<250000 and absf(pos[1])<650000:
            world._go(pos)
        world.car.rotation.y=number(data.get("yaw"),-TAU,TAU)
        world.yaw=number(data.get("orbit"),-TAU,TAU)
        var places=data.get("discovered",[])
        if places is Array:
            for place in places:
                if place is String and place.length()<120 and discovered.size()<4000:discovered.append(place)
    world.in_car=data.get("driving",true)==true
    player.position=world.car.position
    var foot=data.get("player")
    if path.ends_with("kerala_save.json") and foot is Array and foot.size()==2:
        var point:=Vector3(number(foot[0],-250000,250000,world.car.position.x),0,number(foot[1],-650000,650000,world.car.position.z))
        if point.distance_to(world.car.position)<200 and not world._blocked(point):player.position=point
    player.visible=not world.in_car
    update_controls()
    if not world.in_car:world.engine_audio.stop()
    world.speed=0
    update_garage()

func update_controls():
    for button in world.buttons:
        var title: String=button.text
        if title.begins_with("WALK") or title in ["SPRINT","FIRE"]:button.visible=not world.in_car
        elif title in ["ACCEL","BRAKE","HANDBRAKE","HORN"] or title.begins_with("GEAR:"):button.visible=world.in_car
        if title.begins_with("GEAR:"):button.text="GEAR: R" if world.reverse else "GEAR: D"

func update_garage():
    if not is_instance_valid(garage):return
    for button in world.buttons:
        if button.get_parent()!=garage:continue
        if button.text.begins_with("CHARACTER"):button.text="CHARACTER: "+["MALE","FEMALE"][character]
        elif button.text.begins_with("PAINT"):button.text="PAINT: "+["BLUE","CRIMSON","PEARL","GRAPHITE","GREEN"][paint]
        elif button.text.begins_with("HEADLIGHTS"):button.text="HEADLIGHTS: "+("ON" if headlights else "OFF")
        elif button.text.begins_with("TIME OF DAY"):button.text="TIME OF DAY: "+["DAY","SUNSET","EVENING"][daylight]
        elif button.text.begins_with("VEHICLE"):button.text="VEHICLE: "+world.fleet.NAMES[world.kind]
