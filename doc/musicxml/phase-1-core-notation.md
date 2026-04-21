# MusicXML Phase 1 — Core Notation

**Scope**: `score-timewise` format; standard pitched notation (17th century onwards).  
**Includes**: document structure, attributes, notes/rests, notations, directions, barlines, metadata, multi-staff parts, grace notes, guitar bends/hammer-ons.  
**Excluded**: voice/polyphony (Phase 3), lyrics (Phase 2), TAB (Phase 2), MIDI (Phase 3).

---

## 1. Document Structure

```
score-timewise
  [work]
  [movement-number]
  [movement-title]
  [identification]
  [defaults]
  [credit]*
  part-list
    score-part+
      part-name
      [part-abbreviation]
      [score-instrument]*
  measure+ (@number)
    part+ (@id → score-part/@id)
      [attributes]
      [direction]*
      [note | barline]*
```

### `<score-timewise>`
Root element. Attribute `version="4.0"` should be set by writing programs.

### `<part-list>` / `<score-part>`
Declares instruments. Each `<score-part id="P1">` must have a matching `<part id="P1">` in every `<measure>`.

### `<measure>` (timewise)
- `@number` — sequential measure identifier (required, string/token; can be non-numeric, e.g. `"X1"` for pickup)
- `@implicit="yes"` — pickup measure; suppresses display of measure number
- `@width` — rendering hint in tenths (optional)

### `<part>` (inside `<measure>`)
- `@id` — references a `<score-part>`
- Contains the musical events for that instrument in that measure

---

## 2. Attributes Element

Placed at the start of a measure (or wherever something changes). Applies from that point forward.

```xml
<attributes>
  <divisions>4</divisions>        <!-- ticks per quarter note -->
  <key>
    <fifths>-1</fifths>           <!-- -7..7; negative=flats, positive=sharps -->
    <mode>minor</mode>            <!-- major | minor | dorian | phrygian | lydian
                                       | mixolydian | aeolian | ionian | locrian | none -->
  </key>
  <time symbol="common">         <!-- common | cut | single-number | note | dotted-note | normal -->
    <beats>4</beats>
    <beat-type>4</beat-type>
  </time>
  <staves>2</staves>             <!-- number of staves in this part (default 1) -->
  <clef number="1">              <!-- @number targets specific staff -->
    <sign>G</sign>               <!-- G | F | C | percussion -->
    <line>2</line>               <!-- staff line (G→2, F→4, C→3 for alto) -->
    <clef-octave-change>-1</clef-octave-change>  <!-- 8vb: -1; 8va: +1 -->
  </clef>
  <transpose>                    <!-- for transposing instruments -->
    <diatonic>-1</diatonic>
    <chromatic>-2</chromatic>
    [<octave-change/>]
  </transpose>
</attributes>
```

**`<divisions>`** — integer; sets the time unit. Duration `4` with `<divisions>4</divisions>` = one quarter note. Must appear in the first measure of each part. Per-part, not global.

**Key**: `<fifths>0</fifths>` = C major / A minor.

**Time**: Multiple `<beats>`/`<beat-type>` pairs = composite meter (e.g. 2/4 + 3/8). `<senza-misura/>` = unmeasured.

**Common clefs**:
| Sign | Line | clef-octave-change | Name |
|------|------|--------------------|------|
| G | 2 | — | Treble |
| F | 4 | — | Bass |
| C | 3 | — | Alto |
| C | 4 | — | Tenor |
| G | 2 | -1 | Treble 8vb |
| percussion | — | — | Unpitched percussion |

---

## 3. Notes and Rests

### `<note>` children (in order)

```
[grace] | [cue]
[chord]               ← present if note is simultaneous with previous note
pitch | rest | unpitched
[duration]            ← required except for grace notes; in divisions
[tie @type]*          ← start | stop (sound; up to 2 per note)
[instrument]
[type]                ← note type name (see table below)
[dot]*                ← one per augmentation dot
[accidental]
[time-modification]   ← for tuplets
[stem]                ← up | down | none | double
[notehead]
[staff]               ← which staff (1 or 2) for multi-staff parts
[beam @number]*       ← level 1–8; value: begin | continue | end | forward hook | backward hook
[notations]*
```

### `<pitch>`
```xml
<pitch>
  <step>C</step>      <!-- A B C D E F G -->
  <octave>4</octave>  <!-- 0–9; middle C = C4 (= MIDI 60) -->
  <alter>-1</alter>   <!-- semitones; -1=flat, 1=sharp, 0.5=quarter-sharp, etc. -->
</pitch>
```

### `<rest>`
```xml
<rest/>                        <!-- ordinary rest -->
<rest measure="yes"/>          <!-- whole-measure rest -->
```

### `<duration>`
Integer in divisions. Examples with `<divisions>4</divisions>`:
| Note value | Duration |
|------------|----------|
| Whole | 16 |
| Half | 8 |
| Quarter | 4 |
| Eighth | 2 |
| 16th | 1 |

### `<type>` values
`1024th` `512th` `256th` `128th` `64th` `32nd` `16th` `eighth` `quarter` `half` `whole` `breve` `long` `maxima`

