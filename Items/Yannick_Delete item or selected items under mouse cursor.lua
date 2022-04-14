-- @description Yannick_Delete item or selected items under mouse cursor
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
  
  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)
  
  local x, y = reaper.GetMousePosition()
  local Item, take = reaper.GetItemFromPoint( x, y, true)
  
  if Item then
    if reaper.IsMediaItemSelected(Item) == false then
      local t={}
      if reaper.CountSelectedMediaItems(0) > 0 then
        for i=1, reaper.CountSelectedMediaItems(0) do
          t[i] = reaper.GetSelectedMediaItem(0,i-1)
        end
      end
      reaper.Main_OnCommand(40289,0)
      reaper.SetMediaItemSelected(Item, true)
      reaper.Main_OnCommand(40006,0)
      if #t > 0 then
        for i=1, #t do
          reaper.SetMediaItemSelected(t[i], true)
        end
      end
    elseif reaper.IsMediaItemSelected(Item) == true then
      reaper.Main_OnCommand(40006,0)
    end
  else
    nothing()
  end
    
  reaper.UpdateArrange()
  reaper.PreventUIRefresh(-1)
  reaper.Undo_EndBlock("Delete item or selected items under mouse cursor",-1)

