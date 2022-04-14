-- @description Yannick_Add or open Melodyne VST3 in selected items
-- @author Yannick
-- @version 1.0
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   + changed donation link
-- @contact b.yanushevich@gmail.com
-- @donation https://telegra.ph/How-to-send-me-a-donation-03-23

  function bla() 
  end 
  
  function nothing() 
    reaper.defer(bla) 
  end
  
  if reaper.CountSelectedMediaItems(0) > 0 then
  
    reaper.Undo_BeginBlock()
    reaper.PreventUIRefresh(1)
    
    local t = {}
    local count = 0
    for i=0, reaper.CountSelectedMediaItems(0)-1 do
     local item = reaper.GetSelectedMediaItem(0,i)
     local take = reaper.GetActiveTake(item)
     local retval, name = reaper.TakeFX_GetFXName( take, 0, 0)
     if name ~= 'VST3: Melodyne (Celemony)' then
       reaper.TakeFX_AddByName( take, 'Melodyne (Celemony)', -1)
     end
     if i == 0 then
      count = count+1
      t[count] = item
     end
     local item_2 = reaper.GetSelectedMediaItem(0,i+1)
     if item_2 then
       if reaper.GetMediaItemTrack(item) ~= reaper.GetMediaItemTrack(item_2) then
        count = count+1
        t[count] = item_2
       end
     end
    end
    
    for i=1, #t do 
      local take = reaper.GetActiveTake(t[i])
      reaper.TakeFX_Show( take, 0, 3)
    end
    
    reaper.Undo_EndBlock('Add or open melodyne', -1)
    reaper.PreventUIRefresh(-1)
  
  else 
    nothing() 
  end
