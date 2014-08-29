
/*
	Main moving camera
	*/
//-----------------------------
class   	MainCamera
{

	scene_3D = 0

	array_viewpoint = 0
	current_viewpoint_index = 0
	
	module_camera_item		= 0

	old_mouse_position = 0

	array_traveling_in_progress = 0
	index_start_point = 0
	lerp_value = 0
	

	MatBSpline = [[ -1.0/6.0,  3.0/6.0, -3.0/6.0, 1.0/6.0],
                [  3.0/6.0, -6.0/6.0,  3.0/6.0, 0.0],
                [ -3.0/6.0,      0.0,  3.0/6.0, 0.0],
                [  1.0/6.0,  4.0/6.0,  1.0/6.0, 0.0]]
                     
	function		SplineEvaluation(p1, p2, p3, p4, t)
	{
		local t2, t3;	    
		t2= t*t; // precalculations
		t3= t2*t;
		
		return  p1*(t3*MatBSpline[0][0] + t2*MatBSpline[1][0] + t*MatBSpline[2][0] + MatBSpline[3][0]) +
		        p2*(t3*MatBSpline[0][1] + t2*MatBSpline[1][1] + t*MatBSpline[2][1] + MatBSpline[3][1]) + 
		        p3*(t3*MatBSpline[0][2] + t2*MatBSpline[1][2] + t*MatBSpline[2][2] + MatBSpline[3][2]) + 
		        p4*(t3*MatBSpline[0][3] + t2*MatBSpline[1][3] + t*MatBSpline[2][3] + MatBSpline[3][3]);		
	}

	is_stereo= false

	save_first_cam_pos = 0

	launch_complete_rotation = false
	rotate_angle = 0
		
	boom = false
	//------------------
	function    Update()
	{
		if(!save_first_cam_pos)
			save_first_cam_pos = ItemGetWorldPosition(module_camera_item)

		if("heart_beat" in SceneGetScriptInstance(g_scene))
		{
		
			// HEART BEAT MOVE
			local heart_beat = SceneGetScriptInstance(g_scene).heart_beat
			local heart_speed = SceneGetScriptInstance(g_scene).heart_speed

			if(heart_beat > 1.25 && !boom)
			{
				if(!is_stereo)
					ItemRegistrySetKey(module_camera_item, "PostProcess:RadialBlur:Strength", 0.5)

				boom = true
				ItemSetPosition(module_camera_item, ItemGetWorldPosition(module_camera_item)+Vector(0.0,0.0,0.25))
				CameraSetFov(ItemCastToCamera(module_camera_item), Deg(55.0))
			}
			if(heart_beat < 1.25)
				boom = false

			ItemSetPosition(module_camera_item, ItemGetWorldPosition(module_camera_item) - (ItemGetWorldPosition(module_camera_item)-save_first_cam_pos)*0.2)
			CameraSetFov(ItemCastToCamera(module_camera_item), CameraGetFov(ItemCastToCamera(module_camera_item)) - (CameraGetFov(ItemCastToCamera(module_camera_item))- Deg(50.0))*0.1 )

			if(!is_stereo)
				ItemRegistrySetKey(module_camera_item, "PostProcess:RadialBlur:Strength", ItemRegistryGetKey(module_camera_item, "PostProcess:RadialBlur:Strength")*0.9)

			local temp_inertie = ItemGetScriptInstance(LegacySceneFindItem(scene_3D, "vaisseau")).inertie_vec
			ItemSetRotation(module_camera_item, Vector(temp_inertie.y*0.3, 0.0, temp_inertie.x+rotate_angle))

			if(!launch_complete_rotation && ((SceneGetScriptInstance(scene_3D).timer_start >= 11.264 && SceneGetScriptInstance(scene_3D).timer_start < 12.0) || 
											(SceneGetScriptInstance(scene_3D).timer_start >= 25.021 && SceneGetScriptInstance(scene_3D).timer_start < 25.6) ||
											(SceneGetScriptInstance(scene_3D).timer_start >= 37.960 && SceneGetScriptInstance(scene_3D).timer_start < 39.4) ||
											(SceneGetScriptInstance(scene_3D).timer_start >= 44.432 && SceneGetScriptInstance(scene_3D).timer_start < 45.0) ||
											(SceneGetScriptInstance(scene_3D).timer_start >= 63.045 && SceneGetScriptInstance(scene_3D).timer_start < 64.0) ||
											(SceneGetScriptInstance(scene_3D).timer_start >= 75.945 && SceneGetScriptInstance(scene_3D).timer_start < 76.3) ||
											(SceneGetScriptInstance(scene_3D).timer_start >= 75.945 && SceneGetScriptInstance(scene_3D).timer_start < 76.3)  ))
			{
				launch_complete_rotation = true
				if(rand()%2 == 0)
					rotate_angle = PI*2.0
				else
					rotate_angle = PI*-2.0
			}
			else
			{
				if(rotate_angle <= 0.08)
				{
					rotate_angle = 0.0
					launch_complete_rotation = false
				}
				else
					rotate_angle -= (rotate_angle-g_dt_frame*3.0)*0.01
			}
		}

//		if(is_stereo)
//			RenderDoubleScreen()
//		else
			RenderSimpleScreen()
		
	}

