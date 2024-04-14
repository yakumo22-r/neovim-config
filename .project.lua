local conf = {}

-- internal run by neovim
function conf:set_path(path)
    self.path = path
end

function conf:build(args)
    print("build not implementation")
end

function conf:run(args)
    print("run not implementation")
end

return conf

