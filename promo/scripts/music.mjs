// Musique originale de la pub Converto, synthétisée en Node (aucune dépendance, aucun échantillon externe).
// Style : pop électro de pub d'appli (synthés « supersaw », basse rebondissante, grosse caisse 808 avec pompage).
// Le tempo et l'énergie montent à chaque changement de scène, avec un « drop » sur la scène confidentialité.
// Les durées des scènes viennent de src/timing.json.
import { mkdirSync, readFileSync, writeFileSync } from "node:fs";

// ---------------------------------------------------------------- réglages
// Trois styles : "pro" (pub de produit tech, sobre), "warm" (feel-good : ukulélé, marimba) et "electro" (supersaw, 808).
const STYLE = (process.argv.find((a) => a.startsWith("--style=")) ?? "--style=pro").split("=")[1];
const SR = 44100;
const TARGET_RMS_DB = -22; // niveau moyen visé avant limitation douce
const PEAK = 0.72; // environ -3 dBFS, laisse de la marge au vrai pic après encodage AAC
const FADE_IN = 0.03;
const FADE_OUT = 0.8;
const WHOOSH_LEN = 0.5;
const GAP = 0.04; // le dernier coup du roulement d'accélération tombe juste avant le temps fort (pas de silence)
const DUCK_DEPTH = 0.6; // profondeur du pompage de la grosse caisse sur les synthés
const DUCK_TIME = 0.16;

// Progression I–V–vi–IV (Do, Sol, La mineur, Fa) : basse + notes de l'accord (MIDI).
const PROGRESSION = [
  { bass: 36, chord: [60, 64, 67] }, // C
  { bass: 43, chord: [59, 62, 67] }, // G
  { bass: 45, chord: [60, 64, 69] }, // Am
  { bass: 41, chord: [60, 65, 69] }, // F
];

// Motif accrocheur répété à chaque mesure : [position en croches, note MIDI, durée en croches].
const HOOK = [
  [[0, 76, 2], [2, 79, 1], [3, 76, 1], [4, 74, 2], [6, 72, 2]], // sur C
  [[0, 74, 2], [2, 79, 1], [3, 74, 1], [4, 71, 2], [6, 74, 2]], // sur G
  [[0, 72, 2], [2, 76, 1], [3, 72, 1], [4, 69, 2], [6, 72, 2]], // sur Am
  [[0, 72, 2], [2, 77, 1], [3, 76, 1], [4, 72, 1], [5, 69, 1], [6, 72, 2]], // sur F
];
const FINAL_HOOK = [[0, 76, 1], [1, 79, 1], [2, 84, 6]];
const FINAL_CHORD = { bass: 36, chord: [64, 67, 72] };

const eighths = [0.5, 1.5, 2.5, 3.5];
const allEighths = [0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5];
const sixteenths = [...Array(16).keys()].map((k) => k / 4);
const bounce = [0, 0.75, 1.5, 2, 2.75, 3.5];
const four = [0, 1, 2, 3];

// Une entrée par scène, dans l'ordre de timing.json.
const SCENES = [
  { name: "hook", bpm: 108, kick: four, clap: [1, 3], hat: eighths, open: [], shaker: false, bass: eighths, stab: [], pad: 0.04, lead: 1, leadGain: 0.14, fill: false },
  { name: "pick", bpm: 114, kick: four, clap: [1, 3], hat: eighths, open: [], shaker: true, bass: bounce, stab: [0.5, 2.5], pad: 0.05, lead: 1, leadGain: 0.15, fill: false },
  { name: "formats", bpm: 120, kick: four, clap: [1, 3], hat: allEighths, open: eighths, shaker: true, bass: bounce, stab: eighths, pad: 0.05, lead: 2, leadGain: 0.15, fill: false },
  { name: "options", bpm: 126, kick: four, clap: [1, 3], hat: allEighths, open: eighths, shaker: true, bass: bounce, stab: [0.5, 0.75, 1.5, 2.5, 2.75, 3.5], pad: 0.06, lead: 2, leadGain: 0.16, fill: true },
  { name: "privacy", bpm: 132, kick: [0, 1, 2, 2.75, 3], clap: [1, 3], hat: sixteenths, open: eighths, shaker: true, bass: bounce, stab: eighths, pad: 0.085, lead: 3, leadGain: 0.17, fill: false, drop: true },
  { name: "cta", bpm: 120, kick: [0], clap: [], hat: [], open: [], shaker: false, bass: [0], stab: [0], pad: 0.09, lead: 1, leadGain: 0.16, fill: false, final: true },
];

// ---------------------------------------------------------------- outils
const timing = JSON.parse(readFileSync(new URL("../src/timing.json", import.meta.url), "utf8"));
const TAU = Math.PI * 2;
const freq = (midi) => 440 * 2 ** ((midi - 69) / 12);
const cents = (c) => 2 ** (c / 1200);

let seed = 20251021;
const random = () => {
  seed = (seed * 1664525 + 1013904223) >>> 0;
  return seed / 4294967296 * 2 - 1;
};

const makeBuffer = (seconds) => {
  const n = Math.round(seconds * SR);
  return { n, L: new Float32Array(n), R: new Float32Array(n) };
};

// Voix mono placée entre deux canaux (pan de -1 à 1).
const addVoice = (buf, start, length, pan, fn) => {
  const first = Math.max(0, Math.floor(start * SR));
  const last = Math.min(buf.n, first + Math.floor(length * SR));
  const angle = (pan + 1) * Math.PI / 4;
  const gl = Math.cos(angle);
  const gr = Math.sin(angle);
  for (let i = first; i < last; i++) {
    const v = fn((i - first) / SR);
    buf.L[i] += v * gl;
    buf.R[i] += v * gr;
  }
};

