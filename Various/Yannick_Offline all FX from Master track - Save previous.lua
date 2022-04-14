-- @description Yannick_Offline all FX from Master track - Save previous
-- @author Yannick
-- @version 1.2
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   # changed donation link
--   # contact link changed
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14

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
  for i=0, reaper.TrackFX_GetCount(master_track)-1 do
    if reaper.TrackFX_GetOffline(master_track, i) == true then
      offline_state = 1
    else
      offline_state = 0
    end
    local GUID = reaper.TrackFX_GetFXGUID(master_track, i)
    offline_str = offline_str .. GUID .. ',' .. offline_state .. ','
    if offline_all_fx_before_saving == true then
      reaper.TrackFX_SetOffline(master_track, i, true)
    end
  end
  
  reaper.SetProjExtState(0, "Master_fx_yannick_reasc", "master_track", offline_str)
  
  reaper.Undo_EndBlock('Offline all FX from Master track - Save previous', -1)
  reaper.PreventUIRefresh(-1)

  


