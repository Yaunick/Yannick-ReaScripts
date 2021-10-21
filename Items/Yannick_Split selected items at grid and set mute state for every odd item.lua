-- @description Yannick_Split selected items at grid and set mute state for every odd item
-- @author Yannick
-- @version 1.0
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   Initial release
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU

  function bla() end function nothing() reaper.defer(bla) end
  
  if reaper.CountSelectedMediaItems(0) == 0 then
    reaper.MB('Please select an item', 'Error',0)
    nothing() return
  end
  
  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)
  
  reaper.Main_OnCommand(40932,0) -- split items at prject grid
  
  local t={}
  for i=1,reaper.CountSelectedMediaItems(0) do
    t[i] = reaper.GetSelectedMediaItem(0,i-1)
  end
  
  local j = 2
  while j <= #t+1 do
    local tr_1 = reaper.GetMediaItemTrack(t[j-1])
    if not t[j] then
      tr_2 = reaper.GetMediaItemTrack(t[j-1])
    else
      tr_2 = reaper.GetMediaItemTrack(t[j])
    end
    reaper.SetMediaItemInfo_Value(t[j-1], 'B_MUTE', 1)
    reaper.UpdateItemInProject(t[j-1])
    if tr_1 == tr_2 then
      j = j + 2
    else  
      j = j + 1
    end
  end
  
  reaper.Undo_EndBlock('Split selected items at grid and set mute state for every odd item', -1)
  reaper.PreventUIRefresh(-1)
