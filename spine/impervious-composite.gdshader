shader_type canvas_item;
render_mode unshaded, blend_premul_alpha;
uniform sampler2D halo_texture : filter_linear;
uniform float strength = 0.0;
uniform float rim_width;
uniform float outline_width;
uniform float rim_strength = 0.68;
uniform float halo_opacity = 0.95;
uniform vec3 rim_color = vec3(1.0, 0.99, 0.95);
uniform vec3 halo_color = vec3(1.0, 0.68, 0.09);
void fragment() {
    vec4 body = texture(TEXTURE, UV);
    float inner = body.a;
    float outer = body.a;
    for (int i = 0; i < 12; i++) {
        float angle = float(i) * 0.523598776;
        vec2 direction = vec2(cos(angle), sin(angle)) * TEXTURE_PIXEL_SIZE;
        inner = min(inner, texture(TEXTURE, UV + direction * rim_width).a);
        outer = max(outer, texture(TEXTURE, UV + direction * outline_width).a);
    }
    float rim = (1.0 - inner) * body.a * strength * rim_strength;
    vec3 rgb = body.rgb + (vec3(body.a) - body.rgb) * rim_color * rim;
    float line = clamp((outer - body.a) * strength * 0.95, 0.0, 1.0);
    float halo = clamp(texture(halo_texture, UV).a * halo_opacity * strength, 0.0, 0.8);
    float behind = line + (1.0 - line) * halo;
    rgb += (rim_color * line + halo_color * halo * (1.0 - line)) * (1.0 - body.a);
    COLOR = vec4(rgb, body.a + behind * (1.0 - body.a));
}