// Voix stéréo : fn renvoie [gauche, droite].
const addStereo = (buf, start, length, fn) => {
  const first = Math.max(0, Math.floor(start * SR));
  const last = Math.min(buf.n, first + Math.floor(length * SR));
  for (let i = first; i < last; i++) {
    const [l, r] = fn((i - first) / SR);
    buf.L[i] += l;
    buf.R[i] += r;
  }
};

// ---------------------------------------------------------------- briques de synthèse
const polyBlep = (t, dt) => {
  if (t < dt) {
    const x = t / dt;
    return x + x - x * x - 1;
  }
  if (t > 1 - dt) {
    const x = (t - 1) / dt;
    return x * x + x + x + 1;
  }
  return 0;
};

// Oscillateur en dents de scie sans repliement ; renvoie une fonction « échantillon suivant ».
const sawOsc = (f, startPhase = Math.random()) => {
  let phase = startPhase;
  const dt = f / SR;
  return () => {
    const v = 2 * phase - 1 - polyBlep(phase, dt);
    phase += dt;
    if (phase >= 1) phase -= 1;
    return v;
  };
};

const squareOsc = (f, width = 0.5) => {
  let phase = Math.random();
  const dt = f / SR;
  return () => {
    let v = phase < width ? 1 : -1;
    v += polyBlep(phase, dt);
    v -= polyBlep((phase + 1 - width) % 1, dt);
    phase += dt;
    if (phase >= 1) phase -= 1;
    return v;
  };
};

// Filtre passe-bas à variable d'état (résonant). damping bas = plus résonant.
const lowpass = () => {
  let low = 0;
  let band = 0;
  return (x, cutoff, damping = 0.6) => {
    const f = 2 * Math.sin(Math.PI * Math.min(cutoff, SR * 0.22) / SR);
    const high = x - low - damping * band;
    band += f * high;
    low += f * band;
    return low;
  };
};

// ---------------------------------------------------------------- instruments
// Accord ou nappe « supersaw » : plusieurs dents de scie désaccordées, filtre dont la fréquence retombe.
const supersaw = (midi, gain, length, { open = 5000, close = 1200, decay = 0.2, attack = 0.005, release = 0.12, hold = false }) => {
  const f = freq(midi);
  const detunes = [-14, -7, 0, 7, 14];
  const oscs = detunes.map((c) => sawOsc(f * cents(c)));
  const filterL = lowpass();
  const filterR = lowpass();
  return (t) => {
    const env = Math.min(1, t / attack) * Math.min(1, Math.max(0, (length - t) / release)) * (hold ? 1 : Math.exp(-t / 0.35));
    const cutoff = close + (open - close) * Math.exp(-t / decay);
    let left = 0;
    let right = 0;
    oscs.forEach((osc, i) => {
      const v = osc();
      left += v * (i < 3 ? 1 : 0.5);
      right += v * (i > 1 ? 1 : 0.5);
    });
    return [filterL(left, cutoff, 0.7) * gain * env * 0.28, filterR(right, cutoff, 0.7) * gain * env * 0.28];
  };
};

// Synthé lead « pluck » : deux dents de scie + un carré, filtre qui se ferme vite.
const lead = (midi, gain, length) => {
  const f = freq(midi);
  const a = sawOsc(f * cents(-9));
  const b = sawOsc(f * cents(9));
  const c = squareOsc(f * 0.5, 0.35);
  const filter = lowpass();
  return (t) => {
    const attack = Math.min(1, t / 0.004);
    const release = Math.min(1, Math.max(0, (length - t) / 0.08));
    const body = 0.25 + 0.75 * Math.exp(-t / 0.28);
    const cutoff = 1100 + 7000 * Math.exp(-t / 0.16);
    const raw = a() * 0.5 + b() * 0.5 + c() * 0.28;
    return filter(raw, cutoff, 0.45) * gain * attack * release * body;
  };
};

// Basse : dent de scie + sous-grave sinusoïdal, filtre qui s'ouvre à l'attaque.
const bassVoice = (midi, gain, length) => {
  const f = freq(midi);
  const saw = sawOsc(f);
  const sq = squareOsc(f, 0.5);
  const filter = lowpass();
  let phase = 0;
  return (t) => {
    const env = Math.min(1, t / 0.004) * Math.min(1, Math.max(0, (length - t) / 0.05)) * (0.4 + 0.6 * Math.exp(-t / 0.18));
    const cutoff = 140 + 900 * Math.exp(-t / 0.12);
    phase += TAU * f / SR;
    const sub = Math.sin(phase);
    return gain * env * (filter(saw() * 0.6 + sq() * 0.3, cutoff, 0.55) + sub * 0.65);
  };
};

const kick = (gain) => {
  let phase = 0;
  return (t) => {
    phase += TAU * (44 + 150 * Math.exp(-t * 34)) / SR;
    const body = Math.tanh(2.2 * Math.sin(phase)) * Math.exp(-t * 6.5) * (1 - Math.exp(-t * 3000));
    const click = random() * Math.exp(-t * 700) * 0.35;
    return gain * (body + click);
  };
};

