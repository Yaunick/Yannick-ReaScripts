-- @description Yannick_Set exclusive record arm for track or toggle folder collapse
-- @author Yannick
-- @version 1.1
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   + Added new setting to unarm tracks with "Record: disable (input monitoring only)" mode - true or false
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU

  -------------------------------------------------------------------
  
    unarm_tracks_with_record_input_monitoring_only_mode = true
    
  -------------------------------------------------------------------

  function bla() end function nothing() reaper.defer(bla) end
  
  if unarm_tracks_with_record_input_monitoring_only_mode ~= true 
  and unarm_tracks_with_record_input_monitoring_only_mode ~= false
  then
    reaper.MB('Incorrect values at the beginnig of the script','Error',0)
    nothing() return
  end
  
  local test_SWS = reaper.CF_EnumerateActions 
  if not test_SWS then
    reaper.MB('Please install or update SWS extension', 'Error', 0) nothing() return
  end

  if reaper.CountSelectedTracks(0) ~= 1 then
    nothing() return 
  end
  
  function Toggle_folder_collapsed(get_track)
    if reaper.GetMediaTrackInfo_Value(get_track, 'I_FOLDERCOMPACT') == 0 then
      reaper.SetMediaTrackInfo_Value(get_track, 'I_FOLDERCOMPACT', 2)
    else
      reaper.SetMediaTrackInfo_Value(get_track, 'I_FOLDERCOMPACT', 0)
    end
  end
  
  local get_track = reaper.GetSelectedTrack(0,0)
  local window, _, _ = reaper.BR_GetMouseCursorContext()
  local track_info = reaper.GetMediaTrackInfo_Value(get_track, 'I_FOLDERDEPTH')
  
  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)

  if track_info == 1 and window == 'tcp' then
    Toggle_folder_collapsed(get_track)
  elseif track_info == 1 and window == 'mcp' then
    reaper.Main_OnCommand(41665, 0)
  elseif track_info ~= 1 then
    if unarm_tracks_with_record_input_monitoring_only_mode == false then
      for i=0, reaper.CountTracks(0)-1 do
        local track = reaper.GetTrack(0,i)
        if reaper.IsTrackSelected(track) == true then
          reaper.SetMediaTrackInfo_Value(track, 'I_RECARM', 1)
        else
          if reaper.GetMediaTrackInfo_Value(track, 'I_RECMODE') ~= 2 then
            reaper.SetMediaTrackInfo_Value(track, 'I_RECARM', 0)
          end
        end
      end
    else
      reaper.Main_OnCommand(40491,0)
      reaper.Main_OnCommand(40294,0)
    end
  end
  
  reaper.UpdateArrange()
  reaper.PreventUIRefresh(-1)
  reaper.Undo_EndBlock('Set exclusive record arm for track or toggle folder collapse', -1)