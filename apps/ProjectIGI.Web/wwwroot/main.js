// Starts the game in the page: WebGPU first, then the installation, then the runtime, then a frame per
// animation frame -- and gives the page back when the game ends.
//
// The order is forced by the browser. The adapter and the device are promises, and nothing inside the
// runtime can wait on one, so they are acquired here and handed to the WebGPU bridge before the game
// asks for them. The installation is read before Boot because the host reads its files by path from the
// first frame.
//
// This boots the fork's host (exports.ProjectIGI.Web.Program), not upstream's: the game that runs here
// is the mobile build's code. Single-player only, folder-pick only -- no rooms, no Discord Activity,
// and the site hosts no game files.

import { dotnet } from './_framework/dotnet.js';
import './wgpu-bridge.js';
import * as platform from './platform.js';
import * as audio from './audio.js';
import * as files from './game-files.js';
import * as userFiles from './user-files.js';
import * as landingAudio from './landing-audio.js';

const GAME_ROOT = '/game';

// Every file the page loads is listed for the service worker once the game is up (keepShell), so the list must not stop at
// the browser's default of 250 entries: the runtime alone is more, and a short list would let the worker drop files the page
// still needs.
performance.setResourceTimingBufferSize?.(10000);

const $ = id => document.getElementById(id);
const canvas = $('view');
const landing = $('landing');
const play = $('play');
const change = $('change');

const query = new URLSearchParams(location.search);
const args = (query.get('args') ?? '').split(' ').filter(Boolean);

// --- Which game ----------------------------------------------------------------------------------------
//
// The browser card plays either game: ?game=igi2 links to one, and the switch's last choice is kept for the next
// visit.

const GAME_KEY = 'openigi-game';

// The page kept for a visit with no network (sw.js): not for an automated run's served folder (?data=), and not when
// asked not to (?sw=0).
const OFFLINE_SHELL = 'serviceWorker' in navigator && window.isSecureContext
  && !query.has('data') && query.get('sw') !== '0';
if (OFFLINE_SHELL) {
  navigator.serviceWorker.register('sw.js').catch(error => console.warn(`The page can't be kept for offline play: ${error.message}`));
}

/** Tells the service worker every file of the page's the game loaded, so it keeps them all and lets older ones go. */
function keepShell() {
  if (!OFFLINE_SHELL) return;
  navigator.serviceWorker.ready.then(registration => {
    // The game's own files are not the page's: game-files.js keeps those, and a data host on the page's own address (a local
    // test server's /data/) would otherwise have them copied here a second time.
    const urls = performance.getEntriesByType('resource').map(entry => entry.name)
      .filter(name => name.startsWith(registration.scope) && !name.startsWith(`${registration.scope}data/`));
    registration.active?.postMessage({ type: 'keep', urls });
  }).catch(() => {});
}

function savedGame() {
  try {
    return localStorage.getItem(GAME_KEY);
  } catch {
    return null; // Storage blocked: the default.
  }
}

let game = [query.get('game'), savedGame()].find(id => id in files.TITLES) ?? 'igi1';

// Sent here by the game's own switcher: played at once. Taken off the address, so reloading by hand later lands on
// the page as usual.
const SWITCHED = query.has('play');
if (SWITCHED) {
  const address = new URL(location.href);
  address.searchParams.delete('play');
  history.replaceState(null, '', address.href);
}

// --- The dossier: what the page says about each game ---------------------------------------------------
//
// The mission names are the games' own (their mission lists, in campaign order). The words around
// them are the page's, written for it — not the guide pages' copy, and the briefings stay in the game.