	//------------------
	function    RenderSimpleScreen()
	{
		RendererSetViewItemAndApplyView(g_render, module_camera_item)

		SceneRegisterAsPropertyCallback(g_scene, g_render)
		
		ScenePushRenderable(scene_3D, g_render)
		RendererSetViewport(g_render, 0, 0, 1, 1)

		// Clear the complete viewport.
		RendererClearFrame(g_render, 0,0,0)

		RendererRenderQueue(g_render)
		RendererRenderQueueReset(g_render)
	}
	
	eye_dist = 0.042
  	convergence = 0.029
	//------------------
	function    RenderDoubleScreen()
	{		

		local save_cam_rot = ItemGetRotationMatrix(module_camera_item)		
		local save_cam_pos = ItemGetWorldPosition(module_camera_item)
		local cam_fov = CameraGetFov(ItemCastToCamera(module_camera_item))
		local cam_aspect_ratio = CameraGetAspectRatio(ItemCastToCamera(module_camera_item))

			RendererSetViewItemAndApplyView(g_render, module_camera_item)

			SceneRegisterAsPropertyCallback(g_scene, g_render)
			
			ScenePushRenderable(scene_3D, g_render)

			// Clear the complete viewport.
			RendererSetViewport(g_render, 0, 0, 1, 1)
			RendererSetClipping(g_render, 0, 0, 1, 1)
			RendererClearFrame(g_render, 0,0,0)


			// compute the horizontal_fov, from the viewport size and the original fov
			local	viewport = RendererGetViewport(g_render)
			local	viewport_ar = viewport.w / (viewport.z/3.0)			

			local	hyp = tan(cam_fov*0.5)
			local	horizontal_fov = atan(hyp /viewport_ar) 

			CameraSetAspectRatio(ItemCastToCamera(module_camera_item), viewport_ar)
			{
				//draw the middle screen
				{
					local rot_matrix = RotationMatrixY(-convergence)
					ItemSetRotationMatrix(module_camera_item, save_cam_rot * rot_matrix)
					ItemSetPosition(module_camera_item, save_cam_pos + ItemGetMatrix(module_camera_item).GetRow(0) * eye_dist *0.5)
				}
				RendererSetViewport(g_render, 0.0, 0.0, 0.5, 1.0)
				RendererRenderQueue(g_render)

				// draw the middle screen Left eye
				{
					local rot_matrix = RotationMatrixY(convergence)
					ItemSetRotationMatrix(module_camera_item, save_cam_rot * rot_matrix)
					ItemSetPosition(module_camera_item, save_cam_pos - ItemGetMatrix(module_camera_item).GetRow(0) * eye_dist *0.5)	// 7 cm
				}
				RendererSetViewport(g_render, 0.5, 0.0, 1.0, 1.0)
				RendererRenderQueue(g_render)
			}

			// force the ui render
			RendererSetViewport(g_render, 0, 0, 0.5, 1.0)
			SceneRenderUI(scene_3D, g_render)

			RendererSetViewport(g_render, 0.5, 0, 1, 1)
			RendererRenderQueueReset(g_render)

		ItemSetRotationMatrix(module_camera_item, save_cam_rot )
		ItemSetPosition(module_camera_item, save_cam_pos)

		CameraSetAspectRatio(ItemCastToCamera(module_camera_item), cam_aspect_ratio)

//		old_fps = Lerp(0.2, old_fps, (1.0/g_dt_frame))
//		WriterWrapper(g_SimuFont, old_fps.tointeger().tostring()+"fps", 10, 60, 0.2)
	}

	//-----------------------	
	function	ResetCamera()
	{	
		save_first_cam_pos = 0
		old_mouse_position = g_cursor.GetMousePos()				
	}

	//-----------
	function	Kill()
	{		
		module_camera_item = 0		
	}
	//-----------
	constructor()
	{				
		array_traveling_in_progress = []	
		index_start_point = 0
		lerp_value = 0.0
	}
	
	//-----------------------------
	function	PostLoad()
	{		
	}
	
	//-----------------------------
	function	LoadCamera(_project_script)
	{
		scene_3D = ProjectSceneGetInstance(_project_script.scene_driving)

		SceneSetRenderless(scene_3D, true) // will draw by ourself

		//local current_camera = SceneAddCamera(scene_3D, "Main_Camera")
		local current_camera = ItemCastToCamera(LegacySceneFindItem(scene_3D, "game_camera"))
	
		SceneSetCurrentCamera(scene_3D, current_camera)
		module_camera_item = CameraGetItem(current_camera)

		ItemSetFlags(module_camera_item, (1 << 4).tointeger(), true)		
		ItemSetNoTarget(module_camera_item)

		CameraSetFov(current_camera, Deg(50.0))
	
		CameraSetClipping(current_camera, Cm(20.0), 25000.0)

		local temp_camera = LegacySceneFindItem(scene_3D, "game_camera")

		ItemSetPosition(module_camera_item, ItemGetWorldPosition(temp_camera));		// Reset Camera to origin
		ItemSetRotation(module_camera_item, ItemGetRotation(temp_camera));		// Reset Camera orientation
	
	//	print("ModuleLoadCamera() : camera_item = " + ItemGetName(camera_item))
		print("ModuleLoadCamera() : current_camera = " + current_camera)
		print("ModuleLoadCamera() : module_camera_item = " + ItemGetName(module_camera_item))
	}
}
