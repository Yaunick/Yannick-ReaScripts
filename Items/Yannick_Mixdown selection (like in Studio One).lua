-- @description Yannick_Mixdown selection (like in Studio One)
-- @author Yannick
-- @version 1.1
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   + Fixed logic with receives in source tracks
--   + Remove "Auto_unsolo_all_tracks_before_render" and "Auto_unmute_all_tracks_before_render" settings, because now they doesn't work correctly :(
--   + Added "Mute_original_items" setting
--   + Added "Name_for_new_track" setting
--   + Now only the one item is selected on the new mixdown track
--   + Some code improvements
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU
  
  ----Set some parameters-------------------------------------------------------
    Name_for_new_track = 'Mixdown'
    Tail_for_new_track = 4  --Sec
    user_input_for_entering_tail = false
    Solo_for_new_track = false
    Mute_original_items = true
    Insert_new_track_at_end_of_all_tracks = false
  ------------------------------------------------------------------------------
  
  ----Color for new send track, if no existed-----------------------------------
    ---enter 0 for R and G and B to disable coloring---
    R = 0
    G = 0
    B = 0
  ------------------------------------------------------------------------------
  
  function bla() end
  function nothing()
    reaper.defer(bla)
  end
  
  if Name_for_new_track ~= tostring(Name_for_new_track)
  or (Solo_for_new_track ~= false and Solo_for_new_track ~= true)
  or (Mute_original_items ~= false and Mute_original_items ~= true)
  or (Insert_new_track_at_end_of_all_tracks ~= false and Insert_new_track_at_end_of_all_tracks ~= true)
  or Tail_for_new_track ~= tonumber(Tail_for_new_track) 
  or (user_input_for_entering_tail ~= false and user_input_for_entering_tail ~= true)
  or (not tonumber(R) or not tonumber(G) or not tonumber(B))
  or (R < 0 or G < 0 or B < 0)
  then
    reaper.MB('Incorrect values at the beginning of the script', 'Error',0) 
    nothing() return 
  end
  
  local test_SWS = reaper.CF_EnumerateActions
  if not test_SWS then
    reaper.MB('Please install or update SWS extension', 'Error', 0) nothing() return
  end
    
  if reaper.CountSelectedMediaItems(0) == 0 then reaper.MB('No items. Please select an item', 'Error', 0) nothing() return end
  
  if user_input_for_entering_tail == true then
    ::START_INPUT::
    local retval, retvals_csv = reaper.GetUserInputs
    (
    'Mixdown selection (like in Studio One)', 
    1, 
    'Set tail for item:', 
    Tail_for_new_track
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
    Tail_for_new_track = tonumber(t_values[1])
  end
  
    ---Save selected items and unselect muted selected items-------
    local t = {}
    local t_rest_m_i = {}
    reaper.PreventUIRefresh(1)
    for i=reaper.CountSelectedMediaItems(0)-1,0,-1 do
      local item = reaper.GetSelectedMediaItem(0,i)
      if item then
        t[#t+1] = item
        if reaper.GetMediaItemInfo_Value(item,'B_MUTE') == 1 then
          t_rest_m_i[#t_rest_m_i+1] = item
          reaper.SetMediaItemSelected(item,false)
        end
      end     
    end
    reaper.PreventUIRefresh(-1)
    ---------------------------------------------------------------
    
    ---Check unmuted items----------------------------------------------------------------------
    if reaper.CountSelectedMediaItems(0) == 0 then
      reaper.MB('No unmuted items. Please select an unmuted item', 'Error', 0) 
      reaper.PreventUIRefresh(1)
      for i=1, #t_rest_m_i do
        reaper.SetMediaItemSelected(t_rest_m_i[i],true)
      end
      reaper.PreventUIRefresh(-1)
      nothing() return 
    end
    --------------------------------------------------------------------------------------------
    
    reaper.Undo_BeginBlock()
    reaper.PreventUIRefresh(1)
    
    --Get tracks from sel items-------------------------------------
    local t_s_tr = {}
    for i=0, reaper.CountSelectedMediaItems(0)-1 do
      local item_1 = reaper.GetSelectedMediaItem(0,i)
      local track_item_1 = reaper.GetMediaItemTrack(item_1)
      local item_2 = reaper.GetSelectedMediaItem(0,i+1)
      if item_2 then
        local track_item_2 = reaper.GetMediaItemTrack(item_2)
        if track_item_1 ~= track_item_2 then
          t_s_tr[#t_s_tr+1] = track_item_1
        end
      else
        t_s_tr[#t_s_tr+1] = track_item_1
      end
    end
    ----------------------------------------------------------------
    
    ---Save track selecton-----------------------------
    local tr_tab = {}
    if reaper.CountSelectedTracks(0) > 0 then
      for i=0, reaper.CountSelectedTracks(0)-1 do
        tr_tab[i+1] = reaper.GetSelectedTrack(0,i)
      end
    end
    ---------------------------------------------------
    
    render_ts = reaper.SNM_GetIntConfigVar('workrender',0)
    change_setting = false
    if render_ts&8192 == 8192 then
      local render_ts2 = render_ts&~(render_ts&8192)
      reaper.SNM_SetIntConfigVar('workrender',render_ts2)
      change_setting = true
    end
  
    ----Save TS and cursor positions---------------------------------------------------
    local cur_pos = reaper.GetCursorPosition()
    local save_start, save_end = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
    -----------------------------------------------------------------------------------
    
    reaper.Main_OnCommand(40290,0) --set TS to items
    ----Set TS to items + Tail--------------------------------------------------------
    local new_start, new_end = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
    reaper.GetSet_LoopTimeRange(true, false, new_start, new_end+Tail_for_new_track, false)
    ----------------------------------------------------------------------------------
    
    local count_mute = {}
    reaper.Main_OnCommand(40340,0) -- unsolo all tracks
    
    for d=1, #t_s_tr do
      reaper.SetMediaTrackInfo_Value(t_s_tr[d], 'I_SOLO', 2)
      for i=0, reaper.CountTrackMediaItems(t_s_tr[d])-1 do
        local item = reaper.GetTrackMediaItem(t_s_tr[d],i)
        if reaper.GetMediaItemInfo_Value(item, 'D_POSITION') >= new_start 
        and reaper.GetMediaItemInfo_Value(item, 'D_POSITION') <= new_end + Tail_for_new_track + 1
        then
          count_mute[#count_mute+1] = { item, reaper.GetMediaItemInfo_Value(item, 'B_MUTE') }
          if reaper.IsMediaItemSelected(item) == false then
            reaper.SetMediaItemInfo_Value(item, 'B_MUTE', 1)
          end
        end
      end
    end
  
    reaper.InsertTrackAtIndex(0, false) --insert track for render
    reaper.SetMediaTrackInfo_Value(reaper.GetTrack(0,0), 'I_FOLDERDEPTH', 1) --set folder state for track for render
    reaper.SetOnlyTrackSelected(reaper.GetTrack(0,0), true) --select global folder track only
      
    local count_tr_br = reaper.CountTracks(0) --count tracks before render
    
    ----Render----------------------------------------------------
    reaper.Main_OnCommand(41719,0) --render stereo (selected area)
    --------------------------------------------------------------
    
    local count_tr_ar = reaper.CountTracks(0) --count tracks after render
    
    for i=1, #count_mute do
      reaper.SetMediaItemInfo_Value(count_mute[i][1], 'B_MUTE', count_mute[i][2])
    end
    
    reaper.Main_OnCommand(40340,0) -- unsolo all tracks
    
    if count_tr_br < count_tr_ar then -- if render is not canceled
      reaper.DeleteTrack(reaper.GetTrack(0,1)) -- delete folder track
      local sel_tr = reaper.GetSelectedTrack(0,0)
      reaper.GetSetMediaTrackInfo_String(sel_tr, 'P_NAME', Name_for_new_track, true) -- named new track
      if R == 0 and G == 0 and B == 0 then
        nothing()
      else
        color = reaper.ColorToNative(R,G,B)|0x1000000
        reaper.SetTrackColor(sel_tr,color)
      end
      if Solo_for_new_track == true then
        reaper.SetMediaTrackInfo_Value(sel_tr, 'I_SOLO', 2)
      end
      if Mute_original_items == true then
        for i=1, #t do
          reaper.SetMediaItemInfo_Value(t[i], 'B_MUTE', 1)
        end
      end
      reaper.Main_OnCommand(40289,0) -- unselect all items
      reaper.SetMediaItemSelected(reaper.GetTrackMediaItem(reaper.GetSelectedTrack(0,0),0), true)
      if Insert_new_track_at_end_of_all_tracks == true then
        reaper.ReorderSelectedTracks(count_tr_ar,0)
        reaper.Main_OnCommand(reaper.NamedCommandLookup("_XENAKIOS_TVPAGEEND"),0)
      else
        reaper.Main_OnCommand(reaper.NamedCommandLookup("_XENAKIOS_TVPAGEHOME"),0)
      end
    elseif count_tr_br == count_tr_ar then --if render is canceled
      reaper.DeleteTrack(reaper.GetTrack(0,0)) --delete folder track
      ---Restore selection of tracks------------
      if tr_tab ~= {} then 
        for i=1, #tr_tab do
          reaper.SetTrackSelected(tr_tab[i], true)
        end
      end
      ------------------------------------------
      for i=1, #t_rest_m_i do
        reaper.SetMediaItemSelected(t_rest_m_i[i],true)
      end
    end

    ---Restore TS and cursor positions-----------------------------------
    reaper.GetSet_LoopTimeRange(true, false, save_start, save_end, false)
    reaper.SetEditCurPos(cur_pos, false, false)
    ---------------------------------------------------------------------
    
    if change_setting == true then
      reaper.SNM_SetIntConfigVar('workrender',render_ts)
    end
    
  reaper.UpdateArrange()
  reaper.Undo_EndBlock('Mixdown items selection', -1)
  reaper.PreventUIRefresh(-1)