const DOSSIER = {
  igi1: {
    brief: 'Fourteen missions, one operative. Get Priboi out, steal Ekk\u2019s plans, find the bomb — the original Project I.G.I., in the browser, with your own copy of the game.',
    missionsIntro: 'Fourteen missions across Eastern Europe, from a coastline trainyard to a nuclear base.',
    campaigns: [
      { name: 'CAMPAIGN', note: 'ONE CAMPAIGN · 14 MISSIONS', missions: [
        'Trainyard', 'SAM Base', 'Military Airbase', 'GOD', 'Radar Base', 'Get Priboi',
        'Border Crossing', 'Re-supply', 'Missile Trainyard', 'Defend Priboi',
        'Eagle\u2019s Nest I', 'Eagle\u2019s Nest II', 'Nuclear Infiltration', 'Finding the bomb',
      ] },
    ],
    intel: [
      { file: 'STORY.TXT', note: 'HOW IT UNFOLDS', body: 'Jones goes in alone. Break Josef Priboi out of an airbase, kidnap his brother Jach, cross the border, and storm Ekk\u2019s fortress to find a nuclear bomb before it goes off.' },
      { file: 'CHARACTERS.TXT', note: 'WHO IS WHO', body: 'David Jones — the operative. Anya — his handler, on the radio. Josef Priboi — the man to rescue. Jach Priboi and Ekk — the opposition.' },
    ],
  },
  igi2: {
    brief: 'Nineteen missions in three campaigns. David Jones follows a stolen EMP chip from a Libyan mine through Russia to a launch pad in China — alone, and in the browser, with your own copy of the game.',
    missionsIntro: 'Nineteen missions in three campaigns: the chip trail, Priboi, and the launch pad.',
    campaigns: [
      { name: 'CAMPAIGN 1', note: 'LIBYA · 7 MISSIONS', missions: [
        'Infiltration', 'Deep in the Mines', 'The Weather Station', 'Bridge Across the Dnestr',
        'Ambush', 'Production Facility', 'Border Crossing',
      ] },
      { name: 'CAMPAIGN 2', note: 'LIBYA AND RUSSIA · 6 MISSIONS', missions: [
        'Libyan Rendezvous', 'Prison Escape', 'Priboi\u2019s Villa', 'The Airfield',
        'Zaleb\u2019s Stronghold', 'Showdown at the Docks',
      ] },
      { name: 'CAMPAIGN 3', note: 'CHINA · 6 MISSIONS', missions: [
        'Island Assault', 'Air-Strike', 'The Ancient Temple', 'Secret Weapons Lab',
        'Mission Control', 'The Launch Pad',
      ] },
    ],
    intel: [
      { file: 'STORY.TXT', note: 'HOW IT UNFOLDS', body: 'A prototype EMP chip — a weapon that kills electronics across a battlefield — has gone missing. David Jones follows it from a mine in Libya through a prison, a villa and an airfield in Russia, to an island launch site in China. He works alone; Anya runs him from the radio.' },
      { file: 'CHARACTERS.TXT', note: 'WHO IS WHO', body: 'David Jones — the operative on the ground. Anya — his handler, on the radio. Josef Priboi — the arms dealer at the centre of it all. Robert Quest, Zaleb, Wu Xing — the men standing between Jones and the chip.' },
    ],
  },
};

/** The intel files both games share. */
const INTEL_COMMON = [
  { file: 'CONTROLS.TXT', note: 'KEYS AND TOUCH', body: 'Mouse to aim, WASD to move, on a computer. Twin sticks and touch buttons on a phone. Every binding can be changed in the game\u2019s own options.' },
  { file: 'REQUIREMENTS.TXT', note: 'WHAT IT NEEDS', body: 'A browser with WebGPU — a current Chrome or Edge on a computer, Safari on an iPhone or iPad. Your own copy of the game, picked once in the browser. About 40 MB downloads on the first visit and is kept for the next.' },
];

