# No frontier : Vietnam

No frontier : Vietnam is a real-time tactical war game set in the Vietnam War era.
It combines a strategic grand map with real-time tactical battles, both running on a single continuous timeline.

<img src="https://raw.githubusercontent.com/renosyah/no-frontier/refs/heads/master/concept/new_bg.png" height="600" />

---

## Overview

This project is a **tile-based grand strategy + tactical battle game** set in the Vietnam War era.  
Players manage factions, bases, units, and logistics on a **Grand Map**, while battles are resolved on **Battle Maps** generated per tile.

The design prioritizes:
- Clear mechanics
- Player-controlled engagement
- Performance-friendly systems
- Practical, non-overdesigned solutions

Procedural-only level design is intentionally avoided — a **map editor is a core feature**.

---

## Base & Logistics

<img src="https://raw.githubusercontent.com/renosyah/no-frontier/refs/heads/master/assets/background/main_menu.png" height="400"/>

Bases are the heart of your operation.  
From here you create squads, resupply weapons, repair vehicles, and manage manpower.  
Bases are static in the current scope but can be placed anywhere on controlled tiles.

## Command & Planning

<img src="https://raw.githubusercontent.com/renosyah/no-frontier/refs/heads/master/assets/background/pre_match.png" height="400" />

All operations are planned from the command layer.  
Players monitor troop movement, initiate ambushes, request indirect fire support, and decide when to zoom into battle maps.

---

## Map System

### Grand Map
- Square tile grid
- Movement limited to **4 directions**
- Tile types:
  - **Ground**
  - **Water** (no battle map, not editable)
- Each ground tile may contain:
  - Battle map
  - Base
  - Capture point

### Battle Map
- Each grand map ground tile has its own battle map
- Tile movement allows **8 directions (including diagonal)**
- Tiles are logical points (not visible squares)
- Terrain:
  - Ground
  - Objects (trees, rocks)
- Simple mesh, optimized for performance
- A* pathfinding works directly on this grid

---

## Battle Map Lifecycle Rules

- If a battle map contains **units from only one side**, it is **force-closed**
- Units may **enter** an active battle map freely
- Units **cannot exit** a battle map once entered  
  *(considered deserters — design choice for simplicity)*

---

## Factions

### MACV (US Forces)
- Regular infantry squad
- SOG squad
- ground Vehicles and helicopters
- Static bases (mobile bases deferred to future scope)

### NVA / VC
- Infantry squads
- can camp anytile
- have +1 soldier per squad
- ground Vehicles
- Static bases (mobile bases deferred to future scope)

---

## Units

### Squads
- Created only via **Barracks**
- Must be on base tile to be edited
- Squad selection:
  - Shows all soldier info
  - Can enter/exit vehicles
  - Can exit battle map

### Individual Soldiers
- Selection shows only that soldier
- Used for:
  - manual movement on battle
  - uses ability : Grenades (x3)
  - uses ability : Launchers (x1)

---

## Special Unit: MACV-SOG

**Elite special forces squad (2–4 soldiers)**

### Core Rules
- Only **1 SOG unit** can exist at a time
- Limited to **3 total deployments** (finite use)
- Cannot be created via Barracks
- Deployed via a **special button**
- Spawns instantly on a base tile

### Capabilities
- Invisible on grand map from enemy POV
- Cannot be detected or engaged on grand map
- Can occupy same tile as enemy without detection
- Scouts adjacent tiles
- Reveals enemy movement
- Extremely strong vs infantry (1:1)
- Extremely weak vs overwhelming forces

### Logistics
- Can camp (friendly tile only)
- Can return to base to rearm and heal
- Cannot be edited via Barracks

### Deployment
- Helicopter transport is visible
- Helicopter disembark:
  - Regular units: must land
  - SOG: fast rope insertion

---

## Bases (Static Only)

Base interaction is **click-to-open menu**.

### Buildings
- **HQ**
  - Base movement (next scope)
  - Building management : add building to base on preset localtion
- **Barracks**
  - Create squads & amount of initial ammo
  - Add/remove soldiers
- **Armory**
  - Manage squad & vehicle ammo
- **Fuel Depot**
  - Manage vehicle fuel
- **Medical Center**
  - remove soldier from squad to be heal (add to manpower)
  - Partial healing via camping only
- **Helipad** (multiple allowed)
  - Request helicopters
  - Land & repair helicopters
- **Vehicle Depot**
  - Request and repair ground vehicles

### Notes
- Resupply/refuel does **not** require proximity to building
- Removing wounded soldiers sends them automatically to medical pool

---

## Camp Mechanic

- Activated manually via **Camp button**
- Camp has a **timer**
- Automatically ends when timer finishes

### Effects
- Resets **weapon degradation**
- Medkits restore **only 1 HP bar**
- Full healing requires Medical Center

---

## Weapon Degradation

- Weapons degrade over time
- Effects:
  - Reduced accuracy
  - Chance to jam
- Camping resets degradation
- Inspired by realism and gameplay necessity

---

## Weapons

### Rifles (Primary Infantry)
- **M16** – 18 / 420
- **Type 56** – 30 / 360

### SMGs (Limited Use)
- **M1A1 Grease Gun**
- **PPSh-43**
- Ammo: 30 / 560

#### SMG Restrictions
- Vehicle crew only
- Select soldiers in squads
- Not standard infantry weapons

---

## Vehicles & Transport

### Ground Vehicles
- Drop squads on grand map with a timer
- Repairable at Vehicle Depot

### Helicopters
- Visible on grand map
- Must land to deploy regular troops
- SOG can deploy via rope
- In battle map:
  - Passengers stay inside
  - Manual action required to disembark

---

## Ambush System

- Player-controlled initiation
- When enemy enters tile:
  - Ambush icon appears with timer
- Player may start battle if:
  - Battle map quota is available

### Ambush Entry
- Enemy enters normally
- Ambusher enters from chosen edge
- Two movement modes:
  - Move only
  - Move + attack anything on path

---

## Capture Points & NPC Factions

### When Captured by MACV
- Weapon caches destroyed
- US & South Vietnam flags placed

### When Captured by NVA
- Flags removed
- Weapon cache spawned
- VC squad spawns (1 squad max)
- VC attempts to prevent recapture

### Weapon Cache
- Can only be destroyed using:
  - Grenades
  - Launchers

---

## Indirect Fire Support (Next Scope)

- **Mortar Team**
  - Indirect fire
  - Random impact on battle maps
- **Towed Artillery**
  - Must be set up first
  - Direct fire only

---

## Base Attack Restrictions (Revised)

- Enemy bases **cannot be attacked directly**
- Battle map locked until:
  - All capture points secured
  - Continuous tile connection from player base to enemy base exists

---

## Map Editor (Core Feature)

### Features
- Generate & edit grand map
- Save/load maps as files
- Edit battle map per tile

### Editing Rules
- Grand map:
  - Ground & water only
- Battle map:
  - Ground & objects only

> Procedural-only generation is intentionally avoided due to poor level quality.

---

## Current Scope Limitations

- No mobile bases (planned for later)
- No full medic carry system (deferred)
- Static bases only
- Infantry-focused combat

---

## Status

**Active design phase – mechanics locked, content expanding**

---

## Inspiration

- Arma 3 – Warlords
- Vietnam War asymmetric warfare
- Tactical realism with pragmatic design choices

### About GoDot
See [GoDot Game Engine](https://godotengine.org).