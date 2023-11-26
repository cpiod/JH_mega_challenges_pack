register_blueprint "trait_call_cri"
{
    blueprint = "trait",
    text = {
        name   = "Call CRI (0/15)",
        desc   = "",
        full   = "",
        abbr   = "",
		cant_use = "Kill more demons to deserve some reinforcement!",
    },
    attributes = {
        kill = 0,
        required_kills = 15
    },
    callbacks = {
        on_activate = [=[
            function(self,entity)
                return -1
            end
        ]=],
        on_use = [=[
            function ( self, player, level, target )
                if self.attributes.kill < self.attributes.required_kills then
                    ui:set_hint( self.text.cant_use, 50, 1 )
                    return -1
                else
                    self.text.name = "Call CRI (0/15)"
                    self.attributes.kill = 0
                    local episode = world:get_level().level_info.episode
                    local ids     = { "cri_marine", "cri_bot",}
                    local count   = 2 * episode
                    local positions = leveltk.find_open_elevator_coords( level )
                    for _=1,count do
                        local id = ids[ math.random( #ids ) ]
                        local pos = positions[math.random(#positions)]
                        local b = level:add_entity( id, pos )
                        b.data.cri_clearanced = true
                        b.flags.data[ EF_BUMPACTION ] = true
                        b.flags.data[ EF_FOLLOW ] = true
                        aitk.convert( b, world:get_player(), false, false, true, true ) -- no control, no summon, no experience, no drop
                        b.data.ai.idle  = "active_hunt_no_player"
                        b.data.ai.state = "active_hunt_no_player"
                        b.attributes.experience_value = 0
                    end
                end
            end
        ]=],
		on_kill = [=[
            function ( self, entity, target, weapon )
                if target and target.data and target.data.ai and gtk.is_ai_group( target, { "demon" } ) and self.attributes.kill < self.attributes.required_kills then
                    self.attributes.kill = self.attributes.kill + 1
                    if self.attributes.kill == self.attributes.required_kills then
                        self.text.name = "Call CRI (READY)"
                    else
                        self.text.name = "Call CRI ("..self.attributes.kill.."/"..self.attributes.required_kills..")"
                    end
                end
            end
        ]=]
    },
    skill = {
        cooldown = 0,
        cost = 0
    },
}

register_blueprint "cpiod_cri_clearance"
{
    flags = { EF_NOPICKUP, EF_PERMANENT }, 
    text = {
        name  = "CRI Clearance",
        desc  = "CRI has given you clearance. CRI forces will no longer attack you.",
        bdesc = "non-corrupted CRI forces will be friendly",
    },
    callbacks = {
        do_convert = [=[
            function ( self, fx )
                local l    = world:get_level()
                for e in l:entities() do
                    if e.data and e.data.cri and e.data.ai then
                        local ai = e.data.ai
                        if ai.group == "cri" or ai.group == "cri_n" then
                            if fx then
                                ui:spawn_fx( e, "fx_convert", e )
                            end
                            e.data.cri_clearanced = true
                            e.flags.data[ EF_BUMPACTION ] = true
                            aitk.convert( e, world:get_player(), false, false, false, true )
                        end
                    end
                end
            end
        ]=],
        on_enter_level = [=[
            function ( self, entity, reenter )
                world:lua_callback( self, "do_convert", false )
            end
        ]=],
    },
}

register_blueprint "challenge_charon"
{
    text = {
        name   = "Angel of Charon",
        desc   = "{!MEGA CHALLENGE PACK MOD}\nYou were sent by the Charon Research Institute (CRI) to remove any trace of demonic activity. You have a blaster and you feel no pain. And you are not alone: kill demons to call backups!\n\nRating   : {YMEDIUM}",
        rating = "MEDIUM",
        abbr   = "AoCh",
        letter = "C",
    },
    challenge = {
        type      = "challenge",
    },
    callbacks = {
        on_create_player = [[
            function( self, player )
                local egun  = player:child("pistol") or player:child("rpistol")
                if egun then world:destroy( egun ) end
                local eammo = player:child("ammo_9mm") or player:child("ammo_44") 
                if eammo then world:destroy( eammo ) end
                player:attach( "cpiod_cri_clearance" )
                player:attach( "exo_blaster" )
                player:equip( "armor_cri" )
                player.equipment.count = 1
                player.attributes.inv_capacity = 4
                player.attributes.health = 35
                player.attributes.pain_effect = 0.0
                player:attach( "trait_call_cri" )
            end
        ]],
    },
}

