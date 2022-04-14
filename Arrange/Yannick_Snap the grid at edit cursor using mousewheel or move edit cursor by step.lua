-- @description Yannick_Snap the grid at edit cursor using mousewheel or move edit cursor by step
-- @author Yannick
-- @version 1.2
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   # changed donation link
--   # contact link changed
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14
    
  ---------------------- 
  division_step = 1
  ----------------------
   
  function bla() end
  function nothing()
    reaper.defer(bla)
  end
  
  local test_SWS = reaper.CF_EnumerateActions 
  if not test_SWS then
    reaper.MB('Please install or update SWS extension', 'Error', 0) nothing() return
  end
  
  if reaper.CountSelectedMediaItems(0) == 0 then
    reaper.MB('No items. Please select one item','Error',0)
    nothing() return
  elseif reaper.CountSelectedMediaItems(0) > 1 then
    reaper.MB('The script works only for one item. Glue several selected items if needed','Error',0)
    nothing() return
  end
  
  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)
  
  if reaper.GetToggleCommandState(reaper.NamedCommandLookup("_SWS_AWTBASETIME")) == 0 then
    reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_AWTBASETIME"),0)
  end
  
  is_new_value,filename,sectionID,cmdID,mode,resolution,val = reaper.get_action_context()

  local _, division, _, _ = reaper.GetSetProjectGrid(0, false, 0, 0, 0)
  reaper.GetSetProjectGrid(0, true, division_step, 0, 0)
  
  local item = reaper.GetSelectedMediaItem(0,0)
  local item_start = reaper.GetMediaItemInfo_Value(item,'D_POSITION')
  local item_end = item_start + reaper.GetMediaItemInfo_Value(item,'D_LENGTH')

  
  local take = reaper.GetActiveTake(item)
  sa_c = reaper.GetCursorPosition()
  reaper.SetEditCurPos(item_start,false,false)
  reaper.Main_OnCommand(42394,0) --- go to next take marker
  save_cur = reaper.GetCursorPosition()
  measure = save_cur - item_start 
  reaper.SetEditCurPos(sa_c,false,false)
  
 
  if reaper.GetNumTakeMarkers(take) == 1 then
    local get_cr_ps = reaper.GetCursorPosition()
    if val > 0 then
      reaper.SetEditCurPos(get_cr_ps+measure,true,false)
    else
      if get_cr_ps > 0 then
        reaper.SetEditCurPos(get_cr_ps-0.00026,true,false)
        reaper.Main_OnCommand(reaper.NamedCommandLookup("_BR_MOVE_GRID_TO_EDIT_CUR"),0)
      else
        reaper.Main_OnCommand(42330,0)
      end
    end
  else
    reaper.MB('Please create only one take marker','Error',0)
  end
  
  reaper.GetSetProjectGrid(0, true, division , 0, 0)
  
  reaper.PreventUIRefresh(-1)
  reaper.Undo_EndBlock('Convert selected item stretch markers to project markers', -1)