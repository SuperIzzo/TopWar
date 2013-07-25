--===========================================================================--
--  Dependencies
--===========================================================================--
local Arena				= require 'src.game.object.Arena'
local Dyzk				= require 'src.game.object.Dyzk'
local Camera			= require 'src.game.object.Camera'
local BattleController	= require 'src.game.input.BattleController'



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class ScBattle : Battle scene 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local ScBattle = {}


-------------------------------------------------------------------------------
--  ScBattle:Init : Initializes the scene
-------------------------------------------------------------------------------
function ScBattle:Init()
	
	self.dyzk1 = Dyzk:new("data/dyzx/DyzkAA001.png");
	self.dyzk1.phDyzk.x = 100;
	self.dyzk1.phDyzk.y = 100;
	self.dyzk1.phDyzk.vx = 10;
	self.dyzk1.phDyzk.vy = 10;
	self.dyzk1.phDyzk.angVel = 3600;
	
	self.dyzk2 = Dyzk:new("data/dyzx/DyzkAA002.png");
	self.dyzk2.phDyzk.x = 924;
	self.dyzk2.phDyzk.y = 924;
	self.dyzk2.phDyzk.vx = -10;
	self.dyzk2.phDyzk.vy = -10;
	self.dyzk2.phDyzk.angVel = 3600;
	
	self.arena = Arena:new("data/arena/arena_mask2.png");
	self.arena:AddDyzk( self.dyzk1 );
	self.arena:AddDyzk( self.dyzk2 );
	self.arena:SetScale(2,2,4);
	
	self.camera = Camera:new();
	self.camera:SetScale( 0.5, 0.5 );
	self.camera:AddTrackObject( self.dyzk1:GetPhysicsBody() );
	self.camera:AddTrackObject( self.dyzk2:GetPhysicsBody() );
	
	self.controller1 = BattleController:new( 1, self.dyzk1:GetPhysicsBody() );
	self.controller2 = BattleController:new( 2, self.dyzk2:GetPhysicsBody() );
	
end


-------------------------------------------------------------------------------
--  ScBattle:Update : Updates the scene
-------------------------------------------------------------------------------
function ScBattle:Update( dt )
	self.camera:Update( dt );
	self.arena:Update( dt );
	self.dyzk1:Update( dt );
	self.dyzk2:Update( dt );
end


-------------------------------------------------------------------------------
--  ScBattle:Draw : Draws the scene
-------------------------------------------------------------------------------
function ScBattle:Draw()
	self.camera:Draw();
	self.arena:Draw();
	self.dyzk1:Draw();
	self.dyzk2:Draw();
	
	self.camera:PostDraw();
end


-------------------------------------------------------------------------------
--  ScBattle:Control : Handle input event
-------------------------------------------------------------------------------
function ScBattle:Control( control )
	self.controller1:Control( control );
	self.controller2:Control( control );
end


--===========================================================================--
--  Initialization
--===========================================================================--
return ScBattle;