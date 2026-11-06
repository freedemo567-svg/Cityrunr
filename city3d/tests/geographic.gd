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
    # Concave footprint has area 3, rather than its 2 x 2 bounding box.
    var visual=preload("res://geographic_visuals.gd")
    var sample=[[7,[[0,0],[2,0],[2,1],[1,1],[1,2],[0,2],[0,0]],6.0]]
    var mesh: ArrayMesh=visual.buildings(sample,Vector3.ZERO)
    if not require(mesh!=null,"Building footprint mesh missing"):return
    var arrays:=mesh.surface_get_arrays(0)
    var vertices: PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
    var normals: PackedVector3Array=arrays[Mesh.ARRAY_NORMAL]
    var roof_area:=0.0
    for i in range(0,vertices.size(),3):
        if normals[i].y>0.9:
            roof_area+=(vertices[i+1]-vertices[i]).cross(vertices[i+2]-vertices[i]).length()/2
    if not require(absf(roof_area-3.0)<0.01,"Building roof does not follow mapped footprint"):return
    var train=Node3D.new()
    train.set_script(preload("res://geographic_train.gd"))
    root.add_child(train)
    train.set_tracks([{"rail":[[[0,0],[100,0]],[[100,0],[200,0]]]}])
    train.tick(0.1,Vector3(50,0,3))
    if not require(train.active and train.blocks(train.position) and train.position.distance_to(Vector3(50,0,3))>35,"Mapped train spawn or vehicle blocking failed"):return
    var train_start: Vector3=train.position
    train.tick(5.0,Vector3(50,0,3))
    if not require(train.position.distance_to(train_start)>50 and absf(train.position.z)<0.01,"Train did not follow connected rail"):return
    train.set_tracks([])
    if not require(not train.active and not train.visible,"Train survived unloaded tracks"):return
    train.queue_free()
    var scene=load("res://geodrive.tscn").instantiate()
    root.add_child(scene)
    scene.set_physics_process(false)
    if not require(not scene.manifest.is_empty() and not scene.loaded.is_empty(),"Install real map data before geographic test"):return
    var roads:=0
    for tile in scene.loaded.values():roads+=tile.roads.size()
    if not require(roads>20,"Mapped roads missing"):return
    scene._load_tile(Vector2i(-10,-63))
    var track_tile=scene.loaded[Vector2i(-10,-63)].node
    var track_mesh: ArrayMesh=track_tile.get_node("RoadsAndRail").mesh
    var track_arrays:=track_mesh.surface_get_arrays(0)
    var colors: PackedColorArray=track_arrays[Mesh.ARRAY_COLOR]
    var track_vertices: PackedVector3Array=track_arrays[Mesh.ARRAY_VERTEX]
    var rails:=false
    var bridge:=false
    for i in range(colors.size()):
        if colors[i].is_equal_approx(Color("b8c1bd")): rails=true
        if colors[i].is_equal_approx(Color("bbb9a9")) and track_vertices[i].y>0.6: bridge=true
    if not require(rails and bridge,"Mapped rails or bridge detail missing"):return
    var mapped_rail: Array=scene.loaded[Vector2i(-10,-63)].rail[0]
    var rail_point:=Vector3((mapped_rail[0][0]+mapped_rail[1][0])/2,0,(mapped_rail[0][1]+mapped_rail[1][1])/2)
    scene.train.set_tracks([scene.loaded[Vector2i(-10,-63)]])
    scene.train.tick(0.1,rail_point)
    if not require(scene.train.active and scene.train.blocks(scene.train.position),"Train did not use mapped railway data"):return
    track_tile.queue_free()
    scene.loaded.erase(Vector2i(-10,-63))
    scene.train.set_tracks(scene.loaded.values())
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
    scene.pedal=false
    # Use an empty location while keeping the loaded map intact.
    var map_position: Vector3=scene.car.position
    var map_center: Vector2i=scene.tile_center
    for heading in [0.0, PI/2]:
        for direction in [-1, 1]:
            for initial_speed in [-5.0, 5.0]:
                scene.car.position=Vector3(100001,0,100001)
                scene.tile_center=Vector2i(50,50)
                scene.car.rotation.y=heading
                scene.speed=initial_speed
                scene._input(touch(12,true,Vector2(155+70*direction,575)))
                var start: Vector3=scene.car.position
                scene._physics_process(0.1)
                var right:=Vector3(-cos(heading),0,sin(heading))
                if not require((scene.car.position-start).dot(right)*direction>0 and (scene.car.rotation.y-heading)*direction*initial_speed<0,"Geographic wheel steering direction incorrect"):return
                scene._input(touch(12,false,Vector2(155+70*direction,575)))
    scene.car.position=map_position
    scene.tile_center=map_center
    scene.car.rotation.y=0
    scene.speed=0
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
    var focus: Vector3=scene.car.position
    scene.train.set_tracks([{"rail":[[[focus.x-100,focus.z],[focus.x+100,focus.z]]]}])
    scene.train.tick(0.1,focus)
    if not require(scene.train.active,"Pause test train did not start"):return
    var frozen_train: Vector3=scene.train.position
    scene._physics_process(1.0)
    if not require(scene.train.position==frozen_train,"Train moved while paused"):return
    scene.train.set_tracks(scene.loaded.values())
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
