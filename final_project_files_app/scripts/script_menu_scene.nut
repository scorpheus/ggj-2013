
Include("scripts/utils/global_independent_include.nut")
Include("scripts/leaderboard.nut")

class	TemplateDebugScriptScene
{
	global_item_update = 0
	main_window = 0
	leaderboard_item = 0


//********************************************************************************************
	
	function ClickOnOpenLeaderboard(_sprite)
	{		
		main_window.Hide(true)
		leaderboard_item = Leaderboard()
		leaderboard_item.Load()
		leaderboard_item.CreateMenu(true)
	}
	function ClickOnScenario(_sprite)
	{
		print("click on scenario "+ _sprite.text)

		if(_sprite.user_param == "scenes/menu_scene_stereo.nms")
			g_MainCamera.is_stereo = true
		else
			g_MainCamera.is_stereo = false
		
		if(_sprite.user_param == "scenes/level1.nms")
			ProjectGetScriptInstance(g_project).seconde_before_go_to_next_step = 20.0
		else if(_sprite.user_param == "scenes/level2.nms")
			ProjectGetScriptInstance(g_project).seconde_before_go_to_next_step = 17.0
		else if(_sprite.user_param == "scenes/menu_scene_stereo.nms")
			ProjectGetScriptInstance(g_project).seconde_before_go_to_next_step = 15.0

		//load the current cliock scene which scenario got this name
				ProjectGetScriptInstance(g_project).LoadScenario(_sprite.user_param)
	}
	//-----------------------------------------------------------------
	function ClickOnQuitMenu(_sprite)
	//-----------------------------------------------------------------
	{
		ProjectEnd(g_project)
	}

//********************************************************************************************
	
	function OnRenderDone(scene)
	{	
		ItemGetScriptInstance(global_item_update).OnRenderUser(scene)
	}
	
//********************************************************************************************
	
	Show_menu = 0.0;
	Menu_first_appearance = true;

	/*! @short	OnUpdate Called each frame. */ 
	function	OnUpdate(scene) 
	{
		Show_menu += g_dt_frame;
		if(Show_menu > 1.50 && Menu_first_appearance)
		{
			LaunchMenu();
			Menu_first_appearance = false
		}
	}	
	
	function LaunchMenu()
	{
		main_window = g_WindowsManager.CreateVerticalSizer(0, 550)
		// create main menu		
		main_window.authorize_move = false; main_window.authorize_folded = false;
		
		//Set Level
		local widget = g_WindowsManager.CreateClickButton(main_window, tr("Controls"), "", this, "ClickOnScenario")		
		widget.user_param = "scenes/Controls.nms"
		local widget = g_WindowsManager.CreateClickButton(main_window, tr("Start Game"), "", this, "ClickOnScenario")		
		widget.user_param = "scenes/level1.nms"
		local widget = g_WindowsManager.CreateClickButton(main_window, tr("Special Game - Albinos"), "", this, "ClickOnScenario")		
		widget.user_param = "scenes/level2.nms"
		local widget = g_WindowsManager.CreateClickButton(main_window, tr("Special Game - Stereo"), "", this, "ClickOnScenario")		
		widget.user_param = "scenes/menu_scene_stereo.nms"

		local widget = g_WindowsManager.CreateClickButton(main_window, tr("Leaderboard"), "", this, "ClickOnOpenLeaderboard")
				
		local scenario_widget = g_WindowsManager.CreateClickButton(main_window, tr("Quit"), "", this, "ClickOnQuitMenu")

		main_window.SetPos(Vector(g_cursor.GetXScreenSpace(0.5)-main_window.width*0.5, g_cursor.GetYScreenSpace(0.68), 0))
	}

	/*!
		@short	Refresh
		when lose the context
	*/
	function	Refresh()
	{
	}

	/*!
		@short	OnReset
	*/
	function OnReset(scene)
	{
		g_MainCamera.is_stereo = false

		//create title
		local title_sprite = g_WindowsManager.CreateBitmapButton(0, "ui/Background.png")	
		title_sprite.SetPos(Vector(g_cursor.GetXScreenSpace(0.5)-title_sprite.width*0.5, 0, 0))
//		title_sprite.authorize_move = false; title_sprite.authorize_folded = false;	title_sprite.authorize_push_in_front = false

		Show_menu = 0.0;
		Menu_first_appearance = true;
	}	

	/*!
		@short	OnSetup
		Called when the scene is about to be setup.
	*/
	function	OnSetup(scene)
	{		
		// Create an object containing the script for the global update	
		global_item_update = ObjectGetItem(SceneAddObject(scene, "global_item_update"))
		ItemSetScript(global_item_update, "scripts/utils/global_independent_include.nut", "GlobalItemUpdateScript")
		ItemSetupScript(global_item_update)
		SceneSetupItem(scene, global_item_update)

		g_WindowsManager.current_ui = SceneGetUI(scene)
	}
}

