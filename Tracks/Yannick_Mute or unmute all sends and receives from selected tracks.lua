-- @description Yannick_Mute or unmute all sends and receives from selected tracks
-- @author Yannick
-- @version 1.2
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   # changed donation link
--   # contact link changed
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14
  
  
  -----------------------------------------------------------------
  
    bypass_sends = true
    bypass_receives = true
  
  -----------------------------------------------------------------
  
  function bla() end
  function nothing() reaper.defer(bla) end
  
  if (bypass_sends ~= true and bypass_sends ~= false)
  or (bypass_receives ~= true and bypass_receives ~= false)
  or (bypass_sends == false and bypass_receives == false)
  then
    reaper.MB("Incorrect values at the beginning of the script", "Error", 0)
    nothing() return
  end
  
  if reaper.CountSelectedTracks(0) == 0 then
    reaper.MB("No tracks. Please select tracks", "Error", 0)
    nothing() return
  end
  
  local toggle_mute = 1
  local change_sends = false
  local change_receives = false
  for i=0, reaper.CountSelectedTracks(0)-1 do
    local track = reaper.GetSelectedTrack(0,i)
    if bypass_sends == true then
      if reaper.GetTrackNumSends(track, 0) > 0 then
        change_sends = true
        for j=0, reaper.GetTrackNumSends(track, 0)-1 do
          if reaper.GetTrackSendInfo_Value( track, 0, j, "B_MUTE") == 1 then
            toggle_mute = 0
          end
        end
      end
    end
    if bypass_receives == true then
      if reaper.GetTrackNumSends(track, -1) > 0 then
        change_receives = true
        for j=0, reaper.GetTrackNumSends(track, -1)-1 do
          if reaper.GetTrackSendInfo_Value( track, -1, j, "B_MUTE") == 1 then
            toggle_mute = 0
          end
        end
      end
    end
  end
  
  if (change_sends == true and change_receives == false)
  or (change_sends == true and change_receives == true)
  or (change_sends == false and change_receives == true)
  then
    reaper.Undo_BeginBlock()
    reaper.PreventUIRefresh(1)
    for i=0, reaper.CountSelectedTracks(0)-1 do
      local track = reaper.GetSelectedTrack(0,i)
      if change_sends == true then
        for j=0, reaper.GetTrackNumSends(track, 0)-1 do
          reaper.SetTrackSendInfo_Value( track, 0, j, "B_MUTE", toggle_mute)
        end
      end
      if change_receives == true then
        for j=0, reaper.GetTrackNumSends(track, -1)-1 do
          reaper.SetTrackSendInfo_Value( track, -1, j, "B_MUTE", toggle_mute)
        end
      end
    end
    reaper.Undo_EndBlock("Mute or unmute all sends and receives from selected tracks", -1)
    reaper.PreventUIRefresh(-1)
  end
  
  