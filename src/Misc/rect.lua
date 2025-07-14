local rect = {x = 0, y = 0, w = 0, h = 0}
local settings = require("src.settings")
rect.__index = rect

function rect.new(x, y, w, h)
    local self = setmetatable({}, rect)

    self.x = x or 0
    self.y = y or 0
    self.w = w or 0
    self.h = h or 0
    

    return self
end

function rect:display_info()
    print("Rect: ".."X: "..self.x, "Y: "..self.y, "W: "..self.w, "H: "..self.h)
end

function rect:get_center()
    return {x=self.x + self.w / 2, y=self.y + self.h / 2}
end

function rect:draw()
    love.graphics.setColor(settings.Colors.debug.r, settings.Colors.debug.g, settings.Colors.debug.b)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
end

function rect:collides_with(other_rect)
    return self:collides_horizontally(other_rect) and self:collides_vertically(other_rect)
end

function rect:collides_horizontally(other_rect)
    local l1, r1, l2, r2

    l1, r1 = self.x, self.x + self.w
    l2, r2 = other_rect.x, other_rect.x + other_rect.w

    -- If this rects x is betwwen the others left and right coords or vice versa
    if (l1 > l2 and l1 < r2) or (l2 > l1 and l2 < r1) then return true end
    return false
end

function rect:collides_vertically(other_rect)
    local t1, b1, t2, b2 -- Other rects top and bottom coordinates

    t1, b1 = self.y, self.y + self.h
    t2, b2 = other_rect.y, other_rect.y + other_rect.h

    -- If this rects y is betwwen the others top and bottom coords or vice versa
    if (t1 > t2 and t1 < b2) or (t2 > t1 and t2 < b1) then return true end
    return false
end

function rect:collided_on_the_side(other_rect)
    local l1, r1 = self.x, self.x + self.w
    local t1, b1 = self.y, self.y + self.h
    local l2, r2 = other_rect.x, other_rect.x + other_rect.w
    local t2, b2 = other_rect.y, other_rect.y + other_rect.h

    -- Calculate overlap on both axes
    local horizontal_overlap = math.min(r1, r2) - math.max(l1, l2)
    local vertical_overlap = math.min(b1, b2) - math.max(t1, t2)

    -- If they don't actually overlap, return false
    if horizontal_overlap <= 0 or vertical_overlap <= 0 then
        return false
    end

    -- Side collision if horizontal overlap is smaller
    return horizontal_overlap < vertical_overlap
end

function rect:collision_side(other_rect)
    if self:collided_on_the_side(other_rect) then
        if self:get_center().x < other_rect:get_center().x then
            return "left"  -- self hit other from the left
        else
            return "right" -- self hit other from the right
        end
    else
        if self:get_center().y < other_rect:get_center().y then
            return "top"
        else
            return "bottom"
        end
    end
end

return rect