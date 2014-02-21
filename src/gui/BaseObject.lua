--===========================================================================--
--  Dependencies
--===========================================================================--



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class BaseObject: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local BaseObject = {}
BaseObject.__index = BaseObject;


-------------------------------------------------------------------------------
--  BaseObject:new : Creates a new BaseObject
-------------------------------------------------------------------------------
function BaseObject:new()
	local obj = {}

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  BaseObject:new : Creates a new BaseObject
-------------------------------------------------------------------------------
function BaseObject:new()
	local obj = {}
	
	-- Class defaults
	self._x 		= self._x or 0;
	self._y 		= self._y or 0;
	self._w 		= self._w or 0;
	self._h 		= self._h or 0;
	
	self._relX 		= self._relX or false;
	self._relY 		= self._relY or false;
	self._relW 		= self._relW or false;
	self._relH 		= self._relH or false;
	
	self._selected	= false;
	self._pressed	= false;

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  BaseObject:SetSkin : Sets the skin of the base object
-------------------------------------------------------------------------------
function BaseObject:SetSkin( skin )
	self._skin = skin;
end


-------------------------------------------------------------------------------
--  BaseObject:SetSkin : Sets the skin of the base object
-------------------------------------------------------------------------------
function BaseObject:GetSkin()
	return self._skin;
end


-------------------------------------------------------------------------------
--  BaseObject:Select : Select the base object
-------------------------------------------------------------------------------
function BaseObject:Select()
	self._selected = true;
end


-------------------------------------------------------------------------------
--  BaseObject:Deselect : Deselects the base object
-------------------------------------------------------------------------------
function BaseObject:Deselect()
	self._selected = false;
end


-------------------------------------------------------------------------------
--  BaseObject:IsSelected : Returns whether the base object has been selected
-------------------------------------------------------------------------------
function BaseObject:IsSelected()
	return self._selected;
end


-------------------------------------------------------------------------------
--  BaseObject:Press : Presses the base object down
-------------------------------------------------------------------------------
function BaseObject:Press()
	self._pressed = true;
end


-------------------------------------------------------------------------------
--  BaseObject:Release : Releases the base object press
-------------------------------------------------------------------------------
function BaseObject:Release()
	self._pressed = false;
	if self.OnClick then
		self:OnClick()
	end
end


-------------------------------------------------------------------------------
--  BaseObject:IsPressed : Returns whether the base object has been pressed down
-------------------------------------------------------------------------------
function BaseObject:IsPressed()
	return self._pressed;
end


-------------------------------------------------------------------------------
--  BaseObject:IsHit : Returns true if the object is hit at the given coords
-------------------------------------------------------------------------------
function BaseObject:IsHit( xPoint, yPoint )
	local w, h		= self:GetAbsSize()
	local x1, y1	= self:GetAbsPosition()
	local x2, y2	= x1+w, y1+h;
	
	return 	xPoint>x1 and xPoint<x2 and yPoint>y1 and yPoint<y2;
end


-------------------------------------------------------------------------------
--  BaseObject:SetPosition : Sets the position of the base object
-------------------------------------------------------------------------------
function BaseObject:SetPosition(x,y)
	self._x = x;
	self._y = y;
	self._relX = (x>=0 and x<=1);
	self._relY = (y>=0 and y<=1);
end


-------------------------------------------------------------------------------
--  BaseObject:GetAbsPosition : Returns the absolute position of the object
-------------------------------------------------------------------------------
function BaseObject:GetAbsPosition()
	local absX = self._x;
	local absY = self._y;
	
	if self._relX then
		absX = absX * love.graphics.getWidth();
	end
	
	if self._relY then
		absY = absY * love.graphics.getHeight();
	end
	
	return absX, absY;
end


-------------------------------------------------------------------------------
--  BaseObject:SetSize : Sets the size of the base object
-------------------------------------------------------------------------------
function BaseObject:SetSize(w,h)
	self._w = w;
	self._h = h;
	self._relW = (w>=0 and w<=1);
	self._relH = (h>=0 and h<=1);
end


-------------------------------------------------------------------------------
--  BaseObject:GetAbsSize : Returns the absolute size of the base object
-------------------------------------------------------------------------------
function BaseObject:GetAbsSize()
	local absW = self._w;
	local absH = self._h;
	
	if self._relW then
		absW = absW * love.graphics.getWidth();
	end
	
	if self._relH then
		absH = absH * love.graphics.getHeight();
	end
	
	return absW, absH;
end


--===========================================================================--
--  Initialization
--===========================================================================--
return BaseObject;