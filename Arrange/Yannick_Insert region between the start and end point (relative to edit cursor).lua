-- @description Yannick_Insert region between the start and end point (relative to edit cursor)
-- @author Yannick
-- @version 1.0
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   Initial release
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU

  ---------------------------------------------------------
    marker_name_for_start_of_region = 'START_FOR_REGION'
    region_name = ''
    
    R = 0       --- Red
    G = 0       --- Green
    B = 0       --- Blue
  ---------------------------------------------------------
  
  function bla() end
  function nothing() reaper.defer(bla) end
  
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
  
    local function main()
      reaper.AddProjectMarker(0, false, cur_pos, 0, marker_name_for_start_of_region, -1)
    end
    reaper.defer(main)
    
  else
  
    if cur_pos == save_pos then
      reaper.MB('Please move edit cursor to a new position','Error',0)
      nothing() return
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
  
