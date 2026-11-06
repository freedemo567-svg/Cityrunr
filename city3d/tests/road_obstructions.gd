extends SceneTree
func _initialize():run.call_deferred()
func require(value: bool, message: String) -> bool:
    if not value:push_error(message);quit(1)
    return value
func run():
    var world=load("res://geodrive.tscn").instantiate()
    root.add_child(world);world.set_physics_process(false)
    var witness:=false
    # Find an actual mapped road point inside an old bounding box, outside all visible footprints.
    for tile in world.loaded.values():
        for road in tile.roads:
            for fraction in [0.1,0.3,0.5,0.7,0.9]:
                var p: Vector3=road[0].lerp(road[1],fraction)
                var cell:=Vector2i(floori(p.x/32),floori(p.z/32))
                var old_blocked:=false
                for other in world.loaded.values():
                    for obstacle in other.grid.get(cell,[]):
                        if obstacle.bounds.has_point(Vector2(p.x,p.z)):old_blocked=true
                if old_blocked and not world._blocked(p):witness=true;break
            if witness:break
        if witness:break
    if not require(witness,"No real mapped road point verified against old rectangle blocking"):return
    var original_loaded: Dictionary=world.loaded
    var original_bounds: Array=world.services.bounds.duplicate()
    world.services.bounds.clear()
    var poly:=PackedVector2Array([Vector2(0,0),Vector2(10,0),Vector2(10,2),Vector2(2,2),Vector2(2,10),Vector2(0,10)])
    var obstacle={"bounds":Rect2(-1,-1,12,12),"polygon":poly}
    world.loaded={Vector2i.ZERO:{"grid":{Vector2i.ZERO:[obstacle]}}}
    if not require(not world._blocked(Vector3(6,0,6)),"Empty concave footprint blocked"):return
    if not require(world._blocked(Vector3(1,0,5)),"Solid footprint missing"):return
    world.life.traffic.clear();world.life.crossings.signals=[];world.life.crossings.gates=[];world.train.active=false
    if not require(world._path_blocked(Vector3(3,0,5),Vector3(1,0,5)) and world.physical_obstacle,"Entering solid wall did not block"):return
    if not require(not world._path_blocked(Vector3(1,0,5),Vector3(1.2,0,5)),"Could not escape a footprint overlap"):return
    if not require(world._path_blocked(Vector3(0.3,0,5),Vector3(0.6,0,5)),"Deeper movement inside building allowed"):return
    world.loaded={}
    world.life.crossings.signals=[{"point":Vector3.ZERO,"lamps":[]}]
    world.life.crossings.elapsed=0
    if not require(world._path_blocked(Vector3(8.1,0,0),Vector3(7.9,0,0)) and not world.physical_obstacle,"Red approach did not stop safely"):return
    if not require(world._path_blocked(Vector3(6.9,0,0),Vector3(5.9,0,0)),"Movement crossed the red stop ring"):return
    if not require(not world._path_blocked(Vector3(7.9,0,0),Vector3(8.1,0,0)),"Cannot reverse away from red signal"):return
    if not require(not world._path_blocked(Vector3(5.9,0,0),Vector3(6.1,0,0)),"Cannot exit junction when signal changes"):return
    world.life.crossings.elapsed=10
    if not require(not world._path_blocked(Vector3(8.1,0,0),Vector3(7.9,0,0)),"Green signal still blocks"):return
    world.life.crossings.signals=[];world.life.crossings.gates=[{"point":Vector3.ZERO,"closed":true}]
    if not require(world._path_blocked(Vector3(7.1,0,0),Vector3(6.9,0,0)),"Closed gate did not stop approach"):return
    if not require(not world._path_blocked(Vector3(6.9,0,0),Vector3(7.1,0,0)),"Cannot back out of closed gate"):return
    world.life.crossings.gates=[]
    world.services.bounds.append(Rect2(-2,-2,4,4))
    if not require(not world._path_blocked(Vector3(1,0,0),Vector3(1.1,0,0)),"Cannot exit service overlap"):return
    if not require(world._path_blocked(Vector3(3,0,0),Vector3(1.9,0,0)),"Service obstacle no longer blocks entry"):return
    world.services.bounds.clear()
    var traffic:=Node3D.new();world.add_child(traffic);traffic.position=Vector3(5,0,0)
    world.life.traffic=[{"node":traffic,"a":Vector3(0,0,0),"b":Vector3(20,0,0),"forward":false}]
    world.car.position=Vector3.ZERO;world.life.traffic_origin=Vector3.ZERO;world.life.crossings.origin=Vector3.ZERO
    world.life.tick(0.1)
    if not require(traffic.position.x>5,"Traffic did not move away from approaching player"):return
    if not require(not world._path_blocked(Vector3(4,0,0),Vector3(3.9,0,0)),"Cannot back out of traffic overlap"):return
    if not require(world._path_blocked(Vector3(2,0,0),Vector3(3.3,0,0)),"Traffic collision missing"):return
    world.life.traffic=[];traffic.queue_free();world.loaded=original_loaded;world.services.bounds.assign(original_bounds)
    for city in ["Kochi","Thiruvananthapuram","Kozhikode","Thrissur"]:
        world.speed=0;world._search(city);world._go(world.matches[0].point)
        if not require(not world._blocked(world.car.position),"City road spawn inside building: "+city):return
    print("Mapped and concave footprint clearance, physical collisions, retreat, signals, gates, traffic and safe city spawns passed")
    quit()
