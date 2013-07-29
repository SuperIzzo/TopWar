--===========================================================================--
--  Dependencies
--===========================================================================--


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class SceneManager : Selection scene 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local SceneManager = {}
SceneManager.__index = SceneManager


-------------------------------------------------------------------------------
--  SceneManager_new : Creates a new scene manager
-------------------------------------------------------------------------------
local function SceneManager_new()
	local obj = {}
	
	obj._currentScene = nil;
	
	return setmetatable( obj, SceneManager );
end


-------------------------------------------------------------------------------
--  SceneManager:GetInstance : Returns the scene manager instace
-------------------------------------------------------------------------------
local sceneManager
function SceneManager:GetInstance()
	if not sceneManager then
		sceneManager = SceneManager_new();
	end
	
	return sceneManager;
end


-------------------------------------------------------------------------------
--  SceneManager:SetScene : Changes the current scene
-------------------------------------------------------------------------------
function SceneManager:SetScene( scene )
	self:Leave();
	self._currentScene = scene;
	self:Init();
end


-------------------------------------------------------------------------------
--  SceneManager:GetScene : Returns the current scene
-------------------------------------------------------------------------------
function SceneManager:GetScene()
	return self._currentScene;
end


-------------------------------------------------------------------------------
--  SceneManager:Init : Initializes the current scene
-------------------------------------------------------------------------------
function SceneManager:Init()
	if self._currentScene and self._currentScene.Init then
		self._currentScene:Init();
	end
end


-------------------------------------------------------------------------------
--  SceneManager:Leave : Leaves the current scene
-------------------------------------------------------------------------------
function SceneManager:Leave()
	if self._currentScene and self._currentScene.Leave then
		self._currentScene:Leave();
	end
end


-------------------------------------------------------------------------------
--  SceneManager:Draw : Draws the current scene
-------------------------------------------------------------------------------
function SceneManager:Draw()
	if self._currentScene and self._currentScene.Draw then
		self._currentScene:Draw();
	end
end


-------------------------------------------------------------------------------
--  SceneManager:Update : Updates the current scene
-------------------------------------------------------------------------------
function SceneManager:Update( dt )
	if self._currentScene and self._currentScene.Update then
		self._currentScene:Update( dt );
	end
end


-------------------------------------------------------------------------------
--  SceneManager:Control : Handles controls in the current scene
-------------------------------------------------------------------------------
function SceneManager:Control( control )
	if self._currentScene and self._currentScene.Control then
		self._currentScene:Control( control );
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
return SceneManager
