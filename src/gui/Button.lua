--===========================================================================--
--  Dependencies
--===========================================================================--


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class Button: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local Button = {}
Button.__index = Button;


-------------------------------------------------------------------------------
--  Button:new : Creates a new Button
-------------------------------------------------------------------------------
function Button:new()
	local obj = {}
	
	-- Class defaults
	self._x = self._x or 0;
	self._y = self._y or 0;
	self._w = self._w or 0;
	self._h = self._h or 0;
	
	self._relX = self._relX or false;
	self._relY = self._relY or false;
	self._relW = self._relW or false;
	self._relH = self._relH or false;

	obj._text		= "";
	obj._selected	= false;
	obj._pressed	= false;
	

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  Button:SetSkin : Sets the skin of the button
-------------------------------------------------------------------------------
function Button:SetSkin( skin )
	self._skin = skin;
end


-------------------------------------------------------------------------------
--  Button:Select : Select the button
-------------------------------------------------------------------------------
function Button:Select()
	self._selected = true;
end


-------------------------------------------------------------------------------
--  Button:Deselect : Deselects the button
-------------------------------------------------------------------------------
function Button:Deselect()
	self._selected = false;
end


-------------------------------------------------------------------------------
--  Button:IsSelected : Returns whether the button has been selected
-------------------------------------------------------------------------------
function Button:IsSelected()
	return self._selected;
end


-------------------------------------------------------------------------------
--  Button:Press : Presses the button down
-------------------------------------------------------------------------------
function Button:Press()
	self._pressed = true;
end


-------------------------------------------------------------------------------
--  Button:Release : Releases the button press
-------------------------------------------------------------------------------
function Button:Release()
	self._pressed = false;
	if self.OnClick then
		self:OnClick()
	end
end


-------------------------------------------------------------------------------
--  Button:IsPressed : Returns whether the button has been pressed down
-------------------------------------------------------------------------------
function Button:IsPressed()
	return self._pressed;
end


-------------------------------------------------------------------------------
--  Button:SetPosition : Sets the position of the button
-------------------------------------------------------------------------------
function Button:SetPosition(x,y)
	self._x = x;
	self._y = y;
	self._relX = (x>=0 and x<=1);
	self._relY = (y>=0 and y<=1);
end


-------------------------------------------------------------------------------
--  Button:GetAbsPosition : Returns the absolute position of the button
-------------------------------------------------------------------------------
function Button:GetAbsPosition()
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
--  Button:SetSize : Sets the size of the button
-------------------------------------------------------------------------------
function Button:SetSize(w,h)
	self._w = w;
	self._h = h;
	self._relW = (w>=0 and w<=1);
	self._relH = (h>=0 and h<=1);
end


-------------------------------------------------------------------------------
--  Button:GetAbsSize : Returns the absolute size of the button
-------------------------------------------------------------------------------
function Button:GetAbsSize()
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


-------------------------------------------------------------------------------
--  Button:SetText : Sets the text of the button
-------------------------------------------------------------------------------
function Button:SetText( text )
	self._text = text;
end


-------------------------------------------------------------------------------
--  Button:GetText : Returns the text of the button
-------------------------------------------------------------------------------
function Button:GetText()
	return self._text;
end


-------------------------------------------------------------------------------
--  Button:Draw : Draws the button
-------------------------------------------------------------------------------
function Button:Draw()
	if self._skin then
		self._skin:DrawButton( self );
	else
		local absX, absY = self:GetAbsPosition();
		local absW, absH = self:GetAbsSize();
		love.graphics.rectangle( "fill", absX, absY, absW, absH );
	end
end


-------------------------------------------------------------------------------
--  Button:IsHit : Returns true if the button is hit at the given coordinates
-------------------------------------------------------------------------------
function Button:IsHit( xPoint, yPoint )
	local w, h		= self:GetAbsSize()
	local x1, y1	= self:GetAbsPosition()
	local x2, y2	= x1+w, y1+h;
	
	return 	xPoint>x1 and xPoint<x2 and yPoint>y1 and yPoint<y2;
end


--===========================================================================--
--  Initialization
--===========================================================================--
return Button