extends SceneTree
func _initialize():run.call_deferred()
func require(condition: bool, message: String) -> bool:
    if not condition:
        push_error(message)
        quit(1)
    return condition
func touch(index: int, pressed: bool, point: Vector2):
    var event:=InputEventScreenTouch.new()
    event.index=index
    event.pressed=pressed
    event.position=point
    return event
func run():
    var scene=load("res://geodrive.tscn").instantiate()
    root.add_child(scene)
    scene.set_physics_process(false)
    if not require(not scene.manifest.is_empty() and not scene.loaded.is_empty(),"Install real map data before geographic test"):return
    var roads:=0
    for tile in scene.loaded.values():roads+=tile.roads.size()
    if not require(roads>20,"Mapped roads missing"):return
    scene._search("Kochi")
    if not require(not scene.matches.is_empty() and scene.matches[0].name=="Kochi","Exact place search priority failed"):return
    scene._search("Thrissur")
    if not require(not scene.matches.is_empty() and scene.matches[0].name=="Thrissur","Administrative seat search failed"):return
    scene._search("Kozhikode")
    if not require(not scene.matches.is_empty(),"Real place search failed"):return
    scene._go(scene.matches[0].point)
    scene._physics_process(0.01)
    var before: Vector3=scene.car.position
    scene.pedal=true
    scene._physics_process(0.1)
    if not require(scene.speed>0 and scene.car.position!=before,"Geographic driving failed"):return
    scene.handbrake=true
    scene._physics_process(0.1)
    if not require(scene.speed==0,"Handbrake did not stop vehicle"):return
    scene.handbrake=false
    for kind in range(6):
        scene.kind=kind
        scene._vehicle()
        if not require(scene.car.get_child_count()>0,"Fleet visual missing"):return
    scene._input(touch(4,true,Vector2(50,450)))
    if not require(scene.horn_down and scene.horn.playing,"Horn did not start"):return
    scene.horn.stop()
    scene._physics_process(0.01)
    if not require(scene.horn.playing,"Held horn did not repeat"):return
    scene._input(touch(4,false,Vector2(50,450)))
    if not require(not scene.horn_down and not scene.horn.playing,"Horn did not release"):return
    scene._input(touch(5,true,Vector2(1200,600)))
    scene._notification(Node.NOTIFICATION_APPLICATION_PAUSED)
    if not require(scene.paused and not scene.pedal and scene.touches.is_empty() and not scene.engine_audio.playing,"Background controls/audio not reset"):return
    scene.paused=false
    var center: Vector2i=scene.tile_center
    scene.car.position.x+=7000
    scene._stream()
    if not require(scene.tile_center!=center and scene.loaded.size()<=9,"Streaming bounds failed"):return
    scene._search("Kochi")
    scene._go(scene.matches[0].point)
    scene.kind=0
    scene._vehicle()
    scene._physics_process(0.01)
    await process_frame
    await process_frame
    if OS.get_environment("CITY_GEO_CAPTURE")!="":
        root.get_texture().get_image().save_png(OS.get_environment("CITY_GEO_CAPTURE"))
    print("Geographic search, fleet, driving, handbrake, horn, background and streaming checks passed; roads ",roads)
    quit()
