-- @description Yannick_Save (copy) all tempo markers from the project
-- @author Yannick
-- @version 1.0
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   Initial release
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU

  ---------------------------------
    show_warning_window = true
  ---------------------------------

  function bla() end
  function nothing() reaper.defer(bla) end
  
  if show_warning_window ~= false and show_warning_window ~= true then
    reaper.MB("Incorrect values at the beginning of the script", "Error",0)
    nothing() return
  end
  
  local count_tempo_markers = reaper.CountTempoTimeSigMarkers(0)
  if count_tempo_markers == 0 then
    reaper.MB("No tempo markers!", "Error", 0)
    nothing()
  else
    reaper.Undo_BeginBlock()
    local tempo_string = ""
    
    for i=0, count_tempo_markers-1 do
      local retval, timepos, measurepos, beatpos, bpm, timesig_num, timesig_denom, lineartempo = reaper.GetTempoTimeSigMarker(0, i)
      if lineartempo == false then
        lineartempo = 0
      else
        lineartempo = 1
      end
      tempo_string = tempo_string ..
          timepos .. ',' .. 
          bpm .. ',' .. 
          timesig_num .. ',' .. 
          timesig_denom .. ',' .. 
          lineartempo .. ',' .. '\n'
    end
    
    reaper.SetExtState("tempo_markers_yannick_reasc_section", "tempo_markers_yan_key", tempo_string, false)
    if show_warning_window == true then
      reaper.MB("Success! All tempo markers have been saved", "Warning", 0)
    end
    
    reaper.Undo_EndBlock('Save (copy) all tempo markers from the project', -1)
  end
