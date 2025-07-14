local settings = require("src.settings")
local misc = {}

--- @param key_table table
--- @return boolean
function misc.is_pressed(key_table)
    for _, key in ipairs(key_table) do
        if love.keyboard.isDown(key) then
            return true
        end
    end
    return false
end

--- @param value number
--- @param minValue number
--- @param maxValue number
--- @return number
function misc.clamp(value, minValue, maxValue)
    if value > maxValue then value = maxValue end
    if value < minValue then value = minValue end
    return value
end

function misc.remove_from_list(table, value) -- Removes value by shifting values preceeding it to the left, instead of the cliche nil
    local found = false -- If true, from the coord 'i' all elements will be shitfted to the left
    for i = 1, #table, 1 do
        if not found and table[i] == value then found = true end
        if found then
            table[i] = table[i + 1]
        end
    end
end

function misc.get_row_and_col_from_index(i, cols)
    local c = (i - 1) % cols + 1
    local r = math.ceil(i / cols)

    return {r=r, c=c}
    
end

function misc.save_high_score(score)
    local current_highscore = misc.load_high_score()
    if score > current_highscore then love.filesystem.write(settings.highscore_file_path, tostring(score)) end 
end

function misc.load_high_score()
    if love.filesystem.getInfo(settings.highscore_file_path) then
        local contents = love.filesystem.read(settings.highscore_file_path)
        return tonumber(contents) or 0
    else
        return 0
    end
end

return misc