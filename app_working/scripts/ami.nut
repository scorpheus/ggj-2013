
/*
	Ami
	*/
//-----------------------------
class   	Ami
{
	prev_minmax = 0

	new_parent_item = 0
	function	OnCollision(item, with_item)
	{
//		print("Yeah collide me friend")
//		SceneGetScriptInstance(g_scene).life -= 10.0
	}

	//------------------
	function    OnUpdate(item)
	{
		prev_minmax = ItemGetWorldMinMax(item)

		if(new_parent_item)
			ItemSetPosition(item, ItemGetWorldPosition(new_parent_item))


		ItemSetRotation(item, ItemGetRotation(item)+Vector(Rand(0.0, 100)*0.01*g_dt_frame*3.0,Rand(0.0, 100)*0.01*g_dt_frame*3.0,Rand(0.0, 100)*0.01*g_dt_frame*3.0))
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
