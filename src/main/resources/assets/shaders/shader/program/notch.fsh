#version 120
uniform sampler2D DiffuseSampler;
varying vec2 texCoord;
void main(){vec4 c=texture2D(DiffuseSampler,texCoord);c.rgb=floor(c.rgb*vec3(8.0,8.0,4.0))/vec3(8.0,8.0,4.0);gl_FragColor=vec4(c.rgb,1.0);}