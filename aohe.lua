
original_generator_run = generator.run

function generator.run( self, linfo, gen_run_func, gen_spawn_func )

	local linfo = linfo or world.data.level[ world.data.current ]
    local events = nil
    if linfo then
        events = linfo.event
        linfo.event = nil
    end
    -- we will take care of that

    -- run the original generator
    original_generator_run ( self, linfo, gen_run_func, gen_spawn_func )

    if linfo then
        linfo.event = events
    end
    -- cpiod’s hack, should be backward compatible
	local event = nil
	if linfo.event then
        if type(linfo.event) == "string" then -- legacy behavior
            linfo.event = { linfo.event }
        end
        for _,v in pairs(linfo.event) do
            event = world:create_entity( v )
            world:attach( self, event )
            local uevent  = ecs:add( self, "ui_event" )
            uevent.event  = event
            uevent.active = true
        end
    end

end

register_blueprint "challenge_he"
{
    text = {
        name   = "Angel of Hell",
        desc   = "{!MEGA CHALLENGE PACK MOD}\nAn eventful adventure.\n\nRating   : {GEASY}",
        rating = "EASY",
        abbr   = "AoHe",
        letter = "H",
    },
    challenge = {
        type      = "challenge",
    },
    callbacks = {
        on_create = [[
            function( self, player )
                for i,linfo in ipairs( world.data.level ) do
                    local timed_events = { "event_lockdown",
                                "event_hunt",
                                "event_exalted_summons",
                                "event_cursed" }
                    local untimed_events = { "event_low_light",
                                "event_desolation",
                                "event_volatile_storage",
                                "event_infestation",
                                "event_exalted_curse",
                                "event_vault",
                                "event_contamination",
                                "event_windchill" }

                    if linfo.episode == 1 then
                        local pick1 = table.remove( timed_events, math.random( #timed_events ) )
                        local pick2 = table.remove( untimed_events, math.random( #untimed_events ) )
                        linfo.event = { pick1, pick2 }
                    elseif linfo.episode == 2 then
                        local pick1 = table.remove( timed_events, math.random( #timed_events ) )
                        local pick2 = table.remove( untimed_events, math.random( #untimed_events ) )
                        local pick3 = table.remove( untimed_events, math.random( #untimed_events ) )
                        linfo.event = { pick1, pick2, pick3 }
                    elseif linfo.episode >= 3 then
                        local pick1 = table.remove( timed_events, math.random( #timed_events ) )
                        local pick2 = table.remove( untimed_events, math.random( #untimed_events ) )
                        local pick3 = table.remove( untimed_events, math.random( #untimed_events ) )
                        local pick4 = table.remove( untimed_events, math.random( #untimed_events ) )
                        linfo.event = { pick1, pick2, pick3, pick4 }
                    end
                end
            end
        ]],
    },
}


