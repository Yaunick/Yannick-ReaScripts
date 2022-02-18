-- @description Toggle offline all FX except instruments from selected tracks - Clear all saves
-- @author Yannick
-- @version 1.0
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   Initial release
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU 
  
  function bla() end
  function nothing() reaper.defer(bla) end
  
  local retval, key, val = reaper.EnumProjExtState(0, "Selected_tracks_fx_yannick_reasc_toggle_offline_tracks_ind", 0)
  if retval == false then
    reaper.MB("Nothing to clean", "Warning", 0)
  else
    reaper.SetProjExtState(0, "Selected_tracks_fx_yannick_reasc_toggle_offline_tracks_ind", "", "")
    reaper.MB("Success! All bypass states of FX from tracks have been removed", "Warning", 0)
  end
  nothing()
