

-- vim.g.gf_xcld_expr = "build ./build.sh temp/file file file3"
vim.g.gf_xcld_expr = "build .git"

-- You could probably cache the string this builds and just rebuild it when the
-- old gf_xcld_expr doesn't match the current gf_xcld_expr to avoid rerunning
-- this needlessly
local function exclude_expr()

    local find_expr = "\\("

    local excluded_files = vim.split(vim.g.gf_xcld_expr, ' ')

    for i, excluded_file in ipairs(excluded_files) do
        if excluded_file:find('/') then
            find_expr = find_expr .. " -path " .. excluded_file
        else
            find_expr = find_expr .. " -name " .. excluded_file
        end

        if i ~= #excluded_files then
            find_expr = find_expr .. " -o"
        end
    end

    return find_expr .. " \\) -prune -o "
end

local function file_exists(filename)
    local file = io.open(filename, "r")
    if (file) then file:close() return true end
    return false
end

local function gf_wont_callback()

    -- Expand twice since the expanded <cfile> might contain unexpanded symbols like `~`
    local cfile = vim.fn.expand(vim.fn.expand("<cfile>"))

    if file_exists(cfile) then
        -- Replace % with \% since :edit will expand it
        vim.cmd("edit " .. cfile:gsub("%%", "\\%%"))
        return
    end

    local cwd = ""

    -- Aware of your terminal buffers' cwd
    local pid = vim.b.terminal_job_pid
    if pid ~= nil then
        local cwd_cmd = "readlink -e /proc/" .. pid .. "/cwd"
        cwd = vim.fn.system(cwd_cmd):sub(1, -2)
    else
        cwd = vim.loop.cwd() or ""
    end

    local abs_file_path = cwd .. "/" .. cfile

    --[[
    -- BUG:
    --  When you are hovering over the word Makefile and if you are in folder1
    --  and want to open folder1/folder2/Makefile but there is a
    --  folder1/Makefile it will open that instead
    --]]
    if file_exists(abs_file_path) then
        vim.cmd("edit " .. abs_file_path)
        return
    end

    -- Add a way to specify which files to ignore like build directories and
    -- git folders

    print("gf_wont_callback: not a complete path. SEARCHING " .. cwd)

    local find_cmd = ""

    if cfile:find('/') then
        find_cmd = "find " .. cwd .. exclude_expr() .. " -path '*" .. cfile .. "*'"
    else
        find_cmd = "find " .. cwd .. exclude_expr() .. " -name " .. cfile
    end

    find_cmd = find_cmd .. " 2> /dev/null"

    local find_stdout = vim.fn.system(find_cmd)

    local paths = vim.split(find_stdout, "\n")

    -- Exit if empty
    if #paths == 1 then
        print("gf_wont_callback: no file found in " .. cwd)
        return
    end

    -- If there was only one result
    if #paths == 2 then
        vim.cmd("edit " .. paths[1])
        return
    end

    local qf_items = {}

    for i, path in ipairs(paths) do
        qf_items[i] = { filename = path }
    end

    -- get rid of last
    qf_items[#qf_items] = nil

    vim.fn.setqflist({}, ' ', {
        title = "goto file",
        items = qf_items
    })

    vim.cmd('copen')
end

return gf_wont_callback
