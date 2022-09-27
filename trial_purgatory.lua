-- Copyright (c) ChaosForge Sp. z o.o.
nova.require "data/lua/core/world"
nova.require "data/lua/jh/data/difficulty"
nova.require "data/lua/jh/data/generators/callisto"
nova.require "data/lua/jh/data/generators/europa"
nova.require "data/lua/jh/data/generators/io"
nova.require "data/lua/jh/data/generators/beyond"
nova.require "data/lua/jh/data/levels/callisto_intro"
nova.require "data/lua/jh/data/levels/callisto_spaceport"
nova.require "data/lua/jh/data/levels/europa"
nova.require "data/lua/jh/data/levels/europa_central_dig"
nova.require "data/lua/jh/data/levels/io"
nova.require "data/lua/jh/data/levels/beyond_intro"
nova.require "data/lua/jh/data/levels/beyond_crucible"
nova.require "data/lua/jh/data/levels/beyond_percipice"
nova.require "data/lua/jh/data/levels/cot/cot"

register_blueprint "runtime_boss_rexio"
{
    flags = { EF_NOPICKUP },
    callbacks = {
        on_die = [[
			function( self )
                ui:spawn_fx( nil, "fx_boss_die_1", nil, world:get_position( self ) )
                world:play_sound( "gib", self, 2.0 )
				world:play_sound( "boss_die_final", self )
				world:next_level( 1000 )
			end
        ]]
    },
}

register_blueprint "trial_purgatory"
{
	text = {
        name        = "Purgatory",
        desc        = "{!MEGA CHALLENGE PACK MOD}\nEnter the Purgatory and loot its uniques. But what’s that distant howling?…\n\nBEWARE: winning this trial will crash the game. No data will be lost.",
        rating 		= "TODO",
		abbr        = "Purg",
		mortem_line = "He witnessed the {!Purgatory}!",
        mortem_win  = "He defeated the {!Purgatory}!",
        win         = "PURGATORY DEFEATED!",
    },
	challenge = {
		type  = "trial",
        rank = 1,
		group = "trial_purgatory",
		score = false,
	},
	callbacks = {
        on_create_player = [[
            function( self, player )
                local egun  = player:child("pistol") or player:child("rpistol")
                if egun then world:destroy( egun ) end
                local eammo = player:child("ammo_9mm") or player:child("ammo_44") 
                if eammo then world:destroy( eammo ) end
                player:attach( "armor_green" )
                player:attach( "helmet_green" )
                player:attach( "auto_rifle" )
                player:attach( "pistol" )
                player:attach( "ammo_9mm", { stack = { amount = 50 } } )
                player:attach( "medkit_small", { stack = { amount = 3 } } )
                player:attach( "kit_phase" )
                player:attach( "kit_multitool", { stack = { amount = 3 } } )
            end
        ]],
        on_mortem = [[
            function( self, player, win )
            end
        ]],
    }
}

register_blueprint "level_cot_cpiod"
{
	blueprint   = "level_base",
    text = {
		name  = "Purgatory",
    },
    level_info = {
        returnable = true,
        store      = true,
    },
	level_vo = {
		silly   = 0.0,
		serious = 1.0,
    },
    attributes = {
        spawn_bulk = 0.0,
    },
	callbacks = {
		on_create = [[
			function ( self )
				self.environment.lut   = "lut_09_cot"
				self.environment.music = "music_cot_01"
                local generate = function( self, params )
                    return cpiod_cot_generate( self, params, 1678 )
                end
                local spawn = function( self )
                    return cot.spawn( self, 1678 )
                end
                generator.run( self, nil, generate, spawn )
			end
		]],
        on_enter_level = [[
            function ( self, player, reenter )
                ui:set_hint( " ", 666, 0, true )
                local cinfo = world.data.level[ world.data.current ]
                local newcinfocot = ""
                local convert = { n="U", e="R", w="L", s="D" }
                for i=1,#cinfo.cot do
                    local c = string.char(string.byte( cinfo.cot, i ))
                    newcinfocot = newcinfocot..convert[c]
                end
                self.text.name = "Purgatory "..tostring(newcinfocot)
                local curse   = player:child("cot_curse") or player:attach( "cot_curse" )
                local tick    = math.max( 2, ( DIFFICULTY * 2 ) - 1 )
                local current = curse.attributes.health_lost
                local hattr   = player.attributes.health
                if current < 80 and hattr > 20 then
                    curse.attributes.health_lost = current + tick
                    player.attributes.health     = hattr   - tick
                end
                curse.attributes.experience_mult = math.max( 1.0 - ( curse.attributes.health_lost * 0.02 ), 0.1 )
            end
        ]],
    }
}

