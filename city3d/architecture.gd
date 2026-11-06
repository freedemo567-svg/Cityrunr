extends Node3D

# Shared PBR surfaces and scanned window/door modules; geometry remains original.
var facade_scene=preload("res://assets/facade/modular_urban_apartments_facade_1k.gltf")
var modules: Dictionary={}
var surfaces: Dictionary={}
var building_roots: Array[Node3D]=[]

func _init():
    var source: Node3D=facade_scene.instantiate()
    for item in source.find_children("*","MeshInstance3D",true,false):
        if item.name in ["window_centered_small_01","window_centered_large_01","door_centered_small_01"]:
            modules[str(item.name)]=item.mesh
    source.free()

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

func module(parent: Node3D, title: String, center: Vector3, target: Vector3):
    var visual:=MeshInstance3D.new()
    visual.mesh=modules[title]
    var bounds:=visual.mesh.get_aabb()
    visual.scale=target/bounds.size
    visual.position=center-(bounds.position+bounds.size/2)*visual.scale
    parent.add_child(visual)

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
    for side_index in range(4):
        var face:=Node3D.new()
        face.rotation.y=side_index*PI/2
        house.add_child(face)
        var width: float=size.x if side_index%2==0 else size.z
        var depth: float=size.z if side_index%2==0 else size.x
        for floor_index in range(maxi(1,int(size.y/3))):
            var floor_y:=1.8+floor_index*3
            for column in [-1,1]:
                if style==3 and floor_index==0 and side_index==0:
                    box(face,Vector3(column*width/4,1.25,depth/2+0.06),Vector3(width/3,2.4,0.16),Color("66776e"))
                    for slat in range(9):
                        box(face,Vector3(column*width/4,0.25+slat*0.25,depth/2+0.17),Vector3(width/3,0.025,0.04),Color("a6ada3"))
                else:
                    module(face,"window_centered_small_01" if style<2 else "window_centered_large_01",Vector3(column*width/4,floor_y,depth/2+0.09),Vector3(1.4,1.65,0.25))
                    box(face,Vector3(column*width/4,floor_y+0.95,depth/2+0.32),Vector3(1.9,0.1,0.8),Color("777b6b"))
        if side_index==0:
            module(face,"door_centered_small_01",Vector3(0,1.3,depth/2+0.1),Vector3(1.45,2.6,0.3))
    if style<2:
        roof(house,size,color)
        # Veranda pillars and wooden fascia.
        box(house,Vector3(0,0.2,size.z/2+0.7),Vector3(size.x+0.4,0.4,1.4),Color("a8a193"))
        box(house,Vector3(0,2.9,size.z/2+0.7),Vector3(size.x+0.4,0.2,1.6),Color("704d36"))
        for side in [-1,1]: box(house,Vector3(side*(size.x/2-0.4),1.5,size.z/2+1.15),Vector3(0.25,2.7,0.25),Color("ede4cc"))
    else:
        box(house,Vector3(0,size.y+0.1,0),Vector3(size.x+0.6,0.2,size.z+0.6),Color("d3cdbd"))
        for side in [-1,1]:
            box(house,Vector3(side*size.x/2,size.y+0.55,0),Vector3(0.2,0.9,size.z),color)
            box(house,Vector3(0,size.y+0.55,side*size.z/2),Vector3(size.x,0.9,0.2),color)
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
        box(plane,Vector3.ZERO,Vector3(length,0.16,size.z+1.3),Color("8a4c35"))
        for row in range(7):
            box(plane,Vector3(-length/2+(row+0.5)*length/7,0.1,0),Vector3(0.06,0.055,size.z+1.3),Color("b37250"))
    box(parent,Vector3(0,size.y+rise+0.1,0),Vector3(0.24,0.18,size.z+1.3),Color("ad6947"))
