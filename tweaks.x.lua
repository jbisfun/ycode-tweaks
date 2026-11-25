-- ycode-tweaks: drew-council/zed-config (https://github.com/drew-council/zed-config)
-- as a ycode plugin.
--
-- * settings.json -> ycode.settings{} (in-memory plugin layer, never written to disk)
-- * keymap.json   -> %hookf keymap::user (prepended, so the user's keymap.json still wins)
-- * tasks.json    -> %hookf tasks::global (the lazygit task bound to ctrl-shift-space)

-- JSON null (unbinds a key); Lua nil would just drop the entry.
local NULL = ycode.json_decode("null")

local function have(cmd)
    local p = io.popen("command -v " .. cmd .. " 2>/dev/null")
    if not p then return false end
    local out = p:read("a")
    p:close()
    return out ~= ""
end

local SETTINGS = {
    -- ai
    agent_servers = {
        ["codex-acp"] = { type = "registry" },
    },
    agent = {
        dock = "right",
        favorite_models = {
            { provider = "zed.dev", model = "claude-sonnet-4-6", enable_thinking = false },
        },
        default_profile = "write",
        inline_assistant_model = { provider = "zed.dev", model = "gpt-5.5" },
        default_model = {
            effort = "high",
            enable_thinking = true,
            provider = "zed.dev",
            model = "claude-sonnet-4-6",
        },
    },
    -- `provider = "zed"` is left out: it needs a zed.dev sign-in and would override
    -- ycode-offline's `provider = "none"` (plugins merge in load order).
    edit_predictions = {
        disabled_globs = {
            "**/.env*", "**/*.pem", "**/*.key", "**/*.cert", "**/*.crt",
            "**/.dev.vars", "**/secrets.yml",
        },
        mode = "subtle",
    },

    cli_default_open_behavior = "existing_window",
    project_panel = { dock = "left" },
    outline_panel = { dock = "left" },
    collaboration_panel = { dock = "left" },
    git_panel = { dock = "left" },

    -- extensions
    lsp = {
        ols = { initialization_options = { enable_fake_methods = true } },
    },
    auto_install_extensions = {
        basher = true, catppuccin = true, ["catppuccin-icons"] = true, csv = true,
        ["docker-compose"] = true, dockerfile = true, env = true, ["git-firefly"] = true,
        gosum = true, html = true, ini = true, latex = true, log = true, lua = true,
        make = true, ["markdown-oxide"] = true, neocmake = true, nginx = true, nix = true,
        nu = true, proto = true, ruff = true, sql = true, terraform = true, toml = true,
        xml = true, zig = true, kdl = true,
    },

    -- editor
    autosave = { after_delay = { milliseconds = 500 } },
    base_keymap = "VSCode",
    buffer_font_family = "JetBrainsMono Nerd Font",
    buffer_font_size = 15,
    cursor_blink = false,
    hide_mouse = "on_typing",
    scroll_beyond_last_line = "off",
    file_types = {
        CMake = { "CMakeLists.txt", "cmake" },
        Dockerfile = { "Dockerfile*" },
    },
    icon_theme = { dark = "Catppuccin Mocha", light = "Catppuccin Latte", mode = "dark" },
    languages = {
        Markdown = { soft_wrap = "editor_width" },
        Go = { soft_wrap = "editor_width", tab_size = 4 },
        Nix = { formatter = { external = { command = "nixfmt" } } },
        Python = { tab_size = 4 },
        Zig = { tab_size = 4 },
        Nu = { tab_size = 4 },
    },
    load_direnv = "shell_hook",
    theme = { dark = "Catppuccin Mocha", light = "Catppuccin Mocha", mode = "dark" },
    ui_font_size = 15,
    vim_mode = true,
    vim = { toggle_relative_line_numbers = true, highlight_on_yank_duration = 400 },
}

local KEYMAP = {
    {
        bindings = {
            ["alt-h"] = "workspace::ActivatePaneLeft",
            ["alt-j"] = "workspace::ActivatePaneDown",
            ["alt-k"] = "workspace::ActivatePaneUp",
            ["alt-l"] = "workspace::ActivatePaneRight",
            ["ctrl-b"] = "workspace::ToggleLeftDock",
            ["ctrl-shift-escape"] = "workspace::ToggleZoom",
            ["ctrl-shift-e"] = "project_panel::ToggleFocus",
            ["shift-escape"] = NULL,
            ["ctrl-shift-space"] = { "task::Spawn", { task_name = "lazygit" } },
            ["ctrl-right"] = "pane::SplitRight",
            ["ctrl-left"] = "pane::SplitLeft",
            ["ctrl-up"] = "pane::SplitUp",
            ["ctrl-down"] = "pane::SplitDown",
            ["ctrl-q"] = "pane::CloseActiveItem",
        },
    },
    {
        context = "Editor && edit_prediction",
        bindings = {
            ["alt-tab"] = "editor::AcceptEditPrediction",
            ["alt-l"] = NULL,
            ["tab"] = NULL,
        },
    },
}

local TASKS = {
    {
        label = "lazygit",
        command = "lazygit",
        allow_concurrent_runs = false,
        reveal = "always",
        hide = "always",
        reveal_target = "center",
        shell = "system",
    },
}

%ctor
    -- The upstream config runs nu as the terminal shell; only switch when it's installed.
    if have("nu") then
        SETTINGS.terminal = { shell = { program = "nu" } }
    end
    ycode.settings(SETTINGS)
    ycode.log("ycode-tweaks: active")
end

%hookf keymap::user(sections)
    local out = {}
    for _, s in ipairs(KEYMAP) do out[#out + 1] = s end
    for _, s in ipairs(sections or {}) do out[#out + 1] = s end
    return %orig(out)
end

%hookf tasks::global(tasks)
    local out = {}
    for _, t in ipairs(tasks or {}) do out[#out + 1] = t end
    for _, t in ipairs(TASKS) do out[#out + 1] = t end
    return %orig(out)
end
