shader_type spatial;
render_mode cull_disabled;

uniform sampler2D plaster : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D plaster_normal : hint_normal, repeat_enable, filter_linear_mipmap_anisotropic;
uniform sampler2D roof : source_color, repeat_enable, filter_linear_mipmap_anisotropic;
varying float is_wall;
varying vec3 world_position;

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz;
    is_wall = 1.0 - abs(NORMAL.y);
    // UV.x follows each mapped edge, UV.y follows building height.
    TANGENT = vec3(-NORMAL.z,0.0,NORMAL.x);
    BINORMAL = vec3(0.0,1.0,0.0);
}

void fragment() {
    vec3 color = pow(COLOR.rgb,vec3(2.2));
    if (is_wall > 0.5) {
        vec2 cell = fract(UV / vec2(3.2, 3.0));
        float window = step(0.22, cell.x) * step(cell.x, 0.72) * step(0.30, cell.y) * step(cell.y, 0.78);
        window *= smoothstep(75.0,110.0,distance(world_position,CAMERA_POSITION_WORLD));
        float frame = step(0.25, cell.x) * step(cell.x, 0.69) * step(0.33, cell.y) * step(cell.y, 0.75);
        vec3 plaster_sample = texture(plaster, UV * 0.35).rgb;
        // Broad damp marks near the foundation and small vertical rain streaks.
        float streak = texture(plaster,vec2(UV.x*0.19,UV.y*0.035)).r;
        float damp = (1.0-smoothstep(0.0,1.0,world_position.y))*(0.12+0.3*streak);
        vec3 facade = color * mix(vec3(1.0),plaster_sample,0.55);
        facade *= 1.0-damp;
        color = mix(facade, vec3(0.38,0.36,0.3), window);
        color = mix(color,vec3(0.065,0.1,0.11),window*frame);
        NORMAL_MAP = texture(plaster_normal,UV*0.35).rgb;
        NORMAL_MAP_DEPTH = 0.35;
    } else {
        // Flat source roofs are concrete terraces; tile maps belong on the
        // actual sloping roof geometry, not on every horizontal footprint.
        color = mix(vec3(0.25,0.26,0.23),texture(plaster,UV*0.18).rgb,0.3);
    }
    ALBEDO = color;
    ROUGHNESS = 0.87;
    SPECULAR = 0.25;
}
