--===========================================================================--
--  Dependencies
--===========================================================================--
local Array 			= require 'src.util.collection.Array'
local Vector 			= require 'src.math.Vector'

local sqrt				= math.sqrt;
local abs				= math.abs;
local cos				= math.cos;
local sin				= math.sin;
local pi				= math.pi;



-------------------------------------------------------------------------------
--  CalculateRingVerts : An utility to calculates the vertices on a unit ring
-------------------------------------------------------------------------------
local function CalculateRingVerts( segments )
	local ring = {};
	
	for i = 1, segments do
		ring[i] = {
			x = cos(  (i-1)/segments * pi*2 );
			y = -sin( (i-1)/segments * pi*2 );
		}
	end
		
	return ring;
end


-------------------------------------------------------------------------------
--  Local Constants
-------------------------------------------------------------------------------
local DYZK_SURFACE_RING		= CalculateRingVerts(8);
local DYZK_DEPTH			= 32;


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

	return self._depthMask:Get( x, y ) * self._zScale;
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
	
	return self._xScale*width, self._yScale*height, self._zScale;
end


-------------------------------------------------------------------------------
--  ArenaModel:SetSize : Sets the size of the arena (scaling it)
-------------------------------------------------------------------------------
function ArenaModel:SetSize( w, h, d )
	self._xScale = w/self._normalMask:GetWidth();
	self._yScale = h/self._normalMask:GetHeight();
	self._zScale = d;
end


-------------------------------------------------------------------------------
--  ArenaModel:Update : Updates the velocity of all dyzx in the ArenaModel
-------------------------------------------------------------------------------
function ArenaModel:Update( dt )
	local dyzxOut;
	
	for dyzk in self._dyzx:Items() do
		local x,y	= dyzk:GetPosition();
		local depth	= self:GetDepth( x, y );
		local norm	= self:GetNormal( x, y );
		
		-- Normal data is redundant we know that it valid normals are
		-- always unit vectors, so we overload the zero vector to 
		-- indicate a hole, if a dyzk falls into it, we stage it for removal
		if norm[1] == 0 and norm[2] == 0 and norm[3] == 0 then			
			dyzxOut = dyzxOut or Array:new();
			dyzxOut:Add( dyzk );
			
		else
			local ringRad	= dyzk:GetRadius() * dyzk:GetPerspScale()/2;
			local ring		= DYZK_SURFACE_RING;
			
			-- We average each dyzk normal so that they feel more like discs 
			-- they contact the ground at multiple points and weight more
			-- towards the center
			for i =1, #ring do
				local radNorm = self:GetNormal( x + ring[i].x*ringRad,
												y + ring[i].y*ringRad );
												
				norm[1] = norm[1] + radNorm[1];
				norm[2] = norm[2] + radNorm[2];
				norm[3] = norm[3] + radNorm[3];
			end
			
			-- Average the sum
			norm[1] = norm[1]/(#ring+1);
			norm[2] = norm[2]/(#ring+1);
			norm[3] = norm[3]/(#ring+1);

			dyzk:SetArenaDepth( depth );
			dyzk:SetArenaNormal( norm[1], norm[2], norm[3] );			
		end
	end
	
	-- We remove the dyzx now to avoid messing up the previous loop
	if dyzxOut then
		self:AnnounceOut( dyzxOut );
	end
	
	-- Do some a bit detecting
	self:_DetectDyzxCollision( dt );
	self:_DetectArenaCollision( dt );
end


-------------------------------------------------------------------------------
--  ArenaModel:_DetectDyzxCollision : Detects collision between dyzx
-------------------------------------------------------------------------------
function ArenaModel:_DetectDyzxCollision( dt )
	-- TODO:	Move this detection to DyzkModel... 
	--		 	when we add more objects

	-- Go through all 2-dyzk pairs
	for i = 1, #self._dyzx-1 do
		for j = i+1, #self._dyzx do
			local dyzk1 = self._dyzx[i];
			local dyzk2 = self._dyzx[j];

			local x1, y1, z1 = dyzk1:GetPosition();
			local x2, y2, z2 = dyzk2:GetPosition();
			
			-- We treat dyzx as cylinders orthogonal cylinders,
			-- if they are on the same height we check them as circles
			-- This hit model doesn't take into account orientation
			-- but makes life so much easier...
			if abs( z1-z2 ) < DYZK_DEPTH then
				local rad1 = dyzk1:GetRadius() * dyzk1:GetPerspScale();
				local rad2 = dyzk2:GetRadius() * dyzk2:GetPerspScale();

				-- Circle-circle collision is quite simple:
				-- if the distance between the centers is lower than
				-- the sum of the radii then we have a collision
				if sqrt((x1-x2)^2 + (y1-y2)^2) < (rad1+rad2) then
					dyzk1:OnDyzkCollision( dyzk2, true );
					dyzk2:OnDyzkCollision( dyzk1, false );
				end
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
	
		local x, y, z	= dyzk:GetPosition();
		local rad		= dyzk:GetRadius() * dyzk:GetPerspScale();
		local vel		= Vector:new( dyzk:GetVelocity() );
		local dir, speed = vel:Unit();
		
		-- When testing for arena-dyzk collision out hit model
		-- is a straight line that goes trough the dyzk center 
		-- and is in the direction of the dyzk velocity
		-- The line actually starts a little behind the dyzk, compensating
		-- for the time delta
		-- TODO:	Shouldn't 'scanLineStart' start 'rad' earlier? 
		--			otherwise we are testing only half the dyzk
		local scanLineStart = -(speed * dt * 1.2);
		local scanLineLength = rad - scanLineStart;		
		
		-- The higher the dyzk is the more the threshold grows too
		local depthThresh = DYZK_DEPTH * dyzk:GetPerspScale();
		
		for i = 0, 6 do
			local ratio = scanLineLength * i/6 + scanLineStart;
			
			local pos = dir * ratio;
			local arenaDepth = self:GetDepth(pos.x+x, pos.y+y);
			
			if arenaDepth - z > depthThresh then
				dyzk:OnArenaCollision( pos.x+x, pos.y+y, arenaDepth );
			end
		end
	end
end


-------------------------------------------------------------------------------
--  ArenaModel:AnnounceOut : Announces arena out events
-------------------------------------------------------------------------------
function ArenaModel:AnnounceOut( dyzx )
	-- Announce all dyzx in the table out 
	-- (note: dyzx is plural, dyzk singular)
	for dyzk in Array.Items( dyzx ) do
		dyzk:OnArenaOut();
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
return ArenaModel