//-----------------------------------------------------------------
// Game Engine WinMain Function
// C++ Source - GameWinMain.cpp - version v8_01
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// Include Files
//-----------------------------------------------------------------
#include "GameWinMain.h"
#include "GameEngine.h"
#include "sol/sol.hpp"
#include <filesystem>
namespace fs = std::filesystem;

#include "Game.h"	


//Credit to Adam Knapecz
void AllocateConsole()
{
    if (AllocConsole())                          // Allocate a new console for the application
    {
        FILE* fp;                                // Redirect STDOUT to the console
        freopen_s(&fp, "CONOUT$", "w", stdout);
        setvbuf(stdout, NULL, _IONBF, 0);        // Disable buffering for stdout

        freopen_s(&fp, "CONOUT$", "w", stderr);  // Redirect STDERR to the console
        setvbuf(stderr, NULL, _IONBF, 0);        // Disable buffering for stderr

        freopen_s(&fp, "CONIN$", "r", stdin);    // Redirect STDIN to the console
        setvbuf(stdin, NULL, _IONBF, 0);         // Disable buffering for stdin

        std::ios::sync_with_stdio(true);         // Sync C++ streams with the console
    }
}
void OutputLuaMessage(const tstring& message)
{
    tcout << message;
}
void CreateBindings(sol::state& lua)
{
    lua.new_usertype<POINT>(
        "LongPoint",
        sol::constructors<sol::types<>>(),
        "x", &POINT::x,
        "y", &POINT::y
    );

    lua.new_usertype<RECT>(
        "LongRect",
        sol::constructors<sol::types<>>(),
        "left", &RECT::left,
        "top", &RECT::top,
        "right", &RECT::right,
        "bottom", &RECT::bottom
    );

    lua.new_enum<HitRegion::Shape>(
        "HitRegionShape",
        {
            { "Ellipse", HitRegion::Shape::Ellipse },
            { "Rectangle", HitRegion::Shape::Rectangle } 
        }
    );

    lua.new_usertype<HitRegion>(
        "HitRegion",
        sol::constructors<HitRegion(HitRegion::Shape, int, int, int, int)>(),
        "move", &HitRegion::Move,
        "hit_test", sol::overload(
            sol::resolve<bool(int, int) const>(&HitRegion::HitTest),
            sol::resolve<bool(const HitRegion*) const>(&HitRegion::HitTest)),
        "collision_test", &HitRegion::CollisionTest,		
        "get_bounds", &HitRegion::GetBounds,
        "exists", &HitRegion::Exists
    );

    lua.new_usertype<GameEngine>(
        "GameEngine",
        // Setters
        "set_width", &GameEngine::SetWidth,
        "set_height", &GameEngine::SetHeight,
        "set_title", &GameEngine::SetTitle,
        "set_color", &GameEngine::SetColor,
        "set_framerate", &GameEngine::SetFrameRate,
        "fill_window_rect", &GameEngine::FillWindowRect,
        "set_key_list", &GameEngine::SetKeyList,
        // Getters
        "get_frame_delay", &GameEngine::GetFrameDelay,
        "get_width", &GameEngine::GetWidth,
        "get_height", &GameEngine::GetHeight,
        // Draw-functions
        "draw_line", &GameEngine::DrawLine,
        "draw_rect", &GameEngine::DrawRect,
        "draw_rounded_rect", &GameEngine::DrawRoundRect,
        "draw_oval", &GameEngine::DrawOval,
        "draw_arc", &GameEngine::DrawArc,
        "draw_string", sol::overload(
            sol::resolve<int(const tstring&, int, int) const>(&GameEngine::DrawString),
            sol::resolve<int(const tstring&, int, int, int, int) const>(&GameEngine::DrawString)),
        "fill_rect", sol::overload(
            sol::resolve<bool(int, int, int, int) const>(&GameEngine::FillRect),
            sol::resolve<bool(int, int, int, int, int) const>(&GameEngine::FillRect)),
        "fill_rounded_rect", &GameEngine::FillRoundRect,
        "fill_oval", sol::overload(
            sol::resolve<bool(int, int, int, int) const>(&GameEngine::FillOval),
            sol::resolve<bool(int, int, int, int, int) const>(&GameEngine::FillOval)),
        "fill_arc", &GameEngine::FillArc,
        // Other
        "is_key_down", &GameEngine::IsKeyDown
    );

    lua["RGB"] = [](int r, int g, int b) {return RGB(r, g, b); };
   lua.set_function("OutputLuaMessage", [&](const tstring& message) {
       OutputLuaMessage(message); // Call the C++ function
       });
}

//-----------------------------------------------------------------
// Create GAME_ENGINE global (singleton) object and pointer
//-----------------------------------------------------------------
GameEngine myGameEngine;
GameEngine* GAME_ENGINE{ &myGameEngine };

//-----------------------------------------------------------------
// Main Function
//-----------------------------------------------------------------
int APIENTRY wWinMain(_In_ HINSTANCE hInstance, _In_opt_ HINSTANCE hPrevInstance, _In_ LPWSTR lpCmdLine, _In_ int nCmdShow)
{
    //Credit to Adam Knapecz
    AllocateConsole();

    sol::state lua;

    CreateBindings(lua);
    
    luaL_openlibs(lua.lua_state());
    std::string scriptName = "Scripts/Breakout.lua";
    
    myGameEngine.SetGame(new Game(lua));

    int result = 0;
    try
    {  
        lua["GameEngine"] = GAME_ENGINE;
        lua.script_file(scriptName);
        result = myGameEngine.Run(hInstance, nCmdShow);
    }
    catch (const sol::error& e)
    {
        OutputDebugStringA("\nError executing Lua script: " );
        OutputDebugStringA(e.what());
        OutputDebugStringA("\n\n");
    }
    return result;

}

