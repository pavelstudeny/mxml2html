---
name: transform-musicxml-to-html
description: Notes on MusicXML structure and how to use XSLT to transform it to HTML
---

# XSLT Development Resources

Reference material consulted when building and extending `src/xslt/timewise.xslt`.

---

## 1. MusicXML Specification

### Timewise DTD (v4.0)
- **Entrypoint**: `https://raw.githubusercontent.com/w3c-cg/musicxml/v4.0/schema/timewise.dtd`
- **Component modules** (all at same base URL):

| Module | Contents |
|--------|----------|
| `schema/common.mod` | Shared entities: data types (`tenths`, `yes-no`), positioning attrs (`default-x/y`, `relative-x/y`), font, color, `start-stop*`, `number-level`, `beam-level` |
| `schema/layout.mod` | Page, system, staff, measure layout/formatting |
| `schema/identity.mod` | `<identification>`, `<encoding>`, `<creator>`, `<rights>` |
| `schema/attributes.mod` | `<divisions>`, `<key>`, `<time>`, `<clef>`, `<staves>`, `<transpose>`, `<staff-details>` |
| `schema/note.mod` | `<note>`, `<pitch>`, `<rest>`, `<duration>`, `<tie>`, `<beam>`, `<notations>`, `<lyric>`, all articulations/ornaments/technical |
| `schema/barline.mod` | `<barline>`, `<bar-style>`, `<repeat>`, `<ending>` |
| `schema/direction.mod` | `<direction>`, `<direction-type>`, dynamics, words, metronome, wedge, pedal, octave-shift, harmony |
| `schema/score.mod` | `<score-timewise>`, `<score-partwise>`, `<part-list>`, `<score-part>`, `<measure>`, `<part>` |

> **Note**: The DTD format is deprecated as of MusicXML 4.0 in favour of `musicxml.xsd`, but the DTD modules remain the most concise structural reference.

### W3C MusicXML 4.0 Element Reference
Base URL: `https://www.w3.org/2021/06/musicxml40/musicxml-reference/elements/`

Pages consulted during XSLT development:

| Element | URL suffix | Key facts extracted |
|---------|-----------|---------------------|
| `<score-timewise>` | `score-timewise/` | Root element; header + `<measure>+`; `@version` |
| `<measure>` (timewise) | `measure-timewise/` | `@number` (token), `@implicit`, `@width`; contains `<part>+` |
| `<attributes>` | `attributes/` | `<divisions>`, `<key>`, `<time>`, `<clef>`, `<staves>`, `<transpose>` |
| `<key>` | `key/` | `<fifths>` (−7..7), `<mode>`, traditional vs. non-traditional forms |
| `<time>` | `time/` | `<beats>`/`<beat-type>` pairs; `@symbol` (common, cut…); `<senza-misura>` |
| `<clef>` | `clef/` | `<sign>` (G/F/C/percussion/TAB), `<line>`, `<clef-octave-change>` |
| `<note>` | `note/` | Four structural paths (grace/cue/tied/standard); full child order |
| `<pitch>` | `pitch/` | `<step>` (A–G), `<octave>` (0–9, middle C = C4), `<alter>` |
| `<notations>` | `notations/` | `<tied>`, `<slur>`, `<tuplet>`, `<fermata>`, `<articulations>`, `<ornaments>`, `<technical>`, `<dynamics>` |
| `<direction>` | `direction/` | `<direction-type>`, `<offset>`, `<staff>`, `<sound>`; not tied to a note |

---

## 2. Internal Project Documents

### MusicXML Subset Definitions
Located in `../../../doc/musicxml/`:

| File | Scope |
|------|-------|
| `../../../phase-1-core-notation.md` | **Primary XSLT source**: document structure, attributes, notes/rests, notations (incl. guitar bends), directions, barlines, grace notes, multi-staff |
| `../../../phase-2-lyrics-tabs.md` | Phase 2: `<lyric>`, TAB clef, `<staff-details>`, `<string>`/`<fret>` |
| `../../../phase-3-voice-midi.md` | Phase 3: `<voice>`, `<backup>`/`<forward>`, MIDI metadata |

### CSS Class Reference
`../../../src/css/musicxml.css` — defines all class names the XSLT must emit.

