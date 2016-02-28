// License: http://creativecommons.org/publicdomain/zero/1.0/

// Import the required libraries
import CGLFW3
import SGLOpenGL
import SGLImage
import SGLMath
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
    let ourShader = Shader(vertexFile: "textures.vs", fragmentFile: "textures.frag")

    let cubePositions:[vec3] = [
      [ 0.0,  0.0,  0.0], 
      [ 2.0,  5.0, -15.0], 
      [-1.5, -2.2, -2.5],  
      [-3.8, -2.0, -12.3],  
      [ 2.4, -0.4, -3.5],  
      [-1.7,  3.0, -7.5],  
      [ 1.3, -2.0, -2.5],  
      [ 1.5,  2.0, -2.5], 
      [ 1.5,  0.2, -1.5], 
      [-1.3,  1.0, -1.5]  
    ]    

    var VBO:GLuint=0, VAO:GLuint=0
    
    glGenVertexArrays(n: 1, arrays: &VAO)
    defer { glDeleteVertexArrays(1, &VAO) }
    
    glGenBuffers(n: 1, buffers: &VBO)
    defer { glDeleteBuffers(1, &VBO) }

    glBindVertexArray(VAO)

    glBindBuffer(target: GL_ARRAY_BUFFER, buffer: VBO)
    glBufferData(target: GL_ARRAY_BUFFER, 
        size: strideof(GLfloat) * vertices.count,
        data: vertices, usage: GL_STATIC_DRAW)
        
    // Position attribute
    let pointer0offset = UnsafePointer<Void>(bitPattern: 0)
    glVertexAttribPointer(index: 0, size: 3, type: GL_FLOAT,
        normalized: false, stride: GLsizei(strideof(GLfloat) * 5), pointer: pointer0offset)
    glEnableVertexAttribArray(0)

    // TexCoord attribute
    let pointer1offset = UnsafePointer<Void>(bitPattern: strideof(GLfloat) * 3)
    glVertexAttribPointer(index: 1, size: 2, type: GL_FLOAT,
        normalized: false, stride: GLsizei(strideof(GLfloat) * 5), pointer: pointer1offset)
    glEnableVertexAttribArray(1)

    glBindBuffer(target: GL_ARRAY_BUFFER, buffer: 0) // Note that this is allowed,
        // the call to glVertexAttribPointer registered VBO as the currently bound
        // vertex buffer object so afterwards we can safely unbind.

    glBindVertexArray(0) // Unbind VAO; it's always a good thing to
        // unbind any buffer/array to prevent strange bugs.
        // remember: do NOT unbind the EBO, keep it bound to this VAO.


    // Load and create textures
    var texture1:GLuint = 0
    var texture2:GLuint = 0
    
    // Globally change loader to 0,0 in lower left
    SGLImageLoader.flipVertical = true
    
    // == Texture 1
    glGenTextures(1, &texture1)
    glBindTexture(GL_TEXTURE_2D, texture1) // All upcoming GL_TEXTURE_2D operations
                                          // now have effect on this texture object
    // Set texture wrapping to GL_REPEAT (usually basic wrapping method)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)

    // Set texture filtering parameters
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)

    // Load image from disk
    let loader1 = SGLImageLoader(fromFile: "container.png")
    if (loader1.error != nil) { fatalError(loader1.error!) }
    let image1 = SGLImageRGB<UInt8>(loader1)
    if (loader1.error != nil) { fatalError(loader1.error!) }
    
    // Create texture and generate mipmaps
    image1.withUnsafeMutableBufferPointer() {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB,
            GLsizei(image1.width),
            GLsizei(image1.height),
            0, GL_RGB, GL_UNSIGNED_BYTE,
            $0.baseAddress)
    }
    glGenerateMipmap(GL_TEXTURE_2D)
    glBindTexture(GL_TEXTURE_2D, 0)
    
    // == Texture 2
    glGenTextures(1, &texture2)
    glBindTexture(GL_TEXTURE_2D, texture2) // All upcoming GL_TEXTURE_2D operations
                                          // now have effect on this texture object
    // Set texture wrapping to GL_REPEAT (usually basic wrapping method)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)

    // Set texture filtering parameters
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)

    // Load image from disk
    let loader2 = SGLImageLoader(fromFile: "awesomeface.png")
    if (loader2.error != nil) { fatalError(loader2.error!) }
    
    let image2 = SGLImageRGBA<UInt8>(loader2)
    if (loader2.error != nil) { fatalError(loader2.error!) }
    
    // Create texture and generate mipmaps
    image2.withUnsafeMutableBufferPointer() {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,
            GLsizei(image2.width),
            GLsizei(image2.height),
            0, GL_RGBA, GL_UNSIGNED_BYTE,
            $0.baseAddress)
    }
    glGenerateMipmap(GL_TEXTURE_2D)
    glBindTexture(GL_TEXTURE_2D, 0)
    
    // Setup OpenGL options
    glEnable(GL_DEPTH_TEST)

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
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
        
        // Activate shader
        ourShader.use()
        
        // Bind Textures using texture units
        glActiveTexture(GL_TEXTURE0)
        glBindTexture(GL_TEXTURE_2D, texture1)
        glUniform1i(glGetUniformLocation(ourShader.program, "ourTexture1"), 0)
        glActiveTexture(GL_TEXTURE1)
        glBindTexture(GL_TEXTURE_2D, texture2)
        glUniform1i(glGetUniformLocation(ourShader.program, "ourTexture2"), 1)
        
        // Create transformations
        var view = SGLMath.translate(mat4(), vec3(0.0, 0.0, -3.0))
        let aspectRatio = GLfloat(WIDTH) / GLfloat(HEIGHT)
        var projection = SGLMath.perspective(radians(45.0), aspectRatio, 0.1, 100.0)
        // Get their uniform location
        let viewLoc = glGetUniformLocation(ourShader.program, "view")
        let projLoc = glGetUniformLocation(ourShader.program, "projection")
        // Pass them to the shaders
        withUnsafePointer(&view, {
            glUniformMatrix4fv(viewLoc, 1, false, UnsafePointer($0))
        })
        // Note: currently we set the projection matrix each frame, but since
        // the projection matrix rarely changes it's often best practice to
        // set it outside the main loop only once.
        withUnsafePointer(&projection, {
            glUniformMatrix4fv(projLoc, 1, false, UnsafePointer($0))
        })
        
        // Draw container
        glBindVertexArray(VAO)

        let modelLoc = glGetUniformLocation(ourShader.program, "model")
        for (index, cubePosition) in cubePositions.enumerate() {
          var model = mat4()
          model = SGLMath.translate(model, cubePosition)
          model = SGLMath.rotate(model, Float(index), vec3(0.5, 1.0, 0.0))
          withUnsafePointer(&model, {
              glUniformMatrix4fv(modelLoc, 1, false, UnsafePointer($0))
          })
          glDrawArrays(GL_TRIANGLES, 0, 36)
        }

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
