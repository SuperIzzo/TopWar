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
			
		self.x = xMid - love.graphics.getWidth()/2;
		self.y = yMid - love.graphics.getHeight()/2;
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
return Camera