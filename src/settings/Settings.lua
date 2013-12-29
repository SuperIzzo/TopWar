--===========================================================================--
--  Dependencies
--===========================================================================--
local ControlBox 	= require 'src.input.ControlBox'
local Trigger	 	= require 'src.input.TriggerType'

-- Note: Separate in multiple classes when it grows - raphics, input, sound...



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class Settings: Game settings management class
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local Settings = {}
Settings.__index = Settings


-------------------------------------------------------------------------------
--  Settings:new : Creates a settings object
-------------------------------------------------------------------------------
function Settings:new()
	local obj = {}
	
	return setmetatable( obj, self );
end


-------------------------------------------------------------------------------
--  Settings_LoadConfig : Loads the love configurations
-------------------------------------------------------------------------------
local function Settings_LoadConfig()
	Settings._config = nil
	
	if love.conf then
		local gameConf	 = {}
		gameConf.window  = {}
		gameConf.modules = {}
		
		-- For backwards compatibility
		gameConf.screen  = gameConf.window
	
		love.conf( gameConf );		
		
		Settings._config = gameConf;
	end
end


-------------------------------------------------------------------------------
--  Settings:GetConfig : Returns a configuration setting
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
--  If a 'name' has been given returns the config with the given name, 
--  otherwise it returns the configuration table.
--	If a configuration table has not been loaded or the config option does not
--  exist it will return `nil'
-------------------------------------------------------------------------------
function Settings:GetConfig( name )
	if self._config then		
		if name then
			return self._config[ name ];
		else
			return self._config;
		end		
	end	
end


-------------------------------------------------------------------------------
--  Settings:LoadDefaultControls : Loads teh default controls
-------------------------------------------------------------------------------
function Settings:LoadDefaultControls( box )
	local p1Box = box;
	p1Box.player = 1

	local xAxis1	= p1Box:CreateControl("xAxis");
	xAxis1:SetValue(0);
	xAxis1:Bind'Joy1Axis'( 1, 	Trigger.SLIDER(false) 						);
	xAxis1:Bind'Key'( 'a', 		Trigger.SWITCH_TO_SPRING(false, -1, 0) 	);
	xAxis1:Bind'Key'( 'd', 		Trigger.SWITCH_TO_SPRING(false,  1, 0) 	);
	xAxis1:Bind'Joy1Hat'( 'l1', Trigger.SWITCH_TO_SPRING(false, -1, 0) 	);
	xAxis1:Bind'Joy1Hat'( 'lu1',Trigger.SWITCH_TO_SPRING(false, -1, 0)  );
	xAxis1:Bind'Joy1Hat'( 'ld1',Trigger.SWITCH_TO_SPRING(false, -1, 0)  );
	xAxis1:Bind'Joy1Hat'( 'r1', Trigger.SWITCH_TO_SPRING(false,  1, 0) 	);
	xAxis1:Bind'Joy1Hat'( 'ru1',Trigger.SWITCH_TO_SPRING(false,  1, 0)  );
	xAxis1:Bind'Joy1Hat'( 'rd1',Trigger.SWITCH_TO_SPRING(false,  1, 0)  );
	xAxis1:Bind'Update'( 1, 	Trigger.ALWAYS() 						);

	local yAxis1	= p1Box:CreateControl("yAxis");
	yAxis1:SetValue(0);
	yAxis1:Bind'Joy1Axis'( 2, 	Trigger.SLIDER(false) 					);
	yAxis1:Bind'Key'( 'w', 		Trigger.SWITCH_TO_SPRING(false, -1, 0) 	);
	yAxis1:Bind'Key'( 's', 		Trigger.SWITCH_TO_SPRING(false,  1, 0) 	);
	yAxis1:Bind'Joy1Hat'( 'u1', Trigger.SWITCH_TO_SPRING(false, -1, 0) 	);
	yAxis1:Bind'Joy1Hat'( 'ru1',Trigger.SWITCH_TO_SPRING(false, -1, 0)  );
	yAxis1:Bind'Joy1Hat'( 'lu1',Trigger.SWITCH_TO_SPRING(false, -1, 0)  );
	yAxis1:Bind'Joy1Hat'( 'd1', Trigger.SWITCH_TO_SPRING(false,  1, 0) 	);
	yAxis1:Bind'Joy1Hat'( 'rd1',Trigger.SWITCH_TO_SPRING(false,  1, 0)  );
	yAxis1:Bind'Joy1Hat'( 'ld1',Trigger.SWITCH_TO_SPRING(false,  1, 0)  );
	yAxis1:Bind'Update'( 1, 	Trigger.ALWAYS() 						);

	local A1		= p1Box:CreateControl("A");
	A1:Bind'Joy1Button'( 3,		Trigger.SWITCH(true)					);
	A1:Bind'Key'( ' ', 			Trigger.SWITCH(true)			 		);

	local Left1		= p1Box:CreateControl("Left");
	Left1:Bind'Control'( 'xAxis',	Trigger.SPRING_TO_SWITCH(false, -2, -0.5)	);

	local Right1	= p1Box:CreateControl("Right");
	Right1:Bind'Control'( 'xAxis',	Trigger.SPRING_TO_SWITCH(false, 0.5,  2)	);

	local Up1		= p1Box:CreateControl("Up");
	Up1:Bind'Control'( 'yAxis',		Trigger.SPRING_TO_SWITCH(false, -2, -0.5)	);

	local Down1		= p1Box:CreateControl("Down");
	Down1:Bind'Control'( 'yAxis',	Trigger.SPRING_TO_SWITCH(false, 0.5,  2)	);
end


--===========================================================================--
--  Initialization
--===========================================================================--
Settings_LoadConfig();
return Settings;