extends RefCounted
const NAMES := ["Sports car","Motorcycle","Auto rickshaw","City bus","Cargo van","Lorry"]
const SPEEDS := [22.0,26.0,14.0,18.0,19.0,15.0]
const LENGTHS := [4.2,2.2,3.0,8.4,5.0,7.0]
const WIDTHS := [1.8,0.7,1.5,2.5,1.9,2.5]
func material(color: Color, metallic := 0.0):
    var m:=StandardMaterial3D.new()
    m.albedo_color=color
    m.metallic=metallic
    m.roughness=0.35 if metallic>0 else 0.8
    return m
func box(parent: Node3D, pos: Vector3, size: Vector3, mat: Material):
    var n:=MeshInstance3D.new()
    var mesh:=BoxMesh.new()
    mesh.size=size
    n.mesh=mesh
    n.material_override=mat
    n.position=pos
    parent.add_child(n)
    return n
func cylinder(parent: Node3D, pos: Vector3, radius: float, height: float, mat: Material, wheel := false):
    var n:=MeshInstance3D.new()
    var mesh:=CylinderMesh.new()
    mesh.top_radius=radius
    mesh.bottom_radius=radius
    mesh.height=height
    mesh.radial_segments=24
    n.mesh=mesh
    n.material_override=mat
    n.position=pos
    if wheel:n.rotation.z=PI/2
    parent.add_child(n)
    return n
func build(parent: Node3D, kind: int):
    var root:=Node3D.new()
    root.name="CarVisual"
    parent.add_child(root)
    var paint=material(Color("3d6683"),0.4)
    paint.resource_name="Paint 1 Fleet"
    var trim=material(Color("20272a"))
    var chrome=material(Color("a9afb0"),0.8)
    var glass=material(Color("263e49"),0.4)
    var tire=material(Color("181c1d"))
    var length: float=LENGTHS[kind]
    var width: float=WIDTHS[kind]
    var wheels: Array[Node3D]=[]
    var radius:=0.52 if kind in [3,5] else 0.34
    var wheel_locations: Array[Vector3]=[]
    if kind==1:
        wheel_locations=[Vector3(0,radius,0.75),Vector3(0,radius,-0.75)]
        box(root,Vector3(0,0.72,0),Vector3(0.4,0.45,1.0),paint)
        box(root,Vector3(0,0.98,-0.35),Vector3(0.5,0.15,0.8),trim)
        for side in [-1,1]:
            box(root,Vector3(side*0.2,0.6,0.5),Vector3(0.06,0.7,0.1),chrome)
            box(root,Vector3(side*0.28,0.45,-0.3),Vector3(0.09,0.1,1.1),chrome)
            box(root,Vector3(side*0.35,1.32,0.55),Vector3(0.25,0.08,0.08),trim)
        cylinder(root,Vector3(0,0.55,0),0.25,0.5,chrome,true)
    elif kind==2:
        wheel_locations=[Vector3(0,radius,1),Vector3(-0.65,radius,-0.9),Vector3(0.65,radius,-0.9)]
        box(root,Vector3(0,0.55,0),Vector3(1.4,0.35,2.6),paint)
        box(root,Vector3(0,1.0,-0.65),Vector3(1.4,0.75,1.2),paint)
        box(root,Vector3(0,1.7,-0.4),Vector3(1.5,0.16,2.1),trim)
        box(root,Vector3(0,1.25,0.6),Vector3(1.35,0.8,0.1),glass)
        for side in [-1,1]:box(root,Vector3(side*0.67,1.25,-0.4),Vector3(0.08,0.9,1.9),trim)
    else:
        for side in [-1,1]:
            for axle in [-1,1]:wheel_locations.append(Vector3(side*width/2,radius,axle*(length/2-1)))
        box(root,Vector3(0,0.55,0),Vector3(width,0.3,length),trim)
        if kind==3:
            box(root,Vector3(0,1.75,0),Vector3(width,2.3,length),paint)
            box(root,Vector3(0,2.05,length/2+0.02),Vector3(width-0.15,1.3,0.08),glass)
            for side in [-1,1]:
                for i in range(7):box(root,Vector3(side*(width/2+0.02),2.1,-length/2+0.8+i*1.05),Vector3(0.06,1.05,0.9),glass)
                box(root,Vector3(side*width/2,1.1,0),Vector3(0.08,0.15,length),chrome)
        else:
            box(root,Vector3(0,1.3,length/2-1),Vector3(width,1.6,1.9),paint)
            box(root,Vector3(0,1.65,length/2-0.04),Vector3(width-0.2,0.7,0.08),glass)
            for side in [-1,1]:
                box(root,Vector3(side*(width/2+0.02),1.65,length/2-1),Vector3(0.06,0.65,1.5),glass)
                box(root,Vector3(side*(width/2+0.16),1.8,length/2-0.4),Vector3(0.25,0.35,0.18),chrome)
            box(root,Vector3(0,1.5,-1),Vector3(width,1.8,length-2.1),paint if kind==4 else material(Color("8c6d4d")))
            if kind==5:
                for i in range(7):box(root,Vector3(0,1.65,-length/2+0.4+i*0.6),Vector3(width+0.05,0.05,0.1),chrome)
        box(root,Vector3(0,0.65,length/2+0.1),Vector3(width,0.2,0.2),chrome)
        box(root,Vector3(0,1.0,length/2+0.06),Vector3(width*0.6,0.3,0.1),trim)
    for pos in wheel_locations:
        var pivot:=Node3D.new()
        pivot.position=pos
        root.add_child(pivot)
        cylinder(pivot,Vector3.ZERO,radius,0.22,tire,true)
        cylinder(pivot,Vector3(0.12,0,0),radius*0.62,0.04,chrome,true)
        wheels.append(pivot)
    var lamps: Dictionary={}
    for name in ["Headlight","Brakelight"]:
        var m=material(Color("eee8cb") if name=="Headlight" else Color("b5231b"))
        m.emission_enabled=true
        m.emission=Color("f8e8b9") if name=="Headlight" else Color("eb2719")
        m.emission_energy_multiplier=0.1
        lamps[name]=m
        for side in [-1,1]:box(root,Vector3(side*width*0.32,0.85,length/2+0.08 if name=="Headlight" else -length/2-0.03),Vector3(0.25,0.18,0.08),m)
    parent.set_meta("paints",[paint])
    parent.set_meta("lamps",lamps)
    parent.set_meta("wheel_nodes",wheels)
    parent.set_meta("kind",kind)
    return root
