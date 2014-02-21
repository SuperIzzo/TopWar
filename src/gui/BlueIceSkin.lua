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
	self._panelImg			= love.graphics.newImage( "data/gui/panel.png" );
	
	self._textColor			= { 1,31,41 }
	self._captionFntSize	= 32;
	self._captionFnts		= {};
	
	self:SetupQuads();
end


-------------------------------------------------------------------------------
--  BlueIceSkin:SetupQuads : Setup quads
-------------------------------------------------------------------------------
function BlueIceSkin:SetupQuads()
	self._panelQuads = {}
	self._panelQuads[1] = {}
	self._panelQuads[2] = {}
	self._panelQuads[3] = {}
	
	local iW = self._panelImg:getWidth();
	local iH = self._panelImg:getHeight();
	local tW = iW/3;
	local tH = iH/3;
	
	for x = 1, 3 do
		for y = 1, 3 do
			self._panelQuads[x][y] = love.graphics.newQuad( 
				(x-1)*tW, (y-1)*tH, 
				tW,tH, 
				iW,iH )
		end
	end
end


-------------------------------------------------------------------------------
--  BlueIceSkin:DrawButton : Draws a button in this skin
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
	local captionFntSize = math.floor( math.min(fntSizeH, fntSizeW) );
	
	-- Load the appropriate font font (if needed)
	if not self._captionFnts[ captionFntSize ] then
		self._captionFnts[ captionFntSize ] = 
			love.graphics.setNewFont( "data/gui/ace_futurism.ttf", captionFntSize );
	end
	
	-- Assign the correct font
	local font = self._captionFnts[ captionFntSize ];
	
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


-------------------------------------------------------------------------------
--  BlueIceSkin:new : Creates a new BlueIceSkin
-------------------------------------------------------------------------------
function BlueIceSkin:DrawPanel( panel )
	local x, y 	= panel:GetAbsPosition();
	local w, h 	= panel:GetAbsSize();
	local imgW 	= self._panelImg:getWidth();
	local imgH 	= self._panelImg:getHeight();	
	
	local tileW = imgW/3;
	local tileH = imgH/3;
	
	local numHorTiles = math.max( 2, math.ceil( w/(tileW*0.8) ));
	local numVrtTiles = math.max( 2, math.ceil( h/(tileH*0.8) ));
	local horScale	  = w/ (numHorTiles * tileW);
	local vrtScale	  = h/ (numVrtTiles * tileH);
	
	local scaledTileW = tileW * horScale;
	local scaledTileH = tileH * vrtScale;
	
	for tx = 1, numHorTiles do
		for ty = 1, numVrtTiles do
			
			local quadX = 2;
			local quadY = 2;			
			if tx == 1 then
				quadX = 1;
			elseif tx == numHorTiles then
				quadX = 3;
			end
			
			if ty == 1 then
				quadY = 1;
			elseif ty == numVrtTiles then
				quadY = 3;
			end
			
			love.graphics.draw( 
					self._panelImg, 
					self._panelQuads[quadX][quadY],
					x + (tx-1)*scaledTileW, 
					y + (ty-1)*scaledTileH, 
					0, horScale, vrtScale )					
		end
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
return BlueIceSkin