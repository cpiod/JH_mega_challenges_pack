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
        name   = "Angel of Nudism",
        desc   = "You love your body and you will happily expose it to zombies, bots and demons. As such, you won’t wear any armor or helmet.\n\nRating   : {GEASY}",
        rating = "EASY",
        abbr   = "AoNu",
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

