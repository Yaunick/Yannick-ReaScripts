-- @description Yannick_Offline all Monitoring FX - Save previous
-- @author Yannick
-- @version 1.1
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   Added new option "offline_all_fx_before_saving" (true by default)
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU

  --------------------------------------------
    offline_all_fx_before_saving = true
  --------------------------------------------
  
  function bla() end function nothing() reaper.defer(bla) end
  
  if (offline_all_fx_before_saving ~= true and offline_all_fx_before_saving ~= false)
  then
    reaper.MB("Incorrect values at the beginning of the script", "Error",0)
    nothing() return
  end
  
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
      if offline_all_fx_before_saving == true then
        reaper.TrackFX_SetOffline(master_track, 0x1000000 + i, true)
      end
    end
    i = i + 1
  end
  
  reaper.SetProjExtState(0, "Monitoring_fx_yannick_reasc", "monit_fx", offline_str)
  
  reaper.Undo_EndBlock('Offline all Monitoring FX - Save previous', -1)
  reaper.PreventUIRefresh(-1)