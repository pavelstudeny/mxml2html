---
name: display-music-notation-html
description: Guide agents to display, render, visualize, or draw musical notation using HTML and CSS.
---

# Musical Notation Display Skill

## Overview

Use this skill to render Modern music notation using **Unicode/SMuFL glyphs** styled with CSS as HTML. Every symbol — noteheads, stems, clefs, rests, accidentals, barlines — is a Unicode character rendered with the **MusicaD font** (a BravuraText SMuFL font). No SVG drawing is needed for the symbols themselves.

The 5 staff lines are drawn as a CSS `background-image` using a base64-encoded inline SVG on a positioned `div`. Everything else is relatively-positioned `<span>` elements with `font-family: MusicaD`.

---

## Font Setup

 The MusicaD font is available for download at https://github.com/steinbergmedia/bravura/releases and onlinne at https://pavel.hrajou.cz/music/MusicaD.ttf. However, this project uses a local copy at fonts/MusicaD.ttf.
 Always load MusicaD at the top of every widget:

```css
@font-face {
  font-family: 'MusicaD';
  src: url('fonts/MusicaD.ttf');
}
```

Apply to all music symbols:
```css
.staff {
  font-family: 'MusicaD';
  line-height: 1;
  white-space: nowrap;
}
.staff span {
  position: relative;
}
```

---

## Mucic Notation Transposition

The full range of tones composes of 7 tones (octaves) with tones C, D, E, F, G, B, where the frequency (pitch) of each tones doubles with the next octave. Octaves are numbered. For example, A4 frequency is 440Hz, and A5 is 880Hz.

Normally, the lowest note is C0 (16.35Hz) and the highest is G9 (12543.85Hz), although certain instruments can go beyond this range.

This way, the first C below the staff lines in the treble clef is C4. However, for the purpose of playing various instruments with various tone ranges, musicians would call the first C below the staff lines C1, independently on the actual frequency (261.63 Hz, but also 130.81 Hz or 523.25 Hz).

---

## Core Layout Model

All music notation is inside a .staff div.

5 staff lines are drawn as a single CSS `background-image` on the `.staff` div.
- `background-image`: base64 SVG with 5 lines at 0%, 25%, 50%, 75%, 100%
Bar line in the MusicaD font is 0.7em tall, so the staff height is also 0.7em. Use `background-size:100% 0.7em` to stretch the lines to fill the staff height.
background-position-y is 0.14em, which is also the distance between the staff lines.

All music symbols are `<span class="<note type>">` with `position:relative`, where <note type> determines the y-position. Example:
```html
<span class="D1">&#x1D15D;</span> <!-- whole D1 note, stem up -->
```

---

## Note (SMuFL Glyph) Positioning

### Notes inside the staff or directly adjacent to the staff from outside

Positioning a note glyph means placing the `<span>` such that its baseline (= CSS `top` + ascent adjustment) lands on the target pitch.

Positions for the treble clef:

| Musician-called Note | top     | Stem direction | `class` |
|----------------------|---------|----------------|---------|
| D1                   | -0.38em | up             | D4      |
| E1                   | -0.45em | up             | E4      |
| F1                   | -0.52em | up             | F4      |
| G1                   | -0.59em | up             | G4      |
| A1                   | -0.66em | up             | A4      |
| B1                   | -0.73em | up             | B4      |
| C2                   | -0.80em | down           | C5      |
| D2                   | -0.87em | down           | D5      |
| E2                   | -0.94em | down           | E5      |
| F2                   | -1.01em | down           | F5      |

Notes that have stem down have the following a `stemdown` class that creates the steam down effect:
```css
.stem-down {
  /* CSS rules for stem down effect */
  transform: rotate(180deg) translateY(-0.7em);
  display: inline-block;}
```

**Stem rule**: step ≤ 4 (B1 and below) → stem up (`E1D5`, `E1D7`…); step ≥ 5 → stem down (`E1D6`, `E1D8`…).

### Rests positioning

| Duration | Codepoint   | top.      |
|----------|-------------|------------|
| Whole    | `&#x1D13B;` | `-0.73em` (hangs from line 2) |
| Half     | `&#x1D13C;` | `-0.68em` (sits on line 3) |
| Quarter  | `&#x1D13D;` | `-0.63em` |
| Eighth   | `&#x1D13E;` | `-0.73em` |
| 16th     | `&#x1D13F;` | `-0.73em` |

### Bar line positioning
-038em

---

## SMuFL Codepoint Reference

### Clefs
The `top` value places the clef's pitch-anchor on the correct line.

