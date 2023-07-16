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
                    if not player:child( "cri_clearance" ) then
                        player:attach( "cri_clearance" )
                    end
                    local episode = world:get_level().level_info.episode
                    local ids     = { "cri_marine", "cri_bot",}
                    local count   = 2 * episode - 1
                    for _=1,count do
                        local id = ids[ math.random( #ids ) ]
                        local b  = world:create_entity( id )

                        b.data.cri_clearanced = true
                        b.flags.data[ EF_BUMPACTION ] = true
                        aitk.convert( b, world:get_player(), false, false, true, true )
                        b.data.ai.idle  = "active_hunt_no_player"
                        b.data.ai.state = "active_hunt_no_player"
                        b.attributes.experience_value = 0
                        world:add_transfer( b )
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



