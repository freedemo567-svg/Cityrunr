extends RefCounted

# One imported-car path for town, traffic and geographic drive. Source meshes
# are shared; overridden paint, glazing and lamps belong to each vehicle.
static var wheel_cache: Dictionary={}
const SCALE := 0.82

func sports(parent: Node3D, detailed := true) -> Node3D:
    var scene: PackedScene=preload("res://assets/car/car-detail.glb") if detailed else preload("res://assets/car/car-concept.glb")
    var model: Node3D=scene.instantiate()
    model.name="CarVisual"
    # Uniform scaling keeps tyres circular. The imported tyres already touch y=0.
    model.scale=Vector3.ONE*SCALE
    model.position.y=0.02
    parent.add_child(model)
    var source_wheels: Array[MeshInstance3D]=[]
    var paints: Array[StandardMaterial3D]=[]
    var lamps: Dictionary={}
    for visual in model.find_children("*","MeshInstance3D",true,false):
        if not detailed: visual.visibility_range_end=90
        var is_wheel: bool=str(visual.name).begins_with("Wheel")
        for surface in range(visual.mesh.get_surface_count()):
            var source: StandardMaterial3D=visual.mesh.surface_get_material(surface)
            if not source: continue
            var title:=source.resource_name
            if title in ["Tireside","Tiretread"]: is_wheel=true
            if title.begins_with("Paint"):
                var paint:=StandardMaterial3D.new()
                paint.resource_name=title
                paint.cull_mode=BaseMaterial3D.CULL_DISABLED
                paint.albedo_texture=null
                paint.albedo_color=Color("245b87").darkened(0.35) if title.begins_with("Paint 2") else Color("245b87")
                paint.metallic=0.5
                paint.roughness=0.28
                paint.normal_enabled=false
                paint.clearcoat_enabled=true
                paint.clearcoat=0.8
                paint.clearcoat_roughness=0.18
                paints.append(paint)
                visual.set_surface_override_material(surface,paint)
            elif title=="Glass":
                var glass:=StandardMaterial3D.new()
                glass.resource_name="Automotive glass"
                glass.albedo_color=Color(0.12,0.19,0.22,0.48)
                glass.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
                glass.metallic=0.15
                glass.roughness=0.12
                visual.set_surface_override_material(surface,glass)
            elif title in ["Brakelight","Headlight"]:
                var lamp: StandardMaterial3D=source.duplicate()
                lamp.emission_enabled=true
                lamp.emission=Color("f9ebbc") if title=="Headlight" else Color("eb2719")
                lamp.emission_energy_multiplier=0.1
                lamp.albedo_color=Color("a50e0b") if title=="Brakelight" else Color("c1c1ad")
                visual.set_surface_override_material(surface,lamp)
                lamps[title]=lamp
        if is_wheel: source_wheels.append(visual)
    if not wheel_cache.has(detailed): wheel_cache[detailed]=_split_wheels(source_wheels)
    var wheels: Array[Node3D]=[]
    var steering: Array[Node3D]=[]
    var data: Array=wheel_cache[detailed]
    for index in range(data.size()):
        var item: Dictionary=data[index]
        var pivot:=Node3D.new()
        pivot.name="WheelPivot%d"%index
        pivot.position=item.center
        model.add_child(pivot)
        if item.center.z>0: steering.append(pivot)
        var spin:=Node3D.new()
        spin.name="WheelSpin"
        spin.set_meta("radius",item.radius*SCALE)
        pivot.add_child(spin)
        wheels.append(spin)
        for part in ["rolling","caliper"]:
            var mesh: ArrayMesh=item[part]
            if mesh.get_surface_count()==0: continue
            var visual:=MeshInstance3D.new()
            visual.mesh=mesh
            if not detailed: visual.visibility_range_end=90
            if part=="rolling": spin.add_child(visual)
            else: pivot.add_child(visual)
    for visual in source_wheels:
        model.remove_child(visual)
        visual.free()
    parent.set_meta("paints",paints)
    parent.set_meta("lamps",lamps)
    parent.set_meta("wheel_nodes",wheels)
    parent.set_meta("steering_nodes",steering)
    parent.set_meta("kind",0)
    _rear_details(model,lamps)
    contact_shadow(model,Vector2(2.4,4.5))
    if not detailed:
        for visual in model.find_children("*","GeometryInstance3D",true,false): visual.visibility_range_end=90
    return model