| CSS class pattern | XSLT usage |
|-------------------|-----------|
| `.clef-G`, `.clef-F`, `.clef-C` | Output by `<xsl:template match="clef">` |
| `.time-sig` | Output by `<xsl:template match="time">` |
| `.pitch-{Step}{Octave}` e.g. `.pitch-D4` | Built with `concat('pitch-', step, octave)` |
| `.stem-down` | Added when `number(pitch/octave) >= 5` |
| `.rest-whole` … `.rest-64th` | Output by named template `rest-glyph` |
| `.barline` | Output by `<xsl:template match="barline">` and auto-generated barlines |
| `.staff` | Wrapping `<div>` per `<score-part>` |
| `.score` | Wrapping `<div>` at document level |

---

## 3. Rendering Model (display-music-notation-html skill)

Source: Claude Code skill at `.claude/skills/display-music-notation-html/`

### Font
- **MusicaD** (BravuraText / SMuFL) at `fonts/MusicaD.ttf`
- All music symbols are Unicode characters rendered with this font
- Staff lines are a base64-encoded inline SVG `background-image`

### SMuFL Unicode Codepoints Used in XSLT

**Clefs**
| Glyph | Codepoint |
|-------|-----------|
| Treble (G) clef | `U+1D11E` |
| Bass (F) clef | `U+1D122` |
| Alto (C) clef | `U+1D121` |

**Notes** (precomposed stem + notehead; stem-up orientation)
| Type | Codepoint |
|------|-----------|
| Whole | `U+1D15D` |
| Half | `U+1D15E` |
| Quarter | `U+1D15F` |
| Eighth | `U+1D160` |
| 16th | `U+1D161` |
| 32nd | `U+1D162` |
| 64th | `U+1D163` |
| 128th | `U+1D164` |

**Rests**
| Type | Codepoint |
|------|-----------|
| Whole | `U+1D13B` |
| Half | `U+1D13C` |
| Quarter | `U+1D13D` |
| Eighth | `U+1D13E` |
| 16th | `U+1D13F` |
| 32nd | `U+1D140` |
| 64th | `U+1D141` |

**Barlines**
| Style | Codepoint |
|-------|-----------|
| Regular | `U+1D100` |
| Double | `U+1D101` |
| Final | `U+1D102` |
| Repeat right (backward) | `U+1D104` |
| Repeat left (forward) | `U+1D105` |

### Layout Rules Relevant to XSLT Output
- **Never use `position: absolute`** — all spans use `position: relative`
- Vertical pitch position is set entirely by the CSS class; the XSLT must not emit inline `top` styles
- **Stem direction**: `octave >= 5` (concert pitch) → add class `stem-down`; the `stem-down` CSS rule rotates the precomposed glyph 180° and translates up by `0.7em`
- **Time signatures**: must use `font-family: sans-serif` (set in `.time-sig` CSS); rendered as `<sup>beats</sup>/<sub>beat-type</sub>`

### Validated Reference HTML
`notation.html` at project root — hand-authored example that confirmed font loading, staff background SVG, and glyph positioning before XSLT was written.

---

## 4. XSLT Implementation Notes

### Version and Compatibility
Per [Google announcement](https://developer.chrome.com/docs/web-platform/deprecating-xslt), XSLTProcessor is being deprecated. This is already visible in Chrome for Testing.
[xslt-processor](https://github.com/DesignLiquido/xslt-processor) works just fine and it's a good replacement.
[SaxonJS](https://www.saxonica.com/) might be even better but their documentation is terrible.

`xsltproc` is a command line tool that can be used for utility purposes.


### Key Structural Decisions

| Decision | Rationale |
|----------|-----------|
| One `.staff` div per `score-part` | Timewise iteration: `for-each score-part → for-each measure/part[@id]` collects all measures in a single horizontal flow |
| Pitch class built with `concat()` | Avoids 70+ `xsl:when` branches; requires CSS class names to follow the `pitch-{Step}{Octave}` pattern exactly |
| Stem direction by octave only | All notes octave ≤ 4 → stem up; ≥ 5 → stem down. Correct for treble clef C4–B4 range without per-note logic |
| Explicit barline overrides auto barline | `<barline location="right">` takes precedence; regular/final barlines generated automatically based on `position() = last()` |
| `<sound>` and `<midi-instrument>` silently ignored | Phase 1 scope; no output generated for playback-only elements |
