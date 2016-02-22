// License: http://creativecommons.org/publicdomain/zero/1.0/

// Import the required libraries
import CGLFW3
import SGLOpenGL

// Window dimensions
let WIDTH:GLsizei = 800, HEIGHT:GLsizei = 600

// Shaders
let vertexShaderSource = "#version 330 core\n" +
    "layout (location = 0) in vec3 position;\n" +
    "void main()\n" +
    "{\n" +
    "gl_Position = vec4(position.x, position.y, position.z, 1.0);\n" +
    "}\n"
let fragmentShaderSource = "#version 330 core\n" +
    "out vec4 color;\n" +
    "void main()\n" +
    "{\n" +
    "color = vec4(1.0f, 0.5f, 0.2f, 1.0f);\n" +
    "}\n"

// The *main* function; where our program begins running
func main()
{
    print("Starting GLFW context, OpenGL 3.3")
    // Init GLFW
    glfwInit()
    // Terminate GLFW when this function ends
    defer { glfwTerminate() }
    
    // Set all the required options for GLFW
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3)
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3)
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE)
    glfwWindowHint(GLFW_RESIZABLE, GL_FALSE)
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE)

    // Create a GLFWwindow object that we can use for GLFW's functions
    let window = glfwCreateWindow(WIDTH, HEIGHT, "LearnSwiftGL", nil, nil)
    glfwMakeContextCurrent(window)
    guard window != nil else
    {
        print("Failed to create GLFW window")
        return
    }

    // Set the required callback functions
    glfwSetKeyCallback(window, keyCallback)

    // Define the viewport dimensions
    glViewport(x: 0, y: 0, width: WIDTH, height: HEIGHT)


    // Build and compile our shader program
    // Vertex shader
    let vertexShader = glCreateShader(type: GL_VERTEX_SHADER)
    vertexShaderSource.withCString {
        var s = [$0]
        glShaderSource(shader: vertexShader, count: 1, string: &s, length: nil)
    }
    glCompileShader(vertexShader)
    // Check for compile time errors
    var success:GLint = 0
    var infoLog = [GLchar](count: 512, repeatedValue: 0)
    glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &success)
    guard success == GL_TRUE else
    {
        glGetShaderInfoLog(vertexShader, 512, nil, &infoLog)
        fatalError(String.fromCString(infoLog)!)
    }
    // Fragment shader
    let fragmentShader = glCreateShader(type: GL_FRAGMENT_SHADER)
    fragmentShaderSource.withCString {
        var s = [$0]
        glShaderSource(shader: fragmentShader, count: 1, string: &s, length: nil)
    }
    glCompileShader(fragmentShader)
    // Check for compile time errors
    glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, &success)
    guard success == GL_TRUE else
    {
        glGetProgramInfoLog(fragmentShader, 512, nil, &infoLog)
        fatalError(String.fromCString(infoLog)!)
    }
    // Link shaders
    let shaderProgram = glCreateProgram()
    defer { glDeleteProgram(shaderProgram) }
    glAttachShader(shaderProgram, vertexShader)
    glAttachShader(shaderProgram, fragmentShader)
    glLinkProgram(shaderProgram)
    // Check for linking errors
    glGetProgramiv(shaderProgram, GL_LINK_STATUS, &success)
    guard success == GL_TRUE else
    {
        glGetShaderInfoLog(shaderProgram, 512, nil, &infoLog)
        fatalError(String.fromCString(infoLog)!)
    }
    // We no longer need these since they are in the shader program
    glDeleteShader(vertexShader)
    glDeleteShader(fragmentShader)
      
            
    // Set up vertex data (and buffer(s)) and attribute pointers)
    //let vertices:[GLfloat] = [
    //  // First triangle
    //   0.5,  0.5,  // Top Right
    //   0.5, -0.5,  // Bottom Right
    //  -0.5,  0.5,  // Top Left 
    //  // Second triangle
    //   0.5, -0.5,  // Bottom Right
    //  -0.5, -0.5,  // Bottom Left
    //  -0.5,  0.5   // Top Left
    //]
    let vertices:[GLfloat] = [
         0.5,  0.5, 0.0,  // Top Right
         0.5, -0.5, 0.0,  // Bottom Right
        -0.5, -0.5, 0.0,  // Bottom Left
        -0.5,  0.5, 0.0   // Top Left 
    ]
    let indices:[GLuint] = [  // Note that we start from 0!
        0, 1, 3,  // First Triangle
        1, 2, 3   // Second Triangle
    ]
    var VBO:GLuint=0, VAO:GLuint=0, EBO:GLuint=0
    glGenVertexArrays(n: 1, arrays: &VAO)
    defer { glDeleteVertexArrays(1, &VAO) }
    glGenBuffers(n: 1, buffers: &VBO)
    defer { glDeleteBuffers(1, &VBO) }
    glGenBuffers(n: 1, buffers: &EBO)
    defer { glDeleteBuffers(1, &EBO) }
    // Bind the Vertex Array Object first, then bind and set
    // vertex buffer(s) and attribute pointer(s).
    glBindVertexArray(VAO)

    glBindBuffer(target: GL_ARRAY_BUFFER, buffer: VBO)
    glBufferData(target: GL_ARRAY_BUFFER, 
        size: strideof(GLfloat) * vertices.count,
        data: vertices, usage: GL_STATIC_DRAW)

    glBindBuffer(target: GL_ELEMENT_ARRAY_BUFFER, buffer: EBO)
    glBufferData(target: GL_ELEMENT_ARRAY_BUFFER, 
        size: strideof(GLuint) * indices.count,
        data: indices, usage: GL_STATIC_DRAW)

    glVertexAttribPointer(index: 0, size: 3, type: GL_FLOAT,
        normalized: false, stride: GLsizei(strideof(GLfloat) * 3), pointer: nil)
    glEnableVertexAttribArray(0)

    glBindBuffer(target: GL_ARRAY_BUFFER, buffer: 0) // Note that this is allowed,
        // the call to glVertexAttribPointer registered VBO as the currently bound
        // vertex buffer object so afterwards we can safely unbind.

    glBindVertexArray(0) // Unbind VAO; it's always a good thing to
        // unbind any buffer/array to prevent strange bugs.
        // remember: do NOT unbind the EBO, keep it bound to this VAO.
        

    // Uncommenting this call will result in wireframe polygons.
    // glPolygonMode(face: GL_FRONT_AND_BACK, mode: GL_LINE);
      

    // Game loop
    while glfwWindowShouldClose(window) == GL_FALSE
    {
        // Check if any events have been activated
        // (key pressed, mouse moved etc.) and call
        // the corresponding response functions
        glfwPollEvents()

        // Render
        // Clear the colorbuffer
        glClearColor(red: 0.2, green: 0.3, blue: 0.3, alpha: 1.0)
        glClear(GL_COLOR_BUFFER_BIT)
        
        // Draw our first triangle
        glUseProgram(shaderProgram)
        glBindVertexArray(VAO)
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, nil)
        glBindVertexArray(0)

        // Swap the screen buffers
        glfwSwapBuffers(window)
    }
}

// called whenever a key is pressed/released via GLFW
func keyCallback(window: COpaquePointer, key: Int32, scancode: Int32, action: Int32, mode: Int32)
{
    if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS) {
        glfwSetWindowShouldClose(window, GL_TRUE)
    }
}

// Start the program with function main()
main()
