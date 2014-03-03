--===========================================================================--
--  Dependencies
--===========================================================================--
local MathUtils 		= require 'src.math.MathUtils'
local Array 			= require 'src.util.Array'

local clamp				= MathUtils.Clamp;
local bilerp			= MathUtils.Bilerp;
local floor				= math.floor
local ceil				= math.ceil
local sqrt				= math.sqrt



local DEFAULT_ZSCALE	= 256;


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class ArenaModel : The physical data and logic of a battle arena
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local ArenaModel = {}
ArenaModel.__index = ArenaModel;


-------------------------------------------------------------------------------
--  ArenaModel:new : Creates a new ArenaModel
-------------------------------------------------------------------------------
function ArenaModel:new()
	local obj = {}
	
	obj._depthMask = nil;
	obj._normalMask = nil;
	obj._dyzx = Array:new()
	obj._xScale = 1;
	obj._yScale = 1;
	obj._zScale = 1;
	
	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  ArenaModel:SetDepthMask : Sets the depth mask of the ArenaModel
-------------------------------------------------------------------------------
function ArenaModel:SetDepthMask( mask )
	self._depthMask = mask;
end


-------------------------------------------------------------------------------
--  ArenaModel:SetNormalMask : Sets the normal mask of the ArenaModel
-------------------------------------------------------------------------------
function ArenaModel:SetNormalMask( mask )
	self._normalMask = mask;
end


-------------------------------------------------------------------------------
--  ArenaModel:GetDepth : Returns the depth at point x,y
-------------------------------------------------------------------------------
function ArenaModel:GetDepth( x, y )
	local result = {};
	
	result.x = 0;
	result.y = 0;
	result.z = 0;
	
	print( "WARNING: Unimplemented function ArenaModel:GetDepth" );
	
	return result;
end


-------------------------------------------------------------------------------
--  ArenaModel:GetNormal : Returns the normal at point x,y
-------------------------------------------------------------------------------
function ArenaModel:GetNormal( x, y )
	local result = {}

	local normMask = self._normalMask

	local width = normMask:GetWidth();
	local height = normMask:GetHeight();
		
	local x = x/self._xScale
	local y = y/self._yScale
	
	if x>=0 and x<=width-2 and y>=0 and y<=height-2 then
		local ax, ay = floor(x), floor(y);
		local bx, by = ax+1, ay+1;
		local t1, t2 = x - ax, y - ay;
		
		local n00_x, n00_y, n00_z = unpack( normMask:Get(ax,ay) );
		local n01_x, n01_y, n01_z = unpack( normMask:Get(ax,by) );
		local n10_x, n10_y, n10_z = unpack( normMask:Get(bx,ay) );
		local n11_x, n11_y, n11_z = unpack( normMask:Get(bx,by) );
		
		local nx = bilerp( n00_x, n01_x, n10_x, n11_x, t1, t2 );
		local ny = bilerp( n00_y, n01_y, n10_y, n11_y, t1, t2 );
		local nz = bilerp( n00_z, n01_z, n10_z, n11_z, t1, t2 );
		
		
		result.x = (nx-127)/255;
		result.y = (ny-127)/255;
		result.z = nz/255;
	else
		result.x = 0;
		result.y = 0;
		result.z = 0;
	end
	
	return result;
end


-------------------------------------------------------------------------------
--  ArenaModel:AddDyzk : Adds a dyzk to the ArenaModel
-------------------------------------------------------------------------------
function ArenaModel:AddDyzk( dyzk )
	self._dyzx:Add( dyzk );
end


-------------------------------------------------------------------------------
--  ArenaModel:RemoveDyzk : Removes a dyzk to the ArenaModel
-------------------------------------------------------------------------------
function ArenaModel:RemoveDyzk( dyzk )
	self._dyzx:RemoveItem( dyzk );
end


-------------------------------------------------------------------------------
--  ArenaModel:RemoveAllDyzx : Removes all dyzx from the arena
-------------------------------------------------------------------------------
function ArenaModel:RemoveAllDyzx()
	self._dyzx = Array:new()
end


-------------------------------------------------------------------------------
--  ArenaModel:Dyzx : Returns an iterator to all dyzx in the arena
-------------------------------------------------------------------------------
function ArenaModel:Dyzx()
	return self._dyzx:Items()
end


-------------------------------------------------------------------------------
--  ArenaModel:SetScale : Sets the arena scale
-------------------------------------------------------------------------------
function ArenaModel:SetScale(x,y,z)
	self._xScale, self._yScale, self._zScale  =  x,y,z;
end


-------------------------------------------------------------------------------
--  ArenaModel:GetScale : Returns the scale of the arena
-------------------------------------------------------------------------------
function ArenaModel:GetScale()
	return self._xScale, self._yScale, self._zScale
end


-------------------------------------------------------------------------------
--  ArenaModel:GetSize : Returns the size of the arena (scaled)
-------------------------------------------------------------------------------
function ArenaModel:GetSize()
	local width = self._normalMask:GetWidth();
	local height = self._normalMask:GetHeight();
	
	return self._xScale*width, self._yScale*height, 255*self._zScale;
end


-------------------------------------------------------------------------------
--  ArenaModel:SetSize : Sets the size of the arena (scaling it)
-------------------------------------------------------------------------------
function ArenaModel:SetSize( w, h, d )
	self._xScale = w/self._normalMask:GetWidth();
	self._yScale = h/self._normalMask:GetHeight();
	self._zScale = d/255;
end


-------------------------------------------------------------------------------
--  ArenaModel:Update : Updates the velocity of all dyzx in the ArenaModel
-------------------------------------------------------------------------------
function ArenaModel:Update( dt )
	local dyzxOut;
	
	for dyzk in self._dyzx:Items() do
		local norm = self:GetNormal( dyzk.x, dyzk.y );
		
		if norm.x == 0 and norm.y == 0 and norm.z == 0 then
			dyzxOut = dyzxOut or Array:new();
			dyzxOut:Add( dyzk );
		else		
			local zScale = DEFAULT_ZSCALE * self._zScale
			dyzk:SetAcceleration( norm.x * zScale, norm.y * zScale );
		end
	end
	
	if dyzxOut then
		self:AnnounceOut( dyzxOut );
	end
	
	self:DetectCollision();
end


-------------------------------------------------------------------------------
--  ArenaModel:DetectCollision : Detects collision between tops
-------------------------------------------------------------------------------
function ArenaModel:DetectCollision()
	for i = 1, #self._dyzx-1 do
		for j = i+1, #self._dyzx do			
			local dyzk1 = self._dyzx[i];
			local dyzk2 = self._dyzx[j];

			local x1, y1 = dyzk1:GetPosition();
			local x2, y2 = dyzk2:GetPosition();
			local rad1 = dyzk1:GetMaxRadius();
			local rad2 = dyzk2:GetMaxRadius();

			if sqrt((x1-x2)^2 + (y1-y2)^2) < (rad1+rad2) then
				dyzk1:OnDyzkCollision( dyzk2, true );
				dyzk2:OnDyzkCollision( dyzk1, false );
			end
		end
	end
end


-------------------------------------------------------------------------------
--  ArenaModel:AnnounceOut : Announces arena out events
-------------------------------------------------------------------------------
function ArenaModel:AnnounceOut( dyzx )
	for dyzk in Array.Items( dyzx ) do
		dyzk:OnArenaOut();
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
return ArenaModel