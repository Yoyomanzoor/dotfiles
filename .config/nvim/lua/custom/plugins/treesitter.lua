return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").install({
                "bash", "bibtex", "c", "cpp", "cmake", "csv", "diff", "fish",
                "gitcommit", "git_config", "gitignore", "go", "gomod", "html",
                "hyprlang", "java", "javascript", "json", "julia", "latex", "lua",
                "luadoc", "markdown", "markdown_inline", "matlab", "meson", "perl",
                "python", "query", "r", "regex", "rnoweb", "ruby", "rust", "toml",
                "typescript", "vim", "vimdoc", "yaml",
            })
            vim.api.nvim_create_autocmd("FileType", {
                callback = function(event)
                    -- Parsers install asynchronously. Files without one retain normal syntax.
                    local ok = pcall(vim.treesitter.start, event.buf)
                    if ok and vim.bo[event.buf].filetype ~= "ruby" then
                        vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end,
            })
        end,
    },
}