function cpiod_cot_generate( self, params, code )
    if code ~= 1678 then return end
    local names = {
        shad   = "uni_armor_shadowcloak",
        cyber  = "uni_armor_cybersuit",
        exosui = "uni_armor_exosuit",
        fien   = "uni_helmet_fiendcrown",
        overl  = "uni_helmet_overlord",
        firecr = "uni_helmet_firecrown",
        thom   = "uni_rifle_thompson",
        hamme  = "uni_rifle_hammerhead",
        avalan = "uni_rifle_avalanche",
        scra   = "uni_scrapgun",
        vulca  = "uni_vulcan",
        apocal = "uni_apocalypse",
        bfgten = "uni_bfg",
        shadow = "uni_semi_shadowhunter",
        fire   = "uni_launcher_firestorm",
        calam  = "uni_launcher_calamity",
        exec   = "uni_knife",
        waves  = "uni_katana",
        soulst = "uni_sword",
        hate   = "uni_pistol_hate",
        death  = "uni_pistol_death",
        love   = "uni_revolver_love",
        veng   = "uni_semi_vengeance",
        blood  = "uni_semi_bloodletter",
        mons   = "uni_shotgun_monster",
        denia  = "uni_shotgun_denial",
        waveda = "uni_shotgun_wavedancer",
        carn   = "uni_smg_carnage",
        viper  = "uni_smg_viper",
        voidsm = "uni_smg_void",
    }
    local codes = {}
    for k,v in pairs( names ) do
        codes[ cot.name_to_code(k,code) ] = v
    end
    self:resize( ivec2( 37, 37 ) )
    generator.fill( self, "wall" )
    local cinfo = world.data.level[ world.data.current ]
    local depth = cinfo.depth
    local alien = false
    if depth > 1 and math.random(2) == 1 then
        self:set_styles{ "ts10_A", "ts10_A:corridor" }
        alien = true
    else
        self:set_styles{ "tsX_A", "tsX_A:deco" }
    end
    local larea  = self:get_area():shrinked(1) 
    local result = generator.archibald_area( self, larea, cot_9x9, {} )
    generator.checker_style( self, "gap" )
    generator.map_symmetry_y( self, 17 )
    generator.map_symmetry_x( self, 17 )
    result.area = larea
    result.no_elevator_check = true
    for c in self:coords( "marker2" ) do
        self:set_cell( c, "gap" )
        self:place_entity( "dante_gap_obelisk_01_A", c, generator.env_facing( c ) )
    end
    self.attributes.spawn_bulk = 1.0
    local root  = false
    if not cinfo.exit then
        cinfo.exit = {}
        cinfo.visited = true
        cinfo.cot = ""
        root = true
    end
    local ph     = world:get_player_hash()
    local code   = cot.number_to_code( ph, 5, code )
    local used   = false
    local add_exit = function( c, dir )
        self:set_cell( c, "floor_exit_"..dir )
        self:place_entity( "cot_plate_"..dir, c, ivec2(0,1) )
        self:place_entity( "cot_exit_"..dir, c )
        if not cinfo.exit[dir] then
            local rewards = { "lootbox_medical" }
            local count   = 4
            if depth > 12 or ( depth > 6 and ( depth % 2 > 0 ) ) then
                rewards = {}
            end
            if depth > 8 then 
                count = math.max( 4 - math.floor( depth / 8 ), 0 )
            end
            if depth > 3 and ( depth % 3 == 1 ) then 
                table.insert( rewards, "lootbox_special_3" )                
            end
            local dlevel = 6 + depth + DIFFICULTY * 2
            local eid = world.add_special{
                episode        = 1,
                depth          = depth + 1,
                blueprint      = "level_cot_cpiod",
                item_level     = dlevel,
                danger_level   = dlevel,
                branch_index   = 1,
                returnable     = true,
                lootbox_count  = count,
                cot            = cinfo.cot..dir,
                rewards        = rewards,
                intermission = {
                    scene     = "intermission_beyond",
                    music     = "music_main_01",
                    game_over = true,
                }
            }

            cinfo.exit[dir] = eid
            local einfo = world.data.level[ eid ]
            einfo.exit = {}
            einfo.exit[ cot.reverse( dir ) ] = world.data.current
        end
    end
    local add_exit_rexio = function( c, dir )
        self:set_cell( c, "floor_exit_"..dir )
        self:place_entity( "cot_plate_"..dir, c, ivec2(0,1) )
    end
    -- if depth >= 2 then
    if depth >= 8 then
        world:play_voice( "vo_beyond_boss" )
        local e = self:add_entity( "rexio", ivec2( 17,17 ) )
        e:attach( "runtime_boss_rexio" )
        e.flags.data[ EF_ACTION ]     = false
        e.flags.data[ EF_BUMPACTION ] = false
        e.text.name  = "The One Who Was Not Petted"
        e.text.entry  = "The One Who Was Not Petted"
        for i=1,10 do
            world:lua_callback(e, "level_up")
        end
        e.health.current = e.attributes.health
        if DIFFICULTY >= 3 then
            e.health.current = 2*e.attributes.health
        end
        -- e.health.current = 1
        for c in self:coords( "mark_elevator" ) do
            if c.x > 25 then add_exit_rexio(c,"w") end
            if c.x < 10 then add_exit_rexio(c,"e") end
            if c.y > 25 then add_exit_rexio(c,"n") end
            if c.y < 10 then add_exit_rexio(c,"s") end
        end

    else
        for c in self:coords( "mark_elevator" ) do
            if c.x > 25 then add_exit(c,"w") end
            if c.x < 10 then add_exit(c,"e") end
            if c.y > 25 then add_exit(c,"n") end
            if c.y < 10 then add_exit(c,"s") end
        end
    end
    if root then
        local ec = coord( 17,17 )
        self:set_cell( ec, "floor_entrance" )
        self.attributes.spawn_bulk = 0.0
        used = true
    end
    if alien then
        self:transform( "bridge", "floor" )
    end
    if not used and codes[ cinfo.cot ] then
        local code = codes[ cinfo.cot ]
        if type( code ) == "number" then
            local e = self:place_entity( "cot_portal", ivec2( 17,17 ) )
            e.data.target_index = code
            e.data.restore      = 1
        elseif type( code ) == "string" then
            self:place_entity( code, ivec2( 17,17 ) )
        end
    end
    generator.generate_litter( self, nil, {
        litter = { "crate_dante", "barrel_dante", 
        { "crate_dante_group", 0.2 } },
        chance = 25,
        alt    = "altfloor",
        exclude = larea:shrinked( 10 ),
    })
    for c in self:coords( "marker3" ) do
        self:set_cell( c, "floor" )
        self:place_entity( "dante_obelisk_02", c, generator.env_facing( c ) )
    end
    result.no_elevator_check = true
    return result
