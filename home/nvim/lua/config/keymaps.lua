local map = vim.keymap.set

map("n", "<leader>uu", "<cmd>UndotreeToggle<cr>", { desc = "Undotree" })
map("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Diffview Open" })
map("n", "<leader>gD", "<cmd>DiffviewClose<cr>", { desc = "Diffview Close" })
map("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "File History (Diffview)" })
map("n", "<leader>gH", "<cmd>DiffviewFileHistory<cr>", { desc = "Repo History (Diffview)" })
map("n", "<leader>gx", "<cmd>GitConflictListQf<cr>", { desc = "List Conflicts" })
map("n", "<leader>gF", "<cmd>Git<cr>", { desc = "Fugitive" })
map("n", "<leader>cv", "<cmd>CsvViewToggle<cr>", { desc = "Toggle CSV View" })
map({ "n", "x" }, "<leader>p", '"_dP', { desc = "Paste Without Yank" })
map("n", "<Esc>", "<cmd>nohlsearch<cr><Esc>")
map("n", "<leader>fp", function() Snacks.picker.projects() end, { desc = "Projects" })
