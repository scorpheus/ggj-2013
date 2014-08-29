
/*
	Artere
	*/
//-----------------------------
class   	Artere
{
	increase_level_boolean = false

	boom = false

	speed = 0.0
	duration_time = 0.0

	increase_speed_hardness = 0
	//------------------
	function    OnUpdate(item)
	{
		if(duration_time.tointeger()%ProjectGetScriptInstance(g_project).seconde_before_go_to_next_step == 0)
		{
			if(!increase_level_boolean)
			{
				increase_level_boolean = true
				increase_speed_hardness += 0.1				
			}
		}
		else
			increase_level_boolean = false

		// HEART BEAT MOVE
		local heart_beat = SceneGetScriptInstance(g_scene).heart_beat
		local heart_speed = SceneGetScriptInstance(g_scene).heart_speed

		if(heart_speed <= 0.0)
			return 

		if(heart_beat > 1.25 && !boom)
		{
			boom = true
			speed = 0.1+ heart_speed*0.01
			ItemSetRotation(item, ItemGetRotation(item) + Vector(0.0, 0.0, speed)*g_dt_frame)
		}
		if(heart_beat < 1.25)
			boom = false

		local speed_temp = increase_speed_hardness + heart_speed*0.01
		speed -= (speed - speed_temp)*0.1
		ItemSetRotation(item, ItemGetRotation(item) + Vector(0.0, 0.0, speed)*g_dt_frame)
//		ItemSetRotation(item, ItemGetRotation(item) + Vector(0.0, 0.0, 0.5)*g_dt_frame)


		duration_time += g_dt_frame
	}

	//------------------
	function    OnReset(item)
	{
		duration_time = 1.0
		increase_speed_hardness = 0.3
	}

	//-----------
	function	Kill()
	{			
	}
	//-----------
	constructor()
	{			
	}
	
}
