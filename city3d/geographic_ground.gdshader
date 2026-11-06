shader_type spatial;
render_mode cull_disabled;
uniform sampler2D grass : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D grass_normal : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
varying vec2 ground_position;
void vertex() {
    ground_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz;
    TANGENT = vec3(1.0, 0.0, 0.0);
    BINORMAL = vec3(0.0, 0.0, 1.0);
}
void fragment() {
    vec2 uv = ground_position * 0.22;
    vec3 near_color = texture(grass,uv).rgb;
    vec3 broad_color = texture(grass,uv * 0.073).rgb;
    ALBEDO = near_color * mix(vec3(0.85),broad_color + vec3(0.5),0.35) * vec3(0.55,0.75,0.45);
    NORMAL_MAP = texture(grass_normal,uv).rgb;
    NORMAL_MAP_DEPTH = 0.25;
    SPECULAR = 0.1;
    ROUGHNESS = 1.0;
}
