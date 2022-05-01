-- @description Yannick_Remove (clear) time selection then loop points (then close midi editor - disabled by default)
-- @author Yannick
-- @version 1.0
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   + initial release
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14

  ---------------------------------------------------------------
    
    close_midi_editor_if_there_are_no_TS_and_LP = false
    
  ---------------------------------------------------------------
  
  function bla() end
  function nothing() reaper.defer(bla) end
  
  if close_midi_editor_if_there_are_no_TS_and_LP ~= false 
  and close_midi_editor_if_there_are_no_TS_and_LP ~= true 
  then
    reaper.MB('Incorrect values at the beginning of the script', 'Error', 0)
    nothing() return
  end
  
  local ME = reaper.MIDIEditor_GetActive()
  if not ME then
    nothing() return
  end

  function main()
    start_ts, end_ts = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
    start_lp, end_lp = reaper.GetSet_LoopTimeRange(false, true, 0, 0, false)
    if end_ts - start_ts > 0 then
      reaper.Main_OnCommand(40635,0)
    elseif end_lp - start_lp > 0 then
      reaper.Main_OnCommand(40624,0)
    else
      if close_midi_editor_if_there_are_no_TS_and_LP == true then
        reaper.MIDIEditor_OnCommand(ME,2)
      end
    end
  end
  
  reaper.defer(main)