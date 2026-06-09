extends RefCounted

const UI_SCALE := 1.3
const FONT_SCALE := 1.25

# Typography (base px before UI_SCALE × FONT_SCALE)
const BASE_FONT_SCREEN_TITLE := 40
const BASE_FONT_TITLE := 26
const BASE_FONT_GAS_AMOUNT := 32
const BASE_FONT_BODY := 18
const BASE_FONT_BODY_LG := 19
const BASE_FONT_SMALL := 16
const BASE_FONT_CAPTION := 14
const BASE_FONT_TAB := 13

# Spacing (base px before UI_SCALE)
const BASE_MARGIN := 16
const BASE_MARGIN_BOTTOM := 8
const BASE_SEP_CHROME := 12
const BASE_SEP_SECTION := 16
const BASE_SEP_CARD := 12
const BASE_SEP_COMPACT := 8
const BASE_SEP_TIGHT := 4
const BASE_SEP_GLOSSARY := 14
const BASE_SEP_HEADER := 6

# Component sizes (base px before UI_SCALE)
const BASE_BUTTON_HEIGHT := 52
const BASE_MINING_BUTTON_HEIGHT := 64
const BASE_NAV_HEIGHT := 72
const BASE_NAV_BUTTON_HEIGHT := 64
const BASE_GAS_BAR_HEIGHT := 52
const BASE_ICON_NAV := 28
const BASE_ICON_GAS := 24
const BASE_MARKET_CARD_HEIGHT := 175
const BASE_MARKET_CARD_LOCKED_HEIGHT := 200
const BASE_ASSESSMENT_CARD_HEIGHT := 170
const BASE_UPGRADE_BTN_WIDTH := 100
const BASE_UPGRADE_BTN_HEIGHT := 36
const BASE_QUIZ_OPTION_HEIGHT := 84
const BASE_QUIZ_NUMBER_BOX := 36
const BASE_QUIZ_AVATAR := 240
const BASE_QUIZ_HINT_HEIGHT := 64
const BASE_PANEL_PADDING := 10
const BASE_PANEL_PADDING_SM := 8
const BASE_UNDERLINE := 2

const BG_DARK := Color(0.0392157, 0.054902, 0.101961, 1.0)
const BG_PANEL := Color(0.05, 0.07, 0.12, 1.0)
const CYAN := Color(0.0, 1.0, 1.0, 1.0)
const MAGENTA := Color(1.0, 0.0, 1.0, 1.0)
const TEXT_WHITE := Color(0.92, 0.92, 0.96, 1.0)
const TEXT_GRAY := Color(0.72, 0.72, 0.78, 1.0)
const TEXT_DIM := Color(0.42, 0.42, 0.48, 1.0)
const COST_PINK := Color(1.0, 0.55, 0.65, 1.0)
const HEADER_MAGENTA := Color(0.85, 0.1, 0.75, 1.0)

const MEMPOOL_CAPACITY := 10
const VALIDATE_BASE_PAYOUT := 500
const VALIDATE_BLOCK_MULT := 25
const VALIDATE_PASSIVE_MULT := 10

const TAB_NODES := 0
const TAB_MINING := 1
const TAB_MARKET := 2
const TAB_ACADEMY := 3

const ACADEMY_SUBTAB_AUDITS := 0
const ACADEMY_SUBTAB_GLOSSARY := 1
const ACADEMY_SUBTAB_LABELS := ["AUDITS", "GLOSSARY"]

const TAB_TITLES := ["NODES", "MINING", "MARKET", "ACADEMY"]
const TAB_ICON_PATHS := [
	"res://ui/textures/nav/nodes.png",
	"res://ui/textures/nav/mining.png",
	"res://ui/textures/nav/market.png",
	"res://ui/textures/nav/academy.png",
]

const GAS_ICON_PATH := "res://ui/textures/assets/gas_icon.png"
const QUIZ_ICON_PATH := "res://ui/textures/assets/quiz_host.png"
