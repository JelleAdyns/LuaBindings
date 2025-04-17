---@diagnostic disable: undefined-global
-- Tetris

local NR_OF_COLS = 12
local NR_OF_ROWS = 22
local GAME_OVER = false
local USED_FONT_LARGE = Font.new("OCR A Extended",true,false,false, 64)
local TETRIS_THEME = Audio.new("Resources/Tetris.mp3")
local LINE_CLEAR = Audio.new("Resources/Tetris_line_clear.mp3")

----------------------------------------------------------------------------------------------
-- Tile stuff
----------------------------------------------------------------------------------------------
local Tile = {size = 32}
Tile.__index = Tile

---@param x number
---@param y number
---@param color integer
---@return table
function Tile.new(x,y, color)
   local self = setmetatable({}, Tile)
   self.x = x or 0
   self.y = y or 0
   self.color = color or 0
   return self
end

local borderTiles = {}
for row = 1, NR_OF_ROWS do
   for col = 1, NR_OF_COLS do
      if row == 1 or col == 1 or row == NR_OF_ROWS or col == NR_OF_COLS then
         table.insert(borderTiles, Tile.new((col-1) * Tile.size,(row-1)* Tile.size, RGB(100,100,100) ))
      end
   end
end

local WINDOW_WIDTH = Tile.size * NR_OF_COLS
local WINDOW_HEIGHT = Tile.size * NR_OF_ROWS
local NR_OF_BORDER_TILES = #borderTiles 
----------------------------------------------------------------------------------------------
-- Shape stuff
----------------------------------------------------------------------------------------------
local Shape = {tiles = {}}
Shape.__index = Shape

---@param x number
---@param y number
---@return table
function Shape.new(x,y)
   local instance = setmetatable({}, Shape)
   instance.tiles = {}
   instance.x = x or 0
   instance.y = y or 0

   return instance
end
function Shape:move_down()  
   self.y = self.y + Tile.size
   for i = 1, #(self.tiles) do
      self.tiles[i].y = self.tiles[i].y + Tile.size
   end
end
function Shape:move_left()  
   self.x = self.x - Tile.size
   for i = 1, #(self.tiles) do
      self.tiles[i].x = self.tiles[i].x - Tile.size
   end
end
function Shape:move_right()  
   self.x = self.x + Tile.size
   for i = 1, #(self.tiles) do
      self.tiles[i].x = self.tiles[i].x + Tile.size
   end
end

