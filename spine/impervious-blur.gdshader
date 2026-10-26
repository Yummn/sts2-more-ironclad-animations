shader_type canvas_item;
render_mode unshaded, blend_disabled;
uniform vec2 blur_step;
void fragment() {
    float a = texture(TEXTURE, UV).a * 0.227027;
    a += (texture(TEXTURE, UV + blur_step * 1.384615).a + texture(TEXTURE, UV - blur_step * 1.384615).a) * 0.316216;
    a += (texture(TEXTURE, UV + blur_step * 3.230769).a + texture(TEXTURE, UV - blur_step * 3.230769).a) * 0.070270;
    COLOR = vec4(a);
}
