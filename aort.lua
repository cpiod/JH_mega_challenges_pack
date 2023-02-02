register_blueprint "runtime_real_time"
{
    flags = { EF_NOPICKUP },
    text = {
        denied = "{!Too late!}",
    },
    attributes = {
        aort_prev_time = 0
    },
	callbacks = {
        on_pre_command = [[
            function ( self, actor, cmt )
                local t = ui:get_time_ms()
                -- check in combat
                for _ in world:get_level():targets( actor, 10 ) do -- at least one visible enemy
                    if t - self.attributes.aort_prev_time < 1000 or cmt == COMMAND_WAIT then -- pass
                        self.attributes.aort_prev_time = t
                        return 0
                    else
                        world:command( COMMAND_WAIT, actor )
                        world:play_sound("wait", self)
                        ui:set_hint( self.text.denied, 1001, 0 )
                        return -1
                    end
                    break
                end
                -- out of combat
                self.attributes.aort_prev_time = t
                return 0
            end
        ]]
    }
}

register_blueprint "trait_use_medkit"
{
    blueprint = "trait",
    text = {
        name   = "Use medkit",
        desc   = "",
        full   = "",
        abbr   = "",
        denied = "No small medkit!",
    },
    callbacks = {
        on_activate = [=[
            function(self,entity)
                return -1
            end
        ]=],
        on_use = [=[
            function ( self, player, level, target )
                if world:has_item(player, "medkit_small") > 0 then

                    local hc      = player.health
                    local max     = player.attributes.health
                    local current = hc.current

                    if current < max then
                        local mod = world:get_attribute_mul( player, "medkit_mod" ) or 1.0
                        world:play_sound( "medkit_small", player )
                        hc.current = current + math.floor( 40 * mod )
                        if hc.current > max then
                            hc.current = max
                        end
                        ui:spawn_fx( player, "fx_heal", player )
                        if current <= 30 then
                            world:play_voice("vo_imedkit")
                        else
                            world:play_voice("vo_medkit")
                        end
                        world:destroy( player:child("bleed") )
                        world:destroy( player:child("poisoned") )
                        world:destroy( player:child("acided") )
                        world:destroy( player:child("burning") )
                        world:destroy( player:child("freeze") )
                        gtk.remove_fire( player:get_position() )
                        -- remove medkit once used
                        world:remove_items(player, "medkit_small", 1)
                        return 100
                    else
                        ui:set_hint( "No need to heal", 1001, 0 )
                        return -1
                    end
                else
                    ui:set_hint( "{RNo small medkit!}", 1001, 0 )
                    return -1
                end
            end
        ]=],
    },
    skill = {
        cooldown = 0,
        cost = 0
    },
}

register_blueprint "challenge_real_time"
{
    text = {
        name   = "Angel of Real Time",
        desc   = "{!MEGA CHALLENGE PACK MOD}\nYou like to play fast. In combat, you must register your input in less than 1 second or your character waits.\n\nRating   : {RHARD}",
        rating = "HARD",
        abbr   = "AoRT",
        letter = "RT",
    },
    challenge = {
        type      = "challenge",
    },
    callbacks = {
        on_create_player = [[
            function( self, player )
                player:attach( "runtime_real_time" )
                player:attach( "trait_use_medkit" )
            end
        ]],
    },
}
