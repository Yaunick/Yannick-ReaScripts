-- @description Yannick_Offline all FX from selected tracks - Save previous (slot n)
-- @author Yannick
-- @version 1.0
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   Initial release
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU 
    
  --===============
    slot = 1
  --===============
  
  function bla() end function nothing() reaper.defer(bla) end
  
  local count_tracks = reaper.CountSelectedTracks(0)
  if count_tracks == 0 then
    reaper.MB("No tracks selected", "Error", 0)
    nothing() return
  end

  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)
  
  for j=0, count_tracks-1 do
    local offline_str = ""
    local tr = reaper.GetSelectedTrack(0,j)
    tr_guid = reaper.GetTrackGUID(tr)
    for i=0, reaper.TrackFX_GetCount(tr)-1 do
      if reaper.TrackFX_GetOffline(tr, i) == true then
        offline_state = 1
      else
        offline_state = 0
      end
      local GUID = reaper.TrackFX_GetFXGUID(tr, i)
      offline_str = offline_str .. GUID .. ',' .. offline_state .. ','
      reaper.TrackFX_SetOffline(tr, i, true)
    end
    reaper.SetProjExtState(0, "Selected_tracks_fx_yannick_reasc" .. slot, tr_guid, offline_str)
  end
  
  reaper.Undo_EndBlock('Offline all FX from selected tracks - Save previous (slot ' .. slot .. ')', -1)
  reaper.PreventUIRefresh(-1)

  



