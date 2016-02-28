#version 330 core
in vec3 ourColor;
in vec2 TexCoord;

out vec4 color;

uniform sampler2D ourTexture1;
uniform sampler2D ourTexture2;

void main()
{
	// Linearly interpolate between both textures
    // using alpha channel from second texture
    vec4 tex1 = texture(ourTexture1, TexCoord);
    vec4 tex2 = texture(ourTexture2, TexCoord);
    color = vec4(mix(tex1.xyz, tex2.xyz, tex2.w), 1.0f);
}