end

register_world "trial_purgatory"
{
    on_create = function( seed )
        local data = world.setup( seed )
        data.cot = {}
        data.cot.level_index = world.add_special {
            episode        = 1,
            depth          = 1,
            blueprint      = "level_cot_cpiod",
            lootbox_count  = 4,
            ilevel_mod     = 1,
            dlevel_mod     = 1,
            branch_index   = 1,
            returnable     = true,
            rewards        = {},
            intermission = {
                scene     = "intermission_beyond",
                music     = "music_main_01",
                game_over = true,
            }
        }
        data.cot.boss_index = 25
        data.level[1].blueprint = "level_cot_cpiod"
		world.data.unique.guaranteed = 0
		world.data.special_levels = 0
    end,
    on_next = function( next )
        return world.next( next )
    end,
    on_load = function( player )
        world.initialize()
        core.global_mod.exotic      = 2.0
        world.set_klass( player.text.klass )
    end,
    on_init = function( player )
        world.set_klass( player.text.klass )
        player.statistics.data.special_levels.generated  = 0
        player.statistics.data.special_levels.accessible = 0
    end,
	on_end   = function( player, result )
		if result > 0 then
			ui:alert{
				delay = 1000,
				position = ivec2( -1, 18 ),
				size = ivec2( 30, 6 ),
				content = "     {R"..world:get_text("trial_purgatory","win").."}\n "..ui:text("ui.lua.common.continue"),
				footer = " ",
				win = true,
			}
		elseif result == 0 then
			ui:post_mortem( result, true )
			ui:dead_alert()
		elseif result < 0 then
			ui:post_mortem( result, true )
		end
	end,
    on_stats = function( player, win )
    end,
    on_entity = function( entity )
        diff.on_entity( entity )
    end,
}
