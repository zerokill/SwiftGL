#version 330 core

uniform vec2 iResolution;
uniform float iTime;

out vec4 FragColor;

void mainImage( out vec4 fragColor, in vec2 fragCoord );

void main()
{
    mainImage(FragColor, gl_FragCoord.xy);
}

/**
 * @author jonobr1 / http://jonobr1.com/
 */

/**
 * Convert r, g, b to normalized vec3
 */
vec3 rgb(float r, float g, float b) {
	return vec3(r / 255.0, g / 255.0, b / 255.0);
}

/**
 * Draw a circle at vec2 `pos` with radius `rad` and
 * color `color`.
 */
vec4 circle(vec2 uv, vec2 pos, float rad, vec3 color) {
	float d = length(pos - uv) - rad;
	float t = clamp(d, 0.0, 1.0);
	return vec4(color, 1.0 - t);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 r = vec2(fragCoord.x / iResolution.x,
              fragCoord.y / iResolution.y);

	vec3 color1 = vec3(0.841, 0.582, 0.594);
	vec3 color2 = vec3(0.884, 0.850, 0.648);
	vec3 color3 = vec3(0.348, 0.555, 0.641);
	vec3 pixel;
	
	// sugar syntax for "if" conditional. It says
	// "if the x coordinate of a pixel is greater than the half of
	// the width of the screen, then use color1, otherwise use
	// color2."
	if( r.x < 1.0/3.0) {
		pixel = color1;
	} else if( r.x < 2.0/3.0 ) {
		pixel = color2;
	} else {
		pixel = color3;
	}

    fragColor = vec4(pixel, 1.0);

}

