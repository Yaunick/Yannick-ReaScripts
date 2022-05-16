-- @description Yannick_Open repository folder
-- @author Yannick
-- @version 1.0
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   + initial release
-- @contact yannick-reascripts@yandex.ru
-- @donation https://telegra.ph/How-to-send-me-a-donation-04-14

  function bla() end
  function nothing() reaper.defer(bla) end
  
  local test_SWS = reaper.CF_EnumerateActions
  if not test_SWS then
    reaper.MB('Please install or update SWS extension', 'Error', 0) 
    nothing() return
  end

  local sla = package.config:sub(1,1)
  
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
  
  local resource_path = reaper.GetResourcePath()
  
  local find_path_with_repository = path_exists(resource_path .. sla .. 'Scripts', 'Yannick-ReaScripts' )
  
  if find_path_with_repository == false then
    reaper.MB('Scripts from the repository are missing, or they are in a different folder ' ..
    'Use the ReaPack script manager. Read more in the README.md file', 'Error', 0)
    nothing() return
  end
  
  local script_path = resource_path .. sla .. 'Scripts' .. sla .. 'Yannick-ReaScripts'
  
  reaper.CF_ShellExecute(script_path)
  
  nothing()
  
  