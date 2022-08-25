register_blueprint "runtime_real_time"
{
    flags = { EF_NOPICKUP },
    text = {
        denied = "You ran out of time!",
    },
    attributes = {
        aort_prev_time = 0
    },
	callbacks = {
        on_pre_command = [[
            function ( self, actor, cmt )
                local t = ui:get_time_ms()
                -- nova.log("t:"..t.." "..self.attributes.aort_prev_time)
                -- check in combat
                for _ in world:get_level():targets( actor, 10 ) do 
                    if t - self.attributes.aort_prev_time < 1000 or cmt == COMMAND_WAIT then -- pass
                        self.attributes.aort_prev_time = t
                        return 0
                    else
                        world:command( COMMAND_WAIT, actor )
                        ui:set_hint( self.text.denied, 1001, 0 )
                        world:play_voice( "vo_refuse" )
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
                -- for e in world:get_level():entities() do
                --     nova.log(e)
                --     if world:get_id(e) == "medkit_small" then
                --         world:command( COMMAND_USE, player, e)
                --         level:drop_item( player, e )
                --         world:destroy( e )
                --         return 1
                --     end
                -- end

                local e = player:child("medkit_small")
                if e then
                    world:command( COMMAND_USE, player, e)
                    level:drop_item( player, e )
                    world:destroy( e )
                    return 1
                end
                ui:set_hint( self.text.denied, 1001, 0 )
                world:play_voice( "vo_refuse" )
                return 0
            end
        ]=],
    },
    skill = {
        cooldown = 0,
    },
}

register_blueprint "challenge_real_time"
{
    text = {
        name   = "Angel of Real Time",
        desc   = "{!MEGA CHALLENGE PACK MOD}\nYou like to play fast. In combat, you must register your input in less than 1 second or your character waits.\n\nRating   : {GEASY}",
        rating = "EASY",
        abbr   = "AoRT",
        letter = "R",
    },
    challenge = {
        type      = "challenge",
    },
    callbacks = {
        on_create_player = [[
            function( self, player )
                player:attach( "runtime_real_time" )
                -- player:attach( "trait_use_medkit" )
            end
        ]],
    },
}
