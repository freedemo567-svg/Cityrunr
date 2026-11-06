extends RefCounted
var records: Dictionary={}
var cooldown:=0.0
var material: ShaderMaterial
func attach(car: Node3D, kind: int):
    material=ShaderMaterial.new();material.shader=preload("res://vehicle_scratches.gdshader")
    for paint in car.get_meta("paints",[]):paint.next_pass=material
    update(car,kind,0)
func update(car: Node3D, kind: int, delta: float):
    cooldown=maxf(0,cooldown-delta)
    if material==null:return
    material.set_shader_parameter("car_inverse",car.global_transform.affine_inverse())
    var points:=PackedVector3Array()
    for item in records.get(str(kind),[]):points.append(Vector3(item[0],item[1],item[2]))
    var count:=points.size()
    while points.size()<12:points.append(Vector3.ZERO)
    material.set_shader_parameter("contacts",points)
    material.set_shader_parameter("hits",count)
func impact(car: Node3D, kind: int, speed: float, length: float) -> bool:
    if absf(speed)<2 or cooldown>0:return false
    cooldown=0.8
    var key:=str(kind)
    if not records.has(key):records[key]=[]
    if records[key].size()<12:
        records[key].append([sin(records[key].size()*2.4)*0.5,0.65,length*0.43*signf(speed)])
    update(car,kind,0)
    return true
func restore(value):
    records.clear()
    if not value is Dictionary:return
    for kind in range(6):
        var key:=str(kind)
        if not value.get(key) is Array:continue
        records[key]=[]
        for p in value[key]:
            if records[key].size()>=12:break
            if not p is Array or p.size()!=3:continue
            if not (p[0] is float or p[0] is int) or not (p[1] is float or p[1] is int) or not (p[2] is float or p[2] is int):continue
            if Vector3(p[0],p[1],p[2]).is_finite() and Vector3(p[0],p[1],p[2]).length()<10:records[key].append(p)
