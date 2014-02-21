--===========================================================================--
--  Dependencies
--===========================================================================--
local BaseObject 			= require 'src.gui.BaseObject'


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class Button: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local Button = {}
Button.__index = setmetatable( Button, BaseObject );


-------------------------------------------------------------------------------
--  Button:new : Creates a new Button
-------------------------------------------------------------------------------
function Button:new()
	local obj = BaseObject:new();

	obj._text		= "";	

	return setmetatable(obj, self);
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
	local skin = self:GetSkin();
	
	if skin then
		skin:DrawButton( self );
	else
		local absX, absY = self:GetAbsPosition();
		local absW, absH = self:GetAbsSize();
		love.graphics.rectangle( "fill", absX, absY, absW, absH );
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
return Button