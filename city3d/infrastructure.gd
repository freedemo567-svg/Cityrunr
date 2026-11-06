extends Node3D
var world: Node3D
var elapsed := 0.0
var signals: Array[Dictionary]=[]
var bridges: Array[Dictionary]=[]
var crossings: Array[Dictionary]=[]
var train: Node3D
var train_x := -190.0
const RAIL_Z := 112.0
const CANAL_Z := -60.0
func setup(owner_world: Node3D):
    world=owner_world
    _coast()
    _canal_bridges()
    _railway()
    for index in [0,36]:
        var pos: Vector3=world.town.roads[2][index]
        var light_entry: Node3D=Node3D.new()
        light_entry.position=pos+Vector3(7,0,0)
        add_child(light_entry)
        box(light_entry,Vector3(0,2.1,0),Vector3(0.15,4.2,0.15),Color("555c5d"))
        box(light_entry,Vector3(0,4,0),Vector3(0.7,1.9,0.4),Color("202929"))
        var lamps: Array[MeshInstance3D]=[]
        for lamp in range(3):
            var mesh:=MeshInstance3D.new()
            var sphere:=SphereMesh.new()
            sphere.radius=0.22
            sphere.height=0.44
            mesh.mesh=sphere
            mesh.material_override=world._material(Color("282b25"))
            mesh.material_override.emission_enabled=true
            mesh.position=Vector3(0,4.6-lamp*0.6,0.24)
            light_entry.add_child(mesh)
            lamps.append(mesh)
        signals.append({"progress":float(index),"position":pos,"lamps":lamps})
        sign_at(pos+Vector3(0,4,8),"SIGNAL JUNCTION")
    tick(0)
func box(parent: Node3D, pos: Vector3, size: Vector3, color: Color, solid := false):
    return world._box(parent,pos,size,color,solid)
func sign_at(pos: Vector3, title: String):
    var sign:=Label3D.new()
    sign.text=title
    sign.position=pos
    sign.font_size=44
    sign.pixel_size=0.018
    add_child(sign)
func _coast():
    box(self,Vector3(-400,0.025,0),Vector3(496,0.04,800),Color("3d8b9d"))
    box(self,Vector3(-146,0.045,0),Vector3(12,0.04,320),Color("d7bc85"))
    for z in range(-140,141,16):
        box(self,Vector3(-151,0.071,z),Vector3(0.4,0.02,9),Color("d7e5dc"))
        if z%32== -12:
            world._palm(Vector3(-139,0,z))
    sign_at(Vector3(-140,4,30),"KADAVU BEACH")
func _canal_bridges():
    box(self,Vector3(0,0.025,CANAL_Z),Vector3(280,0.04,8),Color("397b82"))
    for road in world.town.roads:
        for i in range(road.size()-1):
            var a: Vector3=road[i]
            var b: Vector3=road[i+1]
            if (a.z-CANAL_Z)*(b.z-CANAL_Z)>=0: continue
            var pos:=a.lerp(b,(CANAL_Z-a.z)/(b.z-a.z))
            var bridge:=Node3D.new()
            bridge.position=pos
            bridge.rotation.y=atan2(b.x-a.x,b.z-a.z)
            add_child(bridge)
            bridges.append({"node":bridge,"position":pos})
            box(bridge,Vector3(0,0.075,0),Vector3(12,0.04,18),Color("636c68"))
            for side in [-1,1]:
                box(bridge,Vector3(side*6.3,0.8,0),Vector3(0.25,0.22,18),Color("d2c9ae"),true)
                for z in [-8,-4,0,4,8]:
                    box(bridge,Vector3(side*6.3,0.5,z),Vector3(0.3,1,0.3),Color("c9c3b7"),true)
            sign_at(pos+Vector3(0,4,0),"CANAL BRIDGE")
