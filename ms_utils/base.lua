function ms_utils.bool_or(value, default)
    if value ~= nil then
        return value
    end

    return default
end

function ms_utils.number_or(value, default)
    local number = tonumber(value)
    if number ~= nil then
        return number
    end

    return default
end

function ms_utils.copy_sequence(value, default)
    local source = value
    if type(source) ~= "table" then
        source = default or {}
    end

    local copy = {}
    for _, item in ipairs(source) do
        table.insert(copy, item)
    end

    return copy
end

function ms_utils.contains(list, expected)
    if type(list) ~= "table" then
        return false
    end

    for _, value in ipairs(list) do
        if value == expected then
            return true
        end
    end

    return false
end

function ms_utils.is_vector(value)
    return type(value) == "table"
        and type(value.x) == "number"
        and type(value.y) == "number"
        and type(value.z) == "number"
end
