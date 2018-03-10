#version 400

out vec4 fragColor;
in vec2 uv;
uniform vec3 xvec;
uniform vec3 yvec;
uniform vec3 eye;

const float EPSILON = 0.01;
const vec2 SCREEN_SIZE = vec2(100, 100);

float distBox(vec3 p, vec3 s) {	
	return length(max(vec3(0, 0, 0), abs(p) - s));
}

float dist(vec3 p) {
	const float R = 30;
	const float r = 10;
	p.y = -p.y;
	const float depth = 5;
	const float c = cos(45);
	const float s = sin(45);
	float r1 = distBox(p+vec3(25, 0, 0), vec3(2.5, 35, depth));
	float r2 = distBox(p+vec3(25, 20, 0), vec3(17, 2.5, depth));
	float nx = p.x * c - p.y * s;
	float ny = p.x * s + p.y * c;
	float r3 = distBox(vec3(nx+30, ny+30, p.z), vec3(9, 2.5, depth));
	nx = p.x * c + p.y * s;
	ny =-p.x * s + p.y * c;
	float r4 = distBox(vec3(nx, ny-15, p.z), vec3(9, 2.5, depth));
	float r5 = distBox(p + vec3(-25, 0, 0), vec3(2.5, 25, depth));
	float r6 = distBox(p + vec3(-25, 23, 0), vec3(12, 2.5, depth));
	float r7 = distBox(p + vec3(-25, 0, 0), vec3(17, 2.5, depth));
	float r8 = distBox(p + vec3(-33, -23, 0), vec3(10, 2.5, depth));
	return min(r1, min(r2, min(r3, min(r4, min(r5, min(r6, min(r7, r8)))))));
}

vec3 getNormal(vec3 p) {
	vec3 result;
	result.x = dist(p + vec3(EPSILON, 0, 0)) - dist(p - vec3(EPSILON, 0, 0));
	result.y = dist(p + vec3(0, EPSILON, 0)) - dist(p - vec3(0, EPSILON, 0));
	result.z = dist(p + vec3(0, 0, EPSILON)) - dist(p - vec3(0, 0, EPSILON));
	return normalize(result);
}

void main() {
	//Ray Marching
	vec3 c = normalize(mat2x3(xvec, yvec) * (uv * SCREEN_SIZE) - eye);
	vec3 p = eye;
	for (int j = 0; j < 80; j++) {
		float d = dist(p);
		p += d * c;
		if (abs(d) < EPSILON)
			break;
	}
	float d = dist(p);
	if (abs(d) < EPSILON) {
		vec3 n = getNormal(p);
		float dif = -dot(n, c);
		fragColor = vec4(vec3(1, 1, 1) * dif, 1.0);
	} else {
		fragColor = vec4(0, 0, 0, 1);
	}
}
