
/*
	Ennemy
	*/
//-----------------------------
class   	Ennemy
{
	origin_vec = 0.0

	new_parent_item = 0
	body = 0

	//-------------------------------------------------------------------------------------
	radius			=	20.0
	speed			=	50.0
	fq				=	1.0
	inertia			=	0.99
	//-------------------------------------------------------------------------------------

	origin_vec		=	Vector(0, 0, 0)
	v				=	Vector(0, 0, 0)
	target			=	Vector(0, 0, 0)
	target_delay	=	0.0

	function	YouAreShoot()
	{
		if(!ItemIsInvisible(body))
			++SceneGetScriptInstance(g_scene).ennemy_killed

		print("fuck")
		ItemSetInvisible(body, true)
	//	SceneItemActivate(g_scene, body, false)
		origin_vec = 0
		target_delay = 0.0
	}

	//------------------
	function    OnUpdate(item)
	{
		body = item

		if(!origin_vec)
			origin_vec = ItemGetPosition(new_parent_item)

		target_delay -= g_dt_frame

		if	(target_delay <= 0.0)
		{
			local dt = Vector().Randomize(-radius, radius)
			target = origin_vec + dt;
			target_delay += fq;
		}

		local	p = ItemGetPosition(new_parent_item),
				w = ((target) - p).Normalize(speed)
		local	idt = Min(1.0 / g_dt_frame, 60.0)		// Keep the refresh rate in reasonable ranges.
		v += (w - v) * pow(inertia, idt)
		ItemSetPosition(new_parent_item, p + v * g_dt_frame)


		if(new_parent_item)
		{
			ItemSetPosition(item, ItemGetWorldPosition(new_parent_item))
			ItemPhysicResetTransformation(item, ItemGetWorldPosition(new_parent_item), Vector(0.0,0.0,0.0))
		}

	}


	//-----------
	function	Kill()
	{			
	}
	//-----------
	constructor()
	{			
		origin_vec = 0.0
	}
	
}
