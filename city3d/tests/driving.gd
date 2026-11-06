extends SceneTree
func require(value: bool, message: String):
    if not value:push_error(message);quit(1)
func _initialize():
    var physics=preload("res://driving_physics.gd").new()
    var distances: Array=[]
    for dt in [1.0/30,1.0/60,1.0/120]:
        physics.reset()
        var speed:=20.0
        var distance:=0.0
        for i in range(1200):
            var previous:=speed
            speed=physics.step(speed,false,true,false,false,40,dt)
            require(speed>=0 and speed<=previous,"Brake reversed or accelerated vehicle")
            distance+=(previous+speed)*0.5*dt
            if speed==0:break
        require(speed==0 and distance>25 and distance<35,"Stopping distance must be progressive, about 29m from 72km/h")
        distances.append(distance)
    require(absf(distances[0]-distances[2])<1,"Brake response depends too strongly on frame rate")
    physics.reset()
    var coast: float=physics.step(20,false,false,false,false,40,0.1)
    physics.reset()
    var stop: float=physics.step(20,false,true,false,false,40,0.1)
    require(stop<coast and stop>19,"Pedal must build pressure without instantaneous stopping")
    physics.reset()
    require(physics.step(10,true,false,false,true,40,0.1)>0,"Reverse selection must brake before reversing")
    require(physics.step(0,false,false,false,true,40,0.1)==0,"Selecting reverse alone must not accelerate")
    physics.reset()
    var low: float=physics.steer(1,2,1)
    physics.reset()
    var high: float=physics.steer(1,30,1)
    require(high>0 and high<low,"High-speed steering must reduce lock")
    physics.reset()
    var light_accel: float=physics.step(0,true,false,false,false,40,0.1,0.25,1)
    physics.reset()
    var full_accel: float=physics.step(0,true,false,false,false,40,0.1,1,1)
    require(light_accel>0 and light_accel<full_accel,"Analog accelerator does not affect acceleration")
    physics.reset()
    physics.step(20,false,true,false,false,40,0.1,1,0.25)
    var light_brake: float=physics.step(20,false,true,false,false,40,0.1,1,0.25)
    physics.reset()
    physics.step(20,false,true,false,false,40,0.1,1,1)
    var full_brake: float=physics.step(20,false,true,false,false,40,0.1,1,1)
    require(full_brake<light_brake,"Analog brake pressure does not affect deceleration")
    print("Progressive braking, stopping distance, frame-rate consistency, reverse and steering passed")
    quit()
