extends SceneTree
func _initialize():run.call_deferred()
func require(condition: bool, message: String) -> bool:
    if not condition:
        push_error(message)
        quit(1)
    return condition
func run():
    var fleet=preload("res://fleet.gd").new()
    for detailed in [true,false]:
        var vehicle:=Node3D.new()
        root.add_child(vehicle)
        var model: Node3D=fleet.build(vehicle,0,detailed)
        if not require(model.scale.is_equal_approx(Vector3.ONE*model.scale.x),"Sports car tyres distorted by non-uniform scale"):return
        if not require(vehicle.get_meta("wheel_nodes").size()==4 and vehicle.get_meta("steering_nodes").size()==2,"Imported wheel rig incomplete"):return
        var materials: Array=vehicle.get_meta("paints")
        if not require(not materials.is_empty() and materials.all(func(paint): return not paint.normal_enabled and not paint.ao_enabled and paint.normal_texture==null and paint.clearcoat_enabled),"Paint retains incompatible flake normal"):return
        var glazing:=0
        for mesh in model.find_children("*","MeshInstance3D",true,false):
            for index in range(mesh.mesh.get_surface_count()):
                var mat: Material=mesh.get_active_material(index)
                if mat.resource_name=="Automotive glass":
                    glazing+=1
                    if not require(mat is StandardMaterial3D and mat.albedo_color.a<0.6 and mat.transparency==BaseMaterial3D.TRANSPARENCY_ALPHA,"Imported glazing remains opaque white"):return
        if not require(glazing>0,"Sports car glazing missing"):return
        for wheel in vehicle.get_meta("wheel_nodes"):
            var radius: float=wheel.get_meta("radius")
            if not require(radius>0.2 and radius<0.4,"Invalid recovered wheel radius"):return
            var mesh: ArrayMesh=wheel.get_child(0).mesh
            var bounds:=mesh.get_aabb()
            if not require(bounds.size.x<bounds.size.y*0.7 and absf(bounds.size.y-bounds.size.z)<0.1,"Recovered wheel axle is skewed"):return
            var start: float=wheel.rotation.x
            fleet.animate(vehicle,0.1,1)
            if not require(not is_equal_approx(start,wheel.rotation.x),"Sports wheel does not roll"):return
        if not require(vehicle.get_meta("steering_nodes").all(func(pivot): return pivot.rotation.y<0),"Visual steering reverses right input"):return
        var other:=Node3D.new()
        root.add_child(other)
        fleet.build(other,0,detailed)
        var original_color: Color=other.get_meta("paints")[0].albedo_color
        materials[0].albedo_color=Color.RED
        if not require(other.get_meta("paints")[0].albedo_color==original_color,"Paint shared between independent cars"):return
        vehicle.free()
        other.free()
    for kind in range(1,6):
        var vehicle:=Node3D.new()
        root.add_child(vehicle)
        var model: Node3D=fleet.build(vehicle,kind)
        var expected: int=2 if kind==1 else (3 if kind==2 else 4)
        if not require(vehicle.get_meta("wheel_nodes").size()==expected and vehicle.has_meta("steering_nodes") and model.has_node("ContactShadow"),"Fleet wheel/shadow setup incomplete"):return
        fleet.animate(vehicle,-0.1,-1)
        if not require(vehicle.get_meta("steering_nodes").all(func(pivot): return pivot.rotation.y>0),"Fleet visual left steering reversed"):return
        vehicle.free()
    print("Vehicle scale, wheel recovery, animation, glazing, material isolation and six-category checks passed")
    quit()
