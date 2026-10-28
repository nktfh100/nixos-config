#version 320 es
// @duration 0.75
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
float fbm(vec2 p) { return noise(p) * 0.57 + noise(p * 2.03 + 7.0) * 0.28 + noise(p * 4.11 + 17.0) * 0.15; }
vec4 over(vec4 base, vec3 color, float alpha) {
    alpha = clamp(alpha, 0.0, 1.0);
    return vec4(color * alpha, alpha) + base * (1.0 - alpha);
}
vec4 sourceAt(vec2 uv) {
    if (any(lessThan(uv, vec2(0))) || any(greaterThan(uv, vec2(1)))) return vec4(0);
    return texture(tex, window_rect.xy + uv * window_rect.zw);
}
float segment(vec2 p, vec2 a, vec2 b) {
    vec2 pa = p - a, ba = b - a;
    return length(pa - ba * clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0));
}
float wings(vec2 p, float unfold) {
    p.x = abs(p.x);
    p.x /= mix(0.18, 1.0, unfold);
    float shape = 0.0;
    for (int i = 0; i < 11; i++) {
        float f = float(i) / 10.0;
        vec2 a = vec2(0.04 + f * 0.49, 0.12 - sin(f * 2.5) * 0.25);
        vec2 b = a + vec2(0.10 + f * 0.16, 0.25 - f * 0.40);
        vec2 d = b - a, q = p - (a + b) * 0.5;
        vec2 local = vec2(dot(q, normalize(vec2(-d.y, d.x))), dot(q, normalize(d)));
        float feather = length(local / vec2(mix(0.033, 0.016, f), length(d) * 0.65));
        shape = max(shape, 1.0 - smoothstep(0.8, 1.06, feather));
    }
    return shape;
}
void main() {
    float t = clamp(progress, 0.0, 1.0);
    vec2 uv = (v_texcoord - window_rect.xy) / max(window_rect.zw, vec2(0.001));
    if (any(lessThan(textureSize(tex, 0), ivec2(2)))) {
        fragColor = vec4(0);
        return;
    }
    float aspect = window_rect.z * surface_size.x / max(window_rect.w * surface_size.y, 1.0);
    vec2 p = (uv - 0.5) * vec2(aspect, 1.0);
    vec4 original = texture(tex, v_texcoord);
    float envelope = smoothstep(0.0, 0.10, t) * (1.0 - smoothstep(0.65, 1.0, t));
    vec4 result = vec4(0);
    float front = mix(1.15, -0.18, smoothstep(0.0, 0.90, t));
    float turbulence = fbm(vec2(uv.x * 15.0, uv.y * 9.0 + t * 7.0) + seed * 8.0);
    float distanceToFlame = uv.y - front + (turbulence - 0.5) * 0.15;
    result = original * smoothstep(-0.025, 0.04, distanceToFlame);
    float flame = exp(-abs(distanceToFlame) * 45.0) * envelope;
    float plume = exp(-abs(distanceToFlame + 0.04) * 17.0) * turbulence * envelope;
    result = over(result, vec3(0.76, 0.035, 0.015), plume * 0.60);
    result = over(result, vec3(1.0, 0.30, 0.025), flame);
    result = over(result, vec3(1.0, 0.87, 0.48), pow(flame, 3.0));
    vec2 pixels = uv * surface_size;
    vec2 emberSpace = vec2(pixels.x, (uv.y - front) * surface_size.y + t * 100.0);
    vec2 spacing = vec2(32.0, 48.0);
    vec2 cell = floor(emberSpace / spacing);
    float sparks = 0.0;
    float glow = 0.0;
    for (int y = -1; y <= 1; y++) for (int x = -1; x <= 1; x++) {
        vec2 id = cell + vec2(x, y);
        float random = hash(id + seed * 19.0);
        vec2 center = (id + 0.2 + 0.6 * vec2(random, hash(id + 8.3))) * spacing;
        center.x += sin(t * 5.0 + random * 2.0 * PI) * 5.0;
        vec2 delta = (emberSpace - center) / vec2(1.0, 1.5);
        float radius = mix(1.0, 2.1, random);
        float brightness = smoothstep(0.45, 0.65, random);
        sparks += exp(-dot(delta, delta) / (radius * radius)) * brightness;
        glow += exp(-dot(delta, delta) / 28.0) * brightness;
    }
    float emberFade = (1.0 - smoothstep(-0.01, 0.03, distanceToFlame))
        * exp(-abs(distanceToFlame + 0.06) * 12.0) * envelope;
    result = over(result, vec3(1.0, 0.20, 0.015), glow * emberFade * 0.32);
    result = over(result, vec3(1.0, 0.72, 0.26), sparks * emberFade);
    fragColor = mix(result, original, smoothstep(0.90, 1.0, t));
}
