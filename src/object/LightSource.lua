--===========================================================================--
--  Dependencies
--===========================================================================--



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class LightSource: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local LightSource = {}
LightSource.__index = LightSource;


-------------------------------------------------------------------------------
--  LightSource:new : Creates a new LightSource
-------------------------------------------------------------------------------
function LightSource:new( lightType, color, diffuseStr, ambientStr, ... )
	local obj = {}
	
	local arg = {...};
	
	obj._type	= lightType;
	obj._on		= true;
	obj._col	= color or {255,255,255,255};
	obj._dif	= diffuseStr or 1;
	obj._amb	= ambientStr or 0;
	
	if lightType == "directional" then
		obj._dir	= arg[1] or {0,0,-1}		
	elseif lightType == "point" then
		obj._pos	= arg[1] or {0,0,0};		
		obj._atten = 
		{
			const	= arg[2] or 0;
			linear	= arg[3] or 0;
			exp 	= arg[4] or 1;
		}
	else
		error( "Invalid light type: " .. tostring(lightType) );
	end		

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  LightSource:Send : Sends the light to the given shader
-------------------------------------------------------------------------------
function LightSource:Send( shader, idx, refW, refH )
	local lightPrefix = self._type .. "Lights[" .. idx .. "].";
	shader:send( lightPrefix .. "base.color",
		{ 
			(self._col[1] or 0)		/ 255,
			(self._col[2] or 0)		/ 255,
			(self._col[3] or 0)		/ 255,
			(self._col[4] or 255)	/ 255,
		}
	);			
	
	shader:send( lightPrefix .. "base.ambientStrength", self._amb );
	shader:send( lightPrefix .. "base.diffuseStrength", self._dif );
	
	if self._type == "directional" then
		shader:send( lightPrefix .. "direction", self._dir );
	elseif self._type == "point" then
		-- Normalize the position
		local pos = { 	self._pos[1]/refW,
						self._pos[2]/refH, 
						self._pos[3] 		};
		shader:send( lightPrefix .. "position", pos );
		shader:send( lightPrefix .. "attenConst", self._atten.const );
		shader:send( lightPrefix .. "attenLinear", self._atten.linear );
		shader:send( lightPrefix .. "attenExp", self._atten.exp );
	end
end


-------------------------------------------------------------------------------
--  LightSource:GetType : Returns the type of the light source
-------------------------------------------------------------------------------
function LightSource:GetType()
	return self._type;
end


-------------------------------------------------------------------------------
--  LightSource:IsOn : Returns whether the light source is on
-------------------------------------------------------------------------------
function LightSource:IsOn()
	return self._on;
end


-------------------------------------------------------------------------------
--  LightSource:SetOn : Turns the light source on/off
-------------------------------------------------------------------------------
function LightSource:SetOn( on )
	self._on = on;
end


-------------------------------------------------------------------------------
--  LightSource:SetColor : Sets the color of the light source
-------------------------------------------------------------------------------
function LightSource:SetColor( r, g, b, a )
	assert( r and g and b );
	self._col = { r, g, b, a or 255 };
end


-------------------------------------------------------------------------------
--  LightSource:GetColor : Returns the color of the light source
-------------------------------------------------------------------------------
function LightSource:GetColor()
	return self._col[1], self._col[2], self._col[3], self._col[4];
end


-------------------------------------------------------------------------------
--  LightSource:SetDiffuseStrength : Sets the diffuse strength of the light
-------------------------------------------------------------------------------
function LightSource:SetDiffusePower( str )
	self._dif = str;
end


-------------------------------------------------------------------------------
--  LightSource:GetDiffusePower : Returns the diffuse strength of the light
-------------------------------------------------------------------------------
function LightSource:GetDiffusePower()
	return self._dif;
end


-------------------------------------------------------------------------------
--  LightSource:SetAmbientPower : Sets the diffuse strength of the light
-------------------------------------------------------------------------------
function LightSource:SetAmbientPower( str )
	self._dif = str;
end


-------------------------------------------------------------------------------
--  LightSource:GetAmbientPower : Returns the ambient strength of the light
-------------------------------------------------------------------------------
function LightSource:GetAmbientPower()
	return self._amb;
end


-------------------------------------------------------------------------------
--  LightSource:SetDirection : Sets the direction of a light source
-------------------------------------------------------------------------------
function LightSource:SetDirection( x, y, z )
	assert( self._type == "directional" );
	assert( x and y and z );
	self._dir = {x,y,z}
end


-------------------------------------------------------------------------------
--  LightSource:GetDirection : Returns the direction of a light source
-------------------------------------------------------------------------------
function LightSource:GetDirection()
	assert( self._type == "directional" );
	return self._dir[1], self._dir[2], self._dir[3]
end


-------------------------------------------------------------------------------
--  LightSource:SetPosition : Sets the position of a point light source
-------------------------------------------------------------------------------
function LightSource:SetPosition( x, y, z )
	assert( self._type == "point" );
	assert( x and y and z );
	self._pos = {x,y,z}
end


-------------------------------------------------------------------------------
--  LightSource:GetPosition : Returns the attenuation of a point light source
-------------------------------------------------------------------------------
function LightSource:GetPosition()
	assert( self._type == "point" );
	return self._pos[1], self._pos[2], self._pos[3]
end


-------------------------------------------------------------------------------
--  LightSource:SetAttenuation : Sets the attenuation of a point light source
-------------------------------------------------------------------------------
function LightSource:SetAttenuation( const, linear, exp )
	assert( self._type == "point" );
	self._atten.const	= const		or 0;
	self._atten.linear	= linear	or 0;
	self._atten.exp 	= exp		or 0;
end


-------------------------------------------------------------------------------
--  LightSource:GetAttenuation : Returns the attenuation of a point light
-------------------------------------------------------------------------------
function LightSource:GetAttenuation()
	assert( self._type == "point" );
	return	self._atten.const, self._atten.linear, self._atten.exp;
end



--===========================================================================--
--  Initialization
--===========================================================================--
return LightSource