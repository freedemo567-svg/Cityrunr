extends Node3D

# Current batched architecture uses shared plaster surfaces.
var surfaces: Dictionary={}

func material(color: Color, plaster := false) -> StandardMaterial3D:
    var key:=str(color)+str(plaster)
    if surfaces.has(key): return surfaces[key]
    var result:=StandardMaterial3D.new()
    result.albedo_color=color
    result.roughness=0.83
    if plaster:
        result.albedo_texture=preload("res://assets/facade/textures/modular_urban_apartments_facade_plaster_diff_1k.jpg")
        result.normal_enabled=true
        result.normal_texture=preload("res://assets/facade/textures/modular_urban_apartments_facade_plaster_nor_gl_1k.jpg")
        result.normal_scale=0.6
        result.uv1_triplanar=true
        result.uv1_scale=Vector3(0.25,0.25,0.25)
    surfaces[key]=result
    return result

func box(parent: Node3D, pos: Vector3, size: Vector3, color: Color, plaster := false) -> MeshInstance3D:
    var visual:=MeshInstance3D.new()
    var mesh:=BoxMesh.new()
    mesh.size=size
    visual.mesh=mesh
    visual.material_override=material(color,plaster)
    visual.position=pos
    parent.add_child(visual)
    return visual

func roof(parent: Node3D, size: Vector3, wall_color: Color):
    # Two sloping tile planes with visible rows and ridge caps.
    var rise:=1.5
    var gable:=MeshInstance3D.new()
    var prism:=PrismMesh.new()
    prism.size=Vector3(size.x,rise,size.z)
    gable.mesh=prism
    gable.position=Vector3(0,size.y+rise/2,0)
    gable.material_override=material(wall_color,true)
    parent.add_child(gable)
    var half_width:=size.x/2+0.65
    var slope:=atan2(rise,half_width)
    var length:=sqrt(half_width*half_width+rise*rise)
    for side in [-1,1]:
        var plane:=Node3D.new()
        plane.position=Vector3(side*half_width/2,size.y+rise/2,0)
        plane.rotation.z=-side*slope
        parent.add_child(plane)
        var tiles: MeshInstance3D=box(plane,Vector3.ZERO,Vector3(length,0.16,size.z+1.3),Color("8a4c35"))
        tiles.material_override=preload("res://surface_materials.gd").roof()
        for row in range(7):
            box(plane,Vector3(-length/2+(row+0.5)*length/7,0.1,0),Vector3(0.06,0.055,size.z+1.3),Color("b37250"))
    box(parent,Vector3(0,size.y+rise+0.1,0),Vector3(0.24,0.18,size.z+1.3),Color("ad6947"))
