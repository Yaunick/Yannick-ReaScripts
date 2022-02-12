-- @description Yannick_Open project from recent projects list in Popup menu (view project list without paths)
-- @author Yannick
-- @version 1.0
-- @about
--   go to the guide https://github.com/Yaunick/Yannick-ReaScripts-Guide/blob/main/Guide%20to%20using%20my%20scripts.md
-- @changelog
--   initial release
-- @contact b.yanushevich@gmail.com
-- @donation https://www.paypal.com/paypalme/yaunick?locale.x=ru_RU
  
  -----------User settings-------------------------
  
    menu_position_x = -60
    menu_position_y = 25
    
  -------------------------------------------------
  
  function bla() end
  function nothing() reaper.defer(bla) end
  
  local str_sep = package.config:sub(1,1)
  
  local filename = reaper.GetResourcePath() .. str_sep .. "reaper.ini"
  local table_proj = {}
  local projects_not_found = {}
  
  for l in io.lines(filename) do
    if string.sub(l,0,6) == "recent" then
      local count = 0
      local count1 = 0
      local find_number = false
      local string_num = ""
      for s in string.gmatch(l, ".") do
        if find_number == false and s == string.match(s,"%d") then
          string_num = string_num .. s
        elseif find_number == false and s == "=" then
          find_number = true
        end
      end
      if reaper.file_exists(l:match("([^=]+)$")) == true then
        table_proj[#table_proj+1] = { l:match("([^=]+)$"), tonumber(string_num) }
      else
        projects_not_found[#projects_not_found+1] = { l:match("([^=]+)$"), tonumber(string_num) }
      end
    end
  end
  
  if #projects_not_found == 0 and #table_proj == 0 then
    nothing()
  else
  
    if #table_proj > 0 then
      table.sort(table_proj, function(a,b) return b[2] < a[2] end)
    end
    if #projects_not_found > 0 then
      table.sort(projects_not_found, function(a,b) return b[2] < a[2] end)
    end
    
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
    if #table_proj > 0 then
      one_table_proj = {}
      
      for i=1, #table_proj do
        one_table_proj[#one_table_proj+1] = table_proj[i][1]
      end
    end
    
    if #projects_not_found > 0 then
      one_projects_not_found = {}
      
      for i=1, #projects_not_found do
        one_projects_not_found[#one_projects_not_found+1] = projects_not_found[i][1]
      end
    end
    
    if #table_proj > 0 then 
      table_proj = remove_duplicates(one_table_proj)
    end
    
    if #projects_not_found > 0 then
      projects_not_found = remove_duplicates(one_projects_not_found)
    end
    ----------------------------------------------------------------------------
    
    local new_table_proj_names = {}
    if #table_proj > 0 then
    
      table.insert(table_proj, 1, ">New project tab...")
      
      for i=2, #table_proj do
        table_proj[#table_proj+1] = table_proj[i]
      end
      
      table.insert(table_proj, (#table_proj-1)/2+2, "<|")
      
      for i=1, #table_proj do
        local new_table_str_vsr = ""
        if table_proj[i] == ">New project tab..." then
          new_table_str_vsr = ">New project tab..."
        elseif table_proj[i] == "<|" then
          new_table_str_vsr = "<|"
        else
          new_table_str_vsr = table_proj[i]:match(".+[\\/](.+)")
        end
        new_table_proj_names[#new_table_proj_names+1] = new_table_str_vsr .. '|'
      end
    end
    
    local new_projects_not_found = {}
    local projects_not_found_str = ""
    if #projects_not_found > 0 then
      for i=1, #projects_not_found do
        new_projects_not_found[#new_projects_not_found+1] = "#   " .. projects_not_found[i]:match(".+[\\/](.+)") .. '|'
      end
      if #table_proj == 0 then
        projects_not_found_str = "#Projects not found!||"
      else
        projects_not_found_str = "|#Projects not found!||"
      end
    end
  
    local x, y = reaper.GetMousePosition()
    gfx.init("Recent projects...",160,4,0,x+menu_position_x,y+menu_position_y)
    local retval = gfx.showmenu(
    table.concat(new_table_proj_names) 
    .. projects_not_found_str 
    .. table.concat(new_projects_not_found)
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
