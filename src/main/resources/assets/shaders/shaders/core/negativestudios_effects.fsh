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

    if(m==10){
        float t=clamp(Progress,0.0,1.0);
        vec2 center=vec2(0.5);
        vec2 p=uv-center;
        float r=length(p);

        float collapse=1.0/(1.0-0.86*t);
        float swirl=2.4*t*(1.0-smoothstep(0.0,0.9,r));
        float cs=cos(swirl);
        float sn=sin(swirl);
        vec2 q=vec2(p.x*cs-p.y*sn,p.x*sn+p.y*cs);
        vec2 sourceUv=center+q*collapse;

        float outside=step(1.0,abs(sourceUv.x)*2.0-0.0)+step(1.0,abs(sourceUv.y)*2.0-0.0);
        vec3 sucked=sample(sourceUv);

        float coreRadius=mix(0.015,0.42,t);
        float core=1.0-smoothstep(coreRadius,coreRadius+0.025,r);
        sucked*=1.0-core;

        float edge=1.0-smoothstep(0.45,0.92,r);
        float dark=smoothstep(0.58,0.92,t)*edge;
        sucked*=1.0-dark*0.75;

        float blackout=smoothstep(0.88,1.0,t);
        fragColor=vec4(mix(sucked,vec3(0.0),blackout),1.0);
        return;
    }

    fragColor=vec4(c,1.0);
}
