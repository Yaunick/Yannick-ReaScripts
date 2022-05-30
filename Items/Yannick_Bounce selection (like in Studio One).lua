-- @description Yannick_Bounce selection (like in Studio One)
-- @author Yannick
-- @version 1.5
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   + unselect muted items before render
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14

  ---------------------------------------------------------------------
  
    render_overlaid_items_into_one_item = true
    render_every_selected_item_to_new_track = false
    mute_original_items = true
    mute_original_tracks = false
    tail_for_every_item = 0
    user_input_for_entering_tail = true
    
    render_in = 2   --- 1 = mono
                    --- 2 = stereo
                    --- 3 = multichannel
                    
  ---------------------------------------------------------------------
  
  function bla() end
  function nothing() reaper.defer(bla) end
  
  if (render_overlaid_items_into_one_item ~= true and render_overlaid_items_into_one_item ~= false)
  or (render_every_selected_item_to_new_track ~= true and render_every_selected_item_to_new_track ~= false)
  or (mute_original_items ~= true and mute_original_items ~= false)
  or (mute_original_tracks ~= true and mute_original_tracks ~= false)
  or (not tonumber(tail_for_every_item) or tail_for_every_item < 0)
  or (user_input_for_entering_tail ~= true and user_input_for_entering_tail ~= false)
  or (not tonumber(render_in) or (render_in ~= 1 and render_in ~= 2 and render_in ~= 3))
  then
    reaper.MB('Incorrect values for some line in user settings. Look at the beginning of the script', 'Error',0)
    nothing() return
  end
  
  local test_SWS = reaper.CF_EnumerateActions
  if not test_SWS then
    reaper.MB('Please install or update SWS extension', 'Error', 0) nothing() return
  end
  
  local items_count = reaper.CountSelectedMediaItems(0)
  if items_count == 0 then
    nothing() return
  end
  
  if user_input_for_entering_tail == true then
    ::START_INPUT::
    retval, retvals_csv = reaper.GetUserInputs
    (
    'Bounce selection (like in Studio One)', 
    1, 
    'Set tail for item(s):', 
    tail_for_every_item
    )
    if not retval then
      nothing() return
    end
    local t_values = {}
    for s in string.gmatch(retvals_csv, "[^,]+") do
      table.insert(t_values,s)
    end
    if #t_values ~= 1 or not tonumber(t_values[1]) or tonumber(t_values[1]) < 0 then
      reaper.MB('Incorrect value. Please enter a valid value', 'Error',0)
      goto START_INPUT
    end
    tail_for_every_item = tonumber(t_values[1])
  end
  
  reaper.Undo_BeginBlock()
  
  render_ts = reaper.SNM_GetIntConfigVar('workrender',0)
  change_setting = false
  if render_ts&8192 == 8192 then
    local render_ts2 = render_ts&~(render_ts&8192)
    reaper.SNM_SetIntConfigVar('workrender',render_ts2)
    change_setting = true
  end
  
  local save_start_ts, save_end_ts = reaper.GetSet_LoopTimeRange( false, false, 0, 0, false )
  local save_cur_pos = reaper.GetCursorPosition()
  
  function FindTracksWithSelectedItems()
    local t = {}
    for i=0, items_count-1 do
      local item = reaper.GetSelectedMediaItem(0,i)
      if reaper.GetMediaItemInfo_Value(item, 'B_MUTE') == 0 then
        t[#t+1] = { item, reaper.GetMediaItemTrack(item) }
      end
    end
    return t
  end
  
  function FindAllDifferentTracks(table)
    local t = {}
    for i=1, #table do
      if i < #table then
        if table[i][2] ~= table[i+1][2] then
          t[#t+1] = table[i][2]
        end
      else
        t[#t+1] = table[i][2]
      end
    end
    return t
  end
  
  function MuteAllUnselectedItemsWithinTimeSelection(track)
    local count_mute = {}
    local restore_mute = {}
    local get_start_ts, get_end_ts = reaper.GetSet_LoopTimeRange( false, false, 0, 0, false )
    for i=0, reaper.CountTrackMediaItems(track)-1 do
      local item = reaper.GetTrackMediaItem(track, i)
      local pos_item = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
      local end_item = pos_item + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
      if end_item >= get_start_ts and end_item <= get_end_ts + 1
      or pos_item >= get_start_ts and pos_item <= get_end_ts + 1
      or pos_item < get_start_ts and end_item > get_end_ts + 1
      then
        count_mute[#count_mute+1] = { item, reaper.GetMediaItemInfo_Value(item, 'B_MUTE') }
        if reaper.IsMediaItemSelected(item) == false then
          reaper.SetMediaItemInfo_Value(item, 'B_MUTE', 1)
        else
          restore_mute[#restore_mute+1] = item
        end
      end
      if pos_item > get_end_ts + 1 then
        break
      end
    end
    return count_mute, restore_mute
  end
  
  function RestoreMutedItems(table)
    for i=1, #table do
      reaper.SetMediaItemInfo_Value(table[i][1], 'B_MUTE', table[i][2])
    end
  end
  
  function GetItemSets(table_1, table_2)
    local number_set = 1
    local count_sets = 0
    local t = {}
    local t_sets = {}
    for i=1, #table_1 do
      local item_start = reaper.GetMediaItemInfo_Value(table_1[i][1], 'D_POSITION')
      if i == #table_1 then
        item_start_2 = item_start
        item_track_2 = table_1[i][2]
      else
        item_start_2 = reaper.GetMediaItemInfo_Value(table_1[i+1][1], 'D_POSITION')
        item_track_2 = table_1[i+1][2]
      end 
      local item_end = item_start + reaper.GetMediaItemInfo_Value(table_1[i][1], 'D_LENGTH')
      if not save_it_end 
      or item_end > save_it_end 
      then
        save_it_end = item_end
      end
      t[#t+1] = { table_1[i][1], number_set}
      if save_it_end 
      and (item_track_2 ~= table_1[i][2] or item_start_2 >= save_it_end) 
      then
        number_set = number_set + 1
        save_it_end = nil
        count_sets = count_sets + 1
        if item_track_2 ~= table_1[i][2] then
          t_sets[#t_sets+1] = { count_sets, table_1[i][2] }
          count_sets = 0
        end
      end
      if i == #table_1 then
        count_sets = count_sets + 1
        t_sets[#t_sets+1] = { count_sets, table_1[i][2] }
      end
    end
    return t, t_sets
  end
  
  function RenderSetsOfItems(table_1, table_2 )
    local i3 = 1
    local t = {}
    for i=1, #table_2 do
      for i2=1, table_2[i][1] do
        reaper.PreventUIRefresh(1)
        reaper.SetOnlyTrackSelected(table_2[i][2], true)
        reaper.Main_OnCommand(40289, 0) -- unselect all items
        local bool = false
        repeat
          reaper.SetMediaItemSelected(table_1[i3][1], true)
          if i3 == #table_1 or table_1[i3][2] ~= table_1[i3+1][2]
          then
            bool = true
          end
          i3 = i3 + 1
        until bool == true
        
        reaper.Main_OnCommand(40290, 0) -- set TS to items
        local start_ts_set, save_end_set = reaper.GetSet_LoopTimeRange( false, false, 0, 0, false )
        reaper.GetSet_LoopTimeRange( true, false, start_ts_set, save_end_set + tail_for_every_item, false )
        
        ---RENDER----
        local count_tr_br = reaper.CountTracks(0)
        local restore_t, mute_t = MuteAllUnselectedItemsWithinTimeSelection(table_2[i][2])
        
        if render_in == 1 then
          reaper.Main_OnCommand(41721,0) -- render mono
        elseif render_in == 2 then
          reaper.Main_OnCommand(41719,0) -- render stereo
        elseif render_in == 3 then
          reaper.Main_OnCommand(41720,0) -- render multichannel
        end
        
        RestoreMutedItems(restore_t)
        local count_tr_ar = reaper.CountTracks(0)
        -------------
        
        reaper.SetMediaTrackInfo_Value(table_2[i][2], 'B_MUTE', 0)
        if count_tr_br == count_tr_ar then
          end_l = true
          save_tra = table_2[i][2]
          goto END_LOOP
        end
        if mute_original_items == true then
          for h=1, #mute_t do
            reaper.SetMediaItemInfo_Value(mute_t[h], 'B_MUTE', 1)
          end
          reaper.Main_OnCommand(40289, 0) -- unselect all items
        end
        if i2 > 1 then
          if render_every_selected_item_to_new_track == false then
            local ge_tra = reaper.GetTrack( 0, reaper.GetMediaTrackInfo_Value( reaper.GetSelectedTrack(0,0), 'IP_TRACKNUMBER' )-2 )
            reaper.MoveMediaItemToTrack( reaper.GetTrackMediaItem( reaper.GetSelectedTrack(0,0), 0), ge_tra )
            reaper.DeleteTrack( reaper.GetSelectedTrack(0,0) )
          end
        end
        reaper.PreventUIRefresh(-1)
      end
      if mute_original_tracks == true then
        reaper.SetMediaTrackInfo_Value(table_2[i][2], 'B_MUTE', 1)
      end
      t[#t+1] = reaper.GetTrack( 0, reaper.GetMediaTrackInfo_Value( table_2[i][2], 'IP_TRACKNUMBER' )-2 )
    end
    ::END_LOOP::
    if end_l == true then
      if mute_original_tracks == true then
        reaper.SetMediaTrackInfo_Value(save_tra, 'B_MUTE', 1)
      end
      t[#t+1] = reaper.GetTrack( 0, reaper.GetMediaTrackInfo_Value( save_tra, 'IP_TRACKNUMBER' )-2 )
      reaper.PreventUIRefresh(-1)
    end
    return t
  end
  
  function RenderEveryItemToTrack(table)
    local bool_new_track = false
    local count = 0
    local t = {}
    for i=1, #table do
      reaper.PreventUIRefresh(1)
      reaper.SetOnlyTrackSelected(table[i][2], true)
      reaper.Main_OnCommand(40289, 0) -- unselect all items
      reaper.SetMediaItemSelected(table[i][1], true)
      
      reaper.Main_OnCommand(40290, 0) -- set TS to items
      local start_ts_set, save_end_set = reaper.GetSet_LoopTimeRange( false, false, 0, 0, false )
      reaper.GetSet_LoopTimeRange( true, false, start_ts_set, save_end_set + tail_for_every_item, false )
      
      ---RENDER----
      local count_tr_br = reaper.CountTracks(0)
      local restore_t, mute_t = MuteAllUnselectedItemsWithinTimeSelection(table[i][2])
      
      if render_in == 1 then
        reaper.Main_OnCommand(41721,0) -- render mono
      elseif render_in == 2 then
        reaper.Main_OnCommand(41719,0) -- render stereo
      elseif render_in == 3 then
        reaper.Main_OnCommand(41720,0) -- render multichannel
      end
      
      RestoreMutedItems(restore_t)
      local count_tr_ar = reaper.CountTracks(0)
      -------------
      
      reaper.SetMediaTrackInfo_Value(table[i][2], 'B_MUTE', 0)
      if count_tr_br == count_tr_ar then
        end_l = true
        save_tra = table[i][2]
        goto END_LOOP_2
      end
      if mute_original_items == true then
        for h=1, #mute_t do
          reaper.SetMediaItemInfo_Value(mute_t[h], 'B_MUTE', 1)
        end
        reaper.Main_OnCommand(40289, 0) -- unselect all items
      end
      if i == 1 then
        nothing()
      elseif table[i][2] ~= table[i-1][2] then
        if mute_original_tracks == true then
          reaper.SetMediaTrackInfo_Value(table[i-1][2], 'B_MUTE', 1)
        end
        t[#t+1] = reaper.GetTrack( 0, reaper.GetMediaTrackInfo_Value( table[i-1][2], 'IP_TRACKNUMBER' )-2 )
      else
        if render_every_selected_item_to_new_track == false then
          local ge_tra = reaper.GetTrack( 0, reaper.GetMediaTrackInfo_Value( reaper.GetSelectedTrack(0,0), 'IP_TRACKNUMBER' )-2 )
          reaper.MoveMediaItemToTrack( reaper.GetTrackMediaItem( reaper.GetSelectedTrack(0,0), 0), ge_tra )
          reaper.DeleteTrack( reaper.GetSelectedTrack(0,0) )
        end
      end
      if i == #table then
        if mute_original_tracks == true then
          reaper.SetMediaTrackInfo_Value(table[i][2], 'B_MUTE', 1)
        end
        t[#t+1] = reaper.GetTrack( 0, reaper.GetMediaTrackInfo_Value( table[i][2], 'IP_TRACKNUMBER' )-2 )
      end
      reaper.PreventUIRefresh(-1)
    end
    ::END_LOOP_2::
    if end_l == true then
      if mute_original_tracks == true then
        reaper.SetMediaTrackInfo_Value(save_tra, 'B_MUTE', 1)
      end
      t[#t+1] = reaper.GetTrack( 0, reaper.GetMediaTrackInfo_Value( save_tra, 'IP_TRACKNUMBER' )-2 )
      reaper.PreventUIRefresh(-1)
    end
    return t
  end
  
  local t_items_tracks = FindTracksWithSelectedItems()
  local t_different_tracks = FindAllDifferentTracks(t_items_tracks)
  
  if render_overlaid_items_into_one_item == true then
    local t_set_items, t_sets = GetItemSets(t_items_tracks, t_different_tracks)
    t_rest_tracks = RenderSetsOfItems(t_set_items, t_sets )
  else
    t_rest_tracks = RenderEveryItemToTrack(t_items_tracks)
  end

  reaper.UpdateArrange()
  
  reaper.Main_OnCommand(40297, 0) -- unselect all tracks
  for i=1, #t_rest_tracks do
    reaper.SetTrackSelected(t_rest_tracks[i], true)
  end
  reaper.Main_OnCommand(40421, 0) -- select all items in tracks
  
  reaper.GetSet_LoopTimeRange( true, false, save_start_ts, save_end_ts, false )
  reaper.SetEditCurPos(save_cur_pos, false, false)
  
  if change_setting == true then
    reaper.SNM_SetIntConfigVar('workrender',render_ts)
  end
  
  reaper.Undo_EndBlock('Bounce selection (like in Studio One)', -1)