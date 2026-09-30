#version 120
uniform sampler2D DiffuseSampler;
varying vec2 texCoord;
void main(){vec4 c=texture2D(DiffuseSampler,texCoord);float lum=dot(c.rgb,vec3(0.2126,0.7152,0.0722));vec3 outc=vec3(lum*0.25,lum*1.15,lum*0.25);gl_FragColor=vec4(outc,1.0);}