func _split_wheels(source: Array[MeshInstance3D]) -> Array:
    var bounds: Array[AABB]=[AABB(),AABB(),AABB(),AABB()]
    var initialized: Array[bool]=[false,false,false,false]
    var points: Array[PackedVector3Array]=[PackedVector3Array(),PackedVector3Array(),PackedVector3Array(),PackedVector3Array()]
    for visual in source:
        for surface in range(visual.mesh.get_surface_count()):
            var mat: Material=visual.mesh.surface_get_material(surface)
            if mat.resource_name!="Tiretread": continue
            var arrays:=visual.mesh.surface_get_arrays(surface)
            for vertex in arrays[Mesh.ARRAY_VERTEX]:
                var point: Vector3=visual.transform*vertex
                var index: int=(0 if point.x<0 else 1)+(0 if point.z>0 else 2)
                points[index].append(point)
                bounds[index]=bounds[index].expand(point) if initialized[index] else AABB(point,Vector3.ZERO)
                initialized[index]=true
    var result: Array=[]
    for index in range(4):
        var center:=bounds[index].get_center()
        # Recover the wheel's axle direction from its tyre vertices. The source
        # concept has a posed front axle; remove that pose before live steering.
        var xx:=0.0
        var zz:=0.0
        var xz:=0.0
        for point in points[index]:
            var offset: Vector3=point-center
            xx+=offset.x*offset.x
            zz+=offset.z*offset.z
            xz+=offset.x*offset.z
        var angle:=0.5*atan2(2*xz,xx-zz)+PI/2
        if angle>PI/2: angle-=PI
        var neutral:=Basis(Vector3.UP,angle)
        result.append({"center":center,"radius":bounds[index].size.y/2,"neutral":neutral,"rolling":ArrayMesh.new(),"caliper":ArrayMesh.new()})
    for visual in source:
        for surface in range(visual.mesh.get_surface_count()):
            var arrays:=visual.mesh.surface_get_arrays(surface)
            var vertices: PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
            var normals: PackedVector3Array=arrays[Mesh.ARRAY_NORMAL]
            var uv: PackedVector2Array=arrays[Mesh.ARRAY_TEX_UV] if arrays[Mesh.ARRAY_TEX_UV]!=null else PackedVector2Array()
            var indices: PackedInt32Array=arrays[Mesh.ARRAY_INDEX]
            var builders: Array[SurfaceTool]=[]
            var counts: Array[int]=[0,0,0,0]
            for index in range(4):
                var builder:=SurfaceTool.new()
                builder.begin(Mesh.PRIMITIVE_TRIANGLES)
                builders.append(builder)
            for face in range(0,indices.size(),3):
                var middle: Vector3=visual.transform*((vertices[indices[face]]+vertices[indices[face+1]]+vertices[indices[face+2]])/3)
                var index: int=(0 if middle.x<0 else 1)+(0 if middle.z>0 else 2)
                var data: Dictionary=result[index]
                for corner in range(3):
                    var vertex_index:=indices[face+corner]
                    builders[index].set_normal(data.neutral*visual.basis*normals[vertex_index])
                    if not uv.is_empty(): builders[index].set_uv(uv[vertex_index])
                    builders[index].add_vertex(data.neutral*(visual.transform*vertices[vertex_index]-data.center))
                    counts[index]+=1
            var material: StandardMaterial3D=visual.mesh.surface_get_material(surface).duplicate()
            if material.resource_name in ["Tireside","Tiretread"]:
                material.roughness=0.9
                material.metallic=0
            elif material.resource_name.begins_with("Rim"):
                material.metallic=0.8
                material.roughness=0.25
            for index in range(4):
                if counts[index]==0: continue
                var mesh: ArrayMesh=result[index].caliper if str(visual.name).contains("BrakePad") else result[index].rolling
                builders[index].index()
                builders[index].commit(mesh)
                mesh.surface_set_material(mesh.get_surface_count()-1,material)
    return result

func contact_shadow(parent: Node3D, size: Vector2):
    var plane:=PlaneMesh.new()
    plane.size=size
    var shadow:=MeshInstance3D.new()
    shadow.name="ContactShadow"
    shadow.mesh=plane
    var material:=ShaderMaterial.new()
    material.shader=preload("res://vehicle_contact_shadow.gdshader")
    shadow.material_override=material
    shadow.position.y=0.005
    shadow.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    parent.add_child(shadow)

func _rear_details(model: Node3D, lamps: Dictionary):
    var trim:=StandardMaterial3D.new()
    trim.albedo_color=Color("1b2023")
    trim.roughness=0.5
    _part(model,Vector3(0,0.63,-1.96),Vector3(1.62,0.18,0.07),trim)
    for side in [-1,1]:
        _part(model,Vector3(side*0.47,0.64,-2.005),Vector3(0.56,0.055,0.04),lamps.Brakelight)
    _part(model,Vector3(0,0.18,-1.85),Vector3(1.75,0.14,0.22),trim)
    var plate:=StandardMaterial3D.new()
    plate.albedo_color=Color("bdbdaf")
    plate.roughness=0.75
    _part(model,Vector3(0,0.35,-1.975),Vector3(0.57,0.18,0.045),plate)
    var lettering:=Label3D.new()
    lettering.name="FictionalPlate"
    lettering.text="CITY RUN"
    lettering.font_size=32
    lettering.pixel_size=0.0035
    lettering.outline_size=0
    lettering.modulate=Color("171c1b")
    lettering.position=Vector3(0,0.35,-2.002)
    lettering.rotation.y=PI
    model.add_child(lettering)

func _part(parent: Node3D, pos: Vector3, size: Vector3, material: Material):
    var visual:=MeshInstance3D.new()
    visual.mesh=preload("res://vehicle_geometry.gd").rounded_box(size)
    visual.material_override=material
    visual.position=pos
    parent.add_child(visual)