/** The dossier for one game: its brief, its mission files, its intel. */
function renderDossier(id) {
  const dossier = DOSSIER[id];
  $('game-brief').textContent = dossier.brief;
  $('missions-intro').textContent = dossier.missionsIntro;
  const total = dossier.campaigns.reduce((sum, campaign) => sum + campaign.missions.length, 0);
  $('mission-count').textContent = `[ALL ${total}]`;
  const list = $('mission-list');
  list.replaceChildren();
  let number = 0;
  for (const campaign of dossier.campaigns) {
    const group = document.createElement('div');
    group.className = 'campaign';
    const head = document.createElement('h3');
    head.textContent = campaign.name;
    const note = document.createElement('span');
    note.textContent = ` — ${campaign.note}`;
    head.append(note);
    group.append(head);
    const missions = document.createElement('ol');
    missions.className = 'missions';
    for (const name of campaign.missions) {
      number++;
      const row = document.createElement('li');
      const num = document.createElement('span');
      num.className = 'num';
      num.textContent = String(number).padStart(2, '0');
      const label = document.createElement('span');
      label.className = 'mname';
      label.textContent = name;
      row.append(num, label);
      missions.append(row);
    }
    group.append(missions);
    list.append(group);
  }
  const intel = $('intel-list');
  intel.replaceChildren();
  for (const entry of [...dossier.intel, ...INTEL_COMMON]) {
    const file = document.createElement('details');
    const head = document.createElement('summary');
    head.textContent = entry.file;
    const note = document.createElement('span');
    note.className = 'file-note';
    note.textContent = entry.note;
    head.append(note);
    const body = document.createElement('p');
    body.className = 'file-body';
    body.textContent = entry.body;
    file.append(head, body);
    intel.append(file);
  }
}

/** Shows a game as the chosen one, and keeps the choice. */
function showGame(id) {
  game = id;
  $('game-name').textContent = files.TITLES[id].name;
  for (const button of $('games').querySelectorAll('button')) button.setAttribute('aria-pressed', String(button.dataset.game === id));
  try {
    localStorage.setItem(GAME_KEY, id);
  } catch {
    // Not kept; chosen again next visit.
  }
  renderDossier(id);
  landingAudio.setGame(id, files.TITLES[id].name);
}
landingAudio.init({ toggle: $('sound-toggle'), line: $('audio-line'), landing });
showGame(game);

const hint = () => `The folder with ${files.TITLES[game].exe} in it${game === 'igi1' ? ', usually pc inside the installation' : ''}.`;

// --- The landing page ----------------------------------------------------------------------------------

/** The action under the text: the button's label, the line below it, and whether a folder can be changed. */
function offer(label, status, tone = 'neutral', canChange = false) {
  $('play-label').textContent = label;
  $('status').textContent = status;
  $('status').dataset.tone = tone;
  change.hidden = !canChange;
  $('action').hidden = false;
  $('loading').hidden = true;
}

/** The loading line in place of the action, with how far it has got as a fraction, or none while unknown. */
function progress(label, fraction = null, value = '') {
  $('action').hidden = true;
  $('loading').hidden = false;
  $('progress-label').textContent = label;
  $('progress-value').textContent = value;
  $('progress').classList.toggle('indeterminate', fraction === null);
  $('progress').firstElementChild.style.width = fraction === null ? '' : `${Math.round(fraction * 100)}%`;
}

/** The page again, in place of the game. */
function showLanding() {
  canvas.hidden = true;
  landing.hidden = false;
}

// --- WebGPU --------------------------------------------------------------------------------------------

/**
 * The adapter, asked for as the page opens so the person learns whether the game can run here before they
 * go looking for its folder. Null, with the reason, where it cannot.
 */
const adapterReady = (async () => {
  if (!window.isSecureContext) return { reason: 'This page has to be opened over https:// for the browser to allow WebGPU.' };
  if (!navigator.gpu) return { reason: 'This browser has no WebGPU. Use a current Chrome or Edge.' };
  try {
    const adapter = await navigator.gpu.requestAdapter({ powerPreference: 'high-performance' });
    return adapter ? { adapter } : { reason: 'This browser offers WebGPU but no graphics adapter. Check that hardware acceleration is on.' };
  } catch (error) {
    return { reason: `WebGPU could not start: ${error.message}` };
  }
})();

