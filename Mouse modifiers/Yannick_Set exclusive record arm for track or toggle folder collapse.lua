-- @description Yannick_Set exclusive record arm for track or toggle folder collapse
-- @author Yannick
-- @version 1.0
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   Initial release
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU

  function bla() end function nothing() reaper.defer(bla) end
  
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
    reaper.Main_OnCommand( 40491, 0)  --- unrecord all tracks
    reaper.Main_OnCommand( 40294, 0)  --- set record one track
  end
  
  reaper.UpdateArrange()
  reaper.PreventUIRefresh(-1)
  reaper.Undo_EndBlock('Set exclusive record arm for track or toggle folder collapse', -1)