| Symbol          | Codepoint | HTML entity | font-size | top       | `class` |
|-----------------|-----------|-------------|-----------|-----------|---------|
| Treble (G) clef | U+1D11E.  | `&#x1D11E;` | `1.5em`   | `-0.20em` | Gclef   |
| Bass (F) clef   | U+1D122   | `&#x1D122;` | `1em`     | `0em`     | Fclef   |
| Alto (C) clef   | U+1D121   | `&#x1D121;` | `1em`     | `0em`     | Cclef   |

### Precomposed Notes (stem + notehead, for use on a staff)
Position `top` per Note positioning above.

| Duration | Cdepoint   |
|----------|------------|
| Whole    | `&#x1D15D;`|
| Half     | `&#x1D15E;` |
| Quarter  | `&#x1D15F;` |
| Eighth   | `&#x1D160;` |
| 16th     | `&#x1D161;` |
| 32nd     | `&#x1D162;` |
| 64th     | `&#x1D163;` |
| 128th    | `&#x1D164;` |


### Accidentals

| Symbol | Codepoint |
|--------|-----------|
| Sharp ♯ | `&#x1D262;` |
| Flat ♭ | `&#x1D260;` |
| Natural ♮ | `&#x1D261;` |
| Double sharp | `&#x1D263;` |
| Double flat | `&#x1D264;` |

### Time Signatures
Time signature consists of two numbers, where the lower number represents the basic note length (4 = quarter note, 8 = eighth note, etc.) and the upper number represents how many of those notes fit in a measure.

Signatures are rendered as <span><sup>upper number</sup> / <sub>lower number</sub></span>, with font-size:0.7em and top:-0.65em;
Example:
```html
<span><sup>2</sup>/<sub>4</sub></span>
```

### Barlines
Barlines use `font-size:1em` (= staff height) and `top:0`. This makes the glyph start exactly at the top staff line and finish at the bottom staff line.

| Symbol | Codepoint |
|--------|-----------|
| Single barline | `&#x1D100;` |
| Double barline | `&#x1D101;` |
| Final barline  | `&#x1D102;` |
| Repeat (right) | `&#x1D104;` |
| Repeat (left)  | `&#x1D105;` |

### Dynamics
Position below staff (`top:1em`). These are text-style glyphs.

| Symbol | Codepoint |
|--------|-----------|
| p  | `&#x1D520;` |
| mp | `&#x1D52C;` |
| mf | `&#x1D52D;` |
| f  | `&#x1D522;` |
| ff | `&#x1D52F;` |
| pp | `&#x1D52A;` |
| sf / sfz | `&#x1D524;` / `&#x1D525;` |

### Articulations
Position above or below the notehead (adjust `top` accordingly).

| Symbol | Codepoint |
|--------|-----------|
| Staccato | `&#x1D4A2;` |
| Accent (>) | `&#x1D4A0;` |
| Tenuto (—) | `&#x1D4A4;` |
| Marcato (^) | `&#x1D4AC;` |
| Fermata above | `&#x1D4C0;` |

### Ornaments / Misc
| Symbol | Codepoint |
|--------|-----------|
| Trill (tr) | `&#x1D566;` |
| Augmentation dot | `&#x1D1E7;` — place at pitch_y, left = note_x + ~10px |

---

## Staff Background CSS

Two data URIs for light and dark mode:

