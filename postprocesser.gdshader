shader_type canvas_item;

uniform int y_res = 240;

vec2 curve(vec2 uv) {

	uv = (uv - 0.5) * 2.0;
	uv *= 1.1;	
	uv.x *= 1.0 + pow((abs(uv.y) / 5.0), 2.0);
	uv.y *= 1.0 + pow((abs(uv.x) / 4.0), 2.0);
	uv  = (uv / 2.0) + 0.5;
	uv =  uv * 0.92 + 0.04;

	return uv;
}
void fragment() {
	
	vec2 resolution = vec2(float(y_res) * SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x, float(y_res));
	vec2 uv = curve(UV);
	vec2 pixel = floor(uv * resolution);
	uv = pixel / resolution;
    
	vec3 col;
	
	if (uv.x < 0.0 || uv.y < 0.0 || uv.x > 1.0 || uv.y > 1.0) {
		col = vec3(0.0);
	} else {
		col = texture(TEXTURE, uv).xyz;
	}

	// quantize channels with dithering (only half of all pixels round to nearest, other half round down)
	col *= 8.0;
	if (floor(mod(pixel.x, 2.0)) == floor(mod(pixel.y, 2.0))) {

		if (mod(col.r, 1.0) > 0.5) {
			col.r = ceil(col.r);
		} else {
			col.r = floor(col.r);
		}

		if (mod(col.g, 1.0) > 0.5) {
			col.g = ceil(col.g);
		} else {
			col.g = floor(col.g);
		}

		if (mod(col.b, 1.0) > 0.5) {
			col.b = ceil(col.b);
		} else {
			col.b = floor(col.b);
		}
	} else {
		col = floor(col);
	}
	col /= 8.0;

    COLOR = vec4(col, 1.0);
}