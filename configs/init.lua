vim.loader.enable()

vim.o.clipboard = 'unnamedplus'
vim.opt.completeopt = { "fuzzy", "menu", "noinsert", "popup" }
vim.o.modeline = false
vim.o.relativenumber = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.undofile = true

vim.o.background = 'dark'
vim.cmd.colorscheme "catppuccin"

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
