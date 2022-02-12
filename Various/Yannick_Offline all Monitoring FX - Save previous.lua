-- @description Yannick_Offline all Monitoring FX - Save previous
-- @author Yannick
-- @version 1.0
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   initial release
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU
  
  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)
  
  local master_track = reaper.GetMasterTrack(0)
  local offline_str = ""
  local bool = false
  local i = 0
  while bool == false do
    local GUID = reaper.TrackFX_GetFXGUID(master_track, 0x1000000 + i)
    if GUID == nil then
      bool = true
    else
      if reaper.TrackFX_GetOffline(master_track, 0x1000000 + i) == true then
        offline_state = 1
      else
        offline_state = 0
      end
      offline_str = offline_str .. GUID .. ',' .. offline_state .. ','
      reaper.TrackFX_SetOffline(master_track, 0x1000000 + i, true)
    end
    i = i + 1
  end
  
  reaper.SetProjExtState(0, "Monitoring_fx_yannick_reasc", "monit_fx", offline_str)
  
  reaper.Undo_EndBlock('Offline all Monitoring FX - Save previous', -1)
  reaper.PreventUIRefresh(-1)