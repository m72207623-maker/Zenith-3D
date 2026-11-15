# ZENITH - Space Mission Design Game

**ZENITH** is a 3D educational game about designing space missions, built for the **NASA Space Apps Challenge 2026**
(*Space Mission Design Game*). You do not just fly a rocket - you act as the mission designer: pick a science goal,
design the spacecraft and the launch vehicle under budget, mass and power constraints, pass a verification review,
launch, and find out how much science your design actually returns.

> Engine: Godot 4.7 (Forward+), GDScript only. Languages: English and Ukrainian. Prototype build.

## The idea: the NASA design loop

Every mission follows the same loop, inspired by the NASA systems-engineering process:

**Scientific objective -> Requirements -> Mission design -> Verification -> Launch -> Operations -> Science results**

1. **Science goal and payload lab** - choose what the mission should learn and design the payload (instrument, power, battery, antenna, ...).
2. **Rocket designer (mandatory in every mission)** - pick fairing, tank, engine, upper stage and (from Mission 4) strap-on boosters.
   Live stats: mass, propellant, thrust, thrust-to-weight, delta-v, reliability, cost against a budget.
3. **Mission Validation** - a requirements checklist with explanations (OK / RISK / FAIL) before you are allowed to launch.
4. **Launch** - an ascent through max-Q and stage separations to orbit, flown by the **autopilot** (default), with
   **Assisted** and **Manual** modes available.
5. **Operations** - the mission-specific phase (satellite operations, spacewalk, docking, constellation, lunar expedition).
6. **Results** - stars, a "Mission Success Proximity" score with a personal best, and an explanation of what helped or hurt.

The four NASA mission segments are modelled: **Launch**, **Space**, **Ground** (downlink windows) and **Users** (what the data is worth).

## The five missions

| # | Mission | What you do |
|---|---------|-------------|
| 1 | **First Launch** | Choose a science goal, design a satellite and a rocket, reach orbit, deploy and downlink data. |
| 2 | **Space Operations** | Design an EVA package (oxygen, gas, suit) and its launch vehicle, then perform a spacewalk repair. |
| 3 | **ISS Expedition** | Design a science cargo and rocket, launch to the station, rendezvous and dock. |
| 4 | **Satellite Constellation** | Heavy multi-stage rocket with boosters; deploy several satellites into evenly spaced orbital slots (prototype). |
| 5 | **Moon and Return** | Heavy launch, trans-lunar burn, lunar orbit insertion, lander separation and powered landing, astronaut EVA (drive, sample, return to the module), ascent and docking with the command ship, crew transfer, trans-Earth burn, capsule separation, re-entry, parachutes and splashdown. Every stage has an autopilot (default); the ascent stage and the capsule heat shield you chose decide success. |

Missions unlock one after another and progress is saved. New rocket parts unlock as the campaign advances.
A **Demo Mode** (Settings) unlocks every mission and adds a demonstration rocket in the designer.

## Features

- Full 3D scenes: launch site, rocket with visible stage / booster / fairing separation, Earth, Moon, station, free orbit camera.
- Rocket designer with required-part markers, drag and drop, validation and budget bars.
- Flight physics with gravity, atmosphere, drag, max-Q, staging and orbital elements (apoapsis / periapsis).
- Flight modes: **Automatic** (autopilot flies, take over with any control key or `M`), **Assisted** (guide shows the next step),
  **Manual**.
- Adaptive UI: scales from 1280x720 to 4K, 16:9 / 16:10 / 21:9, fullscreen by default (Alt+Enter), windowed mode in Settings.
- English / Ukrainian, switchable at runtime in Settings.
- In-game **NASA Resources** screen (main menu) with the NASA material that inspired the game.

## Controls

| Key | Action |
|-----|--------|
| `W` / `S` | Throttle up / down (Mission 1 launch) |
| `A` / `D` | Pitch |
| `Z` / `X` | Full throttle / engine cut |
| `G` / `B` / `F` | Separate stage / boosters / jettison fairing (available only when safe) |
| `T` | Prograde hold |
| `M` | Autopilot on / off (any steering key also takes over) |
| `H` | Guided launch hints on / off |
| `1` `2` `3` | Time warp |
| `SPACE` | Deploy payload |
| `C` / `R` | Free camera (pauses the simulation) / reset camera |
| Mouse | Left drag rotate, wheel zoom, right drag pan (over the 3D view) |
| `F1` | Help |
| `ESC` | Pause |
| `Alt+Enter` | Fullscreen / windowed |

Missions 2-5 list their specific controls in the briefing screen.

## NASA Resources

