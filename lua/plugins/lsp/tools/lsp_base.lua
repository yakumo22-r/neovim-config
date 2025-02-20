local lsp_base = {}
function lsp_base.cmd(cmd)
    if vim.fn.has("win32") == 1 then
        return vim.fn.stdpath("data").."\\mason\\bin\\"..cmd..".cmd"
    else
        return cmd
    end
end 
return lsp_base

