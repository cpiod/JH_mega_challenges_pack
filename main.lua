register_blueprint "runtime_nudity"
{
    flags = { EF_NOPICKUP }, 
    text = {
        denied = "You won’t hide that perfect body!",
    },
    callbacks = {
        can_pickup = [[
            function( self, player, item )
                if item.armor or item.helmet then
                    ui:set_hint( self.text.denied, 1001, 0 )
                    world:play_voice( "vo_refuse" )
                    return -1
                end
                return 0
            end
        ]],
    },
}

register_blueprint "challenge_nudity"
{
    text = {
        name   = "Angel of Nudity",
        desc   = "You love your body and you will happily expose it to zombies, bots and demons. As such, you cannot wear any armor or helmet.\n\nRating   : {GEASY}",
        rating = "EASY",
        abbr   = "AoN",
        letter = "N",
    },
    challenge = {
        type      = "challenge",
    },
    callbacks = {
        on_create_player = [[
            function( self, player )
                player:attach( "runtime_nudity" )
            end
        ]],
    },
}

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
        desc   = "The world is a dark place.\n\nRating   : {GEASY}",
        rating = "EASY",
        abbr   = "AoD",
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


