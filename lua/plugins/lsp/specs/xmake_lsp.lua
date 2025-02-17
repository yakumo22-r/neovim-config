local xmake_client = nil
return function(lspconfig, capabilities, keybindings)
    vim.api.nvim_create_autocmd({"BufRead","BufNewFile"}, {
        pattern = "xmake.lua",
        callback = function(args)
            local bufnr = args.buf
            if not xmake_client then
                xmake_client=vim.lsp.start({
                    name="xmake",
                    cmd={'lua-language-server'},
                    on_attach = function (client, bufnr)
                        keybindings(client,bufnr)
                        xmake_client=client
                        print("xmake,attach")
                    end,
                    capabilities = capabilities,
                    single_file_support = true,
                    settings = {
                        Lua = {
                            runtime = {
                                version = "LuaJIT",
                                path = vim.split(package.path, ";"),
                            },
                            diagnostics = {
                                disable = { "lowercase-global", "trailing-space", "empty-block" },
                            },
                            workspace = {
                                library = {
                                    [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                                    [vim.fn.expand(parent_dir .. '/xmake_docs')] = true,
                                },
                            }
                        },
                    },
                })
            else
                vim.lsp.buf_attach_client(bufnr, xmake_client)
            end
        end,
    })
end
