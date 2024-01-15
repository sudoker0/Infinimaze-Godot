// shader adapted from:
// https://godotshaders.com/shader/retro-tv-shader/

shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float scanline_count : hint_range(0, 1800) = 50.0;
uniform bool enable_scanline = true;
uniform vec2 chromatic_aberration_offset = vec2(2.5, -2.5);
uniform bool enable_chromatic_aberration = true;

vec2 uv_curve(vec2 uv)
{
	uv = (uv - 0.5) * 2.0;
	
	//You can modify the numbers and try different values
	uv.x *= 1.0 + pow(abs(uv.y) / 4.5, 2.0);
	uv.y *= 1.0 + pow(abs(uv.x) / 4.5, 2.0);
	
	//The scale part (you can delete it when you want)
	uv /= 1.0;
	
	uv = (uv/2.0) + 0.5;
	return uv;
}


void fragment()
{
	vec2 chr_aber = vec2(0.0, 0.0);

	if (enable_chromatic_aberration) {
		chr_aber = chromatic_aberration_offset;
	}

	float r = texture(SCREEN_TEXTURE, uv_curve(SCREEN_UV) + vec2(SCREEN_PIXEL_SIZE.x * 0.0), 0.0).r;
	float g = texture(SCREEN_TEXTURE, uv_curve(SCREEN_UV) + vec2(SCREEN_PIXEL_SIZE.x * chr_aber.x), 0.0).g;
	float b = texture(SCREEN_TEXTURE, uv_curve(SCREEN_UV) + vec2(SCREEN_PIXEL_SIZE.x * chr_aber.y), 0.0).b;

	vec4 scan_line = vec4(1.0, 1.0, 1.0, 1.0);
	if (enable_scanline) {
		float s = sin(uv_curve(SCREEN_UV).y * scanline_count * PI * 2.0);
		s = (s * 0.5 + 0.5) * 0.9 + 0.1;
		scan_line = vec4(vec3(pow(s, 0.25)), 1.0);
	}
	
	COLOR = vec4(r, g, b, 1.0) * scan_line;
}
