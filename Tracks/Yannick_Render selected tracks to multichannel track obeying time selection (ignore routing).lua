-- @description Yannick_Render selected tracks to multichannel track obeying time selection (ignore routing)
-- @author Yannick
-- @version 1.1
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   + improved work with different settings in Prefs
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU

  --////////---\\\\\\\---////////---\\\\\\\\---///////---\\\\\\\-- 
  
      ----------------enter some parameters----------------
      
        adjusting_the_render_bounds = 1
        -- 0 = ignore loop points and time selection
        -- 1 = ignore only loop points (like default)
        -- 2 = ignore only time selection
        mute_original_tracks = true
        name_for_new_track = 'stem'  ---enter the name
            
      -----------------------------------------------------
      
      ----------------Color for new track------------------
      ----enter 0 for R and G and B to disable coloring----
      
        R = 0   ----Red
        G = 0   ----Green
        B = 0   ----Blue
        
      -----------------------------------------------------
      -----------------------------------------------------
        
  --////////---\\\\\\\---////////---\\\\\\\\---///////---\\\\\\\--    
  
  
  function bla() end function nothing() reaper.defer(bla) end
  
  if (adjusting_the_render_bounds ~= 0 and adjusting_the_render_bounds ~= 1 and adjusting_the_render_bounds ~= 2)
  or (mute_original_tracks ~= true and mute_original_tracks ~= false)
  or name_for_new_track ~= tostring(name_for_new_track)
  or (not tonumber(R) or not tonumber(G) or not tonumber(B))
  or (R < 0 or G < 0 or B < 0)
  then
    reaper.MB('Incorrect value for "adjusting_the_render_bounds" ' ..
    'or "mute_original_tracks" or "name_for_new_track" or "RGB" parameters. Look at the beginning of the script',
    'Error',0)
    nothing() return
  end
  
  local test_SWS = reaper.CF_EnumerateActions
  if not test_SWS then
    reaper.MB('Please install or update SWS extension', 'Error', 0) nothing() return
  end

  ---Test---How many selected tracks?---------------------------------------------------
  local count_sel_tracks = reaper.CountSelectedTracks(0)
  if count_sel_tracks == 0 then
    reaper.MB('No tracks. Please select tracks', 'Error', 0) nothing() return
  elseif count_sel_tracks > 16 then
    reaper.MB('More than 16 tracks are not supported :(', 'Error', 0) nothing() return
  end
  --------------------------------------------------------------------------------------

  ---Create userinput default values----------------------------------
  local num_inputs = string.rep('1,',count_sel_tracks)
  num_inputs = string.sub(num_inputs, 0, string.len(num_inputs)-1)
  --------------------------------------------------------------------

  local t = {}

  ---Get selected tracks count and tracks names for userinput and contraction the track name, if it's long---
  for i=0, count_sel_tracks-1 do
    local track_for_name = reaper.GetSelectedTrack(0,i)
    local _, name_of_sel_track = reaper.GetSetMediaTrackInfo_String( track_for_name, 'P_NAME', 0, false)
    string_track_length = string.len(name_of_sel_track)
    if string_track_length > 16 then
      name_of_sel_track = string.sub(name_of_sel_track, 0, 8) ..
      '...'..string.sub(name_of_sel_track, string_track_length-6, string_track_length)
    elseif string_track_length == 0 then
      name_of_sel_track = "Track untitled "..i+1 ---Named track, even if no name
    end
    if i < count_sel_tracks-1 then
      table.insert(t,'"' .. name_of_sel_track .. '":,')
    else 
      table.insert(t,'"' .. name_of_sel_track .. '":')
    end
  end
  -----------------------------------------------------------------------------------------------------------

  local inputs_names = table.concat(t) ---String from tracks and tracks names table

  ::START::
  ---User input for entering values----------------------------------------------------------------------------
  local retval, retvals_csv =
  reaper.GetUserInputs('Create multichannel track from sel tracks', count_sel_tracks, inputs_names .. ',extrawidth=25', num_inputs)
  -------------------------------------------------------------------------------------------------------------

  if retval then
     
    function Round_To_Integer(x, n)
      n = n or 1
      return math.floor(x / n + 0.5) * n
    end

    local t_val = {}
   
    ---Test---"You can only enter an integer"-------------------------------------------------------
    for s in string.gmatch(retvals_csv, "[^,]*") do
      if not tonumber(s) or Round_To_Integer(tonumber(s), 1) ~= tonumber(s) or tonumber(s) <= 0 then
        reaper.MB('You can only enter an integer', 'Error', 0)
        goto START
      end
      table.insert(t_val,tonumber(s))
    end
    ------------------------------------------------------------------------------------------------

    ---Get table count of new values--------
    local count_table = 0
    for i=1, #t_val do
      count_table = count_table + t_val[i]
    end
    ----------------------------------------
   
    ---Test---"You cannot enter not an integer and cannot do more than 64 channels on one track"----
    if #t_val ~= count_sel_tracks then
      reaper.MB('You can only enter an integer', 'Error', 0)
      goto START
    elseif count_table > 64 then
      reaper.MB('You cannot do more than 64 channels on one track :(', 'Error', 0)
      goto START
    end
    ------------------------------------------------------------------------------------------------
   
    reaper.Undo_BeginBlock()
    reaper.PreventUIRefresh(1)
   
    ---Round odd number to event number (up)-------------
    function Round_To_Even(number_round)
      if (number_round % 2 ~= 0) then
        number_round = number_round+1 ---odd integer + 1
      end
      return number_round
    end
    -----------------------------------------------------

    ---Insert track for render at top of selected tracks and set track channel count from table------------
    local tra = reaper.GetSelectedTrack(0,0)
    local number_tra = reaper.GetMediaTrackInfo_Value(tra,'IP_TRACKNUMBER')
    reaper.InsertTrackAtIndex(number_tra-1,false)
    reaper.SetMediaTrackInfo_Value(reaper.GetTrack(0,number_tra-1), "I_NCHAN", Round_To_Even(count_table))
    -------------------------------------------------------------------------------------------------------

    local t_tracks = {}
    local new_table_sends = {}
    local num_src_send = 0 ---unit for source sends cycle
    local num_dst_send = 0 ---unit for destination sends cycle
    for i=1, count_sel_tracks do
      t_tracks[i] = reaper.GetSelectedTrack(0,i-1) ---save tracks selection
      local get_track = reaper.GetSelectedTrack(0,i-1)
      reaper.SetMediaTrackInfo_Value(get_track, "I_NCHAN", Round_To_Even(t_val[i])) ---set channel count for track if multichannel source
      ---Insert sends for selected track (count sends from table)----------
      for h=1, t_val[i] do
        new_table_sends[#new_table_sends+1] = reaper.CreateTrackSend(get_track, reaper.GetTrack(0,number_tra-1))
      end
      ---------------------------------------------------------------------
      for j=1, #new_table_sends do
        reaper.SetTrackSendInfo_Value(get_track, 0, new_table_sends[j], 'I_SRCCHAN', 1024+num_src_send) ---set source send channel
        reaper.SetTrackSendInfo_Value(get_track, 0, new_table_sends[j], 'I_DSTCHAN', 1024+num_src_send+num_dst_send) ---set dest send channel
        reaper.SetTrackSendInfo_Value(get_track, 0, new_table_sends[j], 'D_VOL', 1)  ---set send vol
        reaper.SetTrackSendInfo_Value(get_track, 0, new_table_sends[j], 'I_SENDMODE', 0)  ---send mode post fader
        reaper.BR_GetSetTrackSendInfo(get_track, 0, new_table_sends[j], 'I_MIDI_SRCCHAN', true, -1) ---disable default midi send
        num_src_send = num_src_send + 1
      end
      new_table_sends = {}
      num_dst_send = num_dst_send + t_val[i]
      num_src_send = 0
    end
    
    restore = 1
    if adjusting_the_render_bounds == 2 then
       start_point, end_point = reaper.GetSet_LoopTimeRange2(0, false, true, 0, 0, false)
       if end_point - start_point > 0 then
         save_ts_start, save_ts_end = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
         reaper.GetSet_LoopTimeRange2(0, true, false, start_point, end_point, false)
         restore = 2
       end
    elseif adjusting_the_render_bounds == 0 then
      save_ts_start, save_ts_end = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
      reaper.Main_OnCommand(40635,0) --remove time selection
      restore = 0
    end

    reaper.SetOnlyTrackSelected(reaper.GetTrack(0,number_tra-1),true) ---select only global folder track for render

    local count_tr_br = reaper.CountTracks(0) ---count tracks before render
    reaper.Main_OnCommand(41720, 0) -- Render multichannel
    local count_tr_ar = reaper.CountTracks(0) ---count tracks after render

    if count_tr_ar > count_tr_br then ---if render is not canceled
      reaper.DeleteTrack(reaper.GetTrack(0,number_tra))
      if mute_original_tracks == true then
        for i=1, #t_tracks do
          reaper.SetMediaTrackInfo_Value(t_tracks[i],'B_MUTE',1) ---set source tracks mute
        end
      end
    elseif count_tr_br == count_tr_ar then ---if render is canceled
      reaper.DeleteTrack(reaper.GetTrack(0,number_tra-1))
      for i=1, #t_tracks do
        reaper.SetTrackSelected(t_tracks[i],true) ---restore source tracks selection
      end
    end
    
    set_new_track = reaper.GetSelectedTrack(0,0)
    reaper.GetSetMediaTrackInfo_String(set_new_track, 'P_NAME', name_for_new_track, true)
    
    if R == 0 and G == 0 and B == 0 then
      nothing()
    else
      reaper.SetTrackColor(set_new_track, reaper.ColorToNative(R,G,B)|0x1000000)
    end
    
    if restore == 2 or restore == 0 then
      reaper.GetSet_LoopTimeRange2(0, true, false, save_ts_start, save_ts_end, false)
    end
   
    reaper.Undo_EndBlock('Render selected tracks to multichannel track obeying time selection (ignore routing)',-1)
    reaper.PreventUIRefresh(-1)
     
  else nothing() return end ---end script if cancel in user input