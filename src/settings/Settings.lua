--===========================================================================--
--  Dependencies
--===========================================================================--
local ControlBox 	= require 'src.input.ControlBox'
local Trigger	 	= require 'src.input.TriggerType'

-- Note: Separate in multiple classes when it grows - raphics, input, sound...



--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class Settings: Game settings management class
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
--  The Settings class is best place to put specific or general variables and 
--  constants that relate to and configure one or more subsystems- i.e.settings
--  This class will handle loading and saving settings from multiple locations,
--  default settings, recomended settings and more... 
--  For the time being though it will be a mess.
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
--  Settings:LoadDefaultControls : Loads the default controls
-------------------------------------------------------------------------------
function Settings:LoadDefaultControls( box )

	-- player 1
	if box.player and box.player==1 then

	local xAxis	= box:CreateControl("xAxis");
	xAxis:SetValue(0);
	xAxis:Bind'Joy1Axis'( 1, 	Trigger.SLIDER(false) 						);	
	xAxis:Bind'Joy1Hat'( 'l1', Trigger.SWITCH_TO_SPRING(false, -1, 0) 	);
	xAxis:Bind'Joy1Hat'( 'lu1',Trigger.SWITCH_TO_SPRING(false, -1, 0)  );
	xAxis:Bind'Joy1Hat'( 'ld1',Trigger.SWITCH_TO_SPRING(false, -1, 0)  );
	xAxis:Bind'Joy1Hat'( 'r1', Trigger.SWITCH_TO_SPRING(false,  1, 0) 	);
	xAxis:Bind'Joy1Hat'( 'ru1',Trigger.SWITCH_TO_SPRING(false,  1, 0)  );
	xAxis:Bind'Joy1Hat'( 'rd1',Trigger.SWITCH_TO_SPRING(false,  1, 0)  );
	xAxis:Bind'Key'( 'a', 		Trigger.SWITCH_TO_SPRING(false, -1, 0) 	);
	xAxis:Bind'Key'( 'd', 		Trigger.SWITCH_TO_SPRING(false,  1, 0) 	);
	xAxis:Bind'Update'( 1, 	Trigger.ALWAYS() 						);

	local yAxis	= box:CreateControl("yAxis");
	yAxis:SetValue(0);
	yAxis:Bind'Joy1Axis'( 2, 	Trigger.SLIDER(false) 					);
	yAxis:Bind'Joy1Hat'( 'u1', Trigger.SWITCH_TO_SPRING(false, -1, 0) 	);
	yAxis:Bind'Joy1Hat'( 'ru1',Trigger.SWITCH_TO_SPRING(false, -1, 0)  );
	yAxis:Bind'Joy1Hat'( 'lu1',Trigger.SWITCH_TO_SPRING(false, -1, 0)  );
	yAxis:Bind'Joy1Hat'( 'd1', Trigger.SWITCH_TO_SPRING(false,  1, 0) 	);
	yAxis:Bind'Joy1Hat'( 'rd1',Trigger.SWITCH_TO_SPRING(false,  1, 0)  );
	yAxis:Bind'Joy1Hat'( 'ld1',Trigger.SWITCH_TO_SPRING(false,  1, 0)  );
	yAxis:Bind'Key'( 'w', 		Trigger.SWITCH_TO_SPRING(false, -1, 0) 	);
	yAxis:Bind'Key'( 's', 		Trigger.SWITCH_TO_SPRING(false,  1, 0) 	);
	yAxis:Bind'Update'( 1, 	Trigger.ALWAYS() 						);

	local A		= box:CreateControl("A");
	A:Bind'Joy1Button'( 3,		Trigger.SWITCH(true)					);
	A:Bind'Key'( ' ', 			Trigger.SWITCH(true)			 		);
	
	local B		= box:CreateControl("B");
	B:Bind'Joy1Button'( 4,		Trigger.SWITCH(true)					);
	B:Bind'Key'( 'shift', 		Trigger.SWITCH(true)			 		);
	
	local X		= box:CreateControl("X");
	X:Bind'Joy1Button'( 1,		Trigger.SWITCH(true)					);
	
	local Y		= box:CreateControl("Y");
	Y:Bind'Joy1Button'( 2,		Trigger.SWITCH(true)					);

	local Left		= box:CreateControl("Left");
	Left:Bind'Control'( 'xAxis',	Trigger.SPRING_TO_SWITCH(true, -2, -0.5)	);

	local Right	= box:CreateControl("Right");
	Right:Bind'Control'( 'xAxis',	Trigger.SPRING_TO_SWITCH(true, 0.5,  2)	);

	local Up		= box:CreateControl("Up");
	Up:Bind'Control'( 'yAxis',		Trigger.SPRING_TO_SWITCH(true, -2, -0.5)	);

	local Down		= box:CreateControl("Down");
	Down:Bind'Control'( 'yAxis',	Trigger.SPRING_TO_SWITCH(true, 0.5,  2)	);
	
	
	-- player 2
	elseif box.player and box.player==2 then
	
	local xAxis	= box:CreateControl("xAxis");
	xAxis:SetValue(0);
	xAxis:Bind'Joy2Axis'( 1, 	Trigger.SLIDER(false) 					);
	xAxis:Bind'Joy2Hat'( 'l1', Trigger.SWITCH_TO_SPRING(false, -1, 0) 	);
	xAxis:Bind'Joy2Hat'( 'lu1',Trigger.SWITCH_TO_SPRING(false, -1, 0)  );
	xAxis:Bind'Joy2Hat'( 'ld1',Trigger.SWITCH_TO_SPRING(false, -1, 0)  );
	xAxis:Bind'Joy2Hat'( 'r1', Trigger.SWITCH_TO_SPRING(false,  1, 0) 	);
	xAxis:Bind'Joy2Hat'( 'ru1',Trigger.SWITCH_TO_SPRING(false,  1, 0)  );
	xAxis:Bind'Joy2Hat'( 'rd1',Trigger.SWITCH_TO_SPRING(false,  1, 0)  );
	xAxis:Bind'Key'( 'left', 		Trigger.SWITCH_TO_SPRING(false, -1, 0) 	);
	xAxis:Bind'Key'( 'right', 		Trigger.SWITCH_TO_SPRING(false,  1, 0) 	);
	xAxis:Bind'Update'( 1, 	Trigger.ALWAYS() 						);

	local yAxis	= box:CreateControl("yAxis");
	yAxis:SetValue(0);
	yAxis:Bind'Joy2Axis'( 2, 	Trigger.SLIDER(false) 					);
	yAxis:Bind'Joy2Hat'( 'u1', Trigger.SWITCH_TO_SPRING(false, -1, 0) 	);
	yAxis:Bind'Joy2Hat'( 'ru1',Trigger.SWITCH_TO_SPRING(false, -1, 0)  );
	yAxis:Bind'Joy2Hat'( 'lu1',Trigger.SWITCH_TO_SPRING(false, -1, 0)  );
	yAxis:Bind'Joy2Hat'( 'd1', Trigger.SWITCH_TO_SPRING(false,  1, 0) 	);
	yAxis:Bind'Joy2Hat'( 'rd1',Trigger.SWITCH_TO_SPRING(false,  1, 0)  );
	yAxis:Bind'Joy2Hat'( 'ld1',Trigger.SWITCH_TO_SPRING(false,  1, 0)  );
	yAxis:Bind'Key'( 'up', 		Trigger.SWITCH_TO_SPRING(false, -1, 0) 	);
	yAxis:Bind'Key'( 'down', 		Trigger.SWITCH_TO_SPRING(false,  1, 0) 	);
	yAxis:Bind'Update'( 1, 	Trigger.ALWAYS() 						);

	
	local A		= box:CreateControl("A");
	A:Bind'Joy2Button'( 3,		Trigger.SWITCH(true)					);
	
	local B		= box:CreateControl("B");
	B:Bind'Joy2Button'( 4,		Trigger.SWITCH(true)					);
	
	local X		= box:CreateControl("X");
	X:Bind'Joy2Button'( 1,		Trigger.SWITCH(true)					);
	
	local Y		= box:CreateControl("Y");
	Y:Bind'Joy2Button'( 2,		Trigger.SWITCH(true)					);

	
	local Left		= box:CreateControl("Left");
	Left:Bind'Control'( 'xAxis',	Trigger.SPRING_TO_SWITCH(true, -2, -0.5)	);

	local Right	= box:CreateControl("Right");
	Right:Bind'Control'( 'xAxis',	Trigger.SPRING_TO_SWITCH(true, 0.5,  2)	);

	local Up		= box:CreateControl("Up");
	Up:Bind'Control'( 'yAxis',		Trigger.SPRING_TO_SWITCH(true, -2, -0.5)	);

	local Down		= box:CreateControl("Down");
	Down:Bind'Control'( 'yAxis',	Trigger.SPRING_TO_SWITCH(true, 0.5,  2)	);
	
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
Settings_LoadConfig();
return Settings;