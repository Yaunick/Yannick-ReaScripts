-- @description Yannick_Erase notes along with moving edit cursor (like Back in Studio One)
-- @author Yannick
-- @version 1.1
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   # changed donation link
--   # contact link changed
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14

  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)
   
    local midieditor = reaper.MIDIEditor_GetActive()
    local take = reaper.MIDIEditor_GetTake( midieditor )
    if take then
      local _, notecnt, _, _ = reaper.MIDI_CountEvts( take )
      if notecnt > 0 then
        for i=notecnt-1, 0, -1 do
          local _,_,_,startppqpos_last,_,_,_,_ = reaper.MIDI_GetNote( take, i)
          local time_1 = reaper.MIDI_GetPPQPosFromProjTime( take, reaper.GetCursorPosition())
          if time_1 > startppqpos_last then
            reaper.MIDI_DeleteNote( take, i )
            local _,_,_,startppqpos,_,_,_,_ = reaper.MIDI_GetNote( take, i-1)
            if startppqpos_last > startppqpos or i == 0 then 
              local time_2 = reaper.MIDI_GetProjTimeFromPPQPos( take, startppqpos_last )
              reaper.SetEditCurPos(time_2,0,0)
              break 
            end
          end
        end
      end
    end
    
    local undo_item = reaper.GetMediaItem(0,0)
    local is_undo_item_sel = reaper.IsMediaItemSelected(undo_item)
    reaper.SetMediaItemSelected(undo_item,is_undo_item_sel)
   
  reaper.PreventUIRefresh(-1)
  reaper.Undo_EndBlock('Back notes',-1)

