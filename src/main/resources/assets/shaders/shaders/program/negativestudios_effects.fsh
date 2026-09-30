#version 150
uniform sampler2D DiffuseSampler;
out vec4 fragColor;
uniform vec2 InSize;
uniform float Time;
uniform float Mode;
uniform float Progress;
in vec2 texCoord;
in vec2 oneTexel;

vec3 sampleColor(vec2 uv){
    return texture(DiffuseSampler, clamp(uv, 0.0, 1.0)).rgb;
}

void main(){
    vec2 uv = texCoord;
    vec3 original = sampleColor(uv);
    int m = int(Mode + 0.5);

    if(m == 10){
        float t = clamp(Progress, 0.0, 1.0);
        vec2 center = vec2(0.5);
        vec2 p = uv - center;

        float aspect = max(InSize.x / max(InSize.y, 1.0), 1.0);
        p.x *= aspect;

        float r = length(p);
        float edge = smoothstep(0.02, 0.95, r);
        float eased = t * t * (3.0 - 2.0 * t);

        float twist = eased * 7.5 * (1.0 - smoothstep(0.05, 1.15, r));
        twist += eased * 2.0 * smoothstep(0.35, 1.15, r);

        float cs = cos(twist);
        float sn = sin(twist);
        vec2 rotated = vec2(
            p.x * cs - p.y * sn,
            p.x * sn + p.y * cs
        );

        float pull = eased * 0.42 * smoothstep(0.08, 1.0, r);
        float sourceRadius = r * (1.0 + pull);
        sourceRadius += eased * 0.12 * sin(r * 13.0 - eased * 10.0) * edge;

        vec2 source = rotated;
        float rotatedRadius = length(source);
        source *= sourceRadius / max(rotatedRadius, 0.0001);

        source.x /= aspect;
        vec2 sourceUv = center + source;
        vec3 color = sampleColor(sourceUv);

        float coreRadius = mix(0.015, 0.30, eased);
        float core = smoothstep(coreRadius + 0.08, coreRadius, r);
        color *= 1.0 - core;

        float vignette = smoothstep(0.35, 1.05, r);
        float darkness = eased * 0.72 * vignette;

        float fade = smoothstep(0.68, 1.0, t);
        fade = fade * fade;

        color *= 1.0 - darkness;
        color = mix(color, vec3(0.0), fade);

        fragColor = vec4(color, 1.0);
        return;
    }

    fragColor = vec4(original, 1.0);
}
