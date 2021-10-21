-- @description Yannick_Show or hide peaks on all items (global)
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
  
  local showpeaks = reaper.SNM_GetIntConfigVar("showpeaks", -1)
  local display_peaks = showpeaks&1 == 1
  if display_peaks then
    reaper.SNM_SetIntConfigVar("showpeaks", showpeaks-1)
  else
    reaper.SNM_SetIntConfigVar("showpeaks", showpeaks+1)
  end
  reaper.UpdateArrange()
