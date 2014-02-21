#define NUM_LIGHTS 3

struct Light 
{
	vec4 diffuse;
	vec4 ambient;
	vec4 position;
};

uniform Light lights[NUM_LIGHTS];
uniform Image normalMap;


vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
	vec4 outFrag = vec4( 0.0, 0.0, 0.0, 0.0 );
	vec3 normalVec = normalize( texture2D( normalMap, texture_coords ).xyz );
	
	for( int i=0; i<NUM_LIGHTS; i++ )
	{
		vec3 lightVec = lights[i].position.xyz;
	
		// Diffuse
		outFrag += dot( normalVec, lightVec ) * lights[i].diffuse;
		
		// Ambient
		outFrag += lights[i].ambient;
	}
	
	outFrag.a = 1;
	return outFrag * texture2D( texture, texture_coords );
}