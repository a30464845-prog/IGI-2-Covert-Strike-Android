// The landing page's own sound: the game's menu theme and menu clicks, read out of the
// player's own installation. Nothing is bundled in the page and nothing is uploaded.
//
// Where the sounds come from (the engine's own layout, not a guess):
// - The menu theme is `menu_music`, an MPEG stream inside `menusystem/sound/sounds.res`
//   (MusicPlayer.cs: the menu system ships `menu_music` in its own archive; the bank keeps the
//   entry's packed bytes and the decoder reads them from the first frame). A browser plays those
//   bytes as they are, as an MPEG blob.
// - The menu clicks are `menu_high`, `menu_sel`, `menu_ok`, `menu_cancel` in the same archive,
//   as ILSF sounds (RetailIgi2MusicPlaybackTests.cs: the sequel ships all four, codec Ilsf). ILSF
//   is decoded here to WAV: a 20-byte header, then raw PCM or plain IMA ADPCM (IlsfHeader.cs,
//   IlsfAdpcmDecoder.cs).
// - A mission's score is a loose `*_music.mp3` under `common/sounds/` or a mission's `sounds/`
//   (SoundBank.cs: the sequel ships its mission scores as loose files), or `sounds/game_music.wav`
//   (ILSF ADPCM, decoded the same way). Found by listing the folder, never by name: the list is
//   whatever this installation holds.
// - The two games file the same track names at the same paths but ship different recordings, so
//   the sounds always come from the folder of the game the page is set to. Switching games drops
//   the playlist until the new game's folder is known.
//
// Browsers refuse sound before a gesture, so nothing plays until the first pointer or key press
// (or the sound toggle, which is itself a gesture). Before a folder is known there is nothing to
// play: the line under Play says so, and the toggle stays honest about it.

const MENU_ARCHIVE = 'menusystem/sound/sounds.res';
const MENU_TRACK = 'menu_music';
// Hover, then click; each falls back to the next name when the first is not in the archive.
const CLICK_NAMES = { hover: ['menu_high', 'menu_sel'], click: ['menu_ok', 'menu_cancel'] };

const MUSIC_VOLUME = 0.5;
const CLICK_VOLUME = 0.3;
const FADE_MS = 600;
const SOUND_KEY = 'openigi-sound';

// --- The archive: ILFF + IRES ------------------------------------------------------------------
//
// Layout (IlffContainer.cs, IresIndex.cs): a 20-byte header — `ILFF`, total size, alignment,
// next-sibling offset, form type `IRES` — then 16-byte chunk headers — id, size, alignment,
// next-sibling offset — with each payload at alignUp(offset + 16, chunkAlign). A `NAME` chunk
// sets the name the `BODY` chunks after it belong to, until the next `NAME`. Names are Latin-1
// to the first NUL. Nested containers are not walked: the game has one archive like that, and
// the menu sounds are flat.

const alignUp = (value, align) => (value + align - 1) & ~(align - 1);

function ascii(bytes, at, length) {
  let out = '';
  for (let i = at; i < at + length; i++) out += String.fromCharCode(bytes[i]);
  return out;
}

function latin1(bytes, at, length) {
  let end = at;
  while (end < at + length && bytes[end] !== 0) end++;
  let out = '';
  for (let i = at; i < end; i++) out += String.fromCharCode(bytes[i]);
  return out;
}

