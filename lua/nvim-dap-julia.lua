local M = {}

function M.get_plugin_root()
  return vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ":h:h")
end

function M.get_debugger_script()
  return M.get_plugin_root() .. "/scripts/server.jl"
end

function M.setup()
  vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    once = true,
    pattern = { "*.jl" },
    callback = function()
      local dap = require("dap")
      dap.configurations.julia = {
        {
          type = "julia",
          name = "Debug julia executable",
          request = "launch",
          program = "${file}",
          projectDir = "${workspaceFolder}",
          juliaEnv = "${workspaceFolder}",
          exitAfterTaskReturns = false,
          debugAutoInterpretAllModules = false,
          stopOnEntry = true,
          args = {},
        },
      }
      dap.adapters.julia = {
        type = "server",
        port = "${port}",
        executable = {
          command = "julia",
          args = { "--project=" .. M.get_plugin_root(), M.get_debugger_script(), "${port}" },
        },
        options = {
          max_retries = 100,
        },
      }
    end,
  })
end

return M
