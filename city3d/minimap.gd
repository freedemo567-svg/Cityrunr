extends Control
var world: Node3D
func _process(_delta):
    queue_redraw()
func _draw():
    if not is_instance_valid(world): return
    draw_rect(Rect2(Vector2.ZERO,size),Color(0.06,0.1,0.15,0.9))
    for road in world.town.roads:
        for i in range(road.size()-1):
            draw_line(_point(road[i]),_point(road[i+1]),Color("667982"),5)
    draw_line(_point(Vector3(-145,0,112)),_point(Vector3(145,0,112)),Color("c4a77a"),2)
    for bridge in world.features.bridges: draw_circle(_point(bridge.position),3,Color("a9d2d7"))
    for light_entry in world.features.signals: draw_circle(_point(light_entry.position),3,Color("74df9e") if world.features.signal_phase()==2 else Color("ef765b"))
    draw_circle(_point(world.features.train.position),4,Color("ffb663"))
    for car in world.traffic: draw_circle(_point(car.position),3,Color("d6d6dc"))
    for rival in world.rivals:
        if rival.visible: draw_circle(_point(rival.position),3,Color("ff8268"))
    if world.police.visible: draw_circle(_point(world.police.position),4,Color("6688ff"))
    var focus: Vector3=world.car.position if world.in_car else world.player.position
    for place in world.landmarks:
        draw_circle(_point(place.position),4,Color("7cf7b0") if world.discovered.has(place.name) else Color("e5cb8f"))
    draw_circle(_point(focus),5,Color("69c9ff"))
func _point(pos: Vector3) -> Vector2:
    return Vector2(100+pos.x/160*90,100+pos.z/160*90)