/** The archive's bodies by bare stem (`menu_music`, not a path), first in file order wins. */
function parseIres(bytes) {
  const u32 = at => (bytes[at] | (bytes[at + 1] << 8) | (bytes[at + 2] << 16) | (bytes[at + 3] << 24)) >>> 0;
  if (bytes.length < 20) throw new Error('archive too short');
  if (ascii(bytes, 0, 4) !== 'ILFF') throw new Error('not an ILFF archive');
  const size = u32(4);
  const align = u32(8);
  if (ascii(bytes, 16, 4) !== 'IRES') throw new Error('not an IRES archive');
  if (size > bytes.length) throw new Error('archive truncated');
  if (align === 0 || (align & (align - 1)) !== 0) throw new Error('archive alignment is not a power of two');

  const entries = new Map();
  let current = null;
  let offset = alignUp(20, align);
  while (offset + 16 <= size) {
    const id = ascii(bytes, offset, 4);
    const chunkSize = u32(offset + 4);
    const chunkAlign = u32(offset + 8);
    const next = u32(offset + 12);
    if (id === 'ILFF') break; // A nested container; the menu sounds do not nest.
    const payload = alignUp(offset + 16, chunkAlign);
    if (payload > size || chunkSize > size - payload) throw new Error('chunk past the end of the archive');
    if (id === 'NAME') {
      current = latin1(bytes, payload, chunkSize);
    } else if (id === 'BODY' && current !== null) {
      const stem = current.split(/[\\/]/).pop().replace(/\.[^.]*$/, '').toLowerCase();
      if (stem && !entries.has(stem)) entries.set(stem, { offset: payload, length: chunkSize });
    }
    if (next === 0) break;
    if (next < 16) throw new Error('chunk advances by less than its own header');
    offset += next;
  }
  return entries;
}

// --- ILSF: the clicks and any ADPCM mission score ------------------------------------------------
//
// Layout (IlsfHeader.cs): a 20-byte header — `ILSF`, u16 format (0 streamed PCM, 1 resident PCM,
// 2 streamed ADPCM, 3 resident ADPCM), u16 decoded bits, u16 channels, u16 reserved, u32 sample
// rate, u32 frame count — then the payload. ADPCM is plain IMA/DVI (IlsfAdpcmDecoder.cs): high
// nibble first, channels interleaved per sample, one predictor and step index per channel.

const ILSF_STEP_TABLE = [
  7, 8, 9, 10, 11, 12, 13, 14, 16, 17,
  19, 21, 23, 25, 28, 31, 34, 37, 41, 45,
  50, 55, 60, 66, 73, 80, 88, 97, 107, 118,
  130, 143, 157, 173, 190, 209, 230, 253, 279, 307,
  337, 371, 408, 449, 494, 544, 598, 658, 724, 796,
  876, 963, 1060, 1166, 1282, 1411, 1552, 1707, 1878, 2066,
  2272, 2499, 2749, 3024, 3327, 3660, 4026, 4428, 4871, 5358,
  5894, 6484, 7132, 7845, 8630, 9493, 10442, 11487, 12635, 13899,
  15289, 16818, 18500, 20350, 22385, 24623, 27086, 29794, 32767,
];
const ILSF_INDEX_TABLE = [-1, -1, -1, -1, 2, 4, 6, 8, -1, -1, -1, -1, 2, 4, 6, 8];
const clamp16 = value => Math.max(-32768, Math.min(32767, value));