### `<accidental>`
```xml
<accidental>sharp</accidental>
<!-- Values: sharp | natural | flat | double-sharp | sharp-sharp | flat-flat
             natural-sharp | natural-flat | quarter-flat | quarter-sharp
             three-quarters-flat | three-quarters-sharp -->
```
`<accidental>` controls **display** only; `<alter>` controls **sound pitch**.

### `<dot>`
Each `<dot/>` element adds one augmentation dot.

### `<stem>`
`<stem>up</stem>` | `<stem>down</stem>` | `<stem>none</stem>`

### `<beam @number="1">`
Level `@number` 1–8 (8 = 1024th note). Values: `begin` | `continue` | `end` | `forward hook` | `backward hook`.  
Beams must be specified explicitly; they do not auto-generate from duration.

### `<chord>`
Empty element. When present, the note is played simultaneously with the immediately preceding note. Does not appear on rests.

### `<tie @type>`
`<tie type="start"/>` / `<tie type="stop"/>` — controls sound (whether notes are held across a barline).  
Use `<tied>` inside `<notations>` for the visual slur mark.

### Grace Notes
```xml
<note>
  <grace slash="yes"/>      <!-- slash="yes" = acciaccatura; "no"/absent = appoggiatura -->
  <pitch><step>D</step><octave>5</octave></pitch>
  <!-- no <duration> on grace notes -->
  <type>eighth</type>
  <notations><slur type="start" number="1"/></notations>
</note>
```

### Multi-Staff Notes
```xml
<note>
  <pitch>…</pitch>
  <duration>4</duration>
  <staff>2</staff>         <!-- 1 or 2; which staff this note belongs to -->
  <type>quarter</type>
</note>
```

---

## 4. Notations

Attached to a specific `<note>`. Multiple `<notations>` elements are allowed (different editorial levels).

```xml
<notations>
  <tied type="start"/>              <!-- start | stop | continue | let-ring -->
  <slur type="start" number="1"/>   <!-- start | stop | continue; @number for concurrent slurs -->
  <tuplet type="start" number="1" bracket="yes"/>
  <fermata/>                        <!-- @type: normal | angled | square; @placement: above | below -->

  <articulations>
    <accent/>
    <strong-accent/>                <!-- marcato ^ -->
    <staccato/>
    <tenuto/>
    <detached-legato/>
    <staccatissimo/>
    <spiccato/>
    <stress/>
    <unstress/>
    <soft-accent/>
  </articulations>

  <ornaments>
    <trill-mark/>
    <turn/>                         <!-- also: inverted-turn | delayed-turn | delayed-inverted-turn -->
    <mordent/>                      <!-- also: inverted-mordent -->
    <shake/>
    <wavy-line type="start" number="1"/>   <!-- start | stop | continue -->
    <tremolo type="single">2</tremolo>     <!-- single | start | stop | unmeasured; content = beams -->
  </ornaments>

  <technical>
    <!-- General -->
    <fingering>2</fingering>
    <harmonic/>
    <open-string/>
    <snap-pizzicato/>
    <up-bow/>
    <down-bow/>
    <heel/>
    <toe/>
    <!-- Guitar / fretted instrument -->
    <hammer-on type="start" number="1">H</hammer-on>   <!-- start | stop -->
    <pull-off type="start" number="1">P</pull-off>     <!-- start | stop -->
    <bend>
      <bend-alter>1</bend-alter>         <!-- semitones; 1 = full step up -->
      [<pre-bend/>]                      <!-- bend starts before the note -->
      [<release/>]                       <!-- note released after bend -->
      [<with-bar/>]                      <!-- whammy bar bend -->
    </bend>
    <tap/>
    <slide type="start" number="1"/>     <!-- start | stop; legato slide -->
  </technical>

  <dynamics><p/></dynamics>          <!-- note-level dynamics (rare; prefer <direction>) -->
  <arpeggiate direction="up"/>       <!-- up | down; absent = no arrow -->
  <non-arpeggiate type="top"/>       <!-- top | bottom; bracket mark -->
  <glissando type="start" line-type="solid"/>
</notations>
```

### Tuplets
`<time-modification>` carries the ratio; `<tuplet>` in `<notations>` controls the bracket display.
```xml
<time-modification>
  <actual-notes>3</actual-notes>
  <normal-notes>2</normal-notes>
  [<normal-type>eighth</normal-type>]
</time-modification>
```

---

## 5. Directions

Not tied to a specific note. Placed in the `<part>` before or after notes at the measure level.

```xml
<direction placement="above">
  <direction-type>
    <!-- One of: -->
    <dynamics><ff/></dynamics>
    <words font-style="italic">Allegro moderato</words>
    <metronome parentheses="no">
      <beat-unit>quarter</beat-unit>
      <per-minute>120</per-minute>
    </metronome>
    <wedge type="crescendo" number="1"/>     <!-- crescendo | diminuendo | stop | continue -->
    <pedal type="start" line="yes"/>         <!-- start | stop | sostenuto | change -->
    <octave-shift type="down" number="1" size="8"/>  <!-- down | up | stop; size: 8 | 15 -->
    <rehearsal enclosure="box">A</rehearsal>
    <segno/>
    <coda/>
    <dashes type="start" number="1"/>
    <bracket type="start" number="1" line-end="arrow"/>
    <string-mute type="on"/>                 <!-- on | off -->
  </direction-type>
  [<offset>8</offset>]      <!-- displacement in divisions (positive = later) -->
  [<staff>1</staff>]        <!-- if part has multiple staves -->
</direction>
```