```css
.staff {
  position: relative;
  overflow: visible;
  background-image: url('data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPjxsaW5lIHgxPSIwIiB5MT0iMCIgeDI9IjEwMCUiIHkyPSIwIiBzdHJva2U9InJnYmEoMCwwLDAsMC43KSIgc3Ryb2tlLXdpZHRoPSIxLjIiLz48bGluZSB4MT0iMCIgeTE9IjI1JSIgeDI9IjEwMCUiIHkyPSIyNSUiIHN0cm9rZT0icmdiYSgwLDAsMCwwLjcpIiBzdHJva2Utd2lkdGg9IjEuMiIvPjxsaW5lIHgxPSIwIiB5MT0iNTAlIiB4Mj0iMTAwJSIgeTI9IjUwJSIgc3Ryb2tlPSJyZ2JhKDAsMCwwLDAuNykiIHN0cm9rZS13aWR0aD0iMS4yIi8+PGxpbmUgeDE9IjAiIHkxPSI3NSUiIHgyPSIxMDAlIiB5Mj0iNzUlIiBzdHJva2U9InJnYmEoMCwwLDAsMC43KSIgc3Ryb2tlLXdpZHRoPSIxLjIiLz48bGluZSB4MT0iMCIgeTE9IjEwMCUiIHgyPSIxMDAlIiB5Mj0iMTAwJSIgc3Ryb2tlPSJyZ2JhKDAsMCwwLDAuNykiIHN0cm9rZS13aWR0aD0iMS4yIi8+PC9zdmc+');
  background-size: 100% 0.7em;
  background-repeat: no-repeat;
  background-position-y: 0.14em;
}
@media (prefers-color-scheme: dark) {
  .staff {
    background-image: url('data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPjxsaW5lIHgxPSIwIiB5MT0iMCIgeDI9IjEwMCUiIHkyPSIwIiBzdHJva2U9InJnYmEoMjU1LDI1NSwyNTUsMC43KSIgc3Ryb2tlLXdpZHRoPSIxLjIiLz48bGluZSB4MT0iMCIgeTE9IjI1JSIgeDI9IjEwMCUiIHkyPSIyNSUiIHN0cm9rZT0icmdiYSgyNTUsMjU1LDI1NSwwLjcpIiBzdHJva2Utd2lkdGg9IjEuMiIvPjxsaW5lIHgxPSIwIiB5MT0iNTAlIiB4Mj0iMTAwJSIgeTI9IjUwJSIgc3Ryb2tlPSJyZ2JhKDI1NSwyNTUsMjU1LDAuNykiIHN0cm9rZS13aWR0aD0iMS4yIi8+PGxpbmUgeDE9IjAiIHkxPSI3NSUiIHgyPSIxMDAlIiB5Mj0iNzUlIiBzdHJva2U9InJnYmEoMjU1LDI1NSwyNTUsMC43KSIgc3Ryb2tlLXdpZHRoPSIxLjIiLz48bGluZSB4MT0iMCIgeTE9IjEwMCUiIHgyPSIxMDAlIiB5Mj0iMTAwJSIgc3Ryb2tlPSJyZ2JhKDI1NSwyNTUsMjU1LDAuNykiIHN0cm9rZS13aWR0aD0iMS4yIi8+PC9zdmc+');
  }
}
```

The base64 strings decode to:
```xml
<!-- Light (rgba(0,0,0,0.7) stroke): -->
<svg xmlns="http://www.w3.org/2000/svg">
  <line x1="0" y1="0"    x2="100%" y2="0"    stroke="rgba(0,0,0,0.7)"   stroke-width="1.2"/>
  <line x1="0" y1="25%"  x2="100%" y2="25%"  stroke="rgba(0,0,0,0.7)"   stroke-width="1.2"/>
  <line x1="0" y1="50%"  x2="100%" y2="50%"  stroke="rgba(0,0,0,0.7)"   stroke-width="1.2"/>
  <line x1="0" y1="75%"  x2="100%" y2="75%"  stroke="rgba(0,0,0,0.7)"   stroke-width="1.2"/>
  <line x1="0" y1="100%" x2="100%" y2="100%" stroke="rgba(0,0,0,0.7)"   stroke-width="1.2"/>
</svg>
<!-- Dark: same but stroke="rgba(255,255,255,0.7)" -->
```

---

## HTML Structure

```html
<div class="score">            <!-- padding: 60px top+bottom for clefs/dynamics -->
  <div class="staff">
    <span class="<note>">GLYPH</span>
    …
  </div>
</div>
```

### Horizontal Layout (default x positions)

```
x=2px:    Treble clef (&#x1D11E;) at font-size:4em
x=64px:   Time signature digits at font-size:2em
x=100px:  First note (after clef + 4/4 time sig, no key sig)
x=152px:  Second note
x=204px:  Third note
…spacing: 52px between note centers
```

With key signature, shift notes right by ~14px per accidental.

---

## Complete Boilerplate

