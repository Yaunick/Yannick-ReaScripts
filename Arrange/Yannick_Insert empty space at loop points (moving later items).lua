-- @description Yannick_Insert empty space at loop points (moving later items)
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

  function bla() end
  function nothing() reaper.defer(bla) end

  local save_ts_start, save_ts_end = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
  local lp_start, lp_end = reaper.GetSet_LoopTimeRange(false, true, 0, 0, false)
  
  if lp_end - lp_start == 0 then
    reaper.MB('No loop points active', 'Error', 0)
    nothing() return
  end
  
  reaper.GetSet_LoopTimeRange(true, false, lp_start, lp_end, false)
  
  reaper.Main_OnCommand(40200,0)
  
  reaper.GetSet_LoopTimeRange(true, false, save_ts_start, save_ts_end, false)
  
  reaper.Undo_EndBlock('Insert empty space at loop points (moving later items)',-1)
  reaper.PreventUIRefresh(-1)
  