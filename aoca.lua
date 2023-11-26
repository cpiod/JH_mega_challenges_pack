register_blueprint "runtime_carpentry"
{
    flags = { EF_NOPICKUP },
    text = {
        denied = "You prefer your nailgun",
    },
    callbacks = {
        can_pick_trait = [[
            function( self, player, trait_id )
                if trait_id == "trait_scavenger" then
                    return -1
                end
                return 0
            end
        ]],
        on_enter_level = [=[ -- remove all medical stations
            function ( self, entity, reenter )
                local level = world:get_level()
                for e in level:entities() do 
                    local id = world:get_id( e )
                    if id == "medical_station" then
                        world:destroy( e )
                    end
                end
            end
        ]=],
        on_pickup = [=[
            function ( self, user, item )
                local id = world:get_hid( item )
                local ammos =
                {
                    [world:hash("ammo_9mm")]      = {},
                    [world:hash("ammo_shells")]   = {},
                    [world:hash("ammo_762")]      = {},
                    [world:hash("ammo_44")]       = {},
                    [world:hash("ammo_40")]       = {},
                    [world:hash("ammo_rockets")]  = {},
                    [world:hash("ammo_cells")]    = {},
                }
                if ammos[ id ] then
                    item.stack.amount = 0
                    world:destroy( item )
                    user:equip( "kit_multitool", { stack = { amount = 1 } } )
                end
                return 0
            end
        ]=],
        can_pickup = [[
            function( self, player, item )
                if item and item.weapon then
                    if item.clip and item.clip.ammo == world:hash("kit_multitool") then
                        -- can pickup
                    else
                        ui:set_hint( self.text.denied, 1001, 0 )
                        world:play_voice( "vo_refuse" )
                        return -1
                    end
                end
            end
        ]],
    },
}

register_blueprint "challenge_carpentry"
{
    text = {
        name   = "Angel of Carpentry",
        desc   = "{!MEGA CHALLENGE PACK MOD}\nYou are not a fighter, but John, a humble carpenter. Against the demon invasion, your trusty nailgun. You didn’t ask for any of that. You start with 30 max HP and your inventory size is limited, but any ammo you pick up is transformed into a multitool!\n\nRating   : {YMEDIUM}\nDisabled : {dScavenger}",
        rating = "MEDIUM",
        abbr   = "AoCa",
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
                player:attach( "kit_multitool", { stack = { amount = 3 } } )
                player:attach( "exo_nailgun" )
                player:attach( "runtime_carpentry" )
                player.equipment.count = 1
                player.attributes.inv_capacity = 6
                player.attributes.health = 50
            end
        ]],
    },
}



