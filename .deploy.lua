return {
    localPath = "/",
    targets = {
        test215_test = {
            method = "scp",
            server = "root@xy.hzmj-test.215",
            system = "linux",
            path = "/home/windy/nvim",
        },
    },
    ignores = {
        ".git/",
        ".tmp/",
    },
}