```html
<style>
@font-face { font-family:'MusicaD'; src:url('fonts/MusicaD.ttf'); }
.score { padding:80px 16px 64px; }
.staff {
  overflow:visible;
  background-image:url('data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPjxsaW5lIHgxPSIwIiB5MT0iMCIgeDI9IjEwMCUiIHkyPSIwIiBzdHJva2U9InJnYmEoMCwwLDAsMC43KSIgc3Ryb2tlLXdpZHRoPSIxLjIiLz48bGluZSB4MT0iMCIgeTE9IjI1JSIgeDI9IjEwMCUiIHkyPSIyNSUiIHN0cm9rZT0icmdiYSgwLDAsMCwwLjcpIiBzdHJva2Utd2lkdGg9IjEuMiIvPjxsaW5lIHgxPSIwIiB5MT0iNTAlIiB4Mj0iMTAwJSIgeTI9IjUwJSIgc3Ryb2tlPSJyZ2JhKDAsMCwwLDAuNykiIHN0cm9rZS13aWR0aD0iMS4yIi8+PGxpbmUgeDE9IjAiIHkxPSI3NSUiIHgyPSIxMDAlIiB5Mj0iNzUlIiBzdHJva2U9InJnYmEoMCwwLDAsMC43KSIgc3Ryb2tlLXdpZHRoPSIxLjIiLz48bGluZSB4MT0iMCIgeTE9IjEwMCUiIHgyPSIxMDAlIiB5Mj0iMTAwJSIgc3Ryb2tlPSJyZ2JhKDAsMCwwLDAuNykiIHN0cm9rZS13aWR0aD0iMS4yIi8+PC9zdmc+');
  background-size:100% 0.7em; background-repeat:no-repeat;
  font-family:'MusicaD',serif;
  line-height:1; white-space:nowrap;
}
.staff span {
  position: relative;
}
@media (prefers-color-scheme:dark){
  .staff{background-image:url('data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPjxsaW5lIHgxPSIwIiB5MT0iMCIgeDI9IjEwMCUiIHkyPSIwIiBzdHJva2U9InJnYmEoMjU1LDI1NSwyNTUsMC43KSIgc3Ryb2tlLXdpZHRoPSIxLjIiLz48bGluZSB4MT0iMCIgeTE9IjI1JSIgeDI9IjEwMCUiIHkyPSIyNSUiIHN0cm9rZT0icmdiYSgyNTUsMjU1LDI1NSwwLjcpIiBzdHJva2Utd2lkdGg9IjEuMiIvPjxsaW5lIHgxPSIwIiB5MT0iNTAlIiB4Mj0iMTAwJSIgeTI9IjUwJSIgc3Ryb2tlPSJyZ2JhKDI1NSwyNTUsMjU1LDAuNykiIHN0cm9rZS13aWR0aD0iMS4yIi8+PGxpbmUgeDE9IjAiIHkxPSI3NSUiIHgyPSIxMDAlIiB5Mj0iNzUlIiBzdHJva2U9InJnYmEoMjU1LDI1NSwyNTUsMC43KSIgc3Ryb2tlLXdpZHRoPSIxLjIiLz48bGluZSB4MT0iMCIgeTE9IjEwMCUiIHgyPSIxMDAlIiB5Mj0iMTAwJSIgc3Ryb2tlPSJyZ2JhKDI1NSwyNTUsMjU1LDAuNykiIHN0cm9rZS13aWR0aD0iMS4yIi8+PC9zdmc+')}
}

.Gclef { font-size:1.5em; top:-0.20em; }
.D4 { top:-0.38em; }
.E4 { top:-0.45em; }
.F4 { top:-0.52em; }
.G4 { top:-0.59em; }
.A4 { top:-0.66em; }
.B4 { top:-0.73em; }
.C5 { top:-0.80em; }
.D5 { top:-0.87em; }
.E5 { top:-0.94em; }
.F5 { top:-1.01em; }
.stem-down { transform: rotate(180deg) translateY(-0.7em); display:inline-block; }
</style>

<div class="score">
  <div class="staff">
    <!-- Treble clef: font-size:4em, top:-12px -->
    <span class="Gclef" style="left:2px; top:-12px">&#x1D11E;</span>

    <!-- 4/4 time sig: font-size:2em, upper digit top:-0.5em, lower top:0 -->
    <span>4/4</span>

    <!-- D4 half note -->
    <span class="D4">&#x1D15E;</span>

    <!-- E4 quarter note -->
    <span class="E4">&#x1D15F;</span>

    <!-- D5 quarter note; stem DOWN -->
    <span class="D5 stem-down">&#x1D161;</span>

    <!-- Final barline -->
    <span>&#x1D102;</span>
  </div>
</div>
```

---

## Key Rules and Pitfalls

| Issue | Fix |
|-------|-----|
| Notes misalgned when the content around changes | Never ever use any `position: absolute`. No element shall have absolute positioning. |
| Notes misaligned vertically | Always use CSS classes for vertical positioning. Never hardcode per-note values |
| Notes on unexpected positions | Never use absolute positioning with hardcoded `top`/`left`. Always use relative positioning and CSS classes. |

---

## Trigger Phrases

Use this skill when the user asks to:
- "show me [notes / melody / chord / scale] in notation"
- "write out / notate / display sheet music for…"
- "draw a staff with…"
- "render musical notation / sheet music"
- "what does [C major scale / rhythm / chord] look like on a staff"
- "notate this rhythm"
- "show me the treble/bass clef for…"
