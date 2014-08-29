
class   	LeaderboardValue
{
	name = 0
	time_score = 0
	nb_kill = 0

	constructor(_name, _time_score, _nb_kill)
	{
		name = _name
		time_score = _time_score
		nb_kill = _nb_kill
	}
}
/*
	Leaderboard
	*/
//-----------------------------
class   	Leaderboard
{
	list_leader = 0

	max_char			=	10

	close_button_widget = 	0
	grid_window			=	0
	grid_window2			=	0
	text_window			=	0
	text_widget			=	0
	text 				=	""

	keys_table			=	[KeyReturn, KeyBackspace, KeySpace, KeyA, KeyB, KeyC, KeyD, KeyE, KeyF, KeyG, KeyH, KeyI, KeyJ, KeyK, KeyL, KeyM, KeyN, KeyO, KeyP, KeyQ, KeyR, KeyS, KeyT, KeyU, KeyV, KeyW, KeyX, KeyY, KeyZ,
							KeyNumpad0, KeyNumpad1, KeyNumpad2, KeyNumpad3, KeyNumpad4, KeyNumpad5, KeyNumpad6, KeyNumpad7, KeyNumpad8, KeyNumpad9]
	sign_table			=	[">", "<", " ", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
							"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]


	function	ClickOnClose(_sprite)
	{
		close_button_widget.Hide(true)
		grid_window.Hide(true)
		grid_window2.Hide(true)
		SceneGetScriptInstance(g_scene).main_window.Show(true)
	}

	//----------------------------
	function	RefreshTextField()
	//----------------------------
	{
		local	_key = GetKeys()

		switch(_key)
		{
			case	"":
				break
			case	">":	//it's the enter button
				ClickOnOkEnterNameButton(0)
				return
				break
			case	"<":
				if (text.len() > 0)
				{
					text = text.slice(0, text.len() - 1)
				}
				break
			default:
				if (text.len() < max_char)
				{
					text += _key
				}
				break
		}

		text_widget.RefreshValueText(text)
	}

	//------------------
	function	GetKeys()
	//------------------
	{
		local keyboard_device = GetKeyboardDevice()
		foreach(i, _key in keys_table)
			if (DeviceKeyPressed(keyboard_device, _key))
				return sign_table[i]

		return	""
	}

	//------------------
	function	ClickOnOkEnterNameButton(_sprite)
	//------------------
	{
		text_window.Hide(true)
		g_WindowsManager.KillWidget(text_window)
		text_window = 0
		text_widget = 0

		list_leader.append(LeaderboardValue(text.tostring(), SceneGetScriptInstance(g_scene).timer_start, SceneGetScriptInstance(g_scene).ennemy_killed))
		Save()

		if(SceneGetScriptInstance(g_scene).survive_time_widget)
		{
			SceneGetScriptInstance(g_scene).survive_time_widget.Hide(true)
			SceneGetScriptInstance(g_scene).credit_widget.Hide(true)			
		}

		CreateMenu()
	}
	//------------------
	function	Update()
	{
		if(!text_widget && !grid_window)
		{
			text_window = g_WindowsManager.CreateVerticalSizer(0, 600)		
	
			local widget = g_WindowsManager.CreateClickButton(text_window,  tr("~~Color(0,180,255,255) ~~Size(40) Enter your name of champion here"))
			text_widget = g_WindowsManager.CreateClickButton(text_window,  "")
			widget = g_WindowsManager.CreateClickButton(text_window,  "Ok", "", this, "ClickOnOkEnterNameButton")
			text_window.SetPos(Vector(g_cursor.GetXScreenSpace(0.5)-text_window.width*0.5, 50, 0))
		}
		if(text_widget)
			RefreshTextField()
	}

	//------------------
	function	Load()
	{
		local	metafile = MetafileNew();

		// Load statistics.
		if	(!TryLoadMetafile(metafile, "leaderboard_save.nml"))
		{
			return
		}

		local array_leader = MetafileGetRoots(metafile)
		foreach(leader_tag in array_leader)
		{
			local name_config = ""
			if(MetatagGetValue(MetatagGetTag(leader_tag, "name")) != null)
				name_config = MetatagGetValue(MetatagGetTag(leader_tag, "name")).tostring()
			local time_score_config = MetatagGetValue(MetatagGetTag(leader_tag, "time_score_config")).tofloat()
			local nb_kill_config = MetatagGetValue(MetatagGetTag(leader_tag, "nb_kill_config")).tointeger()

			list_leader.append(LeaderboardValue(name_config, time_score_config, nb_kill_config))
		}

		MetafileDelete(metafile)
	}
	//------------------
	function	Save()
	{
		local	metafile = MetafileNew();

		foreach(leader in list_leader)
		{
			local root_tag = MetafileAddRoot(metafile, "config")

			MetatagAddChildWithValue(root_tag, "name", leader.name)	
			MetatagAddChildWithValue(root_tag, "time_score_config", leader.time_score)	
			MetatagAddChildWithValue(root_tag, "nb_kill_config", leader.nb_kill)	
		}

		TrySaveMetafile(metafile, "leaderboard_save.nml")
		MetafileDelete(metafile)
	}

	function sort_by_time(a,b)
	{
		if(a.time_score<b.time_score) return 1
		else if(a.time_score>b.time_score) return -1
		return 0;
	}
	function sort_by_kill(a,b)
	{
		if(a.nb_kill<b.nb_kill) return 1
		else if(a.nb_kill>b.nb_kill) return -1
		return 0;
	}
	
	
	//------------------
	function    CreateMenu(_AddCloseButton = false)
	{
		grid_window = g_WindowsManager.CreateGridSizer(0, 450, 1000.0)		
		grid_window.SetMaxSprite(2, 11)
		grid_window.skip_scroll_line = 1

		list_leader.sort(sort_by_time)

		g_WindowsManager.CreateClickButton(grid_window, tr("Best Tiime"))	
		g_WindowsManager.CreateClickButton(grid_window, "")	

		foreach(leader in list_leader)
		{
			g_WindowsManager.CreateClickButton(grid_window, leader.name)	
			g_WindowsManager.CreateClickButton(grid_window, RoundFloat2Decimal(leader.time_score))	
		}
		grid_window.SetSize(grid_window.width, grid_window.height)
		grid_window.SetPos(Vector(g_cursor.GetXScreenSpace(0.5)-grid_window.width-45, 120.0, 0))
		grid_window.authorize_move = false; grid_window.authorize_folded = false;	

		grid_window2 = g_WindowsManager.CreateGridSizer(0, 450, 1000.0)	
		grid_window2.SetMaxSprite(2, 11)
		grid_window2.skip_scroll_line = 1

		g_WindowsManager.CreateClickButton(grid_window2, tr("Best Kill"))	
		g_WindowsManager.CreateClickButton(grid_window2, "")	
		list_leader.sort(sort_by_kill)

		foreach(leader in list_leader)
		{
			g_WindowsManager.CreateClickButton(grid_window2, leader.name)	
			g_WindowsManager.CreateClickButton(grid_window2, leader.nb_kill)	
		}
		grid_window2.SetSize(grid_window2.width, grid_window2.height)
		grid_window2.SetPos(Vector(g_cursor.GetXScreenSpace(0.5)+10, 120.0, 0))
		grid_window2.authorize_move = false; grid_window2.authorize_folded = false;

		grid_window2.Show(true)
		grid_window.Show(true)

			g_WindowsManager.PushInFront(grid_window)
			g_WindowsManager.PushInFront(grid_window2)

		if(_AddCloseButton)
		{			
			close_button_widget = g_WindowsManager.CreateClickButton(0, tr("Close Leaderboard"), "", this, "ClickOnClose")
			close_button_widget.SetPos(Vector(g_cursor.GetXScreenSpace(0.5)+25-close_button_widget.width*0.5, g_cursor.GetYScreenSpace(0.85), 0))	
			close_button_widget.authorize_move = false; close_button_widget.authorize_folded = false;	
			g_WindowsManager.PushInFront(close_button_widget)
		}
	}


	//-----------
	constructor()
	{			
		grid_window2		=	0
		grid_window			=	0
		text_window			=	0
		text_widget			=	0
		close_button_widget	=	0

		list_leader = []
	}
	
}
