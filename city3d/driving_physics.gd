extends RefCounted
# Metres/second, radians and seconds. A simplified bicycle model, not a tyre simulator.
var pressure:=0.0
var wheel:=0.0
var pitch:=0.0
func reset():
    pressure=0.0
    wheel=0.0
    pitch=0.0
func step(speed: float, throttle: bool, brake: bool, parking: bool, reverse: bool, maximum: float, delta: float, throttle_amount: float=1.0, brake_amount: float=1.0) -> float:
    var dt:=clampf(delta,0,0.1)
    pressure=move_toward(pressure,clampf(brake_amount,0,1) if brake else 0.0,dt*(5.0 if brake else 8.0))
    var result:=speed
    if brake or parking or pressure>0:
        result=move_toward(speed,0,((7.8*pressure)+(3.2 if parking else 0.0))*dt)
    elif reverse and throttle and throttle_amount>0:
        # Selecting reverse while travelling forward applies braking first.
        result=move_toward(speed,0 if speed>0 else -5.0,(5.0 if speed>0 else 2.0)*dt*clampf(throttle_amount,0,1))
    elif throttle and throttle_amount>0:
        result=move_toward(speed,maximum,maxf(0.8,4.2*(1-absf(speed)/maxf(maximum,1)))*dt*clampf(throttle_amount,0,1))
    else:
        result=move_toward(speed,0,(0.18+0.0009*speed*speed)*dt)
    pitch=clampf((speed-result)/maxf(dt,0.001)*0.008,-0.035,0.065)
    return result
func steer(input: float, speed: float, delta: float) -> float:
    var limit:=deg_to_rad(32.0)/(1+absf(speed)*0.09)
    wheel=move_toward(wheel,clampf(input,-1,1)*limit,delta*1.8)
    return wheel
