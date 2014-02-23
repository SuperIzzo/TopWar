--===========================================================================--
--  Dependencies
--===========================================================================--


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class DyzkData: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local DyzkData = {}
DyzkData.__index = DyzkData;


-------------------------------------------------------------------------------
--  DyzkData:SetDyzkID : Sets a unique dyzk ID for the DyzkData
-------------------------------------------------------------------------------
function DyzkData:SetDyzkID( dyzkID )
	assert( type(dyzkID) == "string" )
	
	self._dyzkID = dyzkID;
end


-------------------------------------------------------------------------------
--  DyzkData:GetDyzkID : Returns the dyzkID of the DyzkData
-------------------------------------------------------------------------------
function DyzkData:GetDyzkID()
	return self._dyzkID or "";
end


-------------------------------------------------------------------------------
--  DyzkData:SetImageName : Sets the image for the DyzkData
-------------------------------------------------------------------------------
function DyzkData:SetImageName( imageName )
	assert( type(imageName) == "string" )
	
	self._imageName = imageName;
end


-------------------------------------------------------------------------------
--  DyzkData:GetImageName : Returns the image name of the DyzkData
-------------------------------------------------------------------------------
function DyzkData:GetImageName()
	return self._imageName or "";
end


-------------------------------------------------------------------------------
--  DyzkData:SetWeight : Sets the weight of the DyzkData
-------------------------------------------------------------------------------
function DyzkData:SetWeight( weigth )
	assert( weigth >= 0 )
	
	self._weight = weigth;
end


-------------------------------------------------------------------------------
--  DyzkData:GetWeight : Returns the weight of the DyzkData
-------------------------------------------------------------------------------
function DyzkData:GetWeight()
	return self._weight or 0;
end


-------------------------------------------------------------------------------
--  DyzkData:SetJaggedness : Sets the jaggedness of the DyzkData
-------------------------------------------------------------------------------
function DyzkData:SetJaggedness( jag )
	assert( jag >= 0 and jag <= 1 )
	
	self._jaggedness = jag;
end


-------------------------------------------------------------------------------
--  DyzkData:GetJaggedness : Returns the jaggedness of the DyzkData
-------------------------------------------------------------------------------
function DyzkData:GetJaggedness()
	return self._jaggedness or 0;
end


-------------------------------------------------------------------------------
--  DyzkData:SetBalance : Sets the balance of the DyzkData
-------------------------------------------------------------------------------
function DyzkData:SetMaxRadius( rad )
	assert( rad >= 0 )
	
	self._maxRadius = rad;
end


-------------------------------------------------------------------------------
--  DyzkData:GetMaxRadius : Returns the radius of the DyzkData
-------------------------------------------------------------------------------
function DyzkData:GetMaxRadius()
	return self._maxRadius or 0;
end


-------------------------------------------------------------------------------
--  DyzkData:SetBalance : Sets the balance of the DyzkData
-------------------------------------------------------------------------------
function DyzkData:SetBalance( balance )
	assert( balance >= 0 and balance <= 1)
	
	self._balance = balance;
end


-------------------------------------------------------------------------------
--  DyzkData:GetBalance : Returns the balance if the dyzk
-------------------------------------------------------------------------------
function DyzkData:GetBalance()
	return self._balance or 0;
end


-------------------------------------------------------------------------------
--  DyzkData:SetSpeed : Sets the control speed of the dyzk
-------------------------------------------------------------------------------
function DyzkData:SetSpeed( speed )
	assert( speed >= 0 )
	
	self._speed = speed;
end


-------------------------------------------------------------------------------
--  DyzkData:GetSpeed : Returns the control speed of the dyzk
-------------------------------------------------------------------------------
function DyzkData:GetSpeed()
	return self._speed or 0;
end


-------------------------------------------------------------------------------
--  DyzkData:SetMaxRadialVelocity : Sets the max angular velocity of the dyzk
-------------------------------------------------------------------------------
function DyzkData:SetMaxRadialVelocity( angVel )
	assert( angVel >= 0 )
	
	self._maxAngVel = angVel;
end


-------------------------------------------------------------------------------
--  DyzkData:GetMaxRadialVelocity : Returns the maximal dyzk angular velocity
-------------------------------------------------------------------------------
function DyzkData:GetMaxRadialVelocity()
	return self._maxAngVel or 0;
end


-------------------------------------------------------------------------------
--  DyzkData:CopyFromDyzkData : Sets the properties of this dyzk from another
-------------------------------------------------------------------------------
function DyzkData:CopyFromDyzkData( dyzkData )
	self:SetDyzkID( 				dyzkData:GetDyzkID() 				);
	self:SetImageName(				dyzkData:GetImageName()				);
	self:SetMaxRadius( 				dyzkData:GetMaxRadius() 			);
	self:SetJaggedness( 			dyzkData:GetJaggedness() 			);
	self:SetWeight( 				dyzkData:GetWeight() 				);
	self:SetBalance( 				dyzkData:GetBalance()				);
	self:SetSpeed( 					dyzkData:GetSpeed()					);
	self:SetMaxRadialVelocity( 		dyzkData:GetMaxRadialVelocity()		);
end


--===========================================================================--
--  Initialization
--===========================================================================--
return DyzkData