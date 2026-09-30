#version 120
uniform sampler2D DiffuseSampler;
varying vec2 texCoord;
varying vec2 oneTexel;
void main(){vec3 c=texture2D(DiffuseSampler,texCoord).rgb;vec3 l=texture2D(DiffuseSampler,texCoord-vec2(oneTexel.x,0)).rgb;vec3 r=texture2D(DiffuseSampler,texCoord+vec2(oneTexel.x,0)).rgb;vec3 u=texture2D(DiffuseSampler,texCoord-vec2(0,oneTexel.y)).rgb;vec3 d=texture2D(DiffuseSampler,texCoord+vec2(0,oneTexel.y)).rgb;float edge=length(c-l)+length(c-r)+length(c-u)+length(c-d);float v=clamp(1.0-edge*2.0,0.0,1.0);gl_FragColor=vec4(vec3(v),1.0);}