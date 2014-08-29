
Include("scripts/utils/global_independent_include.nut")
Include("scripts/leaderboard.nut")

class	TemplateDebugScriptScene
{
	channel_main_song = 0

	global_item_update = 0

	friend_list = 0
	ennemy_list = 0

	leaderboard_item = 0

	artere = 0

	ennemy_item_sida = 0
	ennemy_item_dengue = 0
	friend_item_rouge = 0
	friend_item_blanc = 0
	DummyParentAmi = 0
	TriggerFriend = 0

	title_loser_sprite = 0
	survive_time_widget  = 0
	credit_widget = 0


	heart_beat = 1.0

	life = 100.0
	ennemy_killed = 0

	timer_start = 0.0

	game_state = "Begining"
	widget_start = 0
	start_counter = 0.0

	function ClickOnMainMenu(_sprite)
	{
//		g_SoundManager.RemoveSound(channel_main_song)
//		g_SoundManager.Kill()
		MixerChannelStop(g_mixer, channel_main_song)
		MixerChannelStopAll(g_mixer)
		MixerChannelUnlockAll(g_mixer)
		//load the current cliock scene which scenario got this name
		ProjectGetScriptInstance(g_project).LoadScenario("scenes/menu_scene.nms")
	}

	function ClickOnRestart(sprite)
	{	
		ProjectGetScriptInstance(g_project).ResetScenario()
	}
//********************************************************************************************
	
	function OnRenderDone(scene)
	{	
		ItemGetScriptInstance(global_item_update).OnRenderUser(scene)
	}

//********************************************************************************************
	heart_clock = 0
	heart_speed = 0.7

	level = 0

