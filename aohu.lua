
register_blueprint "chall_event_hunt"
{
    text = {
		name      = "The Hunt",
        intro     = "The hunt will start soon...",
        start     = "The hunt is on!",
	},
    callbacks = {
        on_create = [[
            function ( self )
                local level = world:get_level()
                level.attributes.bulk_mod = 0.8
            end
        ]],
        on_timer = [[
			function ( self, first )
                if first then return 100 end
                local level   = world:get_level()
                if level.level_info.enemies <= 0 then
                    return 0
                end
                local ui_event = gtk.get_event_ui( self )
                local counter = ui_event.counter
                counter = counter - 1 
                ui_event.counter = counter

                if counter <= 0 then
                    ui:set_hint( "{R"..self.text.start.."}", 1001, 0 )

                    for e in level:entities() do
                        if e.data and e.data.ai and e.data.ai.group ~= "player" then
                            e.target.entity = world:get_player()
                            e.data.ai.state = "find"
                        end
                    end
                    return 0
                end
                return 100
            end
        ]],
        on_enter_level = [[
            function ( self, level, entity, reenter )
                if reenter then return end
                local ui_event = gtk.get_event_ui( self )
                ui_event.counter = 60
                ui_event.style   = 1
                ui:set_hint( "{R"..self.text.intro.."}", 1001, 0 )
                world:add_history( "event", self, level )
            end    
        ]],
        on_cleared = [[
            function ( self, level )
                local ui_event = gtk.get_event_ui( self )
                if ui_event.active then
                    ui_event.active = false
                end
            end
        ]],
    },
}


register_blueprint "challenge_hunt"
{
    text = {
        name   = "Angel of the Hunt",
        desc   = "{!MEGA CHALLENGE PACK MOD}\nThey know you are coming. They are waiting for you.\n\nRating   : {GEASY}",
        rating = "EASY",
        abbr   = "AoHu",
        letter = "H",
    },
    challenge = {
        type      = "challenge",
    },
    callbacks = {
        on_create = [[
            function( self, player )
                for i,linfo in ipairs( world.data.level ) do
                    linfo.event = "chall_event_hunt"
                end
            end
        ]],
    },
}


