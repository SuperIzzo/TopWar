uniform float angle;
#define NUM_ROTATIONS 30

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{	
	vec2 center = vec2( 0.5, 0.5 );
	vec2 relPos = texture_coords - center;
	vec4 finalColor = vec4( 0.0, 0.0, 0.0, 0.0 );
	
	float progression = 0.0;
	
	for( int i=0; i<NUM_ROTATIONS; i++ )
	{
		float angleFract = -angle*float(i)/float(NUM_ROTATIONS);
		float cs = cos( angleFract );
		float sn = sin( angleFract );
		vec2 newPos = vec2( relPos.x*cs - relPos.y*sn, relPos.x*sn + relPos.y*cs );
		newPos += center;
		
		vec4 tex = texture2D( texture, newPos );
		float rate = pow(float(i),1.2) * (tex.a +0.4);
		progression = progression + rate;
		finalColor += tex * rate;
	}
	
	return finalColor/progression;
}