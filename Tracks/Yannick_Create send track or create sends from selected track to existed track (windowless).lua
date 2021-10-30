-- @description Yannick_Create send track or create sends from selected track to existed track (windowless)
-- @author Yannick
-- @version 1.1
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   + Added new settings to select send track and open FX browser
--   + Added new setting to set height size for new send track
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU

  --/////////////----USER--INPUTS----\\\\\\\\\----CUSTOMIZE--THIS----//////////////
  
  ----User input default values-------------------------------------------------
    send_track_name = 'BUS'   ---- "Set the send track name"
    source_send = '1/2'       ---- "Set source send (x or x/y)"
    destination_send = '1/2'  ---- "Set destination send (x or x/y)"
    master_send = '0'         ---- "Master send on source tracks" --- Set 1 for enable or 0 for disable master send
    send_mode = '0'           ---- "Post-fd (0) pre-fx (1) post-fx (3)"
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
  
  ----Color for new send track, if no existed-----------------------------------
  ---enter 0 for R and G and B to disable coloring---
    R = 0   ---Red
    G = 0   ---Green
    B = 0   ---Blue
  ------------------------------------------------------------------------------
  
  ----Other parameters for new send track, if no existed------------------------
    show_in_tcp = true        ---- Show new send track in TCP --- true or false
    set_height = 0            ---- 0 to disable, any number for height size (in pixels)
  ------------------------------------------------------------------------------
  
  ----Where will be the new send track, if no existed?--------------------------
    where_track = 1         ---- 1 - start, 2 - end of all tracks
                            ---- 3 - start, 4 - end of selected tracks
  ------------------------------------------------------------------------------
  
  ----Other parameters for send track-------------------------------------------
    select_send_track = false
      show_fx_browser_for_selected_send_track = true
  ------------------------------------------------------------------------------
  
  --\\\\\\\\\\\\----RUN--RUN--RUN----/////////----START--SCRIPT------\\\\\\\\\\\\\\

  function bla() end function nothing() reaper.defer(bla) end
  
  if (show_in_tcp ~= true and show_in_tcp ~= false)
  or (where_track ~= 1 and where_track ~= 2 and where_track ~= 3 and where_track ~= 4) 
  or not tonumber(send_volume)
  or (add_reacomp_for_sidechain ~= true and add_reacomp_for_sidechain ~= false)
  or (show_reacomp ~= true and show_reacomp ~= false)
  or not tonumber(threshold)
  or not tonumber(ratio)
  or (not tonumber(R) or not tonumber(G) or not tonumber(B))
  or (R < 0 or G < 0 or B < 0)
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
  if count_sel_tracks == 0 then 
    reaper.MB('No tracks. Please select a track', 'Error', 0) 
    nothing() return 
  end
  
  function bool_for_settings(bl)
    if bl == true then
      bl = 1
    else
      bl = 0
    end
    return bl
  end
  
  show_in_tcp = bool_for_settings(show_in_tcp)
  
  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)
  
  local val_name, val_src_send, val_dst_send, val_main_send, val_mode =
  send_track_name, source_send, destination_send, master_send, send_mode 
  
  
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
    nothing() return
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
    reaper.MB('Incorrect value. Please enter a valid value for source or destination sends','Error',0) 
    nothing() return
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
      if where_track == 2 then
        reaper.InsertTrackAtIndex(reaper.CountTracks(0),false)
        save_tr = reaper.GetTrack(0,reaper.CountTracks(0)-1)
        reaper.SetOnlyTrackSelected(save_tr, true)
        reaper.ReorderSelectedTracks(reaper.CountTracks(0)-1,0)
      elseif where_track == 4 then
        local numb_frst_tr = reaper.GetMediaTrackInfo_Value(reaper.GetSelectedTrack(0,count_sel_tracks-1),'IP_TRACKNUMBER')
        reaper.InsertTrackAtIndex(numb_frst_tr,false)
        save_tr = reaper.GetTrack(0,numb_frst_tr)
        reaper.SetOnlyTrackSelected(save_tr, true)
        reaper.ReorderSelectedTracks(numb_frst_tr,2)
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

  reaper.Undo_EndBlock('Create send track with sends parameters from selected tracks (windowless)',-1)
  reaper.PreventUIRefresh(-1)