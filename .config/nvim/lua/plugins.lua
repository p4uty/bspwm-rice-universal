local plugin_dir = vim.fn.stdpath("config") .. "/lua/plugins"

local plugins = {}
local configs = {}

for _, file in ipairs(vim.fn.readdir(plugin_dir)) do
    if file:match("%.lua$") then
        local mod = require("plugins." .. file:gsub("%.lua$", ""))

        if mod.plugin then
            if mod.plugin.src then
                plugins[#plugins + 1] = mod.plugin
            else
                vim.list_extend(plugins, mod.plugin)
            end
        end

        if type(mod.config) == "function" then
            configs[#configs + 1] = mod.config
        end
    end
end

-- vim.pack (gestor de plugins nativo) solo existe en Neovim >= 0.12.
-- En versiones anteriores se omite para evitar el error y que nvim abra igual.
if vim.pack and vim.pack.add then
    vim.pack.add(plugins)
else
    vim.schedule(function()
        vim.notify(
            "Este config de Neovim requiere v0.12+ (vim.pack) para instalar plugins. "
            .. "Tienes " .. tostring(vim.version()) .. " — nvim abre sin plugins.",
            vim.log.levels.WARN
        )
    end)
end

for _, config in ipairs(configs) do
    pcall(config)
end