const clap = (gain) => {
  let last = 0;
  const filter = lowpass();
  return (t) => {
    const n = random();
    const high = n - last * 0.5;
    last = n;
    const bursts = [0, 0.012, 0.024].reduce((sum, d) => sum + (t >= d ? Math.exp(-(t - d) * 70) : 0), 0);
    return gain * (filter(high, 5200, 0.8) * (bursts * 0.45 + Math.exp(-t * 13) * 0.55) * 1.4 + Math.sin(TAU * 190 * t) * Math.exp(-t * 40) * 0.18);
  };
};

const hat = (gain, decay) => {
  let last = 0;
  return (t) => {
    const n = random();
    const v = (n - last) * 0.5;
    last = n;
    return gain * v * Math.exp(-t * decay);
  };
};

const bell = (f, gain) => {
  const partials = [[1, 1, 1.4], [2.756, 0.6, 0.9], [5.404, 0.3, 0.6], [8.933, 0.15, 0.35]];
  return (t) =>
    gain * (1 - Math.exp(-t * 900)) *
    partials.reduce((sum, [mult, amp, decay]) => sum + amp * Math.sin(TAU * f * mult * t) * Math.exp(-t / decay), 0);
};

// Montée : bruit filtré dont la fréquence grimpe + glissando de dent de scie.
const addRiser = (buf, end, gain) => {
  const start = end - WHOOSH_LEN;
  const first = Math.max(0, Math.floor(start * SR));
  const last = Math.min(buf.n, Math.floor(end * SR));
  const filterL = lowpass();
  const filterR = lowpass();
  let phase = 0;
  for (let i = first; i < last; i++) {
    const x = (i - first) / (last - first);
    const cutoff = 250 * 38 ** x;
    phase += TAU * (180 * 7 ** x) / SR;
    const saw = ((phase / TAU) % 1) * 2 - 1;
    const amp = x * x * gain;
    buf.L[i] += (filterL(random(), cutoff, 0.5) * 1.2 + saw * 0.12) * amp;
    buf.R[i] += (filterR(random(), cutoff, 0.5) * 1.2 + saw * 0.12) * amp;
  }
};

const crash = (gain) => {
  let last = 0;
  return (t) => {
    const n = random();
    const v = (n - last) * 0.5;
    last = n;
    return gain * v * Math.exp(-t * 3.6);
  };
};

const impact = (gain) => {
  let phase = 0;
  return (t) => {
    phase += TAU * (38 + 60 * Math.exp(-t * 8)) / SR;
    return gain * Math.sin(phase) * Math.exp(-t * 2.6);
  };
};


// ---------------------------------------------------------------- instruments « warm »
// Marimba : fondamentale + partiels de lame de bois, attaque sèche.
const marimba = (f, gain) => {
  const partials = [[1, 1, 0.42], [3.93, 0.4, 0.12], [9.2, 0.12, 0.04]];
  return (t) =>
    gain * (1 - Math.exp(-t * 1500)) *
    partials.reduce((sum, [mult, amp, decay]) => sum + amp * Math.sin(TAU * f * mult * t) * Math.exp(-t / decay), 0);
};

// Corde pincée (Karplus-Strong) : sonne comme un ukulélé ou une guitare nylon.
const string = (f, gain, bright = 0.5) => {
  const size = Math.max(2, Math.round(SR / f));
  const line = new Float32Array(size);
  for (let i = 0; i < size; i++) line[i] = random() * bright + Math.sin((i / size) * TAU) * (1 - bright);
  let index = 0;
  return () => {
    const next = (index + 1) % size;
    const out = line[index];
    line[index] = 0.9965 * 0.5 * (line[index] + line[next]);
    index = next;
    return out * gain;
  };
};

// Sifflement : sinus avec vibrato tardif, un peu de souffle.
const whistle = (f, gain, length) => {
  let phase = 0;
  let breath = 0;
  return (t) => {
    const vibrato = 1 + Math.min(1, Math.max(0, (t - 0.12) / 0.2)) * 0.006 * Math.sin(TAU * 5.6 * t);
    phase += TAU * f * vibrato / SR;
    breath += 0.2 * (random() - breath);
    const env = Math.min(1, t / 0.025) * Math.min(1, Math.max(0, (length - t) / 0.07));
    return gain * env * (Math.sin(phase) + 0.12 * Math.sin(2 * phase) + breath * 0.08);
  };
};

// Basse ronde : sinus et sa première harmonique, attaque douce, pas de dent de scie agressive.
const roundBass = (midi, gain, length) => {
  const f = freq(midi);
  let phase = 0;
  return (t) => {
    const env = Math.min(1, t / 0.006) * Math.min(1, Math.max(0, (length - t) / 0.06)) * (0.45 + 0.55 * Math.exp(-t / 0.22));
    phase += TAU * f / SR;
    return gain * env * (Math.sin(phase) + 0.38 * Math.sin(2 * phase) + 0.1 * Math.sin(3 * phase));
  };
};

// Grosse caisse douce : chute de hauteur rapide, peu de clic.
const softKick = (gain) => {
  let phase = 0;
  return (t) => {
    phase += TAU * (48 + 90 * Math.exp(-t * 40)) / SR;
    return gain * Math.sin(phase) * Math.exp(-t * 9) * (1 - Math.exp(-t * 1500));
  };
};

// Claquement de mains chaleureux, plus rond que le clap électro.
const handclap = (gain) => {
  let last = 0;
  const filter = lowpass();
  return (t) => {
    const n = random();
    const v = (n - last * 0.4);
    last = n;
    const bursts = [0, 0.009, 0.019, 0.03].reduce((sum, d) => sum + (t >= d ? Math.exp(-(t - d) * 55) : 0), 0);
    return gain * filter(v, 3800, 0.9) * (bursts * 0.4 + Math.exp(-t * 11) * 0.6) * 1.5;
  };
};

