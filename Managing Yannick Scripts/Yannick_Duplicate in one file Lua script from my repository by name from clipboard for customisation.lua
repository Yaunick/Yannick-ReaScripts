-- @description Yannick_Duplicate in one file Lua script from my repository by name from clipboard for customisation
-- @author Yannick
-- @version 1.0
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   + initial release
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14
  
  ---------------------------------------------------------------------------------
  
    show_warning_window = true
  
  ---------------------------------------------------------------------------------
  
  function bla() end
  function nothing() reaper.defer(bla) end
  
  if show_warning_window ~= true and show_warning_window ~= false then
    reaper.MB('Incorrect values at the beginning of the script', 'Error', 0) 
    nothing() return
  end
  
  local test_SWS = reaper.CF_EnumerateActions
  if not test_SWS then
    reaper.MB('Please install or update SWS extension', 'Error', 0) 
    nothing() return
  end
  
  local script_name = 'Yannick_Duplicate in one file Lua script from my repository by name from clipboard for customisation'
  local resource_path = reaper.GetResourcePath()
  
  local sla = package.config:sub(1,1)
  
  local _,filename_scr,_,_,_,_,_ = reaper.get_action_context()
  if filename_scr ~= resource_path .. sla .. 'Scripts' .. sla .. 'Yannick-ReaScripts' .. sla .. 'Managing Yannick Scripts' 
  .. sla .. script_name .. '.lua' 
  then
    reaper.MB('Please install this script in the same directory as from my repository (to avoid problems). ' ..
    'To do this, use the ReaPack script manager. Read more in the README.md file', 
    'Error', 0) 
    nothing() return
  end
  
  --- function path exists --------------------------------------------------------------------------------------------------
  
  function path_exists(input_path, input_path_name)
    local o = 0
    local is_path_exists = false
    repeat
      local str_find_p = reaper.EnumerateSubdirectories( input_path, o )
      if str_find_p ~= nil then
        if str_find_p == input_path_name then
          is_path_exists = true
        end
      end
      o = o + 1
    until str_find_p == nil
    return is_path_exists
  end
  
  --- find global repository directory -----------------------------------------------------------------------------------------
  
  local find_path_with_repository = path_exists(resource_path .. sla .. 'Scripts', 'Yannick-ReaScripts' )
  
  if find_path_with_repository == false then
    reaper.MB('Scripts from the repository are missing, or they are in a different folder ' ..
    'Use the ReaPack script manager. Read more in the README.md file', 'Error', 0)
    nothing() return
  end
  
  local path = resource_path .. sla .. 'Scripts' .. sla .. 'Yannick-ReaScripts'
  
  --- get clipboard ------------------------------------------------------------------------------------------------------------
  
  local text_from_clipboard = reaper.CF_GetClipboard()
  if text_from_clipboard == '' then
    reaper.MB('You have an empty clipboard!', 'Error', 0)
    nothing() return
  end
  
  --- remove spaces from the text ----------------------------------------------------------------------------------------------
  
  local count_l_space = 0
  for s in text_from_clipboard:gmatch(".") do
    if s == ' ' then
      count_l_space = count_l_space + 1
    else
      break
    end
  end
  
  local count_r_space = 0
  for s in text_from_clipboard:gmatch(".") do
    if s == ' ' then
      count_r_space = count_r_space + 1
    else
      count_r_space = 0
    end
  end
  
  local text_from_clipboard = text_from_clipboard:sub(count_l_space + 1, text_from_clipboard:len() - count_r_space )
  
  
  --- find global directory for duplicates -------------------------------------------------------------------------------------
  
  local find_path_with_duplicates = path_exists(resource_path .. sla .. 'Scripts', 'Yannick-ReaScripts_Duplicates')
  
  --- create global directory for duplicates if not find -----------------------------------------------------------------------
  
  if find_path_with_duplicates == false then
    os.execute("mkdir " .. resource_path .. sla ..
    'Scripts' .. sla .. 'Yannick-ReaScripts_Duplicates' )
  end
  
  --- get paths ----------------------------------------------------------------------------------------------------------------
  
  local path_for_scripts = resource_path .. sla .. 'Scripts' .. sla .. 'Yannick-ReaScripts_Duplicates'
  
  --- if 'script: ' at the beginning of the name, clear 'script: ' from the name -----------------------------------------------
  
  if text_from_clipboard:lower():sub(1,8) == 'script: ' then
    text_from_clipboard = text_from_clipboard:sub(9, text_from_clipboard:len())
  end
  
  --- if no '.lua' at the end of the name, add '.lua' to the end of the name ---------------------------------------------------
  if text_from_clipboard:lower():reverse():sub(1,4) ~= 'aul.' then
    text_from_clipboard = text_from_clipboard .. '.lua'
  end
  
  --- find all valide paths from main repository -------------------------------------------------------------------------------
  
  local paths_table = {}
  local t = 0
  repeat
    local str = reaper.EnumerateSubdirectories( path, t )
    if str ~= nil then
      if str ~= "Scripts with config files"
      and str ~= "Managing Yannick Scripts" 
      and str ~= "Python scripts"
      then
        paths_table[#paths_table+1] = { path .. sla .. str, str }
      end
    end
    t = t + 1
  until str == nil
  
  --- find script by clipboard name --------------------------------------------------------------------------------------------
  
  local section = 0
  for i=1, #paths_table do
    local j = 0
    repeat
      local str_file = reaper.EnumerateFiles( paths_table[i][1], j)
      if str_file ~= nil then
        if str_file == text_from_clipboard then
          find_script_path = paths_table[i][1] .. sla .. str_file
          if paths_table[i][2] == 'MIDI Editor' then
            section = 32060
          elseif paths_table[i][2] == 'Media Explorer' then
            section = 32063
          end
        end
      end
      j = j + 1
    until str_file == nil
  end
  
  --- if not find script then stop script --------------------------------------------------------------------------------------
  
  if find_script_path == nil then
    reaper.MB('Script by this name not found or it is not supported for copying', 'Error', 0)
    nothing() return
  end
  
  --- if no "Yannick" script then stop script ----------------------------------------------------------------------------------
  
  if text_from_clipboard:sub(1,8) ~= 'Yannick_'
  then
    reaper.MB('This script is 100% not from the Yannick-ReaScripts repository or the script name has been changed', 'Error', 0)
    nothing() return
  end
  
  --- copy script text ---------------------------------------------------------------------------------------------------------
  
  copy_f = io.open(find_script_path, "r")
  copy_f_table = {}
  
  for string_f in copy_f:lines() do
    copy_f_table[#copy_f_table+1] = string_f .. '\n'
  end
  
  copy_f:close()
  
  --- format string ------------------------------------------------------------------------------------------------------------
  
  local t_text_from_clipboard_2 = {}
  for s in text_from_clipboard:gmatch('.') do
    if s == ' ' then
      strr = '_'
    else
      strr = s
    end
    t_text_from_clipboard_2[#t_text_from_clipboard_2+1] = strr
  end
  
  text_from_clipboard_sl = table.concat(t_text_from_clipboard_2)
  
  --- create new folder by script name -----------------------------------------------------------------------------------------
  
  local find_path_with_duplicates_from_folder = path_exists(path_for_scripts, text_from_clipboard_sl:match('(.+)[.]lua'))
  
  --- create global directory for duplicates if not find ----------------------------------------------------------------------- 
  
  if find_path_with_duplicates_from_folder == false then
    os.execute("mkdir " .. path_for_scripts .. sla .. text_from_clipboard_sl:match('Yannick_(.+)[.]lua') )
  end
  
  local path_for_scripts = path_for_scripts .. sla .. text_from_clipboard_sl:match('Yannick_(.+)[.]lua')
  
  --- find duplicate number ----------------------------------------------------------------------------------------------------
  
  local f = 0
  local count = 2
  local text_from_clipboard = text_from_clipboard:match('(.+)[.]lua') .. '_COPY-1.lua'
  repeat
    ::START::
    local str_duplicate_number = reaper.EnumerateFiles(path_for_scripts, f )
    if str_duplicate_number ~= nil then
      if str_duplicate_number == text_from_clipboard then
        text_from_clipboard = str_duplicate_number:gsub('_COPY[-]%d+[.]lua', '_COPY-' .. count .. '.lua')
        count = count + 1
        f = 0
        goto START
      end
    end
    f = f + 1
  until str_duplicate_number == nil
  
  --- create new script ---------------------------------------------------------------------------------------------------------
  
  f = io.open(path_for_scripts .. sla .. text_from_clipboard, "w")
  f:write(table.concat(copy_f_table))
  f:close()
  
  --- add reascript -------------------------------------------------------------------------------------------------------------
  
  reaper.AddRemoveReaScript(true, section, path_for_scripts .. sla .. text_from_clipboard, true)
  
  --- warning text --------------------------------------------------------------------------------------------------------------
  
  if show_warning_window == true then
    reaper.MB('Success!\n\nScript copied, generated name:\n\n' .. '"' .. text_from_clipboard .. '"', 'Warning', 0)
  end
  nothing()