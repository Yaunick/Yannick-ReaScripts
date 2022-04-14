-- @description Yannick_Float instruments from insert or send at selected track or toggle folder collapse
-- @author Yannick
-- @version 1.1
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   # changed donation link
--   # contact link changed
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14

  function bla() end function nothing() reaper.defer(bla) end
  
  local test_SWS = reaper.CF_EnumerateActions 
  if not test_SWS then
    reaper.MB('Please install or update SWS extension', 'Error', 0) nothing() return
  end
  
  if reaper.CountSelectedTracks(0) ~= 1 then
    nothing() return
  end
  
  function Float_Instrument_from_sel_track(track)
    local save_track, save_instr = nil, nil
    local instr_in_insert_tr = false
    local count_fx = reaper.TrackFX_GetCount(track)
    if count_fx > 0 then
      local instrument = reaper.TrackFX_GetInstrument(track)
      if instrument ~= -1 then
        save_track, save_instr = track, instrument 
        instr_in_insert_tr = true
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
              save_instr, save_track = instrument, track
              j = num_sends
            end
          end
          j = j + 1
        end
      end
    end
    
    if save_track ~= nil and save_instr ~= nil then     
      if reaper.TrackFX_GetOpen(save_track, save_instr) == false then
        reaper.TrackFX_Show(save_track, save_instr, 3)
      end
    end
  end

  local window, _, _ = reaper.BR_GetMouseCursorContext()
  local get_track = reaper.GetSelectedTrack(0,0)
  local track_info = reaper.GetMediaTrackInfo_Value(get_track, 'I_FOLDERDEPTH')
  
  if track_info == 1 and window == 'tcp' then
    local compact = reaper.GetMediaTrackInfo_Value(get_track, 'I_FOLDERCOMPACT')
    if compact == 0 then
      reaper.SetMediaTrackInfo_Value(get_track, 'I_FOLDERCOMPACT', 2)
    elseif compact == 2 then
      reaper.SetMediaTrackInfo_Value(get_track, 'I_FOLDERCOMPACT', 0)
    end
  elseif track_info == 1 and window == 'mcp' then
    reaper.Main_OnCommand(41665, 0) --- toggle folder collapsed in MCP
  elseif track_info ~= 1 then
    Float_Instrument_from_sel_track(get_track)
  end

