import Foundation
import SGLOpenGL


public class Shader {

    public private(set) var program:GLuint = 0


    public init(vertex:String, fragment:String)
    {
        let vertexID = glCreateShader(type: GL_VERTEX_SHADER)
        defer{ glDeleteShader(vertexID) }
        if let errorMessage = Shader.compileShader(vertexID, source: vertex) {
            fatalError(errorMessage)
        }
        let fragmentID = glCreateShader(type: GL_FRAGMENT_SHADER)
        defer{ glDeleteShader(fragmentID) }
        if let errorMessage = Shader.compileShader(fragmentID, source: fragment) {
            fatalError(errorMessage)
        }
        self.program = glCreateProgram()
        if let errorMessage = Shader.linkProgram(program, vertex: vertexID, fragment: fragmentID) {
            fatalError(errorMessage)
        }
    }


    public convenience init(vertexFile:String, fragmentFile:String)
    {
        do {
            let vertexData = try Data(contentsOf: URL(fileURLWithPath:vertexFile), options: [.uncached, .alwaysMapped])
            let fragmentData = try Data(contentsOf: URL(fileURLWithPath:fragmentFile), options: [.uncached, .alwaysMapped])
            let vertexString = String(data: vertexData, encoding: .utf8)!
            let fragmentString = String(data: fragmentData, encoding: .utf8)!
            self.init(vertex: vertexString, fragment: fragmentString)
        }
        catch let error as NSError {
            fatalError(error.localizedFailureReason!)
        }
        catch {
            fatalError(String(describing: error))
        }
    }


    deinit
    {
        glDeleteProgram(program)
    }


    public func use()
    {
        glUseProgram(program)
    }


    private static func compileShader(_ shader: GLuint, source: String) -> String?
    {
        source.withCString {
            var s = [$0]
            glShaderSource(shader: shader, count: 1, string: &s, length: nil)
        }
        glCompileShader(shader)
        var success:GLint = 0
        glGetShaderiv(shader: shader, pname: GL_COMPILE_STATUS, params: &success)
        if success != GL_TRUE {
            var logSize:GLint = 0
            glGetShaderiv(shader: shader, pname: GL_INFO_LOG_LENGTH, params: &logSize)
            if logSize == 0 { return "" }
            var infoLog = [GLchar](repeating: 0, count: Int(logSize))
            glGetShaderInfoLog(shader: shader, bufSize: logSize, length: nil, infoLog: &infoLog)
            return String(cString:infoLog)
        }
        return nil
    }


    private static func linkProgram(_ program: GLuint, vertex: GLuint, fragment: GLuint) -> String?
    {
        glAttachShader(program, vertex)
        glAttachShader(program, fragment)
        glLinkProgram(program)
        var success:GLint = 0
        glGetProgramiv(program: program, pname: GL_LINK_STATUS, params: &success)
        if success != GL_TRUE {
        var logSize:GLint = 0
            glGetProgramiv(program: program, pname: GL_INFO_LOG_LENGTH, params: &logSize)
            if logSize == 0 { return "" }
            var infoLog = [GLchar](repeating: 0, count: Int(logSize))
            glGetProgramInfoLog(program: program, bufSize: logSize, length: nil, infoLog: &infoLog)
            return String(cString:infoLog)
        }
        return nil
    }

}
