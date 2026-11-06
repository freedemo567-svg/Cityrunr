extends SceneTree
func _initialize():run.call_deferred()
func require(value: bool,message: String) -> bool:
    if not value:push_error(message);quit(1)
    return value
func run():
    var world=load("res://geodrive.tscn").instantiate()
    root.add_child(world);world.set_physics_process(false)
    world.services.refresh(world.car.position)
    if not require(world.services.stations.size()==2,"Local service placement failed"):return
    for key in world.services.stations:
        var station=world.services.stations[key]
        if not require(station.node.position.distance_to(world.car.position)<(5000 if key=="Police Station" else 8000),"Service outside requested radius"):return
        if not require(world.services.blocked(station.node.position),"Service building collision missing"):return
    var police=world.services.stations["Police Station"].node
    if not require(police.has_node("Officer0") and police.has_node("Officer1") and police.has_node("PoliceVehicle/CarVisual"),"Police staff/vehicle missing"):return
    var fuel=world.services.stations["Petrol / Diesel"].node
    if not require(fuel.has_node("ExampleFront/PetrolLabel") and fuel.has_node("ExampleFront/DieselLabel"),"Petrol/diesel pumps missing"):return
    if not require(not world.damage.impact(world.car,0,0.5,4.2),"Parking touch caused scratches"):return
    if not require(world.damage.impact(world.car,0,12,4.2),"Impact did not mark vehicle"):return
    if not require(not world.damage.impact(world.car,0,12,4.2),"Impact cooldown missing"):return
    world.life.save()
    world.damage.records.clear();world.life.restore()
    if not require(world.damage.records.get("0",[]).size()==1,"Saved scratches lost"):return
    world.damage.update(world.car,0,1)
    if not require(world.damage.material.get_shader_parameter("hits")==1,"Paint damage shader not updated"):return
    var audio=preload("res://vehicle_audio.gd").new()
    if not require(audio.impact().data.size()==22050 and audio.road().loop_end==44100 and audio.engine(0).data!=audio.engine(5).data,"Audio layers/profiles missing"):return
    var original: Vector3=world.car.position
    world.car.position=Vector3(100000,0,100000)
    world.life.crossings.signals=[{"point":world.car.position+Vector3(7,0,0),"lamps":[]}]
    world.life.crossings.elapsed=0
    world._path_blocked(world.car.position,world.car.position)
    if not require(not world.physical_obstacle,"Traffic signal counted as crash"):return
    world.life.crossings.signals=[]
    world.car.position=original
    # Exercise the actual world collision path, not just the damage helper.
    world.damage.cooldown=0
    var ahead:=original+Vector3(sin(world.car.rotation.y),0,cos(world.car.rotation.y))*0.7
    world.services.bounds.append(Rect2(ahead.x-0.3,ahead.z-0.3,0.6,0.6))
    world.speed=12
    world._physics_process(0.1)
    if not require(world.speed==0 and world.damage.records["0"].size()==2 and world.crash_audio.playing,"Physical collision did not stop/mark/sound"):return
    world.services.rebuild_bounds()
    world.paused=true;world._vehicle()
    if not require(not world.engine_audio.playing,"Garage vehicle change started paused engine"):return
    world.paused=false
    world.speed=8;world._physics_process(0.01)
    if not require(world.road_audio.playing,"Moving vehicle has no rolling layer"):return
    world._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
    if not require(not world.road_audio.playing and not world.crash_audio.playing,"Pause left driving sound playing"):return
    world.paused=false
    # Both front and rear paints receive the local-space scratch overlay.
    world.camera.position=world.car.position+Vector3(3,2.2,4.5)
    world.camera.look_at(world.car.position+Vector3(0,0.65,0),Vector3.UP)
    await process_frame
    await process_frame
    if OS.get_environment("DAMAGE_CAPTURE")!="":root.get_texture().get_image().save_png(OS.get_environment("DAMAGE_CAPTURE"))
    if OS.get_environment("SERVICE_CAPTURE")!="":
        var front: Node3D=police.get_node("ExampleFront")
        world.camera.position=front.to_global(Vector3(18,9,24))
        world.camera.look_at(police.position+Vector3(0,2,0),Vector3.UP)
        await process_frame
        await process_frame
        root.get_texture().get_image().save_png(OS.get_environment("SERVICE_CAPTURE"))
    for place in ["Thiruvananthapuram","Kozhikode","Thrissur"]:
        world._search(place)
        if not require(not world.matches.is_empty(),"Coverage fixture city missing"):return
        world._go(world.matches[0].point)
        world.services.refresh(world.car.position)
        for key in world.services.stations:
            if not require(world.services.stations[key].node.position.distance_to(world.car.position)<(5000 if key=="Police Station" else 8000),"Travel left service outside radius: "+place):return
    print("Nearby services, officers/patrol, scratch persistence/cooldown, audio and control-stop exclusion passed")
    quit()
