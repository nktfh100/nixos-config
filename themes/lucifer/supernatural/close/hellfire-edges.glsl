#version 320 es
// @duration 0.95
precision highp float;
in vec2 v_texcoord;
out vec4 fragColor;
uniform sampler2D tex;
uniform float progress;
uniform float seed;
uniform vec4 window_rect;
uniform vec2 surface_size;
const float PI = 3.14159265359;
float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i), hash(i + vec2(1, 0)), f.x), mix(hash(i + vec2(0, 1)), hash(i + 1.0), f.x), f.y);
}
float fbm(vec2 p) {
    float n = 0.0, a = 0.5;
    for (int i = 0; i < 4; i++) { n += a * noise(p); p = mat2(1.6, 1.2, -1.2, 1.6) * p + 2.3; a *= 0.5; }
    return n;
}

vec4 over(vec4 base, vec3 color, float alpha) {
    alpha = clamp(alpha, 0.0, 1.0);
    return vec4(color * alpha, alpha) + base * (1.0 - alpha);
}

void main() {
    float t = clamp(progress, 0.0, 1.0);
    vec2 uv = (v_texcoord - window_rect.xy) / max(window_rect.zw, vec2(0.001));
    float aspect = window_rect.z * surface_size.x / max(window_rect.w * surface_size.y, 1.0);
    vec2 p = (uv - 0.5) * vec2(aspect, 1);
    float burn = mix(-0.14, 0.76, smoothstep(0.0, 0.87, t));
    float edge = min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y));
    float curl = fbm(p * 9.0 + vec2(seed * 40.0, t * 4.0));
    float turbulence = fbm(p * 19.0 + vec2(curl * 3.0, t * 8.0));
    float field = edge + (curl - 0.5) * 0.16 + (turbulence - 0.5) * 0.08 - burn;
    float remaining = smoothstep(0.0, 0.018, field);
    vec4 src = texture(tex, v_texcoord);
    float charred = 1.0 - smoothstep(0.0, 0.055, field);
    src.rgb *= mix(1.0, 0.15, charred);
    src *= remaining;
    float envelope = smoothstep(0.0, 0.07, t) * (1.0 - smoothstep(0.74, 0.98, t));
    float flame = exp(-abs(field + 0.026) * 22.0) * envelope;
    float hot = exp(-abs(field) * 120.0) * envelope;
    float tongues = flame * smoothstep(0.17, 0.68, turbulence);
    src = over(src, vec3(0.65, 0.025, 0.018), flame * 0.82);
    src = over(src, vec3(1.0, 0.25, 0.025), tongues * 0.92);
    src = over(src, vec3(1.0, 0.86, 0.40), hot * 0.97);
    for (int i = 0; i < 22; i++) {
        float id = float(i);
        float birth = hash(vec2(id, seed)) * 0.56;
        float life = (t - birth) / 0.36;
        vec2 origin = vec2(hash(vec2(id, 4.1)), hash(vec2(id, 9.2)));
        if (mod(id, 2.0) < 1.0) origin.x = step(0.5, origin.x); else origin.y = step(0.5, origin.y);
        origin = (origin - 0.5) * vec2(aspect, 1);
        vec2 at = origin + vec2(sin(id * 2.7) * 0.13 * life, -0.3 * life);
        float ember = exp(-length((p - at) * vec2(1, 0.6)) * 430.0);
        float alpha = smoothstep(0.0, 0.1, life) * (1.0 - smoothstep(0.3, 1.0, life));
        src = over(src, vec3(1.0, 0.49, 0.13), ember * alpha);
    }
    fragColor = src * (1.0 - step(0.9999, t));
}
