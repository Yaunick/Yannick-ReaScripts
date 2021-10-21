-- @description Yannick_Create send track or create sends from selected track to existed track
-- @author Yannick
-- @version 1.0
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   Initial release
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU

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
    --- change old values in "User input default values" setting section after re-running the script
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
  ------------------------------------------------------------------------------

  ----Where will be the new send track, if no existed?--------------------------
    where_track = 1           ---- 1 - start, 2 - end of all tracks
                              ---- 3 - start, 4 - end of selected tracks
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
  or (where_track ~= 1 and where_track ~= 2 and where_track ~= 3 and where_track ~= 4)
  or (not tonumber(R) or not tonumber(G) or not tonumber(B))
  or (R < 0 or G < 0 or B < 0)
  then
    reaper.MB
    (
    'Incorrect values for "send_volume" or "input_width" or ' ..
    '"add_reacomp_for_sidechain" or "show_reacomp" or "threshold" or "ratio" or "show_in_tcp" or "where track" or "RGB" parameters. ' .. 
    'Look at the beginning of the script',
    'Error',0
    )
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

  local values_for_script = send_track_name
  ..","..source_send
  ..","..destination_send
  ..","..master_send
  ..","..send_mode

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
      if send_track_name == t_val[1]
      and source_send == t_val[2]
      and destination_send == t_val[3]
      and master_send == t_val[4]
      and send_mode == t_val[5]
      then 
        nothing()
      else
    
        _,inputFile,_,_,_,_,_ = reaper.get_action_context()
        
        local file = io.open(inputFile, 'r')
        local fileContent = {}
        local numb_find_1, numb_find_2, numb_find_3, numb_find_4, numb_find_5 = 0,0,0,0,0
        local bool_find_line_1, bool_find_line_2, bool_find_line_3, 
        bool_find_line_4, bool_find_line_5 = false, false, false, false, false
        local counter_lines = 0
        
        for line in file:lines() do
          counter_lines = counter_lines + 1
          table.insert (fileContent, line)
          if string.find(line, "send_track_name") and bool_find_line_1 == false then
            numb_find_1 = counter_lines
            bool_find_line_1 = true
          elseif string.find(line, "source_send") and bool_find_line_2 == false then
            numb_find_2 = counter_lines
            bool_find_line_2 = true
          elseif string.find(line, "destination_send") and bool_find_line_3 == false then
            numb_find_3 = counter_lines
            bool_find_line_3 = true
          elseif string.find(line, "master_send") and bool_find_line_4 == false then
            numb_find_4 = counter_lines
            bool_find_line_4 = true
          elseif string.find(line, "send_mode") and bool_find_line_5 == false then
            numb_find_5 = counter_lines
            bool_find_line_5 = true
          end
        end
        io.close(file)
        
        fileContent[numb_find_1] = "    send_track_name = " .. "'" .. t_val[1] .. "'" .. 
        '    ---- "Set the send track name"'
        fileContent[numb_find_2] = "    source_send = " .. "'" .. t_val[2] .. "'" .. 
        '    ---- "Set source send (x or x/y)"'
        fileContent[numb_find_3] = "    destination_send = " .. "'" .. t_val[3] .. "'" .. 
        '    ---- "Set destination send (x or x/y)"'
        fileContent[numb_find_4] = "    master_send = " .. "'" .. t_val[4] .. "'" ..
        '    ---- "Master send on source tracks" --- Set 1 for enable or 0 for disable master send'
        fileContent[numb_find_5] = "    send_mode = " .. "'" .. t_val[5] .. "'" ..
        '    ---- "Post-fd (0) pre-fx (1) post-fx (3)"'
        
        file = io.open(inputFile, 'w')
        for index, value in ipairs(fileContent) do
            file:write(value..'\n')
        end
        io.close(file)
        
      end
    end

    local found_tr = false
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

    if found_tr == true then
      if reaper.IsTrackSelected(save_tr) == true then
        reaper.MB('The send track has already been selected, take a closer look :)','Error',0)
        nothing() return
      end
    elseif found_tr == false then
      if where_track == 1 then
        reaper.InsertTrackAtIndex(0,false)
        save_tr = reaper.GetTrack(0,0)
      elseif where_track == 3 then
        local numb_frst_tr = reaper.GetMediaTrackInfo_Value(reaper.GetSelectedTrack(0,0),'IP_TRACKNUMBER')
        reaper.InsertTrackAtIndex(numb_frst_tr-1,false)
        save_tr = reaper.GetTrack(0,numb_frst_tr-1)      
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

    reaper.Undo_EndBlock('Create send track or create sends from selected track to existed track',-1)
    reaper.PreventUIRefresh(-1)
  else nothing() return end