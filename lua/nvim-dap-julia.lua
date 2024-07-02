local M = {}

local function load_module(module_name)
  local ok, module = pcall(require, module_name)
  assert(ok, string.format("nvim-dap-julia dependency error: %s not installed", module_name))
  return module
end

local PLUGIN_ROOT = vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ":h:h")

local function get_plugin_root()
  return PLUGIN_ROOT
end

local function get_debugger_script()
  return get_plugin_root() .. "/scripts/server.jl"
end

local CONFIG = {
  configurations = {
    julia = {
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
    },
  },
  adapters = {
    julia = {
      type = "server",
      port = "${port}",
      executable = {
        command = "julia",
        args = { "--project=" .. get_plugin_root(), get_debugger_script(), "${port}" },
      },
      options = {
        max_retries = 100,
      },
    },
  },
}

local function setup_julia_config(dap, config)
  dap.configurations.julia = config.configurations.julia
  dap.adapters.julia = config.adapters.julia
end

local function setup(opts)
  local config = vim.tbl_deep_extend("force", CONFIG, opts or {})
  local dap = load_module("dap")
  setup_julia_config(dap, config)
end

return {
  get_plugin_root = get_plugin_root,
  get_debugger_script = get_debugger_script,
  setup = setup,
}
