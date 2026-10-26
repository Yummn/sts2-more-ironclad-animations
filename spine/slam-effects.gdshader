shader_type canvas_item;
render_mode unshaded, blend_premul_alpha;
uniform float blur_uv=0.0;
uniform float trail_strength=0.0;
uniform float phase=0.0;
uniform vec4 body_box;
varying vec4 tint;
void vertex(){tint=COLOR;}
vec4 sample_body(sampler2D source,vec2 uv){if(uv.x<0.0||uv.x>1.0||uv.y<0.0||uv.y>1.0)return vec4(0.0);return texture(source,uv);}
void fragment(){
    vec4 body=sample_body(TEXTURE,UV);
    if(blur_uv>0.0001){vec4 sum=body*.12;for(int i=0;i<24;i++)sum+=sample_body(TEXTURE,UV+vec2(blur_uv*(float(i)+.5)/24.0,0.0))*(.88/24.0);body=sum;}
    vec4 trail=vec4(0.0);
    if(trail_strength>0.001&&UV.y>body_box.y&&UV.y<body_box.w){
        float band=(UV.y-body_box.y)/max(.001,body_box.w-body_box.y)*14.0;
        float row=floor(band),seed=fract(row*.722772+0.17),width=.16+seed*.11;
        float line=exp(-pow((fract(band)-.5)/width,2.0)*2.2);
        float y=mix(body_box.y,body_box.w,(row+.5)/14.0),edge=-1.0;
        for(int i=0;i<48;i++){float x=mix(body_box.x,body_box.z,float(i)/47.0);if(edge<0.0&&sample_body(TEXTURE,vec2(x,y)).a>.12)edge=x;}
        if(edge>=0.0){float end=edge+.014,start=end-(.12+seed*.22),u=(UV.x-start)/max(.001,end-start);
            float alpha=line*smoothstep(0.0,.65,u)*(1.0-smoothstep(.97,1.06,u))*.42*trail_strength*(.72+.28*sin(phase*23.0+row*3.0));
            vec3 color=mix(vec3(.83,.89,.94),vec3(.96,.78,.46),step(.7,seed));trail=vec4(color*alpha,alpha);}
    }
    vec4 combined=body+trail*(1.0-body.a);COLOR=vec4(combined.rgb*tint.rgb*tint.a,combined.a*tint.a);
}
