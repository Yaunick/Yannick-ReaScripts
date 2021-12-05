-- @description Yannick_Move last project track to last selected track
-- @author Yannick
-- @version 1.0
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   Initial release
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU
  
  function bla() end
  function nothing() reaper.defer(bla) end
  
  if reaper.CountSelectedTracks(0) == 0 then
    nothing() return
  end
  
  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)
  
  local t = {}
  for i=0, reaper.CountSelectedTracks(0)-1 do
    t[#t+1] = reaper.GetSelectedTrack(0,i)
  end
  
  local last_sel_tr = reaper.GetSelectedTrack(0,reaper.CountSelectedTracks(0)-1)
  local number_last_sel_tr = reaper.GetMediaTrackInfo_Value(last_sel_tr, "IP_TRACKNUMBER")
  local last_poj_tr = reaper.GetTrack(0,reaper.CountTracks(0)-1)
  
  reaper.SetOnlyTrackSelected(last_poj_tr, true)
  reaper.ReorderSelectedTracks(number_last_sel_tr,2)
  
  reaper.Main_OnCommand(40297,0) -- unselect all tracks
  
  for i=1, #t do
    reaper.SetTrackSelected(t[i], true)
  end
  
  reaper.Undo_EndBlock("Move last project track to last selected track", -1)
  reaper.PreventUIRefresh(-1)