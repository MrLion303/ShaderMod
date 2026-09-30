#version 120
uniform sampler2D DiffuseSampler;
varying vec2 texCoord;
uniform float Time;
uniform vec2 Frequency;
uniform vec2 WobbleAmount;
void main(){float t=Time*6.28318;vec2 o=vec2(sin(texCoord.y*Frequency.x+t)*WobbleAmount.x,cos(texCoord.x*Frequency.y+t)*WobbleAmount.y);vec4 c=texture2D(DiffuseSampler,texCoord+o);gl_FragColor=vec4(c.rgb,1.0);}