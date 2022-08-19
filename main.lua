register_blueprint "runtime_nudity"
{
    flags = { EF_NOPICKUP }, 
    text = {
        denied = "You won’t hide that perfect body!",
    },
    callbacks = {
        can_pickup = [[
            function( self, player, item )
                if item.armor or item.helmet then
                    ui:set_hint( self.text.denied, 1001, 0 )
                    world:play_voice( "vo_refuse" )
                    return -1
                end
                return 0
            end
        ]],
    },
}

register_blueprint "challenge_nudity"
{
    text = {
        name   = "Angel of Nudity",
        desc   = "You love your body and you will happily expose it to zombies, bots and demons. As such, you cannot wear any armor or helmet.\n\nRating   : {GEASY}",
        rating = "EASY",
        abbr   = "AoNu",
        letter = "N",
    },
    challenge = {
        type      = "challenge",
    },
    callbacks = {
        on_create_player = [[
            function( self, player )
                player:attach( "runtime_nudity" )
            end
        ]],
    },
}

register_blueprint "runtime_darkness"
{
    flags = { EF_NOPICKUP }, 
    callbacks = {
        on_enter_level = [=[
            function ( self, entity, reenter )
                local l = world:get_level()
                l.level_info.light_range = 4
                l.level_info.low_light = true
			end
		]=],
    },
}

register_blueprint "challenge_darkness"
{
    text = {
        name   = "Angel of Darkness",
        desc   = "The world is a dark place.\n\nRating   : {GEASY}",
        rating = "EASY",
        abbr   = "AoDa",
        letter = "D",
    },
    challenge = {
        type      = "challenge",
    },
    callbacks = {
        on_create_player = [[
            function( self, player )
                player:attach( "runtime_darkness" )
            end
        ]],
    },
}

register_blueprint "chall_event_volatile_storage"
{
    callbacks = {
        on_create = [[
            function ( self )
            end
        ]],
        on_enter_level = [[
            function ( self, level, entity, reenter )
                if reenter then return end
                generator.generate_litter( level, level:get_area(), {
                    litter    = { "barrel_fuel", "barrel_toxin", "barrel_acid", "barrel_cryo", "barrel_napalm" },
                    chance    = 66,
                    max_count = 80,
                })
            end
        ]],
    }
}

register_blueprint "challenge_volatility"
{
    text = {
        name   = "Angel of Volatility",
        desc   = "Ready for an explosive experience?\n\nRating   : {GEASY}",
        rating = "EASY",
        abbr   = "AoVo",
        letter = "V",
    },
    challenge = {
        type      = "challenge",
    },
    callbacks = {
        on_create = [[
            function( self, player )
                for i,linfo in ipairs( world.data.level ) do
                    linfo.event = "chall_event_volatile_storage"
                end
            end
        ]],
    },
}

register_blueprint "runtime_bullet_rain"
{
    flags = { EF_NOPICKUP },
    attributes = {
        shots = 100,
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
        desc   = "You just like a nice bullet rain, you know? Because there can’t be 'too much lead'. Each time you shoot, you empty your magazine! Of course, melee and revolver are forbidden. They are no fun!\n\nRating   : {GEASY}",
        rating = "EASY",
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


