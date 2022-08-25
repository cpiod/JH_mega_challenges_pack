register_blueprint "chall_event_infestation"
{
    text = {
		name          = "Infestation",
        intro_fiend   = "There's a foul stench in the air...",
        intro_reaver  = "You hear the shrieking of reavers...",
        intro_kerberos= "The dogs have been unleashed...",
        intro_demon   = "You shiver from dread...",
	},
    callbacks = {
        on_create = [[
            function ( self )
                local level = world:get_level()
                level.attributes.bulk_mod = 0.0
            end
        ]],
        on_enter_level = [[
            function ( self, level, entity, reenter )
                if reenter then return end
                local linfo    = level.level_info
                local bulk_max = generator.std_exp_value( linfo )
                local dlevel   = linfo.dlevel - math.random(2)
                local params = {
                    list  = event_infestation_beings,
                    mod   = {},
                    level = dlevel,
                    safe  = linfo.entry,
                }

                if dlevel < 9 then
                    ui:set_hint( "{R"..self.text.intro_fiend.."}", 1001, 0 )
                    bulk_max = bulk_max - generator.spawn_exalted( level, 1, { override = {"exalted_fiend"}, safe  = linfo.entry, } )
                elseif dlevel < 16 then
                    ui:set_hint( "{R"..self.text.intro_reaver.."}", 1001, 0 )
                    bulk_max = bulk_max - generator.spawn_exalted( level, 1, { override = {"exalted_reaver"}, safe  = linfo.entry, } )
                elseif dlevel < 21 then
                    ui:set_hint( "{R"..self.text.intro_kerberos.."}", 1001, 0 )
                    bulk_max = bulk_max - generator.spawn_exalted( level, 1, { override = {"exalted_kerberos"}, safe  = linfo.entry, } )
                else
                    ui:set_hint( "{R"..self.text.intro_demon.."}", 1001, 0 )
                    bulk_max = bulk_max - generator.spawn_exalted( level, 1, { override = {"exalted_reaver"}, safe  = linfo.entry, } )
                end
                if level.level_info.depth < 3 then
                    bulk_max = math.ceil( bulk_max * 0.6 )
                end
                generator.spawn_enemies( level, bulk_max, params )
            end    
        ]],
        on_create_entity = [[
            function ( self, level, entity )
                if entity.stack and entity.stack.amount > 1 then
                    entity.stack.amount = math.min( math.ceil( 3 * entity.stack.amount ), entity.stack.max )
                end
            end
        ]],
        on_cleared = [[
            function ( self, level )
                local ui_event = gtk.get_event_ui( self )
                if ui_event and ui_event.active then
                    ui_event.active = false
                    ui:set_hint( "{R"..self.text.complete.."}", 1001, 0 )
                end
            end
        ]],
    }
}


register_blueprint "challenge_infestation"
{
    text = {
        name   = "Angel of Infestation",
        desc   = "{!MEGA CHALLENGE PACK MOD}\nA relaxing experience, with no zombies, no CRI, no bots.\n\nRating   : {GEASY}",
        rating = "EASY",
        abbr   = "AoIn",
        letter = "I",
    },
    challenge = {
        type      = "challenge",
    },
    callbacks = {
        on_create = [[
            function( self, player )
                for i,linfo in ipairs( world.data.level ) do
                    linfo.event = "chall_event_infestation"
                end
            end
        ]],
    },
}



