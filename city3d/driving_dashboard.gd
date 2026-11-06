extends Control
# Drawn in the same 1280 x 720 canvas as the input hit areas.
var world: Node3D
const CENTER:=Vector2(155,575)
const BRAKE:=Rect2(1045,520,100,130)
const ACCEL:=Rect2(1160,495,85,160)
var contacts: Dictionary={}
var wheel_visual:=0.0
var accelerator_visual:=0.0
var brake_visual:=0.0
func _ready():
    mouse_filter=Control.MOUSE_FILTER_IGNORE
func _process(delta):
    visible=world.in_car
    if not visible and not contacts.is_empty():reset()
    var target: float=world.steering
    if target==0:target=Input.get_axis("ui_left","ui_right") if not world.paused else 0.0
    wheel_visual=lerpf(wheel_visual,target,1-exp(-10*delta))
    var throttle_demand: float=1.0 if Input.is_action_pressed("ui_up") else (world.throttle_level if world.pedal else 0.0)
    accelerator_visual=move_toward(accelerator_visual,0.0 if world.paused else throttle_demand,delta*6)
    brake_visual=move_toward(brake_visual,world.dynamics.pressure,delta*6)
    queue_redraw()
func reset():
    contacts.clear()
    world.steering=0
    world.pedal=false
    world.brake=false
    world.throttle_level=1.0
    world.brake_level=1.0
func handle(event: InputEvent) -> bool:
    if not world.in_car or world.paused:return false
    if event is InputEventScreenTouch:
        return press(event.index,event.position) if event.pressed else release(event.index)
    if event is InputEventScreenDrag:return drag(event.index,event.position)
    if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
        return press(-20,event.position) if event.pressed else release(-20)
    if event is InputEventMouseMotion and contacts.has(-20):return drag(-20,event.position)
    return false
func press(id: int, point: Vector2) -> bool:
    var channel:=""
    if point.distance_to(CENTER)<94:channel="wheel"
    elif BRAKE.has_point(point):channel="brake"
    elif ACCEL.has_point(point):channel="accelerator"
    if channel.is_empty():return false
    for contact in contacts.values():
        if contact.channel==channel:
            contacts[id]={"channel":"cancelled","origin":point}
            return true
    contacts[id]={"channel":channel,"origin":point}
    if channel=="wheel":world.steering=clampf((point.x-CENTER.x)/70,-1,1)
    elif channel=="brake":world.brake=true;world.brake_level=1.0
    else:world.pedal=true;world.throttle_level=1.0
    return true
func drag(id: int, point: Vector2) -> bool:
    if not contacts.has(id):return false
    var contact: Dictionary=contacts[id]
    if contact.channel=="cancelled":return true
    if contact.channel=="wheel":world.steering=clampf((point.x-CENTER.x)/70,-1,1)
    else:
        var bounds: Rect2=BRAKE if contact.channel=="brake" else ACCEL
        # A pointer which leaves the pedal area releases it; it cannot stick on.
        if not bounds.grow(70).has_point(point):
            if contact.channel=="brake":world.brake=false;world.brake_level=1.0
            else:world.pedal=false;world.throttle_level=1.0
            contacts[id].channel="cancelled"
            return true
        var amount:=clampf(1-(point.y-contact.origin.y)/100,0,1)
        if contact.channel=="brake":world.brake_level=amount;world.brake=amount>0
        else:world.throttle_level=amount;world.pedal=amount>0
    return true
func release(id: int) -> bool:
    if not contacts.has(id):return false
    var channel: String=contacts[id].channel
    contacts.erase(id)
    if channel=="wheel":world.steering=0
    elif channel=="brake":world.brake=false;world.brake_level=1.0
    elif channel=="accelerator":world.pedal=false;world.throttle_level=1.0
    return true
func panel(rect: Rect2, color: Color, radius: int=10, border: Color=Color("38454b")):
    var style:=StyleBoxFlat.new()
    style.bg_color=color
    style.set_corner_radius_all(radius)
    style.border_color=border
    style.set_border_width_all(1)
    draw_style_box(style,rect)
func label(at: Vector2, value: String, size: int=16, color: Color=Color("bbc6c9")):
    draw_string(ThemeDB.fallback_font,at,value,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)
