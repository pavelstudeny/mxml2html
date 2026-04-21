# MusicXML Phase 2 — Lyrics and Tablature

**Scope**: Extends Phase 1 with vocal text (lyrics) and guitar/bass tablature (TAB).  
**Prerequisite**: Phase 1 (core notation) must be implemented first.

---

## 1. Lyrics

Lyrics are children of `<note>` and appear after `<notations>` in document order.

```xml
<note>
  <pitch>…</pitch>
  <duration>4</duration>
  <type>quarter</type>
  <lyric number="1" name="verse">
    <syllabic>begin</syllabic>   <!-- single | begin | middle | end -->
    <text>hel</text>
    [<elision/>]                 <!-- space between syllables from different words -->
    [<extend type="start"/>]     <!-- melisma extender line; type: start | stop | continue -->
  </lyric>
  <lyric number="2" name="chorus">  <!-- multiple verses use different @number -->
    <syllabic>single</syllabic>
    <text>Yes!</text>
  </lyric>
</note>
```

### Syllabic values
| Value | Meaning |
|-------|---------|
| `single` | Complete word on one note |
| `begin` | First syllable of a multi-syllable word |
| `middle` | Interior syllable |
| `end` | Last syllable |

Hyphens between syllables are implied by `begin`/`middle`; do not add them to `<text>`.

### Melisma (one syllable over multiple notes)
Only the first note has `<lyric>` with `<extend type="start"/>`. Subsequent notes carry no `<lyric>`. The last note of the melisma may have `<extend type="stop"/>`.

### Special content
```xml
<lyric number="1">
  <laughing/>    <!-- notated laughing; no text content -->
</lyric>
<lyric number="1">
  <humming/>     <!-- notated humming -->
</lyric>
```

### Lyric font
Declared in `<defaults>` in the header:
```xml
<defaults>
  <lyric-font font-family="Times New Roman" font-size="10.25"/>
</defaults>
```

---

## 2. Tablature (TAB)

TAB is a staff notation for fretted string instruments. It co-exists with standard notation (grand staff + TAB on separate staves of the same part) or appears standalone.

### TAB Clef and Staff Setup

```xml
<attributes>
  <divisions>4</divisions>
  <staves>2</staves>

  <!-- Standard notation staff -->
  <clef number="1">
    <sign>G</sign><line>2</line>
    <clef-octave-change>-1</clef-octave-change>   <!-- guitar sounds 8vb -->
  </clef>

  <!-- TAB staff -->
  <clef number="2">
    <sign>TAB</sign>
  </clef>

  <!-- String tuning for TAB staff -->
  <staff-details number="2">
    <staff-type>tab</staff-type>
    <staff-lines>6</staff-lines>
    <staff-tuning line="1">    <!-- line 1 = lowest string -->
      <tuning-step>E</tuning-step>
      <tuning-octave>2</tuning-octave>
    </staff-tuning>
    <staff-tuning line="2">
      <tuning-step>A</tuning-step>
      <tuning-octave>2</tuning-octave>
    </staff-tuning>
    <staff-tuning line="3">
      <tuning-step>D</tuning-step>
      <tuning-octave>3</tuning-octave>
    </staff-tuning>
    <staff-tuning line="4">
      <tuning-step>G</tuning-step>
      <tuning-octave>3</tuning-octave>
    </staff-tuning>
    <staff-tuning line="5">
      <tuning-step>B</tuning-step>
      <tuning-octave>3</tuning-octave>
    </staff-tuning>
    <staff-tuning line="6">
      <tuning-step>E</tuning-step>
      <tuning-octave>4</tuning-octave>
    </staff-tuning>
    <capo>0</capo>             <!-- capo fret number; 0 or omit = no capo -->
  </staff-details>
</attributes>
```

### TAB Note

A TAB note has pitch (for sound/standard staff) plus `<technical>` children for the TAB display.

```xml
<note>
  <pitch>
    <step>E</step>
    <octave>3</octave>
  </pitch>
  <duration>4</duration>
  <type>quarter</type>
  <staff>2</staff>          <!-- routes note to TAB staff -->
  <notations>
    <technical>
      <string>3</string>    <!-- string number; 1 = highest-pitched string -->
      <fret>2</fret>        <!-- fret number; 0 = open string -->
    </technical>
  </notations>
</note>
```

