--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class Camera : A camera class
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local Camera = {}
Camera.__index = Camera


-------------------------------------------------------------------------------
--  Camera:new : Creates a new camera
-------------------------------------------------------------------------------
function Camera:new()
	local obj = {}
	
	obj.x = 0;
	obj.y = 0;
	obj.z = 0;
	
	obj.xScale = 1;
	obj.yScale = 1;
	
	obj._trackedObject = {}
	obj._targetX = 0;
	obj._targetY = 0;
	
	obj._speed = 1.5;
	
	return setmetatable( obj, self );
end


-------------------------------------------------------------------------------
--  Camera:SetScale : Sets the camera scale
-------------------------------------------------------------------------------
function Camera:SetScale( xs, ys )
	self.xScale = xs;
	self.yScale = ys;
end


-------------------------------------------------------------------------------
--  Camera:AddTrackObject : Adds an object to be tracked
-------------------------------------------------------------------------------
function Camera:AddTrackObject( obj )
	self._trackedObject[ #self._trackedObject+1 ] = obj;
end


-------------------------------------------------------------------------------
--  Camera:Draw : Sets up the camera
-------------------------------------------------------------------------------
function Camera:Draw()
	love.graphics.push();
	love.graphics.translate( -self.x, -self.y );
	love.graphics.scale( self.xScale, self.yScale );
end


-------------------------------------------------------------------------------
--  Camera:PostDraw : Unsets the camera
-------------------------------------------------------------------------------
function Camera:PostDraw()
	love.graphics.pop();
end


-------------------------------------------------------------------------------
--  Camera:ScreenToWorld : Transforms screen to world coodrdiantes
-------------------------------------------------------------------------------
function Camera:ScreenToWorld( x,y )
	local wX, wY;
	
	wX = (x + self.x)/self.xScale
	wY = (y + self.y)/self.yScale
	
	return wX, wY;
end


-------------------------------------------------------------------------------
--  Camera:Update : Updates the camera
-------------------------------------------------------------------------------
function Camera:Update( dt )
	if #self._trackedObject>0 then
		local xMid, yMid = 0, 0;
		for i = 1, #self._trackedObject do
			local x, y = self._trackedObject[i]:GetPosition();
			xMid = xMid + x;
			yMid = yMid + y;
		end
		
		xMid = xMid/#self._trackedObject*self.xScale;
		yMid = yMid/#self._trackedObject*self.yScale;
		
		self._targetX = xMid - love.graphics.getWidth()/2;
		self._targetY = yMid - love.graphics.getHeight()/2;
				
		self.x = self.x - (self.x - self._targetX)*dt * self._speed;
		self.y = self.y - (self.y - self._targetY)*dt * self._speed;
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
return Camera