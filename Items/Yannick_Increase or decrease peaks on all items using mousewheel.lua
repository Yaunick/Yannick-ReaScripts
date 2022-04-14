-- @description Yannick_Increase or decrease peaks on all items using mousewheel
-- @author Yannick
-- @version 1.1
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   # changed donation link
--   # contact link changed
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14

	function Peaks()
		local _,_,_,_,_,_,val = reaper.get_action_context() 
		if val > 0 then
		reaper.Main_OnCommand(40155, 0)
		else
		reaper.Main_OnCommand(40156, 0)
		end
	end


	Peaks()


