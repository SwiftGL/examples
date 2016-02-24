// License: http://creativecommons.org/publicdomain/zero/1.0/

// Import the required libraries
import CGLFW3
import SGLOpenGL
#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

// Window dimensions
let WIDTH:GLsizei = 800, HEIGHT:GLsizei = 600

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
    let ourShader = Shader(vertexFile: "basic.vs", fragmentFile: "basic.frag")
            
    // Set up vertex data
    let vertices:[GLfloat] = [
         0.5, -0.5, 0.0,   1.0, 0.0, 0.0,// Bottom Right
        -0.5, -0.5, 0.0,   0.0, 1.0, 0.0,// Bottom Left
         0.0,  0.5, 0.0,   0.0, 0.0, 1.0  // Top
    ]
    var VBO:GLuint=0, VAO:GLuint=0
    glGenVertexArrays(n: 1, arrays: &VAO)
    defer { glDeleteVertexArrays(1, &VAO) }
    glGenBuffers(n: 1, buffers: &VBO)
    defer { glDeleteBuffers(1, &VBO) }
    // Bind the Vertex Array Object first, then bind and set
    // vertex buffer(s) and attribute pointer(s).
    glBindVertexArray(VAO)

    glBindBuffer(target: GL_ARRAY_BUFFER, buffer: VBO)
    glBufferData(target: GL_ARRAY_BUFFER, 
        size: strideof(GLfloat) * vertices.count,
        data: vertices, usage: GL_STATIC_DRAW)

    let pointer0offset = UnsafePointer<Void>(bitPattern: 0)
    glVertexAttribPointer(index: 0, size: 3, type: GL_FLOAT,
        normalized: false, stride: GLsizei(strideof(GLfloat) * 6), pointer: pointer0offset)
    glEnableVertexAttribArray(0)

    let pointer1offset = UnsafePointer<Void>(bitPattern: strideof(GLfloat) * 3)
    glVertexAttribPointer(index: 1, size: 3, type: GL_FLOAT,
        normalized: false, stride: GLsizei(strideof(GLfloat) * 6), pointer: pointer1offset)
    glEnableVertexAttribArray(1)

    glBindBuffer(target: GL_ARRAY_BUFFER, buffer: 0) // Note that this is allowed,
        // the call to glVertexAttribPointer registered VBO as the currently bound
        // vertex buffer object so afterwards we can safely unbind.

    glBindVertexArray(0) // Unbind VAO; it's always a good thing to
        // unbind any buffer/array to prevent strange bugs.
        // remember: do NOT unbind the EBO, keep it bound to this VAO.


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
        ourShader.use()
        glBindVertexArray(VAO)
        glDrawArrays(GL_TRIANGLES, 0, 3)
        glBindVertexArray(0)
               
        glBindVertexArray(VAO)
        glDrawArrays(GL_TRIANGLES, 0, 3)
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