// ---------------------------------------------------------------- composition
const composeElectro = (layout) => {
  const frames = Object.values(timing[layout].scenes);
  const total = frames.reduce((a, b) => a + b, 0) / timing.fps;
  const synth = makeBuffer(total); // synthés et basse (soumis au pompage)
  const drums = makeBuffer(total);
  const fx = makeBuffer(total);
  const kicks = [];
  let barCounter = 0;
  let start = 0;
  const map = [];

  SCENES.forEach((scene, index) => {
    const duration = frames[index] / timing.fps;
    const beat = 60 / scene.bpm;
    const barLen = beat * 4;
    const eighth = beat / 2;
    const end = start + duration;
    map.push({ scene: scene.name, start: +start.toFixed(2), bpm: scene.bpm });

    for (let bar = 0; start + bar * barLen < end - 0.05; bar++) {
      const tb = start + bar * barLen;
      const progIndex = barCounter % PROGRESSION.length;
      const chord = scene.final ? FINAL_CHORD : PROGRESSION[progIndex];
      barCounter++;
      const place = (positions, length, pan, make, bus) => {
        for (const position of positions) {
          const t = tb + position * beat;
          if (t < end) addVoice(bus, t, length, pan, make(position));
        }
      };

      // Nappe : accord tenu, filtre un peu ouvert pendant le drop.
      for (const note of chord.chord) {
        addStereo(synth, tb, barLen + 0.15, supersaw(note - 12, scene.pad, barLen + 0.15, { open: scene.drop ? 3200 : 1800, close: scene.drop ? 1800 : 900, decay: 0.4, attack: 0.04, hold: true }));
      }

      // Accords en staccato (« stabs ») sur les contretemps.
      for (const position of scene.stab) {
        const t = tb + position * beat;
        if (t >= end) continue;
        for (const note of chord.chord) addStereo(synth, t, 0.35, supersaw(note, scene.drop ? 0.2 : 0.15, 0.3, { open: 5200, close: 1100, decay: 0.09, release: 0.1 }));
      }

      // Basse rebondissante.
      for (const position of scene.bass) {
        const t = tb + position * beat;
        if (t < end) addVoice(synth, t, 0.4, 0, bassVoice(chord.bass, scene.drop ? 0.36 : 0.3, Math.min(0.32, beat * 0.45)));
      }

      // Batterie.
      for (const position of scene.kick) {
        const t = tb + position * beat;
        if (t < end) {
          addVoice(drums, t, 0.4, 0, kick(0.62));
          kicks.push(t);
        }
      }
      place(scene.clap, 0.3, 0.1, () => clap(scene.drop ? 0.26 : 0.2), drums);
      place(scene.hat, 0.1, -0.25, (p) => hat(p % 1 === 0 ? 0.045 : 0.06, 110), drums);
      place(scene.open, 0.3, 0.25, () => hat(0.07, 24), drums);
      if (scene.shaker) place(sixteenths, 0.08, 0.3, (p) => hat(p % 0.5 === 0 ? 0.018 : 0.03, 140), drums);
      if (scene.fill && bar % 2 === 1) place([3, 3.25, 3.5, 3.75], 0.2, 0, (p) => clap(0.12 + (p - 3) * 0.12), drums);

      // Motif accrocheur au synthé lead, avec un écho rythmé.
      const hook = scene.final ? FINAL_HOOK : HOOK[progIndex];
      for (const [pos, note, len] of hook) {
        const t = tb + pos * eighth;
        if (t >= end) continue;
        const length = len * eighth;
        const layers = scene.lead >= 3 ? [0, 12, -12] : scene.lead === 2 ? [0, 12] : [0];
        layers.forEach((shift, layer) => {
          const g = scene.leadGain * (layer === 0 ? 1 : 0.55);
          addVoice(synth, t, length + 0.15, -0.15 + layer * 0.12, lead(note + shift, g, length));
          if (!scene.final) {
            addVoice(synth, t + beat * 0.75, length + 0.1, 0.4, lead(note + shift, g * 0.32, length));
            addVoice(synth, t + beat * 1.5, length + 0.1, -0.4, lead(note + shift, g * 0.14, length));
          }
        });
      }

      if (scene.final) {
        for (const position of [0, 1, 2, 3]) {
          const t = tb + position * beat;
          if (t < end) addVoice(fx, t, 1.6, position % 2 ? -0.4 : 0.4, bell(freq(FINAL_CHORD.chord[position % 3] + 24), 0.07));
        }
      }
    }

    if (index > 0) {
      addRiser(fx, start, 0.3);
      addVoice(fx, start, 2.2, 0, crash(scene.drop ? 0.2 : 0.14));
      addVoice(fx, start, 1.4, 0, impact(0.32));
      addVoice(fx, start, 1.6, 0.3, bell(freq(84), 0.12));
      kicks.push(start);
    }
    start = end;
  });

  return { synth, drums, fx, kicks, total, map };
};



// ---------------------------------------------------------------- instruments « pro »
const tightKick = (gain) => {
  let phase = 0;
  return (t) => {
    phase += TAU * (52 + 130 * Math.exp(-t * 55)) / SR;
    return gain * (Math.sin(phase) * Math.exp(-t * 11) * (1 - Math.exp(-t * 2500)) + random() * Math.exp(-t * 900) * 0.22);
  };
};

