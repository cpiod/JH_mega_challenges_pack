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


register_blueprint "runtime_monomania"
{
    flags = { EF_NOPICKUP },
    text = {
        choose = "Choose your weapon",
        denied = "Changing weapon? Heresy!",
        denied_drop = "Dropping weapon? Heresy!",
    },
    attributes = {
        cannot_pick_up = true
    },
    callbacks = {
        -- TODO: can drop?
        can_pick_trait = [[
            function( self, player, trait_id )
                if trait_id == "trait_scavenger" then
                    return -1
                end
                return 0
            end
        ]],
        on_pickup = [=[
            function ( self, user, item )
                local id    = world:get_hid( item )
                local ammos  = 
                {
                    [world:hash("ammo_9mm")]      = { id = "ammo_9mm", },
                    [world:hash("ammo_shells")]   = { id = "ammo_shells",},
                    [world:hash("ammo_762")]      = { id = "ammo_762", },
                    [world:hash("ammo_44")]       = { id = "ammo_44", },
                    [world:hash("ammo_40")]       = { id = "ammo_40", },
                    [world:hash("ammo_rockets")]  = { id = "ammo_rockets",},
                    [world:hash("ammo_cells")]    = { id = "ammo_cells",},
                }
                if ammos[ id ] then
                    local wid    = world:hash("ammo_shells")
                    local weapon = user:get_weapon()
                    if weapon and weapon.clip then
                        wid = weapon.clip.ammo
                    end
                        
                    if wid ~= id and ammos[wid] and item.stack.amount > 0 then
                        local amount = item.stack.amount
                        item.stack.amount = 0
                        world:destroy( item )
                        local rate = 8
                        if ammos[wid].id == "ammo_9mm"   then rate = 4 end
                        amount = math.max( math.floor( amount / rate ), 1 )
                        user:equip( ammos[wid].id, { stack = { amount = amount } } )
                    end
                end
                return 0
            end
        ]=],
        can_pickup = [[
            function( self, player, item )
                if item and item.weapon and self.attributes.cannot_pick_up then
                    ui:set_hint( self.text.denied, 1001, 0 )
                    world:play_voice( "vo_refuse" )
                    return -1
                end
            end
        ]],
        on_enter_level = [=[
            function ( self, entity, reenter )
                if not reenter and world.data.current == 1 then
                    local weapons = {
                        "exo_cpistol", "exo_dpistol", "exo_jpistol",
                        "exo_jshotgun", "exo_fshotgun",
                        "exo_jsmg", "exo_csmg", "exo_ssmg",
                        "exo_ac_rifle", "exo_gatling_gun", 
                        "exo_sword",
                    }
                    local param = {
                        title = self.text.choose,
                        size  = coord( 34, 0 ),
                    }
                    for i,id in ipairs( weapons ) do
                        param[i] = { name = world:get_text( id, "name" ), target = self, id = id, }
                    end
                    ui:terminal( entity, self, param )
                end
            end
        ]=],
        on_activate = [=[
            function( self, who, level, param, id )
                id = world:resolve_hash( id )
                local info = { 
                    exo_cpistol = { "ammo_9mm", 100 },
                    exo_dpistol = { "ammo_44",  50 },
                    exo_jpistol = { "ammo_44",  50 },
                    exo_jshotgun = { "ammo_shells", 50, 2 },
                    exo_fshotgun = { "ammo_9mm", 100 },
                    exo_jsmg = { "ammo_44",  50, 2 },
                    exo_csmg = { "ammo_762", 100, 2 },
                    exo_ssmg = { "ammo_9mm", 100, 3 },
                    exo_ac_rifle    = { "ammo_762", 100 },
                    exo_gatling_gun = { "ammo_762", 100, 2 },
                    exo_sword       = { "stimpack_small", 1, 1 },
                }
                who:pickup( id )
                local count = info[id][3] or 1
                for _=1,count do
                    who:equip( info[id][1], { stack = { amount = info[id][2] } } )
                end
                self.attributes.cannot_pick_up = false
                return 0
            end
        ]=],
    },
}

register_blueprint "challenge_monomania"
{
    text = {
        name   = "Angel of Monomania",
        desc   = "You are a sentimental. You went through so many hardships with her… so you’ll keep up until the end! You cannot change weapon.\nTo make things easier, ammo picked up gets converted to a small amount of the ammo type of your beloved weapon.\n\nRating   : {YMEDIUM}\nDisabled : {dScavenger}",
        rating = "MEDIUM",
        abbr   = "AoMo",
        letter = "M",
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
                player:attach( "runtime_monomania" )
                player.equipment.count = 1
            end
        ]],
    },
}

