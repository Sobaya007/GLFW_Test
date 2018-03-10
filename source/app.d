import std.stdio;
import std.string;
import std.conv;
import std.file;
import std.mathspecial;
import derelict.opengl;
import derelict.glfw3.glfw3;

void main() 
{

	/*
       Initialize Derelict (Loading DLL)
    */
	DerelictGL3.load();
	DerelictGLFW3.load();



    /*
       Initialize GLFW & create window
    */
	if (!glfwInit()) {
		writeln("Failed to initialize GLFW");
		return;
	}

    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR,3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR,3);
	auto window = glfwCreateWindow(800, 600,"Hello, D world!", null, null);
	if(!window){
		writeln("Failed to create window");
		return;
	}
	glfwMakeContextCurrent(window);
	auto glver = DerelictGL3.reload();



    /*
       Initialize OpenGL
    */
	int result;

    // Shader Prepare
	int programID = glCreateProgram();

    // Vertex Shader Compile
	auto vsID = glCreateShader(GL_VERTEX_SHADER);
	auto vsPath = readText("source/test.vert");
	auto str = vsPath.toStringz;
	auto len = cast(int)vsPath.length;
	glShaderSource(vsID, 1, &str, &len);
	glCompileShader(vsID);


    // Vertex Shader Compile Check
	glGetShaderiv(vsID, GL_COMPILE_STATUS, &result);
	if (result == GL_FALSE) {
		int logLength;
		glGetShaderiv(vsID, GL_INFO_LOG_LENGTH, &logLength);
		char[] log = new char[logLength];
		int a;
		glGetShaderInfoLog(vsID, logLength, &a, &log[0]);
		("Compile Error in \"" ~ vsPath ~ "\"\n" ~ to!string(log)).writeln;
		return;
	}
	glAttachShader(programID, vsID);


    // Fragment Shader Compile
	auto fsID = glCreateShader(GL_FRAGMENT_SHADER);
	auto fsPath = readText("source/test.frag");
	str = fsPath.toStringz;
	len = cast(int)fsPath.length;
	glShaderSource(fsID, 1, &str, &len);
	glCompileShader(fsID);


    // Fragment Shader Compile Check
	glGetShaderiv(fsID, GL_COMPILE_STATUS, &result);
	if (result == GL_FALSE) {
		int logLength;
		glGetShaderiv(fsID, GL_INFO_LOG_LENGTH, &logLength);
		char[] log = new char[logLength];
		int a;
		glGetShaderInfoLog(fsID, logLength, &a, log.ptr);
		("Compile Error in \"" ~ fsPath ~ "\"\n" ~ to!string(log)).writeln;
		return;
	}
	glAttachShader(programID, fsID);


    // Link Shaders to Program
	glLinkProgram(programID);


    // Link Check
	glGetProgramiv(programID, GL_LINK_STATUS, &result);
	if (result == GL_FALSE) {
		int logLength;
		glGetProgramiv(programID, GL_INFO_LOG_LENGTH, &logLength);
		char[] log = new char[logLength];
		int a;
		glGetProgramInfoLog(programID, logLength, &a, log.ptr);
		("Link Error\n" ~ to!string(log)).writeln;
		return;
	}


	glUseProgram(programID);


    // VAO creation
	uint vao;
	glGenVertexArrays(1, &vao);
	glBindVertexArray(vao);


    // VBO creation & blits data
	uint vbo;
	glGenBuffers(1, &vbo);
	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	float[8] position = [
		-1.0f, -1.0f,
		+1.0f, -1.0f,
		-1.0f, +1.0f,
		+1.0f, +1.0f,
	];
	glBufferData(GL_ARRAY_BUFFER, position.sizeof, position.ptr, GL_STATIC_DRAW);


    // attach VBO to Attribute
	auto vLoc = glGetAttribLocation(programID, "pos");
	glEnableVertexAttribArray(vLoc);
	glVertexAttribPointer(vLoc, 2, GL_FLOAT, false, 0, null);


    // Preparing Uniforms
	auto xLoc = glGetUniformLocation(programID, "xvec");
	auto yLoc = glGetUniformLocation(programID, "yvec");
	auto eLoc = glGetUniformLocation(programID, "eye");

    /*
       Prepare Camera
    */
	enum CAMERA_DISTANCE = 500.0f;
	enum CAMERA_ROTATION_SPEED = 0.05f;

	float[] n = [1/sqrt(3.0f), 1/sqrt(3.0f), 1/sqrt(3.0f)];
	float c = cos(CAMERA_ROTATION_SPEED);
	float s = sin(CAMERA_ROTATION_SPEED);

	float[][] matrix = new float[][](3, 3);
	matrix[0][0] = n[0]*n[0]*(1-c)+c;
	matrix[0][1] = n[0]*n[1]*(1-c)-n[2]*s;
	matrix[0][2] = n[2]*n[0]*(1-c)+n[1]*s;
	matrix[1][0] = n[0]*n[1]*(1-c)+n[2]*s;
	matrix[1][1] = n[1]*n[1]*(1-c)+c;
	matrix[1][2] = n[1]*n[2]*(1-c)-n[0]*s;
	matrix[2][0] = n[2]*n[0]*(1-c)-n[1]*s;
	matrix[2][1] = n[1]*n[2]*(1-c)+n[0]*s;
	matrix[2][2] = n[2]*n[2]*(1-c)+c;

	float[] xvec = [1, 0, 0];
	float[] yvec = [0, 1, 0];
	float[] eye  = [0, 0, CAMERA_DISTANCE];


    /*
       Main Loop
    */
	while (!glfwWindowShouldClose(window))
	{

		glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
		glClear(GL_COLOR_BUFFER_BIT);


		glUniform3fv(xLoc, 1, xvec.ptr);
		glUniform3fv(yLoc, 1, yvec.ptr);
		glUniform3fv(eLoc, 1, eye.ptr);


		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);


		glfwSwapBuffers(window);
		glfwPollEvents();

        // Rotation
		float sx, sy, sz;
		sx = matrix[0][0] * eye[0] + matrix[0][1] * eye[1] + matrix[0][2] * eye[2];
		sy = matrix[1][0] * eye[0] + matrix[1][1] * eye[1] + matrix[1][2] * eye[2];
		sz = matrix[2][0] * eye[0] + matrix[2][1] * eye[1] + matrix[2][2] * eye[2];
		eye[0] = sx; eye[1] = sy; eye[2] = sz;
		sx = matrix[0][0] * xvec[0] + matrix[0][1] * xvec[1] + matrix[0][2] * xvec[2];
		sy = matrix[1][0] * xvec[0] + matrix[1][1] * xvec[1] + matrix[1][2] * xvec[2];
		sz = matrix[2][0] * xvec[0] + matrix[2][1] * xvec[1] + matrix[2][2] * xvec[2];
		xvec[0] = sx; xvec[1] = sy; xvec[2] = sz;
		sx = matrix[0][0] * yvec[0] + matrix[0][1] * yvec[1] + matrix[0][2] * yvec[2];
		sy = matrix[1][0] * yvec[0] + matrix[1][1] * yvec[1] + matrix[1][2] * yvec[2];
		sz = matrix[2][0] * yvec[0] + matrix[2][1] * yvec[1] + matrix[2][2] * yvec[2];
		yvec[0] = sx; yvec[1] = sy; yvec[2] = sz;
	}

	//後始末
	glfwTerminate();
}
