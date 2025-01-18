-- Breakout game

local WINDOW_WIDTH = 160*4
local WINDOW_HEIGHT = 192*4
local YELLOW = RGB(201, 198, 22)
local ORANGE = RGB(199, 126, 0)
local GREEN = RGB(0, 126, 36)
local RED = RGB(159, 8, 0)

local rowColors = {
    {score = 7, color = RED},
    {score = 7, color = RED},
    {score = 5, color = ORANGE},
    {score = 5, color = ORANGE},
    {score = 3, color = GREEN},
    {score = 3, color = GREEN},
    {score = 1, color = YELLOW},
    {score = 1, color = YELLOW}
    }
function delta_time()
    return GameEngine:get_frame_delay()/1000
end


----------------------------------------------------------------------------------------------
-- Point Stuff
----------------------------------------------------------------------------------------------
--- @class Point
local Point = {}
Point.__index = Point

--- Constructor for the Point class
--- @param x number 
--- @param y number 
function Point.new(x, y)
local self = setmetatable({},Point)
self.x = x or 0
self.y = y or 0
return self
end

----------------------------------------------------------------------------------------------
-- Rect Stuff
----------------------------------------------------------------------------------------------
--- @class Rect
local Rect = {}
Rect.__index = Rect

--- Constructor for the Rect class
--- @param left number 
--- @param top number 
--- @param right number
--- @param bottom number
--- @return Rect
function Rect.new(left, top, right, bottom)
local self = setmetatable({},Rect)
self.left = left or 0
self.top = top or 0
self.right = right or 0
self.bottom = bottom or 0
return self
end

--- @param x number 
--- @param y number
function Rect:move(x, y)
    self.left = self.left + x
    self.right = self.right + x
    self.top = self.top + y
    self.bottom = self.bottom + y
end
    
--- @param hitRegion Rect
--- @return Point
function get_center(hitregion)
    return Point.new(hitregion.left + (hitregion.right - hitregion.left)/2, hitregion.top + (hitregion.bottom - hitregion.top)/2) 
end

--- @param rect1 Rect
--- @param rect2 Rect
--- @return boolean
function is_overlapping(rect1, rect2)
    if((rect1.right) <= rect2.left or (rect2.right) <= rect1.left or
        (rect1.bottom) <= rect2.top or (rect2.bottom) <= rect1.top)
            then 
                return false
            end
    return true
end

----------------------------------------------------------------------------------------------
-- Brick Stuff
----------------------------------------------------------------------------------------------
local BORDER = 10
local SPACE_BETWEEN_BRICKS = 5
local AMOUNT_OF_COLUMS = 14
local BRICK_WIDTH = (WINDOW_WIDTH - ((AMOUNT_OF_COLUMS-1) * SPACE_BETWEEN_BRICKS + 2* BORDER)) / AMOUNT_OF_COLUMS
local BRICK_HEIGHT = BRICK_WIDTH/4
local Brick = { }
Brick.__index = Brick

--- Constructor for the Brick class
--- @param left number 
--- @param top number 
--- @param color number
--- @param score integer
function Brick.new(left, top, color, score)
   local self = setmetatable({},Brick)
   self.hitregion = Rect.new(
         left, 
         top,
         left + BRICK_WIDTH, 
         top + BRICK_HEIGHT
         )
   self.color = color
   self.score = score or 0
   return self
end
function Brick:draw()
    GameEngine:set_color(self.color)

    ---@diagnostic disable-next-line: param-type-not-match
    GameEngine:fill_rect(
    math.floor(self.hitregion.left),
    math.floor(self.hitregion.top),
    math.floor(self.hitregion.right),
    math.floor(self.hitregion.bottom))
end

----------------------------------------------------------------------------------------------
-- Platform stuff
----------------------------------------------------------------------------------------------
---@class Platform
---@field hitregion Rect
local Platform = {
    hitregion = Rect.new(
         (WINDOW_WIDTH/2-BRICK_WIDTH/2), 
         (WINDOW_HEIGHT -60),
         (WINDOW_WIDTH/2+BRICK_WIDTH/2), 
         (WINDOW_HEIGHT-60 + BRICK_WIDTH/3)
         )
}

function Platform:draw()
    GameEngine:set_color(RGB(0, 79, 152))

    ---@diagnostic disable-next-line: param-type-not-match
    GameEngine:fill_rect(
    math.floor(self.hitregion.left),
    math.floor(self.hitregion.top),
    math.floor(self.hitregion.right),
    math.floor(self.hitregion.bottom))
end

----------------------------------------------------------------------------------------------
-- Ball stuff
----------------------------------------------------------------------------------------------
local BALLDEFAULTSPEED = 300
---@class Ball
---@field radius number
---@field hitregion Rect
local Ball = {radius = 8}
Ball.__index = Ball

--- Constructor for the Ball class
--- @param x number 
--- @param y number 
function Ball.new(x, y)
    local self = setmetatable({},Ball)
    ---@diagnostic disable-next-line: param-type-not-match
    self.hitregion = Rect.new( 
        x-self.radius,
        y-self.radius,
        x+self.radius,
        y+self.radius)
    self.directionX = 1
    self.directionY = -1
    return self
 end
