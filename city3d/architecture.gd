extends Node3D

# Current batched architecture uses shared plaster surfaces.
var surfaces: Dictionary={}
var building_roots: Array[Node3D]=[]

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

func build(data: Dictionary, index: int):
    var house:=Node3D.new()
    house.name="Building%02d"%index
    house.position=data.position
    # Visibility range belongs to visual instances; root remains a plain Node3D.
    add_child(house)
    building_roots.append(house)
    var size: Vector3=data.size
    var style: int=data.style
    var color: Color=data.color.darkened(0.1)
    var wall:=box(house,Vector3(0,size.y/2,0),size,color,true)
    wall.set_meta("textured_wall",true)
    var body:=StaticBody3D.new()
    var collision:=CollisionShape3D.new()
    var shape:=BoxShape3D.new()
    shape.size=size
    collision.shape=shape
    collision.position=Vector3(0,size.y/2,0)
    body.add_child(collision)
    house.add_child(body)
    box(house,Vector3(0,0.18,0),Vector3(size.x+0.6,0.36,size.z+0.6),Color("7a7469"))
    var polygon:=PackedVector2Array([Vector2(-size.x/2,-size.z/2),Vector2(size.x/2,-size.z/2),Vector2(size.x/2,size.z/2),Vector2(-size.x/2,size.z/2)])
    var facade=preload("res://building_facade.gd").new()
    facade.build(house,polygon,size.y,style,Vector3(0,0,size.z+5),640,style<2)
    if style<2:
        roof(house,size,color)
        # Veranda pillars and wooden fascia.
        box(house,Vector3(0,0.2,size.z/2+0.7),Vector3(size.x+0.4,0.4,1.4),Color("a8a193"))
        box(house,Vector3(0,2.9,size.z/2+0.7),Vector3(size.x+0.4,0.2,1.6),Color("704d36"))
        for side in [-1,1]: box(house,Vector3(side*(size.x/2-0.4),1.5,size.z/2+1.15),Vector3(0.25,2.7,0.25),Color("ede4cc"))
    else:
        box(house,Vector3(0,size.y+0.1,0),Vector3(size.x+0.6,0.2,size.z+0.6),Color("d3cdbd"))
        # Roof water tank, a familiar feature on local homes.
        var tank:=MeshInstance3D.new()
        var cylinder:=CylinderMesh.new()
        cylinder.top_radius=0.7
        cylinder.bottom_radius=0.7
        cylinder.height=1.4
        tank.mesh=cylinder
        tank.material_override=material(Color("303835"))
        tank.position=Vector3(size.x/4,size.y+0.9,-size.z/4)
        house.add_child(tank)
        if style==2:
            box(house,Vector3(0,3.0,size.z/2+0.8),Vector3(size.x,0.18,1.6),Color("c4bba7"))
            box(house,Vector3(0,4.0,size.z/2+1.5),Vector3(size.x,0.08,0.08),Color("4a5555"))
            for bar in range(int(size.x/0.6)):
                box(house,Vector3(-size.x/2+0.3+bar*0.6,3.6,size.z/2+1.5),Vector3(0.06,1.0,0.06),Color("4a5555"))
        else:
            var awning:=box(house,Vector3(0,3,size.z/2+0.8),Vector3(size.x+0.5,0.12,2.0),Color("9a5038"))
            awning.rotation.x=0.15
            var sign:=Label3D.new()
            sign.text=["KADAVU TEA","MALABAR STORES","COCHIN BAKERY","AUTO WORKS"][index%4]
            sign.font_size=50
            sign.pixel_size=0.018
            sign.modulate=Color("282a25")
            sign.position=Vector3(0,3.7,size.z/2+0.18)
            house.add_child(sign)
    for visual in house.find_children("*","GeometryInstance3D",true,false):
        visual.visibility_range_end=160
        visual.visibility_range_end_margin=15

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