**String numbering** in MusicXML: string 1 = highest-pitched (thinnest). Opposite of `<staff-tuning line>` which counts from the lowest.

### TAB-only staff (no standard notation)
```xml
<attributes>
  <staves>1</staves>
  <clef><sign>TAB</sign></clef>
  <staff-details>
    <staff-type>tab</staff-type>
    <staff-lines>6</staff-lines>
    <!-- staff-tuning elements … -->
  </staff-details>
</attributes>
```

### Guitar-specific technical notations (TAB context)

These appear inside `<technical>` inside `<notations>` on the note. See Phase 1 for `<hammer-on>`, `<pull-off>`, and `<bend>`.

```xml
<technical>
  <string>2</string>
  <fret>5</fret>

  <!-- Vibrato bar / whammy -->
  <bend>
    <bend-alter>-1</bend-alter>     <!-- negative = dip down -->
    <with-bar>w/ bar</with-bar>
  </bend>

  <!-- Slide between frets (visual line in TAB) -->
  <!-- Use <slide> or <glissando> in <notations> (not inside <technical>): -->
</technical>
<glissando type="start" line-type="solid"/>   <!-- sibling of <technical> inside <notations> -->
```

### TAB with rhythm stems
By default a TAB staff shows only fret numbers. Adding `<stem>` and `<beam>` to the note causes rhythm stems to appear above the TAB staff.

```xml
<note>
  <pitch>…</pitch>
  <duration>2</duration>
  <type>eighth</type>
  <staff>2</staff>
  <stem>up</stem>
  <beam number="1">begin</beam>
  <notations><technical><string>1</string><fret>0</fret></technical></notations>
</note>
```

---

## 3. Dual Staff Example (Standard + TAB)

```xml
<score-timewise version="4.0">
  <part-list>
    <score-part id="P1"><part-name>Guitar</part-name></score-part>
  </part-list>
  <measure number="1">
    <part id="P1">
      <attributes>
        <divisions>4</divisions>
        <key><fifths>0</fifths></key>
        <time><beats>4</beats><beat-type>4</beat-type></time>
        <staves>2</staves>
        <clef number="1">
          <sign>G</sign><line>2</line>
          <clef-octave-change>-1</clef-octave-change>
        </clef>
        <clef number="2"><sign>TAB</sign></clef>
        <staff-details number="2">
          <staff-type>tab</staff-type>
          <staff-lines>6</staff-lines>
          <!-- tuning omitted for brevity -->
        </staff-details>
      </attributes>

      <!-- Standard notation note (staff 1) -->
      <note>
        <pitch><step>E</step><octave>3</octave></pitch>
        <duration>4</duration><type>quarter</type>
        <staff>1</staff>
      </note>

      <!-- TAB note (staff 2) — same pitch, different staff -->
      <note>
        <chord/>
        <pitch><step>E</step><octave>3</octave></pitch>
        <duration>4</duration><type>quarter</type>
        <staff>2</staff>
        <notations>
          <technical><string>4</string><fret>2</fret></technical>
        </notations>
      </note>

      <note><rest/><duration>12</duration><type>half</type><dot/><staff>1</staff></note>
      <note><rest/><duration>12</duration><type>half</type><dot/><staff>2</staff></note>
    </part>
  </measure>
</score-timewise>
```

---

## 4. Key Constraints and Gotchas

- **String `@number` direction**: MusicXML string 1 = highest pitch (treble string); `<staff-tuning line>` 1 = lowest. They count in opposite directions.
- **Dual-staff notes**: Standard and TAB staff notes at the same time point share a pitch but differ in `<staff>`. Use `<chord/>` on the TAB note to align them.
- **`<fret>0`** = open string.
- **`<staff-details>`** must appear in the same `<attributes>` block as the TAB `<clef>`, or in a later `<attributes>` before the first TAB note.
- **Lyrics and TAB**: Lyrics belong to standard-staff notes (`<staff>1</staff>`), not TAB-staff notes.
- **Syllabic hyphens** are implied; do not include `-` in `<text>` content.
- **Multiple verse numbers**: `<lyric number="1">` and `<lyric number="2">` stack vertically below the staff.
