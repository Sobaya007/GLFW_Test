#version 400

in vec2 pos;
out vec2 uv;

void main()
{
	uv = pos;
    gl_Position = vec4(pos, 0, 1);
}