async function acquireDevice() {
  const { adapter, reason } = await adapterReady;
  if (!adapter) throw new Error(reason);

  // Everything the adapter has: the renderer reads back what the device got and uses what is there.
  const requiredLimits = {};
  for (const name in adapter.limits) requiredLimits[name] = adapter.limits[name];
  const device = await adapter.requestDevice({ requiredFeatures: [...adapter.features], requiredLimits });
  // Each distinct error once, then a count now and again: a broken pipeline repeats the same two errors every frame, and
  // writing them all to the console lagged the game it was reporting on.
  const seen = new Map();
  device.onuncapturederror = e => {
    const message = e.error.message;
    const count = (seen.get(message) ?? 0) + 1;
    seen.set(message, count);
    if (count === 1) console.error(`WebGPU: ${message}`);
    else if (count % 600 === 0) console.error(`WebGPU: the error above again (${count} times so far).`);
  };
  device.lost.then(info => {
    // Destroyed on purpose once the game has ended; anything else is a fault worth saying.
    if (info.reason !== 'destroyed') console.error(`WebGPU device lost: ${info.message}`);
  });
  return { adapter, device };
}

// --- Choosing the installation -------------------------------------------------------------------------

/** Asks for the game's folder; null when the person closes the picker. Throws an InstallationError. */
async function pickFolder() {
  if (window.showDirectoryPicker) {
    try {
      return await files.fromDirectory(await window.showDirectoryPicker({ id: game === 'igi1' ? 'openigi-game' : `openigi-${game}`, mode: 'read' }), game);
    } catch (error) {
      if (error.name === 'AbortError') return null;
      throw error;
    }
  }

  return new Promise((chosen, failed) => {
    const input = Object.assign(document.createElement('input'), { type: 'file', webkitdirectory: true });
    input.addEventListener('change', () => files.fromFileList(input.files, game).then(chosen, failed));
    input.addEventListener('cancel', () => chosen(null));
    input.click();
  });
}

// What the runtime last said on the error console: an exception nothing caught is printed there before the game
// stops, and the stop itself says only that it stopped. Kept to show beside it.
const lastErrors = [];
for (const level of ["error", "warn"]) {
  const original = console[level].bind(console);
  console[level] = (...parts) => {
    const line = parts.map(String).join(" ").slice(0, 600);
    if (level === "error" || /exception|abort|memory|assert/i.test(line)) {
      lastErrors.push(line);
      if (lastErrors.length > 8) lastErrors.shift();
    }
    original(...parts);
  };
}

/** On a phone or a tablet: the page goes fullscreen and sideways as Play is pressed, while the press allows it. */
const touchDevice = matchMedia('(pointer: coarse)').matches;

// An iPad (which says it is a Mac) or an iPhone. The iPhone's Safari has no fullscreen for a page; the iPad's has, and
// treats a game's quick thumbs in it as someone typing on a fake keyboard -- it warns and leaves fullscreen, and its
// swipe and pinch to leave take the finger on the stick. The touch controls went dead on an iPad and only there.
const appleTouch = /iPad|iPhone|iPod/.test(navigator.userAgent)
  || (/Macintosh/.test(navigator.userAgent) && navigator.maxTouchPoints > 1);

function takeTheScreen() {
  if (!touchDevice || appleTouch || document.fullscreenElement) return;
  document.documentElement.requestFullscreen?.({ navigationUI: 'hide' })
    .then(() => screen.orientation?.lock?.('landscape'))
    .catch(() => {});
}

const megabytes = n => (n / 1048576).toFixed(0);

