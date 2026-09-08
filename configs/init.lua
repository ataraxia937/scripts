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
for _, group in ipairs({ 'Normal', 'NonText', 'LineNr', 'SignColumn' }) do
  vim.api.nvim_set_hl(0, group, { bg = 'none' })
end

function _G.tabline()
  local current = vim.api.nvim_get_current_buf()
  local entries, cur_idx = {}, 1
  for _, buf in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
    local name = buf.name ~= '' and vim.fn.fnamemodify(buf.name, ':t') or '[No Name]'
    local modified = buf.changed == 1 and ' [+]' or ''
    local text = string.format(' %d: %s%s ', buf.bufnr, name, modified)
    table.insert(entries, { bufnr = buf.bufnr, text = text, width = vim.fn.strdisplaywidth(text) })
    if buf.bufnr == current then
      cur_idx = #entries
    end
  end

  -- Vim truncates a too-long tabline from the start by default, which can
  -- scroll the active buffer off-screen with no trace it's still open.
  -- Window the list around the active buffer instead, growing outward only
  -- while it still fits, so it's always visible. Reserve 2 columns for the
  -- "<"/">" indicators so this windowing doesn't itself overflow and trigger
  -- Vim's own truncation on top of it.
  local budget = vim.o.columns - 2
  local width, lo, hi = entries[cur_idx].width, cur_idx, cur_idx
  while true do
    local grew = false
    if lo > 1 and width + entries[lo - 1].width <= budget then
      lo = lo - 1
      width = width + entries[lo].width
      grew = true
    end
    if hi < #entries and width + entries[hi + 1].width <= budget then
      hi = hi + 1
      width = width + entries[hi].width
      grew = true
    end
    if not grew then
      break
    end
  end

  local parts = {}
  if lo > 1 then
    table.insert(parts, '%#TabLine#<')
  end
  for i = lo, hi do
    local hl = entries[i].bufnr == current and '%#TabLineSel#' or '%#TabLine#'
    table.insert(parts, hl .. entries[i].text)
  end
  if hi < #entries then
    table.insert(parts, '%#TabLine#>')
  end
  table.insert(parts, '%#TabLineFill#')
  return table.concat(parts)
end

vim.o.showtabline = 2
vim.o.tabline = '%!v:lua.tabline()'

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
