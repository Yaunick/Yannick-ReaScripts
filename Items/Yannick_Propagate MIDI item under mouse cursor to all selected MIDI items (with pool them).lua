-- @description Yannick_Propagate MIDI item under mouse cursor to all selected MIDI items (with pool them)
-- @author Yannick
-- @version 1.2
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   + added new setting "duplicate by item snap offset" (false by default)
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14
  
  ----------------------------------------------
  
    duplicate_envelopes_under_items = false
    duplicate_by_item_snap_offset = false
  
  ----------------------------------------------
  
  function bla() end
  function nothing() reaper.defer(bla) end
  
  if duplicate_envelopes_under_items ~= false and duplicate_envelopes_under_items ~= true
  or (duplicate_by_item_snap_offset ~= false and duplicate_by_item_snap_offset ~= true)
  then
    reaper.MB('Incorrect values at the beginnig of the script','Error',0)
    nothing() return
  end
  
  if reaper.CountSelectedMediaItems(0) == 0 then
    nothing() return
  end
  
  local x,y = reaper.GetMousePosition()
  local sel_item = reaper.GetItemFromPoint(x,y,true)
  if not sel_item then
    nothing() return
  end
  
  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)
  
  if duplicate_by_item_snap_offset == false then
    offs_it = reaper.GetMediaItemInfo_Value(sel_item, 'D_SNAPOFFSET')
  else
    offs_it = 0
  end
  
  local t_items = {}
  local t_items_restore = {}
  local t_tracks = {}
  local index_item = nil
  
  for i=0, reaper.CountSelectedMediaItems(0)-1 do
    local item = reaper.GetSelectedMediaItem(0,i)
    if index_item == item then
      index_item = i+1
    end
    if reaper.TakeIsMIDI(reaper.GetActiveTake(item)) == false then
      reaper.MB('Please select only MIDI takes', 'Error',0)
      nothing() return
    end
    local item_track = reaper.GetMediaItem_Track(item)
    t_items[#t_items+1] = { item, reaper.GetMediaItemInfo_Value(item,'D_POSITION'), item_track }
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
  
  reaper.SetMediaItemSelected(sel_item, false) --- Select all items except under mouse
  reaper.Main_OnCommand(40006,0) --- Delete selected items
  reaper.SetMediaItemSelected(sel_item, true) ---- Select item under mouse
  reaper.Main_OnCommand(40698,0) --- Copy item
  
  for i=1, #t_items do
    if t_items[i][1] == sel_item then
      t_items_restore[#t_items_restore+1] = sel_item
    else
      reaper.SetEditCurPos(t_items[i][2] + offs_it,0,0)
      reaper.SetOnlyTrackSelected(t_items[i][3], true)
      reaper.Main_OnCommand(41072,0) --- past items with pool
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

  reaper.Undo_EndBlock("Propagate MIDI item under mouse cursor to all selected MIDI items (with pool them)",-1)
  reaper.PreventUIRefresh(-1)