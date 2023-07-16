register_blueprint "runtime_arrogance"
{
    flags = { EF_NOPICKUP },
    attributes = {
        aort_prev_time = 0
    },
	callbacks = {
        on_enter_level = [[
            function ( self )
                world:add_experience(world:get_player(), 3000)
            end
        ]],
    }
}

register_blueprint "challenge_arrogance"
{
    text = {
        name   = "Angel of Arrogance",
        desc   = "No time to lose exploring the moons of Jupiter: defeat the Harbinger, now!\n\nRating   : {RHARD}",
        rating = "HARD",
        abbr   = "AoA",
        letter = "A",
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
                local emed = player:child("medkit_small")
                if emed then world:destroy( emed ) end
                player:attach( "ancient_medkit" )
                player:attach( "ancient_medkit" )
                player:attach( "ancient_pack_hallowed" )
                player:attach( "ancient_elixir_health" )
                player:attach( "ancient_elixir_blood" )
                player:attach( "ancient_elixir_power" )
                player:attach( "ancient_elixir_fire" )
                player:attach( "exo_ancient_gun" )
                player:attach( "exo_ancient_sword" )
                player:attach( "ancient_relic_ancient_armband" )
                player:attach( "runtime_arrogance" )
                world.data.current = 25
            end
        ]],
    },
}

