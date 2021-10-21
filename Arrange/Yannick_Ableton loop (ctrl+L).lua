-- @description Yannick_Ableton loop (ctrl+L)
-- @author Yannick
-- @version 1.0
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   Initial release
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU

  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)
  
  local start_loop, end_loop = reaper.GetSet_LoopTimeRange(false, true, 0, 0, 0)
  local count_items = reaper.CountSelectedMediaItems(0)

  local cur_pos = reaper.GetCursorPosition()
  if count_items > 0 then
    reaper.Main_OnCommand(41173,0) -- cursor to start of items
  end
  local item_start = reaper.GetCursorPosition()
  if count_items > 0 then
    reaper.Main_OnCommand(41173,0) -- cursor to start of items
  end
  reaper.Main_OnCommand(41174,0) -- cursor to end of items
  local item_end = reaper.GetCursorPosition()
  reaper.SetEditCurPos(cur_pos,0,0)

  if (item_start ~= start_loop or item_end ~= end_loop or start_loop-end_loop == 0) and count_items > 0 then
    reaper.Main_OnCommand(41039,0) -- set loop points
    reaper.GetSetRepeat(1)  
  elseif reaper.GetSetRepeat(-1) == 0 then
    reaper.GetSetRepeat(1)
  elseif reaper.GetSetRepeat(-1) == 1 then
    reaper.GetSetRepeat(0)
  end
  
  reaper.Undo_EndBlock("Toggle loop and repeat selected items", -1)
  reaper.PreventUIRefresh(-1)
