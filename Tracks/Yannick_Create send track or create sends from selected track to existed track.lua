-- @description Yannick_Create send track or create sends from selected track to existed track
-- @author Yannick
-- @version 1.8
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   # changed donation link
--   # contact link changed
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14

  --/////////////----USER--INPUTS----\\\\\\\\\----CUSTOMIZE--THIS----//////////////

  ----User input default values-------------------------------------------------
    send_track_name = 'BUS'    ---- "Set the send track name"
    source_send = '1/2'    ---- "Set source send (x or x/y)"
    destination_send = '1/2'    ---- "Set destination send (x or x/y)"
    master_send = '0'    ---- "Master send on source tracks" --- Set 1 for enable or 0 for disable master send
    send_mode = '0'    ---- "Post-fd (0) pre-fx (1) post-fx (3)"
  ------------------------------------------------------------------------------
  
  ------------------------------------------------------------------------------
    save_new_values_after_re_running_script = true
    --- save new values in .rpp project file
  ------------------------------------------------------------------------------
  
  ------------------------------------------------------------------------------
    send_volume = 0      ---- Set the send volume for source tracks
  ------------------------------------------------------------------------------
  
  ---Reacomp to send track------------------------------------------------------
    add_reacomp_for_sidechain = false
      show_reacomp = true
      threshold = -20 --dB
      ratio = 0.06
  ------------------------------------------------------------------------------
  
    input_width = 10

  ----Color for new send track, if no existed-----------------------------------
    ---enter 0 for R and G and B to disable coloring---
    R = 0
    G = 0
    B = 0
  ------------------------------------------------------------------------------

  ----Other parameters for new send track, if no existed------------------------
    show_in_tcp = true        ---- Show new send track in TCP --- true or false
    set_height = 0            ---- 0 to disable, any number for height size (in pixels)
  ------------------------------------------------------------------------------

  ----Where will be the new send track, if no existed?--------------------------
    where_track = 1           ---- 1 - start, 2 - end of all tracks
                              ---- 3 - start, 4 - end of selected tracks
                              ---- 5 - experimental - new folder from selected tracks (or reorder selected tracks to existing folder)
  ------------------------------------------------------------------------------
  
  ----Other parameters for send track-------------------------------------------
    always_create_a_new_send_track = false
    select_send_track = false
      show_fx_browser_for_selected_send_track = true
  ------------------------------------------------------------------------------

  --\\\\\\\\\\\\----RUN--RUN--RUN----/////////----START--SCRIPT------\\\\\\\\\\\\\\

  function bla() end function nothing() reaper.defer(bla) end

  if not tonumber(input_width)
  or input_width < 0
  or not tonumber(send_volume)
  or (add_reacomp_for_sidechain ~= true and add_reacomp_for_sidechain ~= false)
  or (show_reacomp ~= true and show_reacomp ~= false)
  or not tonumber(threshold)
  or not tonumber(ratio)
  or (show_in_tcp ~= true and show_in_tcp ~= false)
  or (where_track ~= 1 and where_track ~= 2 and where_track ~= 3 and where_track ~= 4 and where_track ~= 5)
  or (not tonumber(R) or not tonumber(G) or not tonumber(B))
  or (R < 0 or G < 0 or B < 0)
  or (always_create_a_new_send_track ~= true and always_create_a_new_send_track ~= false)
  or (select_send_track ~= true and select_send_track ~= false)
  or (show_fx_browser_for_selected_send_track ~= true and show_fx_browser_for_selected_send_track ~= false)
  or (not tonumber(set_height) or set_height < 0)
  then
    reaper.MB('Incorrect values at the beginnig of the script','Error',0)
    nothing() return
  end

  local test_SWS = reaper.CF_EnumerateActions
  if not test_SWS then
    reaper.MB('Please install or update SWS extension', 'Error', 0) nothing() return
  end

  count_sel_tracks = reaper.CountSelectedTracks(0)
  if count_sel_tracks == 0 then reaper.MB('No tracks. Please select a track', 'Error', 0) nothing() return end

  function bool_for_settings(bl)
    if bl == true then
      bl = 1
    elseif bl == false then
      bl = 0
    end
    return bl
  end

  show_in_tcp = bool_for_settings(show_in_tcp)
  
  local retval_ext_st, val_ext_state = reaper.GetProjExtState(0, "Send_values_yannick_reasc", "yanni_values")
  if retval_ext_st == 1 and save_new_values_after_re_running_script == true then
    values_for_script = val_ext_state
  else
    values_for_script = send_track_name
    ..","..source_send
    ..","..destination_send
    ..","..master_send
    ..","..send_mode
  end

  ::START::
  local retval, retvals_csv = reaper.GetUserInputs
  (
  'Create sends to track from sel. tracks', 5,
  ------------Strings in inputs------------
  [=[Set the send tracks name:                      
  ,Set source send (x or x/y):
  ,Set destination send (x or x/y):
  ,Master send on source tracks:
  ,Post-fd (0) pre-fx (1) post-fx (3):]=] ..
  ',extrawidth=' .. input_width,
  -----------------------------------------
  values_for_script
  )

  if retval then
    reaper.Undo_BeginBlock()
    reaper.PreventUIRefresh(1)

    local t_val = {}
    for s in string.gmatch(retvals_csv, "[^,]+") do
      table.insert(t_val,s)
    end
    
    if #t_val ~= 5 then
      reaper.MB('Incorrect value or no value. Please enter a valid value for any line','Error',0)
      goto START
    end
    
    if t_val[1]:find("'") then
      reaper.MB("Please enter the track name without quotes ( '' )", "Error", 0)
      goto START
    end
    
    if t_val[1]:find('"') then
      reaper.MB('Please enter the track name without quotes ( "" )', "Error", 0)
      goto START
    end
    
    if t_val[1]:find("\\") then
      reaper.MB("Please enter the track name without backslashes ( \\ )", "Error", 0)
      goto START
    end
   
    local val_name, val_src_send, val_dst_send, val_main_send, val_mode =
    t_val[1], t_val[2], t_val[3], t_val[4], t_val[5]
   
    val_main_send_tnbr = tonumber(val_main_send)
    val_mode_tnbr = tonumber(val_mode)

    if (
    val_main_send ~= string.match(val_main_send,'%d')
    or (val_main_send_tnbr ~= 1 and val_main_send_tnbr ~= 0)
    )
    or (
    val_mode ~= string.match(val_mode,'%d')
    or (val_mode_tnbr ~= 0 and val_mode_tnbr ~= 1 and val_mode_tnbr ~= 2 and val_mode_tnbr ~= 3)
    )
    then
      reaper.MB('Incorrect value. Please enter a valid value for master send or send mode','Error',0)
      goto START
    end

    function Round_To_Even(number_round)
      if (number_round % 2 ~= 0) then
        number_round = number_round+1
      end
      return number_round
    end

    function convert_string_to_send_number_or_channels(value)
      if value == string.match(value,"%d+/%d+")
      or value == string.match(value,"%d+")
      then
        num_string = string.match(value,"%d+")
        local def_num = tonumber(num_string)
        if value == def_num .. '/' .. def_num+1
        and (def_num > 0 and def_num < 64)
        then
          value = def_num-1
          value2 = def_num+1
        elseif value == num_string
        and (def_num > 0 and def_num <= 64)
        then
          value = def_num-1|1024
          value2 = def_num
        else
          value = false
          value2 = nil
        end
      else
        value = false
        value2 = nil
      end
      return value, value2
    end

    val_src_send, val_src_2 = convert_string_to_send_number_or_channels(val_src_send)
    val_dst_send, val_dst_2 = convert_string_to_send_number_or_channels(val_dst_send)
    if val_src_send == false or val_dst_send == false then
      reaper.MB('Incorrect value. Please enter a valid value for source or destination sends','Error',0) goto START
    end
    
    if save_new_values_after_re_running_script == true then
      reaper.SetProjExtState(0, "Send_values_yannick_reasc", "yanni_values", 
        t_val[1] .. ',' .. 
        t_val[2] .. ',' .. 
        t_val[3] .. ',' .. 
        t_val[4] .. ',' .. 
        t_val[5]
        )
    end

    local found_tr = false
    if always_create_a_new_send_track == false then
      for i=0, reaper.CountTracks(0)-1 do
        local get_tr = reaper.GetTrack(0,i)
        retval, buf = reaper.GetTrackName(get_tr)
        if buf == val_name then
          if found_tr == false then
            save_tr = get_tr
            found_tr = true
          else
            reaper.MB('You have several tracks with this name','Error',0)
            nothing() return
          end
        end
      end
    end

    if found_tr == true then
      if reaper.IsTrackSelected(save_tr) == true then
        reaper.MB('The send track has already been selected, take a closer look :)','Error',0)
        nothing() return
      end
      if where_track == 5 then
        local numb_frst_tr = reaper.GetMediaTrackInfo_Value(save_tr,'IP_TRACKNUMBER')
        local find_fold_t = false
        if reaper.GetMediaTrackInfo_Value(save_tr,'I_FOLDERDEPTH') == 1 then
          for i = numb_frst_tr-1, reaper.CountTracks(0)-1 do
            local track = reaper.GetTrack(0,i)
            if track == reaper.GetSelectedTrack(0,0) then
              find_fold_t = true
            end
            if reaper.GetMediaTrackInfo_Value(track,'I_FOLDERDEPTH') <= -1 then
              break
            end
          end
        end
        if find_fold_t == false then
          reaper.ReorderSelectedTracks(numb_frst_tr,1)
        end
      end
    elseif found_tr == false then
      if where_track == 1 then
        reaper.InsertTrackAtIndex(0,false)
        save_tr = reaper.GetTrack(0,0)
      elseif where_track == 3 then
        local numb_frst_tr = reaper.GetMediaTrackInfo_Value(reaper.GetSelectedTrack(0,0),'IP_TRACKNUMBER')
        reaper.InsertTrackAtIndex(numb_frst_tr-1,false)
        save_tr = reaper.GetTrack(0,numb_frst_tr-1)      
      elseif where_track == 5 then
        local numb_frst_tr = reaper.GetMediaTrackInfo_Value(reaper.GetSelectedTrack(0,0),'IP_TRACKNUMBER')
        reaper.InsertTrackAtIndex(numb_frst_tr-1,false)
        save_tr = reaper.GetTrack(0,numb_frst_tr-1)    
        reaper.ReorderSelectedTracks(numb_frst_tr,1)
      else
        local t_sel_tracks = {}
        for i=1, count_sel_tracks do
          t_sel_tracks[i] = reaper.GetSelectedTrack(0,i-1)
        end
        local function Insert_and_Reorder_tracks(indx,n)
          reaper.InsertTrackAtIndex(indx,false)
          track = reaper.GetTrack(0,indx)
          reaper.SetOnlyTrackSelected(track, true)
          reaper.ReorderSelectedTracks(indx,n)
          return track
        end
        if where_track == 2 then
          save_tr = Insert_and_Reorder_tracks(reaper.CountTracks(0), 0)
        elseif where_track == 4 then
          local numb_last_tr = reaper.GetMediaTrackInfo_Value(reaper.GetSelectedTrack(0,count_sel_tracks-1),'IP_TRACKNUMBER')
          save_tr = Insert_and_Reorder_tracks(numb_last_tr, 2)
        end  
        reaper.Main_OnCommand(40297,0) --unselect all tracks
        for i=1, #t_sel_tracks do
          reaper.SetTrackSelected(t_sel_tracks[i], true)
        end
      end
      if R == 0 and G == 0 and B == 0 then
        nothing()
      else
        color = reaper.ColorToNative(R,G,B)|0x1000000
        reaper.SetTrackColor(save_tr,color)
      end
      reaper.GetSetMediaTrackInfo_String(save_tr, 'P_NAME', val_name, true)
      reaper.SetMediaTrackInfo_Value(save_tr, 'B_SHOWINTCP', show_in_tcp)
      if set_height > 0 then
        reaper.SetMediaTrackInfo_Value(save_tr, 'I_HEIGHTOVERRIDE', set_height)
      end
    end

    if reaper.GetMediaTrackInfo_Value(save_tr, "I_NCHAN") < val_dst_2 then
      reaper.SetMediaTrackInfo_Value(save_tr, "I_NCHAN", val_dst_2)
    end
   
    if add_reacomp_for_sidechain == true then
      local reacomp = reaper.TrackFX_AddByName(save_tr, 'ReaComp (Cockos)', false, -1)
      local threshold = 10^(0.05*threshold)
      reaper.TrackFX_SetParam(save_tr, reacomp, 0, threshold)
      reaper.TrackFX_SetParam(save_tr, reacomp, 1, ratio)  
      reaper.TrackFX_SetParam(save_tr, reacomp, 8, (1/1084)*2)  
      if show_reacomp == true then
        reaper.TrackFX_Show(save_tr, reacomp, 3)
      end
    end

    for i=0, count_sel_tracks-1 do
      local get_track = reaper.GetSelectedTrack(0,i)
      reaper.SetMediaTrackInfo_Value(get_track, 'B_MAINSEND', val_main_send_tnbr)
      local send_indx = reaper.CreateTrackSend(get_track, save_tr)
      if reaper.GetMediaTrackInfo_Value(get_track, "I_NCHAN") < val_src_2 then
        reaper.SetMediaTrackInfo_Value(get_track, "I_NCHAN", val_src_2)
      end
      reaper.SetTrackSendInfo_Value( get_track, 0, send_indx, 'I_SRCCHAN', val_src_send)
      reaper.SetTrackSendInfo_Value( get_track, 0, send_indx, 'I_DSTCHAN', val_dst_send)
      reaper.SetTrackSendInfo_Value( get_track, 0, send_indx, 'I_SENDMODE', val_mode_tnbr)
      reaper.SetTrackSendInfo_Value( get_track, 0, send_indx, 'D_VOL', 10^(0.05*send_volume))          
      reaper.BR_GetSetTrackSendInfo( get_track, 0, send_indx, 'I_MIDI_SRCCHAN', true, -1)
    end
    
    if select_send_track == true then
      reaper.SetOnlyTrackSelected(save_tr, true)
      if show_fx_browser_for_selected_send_track == true then
        if reaper.GetToggleCommandState(40271) == 0 then
          reaper.Main_OnCommand(40271,0)
        end
      end
    end

    reaper.Undo_EndBlock('Create send track or create sends from selected track to existed track',-1)
    reaper.PreventUIRefresh(-1)
  else nothing() return end