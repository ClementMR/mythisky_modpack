--[[
Copyright (C) 2025
Smnoe01 (Atlante) (discord: smnoe01)
Attribution-NonCommercial-ShareAlike 4.0 International
]]

local modname = core.get_current_modname()
local S = core.get_translator(modname)
local http = core.request_http_api()

local system_config = {
    webhook_url = core.settings:get("server_suggestion_webhook_url") or nil,
    maximum_characters = tonumber(core.settings:get("maximum_characters")) or 500,
    minimum_characters = tonumber(core.settings:get("minimum_characters")) or 20,
    cooldown_duration = tonumber(core.settings:get("cooldown_duration")) or 300,
}

local last_suggestion_time = {}

local function sanitize_message(message)
    if not message then return "" end

    -- On évite les message de ce genre
    message = message:gsub("@everyone", "everyone")
    message = message:gsub("@here", "here")

    message = message:gsub("http", "")
    message = message:gsub("https", "")

    return message
end

local function send_webhook(suggester, suggestion)
    local clean_suggester_name = sanitize_message(suggester)
    local clean_suggestion_message = sanitize_message(suggestion)

    local embed = {
        title = "[In-Game Suggestion]",
        -- Couleur hexadécimal convertie en décimal pour discord
        color = 4766173,
        fields = {
            {name = "Player: ", value = clean_suggester_name, inline = true},
            {name = "Suggestion: ", value = clean_suggestion_message, inline = false},
        },
        footer = {text = "In-Game Suggestion Logger"},
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }

    local json = core.write_json({embeds = {embed}})

    http.fetch({
        url = system_config.webhook_url,
        method = "POST",
        extra_headers = {"Content-Type: application/json"},
        data = json,
    },

    function(res)
        if not res.succeeded then
            core.log("error", "[Wekhook] Sending failed: (" .. (res.code or "unknown") .. ")")
        end
    end)
end

core.register_chatcommand("suggestion", {
    params = S("<message>"),
    description = S("Send a suggestion to the administrative team"),
    privs = {shout = true},
    func = function(name, param)
        if not http or not system_config.webhook_url then
            return false, S("The suggestion system is currently unavailable. Please contact the administrative team.")
        end

        if not param or param:trim() == "" then
            return false, S("Usage: /suggestion <message>")
        end

        -- Validation min/max de la longeur du message
        if #param < system_config.minimum_characters then
            return false, S("Message too short (Your message must contain at least @1 characters)",
            system_config.minimum_characters)
        elseif #param > system_config.maximum_characters then
            return false, S("Message too long (Maximum : @1 characters)", system_config.maximum_characters)
        end

        local current_time = os.time()
        local last_time = last_suggestion_time[name] or 0

        if current_time - last_time < system_config.cooldown_duration then
            local remaining = math.ceil(system_config.cooldown_duration - (current_time - last_time))
            return false, S("Please wait @1 seconds before using @2 again.", remaining, "/suggestion")
        end

        last_suggestion_time[name] = current_time

        send_webhook(name, param)

        return true, S("Your suggestion has been sent to the administrative team.")
    end,
})

core.log("action", "[Server Suggestion] Mod initialized, running version 1.1")
