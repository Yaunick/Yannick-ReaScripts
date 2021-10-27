-- @description Yannick_Propagate first selected item to all selected items
-- @author Yannick
-- @version 1.0
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   Initial release
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU
  
  ----------------------------------------------
  
    duplicate_envelopes_under_items = false
  
  ----------------------------------------------
  
  function bla() end
  function nothing() reaper.defer(bla) end
  
  if duplicate_envelopes_under_items ~= false and duplicate_envelopes_under_items ~= true
  then
    reaper.MB('Incorrect values at the beginnig of the script','Error',0)
    nothing() return
  end
  
  if reaper.CountSelectedMediaItems(0) < 2 then
    reaper.MB("Please select several items", 'Error', 0)
    nothing() return
  end
  
  local t_items = {}
  local t_items_restore = {}
  local t_tracks = {}
  local sel_item = reaper.GetSelectedMediaItem(0,0)
  
  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)
  
  for i=0, reaper.CountSelectedMediaItems(0)-1 do
    local item = reaper.GetSelectedMediaItem(0,i)
    local item_track = reaper.GetMediaItem_Track(item)
    t_items[#t_items+1] = { reaper.GetMediaItemInfo_Value(item,'D_POSITION'), item_track }
  end
  
  if reaper.CountSelectedTracks(0) > 0 then
    for i=0, reaper.CountSelectedTracks(0)-1 do
      t_tracks[#t_tracks+1] = reaper.GetSelectedTrack(0,i)
    end
  end
  
  local change_option = false
  if duplicate_envelopes_under_items == false then
    if reaper.GetToggleCommandState(40070) == 1 then
      change_option = true
      reaper.Main_OnCommand(40070,0)
    end
  end
  
  local save_cur_pos = reaper.GetCursorPosition()
  
  reaper.SetMediaItemSelected(sel_item, false) --- Select all items except first
  reaper.Main_OnCommand(40006,0) --- Delete selected items
  reaper.SetMediaItemSelected(sel_item, true) ---- Select first item
  reaper.Main_OnCommand(40698,0) --- Copy item
  
  for i=1, #t_items do
    if i == 1 then
      t_items_restore[#t_items_restore+1] = sel_item
    else
      reaper.SetEditCurPos(t_items[i][1],0,0)
      reaper.SetOnlyTrackSelected(t_items[i][2], true)
      reaper.Main_OnCommand(42398,0) --- past items
      t_items_restore[#t_items_restore+1] = reaper.GetSelectedMediaItem(0,0)
    end
  end
  
  for i=1, #t_items_restore do
    reaper.SetMediaItemSelected(t_items_restore[i], true)
  end
  
  reaper.Main_OnCommand(40297,0)
  if #t_tracks > 0 then
    for i=1, #t_tracks do
      reaper.SetTrackSelected(t_tracks[i], true)
    end
  end
  
  reaper.SetEditCurPos(save_cur_pos,0,0)
  
  if change_option == true then
    reaper.Main_OnCommand(40070,0)
  end

  reaper.Undo_EndBlock("Propagate first selected item to all selected items",-1)
  reaper.PreventUIRefresh(-1)
