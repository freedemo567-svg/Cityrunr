shader_type spatial;
render_mode cull_disabled;

// Opaque interior mapping avoids transparent pane sorting on the mobile
// compatibility renderer. The virtual room stays behind its physical frame.
void fragment() {
    vec3 view_tangent = vec3(dot(VIEW,TANGENT),dot(VIEW,BINORMAL),dot(VIEW,NORMAL));
    vec3 ray = vec3(vec2(-view_tangent.x,view_tangent.y)/max(abs(view_tangent.z),0.15),-1.0);
    vec3 start = vec3(UV.x*2.0-1.0,1.0-UV.y*2.0,1.0);
    vec3 inverse_ray = 1.0/(ray+vec3(0.0001));
    vec3 distances = abs(inverse_ray)-start*inverse_ray;
    float travel = min(min(distances.x,distances.y),distances.z);
    vec3 room = start+ray*travel;
    float seed = fract(sin(dot(UV2,vec2(12.9898,78.233)))*43758.5453);
    vec3 interior = vec3(0.24,0.21,0.16);
    if (abs(room.y)>0.995) {
        interior = room.y<0.0 ? vec3(0.085,0.065,0.04) : vec3(0.38,0.36,0.3);
    } else if (abs(room.x)>0.995) {
        interior *= 0.64;
    } else {
        float picture = step(abs(room.x-0.25),0.27)*step(abs(room.y-0.12),0.32);
        interior = mix(interior,vec3(0.055,0.07,0.055),picture);
        float cabinet = step(abs(room.x+0.3),0.4)*step(room.y,-0.35);
        interior = mix(interior,vec3(0.085,0.05,0.028),cabinet);
    }
    float curtain = (1.0-smoothstep(0.10,0.26,UV.x)) + smoothstep(0.74,0.90,UV.x);
    vec3 curtain_color = mix(vec3(0.29,0.27,0.22),vec3(0.45,0.39,0.29),seed);
    curtain_color *= 0.82+0.18*cos(UV.x*100.0);
    interior = mix(interior,curtain_color,curtain*0.8);
    // Glass has a subtle cool tint; room brightness varies across panes.
    ALBEDO = mix(interior*mix(0.24,0.62,seed),vec3(0.035,0.065,0.08),0.3);
    METALLIC = 0.28;
    ROUGHNESS = 0.17;
    SPECULAR = 0.8;
}
