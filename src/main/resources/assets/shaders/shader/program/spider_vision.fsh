#version 120
uniform sampler2D DiffuseSampler;
varying vec2 texCoord;
void main(){vec2 p=texCoord-0.5;float r=length(p);float vignette=1.0-smoothstep(0.25,0.72,r);vec4 c=texture2D(DiffuseSampler,texCoord);vec3 tinted=c.rgb*vec3(1.15,0.78,0.78);gl_FragColor=vec4(tinted*vignette,1.0);}