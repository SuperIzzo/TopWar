
function love.conf( game )
    game.title 					= "Battle Dyzx"
    game.author 				= "Hristoz S. Stefanov"
    game.url 					= nil
    game.identity 				= nil
    game.version				= "0.9.0"
    game.console				= true
    game.release 				= false
	game.test					= false
	
	-- Screen settings
    game.window.width 			= 800
    game.window.height 			= 600
    game.window.fullscreen 		= false
    game.window.vsync 			= true
    game.window.fsaa 			= 0
	
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