const tightSnare = (gain) => {
  const filter = lowpass();
  return (t) =>
    gain * (filter(random(), 7200, 0.9) * Math.exp(-t * 20) * 1.3 + Math.sin(TAU * 185 * t) * Math.exp(-t * 30) * 0.45) * (1 - Math.exp(-t * 3000));
};

const rim = (gain) => (t) =>
  gain * (Math.sin(TAU * 1750 * t) * Math.exp(-t * 150) + random() * Math.exp(-t * 400) * 0.2);

// Pluck de synthé étouffé : deux dents de scie, filtre qui se ferme très vite.
const synthPluck = (midi, gain, length, decay = 0.1, cutoff = 4200) => {
  const f = freq(midi);
  const a = sawOsc(f * cents(-5));
  const b = sawOsc(f * cents(5));
  const filter = lowpass();
  return (t) => {
    const env = Math.min(1, t / 0.002) * Math.min(1, Math.max(0, (length - t) / 0.04)) * Math.exp(-t / (decay * 2.2));
    return filter((a() + b()) * 0.5, 500 + cutoff * Math.exp(-t / decay), 0.5) * gain * env;
  };
};

// Basse : sous-grave sinusoïdal + couche médium en dent de scie (audible sur un téléphone).
const proBass = (midi, gain, length) => {
  const f = freq(midi);
  const saw = sawOsc(f * 2);
  const filter = lowpass();
  let phase = 0;
  return (t) => {
    const env = Math.min(1, t / 0.008) * Math.min(1, Math.max(0, (length - t) / 0.05));
    phase += TAU * f / SR;
    return gain * env * (Math.sin(phase) * 0.9 + filter(saw(), 380 + 500 * Math.exp(-t / 0.1), 0.6) * 0.5);
  };
};

// Accélération : roulement de caisse claire dont les intervalles se resserrent, juste avant le changement.
const addAccelRoll = (buf, end) => {
  const last = end - GAP;
  let t = last;
  let gap = 0.2;
  let velocity = 0.2;
  while (gap > 0.03 && t > end - 1.2) {
    addVoice(buf, t, 0.22, 0, tightSnare(velocity));
    t -= gap;
    gap *= 0.78;
    velocity *= 0.86;
  }
};

// Impact net : sous-grave qui chute, coup de grosse caisse et souffle de cymbale.
const addImpact = (buf, fx, at, gain) => {
  addVoice(fx, at, 1.4, 0, (t) => {
    const f = 40 + 140 * Math.exp(-t * 14);
    return gain * Math.sin(TAU * (f * t)) * Math.exp(-t * 2.4) * (1 - Math.exp(-t * 800));
  });
  addVoice(buf, at, 0.4, 0, tightKick(0.75));
};


// ---------------------------------------------------------------- composition « pro »
const PRO_PROGRESSION = [
  { bass: 33, chord: [57, 60, 64, 67] }, // Am7
  { bass: 29, chord: [53, 57, 60, 64] }, // Fmaj7
  { bass: 36, chord: [55, 60, 64, 67] }, // C
  { bass: 31, chord: [55, 59, 62, 67] }, // G
];
const PRO_HOOK = [
  [[0, 76, 1], [1, 79, 1], [2, 81, 3]], // E G A
  [[0, 72, 1], [1, 76, 1], [2, 77, 3]], // C E F
  [[0, 72, 1], [1, 76, 1], [2, 79, 3]], // C E G
  [[0, 74, 1], [1, 79, 1], [2, 83, 3]], // D G B
];
const PRO_FINAL_HOOK = [[0, 76, 1], [1, 79, 1], [2, 84, 6]];
const PRO_FINAL_CHORD = { bass: 36, chord: [55, 60, 64, 72] };
const ARP = [0, 2, 1, 3, 2, 1, 3, 2];

// Un seul tempo, une seule grille rythmique pour toute la vidéo : le beat ne s'arrête jamais.
// 120 BPM : tous les changements de scène tombent exactement sur un temps (durées multiples de 0,5 s).
const PRO_BPM = 120;
const all8 = [0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5];
const all16 = [...Array(16).keys()].map((k) => k / 4);
const off8 = [0.5, 1.5, 2.5, 3.5];

// Le socle (grosse caisse, caisse claire, basse, charleston, arpège) tourne dès la première seconde ;
// les scènes ajoutent seulement des couches par-dessus (accords, motif, charleston plus serré).
const PRO = [
  { name: "hook", kick: [0, 1, 2, 3], snare: [1, 3], hat: off8, open: [], bass: all8, arp: 2, arpGain: 0.06, stab: [], lead: false, leadGain: 0, fill: false },
  { name: "pick", kick: [0, 1, 2, 3], snare: [1, 3], hat: off8, open: [], bass: all8, arp: 4, arpGain: 0.065, stab: [0.5, 2.5], lead: false, leadGain: 0, fill: false },
  { name: "formats", kick: [0, 1, 2, 3], snare: [1, 3], hat: all8, open: [], bass: all8, arp: 4, arpGain: 0.07, stab: [0.5, 2.5], lead: true, leadGain: 0.1, fill: false },
  { name: "options", kick: [0, 1, 2, 3], snare: [1, 3], hat: all16, open: off8, bass: all8, arp: 4, arpGain: 0.075, stab: off8, lead: true, leadGain: 0.11, fill: false },
  { name: "privacy", kick: [0, 1, 2, 3], snare: [1, 3], hat: all16, open: off8, bass: all8, arp: 4, arpGain: 0.085, stab: off8, lead: true, leadGain: 0.13, fill: false, drop: true },
  { name: "cta", kick: [0, 1, 2, 3], snare: [1, 3], hat: all8, open: [], bass: all8, arp: 2, arpGain: 0.07, stab: [0.5, 2.5], lead: true, leadGain: 0.11, fill: false },
];

