-- @description Yannick_Copy all existed plugins names to the clipboard
-- @author Yannick
-- @version 1.5
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   # changed donation link
--   # contact link changed
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14

  -----------------------------------------------------
    show_window = true
  -----------------------------------------------------

  function bla() end
  function nothing() reaper.defer(bla) end
  
  if show_window ~= true and show_window ~= false then
    reaper.MB('Incorrect values at the beginning of the script', 'Error', 0)
    nothing() return
  end
  
  local test_SWS = reaper.CF_EnumerateActions
  if not test_SWS then
    reaper.MB('Please install or update SWS extension', 'Error', 0) nothing() return
  end
  
  local path = reaper.GetResourcePath() .. "/reaper-vstplugins64.ini"
  local js_path = reaper.GetResourcePath() .. "/reaper-jsfx.ini"
  if reaper.file_exists(path) == false or reaper.file_exists(js_path) == false then
    reaper.MB("You don't have the following files - 'reaper-vstplugins64.ini' or 'reaper-jsfx.ini'\n\n" ..
    "Install third party VST plugins and open FX Browser to generate these files", "Error", 0)
    nothing() return
  end
  
  local t_vst, t_vsti, t_js = {}, {}, {}
  
  local file = io.open(path, 'r')
  for l in file:lines() do
    if l:find("!!!VSTi") then
      local vst_i_str = l:match("[^,]+,[^,]+,(.+)!!!VSTi")
      if vst_i_str ~= nil and vst_i_str ~= "<SHELL>" then
        t_vsti[#t_vsti+1] = '"' .. vst_i_str .. '",' .. '\n'
      end
    else
      local vst_str = l:match("[^,]+,[^,]+,(.+)")
      if vst_str ~= nil and vst_str ~= "<SHELL>" then
        t_vst[#t_vst+1] = '"' .. vst_str .. '",' .. '\n'
      end
    end
  end
  io.close(file)
  
  local js_file = io.open(js_path, 'r')
  for l in js_file:lines() do
    if l:find('"JS: ') then
      if l:find(".txt") then
        test_js_str = l:match('"JS: (.+)')
      elseif not l:find("/") then
        test_js_str = l:match('NAME (.+) "JS:')
      else
        test_js_str = l:match('([^/]+) "JS:')
      end
      if test_js_str:sub( test_js_str:len() ) == '"' then
        test_js_str = test_js_str:sub(1, test_js_str:len()-1)
      end
      if test_js_str:sub( 1, 1 ) == '"' then
        test_js_str = test_js_str:sub(2, test_js_str:len())
      end
      t_js[#t_js+1] = '"' .. test_js_str .. '",' .. '\n'
    end
  end
  io.close(js_file)
  
  local insrt_str = 
  "=============================================================================================\n" ..
  "    All INSTRUMENTS             All INSTRUMENTS             All INSTRUMENTS\n" .. 
  "=============================================================================================\n\n"
  
  local vst_str = 
  "=============================================================================================\n" ..
  "    All VST FX             All VST FX             All VST FX             All VST FX\n" ..
  "=============================================================================================\n\n"
  
  local js_str = 
  "=============================================================================================\n" ..
  "    All JS-fx              All JS-fs              All JS-fx              All JS-fx\n" ..
  "=============================================================================================\n\n"
  
  if #t_vsti > 0 then
    table.insert(t_vsti, 1, insrt_str)
  end
  if #t_vst > 0 then
    table.insert(t_vst, 1, vst_str)
  end
  if #t_js > 0 then
    table.insert(t_js, 1, js_str)
  end
  
  local new_str = table.concat(t_vst) .. '\n' .. table.concat(t_vsti) .. '\n' .. table.concat(t_js)
  
  reaper.CF_SetClipboard(new_str)
  
  if show_window == true then
    reaper.MB("Success! All plugins names have been copied to the clipboard!\n" .. 
    '\nPaste the text into a text editor to see the list of names ("Notepad++" for example)\n' ..
    '\nNote! - JS plugin names are not always correct, try adding "JS:" to the beginning of the name or omitting parts of the name', "Warning", 0)
  end

  nothing()