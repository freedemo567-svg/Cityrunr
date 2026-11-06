extends RefCounted

static func road(all_asphalt := false) -> ShaderMaterial:
    var material:=ShaderMaterial.new()
    material.shader=preload("res://geographic_roads.gdshader")
    material.set_shader_parameter("asphalt",preload("res://assets/surfaces/asphalt_02_color.jpg"))
    material.set_shader_parameter("asphalt_normal",preload("res://assets/surfaces/asphalt_02_normal.jpg"))
    material.set_shader_parameter("asphalt_roughness",preload("res://assets/surfaces/asphalt_02_roughness.jpg"))
    material.set_shader_parameter("all_asphalt",all_asphalt)
    return material

static func ground() -> ShaderMaterial:
    var material:=ShaderMaterial.new()
    material.shader=preload("res://geographic_ground.gdshader")
    material.set_shader_parameter("grass",preload("res://assets/surfaces/leafy_grass_color.jpg"))
    material.set_shader_parameter("grass_normal",preload("res://assets/surfaces/leafy_grass_normal.jpg"))
    return material

static func roof() -> StandardMaterial3D:
    var material:=StandardMaterial3D.new()
    material.albedo_texture=preload("res://assets/surfaces/clay_roof_tiles_color.jpg")
    material.normal_enabled=true
    material.normal_texture=preload("res://assets/surfaces/clay_roof_tiles_normal.jpg")
    material.roughness_texture=preload("res://assets/surfaces/clay_roof_tiles_roughness.jpg")
    material.uv1_triplanar=true
    material.uv1_scale=Vector3.ONE*0.3
    return material
