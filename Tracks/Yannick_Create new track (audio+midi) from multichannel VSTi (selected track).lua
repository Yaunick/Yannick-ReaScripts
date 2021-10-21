-- @description Yannick_Create new track (audio+midi) from multichannel VSTi (selected track)
-- @author Yannick
-- @version 1.0
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   Initial release
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU


  --///////////|||\\\\\\\\\\\---Customize this---///////////|||\\\\\\\\\\--
  
  ---some parameters for tracks-----------------------------
  input_width = 30
  number_of_channel_in_names = true
    tracks_postfix = 'ch'
  insert_the_smallest_unused_channel = true
  default_for_new_track = false
  select_the_new_track = false
  ----------------------------------------------------------
  
  ---color for midi track-----------------------------------
   ---enter 0 for R_a and G_a and B_a to disable coloring---
  R = 0     ----Red
  G = 0     ----Green
  B = 0     ----Blue
  ----------------------------------------------------------
  
  --\\\\\\\\\\\|||///////////---//////||\\\\\\---\\\\\\\\\\\|||//////////--
  
  
  --///////////-----------------------------------------------\\\\\\\\\\\--
  --===========---RUN SCRIPT--START START START--RUN SCRIPT---===========--
  --\\\\\\\\\\\-----------------------------------------------///////////--
  
  function bla() end
  function nothing() reaper.defer(bla) end
  
  if not tonumber(input_width)
  or input_width < 0
  or (number_of_channel_in_names ~= true and number_of_channel_in_names ~= false)
  or tracks_postfix ~= tostring(tracks_postfix)
  or (insert_the_smallest_unused_channel ~= true and insert_the_smallest_unused_channel ~= false)
  or (default_for_new_track ~= true and default_for_new_track ~= false) 
  or (select_the_new_track ~= true and select_the_new_track ~= false)
  or (not tonumber(R) or not tonumber(G) or not tonumber(B))
  or (R < 0 or G < 0 or B < 0)
  then
    reaper.MB(
    'Incorrect value for "input_width" or "number_of_channel_in_names" ' ..
    'or "insert_the_smallest_unused_midi_channel" ' ..
    'or "default_for_new_track" or "select_the_new_track" or "RGB" parameters. ' ..
    'Set the boolen - "true" or "false"', 'Error',0)
    nothing() return
  end
  
  local test_SWS = reaper.CF_EnumerateActions
  if not test_SWS then
    reaper.MB('Please install or update SWS extension', 'Error', 0) nothing() return
  end
  
  if reaper.CountSelectedTracks(0) ~= 1 then
    reaper.MB('Please select only one track (for multichannel VSTi)', 'Error',0) 
    nothing() return 
  end
  
  save_snd = ''
  if insert_the_smallest_unused_channel == true then
    local get_tr = reaper.GetSelectedTrack(0,0)
    if reaper.GetTrackNumSends(get_tr, -1) > 0 then
      t_snds = {}
      for j=0, reaper.GetTrackNumSends(get_tr, -1) - 1 do
        local gt_s = reaper.BR_GetSetTrackSendInfo(get_tr, -1, j, 'I_MIDI_DSTCHAN', false, 0)
        t_snds[j+1] = gt_s
      end
      table.sort(t_snds)
      save_snd = 0
      for k=1, #t_snds do
        if (t_snds[k] >= 16 and save_snd == t_snds[k] - 1) then
          save_snd = ''
          goto START
        elseif save_snd == t_snds[k]
        or save_snd == t_snds[k] - 1 then 
          save_snd = t_snds[k]
        else
          break
        end
      end
      save_snd = math.floor(save_snd) + 1
    else
      save_snd = 1
    end
  end   
  
  ::START::
  local retval, values = reaper.GetUserInputs('Create new track from miltich VSTi', 
  2, 'Set the MIDI and AUDIO name:,Set the new channel (1-16):,extrawidth=' .. input_width, "," .. save_snd)
  if retval then
    
    reaper.Undo_BeginBlock()
    reaper.PreventUIRefresh(1)
  
    local t = {}
    for s in string.gmatch(values,'[^,]+') do
      table.insert(t,s)
    end
    
    if #t ~= 2 then
      reaper.MB('Incorrect value or no value. Set the correct value for any line', 'Error', 0)
      goto START
    end  
    
    name = t[1]
    midi = t[2]
   
    if midi ~= string.match(midi, '%d+')
    or (tonumber(midi) < 1 or tonumber(midi) > 16) then 
      reaper.MB('Incorrect value. Set the correct midi channel (1-16)', 'Error', 0) 
      goto START 
    end
    
    midi = tonumber(midi)
    
    --Check feedback project setting----------------------
    if reaper.SNM_GetIntConfigVar('feedbackmode', 0) == 0 then
      rtvl = reaper.MB('To work the sends, the script needs to activate the project setting ' ..
      '"Allow feedback in routing (can result in lower performance, loud noises)". Continue?',
      'Warning',1)
      if rtvl == 1 then
        reaper.SNM_SetIntConfigVar('feedbackmode', 1)
      elseif rtvl == 2 then
        nothing() return
      end
    end
    
    --get main track--
    local get_instrument_track = reaper.GetSelectedTrack(0,0)
    save_tra = get_instrument_track
     if reaper.GetTrackNumSends(get_instrument_track, -1) > 0 then
       t_snds_2 = {}
       for j=0, reaper.GetTrackNumSends(get_instrument_track, -1) - 1 do
         local gt_s = reaper.BR_GetSetTrackSendInfo(get_instrument_track, -1, j, 'I_MIDI_DSTCHAN', false, 0)
         t_snds_2[j+1] = gt_s
       end
       table.sort(t_snds_2)
       bool_k = false
       for k=1, #t_snds_2 do
        if midi < t_snds_2[k] then
          save_k = k-2
          bool_k = true
          break
        end
       end
       if bool_k == false then
        save_k = #t_snds_2-1
       end
       if save_k < 0 then
        get_new_tr = get_instrument_track
       else
        get_new_tr = reaper.BR_GetMediaTrackSendInfo_Track(get_instrument_track,-1,save_k,0)
       end
       track_num_for_s = reaper.GetMediaTrackInfo_Value(get_new_tr,'IP_TRACKNUMBER')
     else
       track_num_for_s = reaper.GetMediaTrackInfo_Value(get_instrument_track,'IP_TRACKNUMBER')
     end
    
    if reaper.GetMediaTrackInfo_Value(get_instrument_track,'I_NCHAN') < midi*2 then
      reaper.SetMediaTrackInfo_Value(get_instrument_track,'I_NCHAN',midi*2)
    end
    
    reaper.SetMediaTrackInfo_Value(get_instrument_track,'B_MAINSEND', 0)
    
    --Insert tracks---------------------------------------
      
    reaper.InsertTrackAtIndex(track_num_for_s, default_for_new_track)
    get_midi_track = reaper.GetTrack(0, track_num_for_s)
    
    if number_of_channel_in_names == true then
      name = name .. ' - ' .. midi .. ' ' .. tracks_postfix
    end
    
    reaper.GetSetMediaTrackInfo_String( get_midi_track, 'P_NAME', name, true )
    reaper.SetMediaTrackInfo_Value(get_midi_track, 'I_RECMON', 1)
    
    if R == 0 and G == 0 and B == 0 then
      nothing()
    else
      reaper.SetTrackColor(get_midi_track, reaper.ColorToNative(R,G,B)|0x1000000)
    end
  
    --Sends-------------------------------------------------
    reaper.CreateTrackSend(get_midi_track, get_instrument_track)
    reaper.SetTrackSendInfo_Value( get_midi_track, 0, 0, 'I_MIDIFLAGS', midi << 5)
    reaper.SetTrackSendInfo_Value( get_midi_track, 0, 0, 'I_SRCCHAN', -1)
    
    reaper.CreateTrackSend(get_instrument_track, get_midi_track)
    reaper.BR_GetSetTrackSendInfo(get_midi_track, -1, 0, 'I_MIDI_SRCCHAN', true, -1 )
    reaper.SetTrackSendInfo_Value(get_midi_track, -1, 0, 'I_SRCCHAN', 2*(midi-1))
    reaper.SetTrackSendInfo_Value(get_midi_track, -1, 0, 'I_DSTCHAN', 0)
    
    reaper.SetOnlyTrackSelected(get_midi_track,1)
    reaper.ReorderSelectedTracks(track_num_for_s,2)
    
    if select_the_new_track == false then
      reaper.SetOnlyTrackSelected(save_tra,1)
    end
    
    reaper.Undo_EndBlock('Create new track (audio+midi) from multichannel VSTi (track)', -1)
    reaper.PreventUIRefresh(-1)
  
  else nothing() return end