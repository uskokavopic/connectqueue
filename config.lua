Config = {}

-- =========================
-- BASIC
-- =========================
Config.JoinDelay = 0

Config.AntiSpam = true
Config.AntiSpamTimer = 3
Config.PleaseWait = "Please wait %d sec..."

Config.RequireSteam = false
Config.PriorityOnly = false
Config.DisableHardCap = true

Config.QueueTimeOut = 90
Config.ConnectTimeOut = 120

-- =========================
-- DEFAULT POINTS (fallback)
-- schedule will override automatically
-- =========================
Config.MinJoinPoints = 0
Config.EarnInterval = 30 -- adds points every X seconds (if schedule is disabled or not used)
Config.EarnAmount = 100 -- how many points are added every X seconds
Config.MaxFreePoints = 3000000

-- =========================
-- SCHEDULE (PEAK HOURS)
-- uses server OS time (set Europe/Bratislava)
-- =========================
Config.QueueSchedule = {
  Enabled = true,

  Peak = {
    StartHour = 14,
    EndHour = 16, -- Peak time range (example: 18 - 23)
    MinJoinPoints = 7000, -- required points to join during peak hours
    EarnInterval = 30,
    EarnAmount = 100,
    MaxFreePoints = 3000000,
  },

  OffPeak = {
    MinJoinPoints = 0,
    EarnInterval = 30,
    EarnAmount = 100,
    MaxFreePoints = 3000000,
  }
}

-- =========================
-- GRACE BOOST (after crash / reconnect)
-- gives temporary high priority points
-- =========================
Config.GraceBoost = {
  Enabled = true,
  DurationSeconds = 120,     -- 2 min
  Points = 2000000,          -- 2,000,000
  UseIdentifier = "discord", -- recommended: discord (can be "license")
}

-- =========================
-- LINKS (BUTTONS)
-- =========================
Config.Links = {
  TebexHome = "https://uskokavopic.tebex.io/",
  Discord   = "https://discord.gg/8SD9yHF7",
  Shop      = "https://uskokavopic.tebex.io/category/2002026",
}

-- =========================
-- RESERVED SLOTS (optional)
-- =========================
Config.ReservedSlots = 0
Config.ReservedMinPriority = 25

-- =========================
-- QUEUE PRIORITY (queue order)
-- =========================
Config.Priority = {
  -- ["discord:xxxxxxxxxxxxxxxxxx"] = 50,
}

-- =========================
-- DISCORD TIERS
-- =========================
Config.RequireDiscord = true

Config.Discord = {
  Enabled = true,
  GuildId = "", -- Your Discord server ID
  BotToken = "", -- ⚠️ Put your bot token here (never share it)
  CacheSeconds = 60,

  RolePoints = {
    -- ["ROLE_ID_TIER1"] = 3000,
    -- ["ROLE_ID_TIER2"] = 5000,
    -- ["ROLE_ID_TIER3"] = 7000,
    -- ["ROLE_ID_TIER4"] = 10000,
  }
}

-- =========================
-- MANUAL POINTS (no role / no Tebex)
-- add players manually into config
-- =========================
Config.ManualPoints = {
    --["xxxxxxxxxxxxxxxxxx"] = 7800,  -- Player Discord ID
}

-- =========================
-- TEBEX QPOINTS (DB stack)
-- =========================
Config.QPoints = {
  Enabled = true,
  DefaultDurationDays = 30,
  UseIdentifier = "discord",         -- stored in DB as "discord:123..."
  CommandName = "queue_addpoints",
  AllowInGameAce = true,
  AcePermission = "queue.addpoints"
}

-- =========================
-- TEXTS
-- =========================
Config.Language = {
  connecting = "Connecting...",
  joining = "Joining the server...",
  connectingerr = "Connection error. Please try again.",
  idrr = "Failed to load your identifiers.",
  steam = "Please start Steam and try again.",
  wlonly = "This server is whitelist only.",
  discord = "You must have Discord running (and linked with FiveM).",

  -- pos, size, time, points, required, paid
  line = "Position: %d/%d | Time: %s | Earned: %d | Paid: %d | Total: %d/%d",
}

