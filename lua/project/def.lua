Project = {}

Project.curr = ""
Project.targets = {}

function Project:run(...)
    local target = self.target[self.curr]
    if target and target.run then
        target.run(...)
    else
        print("no function run() for", self.curr)
    end
end

function Project:build(...)
    local target = self.target[self.curr]
    if target and target.build then
        target.build(...)
    else
        print("no function build() for", self.curr)
    end
end

function Project:add_target(name, run, build)
    self.targets[name] = { run = run, build = build }
end

function Project:del_target(name)
    self.targets[name] = nil
end