const composePro = (layout) => {
  const frames = Object.values(timing[layout].scenes);
  const total = frames.reduce((a, b) => a + b, 0) / timing.fps;
  const synth = makeBuffer(total);
  const drums = makeBuffer(total);
  const fx = makeBuffer(total);
  const kicks = [];
  const beat = 60 / PRO_BPM;
  const barLen = beat * 4;
  const eighth = beat / 2;
  const bounds = [];
  let acc = 0;
  for (const f of frames) {
    bounds.push([acc, acc + f / timing.fps]);
    acc += f / timing.fps;
  }
  const map = PRO.map((scene, i) => ({ scene: scene.name, start: +bounds[i][0].toFixed(2), bpm: PRO_BPM }));

  PRO.forEach((scene, index) => {
    const [start, end] = bounds[index];
    const inScene = (t) => t >= start - 1e-6 && t < end - 1e-6;
    for (let bar = Math.floor(start / barLen + 1e-9); bar * barLen < end - 1e-6; bar++) {
      const tb = bar * barLen;
      const progIndex = bar % PRO_PROGRESSION.length;
      const chord = PRO_PROGRESSION[progIndex];
      const place = (positions, length, pan, make, bus) => {
        for (const position of positions) {
          const t = tb + position * beat;
          if (inScene(t)) addVoice(bus, t, length, pan, make(position, t));
        }
      };

      // Nappe : une par mesure, continue d'une scène à l'autre.
      if (inScene(tb)) {
        for (const note of chord.chord) {
          addStereo(synth, tb, barLen + 0.12, supersaw(note - 12, 0.045, barLen + 0.12, { open: 1600, close: 600, decay: 0.6, attack: 0.05, hold: true }));
        }
      }
      for (const position of scene.stab) {
        const t = tb + position * beat;
        if (!inScene(t)) continue;
        for (const note of chord.chord) addStereo(synth, t, 0.22, supersaw(note, scene.drop ? 0.13 : 0.1, 0.18, { open: 3400, close: 600, decay: 0.05, release: 0.06 }));
      }

      place(scene.bass, 0.35, 0, () => proBass(chord.bass, scene.drop ? 0.42 : 0.37, Math.min(0.28, beat * 0.45)), synth);
      place(scene.kick, 0.4, 0, (p, t) => {
        kicks.push(t);
        return tightKick(scene.drop ? 0.66 : 0.58);
      }, drums);
      place(scene.snare, 0.25, 0.05, () => tightSnare(scene.drop ? 0.3 : 0.24), drums);
      place(scene.hat, 0.08, -0.2, (p) => hat(p % 1 === 0 ? 0.045 : (p % 0.5 === 0 ? 0.07 : 0.03), 130), drums);
      place(scene.open, 0.25, 0.25, () => hat(0.065, 28), drums);
      if (scene.fill && bar % 2 === 1) place([3, 3.25, 3.5, 3.75], 0.2, 0, (p) => tightSnare(0.1 + (p - 3) * 0.14), drums);

      // Arpège de synthé étouffé, en ping-pong.
      for (let k = 0; k < 4 * scene.arp; k++) {
        const t = tb + k * (beat / scene.arp);
        if (!inScene(t)) continue;
        const note = chord.chord[ARP[k % ARP.length] % chord.chord.length] + 12;
        addVoice(synth, t, 0.3, k % 2 === 0 ? -0.4 : 0.4, synthPluck(note, scene.arpGain, 0.25, 0.07));
        if (scene.arp >= 4 && k % 3 === 0) addVoice(synth, t + beat * 0.75, 0.2, k % 2 === 0 ? 0.5 : -0.5, synthPluck(note, scene.arpGain * 0.25, 0.15, 0.06));
      }

      // Motif court et sérieux : deux croches puis une tenue.
      if (scene.lead) {
        for (const [pos, note, len] of PRO_HOOK[progIndex]) {
          const t = tb + pos * eighth;
          if (!inScene(t)) continue;
          const length = len * eighth;
          addVoice(synth, t, length + 0.2, -0.1, synthPluck(note, scene.leadGain, length + 0.15, 0.22, 5200));
          addVoice(synth, t, length + 0.2, 0.1, synthPluck(note + 12, scene.leadGain * 0.35, length + 0.1, 0.16, 5200));
          addVoice(synth, t + beat * 0.75, 0.4, 0.45, synthPluck(note, scene.leadGain * 0.3, 0.2, 0.12, 4200));
        }
      }
    }

    // Par-dessus le beat continu : seulement l'accélération (roulement + souffle ascendant) et un léger accent.
    if (index > 0) {
      addAccelRoll(drums, start);
      addRiser(fx, start, 0.15);
      addVoice(fx, start, 1.4, 0, crash(scene.drop ? 0.1 : 0.07));
    }
  });

  return { synth, drums, fx, kicks, gaps: [], total, map };
};

