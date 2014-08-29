
class Particle
{
	direction = 0
	life = 0
	item = 0
	alive = 0	

	item_spawner = 0
	
	constructor(_item)
	{
		direction = Vector(1.0, 0.0, 0.0)		
		life = 0.0
		item = _item
		alive = false
		ItemActivate(item, false)

		item_spawner = 0
	}
}

class	ParticlesManager
{
	/*<
	<Script =
		<Name = "Particles">
		<Author = "Thomas Simonnet">
		<Description = "Particles">
		<Category = "">
		<Compatibility = <Item>>
	>
	<Parameter =
		<Count = <Name = "Count"> <Type = "Float"> <Default = 200.0>>
		<Speed = <Name = "Speed"> <Type = "Float"> <Default = 5.0>>
		<Accel = <Name = "Accel \n(1.0 constante; \n0.0 stop at the end"> <Type = "Float"> <Default = 0.2>>
		<LifeSpan = <Name = "LifeSpan"> <Type = "Float"> <Default = 5.0>>
		<AngleVariation = <Name = "AngleVariation"> <Type = "Float"> <Default = 0.01>>
		<Birth = <Name = "Birth"> <Type = "Float"> <Default = 1>>
		<NameObj = <Name = "NameObj"> <Type = "String"> <Default = "ObjPart">>
		<AgingPathTexture = <Name = "AgingPathTexture"> <Type = "String"> <Default = "ui/AgingPathTexture.png">>
	>
>*/

	list_item_pos = 0
	
	//--------------------------------------------------------------------------
	Count = 400.0
	Speed = 0.3
	Accel = 0.2
	LifeSpan = 0.3
	AngleVariation = 0.01
	Birth = 5
	
	//--------------------------------------------------------------------------		
	array_particles = 0
	
	WidthAgingTextureMulDivLifeSpan = 0
	array_pixel = 0
	
	AgingTexture = 0	

	id_place_to_spawn = 0
	
	function	Update()
	{		
		// if there is no item
		if(list_item_pos.len() <= 0)
			return

		local count_to_activate = Birth
		
		foreach(id, particle in array_particles)
		{
			if(particle.alive)
			{
				ItemSetPosition(particle.item, ItemGetWorldPosition(particle.item)+particle.direction*Speed*RangeAdjust(particle.life, 0.0, LifeSpan, 1.0, Accel) /** RangeAdjust(Clamp(particle.item_spawner.item_script.Speed, 0.0, 20.0), 0.0, 20.0, 0.0, 1.0)*/* g_dt_frame )
				ItemSetRotationMatrix(particle.item, RotationMatrixFromDirection((ItemGetWorldPosition(particle.item)-ItemGetWorldPosition(CameraGetItem(SceneGetCurrentCamera(g_scene)))).Normalize()))

			//	local scale = RangeAdjust(Clamp(particle.item_spawner.item_script.Speed, 0.0, 20.0), 0.0, 20.0, 0.1, 0.5)
			//	ItemSetScale(particle.item, Vector(scale, scale, scale))
				//set the color of the texture
				local XColor = particle.life * WidthAgingTextureMulDivLifeSpan
				
		//		local	material = GeometryGetMaterialFromIndex(ItemGetGeometry(particle.item), 0)
		//		MaterialSetDiffuse(material, array_pixel[XColor])								
				//MaterialSetDiffuse(material, Vector(XColor/100.0, 0.0, 0.0))				

				ItemSetOpacity(particle.item, XColor/100.0)

				particle.life += g_dt_frame
				if(LifeSpan < particle.life)
				{
					ItemSetOpacity(particle.item, 1.0)
					particle.life = Rand(0.0, LifeSpan*0.2)
					ItemActivate(particle.item, false)
					particle.alive = false
				}
			}
			else
			{
				if(count_to_activate > 0)
				{
					// check the item speed is not 0 and if the camera is not too far, (don't spawn far item)
					local temp_id_place_to_spawn = id_place_to_spawn
					do
					{
						++id_place_to_spawn
						if(id_place_to_spawn >= list_item_pos.len())
							id_place_to_spawn = 0
					}
					while(temp_id_place_to_spawn != id_place_to_spawn && (/*list_item_pos[id_place_to_spawn].item_script.Speed <= 1.0 ||*/
						ItemGetWorldPosition(list_item_pos[id_place_to_spawn].item).Dist2(ItemGetWorldPosition(g_MainCamera.module_camera_item)) > 100.0*100.0))

				//	if(list_item_pos[id_place_to_spawn].item_script.Speed > 1.0)
					{
						local position_to_spawn = ItemGetWorldPosition(list_item_pos[id_place_to_spawn].item) + list_item_pos[id_place_to_spawn].pos_offset

						particle.item_spawner = list_item_pos[id_place_to_spawn]
						ItemSetOpacity(particle.item, 0.0)
						ItemActivate(particle.item, true)
						particle.alive = true
						particle.life = Rand(0.0, LifeSpan*0.2)
						ItemSetPosition(particle.item, position_to_spawn)
						particle.direction = (list_item_pos[id_place_to_spawn].rot * ItemGetRotationMatrix(list_item_pos[id_place_to_spawn].item)+Vector(Rand(-10.0, 10.0), Rand(-10.0, 10.0), Rand(-10.0, 10.0))*AngleVariation).Normalize()
						ItemSetScale(particle.item, Vector(0.01,0.01,0.01))

						local scale =0.8//RangeAdjust(Clamp(particle.item_spawner.item_script.Speed, 0.0, 20.0), 0.0, 20.0, 0.1, 1.6)
						ItemSetCommandList(particle.item, "toscale 0.0,0.5,0.5,0.5;toscale "+LifeSpan+","+scale+",0.6,"+scale+";")
					//	ItemSetCommandList(particle.item, "toalpha 0.0,1.0;toalpha 2.0,0.1;")
					}
					--count_to_activate
				}
			}
		}
	}	
	
