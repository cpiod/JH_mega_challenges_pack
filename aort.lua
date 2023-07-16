register_blueprint "runtime_real_time"
{
    flags = { EF_NOPICKUP },
    attributes = {
        aort_prev_time = 0
    },
	callbacks = {
        on_pre_command = [[
            function ( self, actor, cmt )
                local t = ui:get_time_ms()
                -- check in combat
                for _ in world:get_level():targets( actor, 10 ) do -- at least one visible enemy
                    local max_time = 1000
                    if actor:child("buff_stimpack") then
                        max_time = 3000
                    end
                    if t - self.attributes.aort_prev_time < max_time or cmt == COMMAND_WAIT then -- pass
                        self.attributes.aort_prev_time = t
                        return 0
                    else
                        world:command( COMMAND_WAIT, actor )
                        world:play_sound("wait", self)
                        ui:set_hint( "{!Too late!}", 1001, 0 )
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

register_blueprint "runtime_trait_use_stimpack"
{
    blueprint = "trait",
    text = {
        name   = "Use stimpack",
        desc   = "Internal",
        full   = "Internal",
        abbr   = "MED",
    },
    flags = { EF_CONSUMABLE },
    callbacks = {
        on_activate = [=[
            function(self,entity)
                return -1
            end
        ]=],

        on_post_command = [=[
            function ( self, actor, cmt, weapon, time )
                self.skill.charge = world:has_item(actor, "stimpack_small")
            end
        ]=],

        on_use = [=[
            function ( self, entity, level, target )
                if world:has_item(entity, "stimpack_small") > 0 then

                    local hc      = entity.health
                    local max     = entity.attributes.health
                    local mod     = world:get_attribute_mul( entity, "medkit_mod" ) or 1.0
                    local current = hc.current

                    world:play_sound( "medkit_small", entity )
                    if hc.current < max then
                        hc.current = current + math.floor( 40 * mod )
                        if hc.current > max then
                            hc.current = max
                        end
                    end

                    local epain = entity:child("pain")
                    if epain then
                        epain.attributes.accuracy = 0
                        epain.attributes.value    = 0
                    end

                    for c in ecs:children( entity ) do
                        if c.resource then
                            local attr   = c.attributes
                            local value  = attr.value
                            local max    = attr.max
                            if value < max then
                                local amount = math.floor( max / 4 )
                                attr.value = math.min( value + amount, max )
                            end
                        end
                        if c.skill then
                            if c.skill.time_left > 0 then
                                c.skill.time_left = 0
                            end
                        end
                    end
                    world:add_buff( entity, "buff_stimpack", 500 )
                    ui:spawn_fx( entity, "fx_heal", entity )
                    if current <= 30 then
                        world:play_voice("vo_imedkit")
                    else
                        world:play_voice("vo_medkit")
                    end
                    world:destroy( entity:child("bleed") )
                    world:destroy( entity:child("poisoned") )
                    world:destroy( entity:child("acided") )
                    world:destroy( entity:child("burning") )
                    world:destroy( entity:child("freeze") )
                    gtk.remove_fire( entity:get_position() )

                    return 100
                else
                    ui:set_hint( "{RNo small stimpack!}", 1001, 0 )
                    return -1
                end
            end
        ]=],
    },
    skill = {
        cooldown = 0,
        cost = 0,
        charge = 0
    },
}

register_blueprint "challenge_real_time"
{
    text = {
        name   = "Angel of Real Time",
        desc   = "{!MEGA CHALLENGE PACK MOD}\nYou like to play fast. In combat, you must register your input in less than 1 second or your character waits. You got 3 seconds with a stimmed character, and you start with a stimpack!\n\nRating   : {RHARD}",
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
                local tr = player:attach( "runtime_trait_use_stimpack" )
                player:attach( "stimpack_small" )
                tr.skill.charge = world:has_item(player, "stimpack_small")
            end
        ]],
    },
}