	increase_level_boolean = false
	/*! @short	OnUpdate Called each frame. */ 
	function	OnUpdate(scene)
	{

		if(game_state != "GO" && (game_state == "Begining" || widget_start))
		{

			widget_life.RefreshValueText(tr("Life: ")+RoundFloat2Decimal(life))
			widget_Kill.RefreshValueText(tr("Kills: ")+RoundFloat2Decimal(ennemy_killed))
		
			heart_speed = 0.0

			if(!widget_start)
			{

				widget_start = g_WindowsManager.CreateBitmapButton(0, "ui/get_ready.png")
				widget_start.SetPos(Vector(g_cursor.GetXScreenSpace(0.5)-widget_start.width*0.5, g_cursor.GetYScreenSpace(0.5)-widget_start.height*0.5, 0))		
				widget_start.authorize_move = false; widget_start.authorize_folded = false;	widget_start.authorize_resize = false
			}

			start_counter -= g_dt_frame

			if(start_counter <= 0)
			{
				if(game_state == "Begining")
				{
					game_state = "countdown3"
					g_WindowsManager.KillWidget(widget_start)
					widget_start = g_WindowsManager.CreateBitmapButton(0, "ui/3.png")
					widget_start.SetPos(Vector(g_cursor.GetXScreenSpace(0.5)-widget_start.width*0.5, g_cursor.GetYScreenSpace(0.5)-widget_start.height*0.5, 0))		
					widget_start.authorize_move = false; widget_start.authorize_folded = false;	widget_start.authorize_resize = false
					start_counter = 1.0
				}
				else
				if(game_state == "countdown3")
				{
					game_state = "countdown2"
					g_WindowsManager.KillWidget(widget_start)
					widget_start = g_WindowsManager.CreateBitmapButton(0, "ui/2.png")
					widget_start.SetPos(Vector(g_cursor.GetXScreenSpace(0.5)-widget_start.width*0.5, g_cursor.GetYScreenSpace(0.5)-widget_start.height*0.5, 0))		
					widget_start.authorize_move = false; widget_start.authorize_folded = false;	widget_start.authorize_resize = false
					start_counter = 1.0
				}
				else
				if(game_state == "countdown2")
				{
					game_state = "countdown1"
					g_WindowsManager.KillWidget(widget_start)
					widget_start = g_WindowsManager.CreateBitmapButton(0, "ui/1.png")
					widget_start.SetPos(Vector(g_cursor.GetXScreenSpace(0.5)-widget_start.width*0.5, g_cursor.GetYScreenSpace(0.5)-widget_start.height*0.5, 0))		
					widget_start.authorize_move = false; widget_start.authorize_folded = false;	widget_start.authorize_resize = false
					start_counter = 1.0
				}
				else
				if(game_state == "countdown1")
				{
					game_state = "GO"
					g_WindowsManager.KillWidget(widget_start)
					widget_start = g_WindowsManager.CreateBitmapButton(0, "ui/go.png")
					widget_start.SetPos(Vector(g_cursor.GetXScreenSpace(0.5)-widget_start.width*0.5, g_cursor.GetYScreenSpace(0.5)-widget_start.height*0.5, 0))		
					widget_start.authorize_move = false; widget_start.authorize_folded = false;	widget_start.authorize_resize = false
					start_counter = 0.5

					heart_speed = 0.810
				}
			}
			return
		}

		start_counter -= g_dt_frame

		if(start_counter <= 0 && widget_start && game_state == "GO")
		{
			widget_start.Hide(true)
			g_WindowsManager.KillWidget(widget_start)
			widget_start = 0
		}

		if(heart_speed <= 0.0)
		{
			if(!leaderboard_item)
				leaderboard_item = Leaderboard()
			leaderboard_item.Update()
			return
		}
			
		widget_life.RefreshValueText(tr("Life: ")+RoundFloat2Decimal(life))
		widget_Kill.RefreshValueText(tr("Kills: ")+RoundFloat2Decimal(ennemy_killed))
		

		if(life <= 0.0)
		{
			//create title

			survive_time_widget = g_WindowsManager.CreateClickButton(0, tr("you survive ")+RoundFloat2Decimal(timer_start)+" sec and kill "+ennemy_killed.tostring()+" viruses")	
			survive_time_widget.SetPos(Vector(g_cursor.GetXScreenSpace(0.5)-survive_time_widget.width*0.5, 300.0, 0))	
			survive_time_widget.authorize_move = false; survive_time_widget.authorize_folded = false;		
			

			credit_widget = g_WindowsManager.CreateVerticalSizer(0, 600)		

			local widget = g_WindowsManager.CreateClickButton(credit_widget, tr("~~Size(30) ~~Color(251,97,29,255) Credit to "))	
			local widget = g_WindowsManager.CreateClickButton(credit_widget, tr("~~Size(30) ~~Color(251,97,29,255) Antoine Delhommeau "))	
			local widget = g_WindowsManager.CreateClickButton(credit_widget, tr("~~Size(30) ~~Color(251,97,29,255) Stéphane Rey"))	
			local widget = g_WindowsManager.CreateClickButton(credit_widget, tr("~~Size(30) ~~Color(251,97,29,255) Thomas Simonnet"))
			local widget = g_WindowsManager.CreateClickButton(credit_widget, tr("~~Size(30) ~~Color(251,97,29,255) using Gamestart3d editor"))		
			
			credit_widget.SetPos(Vector(g_cursor.GetXScreenSpace(0.5)-credit_widget.width*0.5, 400.0, 0))	
			credit_widget.authorize_move = false; credit_widget.authorize_folded = false;	

			local restart_widget = g_WindowsManager.CreateClickButton(0, tr("Restart"), "", this, "ClickOnRestart")	
			restart_widget.SetPos(Vector(g_cursor.GetXScreenSpace(0.5)-restart_widget.width*0.5, g_cursor.GetYScreenSpace(0.85), 0))	

			heart_speed = 0.0
			heart_beat = 0.0

			return 
		}

		local keyboard_handle_device = GetKeyboardDevice()
		if((DeviceIsKeyDown(keyboard_handle_device, KeyG) && !DeviceWasKeyDown(keyboard_handle_device, KeyG)) ||
			timer_start.tointeger()%ProjectGetScriptInstance(g_project).seconde_before_go_to_next_step == 0 )
		{
			if(!increase_level_boolean)
			{
				increase_level_boolean = true
		//		heart_speed += 0.5

				if(friend_list.len() < 1500)
					for(local i=0; i<10; ++i)
					{			
						SpawnFriend(scene)
					}

				if(ennemy_list.len() < 1500)
					for(local i=0; i<4; ++i)
					{			
						SpawnEnnemy(scene)
					}
			}
		}
		else
			increase_level_boolean = false

		// increase heart speed for 5 sec
		if(timer_start >= 11.264 && timer_start <= 12.472)
			heart_speed = 2.0
		else
			heart_speed = 0.810
	//	if(timer_start.tointeger() >= 14 && timer_start.tointeger() <= 19)
	//		heart_speed = 1.0


		heart_clock += g_dt_frame * heart_speed

		heart_beat = cos(heart_clock*10.0)*2.0

		// update friendly bidule
		local z_rot_artere = ItemGetRotation(artere).z
		foreach(friend_item in friend_list)
		{
			if(ItemGetWorldPosition(friend_item).z < -5.0 ) // behind the cam, respawn in front
			{
				local value_rand = rand()%780 *0.001 + 3.1415  -z_rot_artere
				ItemSetPosition(ItemGetScriptInstance(friend_item).new_parent_item, Vector(Rand(-70.0,70.0)+1165.01*cos(value_rand),Rand(-50.0, 50.0)+1165.01*sin(value_rand), Rand(-70.0,70.0)))
			}
		}

		// update ennemy bidule
		foreach(ennemy_item2 in ennemy_list)
		{
			if(ItemGetWorldPosition(ennemy_item2).z < -5.0 || !ItemIsActive(ennemy_item2)  || ItemIsInvisible(ennemy_item2)) // behind the cam, respawn in front
			{
				ItemSetInvisible(ennemy_item2, false)
			//	SceneItemActivate(scene, ennemy_item2, true)
				local value_rand = rand()%780 *0.001 + 3.1415  - z_rot_artere
				ItemSetPosition(ItemGetScriptInstance(ennemy_item2).new_parent_item, Vector(Rand(-70.0,70.0)+1165.01*cos(value_rand),Rand(-50.0, 50.0)+1165.01*sin(value_rand), Rand(-70.0,70.0)))
				ItemGetScriptInstance(ennemy_item2).origin_vec = ItemGetPosition(ItemGetScriptInstance(ennemy_item2).new_parent_item)
				ItemSetPosition(ennemy_item2, ItemGetWorldPosition(ItemGetScriptInstance(ennemy_item2).new_parent_item) )
				ItemPhysicResetTransformation(ennemy_item2, ItemGetWorldPosition(ItemGetScriptInstance(ennemy_item2).new_parent_item) , Vector(0.0,0.0,0.0))
			}
		}

		timer_start += g_dt_frame

		g_cursor.cursor_opacity = 0.0
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
	widget_life = 0
	widget_Kill = 0
	function OnReset(scene)
	{
		game_state = "Begining"

		widget_start = 0
		start_counter = 1.5

		leaderboard_item = Leaderboard()
		leaderboard_item.Load()

		g_WindowsManager.Kill(true)
		g_ParticlesManager.list_item_pos.clear()

		widget_life = g_WindowsManager.CreateClickButton(0,tr("Life: ")+ "100.0");	
		widget_life.SetPos(Vector(150, 860, 0))		
		widget_life.authorize_move = false; widget_life.authorize_folded = false;	widget_life.authorize_resize = false
		
		widget_Kill = g_WindowsManager.CreateClickButton(0,tr("Kills: ")+ "1000.0");	
		widget_Kill.SetPos(Vector(860, 860, 0))		
		widget_Kill.authorize_move = false; widget_Kill.authorize_folded = false;	widget_Kill.authorize_resize = false
		
		//Set Level
		local widget = g_WindowsManager.CreateClickButton(0, tr("Back to Menu"), "", this, "ClickOnMainMenu")	
		widget.SetPos(Vector(g_cursor.GetXScreenSpace(0.5)-widget.width*0.5, 890, 0))	
		//widget.SetPos(Vector(150, 910, 0))		
		widget.authorize_move = false; widget.authorize_folded = false;	widget.authorize_resize = false


		heart_beat = 1.0
		timer_start = 0.0

		life = 100.0
		heart_clock = 0.0
		heart_speed = 0.810

		ennemy_killed = 0
		level = 0
		increase_level_boolean = true


		ennemy_item_sida = LegacySceneFindItem(scene, "ennemy_sida")
		ennemy_item_dengue = LegacySceneFindItem(scene, "ennemy_dengue")
		friend_item_rouge = LegacySceneFindItem(scene, "ami_rouge")
		friend_item_blanc = LegacySceneFindItem(scene, "ami_blanc")
		DummyParentAmi = LegacySceneFindItem(scene, "DummyParentAmi")
		TriggerFriend = LegacySceneFindItem(scene, "TriggerFriend")		

		
		foreach(friend_item in friend_list)
		{
			SceneDeleteItem(scene, friend_item)
		}
		
		artere = LegacySceneFindItem(scene, "Artere")
		friend_list = []
		for(local i=0; i<12; ++i)
		{			
			SpawnFriend(scene, true)
		}

		foreach(ennemy_item2 in ennemy_list)
		{
			SceneDeleteItem(scene, ennemy_item2)
		}
		ennemy_list = []
		for(local i=0; i<4; ++i)
		{			
			SpawnEnnemy(scene, true)
		}


		ItemActivate(friend_item_rouge, false)
		ItemActivate(friend_item_blanc, false)		
		ItemActivate(DummyParentAmi, false)					
		ItemActivate(TriggerFriend, false)					
		ItemActivate(ennemy_item_sida, false)					
		ItemActivate(ennemy_item_dengue, false)	

		// launch the song.
		//g_SoundManager.RemoveSound(channel_main_song)
		//g_SoundManager.Kill()
		MixerChannelStop(g_mixer, channel_main_song)
		MixerChannelStopAll(g_mixer)
		MixerChannelUnlockAll(g_mixer)

		channel_main_song = MixerChannelLock(g_mixer)
		MixerChannelSetLoopMode(g_mixer, channel_main_song, LoopRepeat)

		local value_rand = rand()%4
		if(value_rand == 0)		
			MixerChannelStartStream(g_mixer, channel_main_song, "Electro Arteres.ogg")
		//	channel_main_song = g_SoundManager.StartSound(ResourceFactoryLoadSound(g_factory, "Electro Arteres.wav"))
		else
		if(value_rand == 1)		
			MixerChannelStartStream(g_mixer, channel_main_song, "Electro ARTERES V3( plus long).ogg")
		//	channel_main_song = g_SoundManager.StartSound(ResourceFactoryLoadSound(g_factory, "Electro ARTERES V3( plus long).wav"))
		else
		if(value_rand == 2)		
			MixerChannelStartStream(g_mixer, channel_main_song, "Electro Arteres_old.ogg")
		//	channel_main_song = g_SoundManager.StartSound(ResourceFactoryLoadSound(g_factory, "Electro Arteres_old.wav"))
		else
		if(value_rand == 3)		
			MixerChannelStartStream(g_mixer, channel_main_song, "ztek.ogg")
		//	channel_main_song = g_SoundManager.StartSound(ResourceFactoryLoadSound(g_factory, "ztek.wav"))

	}	

	function SpawnFriend(scene, _first=false)
	{			
		local new_parent_item = SceneDuplicateItem(scene, DummyParentAmi)
					
		ItemSetParent(new_parent_item, artere)
		SceneSetupItem(scene, new_parent_item)
		ItemRenderSetup(new_parent_item, g_factory)
		ItemActivate(new_parent_item, true)	

		local z_rot_artere = ItemGetRotation(artere).z		
		local value_rand
		if(_first)
			value_rand = rand()%1575 *0.001 + 3.1415 -z_rot_artere
		else			
			value_rand = rand()%780 *0.001 + 3.1415 -z_rot_artere
		ItemSetPosition(new_parent_item, Vector(Rand(-70.0,70.0)+1165.01*cos(value_rand),Rand(-50.0, 50.0)+1165.01*sin(value_rand), Rand(-70.0,70.0)))

		local new_item
		if(rand()%2 == 0)
			new_item = SceneDuplicateItem(scene, friend_item_rouge)
		else
			new_item = SceneDuplicateItem(scene, friend_item_blanc)
					
	//	ItemSetParent(new_item, new_parent_item)
		ItemSetLinkInheritsPositionOnly(new_item, true)
		SceneSetupItem(scene, new_item)
		ItemRenderSetup(new_item, g_factory)
		ItemActivate(new_item, true)		
		ItemSetPosition(new_item, Vector(0.0,0.0,0.0))
		ItemGetScriptInstance(new_item).new_parent_item = new_parent_item

			ItemSetPosition(new_item, ItemGetWorldPosition(new_parent_item) )
			ItemPhysicResetTransformation(new_item, ItemGetWorldPosition(new_parent_item) , Vector(0.0,0.0,0.0))


		local new_trigger = SceneDuplicateItem(scene, TriggerFriend)
					
		ItemSetParent(new_trigger, new_item)
		ItemSetLinkInheritsPositionOnly(new_item, true)
		SceneSetupItem(scene, new_trigger)
		ItemRenderSetup(new_trigger, g_factory)
		ItemActivate(new_trigger, true)		
		ItemSetPosition(new_trigger, Vector(0.0,0.0,0.0))

		friend_list.append(new_item)

		g_ParticlesManager.AddItemSpawner(new_item, this, Vector(0.0, 0.0, 0.0), Vector(0.1,0.0,-1.0))
	}	
	
	//*********************************************************************************

	function SpawnEnnemy(scene, _first=false)
	{
		local new_parent_item = SceneDuplicateItem(scene, DummyParentAmi)
					
		ItemSetParent(new_parent_item, artere)
		SceneSetupItem(scene, new_parent_item)
		ItemRenderSetup(new_parent_item, g_factory)
		ItemActivate(new_parent_item, true)		
		
		local z_rot_artere = ItemGetRotation(artere).z		
		local value_rand
		if(_first)
			value_rand = rand()%1575 *0.001 + 3.1415 -z_rot_artere
		else			
			value_rand = rand()%780 *0.001 + 3.1415 -z_rot_artere

		ItemSetPosition(new_parent_item, Vector(Rand(-70.0,70.0)+1165.01*cos(value_rand),Rand(-50.0, 50.0)+1165.01*sin(value_rand), Rand(-70.0,70.0)))

		local new_item
		if(rand()%2 == 0)
			new_item = SceneDuplicateItem(scene, ennemy_item_sida)
		else
			new_item = SceneDuplicateItem(scene, ennemy_item_dengue)
					
		ItemSetLinkInheritsPositionOnly(new_item, true)
//		ItemSetParent(new_item, NULL)
		SceneSetupItem(scene, new_item)
		ItemRenderSetup(new_item, g_factory)
		ItemActivate(new_item, true)		
		ItemSetPosition(new_item, Vector(0.0,0.0,0.0))
		ItemGetScriptInstance(new_item).new_parent_item = new_parent_item

			ItemSetPosition(new_item, ItemGetWorldPosition(new_parent_item) )
			ItemPhysicResetTransformation(new_item, ItemGetWorldPosition(new_parent_item) , Vector(0.0,0.0,0.0))
			ItemGetScriptInstance(new_item).origin_vec = ItemGetPosition(new_parent_item)

		ennemy_list.append(new_item)

		g_ParticlesManager.AddItemSpawner(new_item, this, Vector(0.0, 0.0, 0.0), Vector(0.1,0.0,-1.0))
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

		friend_list = []
		ennemy_list = []
	}
}

