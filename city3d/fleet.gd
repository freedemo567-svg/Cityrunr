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
    var mesh:=preload("res://vehicle_geometry.gd").rounded_box(size)
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
func build(parent: Node3D, kind: int, detailed := true):
    if kind==0: return preload("res://vehicle_visuals.gd").new().sports(parent,detailed)
    var root:=Node3D.new()
    root.name="CarVisual"
    parent.add_child(root)
    var paint=material([Color("245b87"),Color("34604b"),Color("d4a62b"),Color("8b3330"),Color("c8c7bc"),Color("94613c")][kind],0.35)
    paint.clearcoat_enabled=true
    paint.clearcoat=0.6
    paint.clearcoat_roughness=0.25
    paint.resource_name="Paint 1 Fleet"
    var trim=material(Color("20272a"))
    var chrome=material(Color("a9afb0"),0.8)
    var glass=material(Color("17292f"),0.25)
    glass.roughness=0.18
    var tire=material(Color("181c1d"))
    var length: float=LENGTHS[kind]
    var width: float=WIDTHS[kind]
    var wheels: Array[Node3D]=[]
    var steering_wheels: Array[Node3D]=[]
    var radius:=0.52 if kind in [3,5] else 0.34
    var wheel_locations: Array[Vector3]=[]
    if kind==1:
        wheel_locations=[Vector3(0,radius,0.75),Vector3(0,radius,-0.75)]
        box(root,Vector3(0,0.72,0),Vector3(0.4,0.45,1.0),paint)
        box(root,Vector3(0,0.98,-0.35),Vector3(0.5,0.15,0.8),trim)
        for side in [-1,1]:
            box(root,Vector3(side*0.2,0.85,0.5),Vector3(0.06,0.9,0.1),chrome)
            box(root,Vector3(side*0.28,0.45,-0.3),Vector3(0.09,0.1,1.1),chrome)
            box(root,Vector3(side*0.35,1.32,0.55),Vector3(0.25,0.08,0.08),trim)
        cylinder(root,Vector3(0,0.55,0),0.25,0.5,chrome,true)
    elif kind==2:
        wheel_locations=[Vector3(0,radius,1),Vector3(-0.65,radius,-0.9),Vector3(0.65,radius,-0.9)]
        box(root,Vector3(0,0.55,0),Vector3(1.4,0.35,2.6),paint)
        box(root,Vector3(0,1.0,-0.65),Vector3(1.4,0.75,1.2),paint)
        box(root,Vector3(0,1.7,-0.4),Vector3(1.5,0.16,2.1),trim)
        box(root,Vector3(0,1.25,0.6),Vector3(1.35,0.8,0.1),glass)
        box(root,Vector3(0,0.9,0.8),Vector3(1.1,0.65,0.65),paint)
        box(root,Vector3(0,0.88,-0.45),Vector3(1.18,0.2,0.65),trim)
        box(root,Vector3(0,1.15,-0.8),Vector3(1.18,0.5,0.12),trim)
        for side in [-1,1]:
            for z in [-1.25,0.65]:
                box(root,Vector3(side*0.66,1.27,z),Vector3(0.065,0.85,0.065),trim)
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
        if pos.z>0: steering_wheels.append(pivot)
        var spin:=Node3D.new()
        spin.name="WheelSpin"
        spin.set_meta("radius",radius)
        pivot.add_child(spin)
        var rubber:=MeshInstance3D.new()
        var torus:=TorusMesh.new()
        torus.inner_radius=radius*0.6
        torus.outer_radius=radius
        torus.rings=32 if detailed else 20
        torus.ring_segments=12 if detailed else 8
        rubber.mesh=torus
        rubber.rotation.z=PI/2
        rubber.material_override=tire
        spin.add_child(rubber)
        cylinder(spin,Vector3.ZERO,radius*0.68,0.17,trim,true)
        for side in [-1,1]:
            cylinder(spin,Vector3(side*0.095,0,0),radius*0.48,0.025,chrome,true)
            cylinder(spin,Vector3(side*0.12,0,0),radius*0.15,0.03,trim,true)
            for spoke in range(5):
                var bar: MeshInstance3D=box(spin,Vector3(side*0.12,0,0),Vector3(0.035,radius*1.18,0.045),chrome)
                bar.rotation.x=spoke*TAU/5
        wheels.append(spin)
    _body_details(root,kind,length,width,paint,trim,chrome)
    preload("res://vehicle_visuals.gd").new().contact_shadow(root,Vector2(width+0.3,length+0.2))
    var lamps: Dictionary={}
    for name in ["Headlight","Brakelight"]:
        var m=material(Color("eee8cb") if name=="Headlight" else Color("b5231b"))
        m.emission_enabled=true
        m.emission=Color("f8e8b9") if name=="Headlight" else Color("eb2719")
        m.emission_energy_multiplier=0.1
        lamps[name]=m
        for side in ([0] if kind in [1,2] else [-1,1]):
            var lamp_y:=1.15 if kind in [1,2] and name=="Headlight" else 0.85
            var lamp_z: float=length/2+0.08 if name=="Headlight" else -length/2-0.03
            if kind==1: lamp_z=0.76 if name=="Headlight" else -0.84
            if kind==2: lamp_z=1.15 if name=="Headlight" else -1.32
            box(root,Vector3(side*width*0.32,lamp_y,lamp_z),Vector3(0.25,0.18,0.08),m)
    parent.set_meta("paints",[paint])
    parent.set_meta("lamps",lamps)
    parent.set_meta("wheel_nodes",wheels)
    parent.set_meta("steering_nodes",steering_wheels)
    parent.set_meta("kind",kind)
    return root

