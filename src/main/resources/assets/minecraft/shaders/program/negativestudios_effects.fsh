#version 150
uniform sampler2D DiffuseSampler;
out vec4 fragColor;
uniform vec2 InSize;
uniform float Time;
uniform float Mode;
uniform float Progress;
in vec2 texCoord;
in vec2 oneTexel;

float luminance(vec3 c){return dot(c,vec3(0.299,0.587,0.114));}
vec3 sample(vec2 uv){return texture(DiffuseSampler,clamp(uv,0.0,1.0)).rgb;}

void main(){
    vec2 uv=texCoord;
    vec3 c=sample(uv);
    int m=int(Mode+0.5);

    if(m==0){ // Flip
        fragColor=vec4(sample(vec2(1.0-uv.x,uv.y)),1.0);
        return;
    }

    if(m==1){ // Pencil
        float gx=luminance(sample(uv+vec2(oneTexel.x,0.0)))-luminance(sample(uv-vec2(oneTexel.x,0.0)));
        float gy=luminance(sample(uv+vec2(0.0,oneTexel.y)))-luminance(sample(uv-vec2(0.0,oneTexel.y)));
        float edge=1.0-clamp(length(vec2(gx,gy))*4.0,0.0,1.0);
        float gray=luminance(c);
        fragColor=vec4(vec3(gray*0.85+edge*0.15),1.0);
        return;
    }

    if(m==2){ // Sobel
        float tl=luminance(sample(uv+oneTexel*vec2(-1,1)));
        float tc=luminance(sample(uv+oneTexel*vec2(0,1)));
        float tr=luminance(sample(uv+oneTexel*vec2(1,1)));
        float ml=luminance(sample(uv+oneTexel*vec2(-1,0)));
        float mr=luminance(sample(uv+oneTexel*vec2(1,0)));
        float bl=luminance(sample(uv+oneTexel*vec2(-1,-1)));
        float bc=luminance(sample(uv+oneTexel*vec2(0,-1)));
        float br=luminance(sample(uv+oneTexel*vec2(1,-1)));
        float gx=-tl-2.0*ml-bl+tr+2.0*mr+br;
        float gy=-tl-2.0*tc-tr+bl+2.0*bc+br;
        float e=clamp(length(vec2(gx,gy))*2.5,0.0,1.0);
        fragColor=vec4(vec3(e),1.0);
        return;
    }

    if(m==3){ // Desaturate
        float g=luminance(c);
        fragColor=vec4(vec3(g),1.0);
        return;
    }

    if(m==4){ // Wobble
        vec2 p=uv*vec2(40.0,30.0);
        vec2 w=vec2(sin(p.y+Time*6.2831),sin(p.x+Time*6.2831))*0.008;
        fragColor=vec4(sample(uv+w),1.0);
        return;
    }

    if(m==5){ // Scan pincushion
        vec2 p=uv-0.5;
        float r=dot(p,p);
        vec2 warped=0.5+p*(1.0+0.22*r);
        float scan=0.92+0.08*sin(uv.y*900.0);
        fragColor=vec4(sample(warped)*scan,1.0);
        return;
    }

    if(m==6){ // Notch
        float g=luminance(c);
        float bands=0.94+0.06*sin(uv.y*700.0);
        vec3 n=vec3(g*0.55+0.45*c.r,g*0.42+0.35*c.g,g*0.25+0.2*c.b);
        fragColor=vec4(n*bands,1.0);
        return;
    }

    if(m==7){ // Creeper vision
        float g=luminance(c);
        vec3 green=vec3(g*0.25,g*1.05,g*0.18);
        float edge=abs(luminance(sample(uv+oneTexel*vec2(1,0)))-luminance(sample(uv-oneTexel*vec2(1,0))));
        green+=vec3(edge*0.2,edge*0.45,edge*0.1);
        fragColor=vec4(clamp(green,0.0,1.0),1.0);
        return;
    }

    if(m==8){ // Spider vision
        float g=luminance(c);
        float red=1.0-g*0.35;
        vec3 spider=vec3(g*0.45+0.18,g*0.08,red*0.45+0.12);
        float pulse=0.96+0.04*sin(Time*6.2831);
        fragColor=vec4(clamp(spider*pulse,0.0,1.0),1.0);
        return;
    }

    if(m==10){ // Absorcion / Season X black hole
        // Progress is supplied by Java and runs once from 0 to 1.
        float t = clamp(Progress, 0.0, 1.0);
        vec2 center = vec2(0.5);
        vec2 p = uv - center;
        float r = length(p);

        // Strong radial collapse, with a progressively faster pull near the end.
        float pull = 1.0 + 0.85 * t + 4.5 * t * t + 3.0 * t * t * t;
        float angle = 1.35 * t * (1.0 - smoothstep(0.0, 0.95, r));
        float ca = cos(angle);
        float sa = sin(angle);
        vec2 rotated = vec2(p.x * ca - p.y * sa, p.x * sa + p.y * ca);
        vec2 sourceUv = center + rotated * pull;

        float inside = step(0.0, sourceUv.x) * step(sourceUv.x, 1.0)
                     * step(0.0, sourceUv.y) * step(sourceUv.y, 1.0);
        vec3 sucked = sample(sourceUv) * inside;

        // Dense dark core: the center disappears first into the singularity.
        float core = 1.0 - smoothstep(0.015, 0.24, r);
        float coreStrength = smoothstep(0.10, 0.58, t);
        sucked *= 1.0 - core * coreStrength * 0.92;

        // Last stage is a clean blackout.
        float blackout = smoothstep(0.72, 1.0, t);
        fragColor = vec4(mix(sucked, vec3(0.0), blackout), 1.0);
        return;
    }

    if(m==9){ // Enderman vision
        vec3 e=vec3(c.b*0.35,c.r*0.08,c.r*0.85+c.b*0.15);
        float glow=0.90+0.10*sin(Time*6.2831);
        fragColor=vec4(clamp(e*glow,0.0,1.0),1.0);
        return;
    }

    fragColor=vec4(c,1.0);
}