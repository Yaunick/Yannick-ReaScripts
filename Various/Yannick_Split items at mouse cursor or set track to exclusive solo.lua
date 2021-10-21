-- @description Yannick_Split items at mouse cursor or set track to exclusive solo
-- @author Yannick
-- @version 1.0
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   Initial release
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU
    
  --------------------------------------------------------------------------------------

    split_item = true
    solo_track = true
  
  --------------------------------------------------------------------------------------
    
  function bla() end function nothing() reaper.defer(bla) end
  
  if (split_item ~= true and split_item ~= false)
  or (solo_track ~= true and solo_track ~= false)
  or (solo_track == false and split_item == false) then
    reaper.MB("Incorrect values at the beginning of the script", "Error", 0)
    nothing() return
  end
  
  local test_SWS = reaper.CF_EnumerateActions 
  if not test_SWS then
    reaper.MB('Please install or update SWS extension', 'Error', 0) 
    nothing() return
  end
  
  local grid_state = reaper.GetToggleCommandState(1157)
  local group_state = reaper.GetToggleCommandState(1156)
  local x, y = reaper.GetMousePosition()
  local Item, take_mo = reaper.GetItemFromPoint( x, y, false)
  local Track, info = reaper.GetTrackFromPoint(x, y)
  
  if Item or Track then
    reaper.Undo_BeginBlock()
    reaper.PreventUIRefresh(1)
  else
    nothing() return
  end
  
  local mouse_position =  reaper.BR_PositionAtMouseCursor(false)
  local grid_mouse_position = reaper.SnapToGrid(0, mouse_position)
  
  if Item then
    if split_item == true then
      if reaper.GetToggleCommandState(1135) == 1
      and reaper.GetToggleCommandState(40576) == 1 then
        reaper.MB('You can not split items until full lock items is disabled','Error',0)
        nothing() return
      end
      local get_group = reaper.GetMediaItemInfo_Value(Item, 'I_GROUPID')
      if get_group == 0 or (get_group > 0 and group_state == 0) then
        if reaper.IsMediaItemSelected(Item) == false then
          if grid_state == 1 then
            reaper.SplitMediaItem(Item, grid_mouse_position)
          elseif grid_state == 0 then
            reaper.SplitMediaItem(Item, mouse_position)
          end
        elseif reaper.IsMediaItemSelected(Item) == true then
          local cur_pos = reaper.GetCursorPosition()
          reaper.SetEditCurPos(grid_mouse_position,false,false)
          reaper.Main_OnCommand(40759, 0)
          reaper.SetEditCurPos(cur_pos,false,false)
        end
      elseif get_group > 0 then
        reaper.Main_OnCommand(40289,0)
        reaper.SetMediaItemSelected(Item, 1)
        local cur_pos = reaper.GetCursorPosition()
        if grid_state == 1 then
          reaper.SetEditCurPos(grid_mouse_position,false,false)
        elseif grid_state == 0 then
          reaper.SetEditCurPos(mouse_position,false,false)
        end  
        reaper.Main_OnCommand(40759, 0)
        reaper.SetEditCurPos(cur_pos,false,false)
      end 
      undo_name = "Split items at mouse cursor"
    end
  else
    if solo_track == true then
      local track_solo_state = reaper.GetMediaTrackInfo_Value(Track, 'I_SOLO')
      reaper.Main_OnCommand(40340,0)
      if track_solo_state == 0 then
        reaper.SetOnlyTrackSelected(Track,1)
        reaper.SetMediaTrackInfo_Value(Track, 'I_SOLO', 2)
      end
      undo_name = "Set track to exclusive solo at mouse cursor"
    end
  end

  reaper.Undo_EndBlock(undo_name, -1)
  reaper.PreventUIRefresh(-1)
  reaper.UpdateArrange()
