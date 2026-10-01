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

float luminance(vec3 c){
    return dot(c, vec3(0.2126, 0.7152, 0.0722));
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

        float twist = t * 9.0 * (1.0 - smoothstep(0.03, 1.15, r));
        twist += t * 2.5 * smoothstep(0.30, 1.15, r);

        float cs = cos(twist);
        float sn = sin(twist);
        vec2 rotated = vec2(
            p.x * cs - p.y * sn,
            p.x * sn + p.y * cs
        );

        float pull = t * 0.48 * smoothstep(0.05, 1.0, r);
        float sourceRadius = r * (1.0 + pull);
        sourceRadius += t * 0.14 * sin(r * 14.0 - t * 12.0) * edge;

        vec2 source = rotated;
        float rotatedRadius = length(source);
        source *= sourceRadius / max(rotatedRadius, 0.0001);

        source.x /= aspect;
        vec3 color = sampleColor(center + source);

        float coreRadius = 0.32 * t;
        float coreSoftness = 0.045 + 0.025 * t;
        float coreMask = 1.0 - smoothstep(coreRadius, coreRadius + coreSoftness, r);
        float coreStrength = smoothstep(0.0, 0.18, t);
        color *= 1.0 - coreMask * coreStrength;

        float vignette = smoothstep(0.28, 1.05, r);
        float darkness = t * 0.78 * vignette;
        color *= 1.0 - darkness;

        float fade = smoothstep(0.82, 1.0, t);
        fade = fade * fade;
        color = mix(color, vec3(0.0), fade);

        fragColor = vec4(color, 1.0);
        return;
    }

    if(m == 11 || m == 12){
        // Colored screen-edge glow.
        // The glow originates at the four borders of the screen and
        // softly fades toward the center. It does NOT detect object contours.
        float edgeDistance = min(
            min(uv.x, 1.0 - uv.x),
            min(uv.y, 1.0 - uv.y)
        );

        // Thickness of the colored atmosphere from the screen edge.
        float edgeWidth = 0.24;

        // Soft, diffuse falloff from the border toward the center.
        float edgeGlow = 1.0 - smoothstep(0.0, edgeWidth, edgeDistance);
        edgeGlow = pow(clamp(edgeGlow, 0.0, 1.0), 1.35);

        // Make the corners slightly stronger, like a real screen-edge vignette.
        float cornerX = abs(uv.x - 0.5) * 2.0;
        float cornerY = abs(uv.y - 0.5) * 2.0;
        float cornerBoost = mix(1.0, 1.18, pow(cornerX * cornerY, 1.5));
        edgeGlow *= cornerBoost;

        vec3 glowColor = (m == 11)
            ? vec3(0.03, 1.0, 0.08)
            : vec3(1.0, 0.025, 0.025);

        // Dense color right at the border, with a broad soft halo inward.
        float innerHalo = pow(edgeGlow, 1.8);
        vec3 color = original + glowColor * innerHalo * 0.82;

        // Slight additional bloom right against the screen boundary.
        float border = 1.0 - smoothstep(0.0, 0.055, edgeDistance);
        color += glowColor * border * 0.28;

        fragColor = vec4(clamp(color, 0.0, 1.0), 1.0);
        return;
    }

    fragColor = vec4(original, 1.0);
}
