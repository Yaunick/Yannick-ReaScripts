-- @description Yannick_Delete all regions that have start and end points within time selection
-- @author Yannick
-- @version 1.0
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   + initial release
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14
  
  -----------------------------------------------------------
  
    is_loop_points = false      --- false = time selection
    
  -----------------------------------------------------------
  
  function bla() end 
  function nothing() reaper.defer(bla) end
  
  local get_start, get_end = reaper.GetSet_LoopTimeRange2(0,false,is_loop_points,0,0,false)
  if get_end-get_start == 0 then
    nothing() return
  end
  local retval, num_markers, num_regions = reaper.CountProjectMarkers(0)
  if num_regions == 0 then
    nothing() return 
  end
  
  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)
  
  local t_regions = {}

  for i=0, num_markers + num_regions - 1 do
    local retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers2(0, i)
    if isrgn == true then
      if pos >= get_start and rgnend <= get_end then
        t_regions[#t_regions+1] = markrgnindexnumber
      end
    end
  end
  
  for i=1, #t_regions do
    reaper.DeleteProjectMarker(0, t_regions[i], true)
  end

  reaper.UpdateTimeline()
  reaper.Undo_EndBlock("Delete all regions that have start and end points within time selection", -1)
  reaper.PreventUIRefresh(-1)