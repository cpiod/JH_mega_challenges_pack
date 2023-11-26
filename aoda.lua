register_blueprint "runtime_darkness"
{
    flags = { EF_NOPICKUP }, 
    callbacks = {
        on_enter_level = [=[
            function ( self, entity, reenter )
                local l = world:get_level()
                l.level_info.light_range = 4
                l.level_info.low_light = true
                for e in l:entities() do
                    if world:get_id( e ) == "terminal" then
                        local reveal = e:child("terminal_recon")
                        reveal = reveal:child("terminal_reveal")
                        world:destroy( reveal )
                    end
                end
            end
        ]=],
        on_move = [=[
            function ( self, entity )
                local level = world:get_level()
                local size = level:get_size()
                for i=0,size.x-1 do
                    for j=0,size.y-1 do
                        if level:is_explored(coord(i,j)) then
                            level:set_explored(coord(i,j), false)
                        end
                    end
                end
            end
        ]=],
    },
}

register_blueprint "challenge_darkness"
{
    text = {
        name   = "Angel of Darkness",
        desc   = "{!MEGA CHALLENGE PACK MOD}\n\"No matter how fast light travels, it finds the darkness has always got there first, and is waiting for it.\" Your vision radius is reduced, your minimap is useless and enemies comes back from the dead. Good luck!\n\nRating   : {RHARD}",
        rating = "HARD",
        abbr   = "AoDa",
        letter = "D",
    },
    challenge = {
        type      = "challenge",
    },
    callbacks = {
        on_create_entity = [[
            function( self, entity, alive )
                if alive and entity.data and entity.data.nightmare then
                    entity:attach( "nightmare_mark" )
                end
            end
        ]],
        on_create_player = [[
            function( self, player )
                player:attach( "runtime_darkness" )
            end
        ]],
    },
}


