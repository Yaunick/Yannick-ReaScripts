-- @description Yannick_Glue selected items independently
-- @author Yannick
-- @version 1.1
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   # changed donation link
--   # contact link changed
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14

  ------User settigns---Customize this-------------------------------------------------------------------------------
  
    glue_mode = 3     ---- 1 = Glue items
                      ---- 2 = Glue items (auto-increase channel count with take FX)
                      ---- 3 = Glue items, ignoring time selection
                      ---- 4 = Glue items, ignoring time selection (auto-increase channel count with take FX)
                      ---- 5 = Glue items, ignoring time selection, including leading fade-in and trailing fade-out
                      ---- 6 = Glue items, including leading fade-in and trailing fade-out
                      
  -------------------------------------------------------------------------------------------------------------------  
  
  function bla() end function nothing() reaper.defer(bla) end
  
  if glue_mode ~= 1 and glue_mode ~= 2 and glue_mode ~= 3 
  and glue_mode ~= 4 and glue_mode ~= 5 and glue_mode ~= 6
  then
    reaper.MB('Incorrect value for "glue_mode" parameter. Look at the beginning of the script', 'Error', 0)
    nothing() return
  end
  
  if reaper.CountSelectedMediaItems(0) == 0 then
    reaper.MB('No items. Please select an item','Error',0)
    nothing() return
  end
  
  if glue_mode == 1 then
    glue_items = 41588
  elseif glue_mode == 2 then
    glue_items = 42009
  elseif glue_mode == 3 then
    glue_items = 40362
  elseif glue_mode == 4 then
    glue_items = 42008
  elseif glue_mode == 5 then
    glue_items = 40257
  elseif glue_mode == 6 then
    glue_items = 40606
  end

  reaper.PreventUIRefresh(1)
  reaper.Undo_BeginBlock()
  
  local t_one = {}
  for i=0,reaper.CountSelectedMediaItems(0)-1 do
    t_one[i+1] = reaper.GetSelectedMediaItem(0,i)
  end
   
  local t_two = {} 
  for i=1, #t_one  do
    reaper.Main_OnCommand(40289,0)
    reaper.SetMediaItemSelected(t_one[i],true)
    reaper.Main_OnCommand(glue_items,0)
    t_two[i] = reaper.GetSelectedMediaItem(0,0)
  end
  
  for i=1, #t_two-1 do
    reaper.SetMediaItemSelected(t_two[i],true)
  end
  
  reaper.PreventUIRefresh(-1)
  reaper.Undo_EndBlock('Glue selected items independently',-1)