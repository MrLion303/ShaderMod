#version 120
attribute vec4 Position;
uniform mat4 ProjMat;
uniform vec2 InSize;
uniform vec2 OutSize;
varying vec2 texCoord;
varying vec2 oneTexel;
void main(){gl_Position=ProjMat*vec4(Position.xy,0.0,1.0);oneTexel=1.0/InSize;texCoord=Position.xy/OutSize;texCoord.y=1.0-texCoord.y;}