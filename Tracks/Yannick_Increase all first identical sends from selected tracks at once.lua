-- @description Yannick_Increase all first identical sends from selected tracks at once
-- @author Yannick
-- @version 1.1
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   # changed donation link
--   # contact link changed
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14

  --------------------------------------------------  
    nudge_sends_by_value = 1
  --------------------------------------------------

  function bla() end
  function nothing() reaper.defer(bla) end
  
  if not tonumber(nudge_sends_by_value) then
    reaper.MB('Incorrect value at the beginning of the script','Error',0)
    nothing() return
  end
  
  local test_SWS = reaper.CF_EnumerateActions
  if not test_SWS then
    reaper.MB('Please install or update SWS extension', 'Error', 0) nothing() return
  end
  
  if reaper.CountSelectedTracks(0) > 0 then
    
    for i=0, reaper.CountSelectedTracks(0)-1 do
      local track = reaper.GetSelectedTrack(0,i)
      if reaper.GetTrackNumSends(track,0) == 1 then
        local get_send_track = reaper.BR_GetMediaTrackSendInfo_Track(track,0,0,1)
        if i == 0 then
          first_send_track = get_send_track
        end
        if first_send_track ~= get_send_track then
          reaper.MB('Please select tracks with identical sends (with sends to the one track)','Error',0)
          nothing() return
        end
      elseif reaper.GetTrackNumSends(track,0) == 0 then
        reaper.MB('Please select only tracks with sends','Error',0)
        nothing() return
      else
        reaper.MB('Please select only tracks with one send','Error',0)
        nothing() return
      end
    end
    
    reaper.Undo_BeginBlock()
    reaper.PreventUIRefresh(1)
    
    for i=0, reaper.CountSelectedTracks(0)-1 do
      local track = reaper.GetSelectedTrack(0,i)
      local send_vol = reaper.GetTrackSendInfo_Value(track, 0, 0,'D_VOL')
      reaper.SetTrackSendInfo_Value(track, 0, 0, 'D_VOL', send_vol*10^(nudge_sends_by_value/20))
    end
    
    reaper.Undo_EndBlock('Decrease all first identical sends from selected tracks at once',-1)
    reaper.PreventUIRefresh(-1)
    
  else
    reaper.MB('No tracks. Please select a track','Error',0)
    nothing() return
  end