func bolt(point: Vector2):
    draw_circle(point,3.2,Color("101619"))
    draw_circle(point-Vector2(0,0.7),2,Color("8b989c"))
    draw_line(point-Vector2(1,0),point+Vector2(1,0),Color("263238"),1,true)
func pedal_plate(bounds: Rect2, amount: float, is_brake: bool):
    var inset:=Vector2(9,8)
    var pos:=bounds.position+inset+Vector2(0,amount*10)
    var size:=bounds.size-inset*2-Vector2(0,amount*8)
    # Recess, hinge, cast metal edge and inset rubber tread.
    panel(bounds.grow(5),Color("080d10"),12)
    panel(Rect2(bounds.position+Vector2(bounds.size.x/2-8,-18),Vector2(16,35)),Color("556167"),3)
    var outline:=PackedVector2Array([pos+Vector2(5,0),pos+Vector2(size.x-5,0),pos+size,pos+Vector2(0,size.y)])
    draw_colored_polygon(outline,Color("10181c"))
    for i in range(5):
        var shade:=Color("79868b").lerp(Color("344047"),float(i)/5)
        panel(Rect2(pos+Vector2(i,i),size-Vector2(i*2,i*2)),shade,6)
    panel(Rect2(pos+Vector2(7,7),size-Vector2(14,14)),Color("1b2428"),4)
    var rows:=5 if is_brake else 7
    for row in range(rows):
        var y:=pos.y+17+row*(size.y-38)/maxi(1,rows-1)
        draw_line(Vector2(pos.x+12,y+2),Vector2(pos.x+size.x-12,y+2),Color("0a1012"),5,true)
        draw_line(Vector2(pos.x+12,y),Vector2(pos.x+size.x-12,y),Color("455158"),3,true)
    bolt(pos+Vector2(6,6));bolt(pos+size-Vector2(6,6))
    label(Vector2(bounds.position.x+5,688),"BRAKE" if is_brake else "ACCEL",15)
    draw_rect(Rect2(bounds.position.x,701,bounds.size.x,3),Color("253239"))
    draw_rect(Rect2(bounds.position.x,701,bounds.size.x*amount,3),Color("d98c6b") if is_brake else Color("8cd6b1"))
func wheel():
    draw_circle(CENTER+Vector2(0,6),99,Color(0.01,0.02,0.025,0.65))
    draw_circle(CENTER,97,Color("090e12"))
    draw_arc(CENTER,91,0,TAU,100,Color("596268"),3,true)
    draw_arc(CENTER,84,0,TAU,100,Color("182126"),15,true)
    draw_arc(CENTER-Vector2(0,2),85,PI,TAU,60,Color("3d484e"),4,true)
    var angle:=wheel_visual*2.2
    for i in range(48):
        var theta:=TAU*i/48+angle
        draw_line(CENTER+Vector2.from_angle(theta)*78,CENTER+Vector2.from_angle(theta+0.018)*81,Color("768080"),1,true)
    for theta in [0.0,PI,PI/2]:
        var direction:=Vector2.from_angle(theta+angle)
        var normal:=Vector2(-direction.y,direction.x)
        var metal:=PackedVector2Array([CENTER+direction*23+normal*12,CENTER+direction*76+normal*7,CENTER+direction*76-normal*7,CENTER+direction*23-normal*12])
        draw_colored_polygon(metal,Color("67747b"))
        draw_line(CENTER+direction*33,CENTER+direction*70,Color("b0b9ba"),2,true)
    draw_circle(CENTER+Vector2(0,3),32,Color("070d10"))
    draw_circle(CENTER,31,Color("3d494f"))
    draw_arc(CENTER,29,PI,TAU,30,Color("7a888d"),1,true)
    label(CENTER+Vector2(-16,5),"CR",16,Color("d6dedd"))
    var marker:=CENTER+Vector2.from_angle(-PI/2+angle)*84
    draw_line(marker-Vector2.from_angle(angle)*5,marker+Vector2.from_angle(angle)*5,Color("d1b484"),5,true)
    label(Vector2(68,704),"DRAG TO STEER",13,Color("899ba2"))
