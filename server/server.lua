local Queue = {}

Queue.MaxPlayers = GetConvarInt("sv_maxclients", 30)
Queue.Debug = GetConvar("sv_debugqueue", "true") == "true"
Queue.DisplayQueue = GetConvar("sv_displayqueue", "true") == "true"
Queue.InitHostName = GetConvar("sv_hostname")
Queue.InitHostName = Queue.InitHostName ~= "default FXServer" and Queue.InitHostName or false

local State = {
  QueueList = {},
  PlayerList = {},
  PlayerCount = 0,
  Priority = {},
  JoinDelay = GetGameTimer() + (Config.JoinDelay or 0),
  tick = 0,
}

local EarnedBank = {} -- [primaryId] = earned points (farm) ✅
local Grace = {}      -- [graceIdentifier] = expiresAtUnix
local DiscordCache = {} -- [discordId] = {points, expires}

local function now() return os.time() end
local function lower(s) return string.lower(s) end

local function capEarned(x)
  x = tonumber(x) or 0
  local cap = tonumber(Config.MaxEarnedPoints) or 0
  if cap > 0 then return math.min(x, cap) end
  return x
end

-- =========================
-- SCHEDULE APPLY (server OS time)
-- =========================
local function getCurrentHour()
  return tonumber(os.date("%H"))
end

local function isPeakHours()
  if not (Config.QueueSchedule and Config.QueueSchedule.Enabled) then return true end
  local h = getCurrentHour()
  local s = Config.QueueSchedule.Peak.StartHour
  local e = Config.QueueSchedule.Peak.EndHour
  if s < e then
    return h >= s and h < e
  else
    return (h >= s) or (h < e)
  end
end

local function applySchedule()
  if not (Config.QueueSchedule and Config.QueueSchedule.Enabled) then return end
  local mode = isPeakHours() and Config.QueueSchedule.Peak or Config.QueueSchedule.OffPeak
  Config.MinJoinPoints = tonumber(mode.MinJoinPoints) or 0
end

