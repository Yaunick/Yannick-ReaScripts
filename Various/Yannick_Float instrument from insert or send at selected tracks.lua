-- @description Yannick_Float instrument from insert or send at selected tracks
-- @author Yannick
-- @version 1.0
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   Initial release
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU

  float_instrument_from_all_selected_tracks = true
  
  function bla() end function nothing() reaper.defer(bla) end
  
  if float_instrument_from_all_selected_tracks ~= true
  and float_instrument_from_all_selected_tracks ~= false 
  then
    reaper.MB
    (
    'Incorrct value for "float_instrument_from_all_selected_tracks" parameter. Set the boolen - "true" or "false"', 
    'Error', 0
    )
    nothing() return
  end
  
  local test_SWS = reaper.CF_EnumerateActions 
  if not test_SWS then
    reaper.MB('Please install or update SWS extension', 'Error', 0) nothing() return
  end
  
  if reaper.CountSelectedTracks(0) == 0 then
    nothing() return
  end
  
  if float_instrument_from_all_selected_tracks == true then
    count_sel_tracks = reaper.CountSelectedTracks(0)
  else
    count_sel_tracks = 1
  end
 
  local count = 1
  local t_instr, t_tracks = {}, {}
  for i=1, count_sel_tracks do
    local instr_in_insert_tr = false
    local track = reaper.GetSelectedTrack(0,i-1)
    local count_fx = reaper.TrackFX_GetCount(track)
    if count_fx > 0 then
      local instrument = reaper.TrackFX_GetInstrument(track)
      if instrument ~= -1 then
        t_instr[count], t_tracks[count] = instrument, track
        count, instr_in_insert_tr = count + 1, true
      end
    end
    if instr_in_insert_tr == false then
      local num_sends = reaper.GetTrackNumSends(track, 0)
      if num_sends > 0 then
        local j = 1
        while j <= num_sends do
          local track = reaper.BR_GetMediaTrackSendInfo_Track(track, 0, j-1, 1)
          local count_fx = reaper.TrackFX_GetCount(track)
          if count_fx > 0 then
            local instrument = reaper.TrackFX_GetInstrument(track)
            if instrument ~= -1 then
              t_instr[count], t_tracks[count] = instrument, track
              count, j = count + 1, num_sends
            end
          end
          j = j + 1
        end
      end
    end
  end
  
  if #t_tracks > 0 and #t_instr > 0 then
    for i=1, #t_tracks do
      if reaper.TrackFX_GetOpen(t_tracks[i], t_instr[i]) == false then
        reaper.TrackFX_Show(t_tracks[i], t_instr[i], 3)
      else
        if #t_tracks == 1 then
         reaper.TrackFX_Show(t_tracks[i], t_instr[i], 2)
        end
      end
    end
  end
 