func shifter():
    panel(Rect2(915,582,110,88),Color("0a1115"),12)
    panel(Rect2(944,592,31,64),Color("303c42"),13)
    panel(Rect2(955,600,9,49),Color("070c0e"),4)
    label(Vector2(995,607),"D",15,Color("8be1b2") if not world.reverse else Color("67777e"))
    label(Vector2(995,651),"R",15,Color("edb187") if world.reverse else Color("67777e"))
    var knob:=Vector2(960,638 if world.reverse else 606)
    draw_circle(knob+Vector2(0,5),18,Color("04090b"))
    draw_circle(knob,17,Color("526169"))
    draw_arc(knob,15,PI,TAU,25,Color("adb8ba"),2,true)
    label(knob+Vector2(-5,5),"R" if world.reverse else "D",14,Color.WHITE)
    label(Vector2(925,687),"GEAR · R",12)
func parking_lever():
    panel(Rect2(896,501,138,73),Color("0b1216"),9)
    var pivot:=Vector2(1012,559)
    var end:=Vector2(925,521 if world.handbrake else 541)
    draw_line(pivot+Vector2(0,4),end+Vector2(0,4),Color("020608"),14,true)
    draw_line(pivot,end,Color("718088"),9,true)
    draw_line(end.lerp(pivot,0.38),end,Color("25343b"),16,true)
    draw_circle(end,7,Color("59666c"))
    label(Vector2(902,489),"HANDBRAKE",13,Color("eeaa7e") if world.handbrake else Color("a7b5ba"))
func horn_button():
    panel(Rect2(20,420,130,60),Color("18242b"),20)
    var col:=Color("e9bd7b") if world.horn_down else Color("a6b6bc")
    draw_polyline(PackedVector2Array([Vector2(49,444),Vector2(62,444),Vector2(77,435),Vector2(77,463),Vector2(62,454),Vector2(49,454),Vector2(49,444)]),col,2,true)
    draw_arc(Vector2(76,449),13,-0.7,0.7,12,col,2,true)
    draw_arc(Vector2(76,449),20,-0.7,0.7,12,col,2,true)
    label(Vector2(102,455),"H",16,col)
func instruments():
    panel(Rect2(330,537,460,132),Color(0.035,0.06,0.075,0.94),18)
    var dial:=Vector2(400,603)
    draw_arc(dial,46,deg_to_rad(140),deg_to_rad(400),70,Color("42545e"),5,true)
    for i in range(9):
        var theta:=deg_to_rad(140+i*32.5)
        draw_line(dial+Vector2.from_angle(theta)*38,dial+Vector2.from_angle(theta)*46,Color("b3c5c9"),2,true)
    var needle:=deg_to_rad(140+260*clampf(absf(world.speed)*3.6/160,0,1))
    draw_line(dial,dial+Vector2.from_angle(needle)*34,Color("dc8e6b"),3,true)
    draw_circle(dial,5,Color("a9babd"))
    label(Vector2(473,598),"%03d"%int(absf(world.speed)*3.6),42,Color("edf5f3"))
    label(Vector2(562,597),"km/h",15)
    label(Vector2(475,628),"R" if world.reverse else "D",22,Color("9cd8bb"))
    label(Vector2(520,626),"BRAKE",12)
    draw_rect(Rect2(570,617,115,6),Color("29383f"))
    draw_rect(Rect2(570,617,115*world.dynamics.pressure,6),Color("d98c6b"))
    label(Vector2(710,588),"(!)" if world.handbrake else "READY",15,Color("ec9b77") if world.handbrake else Color("91a9af"))
    label(Vector2(467,655),"SLIDE PEDALS TO MODULATE",11,Color("7e959d"))
func _draw():
    if not is_instance_valid(world) or not world.in_car:return
    # Dark footwell backs physical pedal faces without obscuring the road centre.
    panel(Rect2(1034,480,222,233),Color(0.035,0.05,0.06,0.88),18)
    for i in range(8):
        draw_line(Vector2(1044+i*29,487),Vector2(1039+i*29,707),Color("19262c"),2,true)
    pedal_plate(BRAKE,brake_visual,true)
    pedal_plate(ACCEL,accelerator_visual,false)
    wheel()
    shifter()
    parking_lever()
    horn_button()
    instruments()
