extends RefCounted

# Fictional Kochi-inspired neighbourhood, not a geographic reconstruction.
var roads: Array[PackedVector3Array] = []
var buildings: Array[Dictionary] = []

func _init():
    var routes = [
        [Vector3(-20,0,-148),Vector3(15,0,-95),Vector3(-12,0,-40),Vector3(0,0,0),Vector3(30,0,60),Vector3(65,0,145)],
        [Vector3(-148,0,10),Vector3(-95,0,-15),Vector3(-45,0,12),Vector3(0,0,0),Vector3(65,0,18),Vector3(148,0,50)],
        [Vector3(-100,0,-90),Vector3(-30,0,-120),Vector3(85,0,-85),Vector3(120,0,0),Vector3(100,0,100),Vector3(0,0,125),Vector3(-120,0,100),Vector3(-130,0,0),Vector3(-100,0,-90)],
        [Vector3(-100,0,-90),Vector3(-65,0,-45),Vector3(-45,0,12)],
        [Vector3(15,0,-95),Vector3(55,0,-50),Vector3(120,0,0)],
        [Vector3(-120,0,100),Vector3(-65,0,60),Vector3(30,0,60),Vector3(100,0,100)]
    ]
    for route in routes:
        var samples := PackedVector3Array()
        for i in range(route.size()-1):
            var a: Vector3=route[maxi(i-1,0)]
            var b: Vector3=route[i]
            var c: Vector3=route[i+1]
            var d: Vector3=route[mini(i+2,route.size()-1)]
            for j in range(12):
                samples.append(b.cubic_interpolate(c,a,d,j/12.0))
        samples.append(route[-1])
        roads.append(samples)
    var rng := RandomNumberGenerator.new()
    rng.seed=2907
    for x in range(-138,139,23):
        for z in range(-138,139,23):
            var pos:=Vector3(x+rng.randf_range(-3,3),0,z+rng.randf_range(-3,3))
            if pos.x < -136 or absf(pos.z-112)<12 or absf(pos.z+60)<9 or nearest(pos).distance_to(pos)<19: continue
            var style:=rng.randi_range(0,3)
            var size:=Vector3(rng.randf_range(8,13),[3.5,5.0,9.0,6.0][style],rng.randf_range(8,12))
            buildings.append({"position":pos,"size":size,"style":style,"color":Color.from_hsv(rng.randf(),0.18,0.85)})

func nearest(pos: Vector3) -> Vector3:
    var best:=Vector3.ZERO
    var distance:=INF
    for road in roads:
        for i in range(road.size()-1):
            var point:=Geometry3D.get_closest_point_to_segment(pos,road[i],road[i+1])
            if pos.distance_squared_to(point)<distance:
                distance=pos.distance_squared_to(point)
                best=point
    return best

func blocked(pos: Vector3, margin: float=1.0) -> bool:
    for building in buildings:
        var p: Vector3=building.position
        var s: Vector3=building.size
        if absf(pos.x-p.x)<s.x/2+margin and absf(pos.z-p.z)<s.z/2+margin: return true
    return false
