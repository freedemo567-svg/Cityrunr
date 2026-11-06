shader_type spatial;
render_mode cull_disabled;

varying vec2 ground_position;

float hash2(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise2(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash2(i), hash2(i + vec2(1.0, 0.0)), f.x),
               mix(hash2(i + vec2(0.0, 1.0)), hash2(i + vec2(1.0, 1.0)), f.x), f.y);
}

void vertex() {
    ground_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz;
}

void fragment() {
    float variation = noise2(ground_position * 0.04) * 0.65 + noise2(ground_position * 0.24) * 0.35;
    ALBEDO = mix(vec3(0.29, 0.38, 0.26), vec3(0.39, 0.46, 0.31), variation);
    ROUGHNESS = 1.0;
}
