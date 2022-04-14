-- @description Yannick_Offline all FX from selected tracks - Clear all saves (slot n)
-- @author Yannick
-- @version 1.3
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   # changed donation link
--   # contact link changed
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14

  --===============
    slot = 1        
  --===============
  
  function bla() end
  function nothing() reaper.defer(bla) end
  
  local retval, key, val = reaper.EnumProjExtState(0, "Selected_tracks_fx_yannick_reasc" .. slot, 0)
  if retval == false then
    reaper.MB("Nothing to clean (slot " .. slot .. ")", "Warning", 0)
  else
    reaper.SetProjExtState(0, "Selected_tracks_fx_yannick_reasc" .. slot, "", "")
    reaper.MB("Success! All offline states of FX from tracks have been removed (slot " .. slot .. ")", "Warning", 0)
  end
  nothing()