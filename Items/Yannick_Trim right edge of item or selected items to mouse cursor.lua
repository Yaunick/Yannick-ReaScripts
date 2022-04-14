-- @description Yannick_Trim right edge of item or selected items to mouse cursor
-- @author Yannick
-- @version 1.1
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   # changed donation link
--   # contact link changed
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14
  
  function bla() end function nothing() reaper.defer(bla) end  
  
  local screen_x, screen_y = reaper.GetMousePosition()
  local cur_item, _ = reaper.GetItemFromPoint( screen_x, screen_y, false)
  if not cur_item then 
    nothing() return 
  end
  
  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)
  
  local items = reaper.IsMediaItemSelected(cur_item)
  if items == true then
    local save_cursor = reaper.GetCursorPosition()
    reaper.Main_OnCommand(40513, 0)
    reaper.Main_OnCommand(41311, 0)
    reaper.SetEditCurPos(save_cursor, false, false)
  elseif items == false then
    local save_cursor = reaper.GetCursorPosition()
    reaper.Main_OnCommand(40513, 0)
    reaper.Main_OnCommand(41310, 0)
    reaper.SetEditCurPos(save_cursor, false, false)
  else
    nothing()
  end

  reaper.PreventUIRefresh(-1)
  reaper.Undo_EndBlock('Trim right edge of item or selected items to mouse cursor', -1)
