-- don't load ALE from APT
vim.g.loaded_ale_dont_use_this_in_other_plugins_please = 1

-- use system clipboard
vim.o.clipboard = 'unnamedplus'

-- completions
vim.opt.completeopt = { 'fuzzy', 'menu', 'noinsert', 'popup' }

-- indentation
vim.o.shiftwidth = 2
vim.o.tabstop = 2

-- security
vim.o.modeline = false
vim.o.undofile = false
vim.opt.shadafile = 'NONE'

-- appearance
vim.o.relativenumber = true
vim.o.background = 'dark'
vim.cmd.colorscheme('lunaperche')
for _, group in ipairs({ 'Normal', 'NonText', 'LineNr', 'SignColumn' }) do
  vim.api.nvim_set_hl(0, group, { bg = 'none' })
end

-- LSP
vim.lsp.config('tsc', {
  cmd = { 'tsc', '--lsp', '--stdio' },
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json' },
})
vim.lsp.enable('tsc')

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or not client:supports_method('textDocument/completion') then
      return
    end

    vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })

    -- tsc's native LSP hard-rejects any triggerCharacter it didn't itself
    -- advertise, so extending completionProvider.triggerCharacters (the
    -- documented way to autocomplete on every keystroke) makes typing a
    -- bare identifier error out instead of completing. Invoke completion
    -- with no triggerCharacter (like <C-x><C-o> does) on keyword characters
    -- instead; trigger() already dedupes/cancels, so this is cheap.
    if not vim.b[args.buf].keyword_completion_autocmd then
      vim.b[args.buf].keyword_completion_autocmd = true
      vim.api.nvim_create_autocmd('InsertCharPre', {
        buffer = args.buf,
        callback = function()
          if vim.v.char:match('[%w_$]') then
            vim.schedule(vim.lsp.completion.get)
          end
        end,
      })
    end
  end,
})
