-- @description Yannick_Add MIDI file into project - switch previous MIDI take from recent folder
-- @author Yannick
-- @version 1.2
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   + some code improvements
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14
  
  function bla() end
  function nothing() reaper.defer(bla) end
  
  local test_SWS = reaper.CF_EnumerateActions
  if not test_SWS then
    reaper.MB('Please install or update SWS extension', 'Error', 0) 
    nothing() return
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
  
  function load_midi_to_selected_items(count_sel_its, input_path, input_name)
    local count_takes_more1 = false
    for i=0, count_sel_its-1 do
      local get_sel_item = reaper.GetSelectedMediaItem(0,i)
      local get_act_take = reaper.GetActiveTake(get_sel_item)
      if reaper.CountTakes(get_sel_item) > 1 then
        count_takes_more1 = true
      end
      reaper.BR_SetTakeSourceFromFile( get_act_take, input_path, true)
      reaper.GetSetMediaItemTakeInfo_String( get_act_take, 'P_NAME', input_name, true)
    end
    reaper.UpdateArrange()
    if count_takes_more1 == false then
      reaper.Main_OnCommand(42228,0)
    end
  end
  
  function open_folder()
    local start_path = sl
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
      
      load_midi_to_selected_items(count_selected_items, filenameNeed4096, name)
      
      reaper.Undo_EndBlock('Select folder for MIDI files',-1)
      reaper.PreventUIRefresh(-1)
    end
  end
  
  local retval_path, val_path = reaper.GetProjExtState( 0, 'YANNICK_REASCR_MIDI_folder_PATH__extname', 'YANNICK_REASCR_MIDI_folder_PATH__key')
  if val_path == "" then
    open_folder()
    nothing() return
  end
  
  local file_list = {}
  local bool = false
  local i = 0
  while bool == false do
    local str = reaper.EnumerateFiles( val_path, i)
    if str == nil then
      bool = true
    else
      if str:lower():reverse():sub(1,4) == 'dim.'
      or str:lower():reverse():sub(1,5) == 'idim.'
      or str:lower():reverse():sub(1,4) == 'rak.'
      then
        file_list[#file_list+1] =  str
      end
      i = i + 1
    end
  end
  
  if #file_list == 0 then
    open_folder()
    nothing() return
  end
  
  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)
  
  local take = reaper.GetActiveTake( reaper.GetSelectedMediaItem(0,0) )
  local filename = reaper.GetTakeName(take)
  for i=1, #file_list do
    if file_list[i] == filename then
      if i == 1 then
        save_source_name = file_list[#file_list]
      else
        save_source_name = file_list[i-1]
      end
      break
    end
  end
  
  if save_source_name == nil then 
    save_source_name = file_list[1] 
  end
  
  load_midi_to_selected_items(count_selected_items, val_path .. sl .. save_source_name, save_source_name)
  
  reaper.Undo_EndBlock('Add MIDI file into project - switch previous MIDI take from recent folder',-1)
  reaper.PreventUIRefresh(-1)
