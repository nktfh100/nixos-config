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
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}
float noise(vec2 p) {
    vec2 i = floor(p), f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i), hash(i + vec2(1, 0)), f.x), mix(hash(i + vec2(0, 1)), hash(i + 1.0), f.x), f.y);
}
float fbm(vec2 p) {
    float value = 0.0, amplitude = 0.5;
    for (int i = 0; i < 5; i++) {
        value += noise(p) * amplitude;
        p = mat2(1.6, 1.2, -1.2, 1.6) * p + 3.7;
        amplitude *= 0.5;
    }
    return value;
}
void main() {
    float t = clamp(progress, 0.0, 1.0);
    vec2 uv = (v_texcoord - window_rect.xy) / max(window_rect.zw, vec2(0.001));
    float aspect = (window_rect.z * surface_size.x) / max(window_rect.w * surface_size.y, 1.0);
    vec2 p = (uv - 0.5) * vec2(aspect, 1.0);
    vec2 wind = vec2(sin(t * 6.0 + seed * 9.0) * 0.15, t * 1.5);
    vec2 curl = vec2(fbm(p * 3.0 + wind), fbm(p * 3.0 + wind + 7.3));
    float billow = fbm(p * 6.0 + curl * 3.0 + wind * 2.0 + seed * 15.0);
    vec2 displaced = v_texcoord + vec2((curl.x - 0.5) * 0.055 * t, t * 0.08) * window_rect.zw;
    vec4 original = texture(tex, clamp(displaced, 0.0, 1.0));
    float surviving = smoothstep(t - 0.12, t + 0.14, billow);
    surviving = mix(1.0, surviving, smoothstep(0.0, 0.12, t));
    vec4 remnant = original * surviving * (1.0 - smoothstep(0.6, 1.0, t));
    vec2 cloud = abs(uv - vec2(0.5 + sin(t * 5.0) * 0.07, 0.5 - t * 0.32)) - vec2(0.5 - t * 0.17, 0.49 - t * 0.08);
    float edge = max(cloud.x, cloud.y) + (billow - 0.5) * 0.34;
    float density = (1.0 - smoothstep(-0.11, 0.1, edge)) * smoothstep(0.22, 0.68, billow);
    float envelope = smoothstep(0.0, 0.18, t) * (1.0 - smoothstep(0.58, 1.0, t));
    float alpha = density * envelope * 0.94;
    vec3 charcoal = mix(vec3(0.012, 0.009, 0.018), vec3(0.16, 0.13, 0.18), pow(billow, 3.0));
    fragColor = vec4(charcoal * alpha, alpha) + remnant * (1.0 - alpha);
    fragColor *= 1.0 - step(0.9999, t);
}
