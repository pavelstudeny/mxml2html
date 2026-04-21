# MusicXML Phase 3 — Voice / Polyphony and MIDI

**Scope**: Extends Phase 1 with multiple simultaneous voices on a staff, and MIDI/playback metadata.  
**Prerequisite**: Phase 1 (core notation) must be implemented first.

---

## 1. Voice and Polyphony

A *voice* is a melodic strand that has its own stem direction, beaming, and rhythmic independence. Multiple voices share the same staff (and the same `<part>` in timewise MusicXML).

### `<voice>`
```xml
<voice>1</voice>   <!-- string label; conventionally "1"–"4" per staff -->
```

- Voice labels are arbitrary strings, but single digits `"1"`–`"4"` are conventional.
- Voices `"1"` and `"2"` are typically stems-up and stems-down on staff 1.
- Voices `"3"` and `"4"` serve the same role on staff 2 (grand staff).

### `<backup>` and `<forward>`

After writing all notes for one voice, rewind the time pointer to write another voice.

```xml
<backup>
  <duration>16</duration>   <!-- rewind by N divisions (must equal the measure length written so far) -->
</backup>

<forward>
  <duration>4</duration>    <!-- advance time pointer by N divisions (fills gaps) -->
</forward>
```

`<backup>` and `<forward>` have no visual output; they only move the internal time cursor.

### Two-voice example (4/4 with `<divisions>4</divisions>`)

```xml
<part id="P1">
  <attributes>
    <divisions>4</divisions>
    <key><fifths>0</fifths></key>
    <time><beats>4</beats><beat-type>4</beat-type></time>
    <clef><sign>G</sign><line>2</line></clef>
  </attributes>

  <!-- Voice 1: stems up -->
  <note>
    <pitch><step>E</step><octave>5</octave></pitch>
    <duration>8</duration><voice>1</voice><type>half</type><stem>up</stem>
  </note>
  <note>
    <pitch><step>D</step><octave>5</octave></pitch>
    <duration>8</duration><voice>1</voice><type>half</type><stem>up</stem>
  </note>

  <!-- Rewind to the start of the measure -->
  <backup><duration>16</duration></backup>

  <!-- Voice 2: stems down -->
  <note>
    <pitch><step>C</step><octave>4</octave></pitch>
    <duration>4</duration><voice>2</voice><type>quarter</type><stem>down</stem>
  </note>
  <note>
    <pitch><step>B</step><octave>3</octave></pitch>
    <duration>4</duration><voice>2</voice><type>quarter</type><stem>down</stem>
  </note>
  <note>
    <pitch><step>A</step><octave>3</octave></pitch>
    <duration>8</duration><voice>2</voice><type>half</type><stem>down</stem>
  </note>
</part>
```

### Grand-staff polyphony

For two-staff parts (piano), combine `<staff>` with `<voice>`:

```xml
<!-- Voice 1 on staff 1 -->
<note>
  <pitch><step>G</step><octave>4</octave></pitch>
  <duration>4</duration><voice>1</voice><type>quarter</type>
  <staff>1</staff><stem>up</stem>
</note>

<backup><duration>4</duration></backup>

<!-- Voice 2 on staff 2 -->
<note>
  <pitch><step>C</step><octave>3</octave></pitch>
  <duration>4</duration><voice>3</voice><type>quarter</type>
  <staff>2</staff><stem>down</stem>
</note>
```

### Cross-staff beaming

A note physically drawn on staff 2 but beamed with notes on staff 1:

```xml
<note>
  <pitch><step>C</step><octave>4</octave></pitch>
  <duration>2</duration><voice>1</voice><type>eighth</type>
  <staff>2</staff>         <!-- displayed on staff 2 -->
  <beam number="1">continue</beam>
</note>
```

### Chord within a voice

`<chord/>` makes a note simultaneous with the previous one in the **same voice**:

```xml
<note>
  <pitch><step>C</step><octave>4</octave></pitch>
  <duration>4</duration><voice>1</voice><type>quarter</type>
</note>
<note>
  <chord/>
  <pitch><step>E</step><octave>4</octave></pitch>
  <duration>4</duration><voice>1</voice><type>quarter</type>
</note>
<note>
  <chord/>
  <pitch><step>G</step><octave>4</octave></pitch>
  <duration>4</duration><voice>1</voice><type>quarter</type>
</note>
```

---

## 2. MIDI / Playback Metadata

