extends Node3D
# Illustrative controls at mapped junctions/crossings, not surveyed junction assets.
var signals: Array=[]
var gates: Array=[]
var elapsed:=0.0
var origin:=Vector3(INF,0,0)
func refresh(tiles: Array, focus: Vector3):
    if focus.distance_to(origin)<250:return
    origin=focus
    for child in get_children():remove_child(child);child.queue_free()
    signals.clear();gates.clear()
    var endpoints: Dictionary={}
    var roads: Array=[]
    var rails: Array=[]
    for tile in tiles:
        for road in tile.roads:
            if Geometry3D.get_closest_point_to_segment(focus,road[0],road[1]).distance_to(focus)>180:continue
            roads.append(road)
            for point in road:
                var key:=Vector2i(roundi(point.x),roundi(point.z))
                if not endpoints.has(key):endpoints[key]={"count":0,"point":point}
                endpoints[key].count+=1
        for rail in tile.rail:
            rails.append([Vector3(rail[0][0],0,rail[0][1]),Vector3(rail[1][0],0,rail[1][1])])
    for entry in endpoints.values():
        if entry.count<3 or signals.size()>=8:continue
        var point: Vector3=entry.point
        var post:=Node3D.new()
        add_child(post)
        post.position=point+Vector3(5,0,5)
        cube(post,Vector3(0,1.6,0),Vector3(0.12,3.2,0.12),Color("687572"))
        cube(post,Vector3(0,3.1,0),Vector3(0.4,1.15,0.35),Color("182321"))
        var lamps: Array=[]
        for i in range(3):
            var lamp=cube(post,Vector3(0,3.45-i*0.34,-0.2),Vector3(0.24,0.24,0.06),[Color.RED,Color.ORANGE,Color.GREEN][i])
            lamps.append(lamp.material_override)
        signals.append({"point":point,"lamps":lamps})
    for road in roads:
        if gates.size()>=4:break
        for rail in rails:
            var crossing=Geometry2D.segment_intersects_segment(Vector2(road[0].x,road[0].z),Vector2(road[1].x,road[1].z),Vector2(rail[0].x,rail[0].z),Vector2(rail[1].x,rail[1].z))
            if crossing==null:continue
            var point:=Vector3(crossing.x,0,crossing.y)
            var duplicate:=false
            for gate in gates:
                if gate.point.distance_to(point)<12:duplicate=true
            if duplicate:continue
            var pivot:=Node3D.new()
            add_child(pivot)
            var forward: Vector3=(road[1]-road[0]).normalized()
            pivot.position=point+forward*5+forward.cross(Vector3.UP)*4+Vector3.UP
            pivot.rotation.y=atan2(forward.x,forward.z)
            var arm:=Node3D.new()
            pivot.add_child(arm)
            for stripe in range(8):cube(arm,Vector3(-stripe*0.9,0,0),Vector3(0.9,0.14,0.18),Color("e7e4d5") if stripe%2==0 else Color("b1352d"))
            gates.append({"point":point,"arm":arm,"closed":false})
            break
func cube(parent: Node3D, position: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
    var mesh:=MeshInstance3D.new()
    var box:=BoxMesh.new()
    box.size=size;mesh.mesh=box;mesh.position=position
    var material:=StandardMaterial3D.new()
    material.albedo_color=color
    mesh.material_override=material
    parent.add_child(mesh)
    return mesh
func tick(delta: float, train: Node3D):
    elapsed=fmod(elapsed+delta,16)
    var phase:=0 if elapsed<7 else (1 if elapsed<9 else 2)
    for junction in signals:
        for i in range(3):
            junction.lamps[i].emission_enabled=i==phase
            junction.lamps[i].emission=junction.lamps[i].albedo_color
            junction.lamps[i].emission_energy_multiplier=2 if i==phase else 0
    for gate in gates:
        gate.closed=train.active and train.position.distance_to(gate.point)<70
        gate.arm.rotation.z=move_toward(gate.arm.rotation.z,0 if gate.closed else -PI/2,delta*1.5)
func blocks(point: Vector3) -> bool:
    for gate in gates:
        if gate.closed and point.distance_to(gate.point)<7:return true
    # Vehicles wait before the centre rather than stopping inside the junction.
    if elapsed<9:
        for junction in signals:
            var distance:=point.distance_to(junction.point)
            if distance>6 and distance<8:return true
    return false
