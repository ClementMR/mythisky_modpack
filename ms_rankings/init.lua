local storage = core.get_mod_storage()
local stats = core.deserialize(storage:get_string("player_stats")) or {}

local update_timer = 10
local radius = 10

local function save_stats()
    storage:set_string("player_stats", core.serialize(stats))
end

local function inc_stat(name, stat)
    if not stats[name] then stats[name] = {} end
    if not stats[name][stat] then stats[name][stat] = 0 end
    stats[name][stat] = stats[name][stat] + 1
end

local function get_leaderboard()
    local t = {}
    for name, s in pairs(stats) do
        table.insert(t, {name = name, v = s["kills"] or 0})
    end
    table.sort(t, function(a, b) return a.v > b.v end)
    local res = {"  [leaderboard]"}
    for i = 1, math.min(5, #t) do
        table.insert(res, i .. "." .. t[i].name .. " [" .. t[i].v .. " kills]")
    end
    return res
end

local function add_text(pos, text, yaw)
    local offset = 0
    text = text:lower()
    for i = 1, #text do
        local texture
        local char = text:sub(i, i)
        if char:match("%a") then texture = "mythisky_letter_" .. char .. ".png^[colorize:yellow:200"
        elseif char:match("%d") then texture = "mythisky_number_" .. char .. ".png^[colorize:yellow:200"
        elseif char == "." then texture = "mythisky_dot.png^[colorize:purple:200"
        elseif char == "_" then texture = "mythisky_underscore.png^[colorize:yellow:200"
        elseif char == "[" then texture = "mythisky_op_square_bracket.png^[colorize:purple:200"
        elseif char == "]" then texture = "mythisky_cl_square_bracket.png^[colorize:purple:200"
        else texture = "blank.png" end

        local dx = math.cos(yaw) * offset * 0.17
        local dz = math.sin(yaw) * offset * 0.17
        local ent = core.add_entity({x = pos.x + dx, y = pos.y, z = pos.z + dz}, "ms_rankings:leaderboard")
        if ent then
            ent:get_luaentity().ent_child = true
            ent:get_luaentity().object:set_yaw(yaw)

            ent:get_luaentity().ent_textures = texture
            ent:get_luaentity().object:set_properties({textures = {texture}})
        end
        offset = offset + 1
    end
end

core.register_entity("ms_rankings:leaderboard", {
    initial_properties = {
        visual = "upright_sprite",
        textures = {"blank.png"},
        physical = false,
        pointable = false,
        visual_size = {x = 0.2, y = 0.2},
    },
    timer = 0,
    on_step = function(self, dtime)
        self.timer = self.timer + dtime

        if self.timer > update_timer then
            if self.ent_textures then
                self.object:set_properties({textures = {self.ent_textures}})
            end

            if self.ent_mother == true then
                local pos = self.object:get_pos()
                core.after(0.1, function()
                    for _, obj in ipairs(core.get_objects_inside_radius(pos, radius)) do
                        local luaent = obj:get_luaentity()
                        if luaent and luaent.ent_child then
                            obj:remove()
                        end
                    end

                    for i, line in ipairs(get_leaderboard()) do
                        add_text({x = pos.x, y = pos.y - (i-1)*0.5, z = pos.z}, line, self.ent_yaw)
                    end
                end)
            end

            self.timer = 0
        end
    end,
    on_activate = function(self, staticdata)
        if staticdata and staticdata ~= "" then
            local data = core.deserialize(staticdata)
            if data then
                self.ent_textures = data.ent_textures
                self.ent_mother = data.ent_mother
                self.ent_child = data.ent_child
                self.ent_yaw = data.ent_yaw
            end
        end

        if self.ent_textures then
            self.object:set_properties({textures = {self.ent_textures}})
        end

        if self.ent_mother == true then
            local pos = self.object:get_pos()
            core.after(0.1, function()
                for _, obj in ipairs(core.get_objects_inside_radius(pos, radius)) do
                    local luaent = obj:get_luaentity()
                    if luaent and luaent.ent_child then
                        obj:remove()
                    end
                end

                for i, line in ipairs(get_leaderboard()) do
                    add_text({x = pos.x, y = pos.y - (i-1)*0.5, z = pos.z}, line, self.ent_yaw)
                end
            end)
        end
    end,
    get_staticdata = function(self)
        return core.serialize({
            ent_textures = self.ent_textures or "blank.png",
            ent_mother = self.ent_mother or false,
            ent_child = self.ent_child or false,
            ent_yaw = self.ent_yaw or 0,
        })
    end
})

core.register_craftitem("ms_rankings:leaderboard", {
    description = "Leaderboard (Entity Spawner)",
    groups = {not_in_creative_inventory = 1},
    stack_max = 1,
    on_place = function(itemstack, placer, pointed_thing)
        if pointed_thing.type ~= "node" then
            return itemstack
        end

        local yaw = placer:get_look_horizontal() or 0
        local pos = pointed_thing.above
        local ent = core.add_entity(pos, "ms_rankings:leaderboard")
        if ent then
            for _, obj in ipairs(core.get_objects_inside_radius(pos, radius)) do
                local luaent = obj:get_luaentity()
                if luaent and (luaent.ent_mother or luaent.ent_child) then
                    obj:remove()
                end
            end

            ent:get_luaentity().ent_mother = true
            ent:get_luaentity().ent_yaw = yaw
            ent:get_luaentity().object:set_yaw(yaw)

            for i, line in ipairs(get_leaderboard()) do
                add_text({x = pos.x, y = pos.y - (i-1)*0.5, z = pos.z}, line, yaw)
            end
        end
    end
})

core.register_alias("leaderboard", "ms_rankings:leaderboard")

core.register_on_dieplayer(function(_, reason)
    if reason.type == "punch" then
        local puncher_name = reason.object:get_player_name()
        if reason.object:is_player() then
            inc_stat(puncher_name, "kills")
        end
    end
end)

local timer = 0
core.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer > update_timer then
        save_stats()
        timer = 0
    end
end)

core.register_on_shutdown(save_stats)