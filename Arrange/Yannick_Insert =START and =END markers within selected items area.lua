-- @description Yannick_Insert =START and =END markers within selected items area
-- @author Yannick
-- @version 1.1
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   # some code improvements
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14
  
  ---//////---COLOR---\\\\\---
    R = 186   ----Red
    G = 0     ----Green
    B = 0     ----Blue
  ---\\\\\\\\\\||//////////---
  
  function bla() end
  function nothing() reaper.defer(bla) end
  
  if (not tonumber(R) or not tonumber(G) or not tonumber(B))
  or (R < 0 or G < 0 or B < 0)
  then
    reaper.MB('Incorrect values at the beginning of the script', 'Error', 0)
    nothing() return
  end
  
  if reaper.CountSelectedMediaItems(0) == 0 then
    reaper.MB('No items! Please select an item', 'Error', 0)
    nothing() return
  end

  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)
  
  local color = reaper.ColorToNative(R,G,B)|0x1000000
  local start_ts, end_ts = reaper.GetSet_LoopTimeRange( false, false, 0, 0, false)
  local cur_pos = reaper.GetCursorPosition()
  reaper.Main_OnCommand(40290, 0) -- Set TS to selected items
  local new_start_ts, new_end_ts = reaper.GetSet_LoopTimeRange( false, false, 0, 0, false)
  
  local retval, num_markers, num_regions = reaper.CountProjectMarkers(0)
  if num_markers + num_regions > 0 then
    for i=num_markers+num_regions-1, 0, -1  do
      local retval, _, _, _, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
      if name == '=START' or name == '=END' then
        reaper.DeleteProjectMarker( 0, markrgnindexnumber, false)
      end
    end
  end
  
  reaper.AddProjectMarker2(0, false, new_start_ts, 0, '=START', -1, color )
  reaper.AddProjectMarker2(0, false, new_end_ts, 0, '=END', -1, color )
  
  reaper.GetSet_LoopTimeRange( true, false, start_ts, end_ts, false)
  reaper.SetEditCurPos(cur_pos, false, false)
  
  reaper.Undo_BeginBlock('Insert =START and =END markers within selected items area', -1)
  reaper.PreventUIRefresh(-1)
  