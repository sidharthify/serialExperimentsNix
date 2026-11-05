vim.g.autoformat = false
vim.g.snacks_animate = false
vim.g.lazyvim_picker = "snacks"
vim.g.lazyvim_python_lsp = "pyright"
vim.g.lazyvim_python_ruff = "ruff"
vim.g.root_spec = { "lsp", { ".git", "lua", ".repo" }, "cwd" }

local opt = vim.opt

opt.conceallevel = 0
opt.relativenumber = true
opt.scrolloff = 8
opt.wrap = false
opt.spell = false
opt.swapfile = false
opt.undofile = true
opt.undolevels = 10000
opt.cursorline = true
opt.colorcolumn = ""
opt.list = true
opt.listchars = { tab = "  ", trail = "·", nbsp = "␣" }
opt.fillchars:append({ eob = " " })
opt.shortmess:append({ I = true, c = true, C = true, W = true, s = true })
opt.showcmd = false
opt.ruler = false
opt.laststatus = 3
opt.cmdheight = 0
opt.pumheight = 12
opt.signcolumn = "yes"
opt.smoothscroll = true

vim.filetype.add({
  extension = {
    bp = "bp",
    te = "conf",
  },
  filename = {
    ["Android.mk"] = "make",
    ["BoardConfig.mk"] = "make",
    ["file_contexts"] = "conf",
    ["genfs_contexts"] = "conf",
    ["property_contexts"] = "conf",
    ["service_contexts"] = "conf",
    ["hwservice_contexts"] = "conf",
  },
  pattern = {
    [".*/etc/init/.*%.rc"] = "conf",
    [".*init.*%.rc"] = "conf",
    [".*/defconfig"] = "kconfig",
    [".*_defconfig"] = "kconfig",
  },
})
