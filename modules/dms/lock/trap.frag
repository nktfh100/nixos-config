#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float traced;
    float fracture;
    vec4 ink;
};
layout(binding = 1) uniform sampler2D source;
void main() {
    vec2 uv = qt_TexCoord0;
    vec2 p = uv - 0.5;
    float angle = mod(atan(p.y, p.x) + 7.8539816, 6.2831853);
    float sector = floor(angle / 1.2566371);
    float direction = sector * 1.2566371 - 0.9424778;
    vec2 offset = vec2(cos(direction), sin(direction)) * fracture * 0.24;
    vec2 sampleUv = uv - offset;
    float inside = step(0.0, sampleUv.x) * step(sampleUv.x, 1.0) * step(0.0, sampleUv.y) * step(sampleUv.y, 1.0);
    float line = 1.0 - texture(source, clamp(sampleUv, 0.0, 1.0)).r;
    float reveal = 1.0 - smoothstep(traced * 6.2831853, traced * 6.2831853 + 0.035, angle);
    float cracks = fracture < 0.001 ? 1.0 : smoothstep(0.018 * fracture, 0.024 * fracture + 0.001, min(mod(angle, 1.2566371), 1.2566371 - mod(angle, 1.2566371)));
    float alpha = line * reveal * inside * cracks * (1.0 - fracture) * ink.a * qt_Opacity;
    fragColor = vec4(ink.rgb * alpha, alpha);
}