---@param clockwise boolean
function Shape:Rotate(clockwise)  

   local newCoordinates = {}

   for i = 1, #(self.tiles) do
      local dx = self.x - self.tiles[i].x
      local dy = self.y - self.tiles[i].y
      
      local r = math.sqrt(dx^2+dy^2)
      local currentAngle = math.atan(dy, dx)
      local degrees = math.rad(90) + currentAngle
      
      local finalX = math.floor(self.x + math.cos(degrees) * r)
      local finalY = math.floor(self.y + math.sin(degrees) * r)
      local xRemainder = math.fmod(finalX, Tile.size)
      local yRemainder = math.fmod(finalY, Tile.size)
      
      if(xRemainder < Tile.size/2)then
         finalX = Tile.size * (math.floor(finalX /Tile.size))
      else
         finalX = Tile.size * (math.floor(finalX /Tile.size) + 1)
      end
      
      if(yRemainder < Tile.size/2)then
         finalY = Tile.size * (math.floor(finalY /Tile.size))
      else
         finalY = Tile.size * (math.floor(finalY /Tile.size) + 1)
      end

      local correct = true
      for bordI = 1, #borderTiles do
         if finalX == borderTiles[bordI].x and finalY == borderTiles[bordI].y then
            correct = false
            break
         end
      end

      if not correct then
         break
      end

      table.insert(newCoordinates, #newCoordinates+1, {x = finalX, y=finalY})

   end

   if #newCoordinates == #self.tiles then
      for i = 1, #self.tiles do
      self.tiles[i].x = newCoordinates[i].x
      self.tiles[i].y = newCoordinates[i].y
      end
   end
end

-- Line construction
local Line = {}
setmetatable(Line, {__index = Shape})
Line.__index = Line
---@param x number
---@param y number
---@return table
function Line.new(x,y)
   local instance = Shape.new(x,y)

   local color = RGB(0,255,125)
   table.insert(instance.tiles, Tile.new(x,y ,color))
   table.insert(instance.tiles, Tile.new(x+Tile.size,y ,color))
   table.insert(instance.tiles, Tile.new(x-Tile.size,y ,color))
   table.insert(instance.tiles, Tile.new(x-Tile.size*2,y ,color))
   setmetatable(instance, Line)

   return instance
end

-- Square construction
local Square = {}
setmetatable(Square, {__index = Shape})
Square.__index = Square
---@param x number
---@param y number
---@return table
function Square.new(x,y)
   local instance = Shape.new(x,y)
 
   local color = RGB(200,100,0)
   table.insert(instance.tiles, Tile.new(x , y,color))
   table.insert(instance.tiles, Tile.new(x - Tile.size,y ,color))
   table.insert(instance.tiles, Tile.new(x - Tile.size,y - Tile.size ,color))
   table.insert(instance.tiles, Tile.new(x,y - Tile.size,color))
   setmetatable(instance, Square)

   return instance
end

-- LShape construction
local LShape = {}
setmetatable(LShape, {__index = Shape})
LShape.__index = LShape
---@param x number
---@param y number
---@return table
function LShape.new(x,y)
   local instance = Shape.new(x,y)
 
   local color = RGB(0,10,255)
   table.insert(instance.tiles, Tile.new(x , y,color))
   table.insert(instance.tiles, Tile.new(x - Tile.size, y, color))
   table.insert(instance.tiles, Tile.new(x + Tile.size, y, color))
   table.insert(instance.tiles, Tile.new(x + Tile.size, y - Tile.size,color))
   setmetatable(instance, LShape)

   return instance
end

-- rLShape construction
local rLShape = {}
setmetatable(rLShape, {__index = Shape})
rLShape.__index = rLShape
---@param x number
---@param y number
---@return table
function rLShape.new(x,y)
   local instance = Shape.new(x,y)
 
   local color = RGB(200,10,255)
   table.insert(instance.tiles, Tile.new(x , y,color))
   table.insert(instance.tiles, Tile.new(x - Tile.size, y, color))
   table.insert(instance.tiles, Tile.new(x - Tile.size, y - Tile.size,color))
   table.insert(instance.tiles, Tile.new(x + Tile.size, y, color))
   setmetatable(instance, rLShape)

   return instance
end

-- ZigZag construction
local ZigZag = {}
setmetatable(ZigZag, {__index = Shape})
ZigZag.__index = ZigZag
---@param x number
---@param y number
---@return table
function ZigZag.new(x,y)
   local instance = Shape.new(x,y)
 
   local color = RGB(100,240,10)
   table.insert(instance.tiles, Tile.new(x , y,color))
   table.insert(instance.tiles, Tile.new(x, y - Tile.size, color))
   table.insert(instance.tiles, Tile.new(x - Tile.size, y - Tile.size, color))
   table.insert(instance.tiles, Tile.new(x + Tile.size, y,color))
   setmetatable(instance, ZigZag)

   return instance
end

-- rZigZag construction
local rZigZag = {}
setmetatable(rZigZag, {__index = Shape})
rZigZag.__index = rZigZag
---@param x number
---@param y number
---@return table
function rZigZag.new(x,y)
   local instance = Shape.new(x,y)
 
   local color = RGB(210,45,100)
   table.insert(instance.tiles, Tile.new(x , y,color))
   table.insert(instance.tiles, Tile.new(x - Tile.size, y,color))
   table.insert(instance.tiles, Tile.new(x, y - Tile.size, color))
   table.insert(instance.tiles, Tile.new(x + Tile.size, y - Tile.size, color))
   setmetatable(instance, rZigZag)

   return instance
end

-- TShape construction
local TShape = {}
setmetatable(TShape, {__index = Shape})
TShape.__index = TShape
---@param x number
---@param y number
---@return table
function TShape.new(x,y)
   local instance = Shape.new(x,y)
 
   local color = RGB(200,200,0)
   table.insert(instance.tiles, Tile.new(x , y,color))
   table.insert(instance.tiles, Tile.new(x - Tile.size, y,color))
   table.insert(instance.tiles, Tile.new(x + Tile.size, y, color))
   table.insert(instance.tiles, Tile.new(x, y - Tile.size, color))
   setmetatable(instance, TShape)

   return instance
end
----------------------------------------------------------------------------------------------
-- Setup
----------------------------------------------------------------------------------------------

local TIMER = 0
local TICK_TIME = 1
local KEY_TIMER = 0



local SHAPES = {Line, Square, LShape, rLShape, ZigZag, rZigZag, TShape}
local controlledShape = SHAPES[math.random(1, #SHAPES)].new(6*Tile.size, 2*Tile.size)

---@param tiles table
local function paint_tiles(tiles)
   for i = 1, #tiles do
      GameEngine:set_color(tiles[i].color)
      GameEngine:fill_rect(tiles[i].x,tiles[i].y,tiles[i].x + Tile.size, tiles[i].y + Tile.size)
      GameEngine:set_color(RGB(0,0,0))
      GameEngine:draw_rect(tiles[i].x,tiles[i].y,tiles[i].x + Tile.size, tiles[i].y + Tile.size)
   end
end

---@param xDirection boolean
---@param predictionOffset number
---@return boolean
local function allowed_to_move(xDirection, predictionOffset)
   for shapeTileIndex = 1, #controlledShape.tiles do
      for tIndex = 1, #borderTiles do
         local shapeTile = controlledShape.tiles[shapeTileIndex]
         local tile = borderTiles[tIndex]
         if xDirection then
            if shapeTile.x + predictionOffset == tile.x and shapeTile.y == tile.y then
               return false
            end
         else
            if shapeTile.x == tile.x and shapeTile.y + predictionOffset == tile.y then
               return false
            end
         end
      end
   end

   return true
end


local function check_to_remove_line()
  
   local row =  NR_OF_ROWS-1
   while row > 2 do
 
      local correctIndeces = {}
      local nrOfCorrect = 0
      local completedRow = false
      for col = 2, NR_OF_COLS -1 do

         for i = NR_OF_BORDER_TILES + 1, #borderTiles do

            local tile = borderTiles[i]
             
            if tile.x == Tile.size*(col-1) and tile.y == Tile.size*(row-1) then
               nrOfCorrect = nrOfCorrect + 1
               table.insert(correctIndeces, #correctIndeces + 1, i)

               break
            end
         end

         completedRow = nrOfCorrect >= NR_OF_COLS-2
         if completedRow then
            break;
         end
      end

      if completedRow then

         table.sort(correctIndeces, function(a, b) return a > b end)   
         
         for i = 1, #correctIndeces do
            table.remove(borderTiles,correctIndeces[i])
         end
         
         for i = NR_OF_BORDER_TILES + 1, #borderTiles do
            if borderTiles[i].y < Tile.size*(row-1) then
               borderTiles[i].y = borderTiles[i].y + Tile.size  
            end
         end

         row = row + 1
         LINE_CLEAR:play(0,-1)
      end 
      row = row - 1
   
  end

end

----------------------------------------------------------------------------------------------
-- Game functions
----------------------------------------------------------------------------------------------
function initialize()
   GameEngine:set_width(WINDOW_WIDTH)
   GameEngine:set_height(WINDOW_HEIGHT)
   GameEngine:set_framerate(60)
   GameEngine:set_title("SE_Jelle_Adyns_Tetris")
   GameEngine:set_key_list(
      "ASDW" .. string.char( VK_SPACE) ..string.char( VK_LEFT) ..string.char( VK_RIGHT) .. string.char( VK_UP) ..string.char( VK_DOWN)
      )
      GameEngine:set_font(USED_FONT_LARGE)
   print(TETRIS_THEME:exists())
   GameEngine:show_mouse_pointer(false)
end

function start()
   TETRIS_THEME:set_repeat(true)
   TETRIS_THEME:play(0,-1)
   TETRIS_THEME:set_volume(20)
   print("helel")
end

function stop()

   
end 

--- @param rect LongRect
function paint(rect)
   GameEngine:fill_window_rect(RGB(0,0,0))
   paint_tiles(controlledShape.tiles)
   paint_tiles(borderTiles)

   if GAME_OVER then
      GameEngine:set_color(RGB(200,0,0))
      local size = GameEngine:calculate_text_dimensions("GAME OVER", USED_FONT_LARGE )
      --size.cx = size.cx *4
      --size.cy = size.cy *4
      GameEngine:draw_string(
         "GAME OVER", 
         math.floor(WINDOW_WIDTH/2 - size.cx/2),
         math.floor( WINDOW_HEIGHT/2 - size.cy/2)
         )
   end
end

function tick()
   
   TETRIS_THEME:on_tick()
   LINE_CLEAR:on_tick()


   KEY_TIMER = KEY_TIMER + delta_time()
   TIMER = TIMER + delta_time()
   if(not GAME_OVER and TIMER >= TICK_TIME) then

      if allowed_to_move(false, Tile.size) then
         controlledShape:move_down()
      else

         table.move(controlledShape.tiles, 1, #controlledShape.tiles, #borderTiles + 1, borderTiles)
         
         controlledShape = nil
         local index = math.random(1, #SHAPES)
         controlledShape = SHAPES[index].new(6*Tile.size, 2*Tile.size)
         
         check_to_remove_line()

         if not allowed_to_move(false, Tile.size) then
           GAME_OVER = true
         end

      end
      TIMER = TIMER - TICK_TIME

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
    
end

function check_keyboard()

   if(not GAME_OVER and KEY_TIMER > 0.075) then
      ---@diagnostic disable-next-line: param-type-not-match
      if GameEngine:is_key_down(string.byte('A')) or GameEngine:is_key_down(VK_LEFT) then
         if allowed_to_move(true, -Tile.size) then
            controlledShape:move_left()
         end
      end
      ---@diagnostic disable-next-line: param-type-not-match
      if GameEngine:is_key_down(string.byte('S'))  or GameEngine:is_key_down(VK_DOWN) then
         if allowed_to_move(false, Tile.size) then
            controlledShape:move_down()
         end
      end
      ---@diagnostic disable-next-line: param-type-not-match
      if GameEngine:is_key_down(string.byte('D')) or GameEngine:is_key_down(VK_RIGHT)  then
         if allowed_to_move(true, Tile.size) then
            controlledShape:move_right()
         end
      end
   KEY_TIMER = KEY_TIMER - 0.075
   end
end

--- @param key integer
function key_pressed(key)

   if GAME_OVER then
      if key == string.char(VK_SPACE) then
         for i =  #borderTiles, NR_OF_BORDER_TILES+1, -1 do
            table.remove(borderTiles, i)
         end
         TIMER = 0 
         KEY_TIMER = 0 
         GAME_OVER = false
         controlledShape = nil
         local index = math.random(1, #SHAPES)
         controlledShape = SHAPES[index].new(6*Tile.size, 2*Tile.size)
      end
   else
      if (key == 'W' or key == string.char(VK_UP)) then
         controlledShape:Rotate(true)
      end
      if key == string.char(VK_SPACE) then
         
         while allowed_to_move(false, Tile.size) do
            controlledShape:move_down()
         end
         TIMER = TICK_TIME
      end
   end
end

---@param callerPtr Caller
function call_action(callerPtr)

end