function decodeIlsf(bytes) {
  const u16 = at => bytes[at] | (bytes[at + 1] << 8);
  const u32 = at => (bytes[at] | (bytes[at + 1] << 8) | (bytes[at + 2] << 16) | (bytes[at + 3] << 24)) >>> 0;
  if (bytes.length < 20 || ascii(bytes, 0, 4) !== 'ILSF') throw new Error('not an ILSF sound');
  const format = u16(4);
  const bits = u16(6);
  const channels = u16(8);
  const sampleRate = u32(12);
  const frameCount = u32(16);
  if (format > 3) throw new Error(`unknown ILSF format ${format}`);
  if (bits !== 8 && bits !== 16) throw new Error(`ILSF sound is ${bits}-bit`);
  if (channels < 1 || channels > 2) throw new Error(`ILSF sound has ${channels} channels`);
  if (sampleRate <= 0) throw new Error('ILSF sound has no sample rate');

  const payload = bytes.subarray(20);
  const samples = new Int16Array(frameCount * channels);
  if (format === 0 || format === 1) {
    if (bits === 16) {
      const view = new DataView(payload.buffer, payload.byteOffset, payload.byteLength);
      for (let i = 0; i < samples.length; i++) samples[i] = view.getInt16(i * 2, true);
    } else {
      for (let i = 0; i < samples.length; i++) samples[i] = (payload[i] - 128) << 8;
    }
    return { sampleRate, channels, samples };
  }

  const predictor = [0, 0];
  const stepIndex = [0, 0];
  let bytePos = 0;
  let hasPending = false;
  let pending = 0;
  for (let frame = 0; frame < frameCount; frame++) {
    for (let channel = 0; channel < channels; channel++) {
      let nibble;
      if (hasPending) {
        nibble = pending & 0xF;
      } else {
        if (bytePos >= payload.length) throw new Error('ILSF ADPCM payload ends early');
        pending = payload[bytePos++];
        nibble = pending >> 4;
      }
      hasPending = !hasPending;
      // The step in force is the one the previous index selected; the index moves first but the
      // new step only applies to the next sample — the original's cached-step variable, exactly.
      const step = ILSF_STEP_TABLE[stepIndex[channel]];
      stepIndex[channel] = Math.max(0, Math.min(88, stepIndex[channel] + ILSF_INDEX_TABLE[nibble]));
      let magnitude = step >> 3;
      if (nibble & 4) magnitude += step;
      if (nibble & 2) magnitude += step >> 1;
      if (nibble & 1) magnitude += step >> 2;
      predictor[channel] = clamp16((nibble & 8) ? predictor[channel] - magnitude : predictor[channel] + magnitude);
      samples[frame * channels + channel] = predictor[channel];
    }
  }
  return { sampleRate, channels, samples };
}

/** An ILSF sound as a WAV blob a browser can play. */
function ilsfToWav(bytes) {
  const { sampleRate, channels, samples } = decodeIlsf(bytes);
  const dataBytes = samples.length * 2;
  const buffer = new ArrayBuffer(44 + dataBytes);
  const view = new DataView(buffer);
  const text = (at, s) => { for (let i = 0; i < s.length; i++) view.setUint8(at + i, s.charCodeAt(i)); };
  text(0, 'RIFF');
  view.setUint32(4, 36 + dataBytes, true);
  text(8, 'WAVE');
  text(12, 'fmt ');
  view.setUint32(16, 16, true);
  view.setUint16(20, 1, true);
  view.setUint16(22, channels, true);
  view.setUint32(24, sampleRate, true);
  view.setUint32(28, sampleRate * channels * 2, true);
  view.setUint16(32, channels * 2, true);
  view.setUint16(34, 16, true);
  text(36, 'data');
  view.setUint32(40, dataBytes, true);
  new Int16Array(buffer, 44).set(samples);
  return new Blob([buffer], { type: 'audio/wav' });
}

// --- A track's bytes as something a browser can play ---------------------------------------------

function isMpeg(bytes) {
  // An MPEG frame sync: 11 set bits, then a version other than the reserved one.
  return bytes.length > 4 && bytes[0] === 0xFF && (bytes[1] & 0xE0) === 0xE0 && (bytes[1] & 0x18) !== 0x08;
}

/** An entry's bytes as a playable blob, or null when they are neither MPEG nor ILSF. */
function soundToBlob(bytes) {
  if (bytes.length >= 20 && ascii(bytes, 0, 4) === 'ILSF') {
    try {
      return ilsfToWav(bytes);
    } catch {
      return null;
    }
  }
  if (isMpeg(bytes)) return new Blob([bytes], { type: 'audio/mpeg' });
  return null;
}

// --- The player ----------------------------------------------------------------------------------

let soundOn = true;
try {
  soundOn = localStorage.getItem(SOUND_KEY) !== 'off';
} catch {
  // Storage blocked: sound on, not kept.
}