function Ball:draw()
    GameEngine:set_color(RGB(230,230,230))

    ---@diagnostic disable-next-line: param-type-not-match
    GameEngine:fill_oval(
    math.floor(self.hitregion.left),
    math.floor(self.hitregion.top),
    math.floor(self.hitregion.right),
    math.floor(self.hitregion.bottom))
end

function Ball:tick()
    self.hitregion:move(
       self.directionX * BALLDEFAULTSPEED * delta_time(),
       self.directionY * BALLDEFAULTSPEED * delta_time()
        ) 
end

---@param collisionShape Rect
---@return boolean
function Ball:handle_collision(collisionShape)
    if(is_overlapping(self.hitregion, collisionShape)) then

        local xDist = math.min(self.hitregion.right - collisionShape.left, collisionShape.right - self.hitregion.left)
        local yDist = math.min(self.hitregion.bottom - collisionShape.top, collisionShape.bottom - self.hitregion.top)

        if(xDist < yDist) then

            self.directionX = -self.directionX
            self.hitregion:move((xDist)* self.directionX, 0)
            
        elseif (yDist < xDist) then

            self.directionY = -self.directionY
            self.hitregion:move(0, (yDist)* self.directionY) 
                
        else
            self.hitregion:move(-(xDist), (yDist))
            self.directionX = -self.directionX
            self.directionY = -self.directionY
        end

        return true
    end
    return false
end
----------------------------------------------------------------------------------------------
-- Setup
----------------------------------------------------------------------------------------------
local HUDSPACE = 120 + BORDER*3
local bricks = {}
for row = 1, #rowColors do
    for col = 1, AMOUNT_OF_COLUMS do
    local brick = Brick.new(
        ((col-1) * (BRICK_WIDTH + SPACE_BETWEEN_BRICKS) + BORDER),
        ((row-1) * (BRICK_HEIGHT + SPACE_BETWEEN_BRICKS) + HUDSPACE),
        rowColors[row].color, rowColors[row].score)
    table.insert(bricks, brick)
    end
end
local ball = Ball.new(WINDOW_WIDTH/2, WINDOW_HEIGHT-100) 

local collisionShapes = 
{
    Rect.new(0,0,BORDER,WINDOW_HEIGHT),
    Rect.new(WINDOW_WIDTH-BORDER,0,WINDOW_WIDTH,WINDOW_HEIGHT),
    Rect.new(0,0,WINDOW_WIDTH,BORDER*3),
  
}

----------------------------------------------------------------------------------------------
-- Game functions
----------------------------------------------------------------------------------------------
function initialize()
    GameEngine:set_width(WINDOW_WIDTH)
    GameEngine:set_height(WINDOW_HEIGHT)
    GameEngine:set_title("My Game")
    GameEngine:set_key_list("K")
    GameEngine:set_framerate(60)
   
end

function start()
end

function stop()

end 

--- @param rect LongRect
function paint(rect)

--Background
    GameEngine:fill_window_rect(RGB(0,0,0))
-- draw borders
    GameEngine:set_color(RGB(235,235,235))
    for i = 1, #collisionShapes do
       
        ---@diagnostic disable-next-line: param-type-not-match
        GameEngine:fill_rect(
            math.floor(collisionShapes[i].left), 
            math.floor(collisionShapes[i].top), 
            math.floor(collisionShapes[i].right), 
            math.floor(collisionShapes[i].bottom))
    end
--Draw bricks
   for i = 1, #bricks do
    bricks[i]:draw()
   end

   Platform:draw()
   ball:draw()
end

function tick()
    for i = 1, #collisionShapes do
        ball:handle_collision(collisionShapes[i])
    end 
    for i = 1, #bricks do
        if(ball:handle_collision(bricks[i].hitregion)) then
            removedBrick = table.remove(bricks, i)
            removedBrick = nil
        end
    end
    if(ball:handle_collision(Platform.hitregion)) then
       --ball.directionX = get_center(ball.hitregion).x
      -- ball.directionX = 
    end
    ball:tick()
end

--- @param isLeft boolean
--- @param isDown boolean
--- @param x integer
--- @param y integer
--- @param wParam integer
function mouse_button_action(isLeft, isDown,  x, y,  wParam)
    if(isLeft and isDown)
    then
        for i = 1, #bricks do
            if(x > bricks[i].hitregion.left and x < bricks[i].hitregion.right and
                y > bricks[i].hitregion.top and y < bricks[i].hitregion.bottom)
            then
                removedBrick = table.remove(bricks, i)
                removedBrick = nil
            end
        end
    end
end

--- @param x integer
--- @param y integer
--- @param distance integer
--- @param wParam integer
function mouse_wheel_action(x, y, distance, wParam)

end

--- @param x integer
--- @param y integer
--- @param wParam integer
function mouse_move(x, y, wParam)
    
    Platform.hitregion:move(x - get_center(Platform.hitregion).x, 0)
end

function check_keyboard()

end

--- @param key integer
function key_pressed(key)
    if(key == 'K') 
    then
        print("Released K")
    end
end