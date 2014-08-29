
/*
	Vaisseau
	*/
//-----------------------------
class   	Vaisseau
{
	limit_extend = 5.0

	inertie_vec = Vector(0.0,0.0,0.0)

	center_cible_pos = 0

	prev_collide_friend = 0

	//-----------------------------------------------
	function			OnTrigger(item, trigger_item)
	//-----------------------------------------------
	{
	//	print("trigger "+ItemGetName(trigger_item))
	}
	

	//------------------
	function    OnUpdate(item)
	{
		if(!center_cible_pos)
			center_cible_pos = ItemGetWorldPosition(LegacySceneFindItem(g_scene, "center_cible"))

		// take care of the shortcut from the keyboard
		local keyboard_handle_device = GetKeyboardDevice()

		// up
		if(DeviceIsKeyDown(keyboard_handle_device, KeyZ))
			inertie_vec += Vector(0.0,1.2,0.0) * g_dt_frame
		// left
		if(DeviceIsKeyDown(keyboard_handle_device, KeyQ))
			inertie_vec += Vector(-1.2,0.0,0.0) * g_dt_frame
		// right
		if(DeviceIsKeyDown(keyboard_handle_device, KeyD))
			inertie_vec += Vector(1.2,0.0,0.0) * g_dt_frame
		// down
		if(DeviceIsKeyDown(keyboard_handle_device, KeyS))
			inertie_vec += Vector(0.0,-1.2,0.0) * g_dt_frame

		local item_pos = ItemGetWorldPosition(item)
		if(Abs(item_pos.x-center_cible_pos.x + inertie_vec.x) > limit_extend)
			inertie_vec.x -= inertie_vec.x

		if(Abs(item_pos.y-center_cible_pos.y + inertie_vec.y) > limit_extend)
			inertie_vec.y -= inertie_vec.y

		ItemSetPosition(item, ItemGetWorldPosition(item) + inertie_vec)
		inertie_vec *= 0.9

		local minmax = ItemGetWorldMinMax(item)
		// check if collide friend
		foreach(friend_item in SceneGetScriptInstance(g_scene).friend_list)
		{
			if(prev_collide_friend != friend_item && ItemGetScriptInstance(friend_item).prev_minmax)
			{
				local friend_min_max = ItemGetWorldMinMax(friend_item)
				local prev_friend_min_max = ItemGetScriptInstance(friend_item).prev_minmax
				if(friend_min_max.max.x < prev_friend_min_max.max.x)
					friend_min_max.max.x = prev_friend_min_max.max.x
				if(friend_min_max.max.y < prev_friend_min_max.max.y)
					friend_min_max.max.y = prev_friend_min_max.max.y
				if(friend_min_max.max.z < prev_friend_min_max.max.z)
					friend_min_max.max.z = prev_friend_min_max.max.z
				if(friend_min_max.min.x > prev_friend_min_max.min.x)
					friend_min_max.min.x = prev_friend_min_max.min.x
				if(friend_min_max.min.y > prev_friend_min_max.min.y)
					friend_min_max.min.y = prev_friend_min_max.min.y
				if(friend_min_max.min.z > prev_friend_min_max.min.z)
					friend_min_max.min.z = prev_friend_min_max.min.z

				if(ItemGetScriptInstance(friend_item).prev_minmax && doesCubeIntersectSphere(friend_min_max.min, friend_min_max.max, ItemGetWorldPosition(item), 0.5))
				{	print("kkkkkk")
					SceneGetScriptInstance(g_scene).life -= 10.0
					prev_collide_friend = friend_item
				}
				else
				if(ItemGetWorldPosition(friend_item).Dist2(ItemGetWorldPosition(item)) < ((minmax.max.z-minmax.min.z)*0.5)*((minmax.max.z-minmax.min.z)*0.5))
				{
					print("Hit")
					SceneGetScriptInstance(g_scene).life -= 10.0
					prev_collide_friend = friend_item
				}
			}
		}
	}
function squared( v) { return v * v; }
function doesCubeIntersectSphere( C1,  C2,  S,  R)
{
    local dist_squared = R * R;
    /* assume C1 and C2 are element-wise sorted, if not, do that now */
    if (S.x < C1.x) dist_squared -= squared(S.x - C1.x);
    else if (S.x > C2.x) dist_squared -= squared(S.x - C2.x);
    if (S.y < C1.y) dist_squared -= squared(S.y - C1.y);
    else if (S.y > C2.y) dist_squared -= squared(S.y - C2.y);
    if (S.z < C1.z) dist_squared -= squared(S.z - C1.z);
    else if (S.z > C2.z) dist_squared -= squared(S.z - C2.z);
    return dist_squared > 0;
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