let gameId = 'igi1';
let gameName = 'Project I.G.I.';
let generation = 0;
let source = null;
let discovered = false; // A discovery has finished for the current source.
let discoveryPending = false;
let armed = false; // A gesture has happened, so sound may start.
let playlist = []; // { title, getUrl } in play order; the menu theme first.
let trackIndex = -1;
let playing = false;
let clicks = {}; // role -> object URL of a decoded click.
let clickBuffers = {};
let fadeTimer = null;

let audio = null; // The music element, made on first use.
let actx = null; // The clicks' audio context, made on first use.
let clickGain = null;
let toggleButton = null;
let lineElement = null;
let landingElement = null;

function musicElement() {
  if (!audio) {
    audio = new Audio();
    audio.loop = false;
    audio.volume = 0;
    audio.preload = 'auto';
    audio.addEventListener('ended', () => playTrack(trackIndex + 1));
    audio.addEventListener('error', () => {
      // A track the browser cannot play is skipped, not retried.
      if (playing) playTrack(trackIndex + 1);
    });
  }
  return audio;
}

function fadeTo(target, done) {
  clearInterval(fadeTimer);
  const element = musicElement();
  const from = element.volume;
  const began = performance.now();
  fadeTimer = setInterval(() => {
    const fraction = Math.min(1, (performance.now() - began) / FADE_MS);
    element.volume = from + (target - from) * fraction;
    if (fraction >= 1) {
      clearInterval(fadeTimer);
      fadeTimer = null;
      done?.();
    }
  }, 50);
}

function setLine(text) {
  if (lineElement) lineElement.textContent = text;
}

function showToggle() {
  if (!toggleButton) return;
  toggleButton.textContent = soundOn ? 'SOUND ON' : 'SOUND OFF';
  toggleButton.setAttribute('aria-pressed', String(soundOn));
}

/** The next track, wrapping around the playlist. */
async function playTrack(index) {
  if (!playlist.length) return;
  const next = ((index % playlist.length) + playlist.length) % playlist.length;
  const track = playlist[next];
  const element = musicElement();
  trackIndex = next;
  playing = true;
  element.muted = !soundOn;
  setLine(`AUDIO: NOW PLAYING — ${track.title} (${gameName})`);
  fadeTo(0, async () => {
    try {
      element.src = await track.getUrl();
      await element.play();
      fadeTo(MUSIC_VOLUME);
    } catch {
      // Unplayable here: on to the next one, and silence if none will play.
      if (playlist.length > 1) playTrack(next + 1);
      else {
        playing = false;
        setLine(`AUDIO: NO SOUNDTRACK IN THIS FOLDER`);
      }
    }
  });
}

function maybeStart() {
  if (!soundOn || !armed || playing || !playlist.length) return;
  playTrack(trackIndex < 0 ? 0 : trackIndex);
}

