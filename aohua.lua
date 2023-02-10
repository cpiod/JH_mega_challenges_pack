register_blueprint "runtime_hubris_again"
{
    flags = { EF_NOPICKUP },
    text = {
        choose = "Choose your weapon",
    },
    callbacks = {
        on_enter_level = [=[
            function ( self, entity, reenter )
                if not reenter and world.data.current == 15 then
                    local weapons = {
                        "exo_katana","uni_revolver_love","esmg","exo_railgun","uni_rifle_hammerhead","uni_vulcan", "uni_shotgun_monster","uni_launcher_calamity"
                    }
                    local param = {
                        title = self.text.choose,
                        size  = coord( 34, 0 ),
                    }
                    for i,id in ipairs( weapons ) do
                        param[i] = { name = world:get_text( id, "name" ), target = self, id = id, }
                    end
                    -- rewrite the Love one
                    param[2].name = "Love and Hate"
                    ui:terminal( entity, self, param )
                end
            end
        ]=],
        on_activate = [=[
            function( self, who, level, param, id )
                id = world:resolve_hash( id )
                local info = { 
                    uni_shotgun_monster = { "ammo_shells", 50, 2 },
                    uni_vulcan = { "ammo_762", 100, 2 },
                    uni_rifle_hammerhead    = { "ammo_762", 100 },
                    exo_railgun = { "ammo_cells", 100 },
                    uni_launcher_calamity = { "ammo_cells", 100 },
                    uni_revolver_love = { "ammo_44", 50 },
                    exo_smg = { "ammo_cells", 100 },
                    exo_katana       = { "stimpack_small", 1, 1 },
                }
                who:pickup( "armor_blue" )
                who:pickup( id )
                if id == "uni_revolver_love" then
                    who:equip( "uni_pistol_hate" )
                    who:equip( "ammo_762", { stack = { amount = 50 } } )
                end
                local count = info[id][3] or 1
                for _=1,count do
                    who:equip( info[id][1], { stack = { amount = info[id][2] } } )
                end
                return 0
            end
        ]=],
    },
}

register_blueprint "challenge_hubris_again"
{
    text = {
        name   = "Angel of Hubris, Again",
        desc   = "{!MEGA CHALLENGE PACK MOD}\nOverconfidence? Nah, pure hubris! You don't need all that junk and experience, you can tackle Io from the get go! To help out you get a bunch of small medkits, a blue armor, a phase device, and a choice of exotic weapon.\n\nRating   : {YMEDIUM}",
        rating = "MEDIUM",
        abbr   = "AoH",
        letter = "H",
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
                player:attach( "runtime_hubris_again" )
                player:attach( "medkit_small", { stack = { amount = 2 } } )
                player:attach( "kit_phase" )
                world.data.current = 15
            end
        ]],
    },
}

