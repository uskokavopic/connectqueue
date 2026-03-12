# 🚀 CONNECTQUEUE
CONNECTQUEUE je pokročilý, výkonný a plne konfigurovateľný queue systém pre FiveM servery.  
Je navrhnutý pre **OneSync Infinity**, veľké RP komunity a servery s vysokým náporom hráčov.

Systém kombinuje:
- **Earned body** (zadarmo pre každého)
- **Paid body** (Discord Tiers, Tebex QPoints, manuálne priority)
- **Grace body** (po páde hry)
- **Peak Time požiadavky** (vyšší limit bodov počas špičky)
- **Anti‑spam ochranu**
- **Deferrals queue** s detailnými informáciami pre hráča

---

# 🎯 Čo CONNECTQUEUE rieši
- chaos po reštarte servera  
- spamovanie pripojenia  
- neférové predbiehanie  
- VIP systém  
- monetizáciu cez Tebex  
- stabilitu pri 100–300+ hráčoch  
- férové čakanie pre všetkých  

---

# ⭐ Hlavné funkcie
- plne funkčný **deferrals queue**
- **Earned body** – hráč získava body každých X sekúnd
- **Discord Tier body** – automatické VIP body podľa role
- **Tebex QPoints** – body zakúpené cez obchod (DB + expirácia)
- **Grace body** – obrovský boost po páde hry
- **Peak Time systém** – vyššie požiadavky počas špičky
- **Anti‑spam cooldown** – blokuje rýchle reconnecty
- **Priority systém** – manuálne priority podľa identifikátora
- **Reserved slots** – miesta pre adminov / VIP
- **DB systém** pre QPoints
- prehľadné UI texty v queue
- stabilita pre veľké servery

---

# 🧮 Body systém (jadro queue)
Každý hráč má:

### 1️⃣ **EARNED BODY**  
Získava automaticky každých X sekúnd.  
Motivuje hráčov čakať férovo.

### 2️⃣ **PAID BODY**  
- Discord Tier body  
- Tebex QPoints  
- manuálne priority  
- Grace body  

### 3️⃣ **TOTAL BODY**  
```
TOTAL = EARNED + PAID
```

Hráč sa dostane na server, keď:
```
TOTAL ≥ MinJoinPoints
```

---

# ⏰ Peak Time systém
CONNECTQUEUE umožňuje nastaviť **časové okno**, počas ktorého musí hráč splniť vyšší limit bodov.

Príklad:
```lua
Config.PeakTime = {
    Enabled = true,
    From = 18,   -- 18:00
    To = 23,     -- 23:00
    RequiredPoints = 5000
}
```

### Ako to funguje:
- mimo špičky → stačí MinJoinPoints (napr. 3000)
- počas špičky → musí mať PeakTime.RequiredPoints (napr. 5000)

Toto zabraňuje tomu, aby sa večer dostali na server hráči bez bodov.

---

# 🛡️ Anti‑Spam Cooldown
Systém blokuje hráčov, ktorí sa snažia pripájať príliš rýchlo.

Výhody:
- žiadne spamovanie connectu  
- stabilita po reštarte  
- férové poradie  
- menej lagov  

---

# 💎 Discord Tiers (VIP systém)
Hráč dostane body podľa najvyššej role:

```lua
Config.Discord.RolePoints = {
    ["ROLE_ID_TIER1"] = 3000,
    ["ROLE_ID_TIER2"] = 5000,
    ["ROLE_ID_TIER3"] = 7000,
    ["ROLE_ID_TIER4"] = 10000,
}
```

---

# 💰 Tebex QPoints (DB + expirácia)
- body zakúpené cez Tebex  
- ukladajú sa do databázy  
- majú expiráciu (default 30 dní)  
- stackujú sa  

SQL súbor:
```
sql/queue_qpoints.sql
```

---

# 🛟 Grace body (po páde hry)
Ak hráč spadne alebo crashne, dostane dočasný boost:

```lua
Config.GraceBoost = {
    Enabled = true,
    DurationSeconds = 120,
    Points = 2000000
}
```

Pomáha hráčom dostať sa späť bez čakania.

---

# 🧠 Earned body
```lua
Config.EarnInterval = 30
Config.EarnAmount = 100
Config.MaxEarnedPoints = 3000
```

---

# 🥇 Priority systém
```lua
Config.Priority = {
    ["discord:123456789012345678"] = 50
}
```

---

# 🎫 Reserved slots
```lua
Config.ReservedSlots = 2
Config.ReservedMinPriority = 50
```

---

# 📦 Inštalácia
1. Nakopíruj `connectqueue` do `resources/`
2. Spusti SQL:
```
sql/queue_qpoints.sql
```
3. Do `server.cfg` pridaj:
```cfg
ensure oxmysql
ensure connectqueue
set sv_maxclients ""
set sv_debugqueue "false"
set sv_displayqueue "true"
```

---

# 🧰 Admin príkazy
Pridanie QPoints:
```
queue_addpoints discord:123456789012345678 7000 30
```

---

# 📁 Štruktúra projektu
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

# 📝 Licencia
MIT License – môžeš upravovať a používať na svojom serveri.

---

# ❤️ Autor
Vytvoril **Uskokavopic**  
Optimalizované pre FiveM ekosystém roku 2026.
