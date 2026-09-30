#version 120
uniform sampler2D DiffuseSampler;
varying vec2 texCoord;
void main(){vec4 c=texture2D(DiffuseSampler,texCoord);vec3 outc=vec3(c.r*0.7+c.b*0.25,c.g*0.25+c.b*0.65,c.b*1.15);gl_FragColor=vec4(outc,1.0);}