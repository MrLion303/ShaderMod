#version 120
uniform sampler2D DiffuseSampler;
varying vec2 texCoord;
uniform vec2 InSize;
void main(){vec2 p=texCoord*2.0-1.0;float r2=dot(p,p);vec2 uv=texCoord+p*0.02*r2;vec4 c=texture2D(DiffuseSampler,uv);float scan=0.72+0.28*sin(uv.y*InSize.y*3.14159);c.rgb*=scan;gl_FragColor=vec4(c.rgb,1.0);}