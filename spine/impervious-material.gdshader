shader_type canvas_item;
render_mode unshaded;
varying vec4 material_flags;
uniform float strength = 0.0;
uniform float material_strength = 0.5;
uniform float warm_fill = 0.4;
uniform float shadow_depth = 0.55;
uniform vec2 shadow_range = vec2(0.22, 0.54);
uniform vec3 shadow_tint = vec3(0.48, 0.20, 0.07);
uniform float shadow_tint_strength = 0.9;
uniform vec3 gold_shadow = vec3(0.3675, 0.1725, 0.01925);
uniform vec3 gold_mid = vec3(1.0, 0.72625, 0.068125);
uniform vec3 gold_light = vec3(1.0, 0.9, 0.25);
void vertex() {
    material_flags = COLOR;
}
void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    vec3 original = tex.rgb * material_flags.g;
    int flags = int(round(material_flags.r * 7.0));
    vec3 category = vec3(float(flags & 1), float((flags >> 1) & 1), float((flags >> 2) & 1));
    float lum = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
    float value = clamp((lum - 0.075) / 0.71, 0.0, 1.0);
    vec3 gold = mix(gold_shadow, gold_mid, smoothstep(0.0, 0.64, value));
    gold = mix(gold, gold_light, smoothstep(0.56, 1.0, value));
    float shadow_mask = 1.0 - smoothstep(shadow_range.x, shadow_range.y, value);
    gold *= 1.0 - shadow_depth * shadow_mask;
    vec3 brown = shadow_tint * (dot(gold, vec3(0.299, 0.587, 0.114)) / max(dot(shadow_tint, vec3(0.299, 0.587, 0.114)), 0.001));
    gold = mix(gold, brown, shadow_mask * shadow_tint_strength);
    float red_accent = smoothstep(0.52, 0.68, (tex.r - tex.g) / max(tex.r, 0.01)) * category.b;
    gold = mix(gold, original, red_accent * 0.94);
    vec3 warm = original + vec3(0.35, 0.22, 0.015) * warm_fill * (0.35 + 0.65 * lum);
    warm = mix(warm, original, category.g);
    COLOR.rgb = mix(original, mix(warm, gold, category.r), strength * material_strength);
}
