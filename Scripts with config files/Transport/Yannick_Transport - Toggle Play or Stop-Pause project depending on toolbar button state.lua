-- @description Yannick_Transport - Toggle Play or Stop-Pause project depending on toolbar button state
-- @author Yannick
-- @version 1.0
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   + initial release
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14
  
  local button_script_state = reaper.GetToggleCommandStateEx(0, reaper.NamedCommandLookup("_RSc14726b85f94706b39bf8c97429fd5d6ad8d410f") )
  local play_state = reaper.GetToggleCommandState(1007)
  local rec_state = reaper.GetToggleCommandState(1013)
  if play_state == 1 or rec_state == 1 then
    if button_script_state == 1 then
      local play_pos = reaper.GetPlayPosition()
      reaper.SetEditCurPos(play_pos, false, false)
      reaper.Main_OnCommand(1016,0) -- Stop
    else
      reaper.Main_OnCommand(1016,0) -- Stop
    end
  else
    reaper.Main_OnCommand(1007,0) -- Play
  end
