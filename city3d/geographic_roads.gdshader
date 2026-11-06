shader_type spatial;
render_mode cull_disabled;
uniform sampler2D asphalt : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D asphalt_normal : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D asphalt_roughness : repeat_enable, filter_linear_mipmap;
uniform bool all_asphalt = false;
void vertex() {
    TANGENT = vec3(1.0, 0.0, 0.0);
    BINORMAL = vec3(0.0, 0.0, 1.0);
}
void fragment() {
    vec3 tint = COLOR.rgb;
    bool road = all_asphalt || (COLOR.a > 0.9 && max(max(tint.r,tint.g),tint.b)-min(min(tint.r,tint.g),tint.b)<0.07 && tint.r<0.4);
    ALBEDO = tint;
    ROUGHNESS = 0.85;
    if (road) {
        vec2 tex_uv = UV * 0.25;
        ALBEDO = texture(asphalt,tex_uv).rgb;
        NORMAL_MAP = texture(asphalt_normal,tex_uv).rgb;
        NORMAL_MAP_DEPTH = 0.45;
        ROUGHNESS = clamp(texture(asphalt_roughness,tex_uv).r,0.65,1.0);
    }
}
