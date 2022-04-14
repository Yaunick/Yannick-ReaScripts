-- @description Yannick_Create audio track from multichannel VSTi (selected track)
-- @author Yannick
-- @version 1.1
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   # changed donation link
--   # contact link changed
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14

   --/////////////---\\\\\\\\\---/////////---\\\\\\\\\\\\--

  --------------------------------------------------------
  input_width = 0
  show_audio_on_tcp = true
  number_of_channel_in_names = true
    audio_postfix = 'st'
  defaults_audio_track = false
  insert_the_smallest_unused_midi_channel = true
  --------------------------------------------------------

  ---color for audio track--------------------------------
  ---enter 0 for R_a and G_a and B_a to disable coloring--
  R_a = 0   ---Red
  G_a = 0   ---Green
  B_a = 0   ---Blue
  --------------------------------------------------------

  --\\\\\\\\\\\\\---/////////---\\\\\\\\\---////////////--

  function bla() end
  function nothing() reaper.defer(bla) end

  if not tonumber(input_width) 
  or input_width < 0 
  or (show_audio_on_tcp ~= true and show_audio_on_tcp ~= false)
  or (number_of_channel_in_names ~= true and number_of_channel_in_names ~= false)
  or audio_postfix ~= tostring(audio_postfix)
  or (defaults_audio_track ~= true and defaults_audio_track ~= false)
  or (insert_the_smallest_unused_midi_channel ~= true and insert_the_smallest_unused_midi_channel ~= false)
  or (not tonumber(R_a) or not tonumber(G_a) or not tonumber(B_a))
  or (R_a < 0 or G_a < 0 or B_a < 0)
  then
    reaper.MB
    (
    'Incorrect value for "input_width" or "show_audio_on_tcp" ' ..
    'or "number_of_channel_in_names" ' ..
    'or "defaults_audio_track" ' ..
    'or "insert_the_smallest_unused_midi_channel" ' ..
    'or "RGB" parameters. Look at the beginning of the script',
    'Error',0
    )
    nothing() return
  end

  local test_SWS = reaper.CF_EnumerateActions 
  if not test_SWS then
    reaper.MB('Please install or update SWS extension', 'Error', 0) nothing() return
  end

  if reaper.CountSelectedTracks(0) > 0 then
  
    save_snd = ''
    if insert_the_smallest_unused_midi_channel == true then
      if reaper.CountSelectedTracks(0) == 1 then
        local get_tr = reaper.GetSelectedTrack(0,0)
        if reaper.GetTrackNumSends(get_tr, 0) > 0 then
          t_snds = {}
          for j=0, reaper.GetTrackNumSends(get_tr, 0) - 1 do
            local gt_s = reaper.GetTrackSendInfo_Value(get_tr, 0, j, 'I_SRCCHAN')
            t_snds[j+1] = math.floor((gt_s/2)+1)
          end
          table.sort(t_snds)
          save_snd = 0
          for k=1, #t_snds do
            if t_snds[k] >= 16 and save_snd == t_snds[k] - 1 then
              save_snd = ''
              goto START
            elseif save_snd == t_snds[k]
            or save_snd == t_snds[k] - 1 then 
              save_snd = t_snds[k]
            else
              break
            end
          end
          save_snd = save_snd + 1
        else
          save_snd = 1
        end
      end  
    end

    ::START::
    local retval, value = reaper.GetUserInputs
    (
    'Create audio track from multich VSTi', 2,
    'Set the AUDIO name:,Set new channel as midi (1-16):,extrawidth=' .. input_width, "," .. save_snd
    )
   
    if retval then
     
      reaper.Undo_BeginBlock()
      reaper.PreventUIRefresh(1)
     
      local t = {}
      for s in string.gmatch(value,'[^,]+') do
        table.insert(t,s)
      end
     
      if #t ~= 2 then
        reaper.MB('Incorrect value or no value. Set the correct value for any line', 'Error', 0)
        goto START
      end      
     
      name = t[1]
      channel = t[2]
     
      if channel ~= string.match(channel,'%d+')
      or (tonumber(channel) < 1 or tonumber(channel) > 16)
      then
        reaper.MB('Incorrect value. Set the correct midi channel (1-16)', 'Error', 0)
        goto START
      end
     
     
      function convert_bool(bool)
        if bool == false then
          bool = 0
        else
          bool = 1
        end
        return bool
      end
     
      for i = 0, reaper.CountSelectedTracks(0)-1 do
        local get_instrument_track = reaper.GetSelectedTrack(0,i)
        local instrument_track_num = reaper.GetMediaTrackInfo_Value(get_instrument_track,'IP_TRACKNUMBER')
        if reaper.GetMediaTrackInfo_Value(get_instrument_track,'I_NCHAN') < tonumber(channel)*2 then
          reaper.SetMediaTrackInfo_Value(get_instrument_track,'I_NCHAN', tonumber(channel)*2)
        end
        if reaper.GetMediaTrackInfo_Value(get_instrument_track,'B_MAINSEND') == 1 then
          reaper.SetMediaTrackInfo_Value(get_instrument_track,'B_MAINSEND', 0)
        end
       
        reaper.InsertTrackAtIndex(instrument_track_num-1,defaults_audio_track)
        local get_audio_track = reaper.GetTrack(0,instrument_track_num-1)
        
        if number_of_channel_in_names == true then
          name = name .. ' - '.. channel .. ' ' .. audio_postfix
        end
        
        reaper.GetSetMediaTrackInfo_String(get_audio_track, 'P_NAME', name, true)

        reaper.SetMediaTrackInfo_Value(get_audio_track, 'B_SHOWINTCP', convert_bool(show_audio_on_tcp))
        if R_a == 0 and G_a == 0 and B_a == 0 then
          nothing()
        else
          reaper.SetTrackColor(get_audio_track, reaper.ColorToNative(R_a,G_a,B_a)|0x1000000)
        end
        reaper.CreateTrackSend(get_instrument_track, get_audio_track)
        reaper.BR_GetSetTrackSendInfo(get_audio_track, -1, 0, 'I_MIDI_SRCCHAN', true, -1)
        reaper.SetTrackSendInfo_Value(get_audio_track, -1, 0, 'I_SRCCHAN', 2*(tonumber(channel)-1))
        reaper.SetTrackSendInfo_Value(get_audio_track, -1, 0, 'I_DSTCHAN', 0)
      end
   
      reaper.Undo_EndBlock('Create only audio track from multichannel VSTi (track)', -1)
      reaper.PreventUIRefresh(-1)
     
    else
      nothing() return
    end
   
  else
    reaper.MB('Please select a track', 'Error',0)
    nothing()
  end