func _body_details(root: Node3D, kind: int, length: float, width: float, paint: Material, trim: Material, chrome: Material):
    if kind==1:
        var tank:=MeshInstance3D.new()
        var sphere:=SphereMesh.new()
        sphere.radius=0.29
        sphere.height=0.58
        tank.mesh=sphere
        tank.material_override=paint
        tank.position=Vector3(0,0.98,0.06)
        tank.scale=Vector3(0.8,0.8,1.3)
        root.add_child(tank)
        for side in [-1,1]:
            cylinder(root,Vector3(side*0.32,1.46,0.53),0.1,0.045,chrome).rotation.x=PI/2
        return
    for side in [-1,1]:
        var height:=1.15 if kind==2 else 1.5
        box(root,Vector3(side*(width/2+0.03),height,length/2-0.85),Vector3(0.04,0.06,0.3),chrome)
        if kind==3:
            box(root,Vector3(side*(width/2+0.12),2.45,length/2-0.2),Vector3(0.22,0.4,0.17),trim)
            # A continuous pale belt and wheel-arch trim break up the bus mass.
            box(root,Vector3(side*(width/2+0.035),1.36,0),Vector3(0.05,0.22,length-0.15),material(Color("bdb8a3")))
            for axle in [-1,1]:
                box(root,Vector3(side*(width/2+0.025),1.03,axle*(length/2-1)),Vector3(0.08,0.12,1.25),trim)
        elif kind==4:
            box(root,Vector3(side*(width/2+0.03),1.3,-0.9),Vector3(0.03,0.025,2.45),trim)
            box(root,Vector3(side*(width/2+0.035),1.5,-1.7),Vector3(0.04,0.07,0.25),chrome)
        elif kind==5:
            box(root,Vector3(side*(width/2+0.05),0.8,-0.7),Vector3(0.1,0.14,length-2.8),chrome)
    if kind in [3,4,5]:
        for slat in range(5):
            box(root,Vector3(0,0.8+slat*0.085,length/2+0.12),Vector3(width*0.56,0.028,0.04),chrome)
        for side in [-1,1]:
            var wiper: MeshInstance3D=box(root,Vector3(side*width*0.23,1.6,length/2+0.08),Vector3(0.035,0.55,0.035),trim)
            wiper.rotation.z=side*0.25
    # Fictional local plate styling; no real registration is reproduced.
    for end in [-1,1]:
        box(root,Vector3(0,0.58,end*(length/2+0.145)),Vector3(0.43,0.13,0.025),material(Color("b3a578")))

func animate(parent: Node3D, distance: float, steering: float):
    for wheel in parent.get_meta("wheel_nodes",[]):
        wheel.rotation.x=fposmod(wheel.rotation.x+distance/float(wheel.get_meta("radius",0.34)),TAU)
    for pivot in parent.get_meta("steering_nodes",[]):
        pivot.rotation.y=-clampf(steering,-1,1)*0.45
