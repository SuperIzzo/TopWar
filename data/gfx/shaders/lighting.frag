uniform Image normalMap;
//uniform vec3 lightPos;


vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
	vec4 diffuse = texture2D( texture, texture_coords );

	vec3 normalVec = normalize( texture2D( normalMap, texture_coords ).xyz );
	
	vec3 lightVec = normalize( vec3(10.0, -5.0, 2.0) );
	
	float i = dot( normalVec, lightVec ) * 1.0;
	
	return vec4( diffuse.x * i, diffuse.y * i, diffuse.z * i, diffuse.w );
}