-- Breakout game

local WINDOW_WIDTH = 160*4
local WINDOW_HEIGHT = 192*4
local rowColors = {
    RGB(200,0,0),
    RGB(0,200,0),
    RGB(0,0,200),
    RGB(200,200,0),
    RGB(0,200,200),
    RGB(200,0,200),
    RGB(200,100,30),
    RGB(200,200,200),
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
local Brick = { 
    width = BRICK_WIDTH,
    height = BRICK_WIDTH/4
    }
Brick.__index = Brick

--- Constructor for the Brick class
--- @param x number 
--- @param y number 
--- @param color number
--- @param score integer
function Brick.new(x, y, color, score)
   local self = setmetatable({},Brick)
   self.left = x or 0
   self.top = y or 0
   self.color = color
   self.score = score or 0
   return self
end
function Brick:draw()
    GameEngine:set_color(self.color)

    ---@diagnostic disable-next-line: param-type-not-match
    GameEngine:fill_rect(
    math.floor(self.left),
    math.floor(self.top),
    math.floor(self.left + self.width),
    math.floor(self.top+ self.height))
end

---@diagnostic disable-next-line: param-type-not-match
----------------------------------------------------------------------------------------------
-- Platform stuff
----------------------------------------------------------------------------------------------
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
local BALLDEFAULTSPEED = 90
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
        y- self.radius,
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

----------------------------------------------------------------------------------------------
-- Setup
----------------------------------------------------------------------------------------------
local HUDSPACE = 120 + BORDER*3
local bricks = {}
for row = 1, #rowColors do
    for col = 1, AMOUNT_OF_COLUMS do
    local brick = Brick.new(
        ((col-1) * (Brick.width + SPACE_BETWEEN_BRICKS) + BORDER),
        ((row-1) * (Brick.height + SPACE_BETWEEN_BRICKS) + HUDSPACE),
        rowColors[row])
    table.insert(bricks, brick)
    end
end
local ball = Ball.new(WINDOW_WIDTH/2, WINDOW_HEIGHT-100) 

local collisionShapes = 
{
    Rect.new(0,0,BORDER,WINDOW_HEIGHT),
    Rect.new(WINDOW_WIDTH-BORDER,0,WINDOW_WIDTH,WINDOW_HEIGHT),
    Rect.new(0,0,WINDOW_WIDTH,BORDER*3),
    Platform.hitregion
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

        if(is_overlapping(ball.hitregion, collisionShapes[i])) then

            local xDist = math.min(ball.hitregion.right - collisionShapes[i].left, collisionShapes[i].right - ball.hitregion.left)
            local yDist = math.min(ball.hitregion.bottom - collisionShapes[i].top, collisionShapes[i].bottom - ball.hitregion.top)

            if(xDist < yDist) then

                ball.directionX = -ball.directionX
                ball.hitregion:move((xDist)* ball.directionX, 0)
              
            elseif (yDist < xDist) then

                ball.hitregion:move(0, -(yDist)* ball.directionY) 
                ball.directionY = -ball.directionY
                    
            else
                ball.hitregion:move(-(xDist), (yDist))
                ball.directionX = -ball.directionX
                ball.directionY = -ball.directionY
            end
            
            
        end
            
        
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
            if(x > bricks[i].left and x < bricks[i].left + bricks[i].width and
                y > bricks[i].top and y < bricks[i].top + bricks[i].height)
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