
/*
	Cible
	*/
//-----------------------------
class   	Cible
{
	limit_extend = 5.0

	inertie_vec = Vector(0.0,0.0,0.0)

	center_cible_pos = 0

	rotate_angle = 0

	//------------------
	function    OnUpdate(item)
	{
		if(!center_cible_pos)
			center_cible_pos = ItemGetWorldPosition(LegacySceneFindItem(g_scene, "center_cible"))

		// take care of the shortcut from the keyboard
		local keyboard_handle_device = GetKeyboardDevice()

		// up
		if(DeviceIsKeyDown(keyboard_handle_device, KeyUpArrow))
			inertie_vec += Vector(0.0,1.0,0.0) * g_dt_frame
		// left
		if(DeviceIsKeyDown(keyboard_handle_device, KeyLeftArrow))
			inertie_vec += Vector(-1.0,0.0,0.0) * g_dt_frame
		// right
		if(DeviceIsKeyDown(keyboard_handle_device, KeyRightArrow))
			inertie_vec += Vector(1.0,0.0,0.0) * g_dt_frame
		// down
		if(DeviceIsKeyDown(keyboard_handle_device, KeyDownArrow))
			inertie_vec += Vector(0.0,-1.0,0.0) * g_dt_frame

		local item_pos = ItemGetWorldPosition(item)
		if(Abs(item_pos.x-center_cible_pos.x + inertie_vec.x) > limit_extend)
			inertie_vec.x -= inertie_vec.x

		if(Abs(item_pos.y-center_cible_pos.y + inertie_vec.y) > limit_extend)
			inertie_vec.y -= inertie_vec.y

	//	ItemSetPosition(item, ItemGetWorldPosition(item) + inertie_vec)
		inertie_vec *= 0.9


		// shoot
		if(SceneGetScriptInstance(g_scene).heart_speed > 0.0)
		{
			local ui_device = GetInputDevice("mouse")
			if(DeviceIsKeyDown(keyboard_handle_device, KeySpace) ||
				DeviceIsKeyDown(ui_device, KeyButton0))
			{
				local contact_environment = SceneCollisionRaytrace(g_scene, ItemGetWorldPosition(g_MainCamera.module_camera_item), (ItemGetWorldPosition(item)-ItemGetWorldPosition(g_MainCamera.module_camera_item)).Normalize(), -1, CollisionTraceAll, -1.0)
				
				if	(contact_environment.hit)
				{
					if(ItemHasScript(contact_environment.item, "Ennemy")) 
					{
						ItemGetScriptInstance(contact_environment.item).YouAreShoot()

						if(rand()%2 == 0)
							rotate_angle = PI*2.0
						else
							rotate_angle = PI*-2.0
					}

			//		g_Debug2dManager.DrawCross(contact_environment.p)
				}
			}
		}

		// move the cilbe with the mouse
		local world_pos = CameraScreenToWorld(ItemCastToCamera(g_MainCamera.module_camera_item), g_render, g_cursor.cursor_prev_x, g_cursor.cursor_prev_y)
		local dist_to_cible = ItemGetWorldPosition(g_MainCamera.module_camera_item).Dist(center_cible_pos)

		ItemSetPosition(item, (world_pos - ItemGetWorldPosition(g_MainCamera.module_camera_item)).Normalize() * dist_to_cible)


		rotate_angle -= (rotate_angle-g_dt_frame*3.0)*0.1
		ItemSetRotation(item, Vector(0.0, 0.0, rotate_angle))
			
	}


	//-----------
	function	Kill()
	{			
	}
	//-----------
	constructor()
	{			
		inertie_vec = Vector(0.0,0.0,0.0)	
	}
	
}
