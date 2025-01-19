--- @meta

--- @param r integer 
--- @param g integer 
--- @param b integer 
--- @return integer  
function RGB(r,g,b) end

--- @class LongSize
--- @field cx integer 
--- @field cy integer
LongSize = {}

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

--- @class Caller
Caller = {}

--- @class Audio
Audio = {}

---@param text string
---@return Audio
function Audio.new(filename) end
    
---@return boolean
function Audio:exists() end

---@param msecStart: integer
---@param msecStop: integer
function Audio:play(msecStart, msecStop) end
function Audio:stop() end

---@return integer
function Audio:get_volume() end

---@return integer
function Audio:get_duration() end

---@param volume integer
---@return boolean
function Audio:set_volume(volume) end

function Audio:on_tick() end


function add_action_listener() end

---@class Font
Font = {}
    
---@param fontname string
---@param bold boolean
---@param italic boolean
---@param underline boolean
---@param size integer
---@return Font
function Font.new(fontname,bold, italic, underline, size) end


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

---@param font Font
function GameEngine:set_font(font) end

-- [[Getters]]

--- @return integer
function GameEngine:get_frame_delay() end

--- @return integer
function GameEngine:get_width() end

--- @return integer
function GameEngine:get_height() end

-- [[Draw-functions]]

--- @param rgb integer
--- @return bool
function GameEngine:fill_window_rect(rgb) end

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

---@param text string
---@param font Font
---@param rect LongRect
---@return LongSize
---@overload fun(text: string, font: Font): LongSize
function GameEngine:calculate_text_dimensions(text,font, rect) end