shader_type canvas_item;

void fragment() {
	vec2 uv = vec2(UV.x - sin(TIME * 80.0) * 0.1, UV.y - sin(TIME * 50.0) * 0.02);
	COLOR = texture(TEXTURE,uv);
	
}