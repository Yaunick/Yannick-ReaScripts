-- @description Yannick_Insert item at mouse cursor within a measure (like in Studio One)
-- @author Yannick
-- @version 1.0
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   Initial release
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU

  --------------------------------------------------------
  
    insert_within_time_selection = false
      remove_time_selection_after_item_insertion = true
    
  --------------------------------------------------------
      
  function bla() end function nothing() reaper.defer(bla) end
  
  if insert_within_time_selection ~= false and insert_within_time_selection ~= true
  or remove_time_selection_after_item_insertion ~= false and remove_time_selection_after_item_insertion ~= true
  then
    reaper.MB('Incorrect values at the beginning of the script', 'Error',0)
    nothing() return
  end
  
  local test_SWS = reaper.CF_EnumerateActions
  if not test_SWS then
    reaper.MB('Please install or update SWS extension', 'Error', 0) nothing() return
  end
  
  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)
  
  if reaper.GetToggleCommandState(1013) == 0 then
    local screen_x, screen_y = reaper.GetMousePosition()
    local get_track, _ = reaper.GetTrackFromPoint(screen_x, screen_y)
    if get_track then
      if get_track ~= reaper.GetMasterTrack(0) then
        local _, name = reaper.GetSetMediaTrackInfo_String(get_track, 'P_NAME', 0, false)
        local num_cursor = reaper.BR_PositionAtMouseCursor(true)
        if num_cursor then 
          local QN_start, QN_end = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
          local remove_ts = false
          if QN_end-QN_start > 0 
          and insert_within_time_selection == true 
          and (num_cursor < QN_end and num_cursor > QN_start) then
            remove_ts = true
          else
            local QN_cursor = reaper.TimeMap_timeToQN(num_cursor)
            local _, measure_start, measure_end = reaper.TimeMap_QNToMeasures(0, QN_cursor)
            QN_start = reaper.TimeMap_QNToTime(measure_start)
            QN_end = reaper.TimeMap_QNToTime(measure_end)
          end
          local item_at_cursor = reaper.CreateNewMIDIItemInProj(get_track, QN_start, QN_end, false)
          reaper.SetMediaItemInfo_Value(item_at_cursor, 'B_LOOPSRC', 0)
          local take = reaper.GetActiveTake(item_at_cursor)
          reaper.GetSetMediaItemTakeInfo_String(take, 'P_NAME', name, true)
          reaper.SetMediaItemSelected(item_at_cursor, 1)
          if remove_time_selection_after_item_insertion == true 
          and remove_ts == true then
            reaper.Main_OnCommand(40635,0)
          end
        end
      end
    end
  end
  
  reaper.Undo_EndBlock('Insert item', -1)
  reaper.PreventUIRefresh(-1)