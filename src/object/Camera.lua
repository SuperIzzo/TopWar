--===========================================================================--
--  Dependencies
--===========================================================================--
local Array					= require 'src.util.Array'


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
	
	obj.zoom 		 	= 1;
	obj.zoomInSpeed		= 1;
	obj.zoomOutSpeed	= 1;
	
	obj._minZoom		= 1;
	obj._maxZoom		= 1;
	obj._zoomPadding	= 0;
	
	obj._trackedObject = Array:new();
	obj._targetX = 0;
	obj._targetY = 0;
	obj._targetZoom = 0;
	
	obj._speed = 1.5;
	
	return setmetatable( obj, self );
end


-------------------------------------------------------------------------------
--  Camera:SetScale : Sets the camera scale
-------------------------------------------------------------------------------
function Camera:SetZoom( zoom )
	self.zoom = zoom;
end


-------------------------------------------------------------------------------
--  Camera:SetZoomSpeed : Sets the camera zoom speed
-------------------------------------------------------------------------------
function Camera:SetZoomSpeed( zoomIn, zoomOut )
	self.zoomInSpeed  = zoomIn;
	self.zoomOutSpeed = zoomOut;
end


-------------------------------------------------------------------------------
--  Camera:SetMinZoom : Sets the minimal camera zoom
-------------------------------------------------------------------------------
function Camera:SetMinZoom( zoom )
	self._minZoom	= zoom;
end


-------------------------------------------------------------------------------
--  Camera:SetMaxZoom : Sets the maximal camera zoom
-------------------------------------------------------------------------------
function Camera:SetMaxZoom( zoom )
	self._maxZoom	= zoom;
end


-------------------------------------------------------------------------------
--  Camera:AddTrackObject : Adds an object to be tracked
-------------------------------------------------------------------------------
function Camera:AddTrackObject( obj )
	self._trackedObject:Add( obj );
end


-------------------------------------------------------------------------------
--  Camera:RemoveTrackObject : Removes an object from the tracking list
-------------------------------------------------------------------------------
function Camera:RemoveTrackObject( obj )
	self._trackedObject:RemoveItem( obj );
end


-------------------------------------------------------------------------------
--  Camera:RemoveAllTrackObjects : Removes all objects from the tracking list
-------------------------------------------------------------------------------
function Camera:RemoveAllTrackObjects()
	self._trackedObject = Array:new();
end


-------------------------------------------------------------------------------
--  Camera:Draw : Sets up the camera
-------------------------------------------------------------------------------
function Camera:Draw()
	love.graphics.push();
	love.graphics.translate( -self.x, -self.y );
	love.graphics.scale( self.zoom, self.zoom );
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
	
	wX = (x + self.x)/self.zoom
	wY = (y + self.y)/self.zoom
	
	return wX, wY;
end


-------------------------------------------------------------------------------
--  Camera:Update : Updates the camera
-------------------------------------------------------------------------------
function Camera:Update( dt )
	if #self._trackedObject>0 then
		local xMin, yMin;
		local xMax, yMax;
		local xMid, yMid = 0, 0;
		
		for i = 1, #self._trackedObject do
			local x, y = self._trackedObject[i]:GetPosition();
			xMid = xMid + x;
			yMid = yMid + y;
			
			if not xMin or xMin>x then
				xMin = x;
			end
			
			if not yMin or yMin>y then
				yMin = y;
			end
			
			if not xMax or xMax<x then
				xMax = x;
			end
			
			if not yMax or yMax<y then
				yMax = y;
			end
		end
		
		local xDist = xMax - xMin;
		local yDist = yMax - yMin;
		local width  = love.graphics.getWidth();
		local height = love.graphics.getHeight();
		
		local xScale = xDist/width;
		local yScale = yDist/height;
		local scale = math.max( xScale, yScale );
		
		
		self._targetZoom = 0.6/scale;
		self._targetZoom = math.max( self._targetZoom, self._minZoom );
		self._targetZoom = math.min( self._targetZoom, self._maxZoom );
		
		local zoomDist = self._targetZoom - self.zoom;
		if zoomDist < 0 then
			self.zoom = self.zoom + zoomDist * self.zoomOutSpeed * dt;
		else
			self.zoom = self.zoom + zoomDist * self.zoomInSpeed * dt;
		end
		
		xMid = xMid/#self._trackedObject*self.zoom;
		yMid = yMid/#self._trackedObject*self.zoom;
		
		
		self._targetX = xMid - love.graphics.getWidth()/2;
		self._targetY = yMid - love.graphics.getHeight()/2;
				
		self.x = self.x - (self.x - self._targetX)*dt * self._speed/self.zoom;
		self.y = self.y - (self.y - self._targetY)*dt * self._speed/self.zoom;
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
return Camera