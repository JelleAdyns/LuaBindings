--- @meta

--- @param r integer 
--- @param g integer 
--- @param b integer 
--- @return integer  
function RGB(r,g,b) end

--- @class LongPoint
--- @field x integer 
--- @field y integer
LongPoint = {}

--- @class LongRect
--- @field left integer 
--- @field top integer
--- @field right integer 
--- @field bottom integer 
LongRect = {}
    
----- @enum HitRegionShape
----- @field Ellipse: integer
----- @field Rectangle: integer
--HitRegionShape = {}
--
----- @class HitRegion
--HitRegion = {}
--
----- @param shape HitRegionShape 
----- @param left integer
----- @param top integer
----- @param right integer
----- @param bottom integer
----- @return HitRegion
--function HitRegion.new(shape,left, top , right, bottom) end
--
----- @param x: integer
----- @param y: integer
--function HitRegion:move(x,y) end
--    
----- @param x: integer
----- @param y: integer
----- @return boolean
----- @overload fun(hitregion: HitRegion): boolean
--function HitRegion:hit_test(x,y) end
--        
----- @param hitregion: HitRegion
----- @return Point
--function HitRegion:collision_test(hitregion) end
--
----- @return Rect
--function HitRegion:get_bounds() end
--
----- @return boolean
--function HitRegion:exists() end



--- @class GameEngine
GameEngine = {}

-- [[Setters]]
--- @param width integer
function GameEngine:set_width(width) end

--- @param height integer
function GameEngine:set_height(height) end

--- @param title string
function GameEngine:set_title(title) end

--- @param rgb integer
function GameEngine:set_color(rgb) end
    
--- @param framerate integer
function GameEngine:set_framerate(framerate) end

--- @param keys string
function GameEngine:set_key_list(keys) end

--- @param rgb integer
--- @return bool
function GameEngine:fill_window_rect(rgb) end

-- [[Getters]]

--- @return integer
function GameEngine:get_frame_delay() end

--- @return integer
function GameEngine:get_width() end

--- @return integer
function GameEngine:get_height() end

-- [[Draw-functions]]

--- @param x1 integer
--- @param y1 integer
--- @param x2 integer
--- @param y2 integer
--- @return boolean    
function GameEngine:draw_line(x1,y1,x2,y2) end

--- @param left integer
--- @param top integer
--- @param right integer
--- @param bottom integer
--- @return boolean
function GameEngine:draw_rect(left, top,right,bottom) end

--- @param left integer
--- @param top integer
--- @param right integer
--- @param bottom integer
--- @param opacity integer
--- @return boolean
--- @overload fun(left: integer, top: integer, right: integer, bottom: integer): boolean
function GameEngine:fill_rect(left, top,right,bottom,opacity) end

--- @param left integer
--- @param top integer
--- @param right integer
--- @param bottom integer
--- @param radius integer
--- @return boolean
function GameEngine:draw_rounded_rect(left, top,right,bottom,radius) end

--- @param left integer
--- @param top integer
--- @param right integer
--- @param bottom integer
--- @param radius integer
--- @return boolean
function GameEngine:fill_rounded_rect(left, top,right,bottom,radius) end         

--- @param left integer
--- @param top integer
--- @param right integer
--- @param bottom integer
--- @return boolean
function GameEngine:draw_oval(left, top,right,bottom) end

--- @param left integer
--- @param top integer
--- @param right integer
--- @param bottom integer
--- @param opacity integer
--- @return boolean
--- @overload fun(left: integer, top: integer, right: integer, bottom: integer): boolean
function GameEngine:fill_oval(left, top,right,bottom, opacity) end

--- @param left integer
--- @param top integer
--- @param right integer
--- @param bottom integer
--- @param startDegrees integer
--- @param angle integer
--- @return boolean
function GameEngine:draw_arc(left, top,right,bottom, startDegrees, angle) end

--- @param left integer
--- @param top integer
--- @param right integer
--- @param bottom integer
--- @param startDegrees integer
--- @param angle integer
--- @return boolean
function GameEngine:fill_arc(left, top,right,bottom, startDegrees, angle) end

--- @param text string
--- @param left integer
--- @param top integer
--- @param right integer
--- @param bottom integer
--- @return integer
--- @overload fun(text: string, left: integer, top: integer): integer
function GameEngine:draw_string(text, left, top,right,bottom) end
    
-- [[Other]]
    
--- @param key integer
--- @return boolean
function GameEngine:is_key_down(key) end