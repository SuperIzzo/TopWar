--===========================================================================--
--  Dependencies
--===========================================================================--
local Array 			= require 'src.util.Array'
local Vector 			= require 'src.math.Vector'

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
	local x = x/self._xScale
	local y = y/self._yScale

	return self._depthMask:Get( x, y );
end


-------------------------------------------------------------------------------
--  ArenaModel:GetNormal : Returns the normal at point x,y
-------------------------------------------------------------------------------
function ArenaModel:GetNormal( x, y )
	local x = x/self._xScale
	local y = y/self._yScale

	return self._normalMask:GetNormal( x, y );
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
		
		if norm[1] == 0 and norm[2] == 0 and norm[3] == 0 then
			dyzxOut = dyzxOut or Array:new();
			dyzxOut:Add( dyzk );
		else		
			local zScale = DEFAULT_ZSCALE * self._zScale
			dyzk:SetAcceleration( norm[1] * zScale, norm[2] * zScale );
		end
	end
	
	if dyzxOut then
		self:AnnounceOut( dyzxOut );
	end
	
	self:_DetectDyzxCollision();
	self:_DetectArenaCollision( dt );
end


-------------------------------------------------------------------------------
--  ArenaModel:_DetectDyzxCollision : Detects collision between dyzx
-------------------------------------------------------------------------------
function ArenaModel:_DetectDyzxCollision()
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
--  ArenaModel:_DetectArenaCollision : Detects collision the arena and a dyzx
-------------------------------------------------------------------------------
function ArenaModel:_DetectArenaCollision( dt )
	for i = 1, #self._dyzx do
		local dyzk = self._dyzx[i];
	
		local x, y	= dyzk:GetPosition();
		local rad	= dyzk:GetMaxRadius();
		local vel	= Vector:new( dyzk:GetVelocity() );
		local dir, speed = vel:Unit();
		
		local scanLineStart = -(speed * dt * 1.2);
		local scanLineLength = rad - scanLineStart;		
		
		local dyzkDepth = self:GetDepth( 
								x + dir.x*scanLineStart,
								y + dir.y*scanLineStart );
		local depthThresh = 1024 / self._zScale;
		
		for i = 0, 6 do
			local ratio = scanLineLength * i/6 + scanLineStart;
			
			local pos = dir * ratio;
			local arenaDepth = self:GetDepth(pos.x+x, pos.y+y);
			
			if arenaDepth - dyzkDepth > depthThresh then
				dyzk:OnArenaCollision( pos.x+x, pos.y+y, arenaDepth );
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