/**
 * The installation to play, settled on the landing page: ?data=<url> at once when given (for automated
 * runs); otherwise the person's own folder, picked or remembered from their last visit. The site hosts
 * no game files, so there is no hosted choice to make. Nothing starts until Play is pressed.
 */
async function chooseSource() {
  const gameButtons = [...$('games').querySelectorAll('button')];
  const lockGame = () => gameButtons.forEach(button => { button.disabled = true; });

  const data = query.get('data');
  if (data) {
    lockGame();
    return files.fromUrl(data.endsWith('/') ? data : `${data}/`, game);
  }

  const { adapter, reason } = await adapterReady;
  if (!adapter) {
    play.disabled = true;
    offer('Play now', reason, 'error');
    return new Promise(() => {}); // Nothing can be played here.
  }

  // The hosted flow's buttons are not this build's: the site hosts no game files, so there is nothing
  // to clear and no hosted choice to make.
  $('own').hidden = true;
  $('clear').hidden = true;

  // What Play would start now: a folder just picked and found to be the game, or one remembered.
  let ready = null;
  let remembered = await files.rememberedFolder(game);
  const offerFolder = () => {
    if (remembered) offer('Play game', `Game folder: /${remembered.name}`, 'neutral', true);
    else offer('Choose game folder', hint());
  };
  offerFolder();

  // The game's switcher has just sent the page here (?play) and a folder is remembered: straight in.
  if (SWITCHED && remembered) {
    lockGame();
    try {
      return await files.reopen(remembered, game);
    } catch {
      // Gone, or no longer the game: forgotten, and the person picks again below.
      await files.forgetFolder(game);
      remembered = null;
      offerFolder();
    }
  }

  return new Promise((settle, fail) => {
    // Once the installation is settled the buttons are the page's again (Play again, Reload).
    const listening = new AbortController();
    const resolve = source => { listening.abort(); lockGame(); settle(source); };
    const reject = error => { listening.abort(); lockGame(); fail(error); };

    let busy = false;

    /** The other game chosen: its own remembered folder. */
    const switchTo = async id => {
      if (busy || id === game) return;
      busy = true;
      play.disabled = true;
      try {
        showGame(id);
        remembered = await files.rememberedFolder(game);
        ready = null;
        offerFolder();
      } finally {
        busy = false;
        play.disabled = false;
      }
    };

    const act = async choose => {
      if (busy) return;
      busy = true;
      play.disabled = true;
      try {
        if (!choose && ready) {
          resolve(ready);
          return;
        }

        if (!choose && remembered) {
          try {
            resolve(await files.reopen(remembered, game));
          } catch (error) {
            if (!(error instanceof files.InstallationError)) throw error;
            if (error.permission) {
              offer('Play game', error.message, 'error', true);
              return;
            }
            // Gone, or no longer the game: forgotten, and the person picks again.
            await files.forgetFolder(game);
            remembered = null;
            offer('Choose game folder', error.message, 'error');
          }
          return;
        }

        const picked = await pickFolder();
        if (picked) {
          // A folder of the other game is played as that game: the switch follows the folder.
          if (picked.title !== game) {
            showGame(picked.title);
            remembered = await files.rememberedFolder(game);
          }
          ready = picked;
          // The folder is known while the person is still on the page: its soundtrack
          // starts here, and the game plays from the same folder when Play is pressed.
          landingAudio.setSource(picked);
          if (picked.handle) await files.rememberFolder(picked.title, picked.handle);
          offer('Play game', `Found ${files.TITLES[picked.title].name} in /${picked.name}. Ready.`, 'ok', true);
        }
      } catch (error) {
        if (!(error instanceof files.InstallationError)) {
          reject(error);
          return;
        }
        offer(ready || remembered ? 'Play game' : 'Choose game folder', error.message, 'error', Boolean(ready || remembered));
      } finally {
        busy = false;
        play.disabled = false;
      }
    };

    for (const button of gameButtons) {
      button.addEventListener('click', () => switchTo(button.dataset.game), { signal: listening.signal });
    }
    play.addEventListener('click', () => { takeTheScreen(); act(false); }, { signal: listening.signal });
    change.addEventListener('click', () => act(true), { signal: listening.signal });
  });
}

