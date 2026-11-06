shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, shadows_disabled;
void fragment() {
    vec2 point = (UV-vec2(0.5))*2.0;
    float distance_squared = dot(point,point);
    ALBEDO = vec3(0.015,0.018,0.02);
    ALPHA = (1.0-smoothstep(0.15,1.0,distance_squared))*0.36;
}
