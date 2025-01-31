# nvim-dap-julia

`nvim-dap-julia` is a Neovim plugin that integrates the
[Julia language debugger](https://github.com/julia-vscode/DebugAdapter.jl) with the
[Neovim Debug Adapter Protocol (DAP) client](https://github.com/mfussenegger/nvim-dap).

https://github.com/kdheepak/nvim-dap-julia/assets/1813121/54019d2a-2843-436a-80f1-b9d2d7f126dd

### Setup

Using [`lazy.nvim`](https://github.com/folke/lazy.nvim):

```lua
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "kdheepak/nvim-dap-julia",
      config = function()
        require("nvim-dap-julia").setup()
      end,
    },
  },
}
```

Here's the default configuration:

```lua
local nvim_dap_julia = require("nvim-dap-julia")
nvim_dap_julia.setup({
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
        args = { "--project=" .. nvim_dap_julia.get_plugin_root(), nvim_dap_julia.get_debugger_script(), "${port}" },
      },
      options = {
        max_retries = 100,
      },
    },
  },

})
```

If you want to override a specific section, you can do that by passing the options to `setup({})`.

For example, if you want to override `juliaEnv` to allow the user to pick options, you can setup a
coroutine callback like so:

```lua

local juliaEnvCallback = function()
  return coroutine.create(function(dap_run_co)
    local items = {
      [[ ${file}: Active filename ]],
      [[ ${fileBasename}: The current file's basename ]],
      [[ ${fileDirname}: The current file's dirname ]],
      [[ ${relativeFile}: The current file relative to current working directory ]],
      [[ ${workspaceFolder}: The current working directory of Neovim ]],
      [[ ${workspaceFolderBasename}: The name of the folder opened in Neovim ]],
    }
    vim.ui.select(items, { label = "juliaEnv> " }, function(choice)
      coroutine.resume(dap_run_co, choice)
    end)
  end)
end

local nvim_dap_julia = require("nvim-dap-julia")
nvim_dap_julia.setup({
  configurations = {
    julia = {
      juliaEnv = juliaEnvCallback
    }
  }
})

```

### Usage

To start a debug session, use the following command:

```vim
:DapContinue
```

Set breakpoints in your Julia code by using the following command:

```vim
:DapToggleBreakpoint
```

Control the debugging session with the following commands:

- `:DapContinue` - Continue execution.
- `:DapStepOver` - Step over the current line.
- `:DapStepInto` - Step into the current line.
- `:DapStepOut` - Step out of the current function.
- `:DapTerminate` - Terminate the debugging session.

### Advanced Setup

This setup includes keyboard shortcuts, opens UI elements automatically, etc:

```lua
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
      "kdheepak/nvim-dap-julia",
    },
    config = function()
      local dap = require("dap")
      local ui = require("dapui")

      require("dapui").setup()
      require("nvim-dap-julia").setup()

      vim.keymap.set("n", "<space>b", dap.toggle_breakpoint)
      vim.keymap.set("n", "<space>B", dap.run_to_cursor)

      vim.keymap.set("n", "<F1>", dap.continue)
      vim.keymap.set("n", "<F2>", dap.step_into)
      vim.keymap.set("n", "<F3>", dap.step_over)
      vim.keymap.set("n", "<F4>", dap.step_out)
      vim.keymap.set("n", "<F5>", dap.step_back)
      vim.keymap.set("n", "<F12>", dap.restart)

      dap.listeners.before.attach.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        ui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        ui.close()
      end
    end,
  },
}
```
