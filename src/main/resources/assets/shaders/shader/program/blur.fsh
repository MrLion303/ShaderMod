#version 120
uniform sampler2D DiffuseSampler;
varying vec2 texCoord;
varying vec2 oneTexel;
uniform vec2 BlurDir;
uniform float Radius;
void main(){vec4 sum=vec4(0.0);float weightSum=0.0;for(float r=-8.0;r<=8.0;r+=1.0){float w=1.0-abs(r)/9.0;sum+=texture2D(DiffuseSampler,texCoord+oneTexel*r*BlurDir)*w;weightSum+=w;}gl_FragColor=sum/weightSum;}