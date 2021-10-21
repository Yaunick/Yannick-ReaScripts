-- @description Yannick_Warn about all items that have the offline takes.lua
-- @author Yannick
-- @version 1.0
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   Initial release
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU

  function bla() end function nothing() reaper.defer(bla) end
  
  local test_SWS = reaper.CF_GetMediaSourceOnline --function added in 2.10 SWS
  if not test_SWS then
    reaper.MB('Please install or update SWS extension', 'Error', 0) nothing() return
  end

  reaper.PreventUIRefresh(1)
  boolen = false
  for i=0, reaper.CountMediaItems(0)-1 do
    local item = reaper.GetMediaItem(0,i)
    local j = 0
    local cnt_takes = reaper.CountTakes(item)
    while j <= cnt_takes-1 do
      local take = reaper.GetTake(item,j)
      local source =  reaper.GetMediaItemTake_Source(take)
      if reaper.CF_GetMediaSourceOnline(source) == false then
        reaper.PreventUIRefresh(1)
        if boolen == false then
          if reaper.CountSelectedMediaItems(0) > 0 then
            reaper.Main_OnCommand(40289,0) -- unselect all items
          end
        end
        reaper.SetMediaItemSelected(item, true)
        reaper.UpdateItemInProject(item)
        reaper.PreventUIRefresh(-1)
        boolen = true
        j = cnt_takes-1
      end
      j = j + 1
    end
  end
  reaper.PreventUIRefresh(-1)
  
  if boolen == true then
    reaper.MB('You have some offline takes! Look at the selected items', 'Warning',0)
  else
    reaper.MB('You do not have offline takes :)', 'Warning',0)
  end
  
  