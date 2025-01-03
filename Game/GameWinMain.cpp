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
    sol::state lua2;
    lua.new_usertype<GameEngine>(
        "GameEngine",
        "set_width", &GameEngine::SetWidth,
        "set_height", &GameEngine::SetHeight,
        "set_title", &GameEngine::SetTitle,
        "draw_rect", &GameEngine::DrawRect
    );

    //lua.new_usertype<Game>(
    //    "Game",
    //    "initialize", &Game::Initialize,
    //    "start", &Game::Start,
    //    "stop", &Game::Stop															
    //);
  

    luaL_openlibs(lua.lua_state());

    std::string scriptName = "Scripts/Breakout.lua";
       

    lua.script_file(scriptName);

    lua["GameEngine"] = GAME_ENGINE;

    GAME_ENGINE->SetGame(new Game(lua));
    
       
	return GAME_ENGINE->Run(hInstance, nCmdShow);		// here we go

}

