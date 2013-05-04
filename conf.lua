
function love.conf( game )
    game.title 					= "TopWar"
    game.author 				= "Hristoz S. Stefanov"
    game.url 					= nil
    game.identity 				= nil
    game.version				= "0.8.0"
    game.console				= true
    game.release 				= false
	game.test					= true
	
	-- Screen settings
    game.screen.width 			= 800
    game.screen.height 			= 600
    game.screen.fullscreen 		= false
    game.screen.vsync 			= true
    game.screen.fsaa 			= 0
	
	-- Module flags
    game.modules.joystick		= true
    game.modules.audio 			= true
    game.modules.keyboard 		= true
    game.modules.event 			= true
    game.modules.image 			= true
    game.modules.graphics 		= true
    game.modules.timer 			= true
    game.modules.mouse 			= true
    game.modules.sound 			= true
    game.modules.physics 		= false
end