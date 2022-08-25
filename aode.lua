register_blueprint "chall_event_desolation"
{
    text = {
        name      = "Desolation",
    },
    callbacks = {
        on_create = [[
            function ( self )
                local level = world:get_level()
                level.level_info.low_light   = true
                level.level_info.light_range = 4
            end
        ]],
        on_enter_level = [[
            function ( self, level, entity, reenter )
                if reenter then return end
                local terminal = false
                for e in level:entities() do
                    if e.attributes and e.attributes.is_light then
                        world:mark_destroy( e )
                    end 
                end    

                generator.generate_litter( level, level:get_area(), {
                    litter    = { "permaflames", "permaflames", "permaflames", "barrel_napalm", },
                    chance    = 20+math.random(20),
                    allow     = "gap",
                    max_count = 80,
                })

                for i=1,30+math.random(20) do
                    local c = level:random_coord( "floor" )
                    level:place_entity( "crater_large", c )
                end
                for i=1,10+math.random(20) do
                    local c = level:random_coord( "floor" )
                    level:place_entity( "blood_patch_large", c )
                end
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
        on_timer = [[
            function ( self, first )
                if first then return 1000+math.random(1000) end
                local level  = world:get_level()
                local coords = {}
                for e in level:entities() do
                    if e.health and e.health.current > 0 then
                        local id = world:get_id(e)
                        if id == "barrel_fuel" or id == "barrel_napalm" then
                            local ec = world:get_position(e)
                            local fail = false
                            for c in area.around( ec, 1 ):coords() do
                                if ec ~= c then
                                    if level:get_npc( c ) then
                                        fail = true
                                        break
                                    end
                                end
                            end
                            if not fail then
                                table.insert( coords, { ec, e } )
                            end
                        end
                    end
                end

                if #coords > 0 then
                    local entry = coords[ math.random( #coords ) ]
                    level:apply_damage( entry[2], entry[2], 100, entry[1], "internal", entry[2] )
                end

                return 1000+math.random(1000)
            end
        ]],


    }
}

register_blueprint "challenge_desolation"
{
    text = {
        name   = "Angel of Desolation",
        desc   = "{!MEGA CHALLENGE PACK MOD}\nYou are not the first one to confront the Evil. The scars of fierce battles won’t heal. Welcome to the Jovian Hell.\n\nRating   : {GEASY}",
        rating = "EASY",
        abbr   = "AoDe",
        letter = "D",
    },
    challenge = {
        type      = "challenge",
    },
    callbacks = {
        on_create = [[
            function( self, player )
                for i,linfo in ipairs( world.data.level ) do
                    linfo.event = "chall_event_desolation"
                end
            end
        ]],
    },
}