// --- Starting ------------------------------------------------------------------------------------------

/**
 * The host's own assets -- fonts, colour grades, weather -- served beside the page and listed in
 * host-assets.json, written where the host reads them: /Assets, the application's directory being the root.
 */
async function writeHostAssets(fs) {
  const paths = await (await fetch('host-assets.json')).json();
  await Promise.all(paths.map(async path => {
    const response = await fetch(path);
    if (!response.ok) throw new Error(`${path}: ${response.status}`);
    fs.mkdirTree(`/${path.slice(0, path.lastIndexOf('/'))}`);
    fs.writeFile(`/${path}`, new Uint8Array(await response.arrayBuffer()));
  }));
}

/** After the game, or instead of it: the page offers a reload, which starts again from the landing page. */
function offerReload(label, status, tone) {
  showLanding();
  offer(label, status, tone);
  play.disabled = false;
  play.onclick = () => location.reload();
  play.focus();
  // A clean quit hands the page back with its soundtrack; a stop does not.
  if (tone === 'neutral') landingAudio.resume();
}

async function start() {
  const source = await chooseSource();
  // The soundtrack, out of the installation the game is about to play from.
  landingAudio.setSource(source);
  // The game the files are, which the host is told; an explicit -title in ?args= stands.
  if (!args.includes('-title')) args.push('-title', source.title);

  progress('Starting graphics');
  const { adapter, device } = await acquireDevice();
  globalThis.OpenIgiWebGpu.init({ adapter, device, canvas });

  progress('Starting the engine');
  const runtime = await dotnet.create();
  const fs = runtime.Module.FS;
  await writeHostAssets(fs);

  const read = await files.load(source, fs, GAME_ROOT, (done, total) =>
    progress('Reading game files', total ? done / total : 0, `${megabytes(done)} of ${megabytes(total)} MB`));
  console.log(`Read ${read.files} files; ${read.deferred} wait for their missions.`);

  platform.install(canvas);
  runtime.setModuleImports('openigi-platform', platform.imports);
  runtime.setModuleImports('openigi-audio', audio.imports);
  runtime.setModuleImports('openigi-files', files.imports);
  // The switcher's other game (openGame): the page holds one game's files at a time, so it reloads into it,
  // after the player's files are kept.
  let keptFiles = null;
  runtime.setModuleImports('openigi-page', {
    openGame: id => {
      if (!(id in files.TITLES)) return false;
      showGame(id);
      const next = new URL(location.href);
      next.searchParams.set('game', id);
      next.searchParams.set('play', '');
      next.searchParams.delete('data'); // A folder served for automated runs is one game's.
      Promise.resolve(keptFiles?.flush()).catch(() => {}).finally(() => location.assign(next.href));
      return true;
    },
  });

  progress('Starting the game');
  const exports = await runtime.getAssemblyExports(runtime.getConfig().mainAssemblyName);
  // The assembly is OpenIGI.Web (Directory.Build.props rewrites ProjectIGI to OpenIGI in assembly names),
  // but the exports live under the C# namespace: ProjectIGI.Web.Program.
  const game = exports.ProjectIGI.Web.Program;

  // The player's own profile, settings and saves from an earlier visit, back where the game reads them before it boots.
  const kept = await userFiles.keep(fs, game.UserDirectory());
  keptFiles = kept;
  if (kept.files) console.log(`Restored ${kept.files} of the player's files.`);

  // The canvas takes the page before Boot: the game sizes itself to it.
  landing.hidden = true;
  canvas.hidden = false;
  canvas.focus();
  // The game's own sound takes over from the landing page's soundtrack here.
  landingAudio.stop();
  game.Boot(args);

  // Frames stepped so far and the state of the sound, for anyone measuring from outside (an automated
  // run, the console).
  globalThis.openigi = { frames: 0, audio: audio.diagnostics };

  // Everything the page needed has loaded by now: kept for a visit with no network.
  keepShell();

  const frame = () => {
    let going;
    try {
      globalThis.openigi.frames++;
      going = game.Step();
    } catch (error) {
      platform.uninstall();
      device.destroy();
      // With where it stopped, as far as the browser says: the message alone names a trap, not what trapped.
      const where = String(error.stack || '').split('\n').filter(line => line && !line.includes(error.message)).slice(0, 12).join('\n');
      const said = lastErrors.join('\n');
      offerReload('Reload', `The game stopped: ${error.message}${said ? `\n${said}` : ''}${where ? `\n${where}` : ''}`, 'error');
      throw error;
    }

    if (going) {
      requestAnimationFrame(frame);
      return;
    }

    // Quit. The game has shut itself down -- saved its settings, closed its sound -- and the rest is the
    // page's to release: the keyboard and pointer, the device, and the canvas still holding the last
    // picture, which the page replaces.
    platform.uninstall();
    device.destroy();
    kept.flush();
    offerReload('Play again', 'The game has closed. Your settings are saved.', 'neutral');
  };
  requestAnimationFrame(frame);
}

