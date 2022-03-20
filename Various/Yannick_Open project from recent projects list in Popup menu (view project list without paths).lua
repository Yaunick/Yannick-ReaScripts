-- @description Yannick_Open project from recent projects list in Popup menu (view project list without paths)
-- @author Yannick
-- @version 1.8
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   + fixed some bugs
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU
  
  -----------User settings-------------------------
  
    menu_position_x = -60
    menu_position_y = 25
    
  -------------------------------------------------
  
  function bla() end
  function nothing() reaper.defer(bla) end
  
  local filename = reaper.get_ini_file()
  if reaper.file_exists(filename) == false then
    reaper.MB("No reaper.ini file!", "Error", 0)
    nothing() return
  end
  local table_proj = {}
  local projects_not_found = {}
  
  local filename_read = io.open(filename, 'r')
  for l in filename_read:lines() do
    if l == '[Recent]' then 
      found = true 
    elseif found and l:match('%[.-%]') and l ~= '[Recent]' then
      break
    end
    if found == true then
      if l:match("recent%d+=.*[\\/](.+)") ~= nil then
        if reaper.file_exists(l:match("recent%d+=(.+)")) == true then
          table_proj[#table_proj+1] = { l:match("recent%d+=(.+)"), tonumber(l:match("recent(%d+)=")) }
        else
          projects_not_found[#projects_not_found+1] = { l:match("recent%d+=(.+)"), tonumber(l:match("recent(%d+)=")) }
        end
      end
    end
  end
  
  io.close(filename_read)
  
  if #projects_not_found == 0 and #table_proj == 0 then
    nothing()
  else
    
    function remove_duplicates(input_table)
      local hash = {}
      local res = {}
      
      for _,v in ipairs(input_table) do
        if (not hash[v]) then
          res[#res+1] = v
          hash[v] = true
        end
      end
      return res
    end
    
    ----------------------------------------------------------------------------
    new_table_proj_names_concat = ""
    if #table_proj > 0 then
      table.sort(table_proj, function(a,b) return b[2] < a[2] end)
      
      one_table_proj = {}
      
      for i=1, #table_proj do
        one_table_proj[#one_table_proj+1] = table_proj[i][1]
      end
      
      table_proj = remove_duplicates(one_table_proj)
      
      new_table_proj_names = {}
      
      table.insert(table_proj, 1, ">New project tab...")
      
      for i=2, #table_proj do
        table_proj[#table_proj+1] = table_proj[i]
      end
      
      table.insert(table_proj, (#table_proj-1)/2+2, "<|")
      
      for i=1, #table_proj do
        if table_proj[i] == ">New project tab..." then
          new_table_str_vsr = ">New project tab..."
        elseif table_proj[i] == "<|" then
          new_table_str_vsr = "<|"
        else
          new_table_str_vsr = table_proj[i]:match(".*[\\/](.+)")
        end
        new_table_proj_names[#new_table_proj_names+1] = new_table_str_vsr .. '|'
      end
      
      new_table_proj_names_concat = table.concat(new_table_proj_names) 
    end
    
    projects_not_found_str = ""
    new_projects_not_found_concat = ""
    if #projects_not_found > 0 then
      table.sort(projects_not_found, function(a,b) return b[2] < a[2] end)
      
      one_projects_not_found = {}
      
      for i=1, #projects_not_found do
        one_projects_not_found[#one_projects_not_found+1] = projects_not_found[i][1]
      end
      
      projects_not_found = remove_duplicates(one_projects_not_found)
      
      new_projects_not_found = {}
      for i=1, #projects_not_found do
        new_projects_not_found[#new_projects_not_found+1] = "#   " .. projects_not_found[i]:match(".*[\\/](.+)") .. '|'
      end
      if #table_proj == 0 then
        projects_not_found_str = "#Projects not found!||"
      else
        projects_not_found_str = "|#Projects not found!||"
      end
      new_projects_not_found_concat = table.concat(new_projects_not_found)
    end
    ----------------------------------------------------------------------------
    
    local x, y = reaper.GetMousePosition()
    gfx.init("Recent projects...",160,4,0,x+menu_position_x,y+menu_position_y)
    local retval = gfx.showmenu(
    new_table_proj_names_concat
    .. projects_not_found_str 
    .. new_projects_not_found_concat
    )
    
    if retval == 0 then
      nothing()
    else
      gfx.quit()
      if retval < (#new_table_proj_names-1)/2 then
        reaper.Main_OnCommand(41929,0)
        retval = retval + 1
      else
        retval = retval + 2
      end
      reaper.Main_openProject(table_proj[retval])
    end
  end