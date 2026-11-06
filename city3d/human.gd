extends Node3D
var animation: AnimationPlayer
var walk_name: StringName
var moving := false
var appearance := 0
var clothing: StandardMaterial3D
var long_hair: Node3D
func _ready():
    var model: Node3D=preload("res://assets/human/human.glb").instantiate()
    model.scale=Vector3.ONE*1.19
    add_child(model)
    var skeleton: Skeleton3D=model.find_child("Skeleton3D",true,false)
    clothing=StandardMaterial3D.new()
    clothing.roughness=0.92
    for mesh in model.find_children("*","MeshInstance3D",true,false):
        mesh.material_override=clothing
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
        long_hair=Node3D.new()
        long_hair.name="LongHair"
        pivot.add_child(long_hair)
        var hair_material:=StandardMaterial3D.new()
        hair_material.albedo_color=Color("25201f")
        hair_material.roughness=0.92
        var cap:=MeshInstance3D.new()
        var cap_mesh:=SphereMesh.new()
        cap_mesh.radius=0.125
        cap_mesh.height=0.09
        cap.mesh=cap_mesh
        cap.position=Vector3(0,0.22,-0.02)
        cap.material_override=hair_material
        long_hair.add_child(cap)
        var back:=MeshInstance3D.new()
        var back_mesh:=CapsuleMesh.new()
        back_mesh.radius=0.08
        back_mesh.height=0.28
        back.mesh=back_mesh
        back.position=Vector3(0,0.05,-0.12)
        back.material_override=hair_material
        long_hair.add_child(back)
    set_appearance(appearance)
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
func set_appearance(kind: int):
    appearance=clampi(kind,0,1)
    if clothing: clothing.albedo_color=[Color("364c63"),Color("79485a")][appearance]
    if is_instance_valid(long_hair): long_hair.visible=appearance==1
func set_motion(velocity: Vector3):
    moving=velocity.length()>0.1
    if not animation: return
    if moving:
        rotation.y=atan2(velocity.x,velocity.z)
        animation.speed_scale=clampf(velocity.length()/2.5,0.7,2.5)
        if not animation.is_playing(): animation.play(walk_name)
    else:
        animation.pause()
