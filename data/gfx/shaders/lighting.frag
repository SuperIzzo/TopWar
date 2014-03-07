#define NUM_DIR_LIGHTS 3
#define NUM_POINT_LIGHTS 3

//===================// LightBase //===================//
struct LightBase
{
	vec4 color;
	float diffuseStrength;
	float ambientStrength;
};

//===================// DirectionalLight //===================//
struct DirectionalLight
{
	LightBase base;
	vec3 direction;
};

//===================// PointLight //===================//
struct PointLight
{
	LightBase base;
	vec3 position;
	float attenConst;
	float attenLinear;
	float attenExp;
};


//===================// UNIFORM INPUT //===================//
uniform DirectionalLight	directionalLights[NUM_DIR_LIGHTS];
uniform PointLight		 	pointLights[NUM_POINT_LIGHTS];
uniform Image				normalMap;


//===================// Base Lighting //===================//
vec4 BaseLighting( LightBase base, vec3 lightVec, vec3 normalVec )
{
	vec4 result = vec4(0.0, 0.0, 0.0, 0.0);
	
	// Diffuse
	result += base.color * base.diffuseStrength * max( 0.0, dot( normalVec, -lightVec ));
		
	// Ambient
	result += base.color * base.ambientStrength;
	
	return result;
}

//===================// Directional Lighting //===================//
vec4 DirectionalLighting( DirectionalLight light, vec3 normalVec )
{
	return BaseLighting( light.base, light.direction, normalVec );
}

//===================// Point Lighting //===================//
vec4 PointLighting( PointLight light, vec3 coords, vec3 normalVec )
{
	vec3 lightDir	= coords - light.position;
	float lightDist	= length( lightDir );
	lightDir = normalize( lightDir );
	
	float atten =	light.attenConst + 
					light.attenLinear * lightDist + 
					light.attenExp * lightDist * lightDist;

	if( atten<1.0 )
	{
		atten = 1.0;
	}
	
	vec4 color = BaseLighting( light.base, lightDir, normalVec );
	
	return color / atten;
}


//===================// Main //===================//
vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
	vec4 outFrag = vec4( 0.0, 0.0, 0.0, 0.0 );
	vec3 normalVec = normalize( texture2D( normalMap, texture_coords ).xyz );
	normalVec = (normalVec - vec3( 0.5, 0.5, 0.0 ))* vec3(2.0, 2.0, 1.0);
	vec3 pointCoords = vec3( texture_coords.xy,  0.0 );
	
	for( int i=0; i<NUM_DIR_LIGHTS; i++ )
	{
		outFrag += DirectionalLighting( directionalLights[i], normalVec );
	}
	
	for( int i=0; i<NUM_POINT_LIGHTS; i++ )
	{
		
		outFrag += PointLighting( pointLights[i], pointCoords, normalVec );
	}
	
	outFrag.a = 1.0;
	return outFrag * texture2D( texture, texture_coords );
}