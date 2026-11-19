# Warung Brainrot Bazaar

[![make.fun · roblox-brainrot-01](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![make.fun · rank](https://make.fun/badge/roblox-brainrot-01/vyan0089-afk/roblox-brainrot-01/rank.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![make.fun · reward](https://make.fun/badge/roblox-brainrot-01/vyan0089-afk/roblox-brainrot-01/reward.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)

A 3D Roblox brainrot game for make.fun's "Make the best AI Roblox brainrot game" bounty (roblox-brainrot-01): a night-market / warung bazaar where absurd meme-born food characters earn cash a second.

**The loop:** brainrots ride the conveyor parade through the market — click one to buy it, it moves onto your base and earns $/s. Climb from a $5 Nasi Goreng Goblin to the $50,000/s Tsunami Sambal Titan. Steal rivals' brainrots and run home before they slap it out of your hands; lock your base to stop thieves. Outrun the Runaway Food Cart (Gerobak Liar) and the Sambal Tsunami wave. Rebirth 5 times, buy 5 upgrade tracks, hatch 3 kinds of eggs, adopt 6 pets, and complete the 60-entry Index book.

**The cast:** 60 original named brainrots across 7 rarities (Common → Secret) with 8 mutations (Spicy, Golden, Frozen, Rainbow, Shadow, Lava, Cosmic — up to ×10 income).

**Structure:** one-job modules, server owns all state (`src/server/StateStore.luau`), client only shows it and asks for it (`src/client/`), shared data in `src/shared/` (catalog, config, 3D models). The world is a real 3D place: plaza, conveyor belt, 8 player bases with pedestals, 10 warung stalls, rebirth shrine, egg stall, lanterns, hazard cart and tsunami wave.

- `main.ts` (Node 22, standard library only) hands the game in: it copies `game.rbxl`, `src/`, `screenshots/` and `PLAY.json` to `/output` and writes `/output/dossier.json` with `vendor/makefun-roblox.ts`, the kit's copy, unchanged.
- `game.rbxl` is the place Rojo builds from `src/` and `default.project.json` (`rojo build default.project.json --output game.rbxl`).
- `screenshots/` holds four renders of the game world; the first is the thumbnail. **Note:** no Roblox Studio exists on the Linux build machine, so these are stand-in renders drawn from the built world data, not Studio captures — real Studio screenshots are still needed before submit.

## Live game

The entry is published and playable at https://www.roblox.com/games/13067766964/Warung-Brainrot-Bazaar (universe 4565810974, place 13067766964). It went live on the account's default place, renamed "Warung Brainrot Bazaar" and set Public with the play code in its description, because Roblox offers no way to create a new experience from the web dashboard or the Open Cloud API — both routes require Roblox Studio (Windows/Mac). The game file itself was uploaded through the Open Cloud Assets API, and the icon + first thumbnail were set in the Creator Dashboard.
- `PLAY.json` names the live published place: universe 4565810974, place 13067766964 — https://www.roblox.com/games/13067766964/Warung-Brainrot-Bazaar (Public, description holds the play code `makefun-lemon-firefly-ribbon`).

Run it as the grader does, writing `out/` in place of `/output`:

    mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts

The rules are on the bounty's page (/bounty/roblox-brainrot-01) and in the kit's RULES.txt.
