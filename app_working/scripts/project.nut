/*
	Project Handler
*/

Include("scripts/utils/global_independent_include.nut")

class	ProjectHandler
{

	dispatch				=	0

	scene_key				=	0
	prev_scene_key			=	0

	asset_type				=	0

	scene_driving			=	0
	scene_loading			=	0

	force_reload_scene		=	false

	groups					=	0

	paths					=	0
	prev_paths				=	0
	
	loading_key_path = 0

	seconde_before_go_to_next_step = 15.0

	function	LoadScenario(_key)
	{
		scene_key = _key
	}

	function	ResetScenario()
	{	
		g_MainCamera.ResetCamera()
		SceneReset(ProjectSceneGetInstance(scene_driving))
	}

	function	OnSetup(project)
	{
		// switch the vsync on
		RendererRegistrySetKey(g_render, "VSync:Enable", true)

		//LoadScenario("scenes/menu_scene.nms")
		LoadScenario("scenes/level3.nms")
	}

	function	OnUpdate(project)
	{
		if (dispatch != 0)
			dispatch(project)
	}

	function	MainUpdate(project)
	{
		if (scene_key != prev_scene_key || force_reload_scene)
		{
			if(scene_driving)
			{
				UISetGlobalFadeColor ( SceneGetUI(ProjectSceneGetInstance(scene_driving)), 1.0,0.0,1.0 )
				UISetGlobalFadeEffect (  SceneGetUI(ProjectSceneGetInstance(scene_driving)), 0.0 )
				UISetCommandList( SceneGetUI(ProjectSceneGetInstance(scene_driving)), "globalfade 0.5, 1.0;")
			}

			force_reload_scene = false
			
			//	Open the loading screen
			CreateLoadingScreen(project)
			
			paths.clear()
			paths.rawset("main_scene",scene_key)

			//	Initiate the loading iterator
			asset_type = "main_scene"
			dispatch = LoadAsset
			prev_scene_key = scene_key
			
			loading_key_path = [] 
			foreach(key, value in paths)
				loading_key_path.append(key)
		}
	}

	function	CreateLoadingScreen(project)
	{
		print("ProjectHandler::CreateLoadingScreen()")
		if (scene_loading == 0)
			scene_loading = ProjectLoadScene(project, "scenes/screen_loader.nms", -1.0)
	}

	function	DestroyLoadingScreen(project)
	{
		if (scene_loading != 0)
		{
			ProjectUnloadScene(project, scene_loading)
			scene_loading = 0
		}

		if(scene_driving)
		{
			UISetGlobalFadeColor (  SceneGetUI(ProjectSceneGetInstance(scene_driving)), 1.0,0.0,1.0 )
			UISetGlobalFadeEffect (  SceneGetUI(ProjectSceneGetInstance(scene_driving)), 1.0 )

			UISetCommandList( SceneGetUI(ProjectSceneGetInstance(scene_driving)), "globalfade 0.5, 0.0;")
		}
	}

