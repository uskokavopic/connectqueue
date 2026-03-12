# 🚀 CONNECTQUEUE
CONNECTQUEUE is an advanced, high‑performance and fully configurable queue system for FiveM servers.  
It is designed for **OneSync Infinity**, large RP communities and servers with heavy player traffic.

The system combines:
- **Earned Points** (free for everyone)
- **Paid Points** (Discord Tiers, Tebex QPoints, manual priority)
- **Grace Points** (after crash/restart)
- **Peak Time Requirements** (higher point limit during busy hours)
- **Anti‑Spam Cooldown**
- **Deferrals‑based queue UI**

---

# 🎯 What CONNECTQUEUE Solves
- chaos after server restart  
- connect‑spam  
- unfair queue skipping  
- VIP monetization  
- Tebex integration  
- stability for 100–300+ players  
- fair waiting system for everyone  

---

# ⭐ Key Features
- fully functional **deferrals queue**
- **Earned Points** – players gain points automatically every X seconds
- **Discord Tier Points** – VIP points based on Discord roles
- **Tebex QPoints** – purchased points stored in DB (with expiration)
- **Grace Points** – huge temporary boost after crash
- **Peak Time System** – higher requirements during busy hours
- **Anti‑Spam Cooldown** – blocks rapid reconnect attempts
- **Priority System** – manual priority by identifier
- **Reserved Slots** – for admins / VIP
- **Database system** for QPoints
- clean queue UI messages
- stable for large servers

---

# 🧮 Points System (Core Logic)
Each player has:

### 1️⃣ **EARNED POINTS**  
Automatically generated every X seconds.  
Encourages fair waiting.

### 2️⃣ **PAID POINTS**  
- Discord Tier points  
- Tebex QPoints  
- manual priority  
- Grace Points  

### 3️⃣ **TOTAL POINTS**  
```
TOTAL = EARNED + PAID
```

A player can join the server when:
```
TOTAL ≥ MinJoinPoints
```

---

# ⏰ Peak Time System
CONNECTQUEUE includes a **Peak Time window**, where players must meet a higher point requirement to join.

Example:
```lua
Config.PeakTime = {
    Enabled = true,
    From = 18,   -- 18:00
    To = 23,     -- 23:00
    RequiredPoints = 5000
}
```

### How it works:
- outside Peak Time → only MinJoinPoints required (e.g., 3000)
- during Peak Time → player must meet RequiredPoints (e.g., 5000)

This prevents low‑priority players from entering during busy hours.

---

# 🛡️ Anti‑Spam Cooldown
Prevents players from spamming the connect button.

Benefits:
- protects the server after restart  
- stabilizes queue order  
- reduces lag  
- stops reconnect abuse  

---

# 💎 Discord Tiers (VIP System)
Players receive points based on their highest Discord role:

```lua
Config.Discord.RolePoints = {
    ["ROLE_ID_TIER1"] = 3000,
    ["ROLE_ID_TIER2"] = 5000,
    ["ROLE_ID_TIER3"] = 7000,
    ["ROLE_ID_TIER4"] = 10000,
}
```

---

# 💰 Tebex QPoints (DB + Expiration)
- points purchased via Tebex  
- stored in database  
- expire after X days (default 30)  
- stackable  

SQL file:
```
sql/queue_qpoints.sql
```

---

# 🛟 Grace Points (Crash Protection)
If a player crashes or disconnects unexpectedly, they receive a temporary boost:

```lua
Config.GraceBoost = {
    Enabled = true,
    DurationSeconds = 120,
    Points = 2000000
}
```

This ensures they can return without waiting.

---

# 🧠 Earned Points
```lua
Config.EarnInterval = 30
Config.EarnAmount = 100
Config.MaxEarnedPoints = 3000
```

---

# 🥇 Priority System
```lua
Config.Priority = {
    ["discord:123456789012345678"] = 50
}
```

---

# 🎫 Reserved Slots
```lua
Config.ReservedSlots = 2
Config.ReservedMinPriority = 50
```

---

# 📦 Installation
1. Place `connectqueue` into your `resources/` folder  
2. Import SQL:
```
sql/queue_qpoints.sql
```
3. Add to `server.cfg`:
```cfg
ensure oxmysql
ensure connectqueue
set sv_maxclients ""
set sv_debugqueue "false"
set sv_displayqueue "true"
```

---

# 🧰 Admin Commands
Add QPoints:
```
queue_addpoints discord:123456789012345678 7000 30
```

---

# 📁 Resource Structure
```
connectqueue/
├── fxmanifest.lua
├── config.lua
├── sql/
│   └── queue_qpoints.sql
├── client/
│   └── client.lua
└── server/
    └── server.lua
```

---

# 📝 License
MIT License – free to modify and use on your server.

---

# ❤️ Author
Created by **Uskokavopic**  
Optimized for the FiveM ecosystem of 2026.
