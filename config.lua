Config = {}

-- =========================
-- BASIC
-- =========================
Config.JoinDelay = 0

Config.AntiSpam = true
Config.AntiSpamTimer = 3
Config.PleaseWait = "Prosím počkaj %d sek..."

Config.RequireSteam = false
Config.PriorityOnly = false
Config.DisableHardCap = true

Config.QueueTimeOut = 90
Config.ConnectTimeOut = 120

-- =========================
-- DEFAULT POINTS (fallback)
-- schedule to prepíše automaticky
-- =========================
Config.MinJoinPoints = 0
Config.EarnInterval = 30 -- každých X sekund přidá body (pokud není v schedule, nebo je schedule disabled)
Config.EarnAmount = 100 -- kolik bodů přidá každých X sekund (pokud není v schedule, nebo je schedule disabled)
Config.MaxFreePoints = 3000000

-- =========================
-- SCHEDULE (18:00 PEAK)
-- používa server OS čas (nastav Europe/Bratislava)
-- =========================
Config.QueueSchedule = {
  Enabled = true,

  Peak = {
    StartHour = 14,
    EndHour = 16, -- Čas od kedy do kedy je peak (např. 18 - 23)
    MinJoinPoints = 7000, -- kolik bodů musí mít hráč pro vstup během peak (může být 0, ale pak není smysl mít schedule)
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
-- GRACE BOOST (po páde hry/relog)
-- dá na X sekúnd mega body
-- =========================
Config.GraceBoost = {
  Enabled = true,
  DurationSeconds = 120,     -- 2 min
  Points = 2000000,          -- 2 000 000
  UseIdentifier = "discord", -- odporúčam discord, môže byť "license"
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
-- QUEUE PRIORITY (poradie vo fronte)
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
  GuildId = "", --ID tvého Discord serveru
  BotToken = "", -- ⚠️ sem vlož token (nikomu neposielaj)
  CacheSeconds = 60,

  RolePoints = {
    -- ["ROLE_ID_TIER1"] = 3000, -- Tier1 ... a takhle můžeš přidat další role z Discordu, které budou dávat body (stačí ID role, ne ID uživatele)
    -- ["ROLE_ID_TIER2"] = 5000,
    -- ["ROLE_ID_TIER3"] = 7000,
    -- ["ROLE_ID_TIER4"] = 10000,
  }
}

-- =========================
-- MANUÁLNE BODY (bez role / bez tebex) – len dopíšeš ľudí do configu
-- =========================
Config.ManualPoints = {
    --["xxxxxxxxxxxxxxxxxx"] = 7800,  -- ID z Hračovho Discordu 
}

-- =========================
-- TEBEX QPOINTS (DB stack)
-- =========================
Config.QPoints = {
  Enabled = true,
  DefaultDurationDays = 30,
  UseIdentifier = "discord",         -- ukladá do DB ako "discord:123..."
  CommandName = "queue_addpoints",
  AllowInGameAce = true,
  AcePermission = "queue.addpoints"
}

-- =========================
-- TEXTY
-- =========================
Config.Language = {
  connecting = "Pripájam...",
  joining = "Vstupuješ na server...",
  connectingerr = "Chyba pri pripájaní. Skús znova.",
  idrr = "Nepodarilo sa načítať tvoje identifikátory.",
  steam = "Zapni Steam a skús znova.",
  wlonly = "Tento server je len pre whitelist.",
  discord = "Musíš mať zapnutý Discord (a prepojený s FiveM).",

  -- pos, size, time, points, required, paid
  line = "Pozícia: %d/%d | Čas: %s | Earned: %d | Paid: %d | Spolu: %d/%d",
}