// ---------------------------------------------------------------- composition « warm »
// Rythme de ukulélé : bas, bas, haut, haut, bas, haut.
const strum = [0, 1, 1.5, 2.5, 3, 3.5];
const WARM = [
  { name: "hook", bpm: 100, kick: [0, 2], clap: [1, 3], shaker: false, bass: [0, 1.5, 2], strum, marimba: false, whistle: true, pad: 0.035, hookGain: 0.2, fill: false },
  { name: "pick", bpm: 106, kick: [0, 2, 3.5], clap: [1, 3], shaker: true, bass: [0, 0.75, 1.5, 2, 2.75, 3.5], strum, marimba: true, whistle: true, pad: 0.04, hookGain: 0.2, fill: false },
  { name: "formats", bpm: 112, kick: [0, 1, 2, 3], clap: [1, 3], shaker: true, bass: [0, 0.75, 1.5, 2, 2.75, 3.5], strum, marimba: true, whistle: true, pad: 0.045, hookGain: 0.21, fill: false },
  { name: "options", bpm: 118, kick: [0, 1, 2, 3], clap: [1, 1.5, 3], shaker: true, bass: [0, 0.75, 1.5, 2, 2.75, 3.5], strum, marimba: true, whistle: true, pad: 0.05, hookGain: 0.22, fill: true },
  { name: "privacy", bpm: 124, kick: [0, 1, 2, 2.75, 3], clap: [1, 1.5, 3, 3.5], shaker: true, bass: [0, 0.5, 0.75, 1.5, 2, 2.5, 2.75, 3.5], strum, marimba: true, whistle: true, pad: 0.065, hookGain: 0.24, fill: false, drop: true },
  { name: "cta", bpm: 110, kick: [0], clap: [], shaker: false, bass: [0], strum: [0], marimba: true, whistle: true, pad: 0.07, hookGain: 0.22, fill: false, final: true },
];

const composeWarm = (layout) => {
  const frames = Object.values(timing[layout].scenes);
  const total = frames.reduce((a, b) => a + b, 0) / timing.fps;
  const synth = makeBuffer(total);
  const drums = makeBuffer(total);
  const fx = makeBuffer(total);
  const kicks = [];
  let barCounter = 0;
  let start = 0;
  const map = [];

  WARM.forEach((scene, index) => {
    const duration = frames[index] / timing.fps;
    const beat = 60 / scene.bpm;
    const barLen = beat * 4;
    const eighth = beat / 2;
    const end = start + duration;
    map.push({ scene: scene.name, start: +start.toFixed(2), bpm: scene.bpm });

    for (let bar = 0; start + bar * barLen < end - 0.05; bar++) {
      const tb = start + bar * barLen;
      const progIndex = barCounter % PROGRESSION.length;
      const chord = scene.final ? FINAL_CHORD : PROGRESSION[progIndex];
      barCounter++;

      // Nappe chaude, très filtrée (cordes douces).
      for (const note of chord.chord) {
        addStereo(synth, tb, barLen + 0.15, supersaw(note - 12, scene.pad, barLen + 0.15, { open: 1300, close: 650, decay: 0.5, attack: 0.07, hold: true }));
      }

      // Ukulélé : accord gratté, notes décalées de quelques millisecondes.
      for (const position of scene.strum) {
        const t = tb + position * beat;
        if (t >= end) continue;
        const up = position % 1 !== 0;
        chord.chord.forEach((note, i) => {
          const order = up ? chord.chord.length - 1 - i : i;
          addVoice(synth, t + order * 0.011, 0.9, -0.3 + i * 0.3, string(freq(note + 12), up ? 0.075 : 0.11, 0.55));
        });
      }

      for (const position of scene.bass) {
        const t = tb + position * beat;
        if (t < end) addVoice(synth, t, 0.45, 0, roundBass(chord.bass, scene.drop ? 0.4 : 0.34, Math.min(0.34, beat * 0.5)));
      }

      for (const position of scene.kick) {
        const t = tb + position * beat;
        if (t < end) {
          addVoice(drums, t, 0.4, 0, softKick(scene.drop ? 0.62 : 0.55));
          kicks.push(t);
        }
      }
      for (const position of scene.clap) {
        const t = tb + position * beat;
        if (t < end) addVoice(drums, t, 0.3, 0.1, handclap(position % 1 === 0 ? 0.24 : 0.14));
      }
      if (scene.shaker) {
        for (let k = 0; k < 16; k++) {
          const t = tb + (k / 4) * beat;
          if (t < end) addVoice(drums, t, 0.08, 0.3, hat(k % 2 === 0 ? 0.02 : 0.035, 150));
        }
      }
      if (scene.fill && bar % 2 === 1) {
        for (const position of [3, 3.25, 3.5, 3.75]) {
          const t = tb + position * beat;
          if (t < end) addVoice(drums, t, 0.2, 0, handclap(0.1 + (position - 3) * 0.12));
        }
      }

      // Thème sifflé, doublé au marimba, avec un petit écho.
      const hook = scene.final ? FINAL_HOOK : HOOK[progIndex];
      for (const [pos, note, len] of hook) {
        const t = tb + pos * eighth;
        if (t >= end) continue;
        const length = len * eighth;
        addVoice(synth, t, length + 0.12, -0.1, whistle(freq(note + (scene.final ? 0 : 0)), scene.hookGain, length));
        if (scene.marimba) {
          addVoice(synth, t, 0.8, 0.25, marimba(freq(note - 12), scene.hookGain * 0.55));
          if (!scene.final) addVoice(synth, t + beat * 0.75, 0.6, -0.35, marimba(freq(note - 12), scene.hookGain * 0.18));
        }
      }

      if (scene.final) {
        for (const position of [0, 1, 2, 3]) {
          const t = tb + position * beat;
          if (t < end) addVoice(fx, t, 1.6, position % 2 ? -0.4 : 0.4, bell(freq(FINAL_CHORD.chord[position % 3] + 24), 0.07));
        }
      }
    }

    if (index > 0) {
      addRiser(fx, start, 0.16);
      addVoice(fx, start, 1.6, 0, crash(scene.drop ? 0.13 : 0.09));
      addVoice(fx, start, 1.0, 0, impact(0.18));
      addVoice(fx, start, 1.6, 0.3, bell(freq(84), 0.12));
      kicks.push(start);
    }
    start = end;
  });

  return { synth, drums, fx, kicks, total, map };
};

