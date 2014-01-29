--===========================================================================--
--  Dependencies
--===========================================================================--


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class BlueIceSkin: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local BlueIceSkin = {}
BlueIceSkin.__index = BlueIceSkin;


-------------------------------------------------------------------------------
--  BlueIceSkin:new : Creates a new BlueIceSkin
-------------------------------------------------------------------------------
function BlueIceSkin:new()
	local obj = {}

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  BlueIceSkin:Load : Loads the necessary resources
-------------------------------------------------------------------------------
function BlueIceSkin:Load()
	self._buttonImg			= love.graphics.newImage( "data/gui/button.png" );
	self._textColor			= { 1,31,41 }
	self._captionFntSize	= 32;
	self._captionFnts		= {};
end


-------------------------------------------------------------------------------
--  BlueIceSkin:new : Creates a new BlueIceSkin
-------------------------------------------------------------------------------
function BlueIceSkin:DrawButton( button )
	local x, y 	= button:GetAbsPosition();
	local w, h 	= button:GetAbsSize();
	local text	= button:GetText();
	local imgW 	= self._buttonImg:getWidth();
	local imgH 	= self._buttonImg:getHeight();	
	
	-- Figure out the size of the font in respect to the size of the button
	local fntSizeH = h/1.6;
	local fntSizeW = w/8;	
	self._captionFntSize = math.floor( math.min(fntSizeH, fntSizeW) );
	
	-- Load the appropriate font font (if needed)
	if not self._captionFnts[ self._captionFntSize ] then
		self._captionFnts[ self._captionFntSize ] = 
			love.graphics.setNewFont( "data/gui/ace_futurism.ttf", self._captionFntSize );
	end
	
	-- Assign the correct font
	local font = self._captionFnts[ self._captionFntSize ];
	
	if button:IsPressed() then
		love.graphics.setColor( 0,255,0 );
	elseif button:IsSelected() then
		love.graphics.setColor( 255,0,0 );
	end
	
	-- draw!
	love.graphics.draw( self._buttonImg, x, y, 0, w/imgW, h/imgH );
	love.graphics.setColor( self._textColor );
	love.graphics.setFont( font );
	love.graphics.printf( text, x, y+h/2 -font:getHeight()/2 , w, "center" );
	love.graphics.setColor( 255,255,255 );
end


--===========================================================================--
--  Initialization
--===========================================================================--
return BlueIceSkin