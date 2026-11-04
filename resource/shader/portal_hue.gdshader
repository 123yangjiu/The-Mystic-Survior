shader_type canvas_item;

//给传送门换色：转色相 + 提亮 + 加饱和，让深蓝色的底图转出来也能看出颜色
uniform float hue_shift : hint_range(-1.0, 1.0) = 0.0;
uniform float brightness : hint_range(0.5, 4.0) = 1.0;
uniform float saturation : hint_range(0.0, 3.0) = 1.0;

vec3 rgb2hsv(vec3 c) {
	float maxc = max(c.r, max(c.g, c.b));
	float minc = min(c.r, min(c.g, c.b));
	float delta = maxc - minc;
	float h = 0.0;
	if (delta > 0.0001) {
		if (maxc == c.r) {
			h = mod((c.g - c.b) / delta, 6.0);
		} else if (maxc == c.g) {
			h = (c.b - c.r) / delta + 2.0;
		} else {
			h = (c.r - c.g) / delta + 4.0;
		}
		h /= 6.0;
	}
	float s = (maxc <= 0.0001) ? 0.0 : delta / maxc;
	return vec3(h, s, maxc);
}

vec3 hsv2rgb(vec3 c) {
	vec3 p = abs(fract(c.xxx + vec3(0.0, 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - 3.0);
	return c.z * mix(vec3(1.0), clamp(p - 1.0, 0.0, 1.0), c.y);
}

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec3 hsv = rgb2hsv(tex.rgb);
	hsv.x = fract(hsv.x + hue_shift);
	hsv.y = clamp(hsv.y * saturation, 0.0, 1.0);
	hsv.z = clamp(hsv.z * brightness + 0.08, 0.0, 1.0);
	COLOR = vec4(hsv2rgb(hsv), tex.a) * COLOR;
}
