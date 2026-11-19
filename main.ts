// Warung Brainrot Bazaar — the make.fun roblox-brainrot-01 entrypoint
// (Node 22, standard library only). The game itself is the Rojo project
// in this directory: `rojo build default.project.json --output game.rbxl`
// turns src/ + default.project.json into the place file. This program is
// only the handoff to the grader — it copies the built place, the Luau
// sources, the screenshots and PLAY.json into the output directory, then
// writes the dossier.json the judge reads, using the kit's vendored
// library (vendor/makefun-roblox.ts, unchanged).
//
// What the game is: a 3D night-market brainrot bazaar. Sixty original
// named brainrots in seven rarities with eight mutations ride a conveyor
// parade to be bought, live on eight player bases earning cash a second,
// and can be stolen from rivals (base lock + slap defence) while a
// runaway food cart and a sambal tsunami wave force a dash home.
// Rebirth, upgrades, eggs, pets and a 60-entry Index book finish it.
//
// Output names must start with a letter, digit or _ and hold only
// letters, digits, . _ and -; the grader refuses anything else, so a
// stray .gitkeep or .DS_Store copied in would fail the entry. Every
// directory copy below therefore skips names that start with a dot,
// at any depth.
//
// Outside the grader's container, MAKEFUN_OUTPUT_DIR stands in for
// /output:
//   mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts

import { copyFileSync, cpSync, existsSync, mkdirSync, writeFileSync } from 'node:fs';
import { basename, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildDossier } from './vendor/makefun-roblox.ts';

// The folder this file lives in, and the folder the grader reads.
const here = fileURLToPath(new URL('.', import.meta.url));
const out = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';

// The scorer's own caps, from the kit's reference/gate.json. Only
// text_max_bytes shapes the dossier bytes; the rest refuse an entry the
// scorer would refuse anyway (more than 4 screenshots or one over
// 256 KiB; a place of more than 500,000 instances; scripts totalling
// over 8 MiB of source or over 1,048,576 characters of paths).
const DOSSIER_CAPS = {
  text_max_bytes: 65536,
  screenshots: { max: 4, max_bytes: 262144 },
  max_instances: 500000,
  scripts_max_source_bytes: 8388608,
  scripts_max_path_chars: 1048576,
};

// Keep every name that does not start with a dot; drop .gitkeep,
// .DS_Store, .git and friends. Used as cpSync's filter.
const isVisibleName = (path: string): boolean => !basename(path).startsWith('.');

function handIn(): void {
  mkdirSync(out, { recursive: true });

  // The built place and the link to the live published experience.
  copyFileSync(join(here, 'game.rbxl'), join(out, 'game.rbxl'));
  copyFileSync(join(here, 'PLAY.json'), join(out, 'PLAY.json'));

  // The Luau sources the place was built from, and the screenshots.
  cpSync(join(here, 'src'), join(out, 'src'), { recursive: true, filter: isVisibleName });
  mkdirSync(join(out, 'screenshots'), { recursive: true });
  if (existsSync(join(here, 'screenshots'))) {
    cpSync(join(here, 'screenshots'), join(out, 'screenshots'), { recursive: true, filter: isVisibleName });
  }

  // The judge's summary of the game, built from the handed-in files.
  writeFileSync(join(out, 'dossier.json'), buildDossier(out, DOSSIER_CAPS));
}

handIn();
