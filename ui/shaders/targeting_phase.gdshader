shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture, filter_nearest;

// These use the color for targetable state of the card color, sampled per-pixel for the shades of red
// #770000
uniform vec4 key_a : source_color = vec4(0.4667, 0.0, 0.0, 1.0);
// optional second key for the dimmed variant, e.g. #3B0000
uniform vec4 key_b : source_color = vec4(0.2314, 0.0, 0.0, 1.0);

uniform float tolerance : hint_range(0.0, 0.2) = 0.01;
uniform float feather : hint_range(0.0, 0.1) = 0.005;
uniform float gray_amount : hint_range(0.0, 1.0) = 0.0;

float key_match(vec3 c, vec3 key) {
	float d = distance(c, key);
	return 1.0 - smoothstep(tolerance, tolerance + feather, d);
}

void fragment() {
	vec3 rgb = texture(screen_tex, SCREEN_UV).rgb;

	float keep = max(key_match(rgb, key_a.rgb), key_match(rgb, key_b.rgb));

	// 601 version
	//float g = dot(rgb, vec3(0.299, 0.587, 0.114));
	
	//709 version
	float g = dot(rgb, vec3(0.2126, 0.7152, 0.0722));
	vec3 grayed = mix(rgb, vec3(g), gray_amount);

	COLOR = vec4(mix(grayed, rgb, keep), 1.0);
}