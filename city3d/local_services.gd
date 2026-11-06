extends Node3D
var world: Node3D
var stations: Dictionary={}
var bounds: Array[Rect2]=[]
var last_attempt:=Vector3(INF,0,0)
func refresh(focus: Vector3):
    # Retry failed placement only after moving; dense mapped areas must not stall every frame.
    if focus.distance_to(last_attempt)<250:return
    last_attempt=focus
    for type in ["Police Station","Petrol / Diesel"]:
        var radius:=2000.0 if type=="Police Station" else 3000.0
        if stations.has(type) and stations[type].node.position.distance_to(focus)<radius:continue
        var spot=find_site(focus)
        if spot.is_empty():continue
        if stations.has(type):
            remove_child(stations[type].node);stations[type].node.queue_free()
        var node:=Node3D.new()
        node.position=spot.center
        add_child(node)
        var police: bool=type=="Police Station"
        var data={"name":type,"category":"civic" if police else "vehicle","center":[node.position.x,node.position.z],"point":[spot.road.x,spot.road.z],"width":18,"depth":14,"height":6}
        var polygon:=PackedVector2Array([Vector2(-9,-7),Vector2(9,-7),Vector2(9,7),Vector2(-9,7)])
        var mesh:=MeshInstance3D.new()
        mesh.mesh=preload("res://geographic_visuals.gd").buildings([[0,[[-9,-7],[9,-7],[9,7],[-9,7]],6]],Vector3.ZERO)
        var material:=StandardMaterial3D.new();material.vertex_color_use_as_albedo=true;mesh.material_override=material
        node.add_child(mesh)
        preload("res://building_facade.gd").new().build(node,polygon,6,3,spot.road-node.position,500,false,true)
        if not police:data.name="Gas Station"
        preload("res://example_buildings.gd").new().decorate(node,data)
        var text: Label3D=node.get_node("ExampleFront/ExampleLabel")
        text.text="POLICE STATION · GAME" if police else "PETROL  |  DIESEL · GAME"
        var front: Node3D=node.get_node("ExampleFront")
        if police:
            for i in range(2):
                var officer:=Node3D.new();officer.name="Officer%d"%i;officer.set_script(preload("res://human.gd"));node.add_child(officer)
                officer.position=front.position+front.basis*Vector3(-5+i*3,0,2)
                officer.rotation.y=front.rotation.y
                officer.clothing.albedo_color=Color("8d815d")
            var patrol:=Node3D.new();patrol.name="PoliceVehicle";node.add_child(patrol)
            patrol.position=front.position+front.basis*Vector3(4,0,3);patrol.rotation.y=front.rotation.y
            world.fleet.build(patrol,0,false)
            for paint in patrol.get_meta("paints",[]):paint.albedo_color=Color("e2e7e5")
            var plate:=Label3D.new();plate.text="POLICE";plate.font_size=44;plate.pixel_size=0.01;plate.position=Vector3(0,1.15,1);patrol.add_child(plate)
            for sign in [-1,1]:
                var light:=MeshInstance3D.new();var box:=BoxMesh.new();box.size=Vector3(0.4,0.15,0.3);light.mesh=box
                var mat:=StandardMaterial3D.new();mat.albedo_color=Color.RED if sign<0 else Color.BLUE;mat.emission_enabled=true;mat.emission=mat.albedo_color;light.material_override=mat
                light.position=Vector3(sign*0.25,1.4,0);patrol.add_child(light)
        else:
            for side in [-1,1]:
                var fuel:=Label3D.new();fuel.name="PetrolLabel" if side<0 else "DieselLabel"
                fuel.text="PETROL" if side<0 else "DIESEL";fuel.font_size=32;fuel.pixel_size=0.007
                fuel.position=Vector3(side*2,0.65,1.88);front.add_child(fuel)
        stations[type]={"node":node,"point":[spot.road.x,spot.road.z]}
        rebuild_bounds()
func rebuild_bounds():
    bounds.clear()
    for item in stations.values():
        var pos: Vector3=item.node.position
        bounds.append(Rect2(pos.x-9,pos.z-7,18,14))
        var patrol: Node3D=item.node.get_node_or_null("PoliceVehicle")
        if patrol:
            var size:=Vector2(2,4.4) if absf(patrol.basis.z.z)>0.5 else Vector2(4.4,2)
            var center: Vector3=patrol.global_position
            bounds.append(Rect2(Vector2(center.x,center.z)-size/2,size))
        else:
            var front: Node3D=item.node.get_node("ExampleFront")
            for side in [-1,1]:
                var pump:=front.to_global(Vector3(side*2,0,1.6))
                bounds.append(Rect2(pump.x-0.45,pump.z-0.45,0.9,0.9))
func blocked(point: Vector3) -> bool:
    for rect in bounds:
        if rect.has_point(Vector2(point.x,point.z)):return true
    return false
func find_site(focus: Vector3) -> Dictionary:
    for tile in world.loaded.values():
        for segment in tile.roads:
            var road:=Geometry3D.get_closest_point_to_segment(focus,segment[0],segment[1])
            if road.distance_to(focus)>600:continue
            var direction: Vector3=(segment[1]-segment[0]).normalized().cross(Vector3.UP)
            for sign in [-1,1]:
                var center: Vector3=road+direction*sign*32
                var rect:=Rect2(center.x-14,center.z-14,28,28)
                var clear:=true
                for other in world.loaded.values():
                    for box in other.boxes:
                        if rect.intersects(box):clear=false;break
                    for route in other.roads+other.rail:
                        var a: Vector3=route[0] if route[0] is Vector3 else Vector3(route[0][0],0,route[0][1])
                        var b: Vector3=route[1] if route[1] is Vector3 else Vector3(route[1][0],0,route[1][1])
                        if Geometry3D.get_closest_point_to_segment(center,a,b).distance_to(center)<20:clear=false;break
                    if not clear:break
                for station in stations.values():
                    var pos: Vector3=station.node.position
                    if rect.intersects(Rect2(pos.x-14,pos.z-14,28,28)):clear=false
                if clear:return {"center":center,"road":road}
    return {}