MIDI data controls how a score is rendered for playback. It does not affect visual notation.

### Part-level MIDI setup (in `<score-part>`)

```xml
<score-part id="P1">
  <part-name>Violin</part-name>
  <score-instrument id="P1-I1">
    <instrument-name>Violin</instrument-name>
    [<instrument-sound>strings.violin</instrument-sound>]  <!-- SMuFL sound ID -->
    [<virtual-instrument>
      <virtual-library>General MIDI</virtual-library>
      <virtual-name>Violin</virtual-name>
    </virtual-instrument>]
  </score-instrument>
  <midi-device id="P1-I1" port="1"/>
  <midi-instrument id="P1-I1">
    <midi-channel>1</midi-channel>          <!-- 1–16 -->
    <midi-program>41</midi-program>         <!-- 1–128; General MIDI program number -->
    [<midi-unpitched>60</midi-unpitched>]   <!-- for unpitched percussion; MIDI note -->
    [<volume>80</volume>]                   <!-- 0–100 -->
    [<pan>0</pan>]                          <!-- -90 (left) to 90 (right) -->
    [<elevation>0</elevation>]
  </midi-instrument>
</score-part>
```

`<midi-instrument id>` must match `<score-instrument id>`.

### `<sound>` direction (tempo and playback control)

`<sound>` is a child of `<direction>`, placed after `<direction-type>`. It carries playback-only information.

```xml
<direction>
  <direction-type>
    <words font-style="italic">Allegro</words>
  </direction-type>
  <sound tempo="132"/>   <!-- quarter notes per minute -->
</direction>

<direction>
  <direction-type><dynamics><ff/></dynamics></direction-type>
  <sound dynamics="90"/>   <!-- 0–100 MIDI velocity equivalent -->
</direction>
```

**Common `<sound>` attributes**:
| Attribute | Description |
|-----------|-------------|
| `tempo` | Quarter notes per minute (overrides any metronome marking for playback) |
| `dynamics` | Playback volume 0–100 |
| `dacapo` | `"yes"` = jump to beginning |
| `segno` | Token ID of the segno to jump to |
| `dalsegno` | `"yes"` = jump to matching `<segno>` |
| `coda` | Token ID of the coda to jump to |
| `tocoda` | `"yes"` = jump to matching `<coda>` |
| `fine` | `"yes"` = end here |
| `forward-repeat` | `"yes"` = begin forward repeat for playback |
| `pizzicato` | `"yes"` / `"no"` = pizzicato playback on/off |

### Note-level playback attributes

These are attributes on `<note>` itself (not child elements):

```xml
<note dynamics="71"           <!-- playback MIDI velocity 0–100 -->
      end-dynamics="60"       <!-- velocity at note release -->
      attack="-10"            <!-- timing offset on attack, in divisions -->
      release="5"             <!-- timing offset on release, in divisions -->
      pizzicato="yes">
  …
</note>
```

### `<instrument>` on a note

For parts with multiple `<score-instrument>` elements (e.g. percussion kit), each note selects its instrument:

```xml
<note>
  <pitch>…</pitch>
  <duration>4</duration>
  <instrument id="P1-I2"/>   <!-- references a score-instrument id -->
  <type>quarter</type>
</note>
```

---

## 3. Key Constraints and Gotchas

- **`<backup>` duration** must exactly equal the number of divisions written for the completed voice, or time-cursor errors accumulate across measures.
- **`<voice>` labels** are strings, not integers. `"1"` ≠ `1` as an XML token, but convention uses digit strings.
- **Stem direction** is not enforced by the schema but is conventionally: voice 1 = up, voice 2 = down.
- **`<chord/>` and `<backup>`**: `<chord/>` groups notes within the same time point in the same voice. `<backup>` rewinds to start a separate voice. Do not mix them to achieve polyphony — use `<backup>` for that.
- **`<sound>` is playback-only**: it has no visual effect. Dynamic markings that should be visible must use `<dynamics>` inside `<direction-type>`.
- **`<midi-channel>` 10** is the General MIDI percussion channel. Notes on channel 10 map `<midi-unpitched>` to drum sounds regardless of pitch.
- **`<midi-program>` is 1-based** in MusicXML (1–128), but MIDI protocol is 0-based (0–127). Subtract 1 when sending raw MIDI messages.
- **`tempo` in `<sound>`** is always in quarter notes per minute, even if the time signature uses a different beat unit.
