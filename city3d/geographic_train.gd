extends Node3D

# Illustrative train on mapped rail segments; there are no timetable data.
var points: Dictionary={}
var links: Dictionary={}
var from_key: Vector2i
var to_key: Vector2i
var progress := 0.0
var active := false
var search_delay := 0.0
const SPEED := 12.0

func _ready():
    visible=false
    for coach in range(2):
        var offset: float=-coach*13.0
        _box(Vector3(0,1.5,offset),Vector3(2.8,2.4,12.0),Color("b87745") if coach==0 else Color("457992"))
        _box(Vector3(0,2.78,offset),Vector3(2.9,0.18,12.1),Color("d9d5c8"))
        _box(Vector3(0,0.48,offset),Vector3(2.7,0.55,11.8),Color("333f40"))
        for side in [-1,1]:
            for window in range(5):
                _box(Vector3(side*1.41,1.95,offset-4.4+window*2.2),Vector3(0.04,0.75,1.35),Color("263d48"))
            for axle in [-4.0,4.0]:
                _box(Vector3(side*1.32,0.40,offset+axle),Vector3(0.25,0.65,0.85),Color("252b2b"))

func _box(pos: Vector3, dimensions: Vector3, color: Color):
    var visual:=MeshInstance3D.new()
    var mesh:=BoxMesh.new()
    mesh.size=dimensions
    visual.mesh=mesh
    var material:=StandardMaterial3D.new()
    material.albedo_color=color
    material.roughness=0.8
    visual.material_override=material
    visual.position=pos
    add_child(visual)

func _key(point: Array) -> Vector2i:
    return Vector2i(roundi(float(point[0])*10),roundi(float(point[1])*10))

func set_tracks(tiles: Array):
    points.clear()
    links.clear()
    for tile in tiles:
        for segment in tile.get("rail",[]):
            var a:=_key(segment[0])
            var b:=_key(segment[1])
            if a==b: continue
            points[a]=Vector3(float(segment[0][0]),0,float(segment[0][1]))
            points[b]=Vector3(float(segment[1][0]),0,float(segment[1][1]))
            if not links.has(a): links[a]=[]
            if not links.has(b): links[b]=[]
            if not links[a].has(b): links[a].append(b)
            if not links[b].has(a): links[b].append(a)
    if active and (not links.has(from_key) or not links[from_key].has(to_key)):
        active=false
        visible=false
    search_delay=0

func _find_track(focus: Vector3):
    var best:=250.0*250.0
    var closest:=Vector3.ZERO
    var found:=false
    for a in links:
        for b in links[a]:
            var p: Vector3=Geometry3D.get_closest_point_to_segment(focus,points[a],points[b])
            var distance:=focus.distance_squared_to(p)
            # Do not create the train on top of the player's vehicle.
            if distance<40.0*40.0:
                var first: Vector3=points[a]
                var second: Vector3=points[b]
                var first_distance:=focus.distance_squared_to(first)
                var second_distance:=focus.distance_squared_to(second)
                if first_distance>=40.0*40.0 and (second_distance<40.0*40.0 or first_distance<=second_distance):
                    p=first
                    distance=first_distance
                elif second_distance>=40.0*40.0:
                    p=second
                    distance=second_distance
                else:
                    continue
            if distance<best:
                best=distance
                from_key=a
                to_key=b
                closest=p
                found=true
    if found:
        var length: float=points[from_key].distance_to(points[to_key])
        progress=points[from_key].distance_to(closest)/length
        active=true
        visible=true
        _place()

func _place():
    var a: Vector3=points[from_key]
    var b: Vector3=points[to_key]
    position=a.lerp(b,progress)
    rotation.y=atan2(b.x-a.x,b.z-a.z)

func tick(delta: float, focus: Vector3):
    if not active:
        search_delay-=delta
        if search_delay<=0:
            search_delay=2.0
            _find_track(focus)
        if not active: return
    if position.distance_to(focus)>500:
        active=false
        visible=false
        return
    var remaining:=maxf(delta,0)*SPEED
    while remaining>0:
        var a: Vector3=points[from_key]
        var b: Vector3=points[to_key]
        var length:=a.distance_to(b)
        var available:=length*(1-progress)
        if remaining<available:
            progress+=remaining/length
            remaining=0
        else:
            remaining-=available
            var previous:=from_key
            from_key=to_key
            var direction: Vector3=(b-a).normalized()
            var best_dot:=-2.0
            var next:=previous
            for candidate in links[from_key]:
                if candidate==previous: continue
                var candidate_direction: Vector3=(points[candidate]-b).normalized()
                var dot:=direction.dot(candidate_direction)
                if dot>best_dot:
                    best_dot=dot
                    next=candidate
            to_key=next
            progress=0
    _place()

func blocks(pos: Vector3) -> bool:
    if not active: return false
    var local:=to_local(pos)
    return absf(local.x)<2.4 and local.z>-20.0 and local.z<7.0
