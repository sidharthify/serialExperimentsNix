pcall(vim.api.nvim_del_augroup_by_name, "lazyvim_wrap_spell")

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user_wrap", { clear = true }),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = false
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user_kernel_style", { clear = true }),
  pattern = { "c", "cpp", "kconfig", "make", "dts" },
  callback = function(ev)
    local path = vim.api.nvim_buf_get_name(ev.buf)
    if vim.fs.root(path, { "Kconfig", "Kbuild" }) then
      vim.opt_local.expandtab = false
      vim.opt_local.tabstop = 8
      vim.opt_local.shiftwidth = 8
      vim.opt_local.colorcolumn = "100"
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user_gitcommit", { clear = true }),
  pattern = "gitcommit",
  callback = function()
    vim.opt_local.colorcolumn = "73"
    vim.opt_local.textwidth = 72
  end,
})
