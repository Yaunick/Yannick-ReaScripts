-- @description Yannick_Unselect every even item of selected items
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
  
  local t={}
  for i=1,reaper.CountSelectedMediaItems(0) do
    t[i] = reaper.GetSelectedMediaItem(0,i-1)
  end
  
  j = 2
  while j <= #t do
    tr_1 = reaper.GetMediaItemTrack(t[j-1])
    tr_2 = reaper.GetMediaItemTrack(t[j])
    if tr_1 == tr_2 then
      reaper.SetMediaItemSelected(t[j], false)
      reaper.UpdateItemInProject(t[j])
      j = j + 2
    else
      j = j + 1
    end
  end
  
  reaper.Undo_EndBlock('Unselect every even item of selected items', -1)
  reaper.PreventUIRefresh(-1)