/** What the playlist is for one installation, found by listing it. */
async function discover(installation, foundGeneration) {
  const list = await installation.list();
  const byPath = new Map();
  for (const file of list) byPath.set(file.path.toLowerCase(), file);
  const tracks = [];
  const foundClicks = {};

  const archiveFile = byPath.get(MENU_ARCHIVE);
  if (archiveFile) {
    let entries = null;
    let archive = null;
    try {
      archive = await installation.read(archiveFile);
      entries = parseIres(archive);
    } catch (error) {
      console.warn(`The menu sounds would not open: ${error.message}`);
    }
    if (entries) {
      // The archive's own bytes are sliced out of it and then let go: the menu theme is a blob
      // of its own from here, and the clicks are decoded to WAV the same way.
      const menu = entries.get(MENU_TRACK);
      if (menu) {
        const blob = soundToBlob(archive.subarray(menu.offset, menu.offset + menu.length));
        if (blob) {
          const url = URL.createObjectURL(blob);
          tracks.push({ title: 'MENU THEME', getUrl: async () => url });
        }
      }
      for (const [role, names] of Object.entries(CLICK_NAMES)) {
        for (const name of names) {
          const entry = entries.get(name);
          if (!entry) continue;
          try {
            foundClicks[role] = URL.createObjectURL(
              ilsfToWav(archive.subarray(entry.offset, entry.offset + entry.length)));
          } catch {
            continue;
          }
          break;
        }
      }
    }
  }

  // A mission's score, loose in its sounds folder: the sequel's `*_music.mp3`, or the first
  // game's `game_music.wav`. Read when its turn comes, not up front.
  const loose = list
    .filter(file => {
      const path = file.path.toLowerCase();
      return path.endsWith('_music.mp3') || path.endsWith('/sounds/game_music.wav');
    })
    .sort((a, b) => a.path.localeCompare(b.path, 'en', { numeric: true }));
  for (const file of loose) {
    let url = null;
    tracks.push({
      title: looseTitle(file.path),
      getUrl: async () => {
        if (!url) {
          const bytes = await installation.read(file);
          const blob = file.path.toLowerCase().endsWith('.mp3')
            ? new Blob([bytes], { type: 'audio/mpeg' })
            : soundToBlob(bytes);
          if (!blob) throw new Error(`${file.path} is not playable`);
          url = URL.createObjectURL(blob);
        }
        return url;
      },
    });
  }

  if (foundGeneration !== generation) return null; // A newer game or folder has taken over.
  return { tracks, clicks: foundClicks };
}

/** A loose score's name for the line: the mission's folder, or the file's own stem. */
function looseTitle(path) {
  const parts = path.split('/');
  const soundsAt = parts.findIndex(part => part.toLowerCase() === 'sounds');
  if (soundsAt > 0) return parts[soundsAt - 1].toUpperCase();
  const stem = parts[parts.length - 1].replace(/\.[^.]*$/, '').replace(/_music$/i, '');
  return stem ? stem.toUpperCase() : 'MISSION SCORE';
}

/** The clicks: the game's own where they were found, small synthesized ticks where not. */
function ensureClickContext() {
  if (!actx) {
    const Context = window.AudioContext || window.webkitAudioContext;
    if (!Context) return null;
    actx = new Context();
    clickGain = actx.createGain();
    clickGain.gain.value = CLICK_VOLUME;
    clickGain.connect(actx.destination);
  }
  if (actx.state === 'suspended') actx.resume().catch(() => {});
  return actx;
}

async function playClick(role) {
  if (!soundOn || (landingElement && landingElement.hidden)) return;
  const url = clicks[role];
  if (url) {
    try {
      const context = ensureClickContext();
      if (context) {
        if (!clickBuffers[role]) {
          const bytes = await (await fetch(url)).arrayBuffer();
          clickBuffers[role] = await context.decodeAudioData(bytes);
        }
        const voice = context.createBufferSource();
        voice.buffer = clickBuffers[role];
        voice.connect(clickGain);
        voice.start();
        return;
      }
    } catch {
      // The game's click would not play: the synthesized tick below.
    }
  }

  try {
    const context = ensureClickContext();
    if (!context) return;
    const at = context.currentTime;
    const tone = context.createOscillator();
    const gain = context.createGain();
    tone.type = 'square';
    tone.frequency.value = role === 'click' ? 1150 : 1750;
    gain.gain.setValueAtTime(0.0001, at);
    gain.gain.exponentialRampToValueAtTime(0.18, at + 0.006);
    gain.gain.exponentialRampToValueAtTime(0.0001, at + (role === 'click' ? 0.07 : 0.045));
    tone.connect(gain);
    gain.connect(clickGain);
    tone.start(at);
    tone.stop(at + 0.09);
  } catch {
    // Sound is best-effort on this page; a failure stays silent.
  }
}

let lastHover = 0;

