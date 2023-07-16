
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

function cpiod_pick_event(events)
    local val = math.random( #events )
    local pick = events[val]
    nova.log("nb events avant: "..#events)
    nova.log("chosed: "..pick)
    -- at most one timed event
    if val >= #events-2 and events[#events] == "event_lockdown" then
        table.remove(events, #events)
        table.remove(events, #events)
        table.remove(events, #events)
    else
        table.remove(events, val)
    end
    nova.log("nb events apres: "..#events)
    return pick
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
                    local events = { "event_low_light",
                                "event_desolation",
                                "event_volatile_storage",
                                "event_infestation",
                                "event_exalted_curse",
                                "event_vault",
                                "event_contamination",
                                "event_windchill",
                                "event_hunt",
                                "event_exalted_summons",
                                "event_lockdown",
                            }
                    local e = {}
                    for _=1,linfo.episode+1 do
                        table.insert(e, cpiod_pick_event(events))
                    end
                    linfo.event = e
                end
            end
        ]],
    },
}


