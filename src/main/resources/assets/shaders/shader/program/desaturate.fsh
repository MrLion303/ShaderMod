#version 120
uniform sampler2D DiffuseSampler;
varying vec2 texCoord;
void main(){vec4 c=texture2D(DiffuseSampler,texCoord);float l=dot(c.rgb,vec3(0.2126,0.7152,0.0722));gl_FragColor=vec4(mix(vec3(l),c.rgb,0.2),c.a);}