**`<dynamics>` values**: `p` `pp` `ppp` `pppp` `f` `ff` `fff` `ffff` `mp` `mf` `sf` `sfz` `sffz` `fz` `rf` `rfz` `fp` `pf` `other-dynamics`

---

## 6. Barlines

```xml
<barline location="right">        <!-- left | middle | right -->
  <bar-style>light-heavy</bar-style>
  <!-- bar-style values:
       regular | dotted | dashed | heavy | light-light | light-heavy
       heavy-light | heavy-heavy | tick | short | none -->
  <repeat direction="forward"/>              <!-- forward | backward; @times for repeat count -->
  <ending number="1" type="start"/>          <!-- volta bracket; type: start | stop | discontinue -->
  <fermata/>
</barline>
```

A measure without `<barline>` gets a regular barline at the right edge.

---

## 7. Multi-Staff Parts (Piano, Organ, Harp)

```xml
<attributes>
  <staves>2</staves>
  <clef number="1"><sign>G</sign><line>2</line></clef>
  <clef number="2"><sign>F</sign><line>4</line></clef>
</attributes>

<!-- Each note specifies which staff it belongs to -->
<note>
  <pitch><step>A</step><octave>3</octave></pitch>
  <duration>4</duration>
  <staff>2</staff>
  <type>quarter</type>
</note>
```

---

## 8. Metadata / Header

```xml
<work>
  <work-number>Op. 10</work-number>
  <work-title>Sonata</work-title>
</work>
<movement-number>1</movement-number>
<movement-title>Allegro</movement-title>
<identification>
  <creator type="composer">Johann Sebastian Bach</creator>
  <rights>Public Domain</rights>
  <encoding>
    <software>MyApp 1.0</software>
    <encoding-date>2026-04-20</encoding-date>
  </encoding>
</identification>
<defaults>
  <scaling>
    <millimeters>7.2319</millimeters>
    <tenths>40</tenths>          <!-- 40 tenths = one interline space -->
  </scaling>
</defaults>
<credit page="1">
  <credit-words justify="center" valign="top" font-size="24">Sonata</credit-words>
</credit>
```

---

## 9. Minimal Valid Example

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE score-timewise PUBLIC
  "-//Recordare//DTD MusicXML 4.0 Timewise//EN"
  "http://www.musicxml.org/dtds/timewise.dtd">
<score-timewise version="4.0">
  <part-list>
    <score-part id="P1">
      <part-name>Guitar</part-name>
    </score-part>
  </part-list>
  <measure number="1">
    <part id="P1">
      <attributes>
        <divisions>4</divisions>
        <key><fifths>0</fifths><mode>major</mode></key>
        <time><beats>4</beats><beat-type>4</beat-type></time>
        <clef><sign>G</sign><line>2</line></clef>
      </attributes>
      <note>
        <pitch><step>C</step><octave>4</octave></pitch>
        <duration>4</duration>
        <type>quarter</type>
      </note>
      <note>
        <pitch><step>D</step><octave>4</octave></pitch>
        <duration>4</duration>
        <type>quarter</type>
        <notations>
          <technical>
            <hammer-on type="start" number="1">H</hammer-on>
          </technical>
        </notations>
      </note>
      <note>
        <pitch><step>E</step><octave>4</octave></pitch>
        <duration>4</duration>
        <type>quarter</type>
        <notations>
          <technical>
            <hammer-on type="stop" number="1"/>
          </technical>
        </notations>
      </note>
      <note><rest/><duration>4</duration><type>quarter</type></note>
    </part>
  </measure>
</score-timewise>
```

---

## 10. Key Constraints and Gotchas

- **`<divisions>` is per-part**, not global. Each part can use different values.
- **`<duration>` tracks time** cumulatively within a measure.
- **`<chord>`** makes a note simultaneous with the previous one; never on rests.
- **`<tie>` vs `<tied>`**: `<tie>` (child of `<note>`) = sound; `<tied>` (inside `<notations>`) = display.
- **`<alter>` vs `<accidental>`**: `<alter>` changes the pitch; `<accidental>` controls whether a sign is shown.
- **Octave numbering**: Middle C = C4. `<octave>` follows ISO standard (C4 = MIDI 60).
- **Beam groups** must be specified explicitly; they do not auto-generate from duration.
- **`@number`** on `<slur>`, `<wedge>`, `<hammer-on>`, etc. allows concurrent overlapping spans.
- **Measure `@number`** is always a token, not an integer (e.g. `"X1"` for a pickup).
- **`<bend>`** is inside `<technical>` inside `<notations>`, attached to the source note of the bend.