	function	LoadAsset(project)
	{
		if (!(asset_type in prev_paths))
			prev_paths.rawset(asset_type,0)

		if (!(asset_type in groups))
			groups.rawset(asset_type,0)

		switch(asset_type)
		{
			//	Main Scene
			case	"main_scene" :
	

				if (paths[asset_type] != prev_paths[asset_type])
				{					
					prev_paths.clear()
					groups.clear()

					g_WindowsManager.Kill(true)		
					g_ParticlesManager.Reset()	
					g_ParticlesManager.Kill()		
					
					print("ProjectHandler::LoadAsset() Loading scene '" + paths[asset_type] + "').")
					if (scene_driving != 0)
						ProjectUnloadScene(project, scene_driving)

					scene_driving =	ProjectLoadScene(project, paths[asset_type])
					print("ProjectHandler::LoadAsset() Finished scene load '" + paths[asset_type] + "').")	

					// kill the windows, for the moment I don't know where to place it.
					g_WindowsManager.current_ui = SceneGetUI(ProjectSceneGetInstance(scene_driving))												
				}
				else
				{			
									
				}

				// kill the windows, for the moment I don't know where to place it.
				g_WindowsManager.current_ui = SceneGetUI(ProjectSceneGetInstance(scene_driving))


				asset_type = FindNextAssetTypeToLoad(asset_type)
				break

			default:				//	Any other type of assets will be loaded or reset
				if (paths[asset_type] != prev_paths[asset_type])
				{
					//	Delete the previous asset group and append the new one to the main scene.
					if (groups[asset_type] != 0)
					{
						print("delete previous group")
						SceneDeleteGroup(ProjectSceneGetInstance(scene_driving), groups[asset_type])
						SceneFlushDeletionQueue(ProjectSceneGetInstance(scene_driving))
						groups[asset_type] = 0
					}
					print("ProjectHandler::LoadAsset() Loading scene '" + paths[asset_type] + "').")
					groups[asset_type] = SceneLoadAndStoreGroup(ProjectSceneGetInstance(scene_driving), paths[asset_type], ImportFlagTrigger | ImportFlagObject | ImportFlagLight | ImportFlagCamera | ImportFlagCollision | ImportFlagPhysic)

					GroupSetup(groups[asset_type])
					SceneGroupSetup(ProjectSceneGetInstance(scene_driving), groups[asset_type])
					GroupSetupScript(groups[asset_type])
					print("ProjectHandler::LoadAsset() Finished scene load '" + paths[asset_type] + "').")
				}
				else
					GroupReset(groups[asset_type])

				asset_type = FindNextAssetTypeToLoad(asset_type)
				break	
		}

		if (asset_type == 0)
		{			
			g_MainCamera.LoadCamera(this)
			g_MainCamera.PostLoad()

			ResetScenario()
			
			prev_paths = clone(paths)
			dispatch = MainUpdate
			DestroyLoadingScreen(project)
		}
	}

	/*
		Find the next asset type to load, 
		based on the value of the current one.
	*/
	function	FindNextAssetTypeToLoad(_type)
	{
		loading_key_path.remove(loading_key_path.find(_type))
		
		if (loading_key_path.len() <= 0)
			return 0
		else
			return loading_key_path[0]
		
		/*
		local	key_array = []
		foreach(key, value in paths)
			key_array.append(key)

		local	idx = key_array.find(_type)
		idx++

		if (idx >= key_array.len())
			return	0
		else
			return key_array[idx]		
			*/
	}

	function	SceneGroupSetup(scene, group)
	{		
		local	items = GroupGetItemList(group)
		foreach (item in items)
		{
			ItemRenderSetup(item, g_factory)
			SceneSetupItem(scene, item)
		}
	}

	function	SceneItemsSetup(scene)
	{
		local	items = SceneGetItemList(scene)
		foreach (item in items)
		{
			print("SceneItemsSetup() : item = " + ItemGetName(item) + ".")
			SceneSetupItem(scene, item)
			ItemRenderSetup(item, g_factory)
		}
	}

	/*
		Generic function that loads a scene, instanciate is as a layer,
		then starts a fade out/fade in.
	*/
	function	ProjectLoadScene(project, scene_filename, priority = 0.5)
	{
		local	scene = 0

		if	(FileExists(scene_filename))
		{
			print("ProjectHandler::ProjectLoadScene() Loading scene '" + scene_filename + "'.")
			scene = ProjectInstantiateScene(project, scene_filename)
			ProjectAddLayer(project, scene, priority)
		}
		else
			error("ProjectHandler::ProjectLoadScene() Cannot find scene '" + scene_filename + "'.")

		return	scene
	}

	constructor()
	{
		print("ProjectHandler::constructor()")
		paths = {}
		prev_paths = clone(paths)
		groups = clone(paths)

		dispatch = MainUpdate
	}
}