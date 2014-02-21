--===========================================================================--
--  Dependencies
--===========================================================================--
local Announcer				= require 'src.util.Announcer'


--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
--	Class Timer: a brief... 
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--
local Timer = {}
Timer.__index = Timer;


-------------------------------------------------------------------------------
--  Timer:new : Creates a new timer
-------------------------------------------------------------------------------
function Timer:new( time )
	local obj = {}
	
	obj.timeLeft			= time or 0;
--	obj.announcer			= nil;

	return setmetatable(obj, self);
end


-------------------------------------------------------------------------------
--  Timer:new : Updates the timer reducing it's time counter
-------------------------------------------------------------------------------
function Timer:Update( dt )
	if self.timeLeft > 0 then
		self.timeLeft = self.timeLeft - dt;
		
		if self.timeLeft <= 0 then
			self.timeLeft = 0;
			
			-- Announce if we have someone to announce to
			if self.announcer then
				self.announcer:Announce( self );
			end;
		end
	end		
end


-------------------------------------------------------------------------------
--  Timer:GetTimeLeft : Returns wheter the timer time is over
-------------------------------------------------------------------------------
function Timer:GetTimeLeft()
	return self.timeLeft;
end


-------------------------------------------------------------------------------
--  Timer:Reset : Returns wheter the timer time is over
-------------------------------------------------------------------------------
function Timer:Reset( time )	
	self.timeLeft = time;
end


-------------------------------------------------------------------------------
--  Timer:IsRunning : Returns wheter the timer time is currently running
-------------------------------------------------------------------------------
function Timer:IsRunning()
	return self.timeLeft > 0;
end


-------------------------------------------------------------------------------
--  Timer:IsStopped : Returns wheter the timer time is over
-------------------------------------------------------------------------------
function Timer:IsStopped()
	return self.timeLeft <= 0;
end


-------------------------------------------------------------------------------
--  Timer:AddListener : Adds a timer listener
-------------------------------------------------------------------------------
function Timer:AddListener( obj, func )
	if not self.announcer then
		self.announcer = Announcer:new();
	end
	
	self.announcer:AddListener( obj, func );
end


-------------------------------------------------------------------------------
--  Timer:RemoveListener : Removes a timer listener
-------------------------------------------------------------------------------
function Timer:RemoveListener( obj )
	if self.announcer then
		self.announcer:RemoveListener( obj );
	end
end


--===========================================================================--
--  Initialization
--===========================================================================--
return Timer