
Include("scripts/utils/global_independent_include.nut")

class	TemplateDebugScriptScene
{
	global_item_update = 0


//********************************************************************************************
	
	function OnRenderDone(scene)
	{	
		ItemGetScriptInstance(global_item_update).OnRenderUser(scene)
	}
	
//********************************************************************************************
	
	/*! @short	OnUpdate Called each frame. */ 
	function	OnUpdate(scen
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

