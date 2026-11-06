extends SceneTree
func _initialize():run.call_deferred()
func require(condition: bool, message: String) -> bool:
    if not condition:push_error(message);quit(1)
    return condition
func run():
    var catalog=JSON.parse_string(FileAccess.get_file_as_string("res://assets/kerala/illustrative_buildings.json"))
    if not require(catalog is Dictionary and catalog.buildings.size()==100,"Expected 100 fictional examples"):return
    var world=load("res://geodrive.tscn").instantiate()
    root.add_child(world)
    world.set_physics_process(false)
    var ids={}
    var names={}
    for data in catalog.buildings:
        if not require(not ids.has(data.id) and not names.has(data.name),"Duplicate example ID/name"):return
        ids[data.id]=true;names[data.name]=true
        var parent:=Node3D.new()
        root.add_child(parent)
        preload("res://example_buildings.gd").new().decorate(parent,data)
        var label: Label3D=parent.get_node("ExampleFront/ExampleLabel")
        if not require(label.text.contains(data.name.to_upper()) and label.text.contains("EXAMPLE") and parent.get_meta("example_name")==data.name,"Example signage missing"):return
        if not require(parent.find_children("*","MeshInstance3D",true,false).size()<=12,"Example decoration exceeds mesh budget"):return
        parent.free()
        world._search(data.name)
        var found:=false
        for match_item in world.matches:
            if match_item.name=="Example: %s (%s)"%[data.name,data.city]:found=true
        if not require(found,"Example search missing: "+data.name):return
    for title in ["Hospital","Temple","Gas Station","Water Tower","Underground Bunker","Skyscraper"]:
        var item={}
        for entry in catalog.buildings:
            if entry.name==title:item=entry;break
        if not require(not item.is_empty(),"Required example missing: "+title):return
        world.speed=0
        world.in_car=true
        world._search(title)
        world._go_selected()
        if not require(world.car.position.distance_to(Vector3(item.point[0],0,item.point[1]))<2,"Search did not arrive at requested road"):return
        if not require(not world._blocked(world.car.position),"Example search spawned inside a building"):return
        var present:=false
        for root_node in world.details.roots:
            if root_node.get_meta("example_name","")==title:
                present=true
                var front: Node3D=root_node.get_node("ExampleFront")
                if not require(front.get_node("ExampleLabel").visible,"Example label not visible"):return
        if not require(present,"Example was not rendered at search location: "+title):return
        var center: Array=item.center
        if not require(world._blocked(Vector3(center[0],0,center[1])),"Example collision missing: "+title):return
    world.in_car=false
    world.life.player.visible=true
    world.speed=0
    world._search("Villa")
    var destination: Array=world.matches[0].point
    world._go_selected()
    if not require(world.life.player.position.distance_to(Vector3(destination[0],0,destination[1]))<3 and world.car.position.distance_to(world.life.player.position)<2,"On-foot search did not stream and relocate to the destination"):return
    world.in_car=true
    world.life.player.visible=false
    world.life.update_controls()
    world._search("Kochi")
    if not require(not world.matches.is_empty() and world.matches[0].name=="Kochi","Place search priority changed"):return
    if OS.get_environment("EXAMPLE_CAPTURE")!="":
        world._search("Hospital")
        world._go(world.matches[0].point)
        var result: Dictionary=world.illustrative.filter(func(x):return x.name=="Hospital")[0]
        var center:=Vector3(result.center[0],0,result.center[1])
        var from: Vector3=world.car.position
        world.camera.position=from+Vector3(0,8,0)
        world.camera.look_at(center+Vector3(0,4,0),Vector3.UP)
        await process_frame
        await process_frame
        root.get_texture().get_image().save_png(OS.get_environment("EXAMPLE_CAPTURE"))
    print("100 examples searchable, signage bounded, six searches spawn safely and preserve collision")
    quit()
