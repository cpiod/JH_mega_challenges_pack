register_blueprint "runtime_no_retreat"
{
    flags = { EF_NOPICKUP },
    text = {
        denied_move = "No retreat!", --"No surrender!"
    },
	callbacks = {
        on_pre_command = [[
        function ( self, entity, command, a, b,c,d )
            if core.command_dir[command] then
                local l = world:get_level()
                local p = world:get_player()
                local gx = core.command_dir[command].x
                local gy = core.command_dir[command].y
                local enemy_in_sight = false
                local pp = world:get_position( p )
                for e in l:targets( p, 8 ) do
                    if e.data and e.data.ai and e.data.ai.group ~= "player" then
                        local ep = world:get_position( e )
                        local dx = ep.x - pp.x
                        local dy = ep.y - pp.y
                        dx = dx > 0 and 1 or dx == 0 and 0 or -1
                        dy = dy > 0 and 1 or dy == 0 and 0 or -1
                        if (dx ~= 0 and dx == gx) or (dy ~= 0 and dy == gy) then
                            return 0 --enemy in movement direction, allow move
                        end
                        enemy_in_sight = true
                    end
                end
                if enemy_in_sight then --enemy in sight and move wasn't allowed
                    ui:set_hint( self.text.denied_move, 50, 0 )
                    return -1
                end
            
            end
        end
        ]]
    }
}

register_blueprint "challenge_no_retreat"
{
    text = {
        name   = "Angel of No Retreat",
        desc   = "{!MEGA CHALLENGE PACK MOD}\nJupiter is a no retreat state. You cannot move away from enemies that you see unless moving towards another enemy.\n\nRating   : {YMEDIUM}",
        rating = "MEDIUM",
        abbr   = "AoNoR",
        letter = "N",
    },
    challenge = {
        type      = "challenge",
    },
    callbacks = {
        on_create_player = [[
            function( self, player )
                player:attach( "runtime_no_retreat" )
            end
        ]],
    },
}

