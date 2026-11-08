-- Windows Terminal + WSL. Register before the clipboard provider is loaded.
vim.g.python3_host_prog = "/usr/bin/python"
vim.env.BROWSER = "wsl-open"
vim.g.clipboard = {
    name = "Windows clipboard (UTF-8)",
    copy = { ["+"] = { "wsl-clipboard", "copy" }, ["*"] = { "wsl-clipboard", "copy" } },
    paste = { ["+"] = { "wsl-clipboard", "paste" }, ["*"] = { "wsl-clipboard", "paste" } },
    cache_enabled = 0,
}
vim.filetype.add({ extension = { qmd = "quarto" } })