Open **NASA Resources** from the main menu to see these links with a short note on how each is used.
The game is a simplified educational model - these sources informed the design, they are not a data source for the physics.

| Resource | Used for |
|----------|----------|
| [NASA Systems Engineering Handbook](https://www.nasa.gov/reference/systems-engineering-handbook/) | The design loop: requirements, verification, validation, operations |
| [NASA Glenn - Rocket Propulsion](https://www.grc.nasa.gov/www/k-12/airplane/rocket.html) | Thrust, specific impulse, rocket equation, staging |
| [NASA Space Place - What Is an Orbit?](https://spaceplace.nasa.gov/orbits/en/) | Orbit basics shown in the flight HUD |
| [NASA Earth Science](https://science.nasa.gov/earth/) | Mission 1 science goals (Earth observation) |
| [NASA Earth Observatory](https://earthobservatory.nasa.gov/) | Imaging instruments and science return |
| [NASA Worldview](https://worldview.earthdata.nasa.gov/) | Real satellite imagery as the "user" of the data |
| [NASA Heliophysics](https://science.nasa.gov/heliophysics/) | Space-weather science goal |
| [International Space Station](https://www.nasa.gov/international-space-station/) | Missions 2 and 3: EVA, rendezvous and docking |
| [NASA Small Spacecraft Systems Virtual Institute](https://www.nasa.gov/smallsat-institute/) | Mission 4: small satellites and constellations |
| [NASA Artemis](https://www.nasa.gov/humans-in-space/artemis/) | Mission 5: heavy launch, trans-lunar injection, landing, return |
| [NASA - Earth's Moon](https://science.nasa.gov/moon/) | Mission 5: lunar environment and science |
| [NASA - Apollo 11](https://www.nasa.gov/mission/apollo-11/) | Mission 5: landing and return profile |

Event: [NASA Space Apps Challenge](https://www.spaceappschallenge.org/)

## Honest limitations

- Physics is **simplified on purpose**: a scaled-down Earth (radius 1600 km) so one stage can reach orbit, fixed eclipse and
  contact times, shortened lunar surface day, simplified lunar-orbit insertion. It teaches trade-offs; it is not GMAT-grade analysis.
- Missions 4 and 5 are playable prototypes (Mission 4 phasing, Mission 5 return legs are decisions with real numbers rather than full flight simulation).
- Tested on Windows. Needs a GPU that supports the Forward+ renderer.

## Technology

- **Godot 4.7**, GDScript, Forward+ renderer; 3D with procedural planet / sky shaders.
- Models generated procedurally with **Blender** (script in `Tools/blender/`) and exported as `.glb`.
- Sound effects are synthesised at runtime; background music is two tracks in `Assets/Audio` (calm: menus, designer, briefings; energetic: launch and active mission phases) managed by the `AudioManager` autoload with crossfades, a seamless loop and Music / SFX buses (Settings: Music volume, SFX volume, Music on/off).
- Localisation through Godot `TranslationServer` (`Core/strings_*.gd`).

## Run the project

1. Install [Godot 4.7](https://godotengine.org/download) (standard build).
2. Open `project.godot` in Godot and press **F5** (or run `Godot --path .`).
3. Fullscreen is the default; change it in **Settings**.

## Project layout

```
Core/            autoloads (Loc, GameState, Router, Sfx), UI kit, translations
Core3D/          3D toolkit: space stage, rocket, launch pad, cameras, shaders
Assets/Models/   .glb models
Menus/TempMenu/  main menu, mission select, settings, NASA Resources
Missions/        MissionN/ - one folder per mission; Shared/ - briefing, pause, results, launch profiles
Tools/           automated tests, balance simulation, screenshot helpers
```

## Tests

```
# compile check of every script
Godot --headless --path . res://Tools/compile_check.tscn --quit-after 120
# EN/UK string audit
Godot --headless --path . --script res://Tools/check_strings.gd
# UX / menus / gated separations / autopilot
Godot --headless --fixed-fps 60 --path . --script res://Tools/ux_test.gd --quit-after 400000
# full 5-mission playthrough with real input events
Godot --headless --fixed-fps 60 --path . --script res://Tools/play_full.gd --quit-after 900000
```

## Credits and licences

**Music composed and produced by Danylo Seredniak.** The two soundtrack tracks (`Assets/Audio/music_calm.mp3`, `music_action.mp3`) are original works created by a member of the ZENITH team.

Game code and generated assets: ZENITH team. Engine: [Godot Engine](https://godotengine.org/license/) (MIT).
Models built with [Blender](https://www.blender.org/). NASA is credited as an inspiration and reference only;
ZENITH is not affiliated with or endorsed by NASA.
