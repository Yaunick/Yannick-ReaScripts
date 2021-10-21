-- @description Yannick_Adjust take pitch using mousewheel (fine)
-- @author Yannick
-- @version 1.0
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   Initial release
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU
  
  function Pitch()
    local count = reaper.CountSelectedMediaItems()
    local _,_,_,_,_,_,val = reaper.get_action_context() 
    
    reaper.PreventUIRefresh(1)
    for i = 0, count-1 do
    local count = reaper.CountSelectedMediaItems()
    local selitem = reaper.GetSelectedMediaItem(0,i)
    local take =  reaper.GetActiveTake(selitem)
    local pitch_get = reaper.GetMediaItemTakeInfo_Value(take, 'D_PITCH')
    if val > 0 then
      pitch_val = 0.01
    else
      pitch_val = -0.01
    end
    reaper.SetMediaItemTakeInfo_Value(take, 'D_PITCH', pitch_get+pitch_val)
    reaper.UpdateItemInProject(selitem)
    end
    reaper.PreventUIRefresh(-1) 
  end
  
  reaper.defer(Pitch)


