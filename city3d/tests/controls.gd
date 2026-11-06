extends SceneTree
class DrivingWorld extends Node3D:
    var in_car:=true
    var paused:=false
    var steering:=0.0
    var throttle_level:=1.0
    var brake_level:=1.0
    var pedal:=false
    var brake:=false
    var handbrake:=false
    var horn_down:=false
    var reverse:=false
    var speed:=0.0
    var dynamics=preload("res://driving_physics.gd").new()
func require(value: bool, message: String):
    if not value:push_error(message);quit(1)
func touch(id: int, pressed: bool, point: Vector2) -> InputEventScreenTouch:
    var event:=InputEventScreenTouch.new()
    event.index=id;event.pressed=pressed;event.position=point
    return event
func motion(id: int, point: Vector2) -> InputEventScreenDrag:
    var event:=InputEventScreenDrag.new()
    event.index=id;event.position=point
    return event
func _initialize():run.call_deferred()
func run():
    var world:=DrivingWorld.new()
    root.add_child(world)
    var dashboard=preload("res://driving_dashboard.gd").new()
    dashboard.world=world
    world.add_child(dashboard)
    require(dashboard.handle(touch(1,true,Vector2(1200,570))) and world.pedal,"Accelerator press missing")
    dashboard.handle(touch(10,true,Vector2(1200,570)))
    require(dashboard.handle(motion(10,Vector2(700,300))),"Second pedal touch escaped to camera")
    dashboard.handle(touch(10,false,Vector2(700,300)))
    require(world.pedal,"Secondary touch release cancelled the primary pedal")
    dashboard.handle(motion(1,Vector2(1200,620)))
    require(is_equal_approx(world.throttle_level,0.5),"Accelerator drag did not reduce demand")
    dashboard.handle(touch(2,true,Vector2(1090,555)))
    dashboard.handle(motion(2,Vector2(1090,630)))
    require(is_equal_approx(world.brake_level,0.25) and world.pedal and world.brake,"Independent analog brake failed")
    dashboard.handle(touch(3,true,Vector2(225,575)))
    require(world.steering==1 and world.pedal and world.brake,"Three-finger steering/pedals failed")
    dashboard.handle(touch(3,false,Vector2(225,575)))
    require(world.steering==0 and world.pedal and world.brake,"Wheel release cancelled a pedal")
    dashboard.handle(motion(1,Vector2(800,300)))
    require(not world.pedal and world.brake,"Leaving accelerator failed to release only accelerator")
    require(dashboard.handle(motion(1,Vector2(750,300))),"Cancelled pedal drag escaped to orbit camera")
    dashboard.handle(touch(1,false,Vector2(750,300)))
    dashboard.reset()
    require(not world.brake and not world.pedal and dashboard.contacts.is_empty(),"Pause reset left inputs held")
    var mouse:=InputEventMouseButton.new()
    mouse.button_index=MOUSE_BUTTON_LEFT;mouse.pressed=true;mouse.position=Vector2(1200,570)
    require(dashboard.handle(mouse) and world.pedal,"Mouse accelerator missing")
    mouse.pressed=false
    require(dashboard.handle(mouse) and not world.pedal,"Mouse release missing")
    Input.action_press("ui_up")
    dashboard._process(0.2)
    require(dashboard.accelerator_visual>0.9,"Keyboard accelerator did not depress pedal")
    Input.action_release("ui_up")
    dashboard._process(0.2)
    require(dashboard.accelerator_visual==0,"Keyboard release did not return pedal")
    world.paused=true
    require(not dashboard.handle(touch(9,true,Vector2(1090,555))) and not world.brake,"Paused dashboard accepted input")
    print("Analog pedal modulation, three-finger ownership, slide-out cancellation, mouse and pause reset passed")
    quit()
