shader_type canvas_item;

uniform sampler2D noise_texture : repeat_enable, filter_nearest;
uniform float density : hint_range(0.0, 1.0) = 0.35;
uniform vec2 speed = vec2(0.01, 0.005);

void fragment()
{
    vec2 uv = UV + speed * TIME;

    float noise = texture(noise_texture, uv).r;

    // Make the noise softer
    float fog = smoothstep(0.25, 0.75, noise);

    COLOR = vec4(0.75, 0.75, 0.75, fog * density);
}