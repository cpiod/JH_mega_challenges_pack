function get_code(str)
    if str then
        local start_pos = 1+str:find(")") -- find the end of the function definition
        local i = 0
        local end_pos = 0
        while i do
            end_pos = i-1
            i = str:find("end", i+1)
        end
        return str:sub(start_pos, end_pos)
    end
    return "" -- no callback
end

--bugs: "use medkit" visible in inventory
--bugs: new york reload no weapon on enemies

register_blueprint "runtime_triple_angel"
{
    flags = { EF_NOPICKUP },
    data = {
        nb_choice = 1,
        reload_challenge = false
    },
    callbacks = {
        on_enter_level = [=[
            function ( self, entity, reenter )
                if not reenter and world.data.current == 1 then
                    local ch = {"challenge_rocket","challenge_marksmanship","challenge_shotgunnery","challenge_berserk","challenge_reload"}
                    local param = {
                        title = "Choose your weapon challenge (1/3)",
                        fsize = 15,
                        size  = coord( 40, 0 ),
                    }
                    for i,id in ipairs( ch ) do
                        param[i] = { desc = world:get_text(id, "desc"), name = world:get_text( id, "name" ), target = self, id = id, }
                    end
                    ui:terminal( entity, self, param )
                end
            end
        ]=],
        -- hack for new york reload challenge
        on_create_entity = [=[
            function( self, entity, alive )
                nova.log("reload? "..tostring(self.data.reload_challenge))
                if self.data.reload_challenge and alive then
                    local id = world:get_id( entity )
                    if id == "summoner" or id == "exalted_summoner" then
                        entity.attributes.gate = 666
                    elseif id == "boss_damage_gate" then
                        entity.attributes.gate = 666
                    else
                        local w = entity:get_weapon()
                        if w and w.weapon and w.weapon.natural then
                            if not entity.inventory then
                                ecs:add( entity, "inventory" )
                            end
                            local ilvl = world:get_level().level_info.ilevel
                            local item 
                            if math.random(10) == 1 then
                                item = core.lists.item.weapon:roll( ilvl )
                            else
                                item = core.lists.item.base_weapon:roll( ilvl )
                            end

                            if item then
                                entity:stash_item( item )
                            end
                        end
                    end
                end
            end
        ]=],
        on_activate = [=[
            function( self, who, level, param, id )
                id = world:resolve_hash( id )
                if id == "challenge_reload" then
                    self.data.reload_challenge = true
                    nova.log("reload detected!")
                end
                nova.log("cpiod id: "..tostring(id))
                -- execute challenge code
                local str = "local player = world:get_player()\nlocal level = world:get_level()\n"..get_code(blueprints[id].callbacks["on_create"]).."\n"..get_code(blueprints[id].callbacks["on_create_player"])
                str = str:gsub("world:destroy%(","level:drop_item(player,")
                local new_str = ""
                local i = 0
                local prev = 0
                while i do
                    prev = i
                    i = str:find("\n", i+1)
                    if i then
                        local line=str:sub(prev,i)
                        -- keep runtimes as attached, modify the rest to equip
                        nova.log("match? "..tostring(line:find("runtime_")))
                        if line:find("attach%( \"runtime_")==nil then
                            line = line:gsub("attach","equip")
                        end
                        nova.log(line)
                        new_str = new_str..line
                    end
                end
                loadstring(new_str)()
                if self.data.nb_choice < 3 then
                    local ch = {}
                    local title = ""
                    if self.data.nb_choice==1 then
                        ch = {"challenge_light_travel","challenge_vampirism","challenge_impatience","challenge_doom","challenge_mercy","challenge_exalted"}
                        title = "Choose your modifier challenge (2/3)"
                    else
                        ch = {"challenge_he","challenge_no_retreat","challenge_real_time","challenge_darkness"}
                        title = "Choose your modded challenge (3/3)"
                    end
                    self.data.nb_choice = self.data.nb_choice + 1
                    local param = {
                        title = title,
                        fsize = 15,
                        size  = coord( 40, 0 ),
                    }
                    for i,id in ipairs( ch ) do
                        param[i] = { desc = world:get_text(id, "desc"), name = world:get_text( id, "name" ), target = self, id = id, }
                    end
                    ui:terminal( entity, self, param )
                end
                return 0
            end
        ]=],
    },
}

register_blueprint "challenge_triple_angel"
{
    text = {
        name   = "Triple Angel",
        desc   = "{!MEGA CHALLENGE PACK MOD}\nPlay three challenges at once!\n\nRating   : {RHARD}",
        rating = "HARD",
        abbr   = "AoT",
        letter = "T",
    },
    -- hack for new york reload challenge
    on_create_entity = [=[
        function( self, entity, alive )
            local player = world:get_player()
            nova.log("reload? "..tostring(self.data.reload_challenge))
            if false and alive then
                local id = world:get_id( entity )
                if id == "summoner" or id == "exalted_summoner" then
                    entity.attributes.gate = 666
                elseif id == "boss_damage_gate" then
                    entity.attributes.gate = 666
                else
                    local w = entity:get_weapon()
                    if w and w.weapon and w.weapon.natural then
                        if not entity.inventory then
                            ecs:add( entity, "inventory" )
                        end
                        local ilvl = world:get_level().level_info.ilevel
                        local item 
                        if math.random(10) == 1 then
                            item = core.lists.item.weapon:roll( ilvl )
                        else
                            item = core.lists.item.base_weapon:roll( ilvl )
                        end

                        if item then
                            entity:stash_item( item )
                        end
                    end
                end
            end
        end
    ]=],
    challenge = {
        type      = "challenge",
    },
    callbacks = {
        on_create_player = [[
            function( self, player )
                player:attach( "runtime_triple_angel" )
            end
        ]],
    },
}