	//--------------------------------------------------------------------------	
	
	function	AddItemSpawner(_item, _item_script, _pos_offset, _rot)
	{
		list_item_pos.append({item = _item, item_script = _item_script, pos_offset = _pos_offset, rot = _rot})
	}
	
	//--------------------------------------------------------------------------	
	function	Kill()
	{
		Reset()
		array_particles.clear()
		array_pixel.clear()
		list_item_pos.clear()
	}
	//--------------------------------------------------------------------------	
	function	Reset()
	{
		foreach(id, particle in array_particles)
		{
			ItemSetOpacity(particle.item, 0.0)		
			ItemActivate(particle.item, false)
		}
	}
	
	//--------------------------------------------------------------------------	
	function	Setup()
	{
		if(array_particles.len() <= 0)
		{
			local group = SceneLoadAndStoreGroup(g_scene, "scenes/splash_particle.nms",  ImportFlagTrigger | ImportFlagObject | ImportFlagLight | ImportFlagCamera | ImportFlagCollision | ImportFlagPhysic)// FlagLoadAll & ~FlagLoadGlobals)		
			local	items = GroupGetItemList(group)
			foreach (item in items)
			{
				ItemRenderSetup(item, g_factory)
				SceneSetupItem(g_scene, item)
			}

			local particle_item = GroupFindItem(group, "splash_particle")	
			
			for(local i=0; i<Count; ++i)
			{			
				local new_item = SceneDuplicateItem(g_scene, particle_item)
							
				ItemSetParent(new_item, NullItem)
				SceneSetupItem(g_scene, new_item)
				ItemRenderSetup(new_item, g_factory)
				ItemActivate(new_item, true)		
				ItemSetPosition(new_item, ItemGetWorldPosition(particle_item))
				
				local particle = Particle(new_item)
				
				array_particles.append(particle)
			}
			
			ItemActivate(particle_item, false)
		
			// get the aging texture
			AgingTexture = PictureNew()
			PictureLoadContent(AgingTexture, "assets/particle_asset/AgingPathTexture.png")
			local WidthAgingTexture = PictureGetRect(AgingTexture).ex - PictureGetRect(AgingTexture).sx
			
			WidthAgingTextureMulDivLifeSpan = WidthAgingTexture.tofloat()/LifeSpan.tofloat()
			
			for(local i=0; i<WidthAgingTexture; ++i)
				array_pixel.append(PictureGetPixel(AgingTexture, i, 0))
		}
		else
		{	// hide the particles from the scene
			foreach(id, particle in array_particles)
			{
				ItemSetOpacity(particle.item, 1.0)
				particle.life = Rand(0.0, LifeSpan*0.2)
				ItemActivate(particle.item, false)
				particle.alive = false
			}
		}

		id_place_to_spawn = 0
	}
	constructor()
	{
		array_particles = []
		array_pixel = []

		list_item_pos = []
	}
}