func _railway():
    box(self,Vector3(0,0.065,RAIL_Z),Vector3(290,0.05,4),Color("7b756c"))
    for x in range(-144,145,2):
        box(self,Vector3(x,0.1,RAIL_Z),Vector3(0.25,0.06,3.1),Color("685547"))
    for side in [-1,1]: box(self,Vector3(0,0.14,RAIL_Z+side),Vector3(290,0.1,0.08),Color("a3aaa9"))
    for road in world.town.roads:
        for i in range(road.size()-1):
            var a: Vector3=road[i]
            var b: Vector3=road[i+1]
            if (a.z-RAIL_Z)*(b.z-RAIL_Z)>=0: continue
            var pos:=a.lerp(b,(RAIL_Z-a.z)/(b.z-a.z))
            var gates: Array[Node3D]=[]
            for side in [-1,1]:
                var gate:=Node3D.new()
                gate.position=pos+Vector3(-6.5,1.1,side*6)
                add_child(gate)
                box(self,gate.position-Vector3(0,0.55,0),Vector3(0.5,1.1,0.5),Color("d9ad39"),true)
                box(gate,Vector3(6,0,0),Vector3(12,0.18,0.25),Color("e9e0cb"))
                for stripe in range(6): box(gate,Vector3(1+stripe*2,0,0),Vector3(0.7,0.21,0.3),Color("bf4737"))
                gates.append(gate)
            crossings.append({"position":pos,"gates":gates,"closed":false})
            sign_at(pos+Vector3(8,4,0),"RAIL CROSSING")
    train=Node3D.new()
    train.position=Vector3(train_x,0,RAIL_Z)
    add_child(train)
    for coach in range(4):
        var carriage:=Node3D.new()
        carriage.position.x=-coach*14
        train.add_child(carriage)
        box(carriage,Vector3(0,1.5,0),Vector3(12,2.5,2.8),Color("b56b35") if coach==0 else Color("397b97"),true)
        box(carriage,Vector3(0,2.85,0),Vector3(12,0.25,2.85),Color("dad7ca"))
        for side in [-1,1]:
            for x in [-4,-2,0,2,4]: box(carriage,Vector3(x,2.1,side*1.42),Vector3(1.25,0.8,0.06),Color("263c48"))
            for x in [-4,4]:
                var wheel:=MeshInstance3D.new()
                var cylinder:=CylinderMesh.new()
                cylinder.top_radius=0.45
                cylinder.bottom_radius=0.45
                cylinder.height=0.2
                wheel.mesh=cylinder
                wheel.position=Vector3(x,0.48,side*1.3)
                wheel.rotation.x=PI/2
                wheel.material_override=world._material(Color("323a3b"))
                carriage.add_child(wheel)
func signal_phase() -> int:
    var cycle:=fposmod(elapsed,32)
    return 2 if cycle<12 else (1 if cycle<15 else 0)
func tick(delta: float):
    elapsed+=delta
    train_x=fposmod(train_x+delta*12+210,480)-210
    train.position.x=train_x
    var phase:=signal_phase()
    for light_entry in signals:
        for i in range(3):
            var lamp: StandardMaterial3D=light_entry.lamps[i].material_override
            var color: Color=[Color("e44030"),Color("edc546"),Color("4ad280")][i]
            lamp.albedo_color=color if i==phase else color.darkened(0.85)
            lamp.emission=color if i==phase else Color.BLACK
    for crossing in crossings:
        # Close early, keep the barrier down until the last coach clears it.
        crossing.closed=train_x>crossing.position.x-42 and train_x<crossing.position.x+58
        for gate in crossing.gates: gate.rotation.z=0 if crossing.closed else -PI/2
func stop_traffic(progress: float, next_position: Vector3) -> bool:
    if signal_phase()!=2:
        var count: int=world.town.roads[2].size()-1
        for light_entry in signals:
            var ahead:=fposmod(light_entry.progress-progress,count)
            if ahead>0 and ahead<2.2: return true
    return blocks_vehicle(next_position,next_position)
func blocks_vehicle(from: Vector3, to: Vector3) -> bool:
    if to.x< -151: return true
    if absf(to.z-CANAL_Z)<4 and absf(to.x)<140:
        var on_bridge:=false
        for bridge in bridges:
            var local: Vector3=bridge.node.to_local(to)
            if absf(local.x)<5.8 and absf(local.z)<11: on_bridge=true
        if not on_bridge: return true
    for crossing in crossings:
        if crossing.closed and absf(to.x-crossing.position.x)<9:
            for line in [RAIL_Z-6,RAIL_Z+6]:
                if (from.z-line)*(to.z-line)<0: return true
            if from==to and absf(to.z-RAIL_Z)<8: return true
    # Swept tests in the driving loop keep vehicles out of the moving train.
    return absf(to.z-RAIL_Z)<2.8 and to.x>train_x-49 and to.x<train_x+7
