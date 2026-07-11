local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Шрифт и вид
config.font = wezterm.font 'JetBrainsMono Nerd Font'
config.font_size = 15.0
config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }
config.default_cursor_style = 'BlinkingBar'
config.window_background_opacity = 1.0
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true   -- прятать плашку вкладок если вкладка одна
config.window_decorations = "RESIZE"

-- Рендер: если фон забагует на NVIDIA+Wayland — поменяй на 'Software'
config.front_end = 'OpenGL'

-- Темы
config.color_scheme = 'Ashes (dark) (terminal.sexy)'
-- config.color_scheme = 'poimandres'

-- Твоя палитра (из current-theme.conf)
-- config.colors = {
--   background = '#282f32',
--   foreground = '#dad9df',
--   cursor_bg = '#d35f5a',
--   cursor_border = '#d35f5a',
--   selection_bg = '#eeb7ab',
--   selection_fg = '#282f32',
--   ansi = {
--     '#282f32','#ca1d2c','#edb7ab','#b7aa9a','#2e78c1','#c0226e','#309185','#e9e2cd',
--   },
--   brights = {
--     '#092027','#d35f5a','#d35f5a','#a86571','#7c84c4','#5b5db2','#81908f','#fcf4de',
--   },
-- }

-- Картинка на фон
config.background = {
  {
    source = { File = wezterm.config_dir .. '/bg.jpg' },
    width = '100%',
    height = '100%',
    hsb = { brightness = 0.15 },   -- было 0.5 → темнее
  },
  {
    source = { Color = '#1b1e28' },
    width = '100%',
    height = '100%',
    opacity = 0.75,                -- было 0.55 → плотнее тёмный слой
  },
}
-- Хоткеи как в kitty
config.keys = {
  { key = 't', mods = 'CTRL|SHIFT', action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
  { key = 'w', mods = 'CTRL|SHIFT', action = wezterm.action.CloseCurrentTab{ confirm = false } },
  { key = 'd', mods = 'CTRL|SHIFT', action = wezterm.action.SplitVertical{ domain = 'CurrentPaneDomain' } },
  { key = 'e', mods = 'CTRL|SHIFT', action = wezterm.action.SplitHorizontal{ domain = 'CurrentPaneDomain' } },
  { key = 'x', mods = 'CTRL|SHIFT', action = wezterm.action.CloseCurrentPane{ confirm = false } },
  { key = 'LeftArrow',  mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'CTRL|SHIFT', action = wezterm.action.ActivatePaneDirection 'Right' },
}

return config