// The macOS and Linux install command, copied by its button. The code is selectable by hand as well, for
// a browser that refuses the clipboard.
$('install-copy').addEventListener('click', async event => {
  const button = event.currentTarget;
  try {
    await navigator.clipboard.writeText($('install-command').textContent);
    button.textContent = 'Copied';
  } catch {
    getSelection().selectAllChildren($('install-command'));
    button.textContent = 'Select';
  }
  setTimeout(() => { button.textContent = 'Copy'; }, 1500);
});


// --- The community -------------------------------------------------------------------------------------
//
// The Discord server's own live numbers -- its name, who is online, a few faces, its invite -- read from the
// server's widget feed and drawn in the page's look rather than in Discord's frame. The cards link out
// already; this only fills them in, and leaves them as they are when a feed cannot be read.

const DISCORD_GUILD = '1534217331478106193';

async function showDiscord() {
  const reply = await fetch(`https://discord.com/api/guilds/${DISCORD_GUILD}/widget.json`);
  if (!reply.ok) return;
  const server = await reply.json();

  if (server.instant_invite) {
    for (const link of document.querySelectorAll('[data-discord-link]')) link.href = server.instant_invite;
  }
  if (server.name) $('discord-name').textContent = server.name;
  if (Number.isFinite(server.presence_count)) {
    $('discord-online').textContent = `${server.presence_count} online`;
    $('discord-online').hidden = false;
  }

  const faces = $('discord-avatars');
  for (const member of (server.members ?? []).filter(m => m.avatar_url).slice(0, 5)) {
    const img = Object.assign(document.createElement('img'), { src: member.avatar_url, alt: '', loading: 'lazy', referrerPolicy: 'no-referrer' });
    faces.append(img);
  }
}

async function showGitHub() {
  const reply = await fetch('https://api.github.com/repos/OpenIGI/OpenIGI');
  if (!reply.ok) return;
  const { stargazers_count: stars } = await reply.json();
  if (!Number.isFinite(stars)) return;
  $('github-stars').textContent = `★ ${stars}`;
  $('github-stars').hidden = false;
}

showDiscord().catch(() => {});
showGitHub().catch(() => {});

// What the header says about the browser, as soon as it is known.
adapterReady.then(({ adapter }) => {
  $('gpu').dataset.state = adapter ? 'ok' : 'no';
  $('gpu').textContent = adapter ? 'WebGPU ready' : 'No WebGPU';
});

start().catch(error => {
  console.error(error);
  offerReload('Reload', error.message, 'error');
});
