extends Node3D
var animation: AnimationPlayer
var walk_name: StringName
var moving := false
func _ready():
    var model: Node3D=preload("res://assets/human/human.glb").instantiate()
    model.scale=Vector3.ONE*1.19
    add_child(model)
    var skeleton: Skeleton3D=model.find_child("Skeleton3D",true,false)
    for mesh in model.find_children("*","MeshInstance3D",true,false):
        var cloth:=StandardMaterial3D.new()
        cloth.albedo_color=Color("364c63")
        cloth.roughness=0.92
        mesh.material_override=cloth
    if skeleton:
        var attachment:=BoneAttachment3D.new()
        attachment.bone_name="Skeleton_neck_joint_2"
        skeleton.add_child(attachment)
        var head: Node3D=preload("res://assets/human/head.glb").instantiate()
        var pivot:=Node3D.new()
        pivot.basis=Basis(Vector3(0,1,0),Vector3(1,0,0),Vector3(0,0,-1))
        head.name="ScannedHead"
        attachment.add_child(pivot)
        pivot.add_child(head)
        for mesh in head.find_children("*","MeshInstance3D",true,false):
            var bounds: AABB=mesh.get_aabb()
            var factor: float=0.34/bounds.size.y
            head.scale=Vector3.ONE*factor
            head.position=Vector3(0,0.10,0)-(bounds.position+bounds.size/2)*factor
            var skin:=StandardMaterial3D.new()
            skin.albedo_texture=preload("res://assets/human/head-color.jpg")
            skin.roughness=0.8
            mesh.material_override=skin
    animation=model.find_child("AnimationPlayer",true,false)
    if animation:
        for title in animation.get_animation_list():
            if title!="RESET":
                walk_name=title
                animation.get_animation(title).loop_mode=Animation.LOOP_LINEAR
                break
        animation.play(walk_name)
        animation.seek(0,true)
        animation.pause()
func set_motion(velocity: Vector3):
    moving=velocity.length()>0.1
    if not animation: return
    if moving:
        rotation.y=atan2(velocity.x,velocity.z)
        animation.speed_scale=clampf(velocity.length()/2.5,0.7,2.5)
        if not animation.is_playing(): animation.play(walk_name)
    else:
        animation.pause()
