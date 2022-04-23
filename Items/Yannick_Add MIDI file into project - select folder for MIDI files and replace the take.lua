-- @description Yannick_Add MIDI file into project - select folder for MIDI files and replace the take
-- @author Yannick
-- @version 1.2
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   + fixed a typo in the code
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14
  
  function bla() end
  function nothing() reaper.defer(bla) end
  
  local test_SWS = reaper.CF_EnumerateActions
  if not test_SWS then
    reaper.MB('Please install or update SWS extension', 'Error', 0) nothing() return
  end
  
  local count_selected_items = reaper.CountSelectedMediaItems(0)
  
  if count_selected_items == 0 then
    reaper.MB('Please select an item!', 'Error', 0)
    nothing() return
  end
  
  for i=0, count_selected_items-1 do
    local item = reaper.GetSelectedMediaItem(0,i)
    local take = reaper.GetActiveTake(item)
    if not take or reaper.TakeIsMIDI(take) == false then
      reaper.MB('Please select only MIDI takes!', 'Error', 0)
      nothing() return
    end
  end
  
  local sl = package.config:sub(1,1)
  
  local retval_path, val_path = reaper.GetProjExtState( 0, 'YANNICK_REASCR_MIDI_folder_PATH__extname', 'YANNICK_REASCR_MIDI_folder_PATH__key')
  if val_path == "" then
    start_path = sl
  else
    start_path = val_path .. sl
  end
  
  ::START::
  local retval, filenameNeed4096 = reaper.GetUserFileNameForRead(start_path, 'Select MIDI file', '.')
  if retval == true then
    local path = filenameNeed4096:match("(.*)[\\/]")
    if path == '' then path = sl end
    local name = filenameNeed4096:match(".*[\\/](.+)")
    if name:lower():reverse():sub(1,4) ~= 'dim.'
    and name:lower():reverse():sub(1,5) ~= 'idim.'
    and name:lower():reverse():sub(1,4) ~= 'rak.'
    then
      reaper.MB("Please select a valid file!", "Error", 0)
      start_path = path .. sl
      goto START
    end
    
    reaper.Undo_BeginBlock()
    reaper.PreventUIRefresh(1)
    
    reaper.SetProjExtState( 0, 'YANNICK_REASCR_MIDI_folder_PATH__extname', 'YANNICK_REASCR_MIDI_folder_PATH__key', path )
    
    local count_takes_more1 = false
    for i=0, count_selected_items-1 do
      local get_sel_item = reaper.GetSelectedMediaItem(0,i)
      local get_act_take = reaper.GetActiveTake(get_sel_item)
      if reaper.CountTakes(get_sel_item) > 1 then
        count_takes_more1 = true
      end
      reaper.BR_SetTakeSourceFromFile( get_act_take, filenameNeed4096, true)
      reaper.GetSetMediaItemTakeInfo_String( get_act_take, 'P_NAME', name, true)
    end
    
    reaper.UpdateArrange()
    if count_takes_more1 == false then
      reaper.Main_OnCommand(42228,0)
    end

    reaper.Undo_EndBlock('Add MIDI file into project - select folder for MIDI files and replace the take',-1)
    reaper.PreventUIRefresh(-1)
  else
    nothing()
  end