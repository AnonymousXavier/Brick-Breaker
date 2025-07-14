local settings = {}

math.randomseed(os.time())

settings.highscore_file_path = "score.txt"

settings.Controls = {}
settings.Colors = {}
settings.Fonts = {}
settings.debug = false -- Draw all collision rects

settings.screen_width = 1000
settings.screen_height = settings.screen_width
settings.game_name = "BRICK BREAKER - NO FILL!"

settings.score_on_block_destroyed = 100
settings.power_up_chance = 10 -- in percentage
settings.power_up_width = 25
settings.power_up_height = settings.power_up_width
settings.power_up_fall_speed = 100

settings.hud_height = 50
settings.hud_text_flash_duration = 0.75

settings.font_size = 24
settings.block_health_font_size = 12
settings.pickup_message_font_size = 30
settings.ball_count_font_size = 18
settings.menu_title_font_size = 50
settings.menu_subtitle_font_szie = 26

settings.block_rows = 2
settings.block_cols = 1
settings.block_spacing = 10
settings.block_width = (settings.screen_width / settings.block_cols) - settings.block_spacing
settings.block_height = 25

settings.player_initial_lives = 2
settings.paddle_width = 120
settings.paddle_height = 20
settings.paddle_default_Y = (settings.screen_height - settings.paddle_height) * 0.9
settings.paddle_default_X = (settings.screen_width - settings.paddle_width) / 2
settings.paddle_aim_line_length = 150
settings.paddle_aim_limits = {min = -165, max = -15}
settings.default_player_speed = 500

settings.default_ball_radius = 10
settings.default_ball_Y_offset_from_paddle = 20
settings.default_ball_speed = 400
settings.speed_gain_per_bounce = 10
settings.default_bounces_till_effect_wears_off = 15

settings.Controls.left = {"left", "a"}
settings.Controls.right = {"right", "d"}
settings.Controls.play = {"space", "return", "up"}
settings.Controls.start = {"s"}
settings.Controls.back_to_menu = {"m"}

settings.Colors.debug = {r = 1.0, g = 0.5, b = 0.5}
settings.Colors.paddle = settings.Colors.debug
settings.Colors.ball = settings.Colors.debug
settings.Colors.blocks = settings.Colors.debug
settings.Colors.debug = settings.Colors.debug
settings.Colors.powerups = settings.Colors.debug
settings.Colors.menuColor = settings.Colors.debug

settings.Fonts.default = love.graphics.newFont(settings.font_size)
settings.Fonts.block_health = love.graphics.newFont(settings.block_health_font_size)
settings.Fonts.pickup_message = love.graphics.newFont(settings.pickup_message_font_size)
settings.Fonts.ball_count = love.graphics.newFont(settings.ball_count_font_size)
settings.Fonts.menu_title = love.graphics.newFont(settings.menu_title_font_size)
settings.Fonts.menu_subtitle = love.graphics.newFont(settings.menu_subtitle_font_szie)

return settings
