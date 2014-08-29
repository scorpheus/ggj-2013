
Include("scripts/utils/global_independent_include.nut")
Include("scripts/leaderboard.nut")

class	TemplateDebugScriptScene
{
	global_item_update = 0


//********************************************************************************************
	
	function OnRenderDone(scene)
	{	
		ItemGetScriptInstance(global_item_update).OnRenderUser(scene)
	}
	
//********************************************************************************************

	function ClickOnQuitControls(_sprite)
	//-----------------------------------------------------------------
	{
		ProjectGetScriptInstance(g_project).LoadScenario("scenes/menu_scene.nms")
	}

//********************************************************************************************

	
	/*! @short	OnUpdate Called each frame. */ 
	function OnUpdate(scene) 
	{
	
	}	
	
	/*!
		@short	Refresh
		when lose the context
	*/
	function Refresh()
	{
	}

	/*!
		@short	OnReset
	*/
	function OnReset(scene)
	{
		local main_window = g_WindowsManager.CreateVerticalSizer(0, 550)

		// create main menu		
		main_window.authorize_move = false; main_window.authorize_folded = false;
		
		//Set Level
		local widget = g_WindowsManager.CreateClickButton(main_window, tr("Pilot the vessel to avoid cells"))		
		local widget = g_WindowsManager.CreateClickButton(main_window, tr("Z Q S D"))				
		main_window.SetPos(Vector(g_cursor.GetXScreenSpace(0.5)-main_window.width*0.5, g_cursor.GetYScreenSpace(0.05), 0))
		
		local second_window = g_WindowsManager.CreateVerticalSizer(0, 550)
		second_window.authorize_move = false;second_window.authorize_folded = false;
		local scenario_widget = g_WindowsManager.CreateClickButton(second_window, tr("Kill viruses to score"))
		local scenario_widget = g_WindowsManager.CreateClickButton(second_window, tr("Mouse"))
		second_window.SetPos(Vector(g_cursor.GetXScreenSpace(0.5)-second_window.width*0.5, g_cursor.GetYScreenSpace(0.4), 0))

		local third_window = g_WindowsManager.CreateVerticalSizer(0, 550)
		third_window.authorize_move = false; third_window.authorize_folded = false;
		local scenario_widget = g_WindowsManager.CreateClickButton(third_window, tr("Back to Menu"), "", this, "ClickOnQuitControls")
		third_window.SetPos(Vector(g_cursor.GetXScreenSpace(0.5)-third_window.width*0.5, g_cursor.GetYScreenSpace(0.85), 0))
	}	

	/*!
		@short	OnSetup
		Called when the scene is about to be setup.
	*/
	function OnSetup(scene)
	{		
		// Create an object containing the script for the global update	
		global_item_update = ObjectGetItem(SceneAddObject(scene, "global_item_update"))
		ItemSetScript(global_item_update, "scripts/utils/global_independent_include.nut", "GlobalItemUpdateScript")
		ItemSetupScript(global_item_update)
		SceneSetupItem(scene, global_item_update)

		g_WindowsManager.current_ui = SceneGetUI(scene)
	}
}

