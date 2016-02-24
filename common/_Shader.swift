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
            let vertexData = try NSData(contentsOfFile: vertexFile,
                options: [.DataReadingUncached, .DataReadingMappedAlways])
            let fragmentData = try NSData(contentsOfFile: fragmentFile,
                options: [.DataReadingUncached, .DataReadingMappedAlways])
            let vertexString = NSString(data: vertexData, encoding: NSUTF8StringEncoding)
            let fragmentString = NSString(data: fragmentData, encoding: NSUTF8StringEncoding)
            self.init(vertex: String(vertexString!), fragment: String(fragmentString!))
        }
        catch let error as NSError {
            fatalError(error.localizedFailureReason!)
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


    private static func compileShader(shader: GLuint, source: String) -> String?
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
            var infoLog = [GLchar](count: Int(logSize), repeatedValue: 0)
            glGetShaderInfoLog(shader: shader, bufSize: logSize, length: nil, infoLog: &infoLog)
            return String.fromCString(infoLog)!
        }
        return nil
    }


    private static func linkProgram(program: GLuint, vertex: GLuint, fragment: GLuint) -> String?
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
            var infoLog = [GLchar](count: Int(logSize), repeatedValue: 0)
            glGetProgramInfoLog(program: program, bufSize: logSize, length: nil, infoLog: &infoLog)
            return String.fromCString(infoLog)!
        }
        return nil
    }

}
