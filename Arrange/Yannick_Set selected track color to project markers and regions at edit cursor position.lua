-- @description Yannick_Set selected track color to project markers and regions at edit cursor position
-- @author Yannick
-- @version 1.3
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   # changed donation link
--   # contact link changed
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14

  --------------------------------------------------------
    
    set_color_to_markers = true
    set_color_to_regions = true
      detect_the_regions_only_at_the_starting_point = true
  
  --------------------------------------------------------
  
  function bla() end
  function nothing() reaper.defer(bla) end
  
  if (set_color_to_markers ~= true and set_color_to_markers ~= false)
  or (set_color_to_regions ~= true and set_color_to_regions ~= false)
  or (set_color_to_markers == false and set_color_to_regions == false)
  or (detect_the_regions_only_at_the_starting_point ~= true and detect_the_regions_only_at_the_starting_point ~= false)
  then
    reaper.MB('Incorrect values at the beginning of the script', 'Error', 0)
    nothing() return
  end
  
  if reaper.CountSelectedTracks(0) ~= 1 then
    reaper.MB('Please select only one track','Error',0)
    nothing() return
  end
  
  local retval, num_markers, num_regions = reaper.CountProjectMarkers(0)
  if num_regions+num_markers == 0 then
    reaper.MB('No regions and project markers in this project', 'Error', 0)
    nothing() return
  end
  
  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)
  
  local track = reaper.GetSelectedTrack(0,0)
  local track_color =  reaper.GetTrackColor(track)
  local cur_pos = reaper.GetCursorPosition()
  
  for i=0, num_markers+num_regions-1 do
    local retval2, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
    if isrgn == true then
      if set_color_to_regions == true then
        if detect_the_regions_only_at_the_starting_point == false then
          if cur_pos >= pos and cur_pos <= rgnend then
            reaper.SetProjectMarker3(0, markrgnindexnumber, isrgn, pos, rgnend, name, track_color)
          end
        else
          if cur_pos == pos then
            reaper.SetProjectMarker3(0, markrgnindexnumber, isrgn, pos, rgnend, name, track_color)
          end
        end
      end
    else
      if set_color_to_markers == true then
        if cur_pos == pos then
          reaper.SetProjectMarker3(0, markrgnindexnumber, isrgn, pos, rgnend, name, track_color)
        end
      end
    end
  end
  
  reaper.UpdateArrange()
  reaper.PreventUIRefresh(-1)
  reaper.Undo_EndBlock('Set selected track color to project markers and regions at edit cursor position',-1)
  