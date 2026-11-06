shader_type spatial;
render_mode cull_disabled;

uniform sampler2D plaster : source_color, repeat_enable, filter_linear_mipmap;
varying float is_wall;

void vertex() {
    is_wall = 1.0 - abs(NORMAL.y);
}

void fragment() {
    vec3 color = COLOR.rgb;
    if (is_wall > 0.5) {
        vec2 cell = fract(UV / vec2(3.2, 3.0));
        float window = step(0.22, cell.x) * step(cell.x, 0.72) * step(0.30, cell.y) * step(cell.y, 0.78);
        float frame = step(0.25, cell.x) * step(cell.x, 0.69) * step(0.33, cell.y) * step(cell.y, 0.75);
        vec3 facade = color * texture(plaster, UV * 0.18).rgb;
        color = mix(facade, vec3(0.62, 0.60, 0.54), window);
        color = mix(color, vec3(0.18, 0.25, 0.27), window * frame);
    }
    ALBEDO = color;
    ROUGHNESS = 0.9;
}
