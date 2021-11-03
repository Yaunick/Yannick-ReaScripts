-- @description Yannick_Remove (clear) time selection then loop points
-- @author Yannick
-- @version 1.0
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   Initial release
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU

  function main()
    local start_ts, end_ts = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
    local start_lp, end_lp = reaper.GetSet_LoopTimeRange(false, true, 0, 0, false)
    if end_ts - start_ts > 0 then
      reaper.Main_OnCommand(40635,0)
    elseif end_lp - start_lp > 0 then
      reaper.Main_OnCommand(40624,0)
    end
  end
  
  reaper.defer(main)
  