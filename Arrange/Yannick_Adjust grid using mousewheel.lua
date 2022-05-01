-- @description Yannick_Adjust grid using mousewheel
-- @author Yannick
-- @version 1.0
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   + initial release
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14

  function main()
    local _, grid,_,_ = reaper.GetSetProjectGrid(0, false, 0, 0, 0)
    local _,_,_,_,_,_,val = reaper.get_action_context()
    
    if val < 0 then 
      if grid < 4 then
        reaper.SetProjectGrid(0, grid*2) 
      end
    else 
      if grid > 1/256 then
        reaper.SetProjectGrid(0, grid/2) 
      end
    end
  end
  
  reaper.defer(main)
