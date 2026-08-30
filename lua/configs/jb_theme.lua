local M = {}

local current_theme = "base46"

local function ensure_ibl_hook()
  local pcall_ibl, hooks = pcall(require, "ibl.hooks")
  if pcall_ibl and hooks and hooks.type and hooks.type.HIGHLIGHT_SETUP then
    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
      if vim.g.base46_cache and vim.uv.fs_stat(vim.g.base46_cache .. "blankline") then
        dofile(vim.g.base46_cache .. "blankline")
      end
    end)
  end
end

function M.apply_jb()
  if current_theme == "jb" then
    return
  end
  ensure_ibl_hook()

  local ok, jb = pcall(require, "jb")
  if ok then
    local transparent = false
    local ok_nvconfig, nvconfig = pcall(require, "nvconfig")
    if ok_nvconfig and nvconfig.base46 and nvconfig.base46.transparency ~= nil then
      transparent = nvconfig.base46.transparency
    end
    jb.setup({
      transparent = transparent,
    })
  end

  vim.cmd.colorscheme "jb"

  -- Re-apply NvChad statusline, tabline, devicons, and blankline caches to keep UI cohesive
  if vim.g.base46_cache then
    for _, mod in ipairs { "statusline", "tbline", "devicons", "blankline" } do
      local path = vim.g.base46_cache .. mod
      if vim.uv.fs_stat(path) then
        dofile(path)
      end
    end
  end

  current_theme = "jb"
end

function M.apply_base46()
  if current_theme == "base46" then
    return
  end

  local ok, base46 = pcall(require, "base46")
  if ok then
    base46.load_all_highlights()
  else
    if vim.g.base46_cache then
      for _, mod in ipairs { "defaults", "statusline", "syntax", "treesitter", "tbline", "devicons", "blankline" } do
        local path = vim.g.base46_cache .. mod
        if vim.uv.fs_stat(path) then
          dofile(path)
        end
      end
    end
  end

  current_theme = "base46"
end

local function is_floating_win(win)
  if not win or not vim.api.nvim_win_is_valid(win) then
    return false
  end
  local config = vim.api.nvim_win_get_config(win)
  return config.relative and config.relative ~= ""
end

function M.on_buffer_change(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  local win = vim.api.nvim_get_current_win()
  if is_floating_win(win) then
    return
  end

  local ft = vim.bo[bufnr].filetype
  local bt = vim.bo[bufnr].buftype

  if ft == "java" then
    M.apply_jb()
    return
  end

  -- Ignored non-file buffers while in java mode to avoid theme flickering
  local ignored_buftypes = {
    prompt = true,
    popup = true,
    nofile = true,
    quickfix = true,
    help = true,
  }
  if ignored_buftypes[bt] then
    return
  end

  local ignored_filetypes = {
    [""] = true,
    ["NvimTree"] = true,
    ["neo-tree"] = true,
    ["TelescopePrompt"] = true,
    ["TelescopeResults"] = true,
    ["which-key"] = true,
    ["notify"] = true,
    ["lazy"] = true,
    ["mason"] = true,
    ["cmp_menu"] = true,
    ["cmp_docs"] = true,
    ["dap-repl"] = true,
    ["dapui_scopes"] = true,
    ["dapui_breakpoints"] = true,
    ["dapui_stacks"] = true,
    ["dapui_watches"] = true,
  }
  if ignored_filetypes[ft] then
    return
  end

  M.apply_base46()
end

function M.setup()
  ensure_ibl_hook()

  local group = vim.api.nvim_create_augroup("JavaThemeSwitch", { clear = true })

  vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "WinEnter" }, {
    group = group,
    pattern = "*",
    callback = function(args)
      M.on_buffer_change(args.buf)
    end,
  })

  -- Check current buffer on startup
  vim.schedule(function()
    M.on_buffer_change()
  end)
end

return M
