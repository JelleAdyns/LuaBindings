-- Breakout game

local START = false
local WINDOW_WIDTH = 160*4
local WINDOW_HEIGHT = 192*4 
local SCORE = 0
local YELLOW = RGB(201, 198, 22)
local ORANGE = RGB(199, 126, 0)
local GREEN = RGB(0, 126, 36)
local RED = RGB(159, 8, 0)
local USED_FONT_LARGE = Font.new("OCR A Extended",true,false,false, 64)
local USED_FONT_SMALL = Font.new("OCR A Extended",true,false,false, 32)
local HIT_AUDIO = Audio.new("Resources/HitSound.mp3")

local BRICK_ROWS = {
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
    
--- @return number 
function Rect:get_width()
    return self.right - self.left
end

--- @return number 
function Rect:get_height()
    return self.bottom - self.top
end

----- @param width number 
--function Rect:set_width(width)
--    self.right = self.left + width
--end
--
----- @param height number
--function Rect:set_height(height)
--    self.bottom = self.top + height
--end

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

local WON = false
local CURRENT_LIFE = 1
local MAX_LIVES = 4

---@class Platform
---@field hitregion Rect
local Platform = {
    hitregion = Rect.new(
         -1000, 
         (WINDOW_HEIGHT -60),
         1000, 
         (WINDOW_HEIGHT-60 + BRICK_WIDTH/3)
         ),
    isSmall = false
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
function Platform:reset()
    Platform.hitregion = Rect.new(
        (WINDOW_WIDTH/2-BRICK_WIDTH/2), 
        (WINDOW_HEIGHT -60),
        (WINDOW_WIDTH/2+BRICK_WIDTH/2), 
        (WINDOW_HEIGHT-60 + BRICK_WIDTH/3)
    )  
    Platform.isSmall = false
end

function Platform:make_wide()
    self.hitregion.left = -5000
    self.hitregion.right = 5000
    self.isSmall = false
end

function Platform:make_tiny()
    local platformWidth = Platform.hitregion:get_width()
    self.hitregion.left = Platform.hitregion.left + platformWidth/4
    Platform.hitregion.right = Platform.hitregion.right - platformWidth/4
    Platform.isSmall = true
end

function Platform:make_normal_width()
    local xCenter = get_center(self.hitregion).x
    self.hitregion = Rect.new(
                (xCenter-BRICK_WIDTH/2), 
                (WINDOW_HEIGHT -60),
                (xCenter+BRICK_WIDTH/2), 
                (WINDOW_HEIGHT-60 + BRICK_WIDTH/3)
            ) 
    self.isSmall = false
end
----------------------------------------------------------------------------------------------
-- Ball stuff
----------------------------------------------------------------------------------------------
local BALL_DEFAULT_SPEED = 400

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
    self.directionX = 0.707
    self.directionY = 0.707
    self.speed = BALL_DEFAULT_SPEED
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
       self.directionX * self.speed * delta_time(),
       self.directionY * self.speed * delta_time()
        ) 
end
function Ball:reset()
    local x = math.random(BORDER,WINDOW_WIDTH -BORDER)
    local y = WINDOW_HEIGHT/2
    self.hitregion = Rect.new( 
        x-self.radius,
        y-self.radius,
        x+self.radius,
        y+self.radius)
    self.directionX = 0.707
    self.directionY = 0.707
    self.speed = BALL_DEFAULT_SPEED
end

---@param collisionShape Rect
---@return boolean
function Ball:handle_collision(collisionShape)
    if(is_overlapping(self.hitregion, collisionShape)) then
        HIT_AUDIO:stop()  
        HIT_AUDIO:play(0, 300)  
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
local SCORE_DRAW_TOGGLE_MAX_TIME = 0.1
local SCORE_DRAW_TOGGLE_TIME = 0
local SCORE_DRAW = true
local RESET_MAX_TIME = 3
local RESET_TIME = RESET_MAX_TIME
local WINDOW_RECT = Rect.new(0,0, WINDOW_WIDTH, WINDOW_HEIGHT)
local HUD_SPACE = Rect.new(0,0, WINDOW_WIDTH,120 + BORDER*3)

local bricks = {}
local function CreateBricks()
    bricks = {}
    for row = 1, #BRICK_ROWS do
        for col = 1, AMOUNT_OF_COLUMS do
        local brick = Brick.new(
            ((col-1) * (BRICK_WIDTH + SPACE_BETWEEN_BRICKS) + BORDER),
            ((row-1) * (BRICK_HEIGHT + SPACE_BETWEEN_BRICKS) + HUD_SPACE.bottom),
            BRICK_ROWS[row].color, BRICK_ROWS[row].score)
        table.insert(bricks, brick)
        end
    end    
end

local ball = Ball.new(math.random(BORDER,WINDOW_WIDTH - BORDER), WINDOW_HEIGHT/2) 

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
    GameEngine:set_title("SE_Jelle_Adyns_Breakout")
    GameEngine:set_key_list("SK")
    GameEngine:set_framerate(120)
    GameEngine:set_font(USED_FONT_LARGE)
   
end

function start()
    CreateBricks()
    print(HIT_AUDIO:exists())
    print(HIT_AUDIO:get_duration())
end

function stop()

end 

--- @param rect LongRect
function paint(rect)

    GameEngine:set_font(USED_FONT_LARGE)
    --Background
    GameEngine:fill_window_rect(RGB(0,0,0))
    -- draw borders
    GameEngine:set_color(RGB(209, 209, 209))
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

    if WON then
        local str = "VICTORY!"
        local size = GameEngine:calculate_text_dimensions( str,USED_FONT_LARGE).cx
        ---@diagnostic disable-next-line: param-type-not-match
        GameEngine:draw_string(str, 
        math.floor(WINDOW_WIDTH/2 - size/2),
        math.floor(WINDOW_HEIGHT/2)) 
    end

    ---@diagnostic disable-next-line: param-type-not-match
    if SCORE_DRAW then
    GameEngine:draw_string(
        string.format("%03d",tostring(SCORE)), 
        BORDER+80,
        math.floor((HUD_SPACE.bottom -BORDER*3)/2 + BORDER*3)
    )
    end

    GameEngine:draw_string(tostring(1), BORDER+ 40,BORDER*3
    )
    ---@diagnostic disable-next-line: param-type-not-match
    GameEngine:draw_string(
        tostring(CURRENT_LIFE), 
        math.floor(WINDOW_WIDTH/2 + BORDER + 40),
        BORDER*3
    )
    ---@diagnostic disable-next-line: param-type-not-match
    GameEngine:draw_string(
        string.format("%03d",tostring(0)), 
        math.floor(WINDOW_WIDTH/2 + BORDER +80),
        math.floor((HUD_SPACE.bottom -BORDER*3)/2 + BORDER*3)
    )

    GameEngine:set_font(USED_FONT_SMALL)
    ---@diagnostic disable-next-line: param-type-not-match
    if not START then
        local str = "Press S to start"
        local size = GameEngine:calculate_text_dimensions( str,USED_FONT_SMALL).cx
        GameEngine:draw_string(
            str,
            math.floor(WINDOW_WIDTH/2-size/2),
            WINDOW_HEIGHT-300
        )
    end
    
end

function tick()
    HIT_AUDIO:on_tick()
    ball:tick()
    --Collide with borders
    for i = 1, #collisionShapes do
        ball:handle_collision(collisionShapes[i])
    end 
    --Collide with bricks
    for i = 1, #bricks do
        if(ball:handle_collision(bricks[i].hitregion) and START) then
            
            removedBrick = table.remove(bricks, i)
            SCORE = SCORE + removedBrick.score

            --Increase speed when hitting orange or RED
            if (removedBrick.color == ORANGE or  removedBrick.color == RED) then
                ball.speed = BALL_DEFAULT_SPEED * 1.5
            end
            
            removedBrick = nil

            
            break
        end
    end

    if #bricks == 0 then
        WON = true
        START = false
        Platform:make_wide()
    end
    --Collide with Platform
    if(ball:handle_collision(Platform.hitregion) and START) then
       
        local dX = get_center(ball.hitregion).x - get_center(Platform.hitregion).x
        local dY = get_center(ball.hitregion).y - get_center(Platform.hitregion).y
        local hypothenuse = math.sqrt(dX^2 + dY^2)

        ball.directionX = dX / hypothenuse;
        ball.directionY = dY / hypothenuse;

    end
    
    --Make platform small when in the HUD space
    if (not WON and not Platform.isSmall and is_overlapping(ball.hitregion, HUD_SPACE)) then
        Platform:make_tiny()
    end

    -- if ball is outside window start reset timer and reset
    if(not is_overlapping(ball.hitregion, WINDOW_RECT)) then
        if (RESET_TIME == RESET_MAX_TIME) then CURRENT_LIFE = CURRENT_LIFE + 1 end
        if (CURRENT_LIFE == MAX_LIVES) then
            START = false
            ball:reset()
            Platform:make_wide()
        else
            RESET_TIME = RESET_TIME - delta_time()
            if RESET_TIME < 0 then
                RESET_TIME = RESET_MAX_TIME
                Platform:make_normal_width()
                ball:reset()
            end
        end
    end

    --Timer for flickering of SCORE
    if START then
        SCORE_DRAW_TOGGLE_TIME = SCORE_DRAW_TOGGLE_TIME - delta_time()
        if SCORE_DRAW_TOGGLE_TIME <= 0 then
            SCORE_DRAW = not SCORE_DRAW
            SCORE_DRAW_TOGGLE_TIME = SCORE_DRAW_TOGGLE_MAX_TIME
        end
    else
        SCORE_DRAW = true
    end
end

--- @param isLeft boolean
--- @param isDown boolean
--- @param x integer
--- @param y integer
--- @param wParam integer
function mouse_button_action(isLeft, isDown,  x, y,  wParam)
    
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
    if(not START and key == 'S') then

        START = true
        SCORE = 0 
        CURRENT_LIFE = 1
        WON = false
        Platform:reset()
        ball:reset()
        CreateBricks()
    end
end

---@param callerPtr Caller
function call_action(callerPtr)

end
