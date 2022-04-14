-- @description Yannick_Restore (paste) tempo markers to the project by replacing the old ones
-- @author Yannick
-- @version 1.1
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   # changed donation link
--   # contact link changed
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14
  
  ---------------------------------
    show_warning_window = false
  ---------------------------------
  
  function bla() end
  function nothing() reaper.defer(bla) end
  
  if show_warning_window ~= false and show_warning_window ~= true then
    reaper.MB("Incorrect values at the beginning of the script", "Error",0)
    nothing() return
  end
  
  local val = reaper.GetExtState("tempo_markers_yannick_reasc_section", "tempo_markers_yan_key")
  if val == "" then
    reaper.MB("No copied tempo markers!", "Error", 0)
    nothing()
  else
  
    reaper.Undo_BeginBlock()
    reaper.PreventUIRefresh(1)
    
    local t_tempo_markers = {}
    
    for s in val:gmatch("[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,") do
      local timepos, bpm, timesig_num, timesig_denom = s:match("([^,]+),([^,]+),([^,]+),([^,]+),[^,]+,")
      if s:match("[^,]+,[^,]+,[^,]+,[^,]+,([^,]+),") == '0' then
        lineartempo = false
      else
        lineartempo = true
      end
      t_tempo_markers[#t_tempo_markers+1] = { 
      tonumber(timepos), tonumber(bpm), tonumber(timesig_num), tonumber(timesig_denom), lineartempo
      }
    end
    
    local count_tempo_markers = reaper.CountTempoTimeSigMarkers(0)
    if count_tempo_markers > 0 then
      for i=count_tempo_markers-1, 0, -1 do
        reaper.DeleteTempoTimeSigMarker(0, i)
      end
    end
    
    
    for i=1, #t_tempo_markers do
      reaper.AddTempoTimeSigMarker(0, 
      t_tempo_markers[i][1], 
      t_tempo_markers[i][2], 
      t_tempo_markers[i][3], 
      t_tempo_markers[i][4], 
      t_tempo_markers[i][5])
    end
    
    reaper.PreventUIRefresh(-1)
    reaper.UpdateArrange()
    reaper.UpdateTimeline()
    
    reaper.Undo_EndBlock('Restore (paste) tempo markers to the project by replacing the old ones', -1)
    if show_warning_window == true then
      reaper.MB("Successfully restored!", "Warning", 0)
    end
  end
