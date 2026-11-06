extends Control
var world: Node3D
const CENTER:=Vector2(155,575)
var touch_id := -1
var mouse_active := false
func _ready():
    mouse_filter=Control.MOUSE_FILTER_IGNORE
func _process(_delta):
    visible=world.in_car
    queue_redraw()
func reset():
    touch_id=-1
    mouse_active=false
func handle(event: InputEvent) -> bool:
    if not world.in_car or world.paused: return false
    if event is InputEventScreenTouch:
        if event.pressed and event.position.distance_to(CENTER)<94 and touch_id==-1:
            touch_id=event.index
            _steer(event.position)
            return true
        if not event.pressed and event.index==touch_id:
            reset()
            world.steering=0
            return true
    elif event is InputEventScreenDrag and event.index==touch_id:
        _steer(event.position)
        return true
    elif event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
        if event.pressed and event.position.distance_to(CENTER)<94:
            mouse_active=true
            _steer(event.position)
            return true
        elif not event.pressed and mouse_active:
            reset()
            world.steering=0
            return true
    elif event is InputEventMouseMotion and mouse_active:
        _steer(event.position)
        return true
    return false
func _steer(point: Vector2):
    world.steering=clampf((point.x-CENTER.x)/70,-1,1)
func _draw():
    if not is_instance_valid(world) or not world.in_car: return
    draw_circle(CENTER,94,Color("172027"))
    draw_arc(CENTER,80,0,TAU,64,Color("81939b"),6,true)
    draw_arc(CENTER,73,0,TAU,64,Color("242e35"),12,true)
    var angle: float=world.steering*1.1
    for i in range(3):
        var tip:=CENTER+Vector2.from_angle(angle+TAU*i/3-PI/2)*72
        draw_line(CENTER,tip,Color("627681"),12,true)
    draw_circle(CENTER,26,Color("384b56"))
    draw_arc(CENTER,22,0,TAU,32,Color("a8bdc5"),2,true)
    # Rubber ribs overlay each pedal while preserving the real input button.
    for pair in [[Vector2(1045,520),Vector2(100,130)],[Vector2(1160,495),Vector2(85,160)]]:
        var pos: Vector2=pair[0]
        var dimensions: Vector2=pair[1]
        for rib in range(4):
            var y: float=pos.y+12+rib*9
            draw_line(Vector2(pos.x+12,y),Vector2(pos.x+dimensions.x-12,y),Color("87979b"),4,true)
