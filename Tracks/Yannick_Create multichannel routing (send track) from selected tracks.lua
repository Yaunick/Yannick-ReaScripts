-- @description Yannick_Create multichannel routing (send track) from selected tracks
-- @author Yannick
-- @version 1.0
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   Initial release
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU

  --///////--\\\\\\--//////--\\\\\\--//////--\\\\\\\--
  
    --Ste some parameters for new track and sends---
      
      first_input_width = 0
      second_input_width = 30
      val_name_for_tr = 'Multichannel'
      val_master_send = 0  ---- 1 = yes, 0 = no
      val_send_mode = 0  ---- "Post-fd (0) pre-fx (1) post-fx (3)"
      insert_default_inputs = 1   --- 0 = no default sends
                                  --- 1 = insert default mono sends by tracks count
                                  --- 2 = insert default stereo sends by tracks count
      
    ------------------------------------------------  
    
    --Set color for new track-----------------------
    ---set 0 for R and G and B to disable coloring--
    
      R = 0    ----Red
      G = 0    ----Green
      B = 0    ----Blue
      
    ------------------------------------------------
    ------------------------------------------------
  
  --///////--\\\\\\--//////--\\\\\\--//////--\\\\\\\--
  
  function bla() end function nothing() reaper.defer(bla) end
  
  if not tonumber(first_input_width)
  or first_input_width < 0
  or not tonumber(second_input_width)
  or second_input_width < 0
  or val_name_for_tr ~= tostring(val_name_for_tr)
  or not tonumber(val_master_send)
  or (val_master_send ~= 0 and val_master_send ~= 2)
  or not tonumber(val_send_mode)
  or (val_send_mode ~= 0 and val_send_mode ~= 1 and val_send_mode ~= 2 and val_send_mode ~= 3) 
  or not tonumber(insert_default_inputs)
  or (insert_default_inputs ~= 0 and insert_default_inputs ~= 1 and insert_default_inputs ~= 2)
  or (not tonumber(R) or not tonumber(G) or not tonumber(B))
  or (R < 0 or G < 0 or B < 0)
  then
    reaper.MB('Incorrect value for "first_input_width" or "second_input_width" or "val_name_for_tr" ' ..
    'or "val_master_send" or "val_send_mode" or "insert_default_inputs" or "RGB" parameters. Look at the beginning of the script',
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

  local t = {}
  local t_string = {}
  local cn = 0
  ---Get selected tracks count and tracks names for userinput and contraction the track name, if it's long---
  for i=0, count_sel_tracks-1 do
    local track_for_name = reaper.GetSelectedTrack(0,i)
    local _, name_of_sel_track = reaper.GetSetMediaTrackInfo_String( track_for_name, 'P_NAME', 0, false)
    string_track_length = string.len(name_of_sel_track)
    if string_track_length > 17 then
      name_of_sel_track = string.sub(name_of_sel_track, 0, 11) .. 
      '...'..string.sub(name_of_sel_track, string_track_length-5, string_track_length)
    elseif string_track_length == 0 then
      name_of_sel_track = "Track untitled "..i+1 ---Named track, even if no name
    end
    table.insert(t,'"' .. name_of_sel_track .. '":,')
    if insert_default_inputs == 1 then  
      table.insert(t_string, 1 .. '-' .. i+1 .. ',')
    elseif insert_default_inputs == 2 then
      table.insert(t_string, 1 .. '/' .. 2 .. '-' .. (i*2)+1 .. '/' .. (i*2)+2 .. ',')
    end
  end
  -----------------------------------------------------------------------------------------------------------'
  
  local inputs_names = table.concat(t)
  if #t_string > 0 then
    local conct_inp = table.concat(t_string)
    num_of_inp = conct_inp:sub(0,conct_inp:len()-1)
  else
    num_of_inp = ''
  end
  
  ::START::
  ---User input for entering values----------------------------------------------------------------------------
  local retval, retvals_csv =
  reaper.GetUserInputs('Create multichannel routing from tracks', 
  count_sel_tracks, inputs_names .. ',extrawidth=' .. first_input_width, num_of_inp)
  -------------------------------------------------------------------------------------------------------------

  if not retval then      
    nothing() return 
  end ---end script if cancel in user input

  t_string = {}
 
  ---Test---"You can only enter an integer"-------------------------------------------------------
  for s in string.gmatch(retvals_csv, "[^,]+") do
    table.insert(t_string,s)
  end
  ------------------------------------------------------------------------------------------------

  ---Test---"You cannot enter not an integer and cannot do more than 64 channels on one track"----
  if #t_string ~= count_sel_tracks then
    reaper.MB('Incorrect value or no value. Please enter a valid value for any line', 'Error', 0)
    goto START
  end
  ------------------------------------------------------------------------------------------------
  
  function Round_To_Even(number_round)
    if (number_round % 2 ~= 0) then
      number_round = number_round+1 ---odd integer + 1
    end
    return number_round
  end

  local bl_result = true
  local t_val_1, t_val_2, conv_tab_1, conv_tab_2 = {}, {}, {}, {}
  for i=1, #t_string do
    local t_number = {}
    if t_string[i] == string.match(t_string[i],'%d+/%d+-%d+/%d+') 
    or t_string[i] == string.match(t_string[i],'%d+/%d+-%d+') then
      for num in string.gmatch(t_string[i], "%d+") do
        table.insert(t_number, tonumber(num))
      end
      local def_num_1, def_num_3 = t_number[1], t_number[3]
      if t_string[i] == def_num_1 .. '/' .. def_num_1+1 .. '-' 
      .. def_num_3 .. '/' .. def_num_3+1 
      and (def_num_1 > 0 and def_num_1 < 64) and (def_num_3 > 0 and def_num_3 < 64) then
        t_val_1[i], conv_tab_1[i] = def_num_1-1, def_num_1+1
        t_val_2[i], conv_tab_2[i] = def_num_3-1, def_num_3+1
      elseif t_string[i] == def_num_1 .. '/' .. def_num_1+1 .. '-' .. def_num_3
      and (def_num_1 > 0 and def_num_1 < 64) and (def_num_3 > 0 and def_num_3 <= 64) then
        t_val_1[i], conv_tab_1[i] = def_num_1-1, def_num_1+1
        t_val_2[i], conv_tab_2[i] = def_num_3+1023, def_num_3
      else
        bl_result = false
        break
      end
    elseif t_string[i] == string.match(t_string[i],'%d+-%d+') 
    or t_string[i] == string.match(t_string[i],'%d+-%d+/%d+') then
      for num in string.gmatch(t_string[i], "%d+") do
        table.insert(t_number, tonumber(num))
      end
      local def_num_1, def_num_2 = t_number[1], t_number[2]
      if t_string[i] == def_num_1 .. '-' .. def_num_2 
      and (def_num_1 > 0 and def_num_1 <= 64) and (def_num_2 > 0 and def_num_2 <= 64) then
        t_val_1[i], conv_tab_1[i] = def_num_1+1023, def_num_1
        t_val_2[i], conv_tab_2[i] = def_num_2+1023, def_num_2
      elseif t_string[i] == def_num_1 .. '-' .. def_num_2 .. '/' .. def_num_2+1
      and (def_num_1 > 0 and def_num_1 <= 64) and (def_num_2 > 0 and def_num_2 < 64) then
        t_val_1[i], conv_tab_1[i] = def_num_1+1023, def_num_1
        t_val_2[i], conv_tab_2[i] = def_num_2-1, def_num_2+1
      else
        bl_result = false
        break
      end
    else
      bl_result = false
      break
    end
  end
  
  if bl_result == false then
    reaper.MB('Incorrect value. Please enter a valid value for any send of track','Error',0) 
    goto START
  end
  
  num_inputs_next =  val_name_for_tr ..
  ',' .. val_master_send .. ',' .. val_send_mode
  
  ::START_2::
  local retval_2, retvals_csv_2 =
   reaper.GetUserInputs('Create multichannel routing from tracks', 
   3, 'Set the send track name:,Set the master send:,Post-fd (0) pre-fx (1) post-fx (3):,extrawidth=' .. second_input_width,
   num_inputs_next)
   
  if not retval_2 then      
    num_of_inp = table.concat(t_string, ',')
    goto START
  end ---end script if cancel in user input 
  
  local t_string_2 = {}
  
  ---Test---"You can only enter an integer"-------------------------------------------------------
  for s in string.gmatch(retvals_csv_2, "[^,]+") do
    table.insert(t_string_2,s)
  end
  ------------------------------------------------------------------------------------------------
  
  if #t_string_2 ~= 3 then
    reaper.MB('Incorrect value or no value. Please enter a valid value for any line', 'Error', 0)
    num_of_inp = table.concat(t_string, ',')
    goto START_2
  end
  
  local name_for_s_tr = t_string_2[1]
  local val_main_s = t_string_2[2]
  local val_send_mode = t_string_2[3]
  local val_main_s_tnbr = tonumber(val_main_s)
  local val_send_mode_tnbr = tonumber(val_send_mode)
  
  if (
  val_main_s ~= string.match(val_main_s,'%d')
  or (val_main_s_tnbr ~= 0 and val_main_s_tnbr ~= 1) 
  )
  or (
  val_send_mode ~= string.match(val_send_mode,'%d')
  or (val_send_mode_tnbr ~= 0 and val_send_mode_tnbr ~= 1 and val_send_mode_tnbr ~= 2 and val_send_mode_tnbr ~= 3)
  )
  then
    reaper.MB('Incorrect value. Please enter a valid value for master send or send mode', 'Error', 0)
    num_of_inp = table.concat(t_string, ',')
    goto START_2
  end
  
  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)


  local found_tr = false
  for i=0, reaper.CountTracks(0)-1 do
    local get_tr = reaper.GetTrack(0,i)
    local retval, buf = reaper.GetTrackName(get_tr)
    if buf == name_for_s_tr then
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
     local tra = reaper.GetSelectedTrack(0,0)
     local number_tra = reaper.GetMediaTrackInfo_Value(tra,'IP_TRACKNUMBER')
     reaper.InsertTrackAtIndex(number_tra-1,true)
     save_tr = reaper.GetTrack(0,number_tra-1)
     reaper.GetSetMediaTrackInfo_String(save_tr,'P_NAME',name_for_s_tr,true)
     reaper.SetMediaTrackInfo_Value(save_tr, 'B_MAINSEND', 1)
     if R == 0 and G == 0 and B == 0 then
       nothing()
     else
       reaper.SetTrackColor(save_tr,reaper.ColorToNative(R,G,B)|0x1000000)
     end
   end
  
  if reaper.GetMediaTrackInfo_Value(save_tr, "I_NCHAN") < Round_To_Even(math.max(table.unpack(conv_tab_2))) 
  then
    reaper.SetMediaTrackInfo_Value(save_tr, "I_NCHAN", Round_To_Even(math.max(table.unpack(conv_tab_2))))
  end

  for i=0, count_sel_tracks-1 do
    local get_track = reaper.GetSelectedTrack(0,i)
    reaper.SetMediaTrackInfo_Value(get_track, 'B_MAINSEND', val_main_s_tnbr)
    local send_indx = reaper.CreateTrackSend(get_track, save_tr)
    if reaper.GetMediaTrackInfo_Value(get_track, "I_NCHAN") < conv_tab_1[i+1] then
      reaper.SetMediaTrackInfo_Value(get_track, "I_NCHAN", conv_tab_1[i+1])
    end
    reaper.SetTrackSendInfo_Value( get_track, 0, send_indx, 'I_SRCCHAN', t_val_1[i+1])
    reaper.SetTrackSendInfo_Value( get_track, 0, send_indx, 'I_DSTCHAN', t_val_2[i+1])
    reaper.SetTrackSendInfo_Value( get_track, 0, send_indx, 'I_SENDMODE', val_send_mode)
    reaper.BR_GetSetTrackSendInfo( get_track, 0, send_indx, 'I_MIDI_SRCCHAN', true, -1)
  end

  reaper.Undo_EndBlock('Create multichannel routing (send track) from selected tracks',-1)
  reaper.PreventUIRefresh(-1)
