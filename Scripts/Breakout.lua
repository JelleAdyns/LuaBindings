-- Breakout game

function initialize()
    GameEngine:set_width(400)
    GameEngine:set_height(300)
    GameEngine:set_title("My Game")
end

--- @param rect RECT
function paint(rect)
    GameEngine:draw_rect(20,20,304,202)
end
function tick()
	print("Breakout")
end
