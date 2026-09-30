#version 150
uniform sampler2D DiffuseSampler;
out vec4 fragColor;
uniform vec2 InSize;
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
        // Progress is linear so the visual animation keeps the same duration
        // as the Minecraft Absorción effect.
        float t = clamp(Progress, 0.0, 1.0);

        vec2 center = vec2(0.5);
        vec2 p = uv - center;

        float aspect = max(InSize.x / max(InSize.y, 1.0), 1.0);
        p.x *= aspect;

        float r = length(p);
        float edge = smoothstep(0.02, 0.95, r);

        // Whirlpool rotation increases continuously with the effect duration.
        float twist = t * 9.0 * (1.0 - smoothstep(0.03, 1.15, r));
        twist += t * 2.5 * smoothstep(0.30, 1.15, r);

        float cs = cos(twist);
        float sn = sin(twist);

        vec2 rotated = vec2(
            p.x * cs - p.y * sn,
            p.x * sn + p.y * cs
        );

        // Pull the image inward more strongly as the vortex develops.
        float pull = t * 0.48 * smoothstep(0.05, 1.0, r);
        float sourceRadius = r * (1.0 + pull);
        sourceRadius += t * 0.14 * sin(r * 14.0 - t * 12.0) * edge;

        vec2 source = rotated;
        float rotatedRadius = length(source);
        source *= sourceRadius / max(rotatedRadius, 0.0001);

        source.x /= aspect;

        vec2 sourceUv = center + source;
        vec3 color = sampleColor(sourceUv);

        // The black center starts at zero size and grows continuously.
        // This avoids the sudden large black circle from the previous version.
        float coreRadius = 0.32 * t;
        float coreSoftness = 0.045 + 0.025 * t;
        float coreMask = 1.0 - smoothstep(
            coreRadius,
            coreRadius + coreSoftness,
            r
        );
        float coreStrength = smoothstep(0.0, 0.18, t);
        color *= 1.0 - coreMask * coreStrength;

        // Progressive global darkening.
        float vignette = smoothstep(0.28, 1.05, r);
        float darkness = t * 0.78 * vignette;
        color *= 1.0 - darkness;

        // The last part of the effect completes the transition to pure black.
        float fade = smoothstep(0.82, 1.0, t);
        fade = fade * fade;
        color = mix(color, vec3(0.0), fade);

        fragColor = vec4(color, 1.0);
        return;
    }

    fragColor = vec4(original, 1.0);
}
