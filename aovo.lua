register_blueprint "chall_event_volatile_storage"
{
    callbacks = {
        on_create = [[
            function ( self )
            end
        ]],
        on_enter_level = [[
            function ( self, level, entity, reenter )
                if reenter then return end
                generator.generate_litter( level, level:get_area(), {
                    litter    = { "barrel_fuel", "barrel_toxin", "barrel_acid", "barrel_cryo", "barrel_napalm" },
                    chance    = 66,
                    max_count = 80,
                })
            end
        ]],
        on_cleared = [[
            function ( self, level )
                local ui_event = gtk.get_event_ui( self )
                if ui_event and ui_event.active then
                    ui_event.active = false
                end
            end
        ]],
    }
}


register_blueprint "runtime_volatility"
{
    flags = { EF_NOPICKUP }, 
    callbacks = {
        on_enter_level = [=[
            function ( self, entity )
                for e in world:get_level():entities() do 
                    if e.data and e.data.ai then
                        e:attach( "exalted_kw_unstable" )
                    end
                end
            end
        ]=],
    },
}

register_blueprint "challenge_volatility"
{
    text = {
        name   = "Angel of Kaboom",
        desc   = "{!MEGA CHALLENGE PACK MOD}\nReady for an explosive experience? Each level is a volatile storage and each enemy is unstable!\n\nRating   : {GEASY}",
        rating = "EASY",
        abbr   = "AoK",
        letter = "K",
    },
    challenge = {
        type      = "challenge",
    },
    callbacks = {
        on_create_player = [[
            function( self, player )
                player:attach( "runtime_volatility" )
                player:attach( "shotgun" )
                player:attach( "ammo_shells", { stack = { amount = 10 } } )
            end
        ]],
        on_create = [[
            function( self, player )
                for i,linfo in ipairs( world.data.level ) do
                    linfo.event = "chall_event_volatile_storage"
                end
            end
        ]],
    },
}



