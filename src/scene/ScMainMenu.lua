--===========================================================================--
--  Dependencies
--===========================================================================--
local SceneManager 		= require 'src.scene.SceneManager'
local Button			= require 'src.gui.Button'
local BlueIceSkin		= require 'src.gui.BlueIceSkin'
local GUI				= require 'src.gui.GUI'



-------------------------------------------------------------------------------
--  ChangeToSceneFB : An utility function that creates a change to scene func
-------------------------------------------------------------------------------
local function ChangeToSceneFB( scene )

	-- Note: this is the button.OnClick function signature
	return function( object )
		local sceneMgr = SceneManager:GetInstance();
		sceneMgr:SetScene( scene );
	end
	
end



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class ScMainMenu : The main menu scene
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local ScMainMenu = {}
ScMainMenu.__index = ScMainMenu


-------------------------------------------------------------------------------
--  ScMainMenu:new : Creates a new main menu scene
-------------------------------------------------------------------------------
function ScMainMenu:new()
	local obj = {}	
	
	return setmetatable( obj, self );
end


-------------------------------------------------------------------------------
--  ScMainMenu:Init : Initializes the main menu scene
-------------------------------------------------------------------------------
function ScMainMenu:Init()
	self.giantDyzk = self.giantDyzk or
		love.graphics.newImage( "data/gui/IceDyzk.png" );
		
	love.graphics.setBackgroundColor( 5, 30, 40, 1 );
	
	self.particle1 	= love.graphics.newImage( "data/gui/ice_particle.png");
	self.skin = BlueIceSkin:new();
	self.skin:Load();
	
	
	local numPart = 1.5;
	
	self.partSystem1 = love.graphics.newParticleSystem(self.particle1, numPart*150);
	self.partSystem1:setEmissionRate( numPart*2 );
	self.partSystem1:setSpeed( 30, 40 );
	self.partSystem1:setParticleLifetime( 50 );
	self.partSystem1:setSpread( math.pi );
	self.partSystem1:setSizes( 0.01, 2 );
	self.partSystem1:setRotation( 0, math.pi*2 )
	self.partSystem1:setSpin( -0.2, 0.2 );
	self.partSystem1:setSpinVariation( 6 );
	self.partSystem1:setColors( 
		{13, 112, 106, 125 } )
	self.partSystem1:start()
	
	
	self.partSystem2 = love.graphics.newParticleSystem(self.particle1, numPart*80);
	self.partSystem2:setEmissionRate( numPart*2 );
	self.partSystem2:setSpeed( 40, 60 );
	self.partSystem2:setParticleLifetime( 40 );
	self.partSystem2:setSpread( math.pi*0.4 );
	self.partSystem2:setSizes( 0.1, 2 );
	self.partSystem2:setRotation( 0, math.pi*2 )
	self.partSystem2:setSpin( -0.2, 0.2 );
	self.partSystem2:setSpinVariation( 6 );
	self.partSystem2:setColors( 
		{120, 212, 206, 125 } )
	self.partSystem2:start()
	
	
	self.partSystem3 = love.graphics.newParticleSystem(self.particle1, numPart*60);
	self.partSystem3:setEmissionRate( numPart*1 );
	self.partSystem3:setSpeed( 30, 40 );
	self.partSystem3:setParticleLifetime( 60 );
	self.partSystem3:setSpread( math.pi*0.6 );
	self.partSystem3:setSizes( 2, 10 );
	self.partSystem3:setRotation( 0, math.pi*2 )
	self.partSystem3:setSpin( -0.2, 0.2 );
	self.partSystem3:setSpinVariation( 6 );
	self.partSystem3:setColors( {120, 212, 206, 80 } )
	self.partSystem2:start()
	
	
	-- Give the system a head start
	for i=0,100 do
		self.partSystem1:update( 0.3 )
		self.partSystem2:update( 0.3 )
		self.partSystem3:update( 0.5 )
	end
	
	self.gui = self.gui or self:CreateGUI();
end


-------------------------------------------------------------------------------
--  ScMainMenu:Leave : De-initializes the main menu scene
-------------------------------------------------------------------------------
function ScMainMenu:Leave()
end


-------------------------------------------------------------------------------
--  ScMainMenu:Draw : Draws the main menu scene
-------------------------------------------------------------------------------
local i = 0;
function ScMainMenu:Draw()

	i = i+0.001;
	
	local windowW	= love.graphics.getWidth()
	local windowH	= love.graphics.getHeight()
	local imageW 	= self.giantDyzk:getWidth();	
	local imageH 	= self.giantDyzk:getHeight();

	
	self.gui:Draw();	
	
	local scale = windowH/imageH *1.5;
	local offset = windowH - windowW;
	if offset <0 then
		offset = 0;
	else
		offset = offset*0.8;
	end
	
	love.graphics.setBlendMode( "additive" );
	love.graphics.draw(self.partSystem2, -offset, love.graphics.getHeight()/2 );
	love.graphics.draw(self.partSystem3, -offset, love.graphics.getHeight()/2 );
	love.graphics.setBlendMode( "alpha" );
	
	
	love.graphics.draw( self.giantDyzk,
			-offset, love.graphics.getHeight()/2,
			i, 
			scale, scale,
			self.giantDyzk:getWidth()/2,
			self.giantDyzk:getHeight()/2 );
		
	love.graphics.draw(self.partSystem1, -offset, love.graphics.getHeight()/2 );
end


-------------------------------------------------------------------------------
--  ScMainMenu:Update : Updates the main menu scene
-------------------------------------------------------------------------------
function ScMainMenu:Update( dt )
	self.partSystem1:update(dt)
	self.partSystem2:update(dt)
	self.partSystem3:update(dt)
end


-------------------------------------------------------------------------------
--  ScMainMenu:Control : React to input controls
-------------------------------------------------------------------------------
function ScMainMenu:Control( control )
	self.gui:Control( control );
end


-------------------------------------------------------------------------------
--  CreateGUI : Sets up the gui
-------------------------------------------------------------------------------
function ScMainMenu:CreateGUI()
	local scrWidth	= love.graphics.getWidth();
	local scrHeight	= love.graphics.getHeight();
	
	local gui = GUI:new();

	local btnPlay = gui:Create( Button );
	btnPlay:SetPosition( 0.35, 2/8 );
	btnPlay:SetSize( 0.5, 0.1 );
	btnPlay:SetSkin( self.skin );
	btnPlay:SetText( "Play" );
	btnPlay:Select();
	btnPlay.OnClick = ChangeToSceneFB( "Battle" );

	local btnCollection = gui:Create( Button );
	btnCollection:SetPosition( 0.4, 3/8 );
	btnCollection:SetSize( 0.5, 0.1 );
	btnCollection:SetSkin( self.skin );
	btnCollection:SetText( "Collection" );
	btnCollection.OnClick = ChangeToSceneFB( "Collection" );

	local meh = gui:Create( Button );
	meh:SetPosition( 0.45, 4/8 );
	meh:SetSize( 0.5, 0.1 );
	meh:SetSkin( self.skin );
	meh:SetText( "meh" );
	
	gui:Link( "down", btnPlay, 			btnCollection );
	gui:Link( "down", btnCollection, 	meh );
	gui:Link( "down", meh, 				btnPlay );
	
	gui:SetDefaultObject( btnPlay );

	return gui;
end


--===========================================================================--
--  Initialization
--===========================================================================--
return ScMainMenu;