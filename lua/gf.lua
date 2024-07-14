local gf_wont_callback = require("gf.gf_wont_callback")

local M = {}

M.setup = function()
    vim.keymap.set('n', 'gf', gf_wont_callback, {
        noremap = true, silent = true,
        desc = "Smart goto file under cursor",
    })
end

return M