/** The page's sound. Wired by main.js, which owns the game and its folder. */
export { parseIres, decodeIlsf, soundToBlob }; // The format readers, exported for tests.
export function init({ toggle, line, landing }) {
  toggleButton = toggle;
  lineElement = line;
  landingElement = landing;
  showToggle();
  setLine('AUDIO: SILENT — PICK A GAME FOLDER TO HEAR ITS MENU THEME');

  toggleButton?.addEventListener('click', () => {
    armed = true;
    soundOn = !soundOn;
    try {
      localStorage.setItem(SOUND_KEY, soundOn ? 'on' : 'off');
    } catch {
      // Not kept; chosen again next visit.
    }
    showToggle();
    if (audio) audio.muted = !soundOn;
    if (soundOn) {
      if (discoveryPending && source) {
        discoveryPending = false;
        setSource(source);
      } else {
        maybeStart();
      }
    }
  });

  // The first gesture anywhere: sound may start from here.
  const arm = () => {
    armed = true;
    maybeStart();
  };
  window.addEventListener('pointerdown', arm, { once: true });
  window.addEventListener('keydown', arm, { once: true });

  // Clicks and hovers, on the landing page only: the game has its own sound once it boots.
  landingElement?.addEventListener('pointerover', event => {
    if (!event.target.closest('button, a, summary')) return;
    const now = performance.now();
    if (now - lastHover < 70) return;
    lastHover = now;
    playClick('hover');
  });
  landingElement?.addEventListener('click', event => {
    if (!event.target.closest('button, a, summary')) return;
    playClick('click');
  });
}

/** The game the page is set to: its sounds are dropped until its folder is known. */
export function setGame(id, name) {
  gameId = id;
  gameName = name;
  generation++;
  source = null;
  discovered = false;
  discoveryPending = false;
  playlist = [];
  clicks = {};
  clickBuffers = {};
  trackIndex = -1;
  if (audio) {
    playing = false;
    audio.pause();
  }
  setLine('AUDIO: SILENT — PICK A GAME FOLDER TO HEAR ITS MENU THEME');
}

/** The installation to play the soundtrack out of. Fire and forget: never throws. */
export function setSource(installation) {
  if (!installation) return;
  // The same source twice is a no-op — except while its discovery is still owed, which
  // is how the sound toggle starts it after the page was muted.
  if (installation === source && discovered) return;
  source = installation;
  generation++;
  const foundGeneration = generation;
  discovered = false;
  playlist = [];
  clicks = {};
  clickBuffers = {};
  trackIndex = -1;
  if (audio) {
    playing = false;
    audio.pause();
  }
  if (!soundOn) {
    // Nothing is read while muted; the toggle starts it when it is turned back on.
    discoveryPending = true;
    setLine('AUDIO: MUTED');
    return;
  }
  discoveryPending = false;
  setLine('AUDIO: READING THE SOUNDTRACK…');
  discover(installation, foundGeneration)
    .then(found => {
      if (!found || foundGeneration !== generation) return;
      discovered = true;
      playlist = found.tracks;
      clicks = found.clicks;
      if (!playlist.length) {
        setLine('AUDIO: NO SOUNDTRACK IN THIS FOLDER');
        return;
      }
      setLine(`AUDIO: SOUNDTRACK READY — ${playlist.length} TRACK${playlist.length === 1 ? '' : 'S'} (${gameName})`);
      maybeStart();
    })
    .catch(() => {
      if (foundGeneration !== generation) return;
      discovered = true;
      setLine('AUDIO: SOUNDTRACK UNAVAILABLE');
    });
}

/** The game is starting: its own sound takes over from here. */
export function stop() {
  if (!audio) return;
  playing = false;
  fadeTo(0, () => audio.pause());
}

/** The game has closed cleanly: the landing page's soundtrack comes back. */
export function resume() {
  if (!soundOn || !armed || !playlist.length) return;
  if (trackIndex < 0) {
    maybeStart();
    return;
  }
  playing = true;
  musicElement().muted = false;
  musicElement().play().catch(() => { playing = false; });
  fadeTo(MUSIC_VOLUME);
  setLine(`AUDIO: NOW PLAYING — ${playlist[trackIndex].title} (${gameName})`);
}
