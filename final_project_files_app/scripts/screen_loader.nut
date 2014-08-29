/*
	File: scripts/screen_loader.nut
	Author: Astrofra
*/

/*!
	@short	LogoScreen
	@author	Astrofra
*/
class	LoaderScreen
{
	display_timer		=	0
	sfx_channel			=	-1
	/*!
		@short	OnUpdate
		Called each frame.
	*/

	/*!
		@short	OnSetup
		Called when the scene is about to be setup.
	*/
	function	OnSetup(scene)
	{
		print("LoaderScreen::OnSetup()")
		display_timer = g_clock
		local	ui, logo, logo_flash, tick, bottom_banner, banner_back
		ui = SceneGetUI(scene)

		banner_back		= UIAddSprite(ui, -1, ResourceFactoryLoadTexture(g_factory, "ui/ui_loader_back.png"), 0, 960 - 512, 640, 256)
		SpriteSetScale(banner_back, 2, 2)
		bottom_banner	= UIAddSprite(ui, -1, ResourceFactoryLoadTexture(g_factory, "ui/ui_loader.png"), 0, 960 - 275, 1280, 275)
		logo_flash		= UIAddWindow(ui, -1, 0,0,0,0)
		tick			= UIAddSprite(ui, -1, ResourceFactoryLoadTexture(g_factory, "ui/tick.tga"), 0, 0, 96, 96)
		logo			= UIAddSprite(ui, -1, ResourceFactoryLoadTexture(g_factory, "ui/loading.png"), 0, 0, 256, 64)
		WindowSetPivot(logo, 128, 32)
		WindowSetPivot(tick, 96 * 0.5, 96 * 0.5)
		WindowSetPosition(logo, 1280.0 / 2.0, 960.0 / 2.0) //1.125 - 16.0)
		WindowSetPosition(tick, 128, 110)
		WindowSetParent(logo,logo_flash)
		WindowSetParent(tick,logo)
		WindowSetCommandList(logo_flash, "loop;toalpha 0.0,0.85;nop 0.01;toalpha 0.0,1.0;nop 0.01;next;")
		WindowSetCommandList(banner_back, "loop;toalpha 0.0,0.85;nop 0.01;toalpha 0.0,1.0;nop 0.01;next;")
		WindowSetCommandList(logo, "loop;toalpha 1.0,0.5;toalpha 1.0,1.0;next;")
		WindowSetCommandList(tick, "loop;toangle 0,0;toangle 1,90;toangle 1,180;toangle 1,270;toangle 1,360;next;")
	}
}
