-- @description Yannick_Bounce selection (selected items on the track merge into one new item)
-- @author Yannick
-- @version 1.4
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   + fixed script work if items are located on item lanes
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14

  ------------------------------------------------------------------------------------------------
    
    tail_for_new_item = 0   --- sec
    unser_inputs_for_entering_tail = true
    mute_original_items = true
    mute_original_tracks = false
    
    render_in = 2   --- 1 = mono
                    --- 2 = stereo
                    --- 3 = multichannel
  
  ------------------------------------------------------------------------------------------------

  function bla() end
  function nothing() reaper.defer(bla) end
  
  if not tonumber(tail_for_new_item) or tail_for_new_item < 0
  or unser_inputs_for_entering_tail ~= true and unser_inputs_for_entering_tail ~= false
  or mute_original_items ~= true and mute_original_items ~= false
  or mute_original_tracks ~= true and mute_original_tracks ~= false
  or render_in ~= 1 and render_in ~= 2 and render_in ~= 3
  then
    reaper.MB('Incorrect values at the beginning of the script', 'Error', 0)
    nothing() return
  end
  
  local test_SWS = reaper.CF_EnumerateActions
  if not test_SWS then
    reaper.MB('Please install or update SWS extension', 'Error', 0) nothing() return
  end
  
  if reaper.CountSelectedMediaItems(0) == 0 then
    reaper.MB('No items. Please select an item', 'Error', 0)
    nothing() return
  end
  
  local save_start, save_end = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
  local cur_pos = reaper.GetCursorPosition()
  
  local t_items = {}
  local t_new_tracks = {}
  for i=0, reaper.CountSelectedMediaItems(0)-1 do
    local item = reaper.GetSelectedMediaItem(0,i)
    local item_track = reaper.GetMediaItemTrack(item)
    if reaper.GetMediaItemInfo_Value(item, 'B_MUTE') == 0 then
      t_items[#t_items+1] = { item, item_track }
    end
  end
  
  if #t_items == 0 then
    reaper.MB('No unmuted items', 'Error', 0)
    nothing() return
  end
  
  if unser_inputs_for_entering_tail == true then
    ::START::
    local retval, value = reaper.GetUserInputs('Set tail for new items', 1, "Set tail (sec):", tail_for_new_item)
    if not retval then
      nothing() return
    end
    local value = tonumber(value)
    if not tonumber(value) or value < 0 then
      reaper.MB('Incorrect value. Please enter a valid value', 'Error',0)
      goto START
    end
    tail_for_new_item = value
  end
  
  reaper.Undo_BeginBlock()
  
  render_ts = reaper.SNM_GetIntConfigVar('workrender',0)
  change_setting = false
  if render_ts&8192 == 8192 then
    local render_ts2 = render_ts&~(render_ts&8192)
    reaper.SNM_SetIntConfigVar('workrender',render_ts2)
    change_setting = true
  end
  
  reaper.Main_OnCommand(40289,0) -- unsecelt all items
  
  for i=1, #t_items do
    reaper.SetMediaItemSelected(t_items[i][1], true)
    reaper.UpdateItemInProject(t_items[i][1])
    if i == #t_items
    or t_items[i][2] ~= t_items[i+1][2] then
      reaper.SetOnlyTrackSelected(t_items[i][2], true)
      reaper.Main_OnCommand(40290,0) -- set TS to items
      local get_st, get_en = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
      reaper.GetSet_LoopTimeRange(true, false, get_st, get_en+tail_for_new_item, false)
      
      reaper.PreventUIRefresh(1)
      
      local count_mute = {}
      local sel_track = reaper.GetSelectedTrack(0,0)
      for i=0, reaper.CountTrackMediaItems(sel_track)-1 do
        local item = reaper.GetTrackMediaItem(sel_track,i)
        local pos_item = reaper.GetMediaItemInfo_Value(item, 'D_POSITION')
        local end_item = pos_item + reaper.GetMediaItemInfo_Value(item, 'D_LENGTH')
        if end_item >= get_st and end_item <= get_en + tail_for_new_item + 1
        or pos_item >= get_st and pos_item <= get_en + tail_for_new_item + 1
        or pos_item < get_st and end_item > get_en + tail_for_new_item + 1
        then
          count_mute[#count_mute+1] = { item, reaper.GetMediaItemInfo_Value(item, 'B_MUTE') }
          if reaper.IsMediaItemSelected(item) == false then
            reaper.SetMediaItemInfo_Value(item, 'B_MUTE', 1)
          end
        end
      end
      
      local count_tr_before = reaper.CountTracks(0)
      -------------------------------------------
      if render_in == 1 then
        reaper.Main_OnCommand(41721,0) -- render mono
      elseif render_in == 2 then
        reaper.Main_OnCommand(41719,0) -- render stereo
      elseif render_in == 3 then
        reaper.Main_OnCommand(41720,0) -- render multichannel
      end
      -------------------------------------------
      local count_tr_after = reaper.CountTracks(0)
      
      for i=1, #count_mute do
        reaper.SetMediaItemInfo_Value(count_mute[i][1], 'B_MUTE', count_mute[i][2])
      end
      
      reaper.PreventUIRefresh(-1)
    
      if count_tr_before == count_tr_after then
        goto NEXT
      end
      
      reaper.PreventUIRefresh(1)
      if mute_original_items == true then
        reaper.Main_OnCommand(40719,0) -- mute items
      end
      
      if mute_original_tracks == false then
        reaper.SetMediaTrackInfo_Value(t_items[i][2], 'B_MUTE', 0)
      end
      
      reaper.Main_OnCommand(40289,0) -- unsecelt all items
      t_new_tracks[#t_new_tracks+1] = reaper.GetSelectedTrack(0,0)
      reaper.PreventUIRefresh(-1)
    end
  end
  
  ::NEXT::
  reaper.PreventUIRefresh(1)
  for i=1, #t_new_tracks do
    reaper.SetTrackSelected(t_new_tracks[i], true)
    reaper.SetMediaItemSelected(reaper.GetTrackMediaItem(t_new_tracks[i],0), true)
  end
  reaper.PreventUIRefresh(-1)
  
  reaper.GetSet_LoopTimeRange(true, false, save_start, save_end, false)
  reaper.SetEditCurPos(cur_pos, false, false)
  
  if change_setting == true then
    reaper.SNM_SetIntConfigVar('workrender',render_ts)
  end
  
  reaper.Undo_EndBlock('Bounce selection (selected items on the track merge into one new item)',-1)