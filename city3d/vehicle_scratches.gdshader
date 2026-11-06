shader_type spatial;
render_mode blend_mix, depth_draw_never;
uniform mat4 car_inverse;
uniform vec3 contacts[12];
uniform int hits = 0;
varying vec3 car_point;
void vertex(){car_point=((car_inverse*MODEL_MATRIX)*vec4(VERTEX,1.0)).xyz; VERTEX+=NORMAL*0.012;}
void fragment(){
    vec3 p=car_point;
    float mark=0.0;
    for(int i=0;i<12;i++){
        if(i>=hits)break;
        vec3 d=p-contacts[i];
        float patch=1.0-smoothstep(0.45,1.0,length(d/vec3(0.65,0.28,0.75)));
        float phase=(d.y+d.x*0.25)*12.0+float(i)*0.31;
        float line=abs(fract(phase)-0.5);
        float edge=clamp(fwidth(phase),0.004,0.04);
        float slash=1.0-smoothstep(0.018,0.018+edge,line);
        mark=max(mark,patch*slash);
    }
    if(mark<0.08)discard;
    ALBEDO=vec3(0.32,0.34,0.33); METALLIC=0.25; ROUGHNESS=0.85; ALPHA=mark*0.8;
}