// ---------------------------------------------------------------- mixage
const mix = ({ synth, drums, fx, kicks, gaps = [] }) => {
  const depth = STYLE === "warm" ? 0.3 : STYLE === "pro" ? 0.45 : DUCK_DEPTH;
  let g = 0;
  const out = makeBuffer(synth.n / SR);
  let k = 0;
  for (let i = 0; i < out.n; i++) {
    const t = i / SR;
    while (k + 1 < kicks.length && kicks[k + 1] <= t) k++;
    const since = kicks.length && kicks[k] <= t ? t - kicks[k] : 10;
    const duck = 1 - depth * Math.exp(-since / DUCK_TIME) * Math.min(1, since / 0.003 + 0.2);
    while (g < gaps.length && gaps[g][1] <= t) g++;
    let gate = 1;
    if (g < gaps.length && t >= gaps[g][0]) gate = Math.max(0, 1 - (t - gaps[g][0]) / 0.004);
    out.L[i] = (synth.L[i] * duck + drums.L[i] + fx.L[i]) * gate;
    out.R[i] = (synth.R[i] * duck + drums.R[i] + fx.R[i]) * gate;
  }
  return out;
};

const reverb = (buf) => {
  const delays = [0.0297, 0.0371, 0.0411, 0.0437];
  for (const [channel, spread] of [[buf.L, 1], [buf.R, 1.07]]) {
    const dry = Float32Array.from(channel);
    const wet = new Float32Array(buf.n);
    for (const d of delays) {
      const size = Math.round(d * spread * SR);
      const y = new Float32Array(buf.n);
      for (let i = 0; i < buf.n; i++) {
        y[i] = dry[i] + (i >= size ? 0.45 * y[i - size] : 0);
        wet[i] += y[i] / delays.length;
      }
    }
    for (let i = 0; i < buf.n; i++) channel[i] = dry[i] * 0.88 + wet[i] * 0.16;
  }
};

const master = (buf) => {
  reverb(buf);
  let sum = 0;
  for (let i = 0; i < buf.n; i++) sum += buf.L[i] ** 2 + buf.R[i] ** 2;
  const rms = Math.sqrt(sum / (2 * buf.n));
  const gain = 10 ** (TARGET_RMS_DB / 20) / rms;
  let peak = 0;
  for (let i = 0; i < buf.n; i++) {
    const t = i / SR;
    const fade = Math.min(1, t / FADE_IN) * Math.min(1, Math.max(0, (buf.n / SR - t) / FADE_OUT));
    for (const channel of [buf.L, buf.R]) {
      channel[i] = Math.tanh(channel[i] * gain * (STYLE === "pro" ? 2.1 : 1.3)) * fade;
      peak = Math.max(peak, Math.abs(channel[i]));
    }
  }
  const scale = (STYLE === "pro" ? 0.64 : PEAK) / peak;
  for (let i = 0; i < buf.n; i++) {
    buf.L[i] *= scale;
    buf.R[i] *= scale;
  }
};

const writeWav = (path, buf) => {
  const data = Buffer.alloc(44 + buf.n * 4);
  data.write("RIFF", 0);
  data.writeUInt32LE(36 + buf.n * 4, 4);
  data.write("WAVEfmt ", 8);
  data.writeUInt32LE(16, 16);
  data.writeUInt16LE(1, 20);
  data.writeUInt16LE(2, 22);
  data.writeUInt32LE(SR, 24);
  data.writeUInt32LE(SR * 4, 28);
  data.writeUInt16LE(4, 32);
  data.writeUInt16LE(16, 34);
  data.write("data", 36);
  data.writeUInt32LE(buf.n * 4, 40);
  for (let i = 0; i < buf.n; i++) {
    data.writeInt16LE(Math.round(Math.max(-1, Math.min(1, buf.L[i])) * 32767), 44 + i * 4);
    data.writeInt16LE(Math.round(Math.max(-1, Math.min(1, buf.R[i])) * 32767), 46 + i * 4);
  }
  writeFileSync(path, data);
};

mkdirSync(new URL("../public/", import.meta.url), { recursive: true });
for (const [layout, name] of [["vertical", "9x16"], ["wide", "16x9"]]) {
  seed = 20251021;
  let s = 7;
  Math.random = () => {
    s = (s * 1664525 + 1013904223) >>> 0;
    return s / 4294967296;
  };
  const composed = STYLE === "warm" ? composeWarm(layout) : STYLE === "electro" ? composeElectro(layout) : composePro(layout);
  const out = mix(composed);
  master(out);
  writeWav(new URL(`../public/music-${name}.wav`, import.meta.url), out);
  console.log(`music-${name}.wav (${STYLE}) : ${composed.total.toFixed(1)} s`);
  for (const row of composed.map) console.log(`  ${row.scene.padEnd(8)} à ${String(row.start).padStart(5)} s : ${row.bpm} BPM`);
}