-- =========================
-- IDENTIFIERS
-- =========================
local function getIdentifierByType(ids, idType)
  if not ids then return nil end
  for _, id in ipairs(ids) do
    if string.sub(id, 1, #idType + 1) == (idType .. ":") then return id end
  end
  return nil
end

local function getPrimaryId(ids) return ids and ids[1] or nil end

local function getDiscordId(ids)
  local id = getIdentifierByType(ids, "discord")
  if not id then return nil end
  return string.sub(id, 9)
end

local function getQIdentifier(ids)
  local t = (Config.QPoints and Config.QPoints.UseIdentifier) or "discord"
  return getIdentifierByType(ids, t)
end

local function getGraceId(ids)
  local t = (Config.GraceBoost and Config.GraceBoost.UseIdentifier) or "discord"
  return getIdentifierByType(ids, t)
end

local function getGracePoints(ids)
  if not (Config.GraceBoost and Config.GraceBoost.Enabled) then return 0 end
  local gid = getGraceId(ids)
  if not gid then return 0 end
  local exp = Grace[gid]
  if not exp then return 0 end
  if now() >= exp then Grace[gid] = nil return 0 end
  return tonumber(Config.GraceBoost.Points) or 0
end

local function getManualPoints(ids)
  local did = getDiscordId(ids)
  if not did then return 0 end
  local mp = Config.ManualPoints
  if not mp then return 0 end
  return tonumber(mp[did]) or 0
end

-- init priority list
for id, power in pairs(Config.Priority or {}) do
  State.Priority[lower(id)] = power
end

function Queue:GetIds(src)
  local ids = GetPlayerIdentifiers(src)
  local ip = GetPlayerEndpoint(src)
  ids = (ids and ids[1]) and ids or (ip and {"ip:" .. ip} or false)
  return ids
end

function Queue:IsSteamRunning(src)
  for _, id in ipairs(GetPlayerIdentifiers(src)) do
    if string.sub(id, 1, 5) == "steam" then return true end
  end
  return false
end

function Queue:GetSize() return #State.QueueList end
function Queue:GetPlayerCount() return State.PlayerCount end

local function isInQueue(ids)
  for k, v in ipairs(State.QueueList) do
    local ok = false
    for _, id1 in ipairs(v.ids or {}) do
      for _, id2 in ipairs(ids or {}) do
        if id1 == id2 then ok = true break end
      end
      if ok then break end
    end
    if ok then return k, v end
  end
  return nil, nil
end

local function getQueuePriority(ids)
  for _, id in ipairs(ids or {}) do
    local p = State.Priority[lower(id)]
    if p then return p end
  end
  return 0
end

-- =========================
-- DISCORD TIERS
-- =========================
local function discordApiGetMember(guildId, discordId, botToken)
  local p = promise.new()
  PerformHttpRequest(
    ("https://discord.com/api/guilds/%s/members/%s"):format(guildId, discordId),
    function(code, body) p:resolve({code = code, body = body}) end,
    "GET",
    "",
    { ["Content-Type"] = "application/json", ["Authorization"] = "Bot " .. botToken }
  )
  return Citizen.Await(p)
end

local function getDiscordRolePoints(ids)
  local dc = Config.Discord
  if not dc or not dc.Enabled then return 0 end
  if not dc.GuildId or dc.GuildId == "" or not dc.BotToken or dc.BotToken == "" then return 0 end

  local discordId = getDiscordId(ids)
  if not discordId then return 0 end

  local t = now()
  local cached = DiscordCache[discordId]
  if cached and cached.expires > t then return cached.points or 0 end

  local res = discordApiGetMember(dc.GuildId, discordId, dc.BotToken)
  if not res or res.code ~= 200 or not res.body then return 0 end

  local ok, data = pcall(json.decode, res.body)
  if not ok or not data or not data.roles then return 0 end

  local best = 0
  for _, roleId in ipairs(data.roles) do
    local pts = (dc.RolePoints and dc.RolePoints[roleId]) or 0
    if pts > best then best = pts end
  end

  DiscordCache[discordId] = {points = best, expires = t + (dc.CacheSeconds or 60)}
  return best
end

-- =========================
-- DB QPOINTS (oxmysql lib)
-- =========================
local function dbGetQPoints(identifier)
  if not (Config.QPoints and Config.QPoints.Enabled) then return 0 end
  if not identifier then return 0 end

  local row = MySQL.single.await('SELECT points, expires_at FROM queue_qpoints WHERE identifier = ?', { identifier })
  if not row then return 0 end

  local exp = tonumber(row.expires_at) or 0
  if exp > 0 and now() >= exp then
    MySQL.update.await('UPDATE queue_qpoints SET points = 0, expires_at = 0 WHERE identifier = ?', { identifier })
    return 0
  end

  return tonumber(row.points) or 0
end

local function daysToSeconds(d) return (tonumber(d) or 0) * 86400 end

local function dbAddQPoints(identifier, addPoints, durationDays)
  if not (Config.QPoints and Config.QPoints.Enabled) then return false, "QPoints disabled" end
  if not identifier then return false, "missing identifier" end

  addPoints = tonumber(addPoints) or 0
  if addPoints <= 0 then return false, "points must be > 0" end

  local duration = daysToSeconds(durationDays or (Config.QPoints.DefaultDurationDays or 30))
  local newExpiry = now() + duration

  local row = MySQL.single.await('SELECT points, expires_at FROM queue_qpoints WHERE identifier = ?', { identifier })

  if not row then
    MySQL.insert.await(
      'INSERT INTO queue_qpoints (identifier, points, expires_at) VALUES (?, ?, ?)',
      { identifier, addPoints, newExpiry }
    )
    return true
  end

  local curPoints = tonumber(row.points) or 0
  local curExpiry = tonumber(row.expires_at) or 0

  if curExpiry > 0 and now() >= curExpiry then
    curPoints = 0
    curExpiry = 0
  end

  local finalPoints = curPoints + addPoints
  local finalExpiry = math.max(curExpiry, newExpiry)

  MySQL.update.await(
    'UPDATE queue_qpoints SET points = ?, expires_at = ? WHERE identifier = ?',
    { finalPoints, finalExpiry, identifier }
  )
  return true
end

local function getTotalPaidPoints(ids)
  local tier = getDiscordRolePoints(ids) or 0
  local manual = getManualPoints(ids) or 0
  local qid = getQIdentifier(ids)
  local qpts = qid and (dbGetQPoints(qid) or 0) or 0
  local grace = getGracePoints(ids) or 0
  return (tonumber(tier) or 0) + (tonumber(manual) or 0) + (tonumber(qpts) or 0) + (tonumber(grace) or 0)
end

-- =========================
-- TEBEX/CONSOLE COMMAND
-- queue_addpoints discord:ID points [days]
-- =========================
local function canUseAddPoints(source)
  if source == 0 then return true end
  if not (Config.QPoints and Config.QPoints.AllowInGameAce) then return false end
  return IsPlayerAceAllowed(source, (Config.QPoints.AcePermission or "queue.addpoints"))
end

RegisterCommand((Config.QPoints and Config.QPoints.CommandName) or "queue_addpoints", function(source, args)
  if not canUseAddPoints(source) then return end
  local identifier = args[1]
  local points = tonumber(args[2] or "0")
  local days = tonumber(args[3] or tostring((Config.QPoints and Config.QPoints.DefaultDurationDays) or 30))
  if not identifier or identifier == "" or not points or points <= 0 then
    print("^1Usage:^7 queue_addpoints discord:123456789012345678 10000 30")
    return
  end
  local ok, err = dbAddQPoints(identifier, points, days)
  if ok then
    print(("[QPOINTS] Added %d to %s for %d days"):format(points, identifier, days))
  else
    print(("[QPOINTS] Failed: %s"):format(tostring(err)))
  end
end, true)

-- =========================
-- CAPACITY
-- =========================
local function notFull(prio)
  local current = Queue:GetPlayerCount()
  local max = Queue.MaxPlayers

  local reserved = Config.ReservedSlots or 0
  local minPrio = Config.ReservedMinPriority or 0

  if reserved > 0 then
    if prio >= minPrio then return current < max end
    return current < (max - reserved)
  end

  return current < max
end

-- =========================
-- UI (text fallback)
-- =========================
local function buildMsg(pos, size, qTime, earned, paid, total, required)
  return string.format(
    Config.Language.line,
    pos, size, qTime,
    tonumber(earned) or 0,
    tonumber(paid) or 0,
    tonumber(total) or 0,
    tonumber(required) or 0
  )
end

-- =========================
-- UI (Adaptive Card with buttons)
-- =========================
local function buildQueueCard(pos, size, qTime, earned, paid, total, required)
  local links = Config.Links or {}
  return {
    ["$schema"] = "http://adaptivecards.io/schemas/adaptive-card.json",
    ["type"] = "AdaptiveCard",
    ["version"] = "1.4",
    ["body"] = {
      { ["type"]="TextBlock", ["text"]="Connecting – Queue", ["weight"]="Bolder", ["size"]="Large", ["wrap"]=true },
      { ["type"]="TextBlock", ["text"]=string.format("Pozícia: %d/%d", pos, size), ["wrap"]=true },
      { ["type"]="TextBlock", ["text"]=string.format("Čas: %s", qTime), ["wrap"]=true },
      { ["type"]="TextBlock", ["text"]=string.format("Earned: %d", tonumber(earned) or 0), ["wrap"]=true },
      { ["type"]="TextBlock", ["text"]=string.format("Paid: %d", tonumber(paid) or 0), ["wrap"]=true },
      { ["type"]="TextBlock", ["text"]=string.format("Spolu: %d/%d", tonumber(total) or 0, tonumber(required) or 0), ["wrap"]=true },
      { ["type"]="TextBlock", ["text"]="Odkazy:", ["weight"]="Bolder", ["spacing"]="Medium", ["wrap"]=true },
    },
    ["actions"] = {
      { ["type"]="Action.OpenUrl", ["title"]="Uskokavopic (Tebex)", ["url"]=links.TebexHome or "https://uskokavopic.tebex.io/" },
      { ["type"]="Action.OpenUrl", ["title"]="Discord", ["url"]=links.Discord or "https://discord.gg/8SD9yHF7" },
      { ["type"]="Action.OpenUrl", ["title"]="Shop", ["url"]=links.Shop or "https://uskokavopic.tebex.io/category/2002026" },
    }
  }
end

-- =========================
-- playerConnecting
-- =========================
local function playerConnect(_, _, deferrals)
  applySchedule()

  local src = source
  local ids = Queue:GetIds(src)
  local name = GetPlayerName(src)
  local connectTime = now()

  deferrals.defer()

  if not ids then deferrals.done(Config.Language.idrr) CancelEvent() return end
  if Config.RequireSteam and not Queue:IsSteamRunning(src) then deferrals.done(Config.Language.steam) CancelEvent() return end
  if Config.RequireDiscord and not getDiscordId(ids) then deferrals.done(Config.Language.discord) CancelEvent() return end

  if Config.AntiSpam then
    for i = (Config.AntiSpamTimer or 0), 0, -1 do
      deferrals.update(string.format(Config.PleaseWait or "Please wait %d", i))
      Wait(1000)
    end
  end

  local connecting = true
  CreateThread(function()
    while connecting do
      Wait(150)
      if connecting then deferrals.update(Config.Language.connecting) end
    end
  end)

  local pos, data = isInQueue(ids)
  local primary = getPrimaryId(ids)

  if not pos then
    if primary and EarnedBank[primary] == nil then
      EarnedBank[primary] = 0 -- ✅ earned začína od 0, potom rastie každému
    end

    table.insert(State.QueueList, {
      source = src,
      ids = ids,
      name = name,
      priority = getQueuePriority(ids),
      deferrals = deferrals,
      firstconnect = connectTime,
      queuetime = function() return (now() - connectTime) end,
      earnedPoints = primary and (EarnedBank[primary] or 0) or 0,
      paidPoints = getTotalPaidPoints(ids)
    })

    pos, data = isInQueue(ids)
  else
    data.source = src
    data.deferrals = deferrals
    data.name = name
  end

  if not pos or not data then
    connecting = false
    deferrals.done("Queue error [1]")
    CancelEvent()
    return
  end

  connecting = false

  while true do
    applySchedule()
    local required = tonumber(Config.MinJoinPoints) or 0

    Wait(500)

    local p, d = isInQueue(ids)
    if not p or not d or not d.deferrals then
      deferrals.done("[Queue] Removed (invalid data)")
      CancelEvent()
      return
    end

    local seconds = d.queuetime()
    local qTime = string.format("%02d:%02d:%02d",
      math.floor((seconds % 86400) / 3600),
      math.floor((seconds % 3600) / 60),
      math.floor(seconds % 60)
    )

    local prim = getPrimaryId(d.ids)
    local earned = prim and (EarnedBank[prim] or 0) or 0
    local paid = getTotalPaidPoints(d.ids)
    d.earnedPoints = earned
    d.paidPoints = paid

    local total = (tonumber(earned) or 0) + (tonumber(paid) or 0)

    if d.deferrals.presentCard then
      d.deferrals.presentCard(buildQueueCard(p, Queue:GetSize(), qTime, earned, paid, total, required))
    else
      d.deferrals.update(
        buildMsg(p, Queue:GetSize(), qTime, earned, paid, total, required)
        .. "\n\nUskokavopic: " .. (Config.Links and Config.Links.TebexHome or "https://uskokavopic.tebex.io/")
        .. "\nDiscord: " .. (Config.Links and Config.Links.Discord or "https://discord.gg/8SD9yHF7")
        .. "\nShop: " .. (Config.Links and Config.Links.Shop or "https://uskokavopic.tebex.io/category/2002026")
      )
    end

    if p <= 1 and notFull(d.priority or 0) and State.JoinDelay <= GetGameTimer() and total >= required then
      d.deferrals.update(Config.Language.joining)
      Wait(200)
      d.deferrals.done()
      table.remove(State.QueueList, p)
      return
    end
  end
end

AddEventHandler("playerConnecting", playerConnect)

-- =========================
-- playerDropped => GRACE BOOST
-- =========================
AddEventHandler("playerDropped", function()
  local src = source
  local ids = Queue:GetIds(src)

  if ids and Config.GraceBoost and Config.GraceBoost.Enabled then
    local gid = getGraceId(ids)
    if gid then
      Grace[gid] = now() + (Config.GraceBoost.DurationSeconds or 120)
    end
  end

  if State.PlayerList[src] then
    State.PlayerList[src] = nil
    State.PlayerCount = math.max(0, State.PlayerCount - 1)
  end
end)

RegisterServerEvent("Queue:playerActivated")
AddEventHandler("Queue:playerActivated", function()
  local src = source
  if not State.PlayerList[src] then
    State.PlayerList[src] = true
    State.PlayerCount = State.PlayerCount + 1
  end
end)

-- =========================
-- Earn tick + hostname + cleanup
-- Earned sa pridáva KAŽDÉMU V QUEUE ✅
-- =========================
CreateThread(function()
  while true do
    Wait(1000)

    applySchedule()

    State.tick = State.tick + 1

    -- EARN
    local interval = tonumber(Config.EarnInterval) or 0
    if interval > 0 and (State.tick % interval == 0) then
      for _, d in ipairs(State.QueueList) do
        local primary = d.ids and d.ids[1]
        if primary then
          local earned = EarnedBank[primary] or 0
          earned = capEarned(earned + (tonumber(Config.EarnAmount) or 0))
          EarnedBank[primary] = earned
          d.earnedPoints = earned
        end
      end
    end

    -- cleanup expired grace
    local t = now()
    for k, exp in pairs(Grace) do
      if exp <= t then Grace[k] = nil end
    end

    -- cleanup EarnedBank (odstráň earned pre id ktoré už nikto nemá v queue)
    do
      local seen = {}
      for _, d in ipairs(State.QueueList) do
        local primary = d.ids and d.ids[1]
        if primary then seen[primary] = true end
      end
      for primary, _ in pairs(EarnedBank) do
        if not seen[primary] then
          EarnedBank[primary] = nil
        end
      end
    end

    -- hostname queue count
    Queue.MaxPlayers = GetConvarInt("sv_maxclients", 30)
    Queue.Debug = GetConvar("sv_debugqueue", "true") == "true"
    Queue.DisplayQueue = GetConvar("sv_displayqueue", "true") == "true"

    if Queue.DisplayQueue and Queue.InitHostName then
      local qCount = Queue:GetSize()
      SetConvar("sv_hostname", (qCount > 0 and ("[" .. tostring(qCount) .. "] ") or "") .. Queue.InitHostName)
    end
  end
end)

if Config.DisableHardCap then
  AddEventHandler("onResourceStarting", function(resource)
    if resource == "hardcap" then CancelEvent() return end
  end)
  StopResource("hardcap")
end
