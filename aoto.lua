function neuterAny(being)
	if being.data and being.data.ai.group ~= "player" then
		being.data.ai.state = "idle"
		being.data.ai.smell = nil
		being.minimap.color = 0
		being.target.entity = nil
		being.data.ai.group = "demon_n"					
	end
end

register_blueprint "runtime_tourism"
{
    flags = { EF_NOPICKUP },
	text = {
        denied = "Not a suitable souvenir!",
    },
    attributes = {
        cannot_pick_up = true
    },
    callbacks = {       
        can_pickup = [[
            function( self, player, item )
                if item and item.weapon then
                    ui:set_hint( self.text.denied, 1001, 0 )
                    world:play_voice( "vo_refuse" )
                    return -1
                end
				return 0
            end
        ]],
        on_enter_level = [[
            function ( self, entity, reenter )
                if not reenter then
					local level = world:get_level()
					for e in level:enemies() do
						neuterAny(e)
					end	
					for c in level:coords( { "elevator", "portal", "floor_exit", "elevator_branch", "elevator_special" } ) do
						level:set_explored( c, true )
					end
				end
            end
        ]],
        on_timer = [[
			function ( self, first )
				if first then return 49 end
				local level = world:get_level()
				for t in level:targets( world:get_player(), 8 ) do
					if t.data and t.data.ai.group ~= "demon_n" then
						ui:spawn_fx( t, "fx_convert", t )
					end
					neuterAny(t)
				end
				return 50
			end
		]],
    },
}

register_blueprint "challenge_tourism"
{
    text = {
        name 		= "Angel of Tourism",
        desc   		= "{!MEGA CHALLENGE PACK MOD}\nYou aren't here to battle the hordes of hell, you are just here for a tour of the moons of Jupiter. You can't use weapons, but enemies won't attack you either.\n\nRecommend setting camera-eye-distance to 10 so you can view the model details up close.\n\nRating   : {GTOURIST}\n",
        rating 		= "TOURIST",
        abbr   		= "AoT",
        letter = "T"
    },
    challenge = {
        type      = "challenge",
    },
    callbacks = {
        on_create_player = [[
            function( self, player )
                local egun  = player:child("pistol") or player:child("rpistol")
                if egun then world:destroy( egun ) end
                local eammo = player:child("ammo_9mm") or player:child("ammo_44") 
                if eammo then world:destroy( eammo ) end
                player:attach( "kit_phase", { stack = { amount = 3 } } )
                player:attach( "kit_phase", { stack = { amount = 3 } } )
                player:attach( "kit_phase", { stack = { amount = 3 } } )
                player:attach( "runtime_tourism" )
                player.equipment.count = 0				
            end
        ]],
    },
}


