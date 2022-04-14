-- @description Yannick_Insert region between the start and end point (relative to edit cursor)
-- @author Yannick
-- @version 1.2
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   # changed donation link
--   # contact link changed
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14

  ---------------------------------------------------------
    marker_name_for_start_of_region = 'START_FOR_REGION'
    region_name = ''
    user_inputs = true     --- for entering new region name
      window_width = 100   --- user input window width
    
    R = 0       --- Red
    G = 0       --- Green
    B = 0       --- Blue
  ---------------------------------------------------------
  
  function bla() end
  function nothing() reaper.defer(bla) end
  
  if marker_name_for_start_of_region ~= tostring(marker_name_for_start_of_region)
  or region_name ~= tostring(region_name)
  or user_inputs ~= true and user_inputs ~= false
  or not tonumber(window_width) or window_width < 0
  or (not tonumber(R) or not tonumber(G) or not tonumber(B))
  or (R < 0 or G < 0 or B < 0)
  then
    reaper.MB('Incorrect values at the beginning of the script', 'Error', 0)
    nothing() return
  end
  
  local _, num_markers, num_regions = reaper.CountProjectMarkers(0)
  local bool = false
  local count_exist_markers = 0
  for i=0, num_markers+num_regions do
    retval, isrgn, pos, _, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
    if isrgn == false then
      if name == marker_name_for_start_of_region then
        if count_exist_markers == 0 then
          bool = true
          save_num = markrgnindexnumber
          save_pos = pos
          count_exist_markers = count_exist_markers + 1
        else
          reaper.MB('You have several markers with same name for start of region','Error',0)
          nothing() return
        end
      end
    end
  end
  
  local cur_pos = reaper.GetCursorPosition()
  
  if bool == false then
  
    reaper.Undo_BeginBlock()
    
    reaper.AddProjectMarker(0, false, cur_pos, 0, marker_name_for_start_of_region, -1)
    
    reaper.Undo_EndBlock('Insert start marker for region (relative to edit cursor)',-1)
    
  else
  
    if cur_pos == save_pos then
      reaper.MB('Please move edit cursor to a new position','Error',0)
      nothing() return
    end
    
    if user_inputs == true then
      local retval, retvals_csv = reaper.GetUserInputs('Set new region name', 1, 'Set region name:,extrawidth=' .. window_width, region_name)
      if not retval then
        nothing() return
      end
      region_name = retvals_csv
    end
    
    reaper.Undo_BeginBlock()
    reaper.PreventUIRefresh(1)
    
    reaper.DeleteProjectMarker(0, save_num, false)
    if R == 0 and G == 0 and B == 0 then 
      color = 0
    else
      color = reaper.ColorToNative(R,G,B)|0x1000000
    end
    reaper.AddProjectMarker2(0, true, save_pos, cur_pos, region_name, -1, color)
    
    reaper.Undo_EndBlock('Insert region between the start and end point (relative to edit cursor)',-1)
    reaper.PreventUIRefresh(-1)
    
  end
  