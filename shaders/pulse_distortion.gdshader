shader_type canvas_item;

// Shader parameters that can be set from GDScript
uniform bool just_hit = false;
uniform float hit_intensity = 0.0;
uniform float pulse_speed = 3.0;
uniform float distortion_strength = 0.15;
uniform float wave_frequency = 8.0;
uniform vec4 pulse_color = vec4(1.0, 0.5, 0.8, 1.0);
uniform float chromatic_strength = 0.02;

varying vec2 world_position;

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
    vec2 uv = UV;
    vec4 original_color = texture(TEXTURE, uv);
    
    if (just_hit && hit_intensity > 0.0) {
        // Create pulsing effect from center
        vec2 center = vec2(0.5, 0.5);
        float dist_from_center = distance(uv, center);
        
        // Time-based animation
        float time = TIME * pulse_speed;
        
        // Create expanding rings
        float ring = sin((dist_from_center * wave_frequency) - time) * 0.5 + 0.5;
        ring *= hit_intensity;
        
        // Distortion effect
        vec2 distortion = vec2(
            sin(time + dist_from_center * 10.0) * distortion_strength,
            cos(time * 0.7 + dist_from_center * 8.0) * distortion_strength
        ) * hit_intensity;
        
        // Apply distortion to UV coordinates
        vec2 distorted_uv = uv + distortion * ring;
        
        // Chromatic aberration effect
        float chromatic = chromatic_strength * hit_intensity * ring;
        vec4 distorted_color;
        distorted_color.r = texture(TEXTURE, distorted_uv + vec2(chromatic, 0.0)).r;
        distorted_color.g = texture(TEXTURE, distorted_uv).g;
        distorted_color.b = texture(TEXTURE, distorted_uv - vec2(chromatic, 0.0)).b;
        distorted_color.a = texture(TEXTURE, distorted_uv).a;
        
        // Create psychedelic color shift
        float color_shift = sin(time * 2.0 + dist_from_center * 5.0) * 0.5 + 0.5;
        vec3 trippy_color = mix(
            distorted_color.rgb,
            pulse_color.rgb * (sin(time * 3.0) * 0.3 + 0.7),
            ring * color_shift * 0.4
        );
        
        // Pulsing brightness
        float brightness_pulse = (sin(time * 4.0) * 0.2 + 1.0);
        trippy_color *= brightness_pulse;
        
        // Edge glow effect
        float edge_glow = 1.0 - smoothstep(0.3, 0.7, dist_from_center);
        trippy_color += pulse_color.rgb * edge_glow * ring * 0.3;
        
        // Mix original and effect based on hit intensity
        COLOR = vec4(mix(original_color.rgb, trippy_color, hit_intensity), original_color.a);
    } else {
        COLOR = original_color;
    }
}