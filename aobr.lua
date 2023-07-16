
register_blueprint "runtime_bullet_rain"
{
    flags = { EF_NOPICKUP },
    attributes = {
        shots = 1000,
    },
    text = {
        denied_melee = "That would be cheatin', go play Berserk instead!",
        denied_revolver = "That would be cheatin', go play Marksman instead!",
    },
	callbacks = {
        can_pickup = [[
            function( self, player, item )
                if item and item.weapon and (not item.stack) then
                    local clip_data = item.clip
                    if clip_data and item.weapon.group == world:hash("pistols") and clip_data.reload_count == 1 and clip_data.count > 1 then
                        ui:set_hint( self.text.denied_revolver, 1001, 0 )
                        world:play_voice( "vo_refuse" )
                        return -1
                    end

                    if item.weapon.group == world:hash("melee") then
                        ui:set_hint( self.text.denied_melee, 1001, 0 )
                        world:play_voice( "vo_refuse" )
                        return -1
                    end
                end
            end
        ]]
    }
}

register_blueprint "challenge_bullet_rain"
{
    text = {
        name   = "Angel of Bullet Rain",
        desc   = "{!MEGA CHALLENGE PACK MOD}\nYou just like a nice bullet rain, you know? Because there can’t be 'too much lead'. Each time you shoot, you empty your magazine! Of course, melee and revolver are forbidden. They are no fun!\n\nRating   : {YMEDIUM}",
        rating = "MEDIUM",
        abbr   = "AoBR",
        letter = "B",
    },
    challenge = {
        type      = "challenge",
    },
    callbacks = {
        on_create_player = [[
            function( self, player )
                player:attach( "runtime_bullet_rain" )
                local egun  = player:child("pistol") or player:child("rpistol")
                if egun then world:destroy( egun ) end
                local eammo = player:child("ammo_9mm") or player:child("ammo_44") 
                if eammo then world:destroy( eammo ) end
                player:attach( "pistol" )
                player:attach( "ammo_9mm", { stack = { amount = 32 } } )
            end
        ]],
    },
}


