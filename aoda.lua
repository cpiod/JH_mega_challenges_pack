register_blueprint "runtime_darkness"
{
    flags = { EF_NOPICKUP }, 
    callbacks = {
        on_enter_level = [=[
            function ( self, entity, reenter )
                local l = world:get_level()
                l.level_info.light_range = 4
                l.level_info.low_light = true
            end
        ]=],
    },
}

register_blueprint "challenge_darkness"
{
    text = {
        name   = "Angel of Darkness",
        desc   = "{!MEGA CHALLENGE PACK MOD}\nThe world is a dark place.\n\nRating   : {GEASY}",
        rating = "EASY",
        abbr   = "AoDa",
        letter = "D",
    },
    challenge = {
        type      = "challenge",
    },
    callbacks = {
        on_create_player = [[
            function( self, player )
                player:attach( "runtime_darkness" )
            end
        ]],
    },
}


