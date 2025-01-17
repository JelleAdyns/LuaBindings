//-----------------------------------------------------------------
// Main Game File
// C++ Source - Game.cpp - version v8_01
//-----------------------------------------------------------------

//-----------------------------------------------------------------
// Include Files
//-----------------------------------------------------------------
#include "Game.h"

//-----------------------------------------------------------------
// Game Member Functions																				
//-----------------------------------------------------------------

Game::Game(sol::state_view& lua) :
	m_rLua{ lua }
{

}

Game::~Game()																						
{
	
}

void Game::Initialize()			
{
	AbstractGame::Initialize();
	m_rLua["initialize"]();
}

void Game::Start()
{
	m_rLua["start"]();
}

void Game::Stop()
{
	m_rLua["stop"]();
}

void Game::Paint(RECT rect) const
{
	m_rLua["paint"](rect);
}

void Game::Tick()
{
	m_rLua["tick"]();
}

void Game::MouseButtonAction(bool isLeft, bool isDown, int x, int y, WPARAM wParam)
{	
	m_rLua["mouse_button_action"](isLeft, isDown, x, y ,wParam);
}

void Game::MouseWheelAction(int x, int y, int distance, WPARAM wParam)
{	
	m_rLua["mouse_wheel_action"](x, y, distance ,wParam);
}

void Game::MouseMove(int x, int y, WPARAM wParam)
{	
	m_rLua["mouse_move"](x, y, wParam);
}

void Game::CheckKeyboard()
{	
	m_rLua["check_keyboard"]();
}

void Game::KeyPressed(TCHAR key)
{	
	m_rLua["key_pressed"](key);
}

void Game::CallAction(Caller* callerPtr)
{
	// Insert the code that needs to execute when a Caller (= Button, TextBox, Timer, Audio) executes an action
}




