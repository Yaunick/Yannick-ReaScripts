-- @description Yannick_Create midi track from multichannel VSTi (selected track)
-- @author Yannick
-- @version 1.2
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   # changed donation link
--   # contact link changed
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14

  --///////////|||\\\\\\\\\\\---Customize this---///////////|||\\\\\\\\\\--
  
  ---some parameters for tracks--------------------------------------------
    input_width = 30
    show_midi_on_mcp = false
    number_of_channel_in_names = true
      midi_postfix = 'MIDI'
      
    defaults_midi_track = false
    -- if false then --------------------
    
      monitor_rec_for_MIDI_track = true
      
      record_mode = 1      -- 1 = Record: input (audio or MIDI)
      
                           -- 2 = Record: MIDI overdub
                           -- 3 = Record: MIDI replace
                           -- 4 = Record: MIDI touch-replace
                           -- 5 = Record: MIDI latch-replace
                           
                           -- 6 = Record: output (MIDI)
                           
                           -- 7 = Record: input (force MIDI)
                           
                           -- 8 = Record: disable (input monitoring only)
                             
    -- end ------------------------------
    
    select_the_midi_track = false
    insert_the_smallest_unused_midi_channel = true
  -------------------------------------------------------------------------
  
  ---color for midi track--------------------------------------------------
  ---enter 0 for R_a and G_a and B_a to disable coloring--
    R_m = 0    ---Red
    G_m = 0    ---Green
    B_m = 0    ---Blue
  -------------------------------------------------------------------------
  
  --\\\\\\\\\\\|||///////////---//////||\\\\\\---\\\\\\\\\\\|||//////////--


  --///////////-----------------------------------------------\\\\\\\\\\\--
  --===========---RUN SCRIPT--START START START--RUN SCRIPT---===========--
  --\\\\\\\\\\\-----------------------------------------------///////////--
  

  function bla() end
  function nothing() reaper.defer(bla) end

  if not tonumber(input_width) 
  or input_width < 0 
  or (show_midi_on_mcp ~= true and show_midi_on_mcp ~= false)
  or (number_of_channel_in_names ~= true and number_of_channel_in_names ~= false)
  or midi_postfix ~= tostring(midi_postfix)
  or (defaults_midi_track ~= true and defaults_midi_track ~= false) 
  or (monitor_rec_for_MIDI_track ~= true and monitor_rec_for_MIDI_track ~= false)
  or (record_mode ~= 1 and record_mode ~= 2 and record_mode ~= 3 and record_mode ~= 4 
    and record_mode ~= 5 and record_mode ~= 6 and record_mode ~= 7 and record_mode ~= 8)
  or (select_the_midi_track ~= true and select_the_midi_track ~= false) 
  or (insert_the_smallest_unused_midi_channel ~= true and insert_the_smallest_unused_midi_channel ~= false) 
  or (not tonumber(R_m) or not tonumber(G_m) or not tonumber(B_m))
  or (R_m < 0 or G_m < 0 or B_m < 0)
  then
    reaper.MB
    (
    'Incorrect values at the beginning of the script',
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
        if reaper.GetTrackNumSends(get_tr, -1) > 0 then
          t_snds = {}
          for j=0, reaper.GetTrackNumSends(get_tr, -1) - 1 do
            local gt_s = reaper.BR_GetSetTrackSendInfo(get_tr, -1, j, 'I_MIDI_DSTCHAN', false, 0)
            t_snds[j+1] = gt_s
          end
          table.sort(t_snds)
          save_snd = 0
          for k=1, #t_snds do
            if t_snds[k] == 0
            or (t_snds[k] >= 16 and save_snd == t_snds[k] - 1) then
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
    end       
    
    ::START::
    local retval, value = reaper.GetUserInputs
    (
    'Create MIDI track from multich VSTi', 
    2, 'Set the MIDI name:,Set the new channel (0-16):,extrawidth=' .. input_width, ',' .. save_snd
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
      or (tonumber(channel) < 0 or tonumber(channel) > 16) 
      then 
        reaper.MB('Incorrect value. Set the correct midi channel (0-16)', 'Error', 0) 
        goto START 
      end
      
      booln = true
      name_tr = channel
      if channel == '0' then
        name_tr = 'All'
        booln = false
      end
      
      function convert_bool(bool)
        if bool == false then
          bool = 0
        else 
          bool = 1
        end
        return bool
      end
    
    
    --START-CyCLe----START-CyCLe----START-CyCLe----START-CyCLe--
      for i = 0, reaper.CountSelectedTracks(0)-1 do
    ------------------------------------------------------------  
      
        --START--//////////////////////---Get instrument track and set send properties---\\\\\\\\\\\\\\\\\\\\\\\\\\\\\--
            local get_instrument_track = reaper.GetSelectedTrack(0,i)
            local instrument_track_num = reaper.GetMediaTrackInfo_Value(get_instrument_track,'IP_TRACKNUMBER')
        ---END---\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\--------/////////////////////////////////////////////////////--
      
          
        --START--/////////////////////---Insert MIDI track and set send properties---\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\--
            reaper.InsertTrackAtIndex(instrument_track_num-1,defaults_midi_track)
            local get_midi_track = reaper.GetTrack(0,instrument_track_num-1)
            if select_the_midi_track == true then
              save_mid_tr = get_midi_track
            end
            
            if number_of_channel_in_names == true then
              reaper.GetSetMediaTrackInfo_String(get_midi_track, 'P_NAME', name .. ' - ' .. name_tr .. ' ' .. midi_postfix, true)
            else
              reaper.GetSetMediaTrackInfo_String(get_midi_track, 'P_NAME', name, true)
            end
            
            reaper.SetMediaTrackInfo_Value(get_midi_track, 'B_SHOWINMIXER', convert_bool(show_midi_on_mcp))
            
            if R_m == 0 and G_m == 0 and B_m == 0 then
              nothing()
            else
              reaper.SetTrackColor(get_midi_track, reaper.ColorToNative(R_m,G_m,B_m)|0x1000000)
            end
            
            if defaults_midi_track == false then
              
              if monitor_rec_for_MIDI_track == true then
                reaper.SetMediaTrackInfo_Value(get_midi_track, 'I_RECMON', 1)
              else
                reaper.SetMediaTrackInfo_Value(get_midi_track, 'I_RECMON', 0)
              end
            
              if record_mode == 1 then
                record_mode = 0
              elseif record_mode == 2 then
                record_mode = 7
              elseif record_mode == 3 then
                record_mode = 8
              elseif record_mode == 4 then
                record_mode = 9
              elseif record_mode == 5 then
                record_mode = 16
              elseif record_mode == 6 then
                record_mode = 4
              elseif record_mode == 7 then
                record_mode = 15
              elseif record_mode == 8 then
                record_mode = 2
              end
              
              reaper.SetMediaTrackInfo_Value(get_midi_track, 'I_RECMODE', record_mode)
            
            end
            
            reaper.CreateTrackSend(get_midi_track, get_instrument_track)
            reaper.SetTrackSendInfo_Value(get_midi_track, 0, 0, 'I_SRCCHAN', -1)
            
            if booln == true then
              reaper.SetTrackSendInfo_Value(get_midi_track, 0, 0, 'I_MIDIFLAGS', tonumber(channel) << 5)
            else  
              reaper.SetTrackSendInfo_Value(get_midi_track, 0, 0, 'I_MIDIFLAGS', 0)
            end
        ---END---\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\--------///////////////////////////////////////////////////--
    
    --END-CyCLe----END-CyCLe--
      end
    --------------------------
    if select_the_midi_track == true then
      reaper.Main_OnCommand(40297,0)
      reaper.SetTrackSelected(save_mid_tr, true)
    end
    
      reaper.Undo_EndBlock('Create midi track from multichannel VSTi (track)', -1)
      reaper.PreventUIRefresh(-1)
      
    else 
      nothing() return 
    end
    
  else 
    reaper.MB('Please select a track', 'Error',0) 
    nothing()
  end