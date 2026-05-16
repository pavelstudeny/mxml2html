<?xml version="1.0" encoding="UTF-8"?>
<!--
  timewise.xslt — MusicXML score-timewise → HTML
  Phase 1 scope: clefs, time signatures, pitched notes (C4–E6), rests, barlines.
  Requires: src/css/musicxml.css, fonts/MusicaD.ttf
-->
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="html" encoding="UTF-8" indent="yes"/>

  <!-- ============================================================
       Root: HTML shell
       ============================================================ -->
  <xsl:template match="/score-timewise">
    <html lang="en">
      <head>
        <meta charset="UTF-8"/>
        <title>
          <xsl:choose>
            <xsl:when test="movement-title">
              <xsl:value-of select="movement-title"/>
            </xsl:when>
            <xsl:when test="work/work-title">
              <xsl:value-of select="work/work-title"/>
            </xsl:when>
            <xsl:otherwise>Score</xsl:otherwise>
          </xsl:choose>
        </title>
        <link rel="stylesheet" href="src/css/musicxml.css"/>
        <style>body { font-size: 48px; }</style>
      </head>
      <body>
        <div class="score">
          <xsl:apply-templates select="part-list/score-part"/>
        </div>
      </body>
    </html>
  </xsl:template>

  <!-- ============================================================
       One .staff div per score-part.
       Iterates over all measures collecting that part's content.
       ============================================================ -->
  <xsl:template match="score-part">
    <xsl:variable name="pid" select="@id"/>
    <div class="staff">
      <xsl:for-each select="/score-timewise/measure">
        <xsl:variable name="part" select="part[@id = $pid]"/>

        <!-- Clef and time signature (only when present in this measure) -->
        <xsl:apply-templates select="$part/attributes/clef"/>
        <xsl:apply-templates select="$part/attributes/time"/>

        <!-- Notes (with beam groups wrapped in <span class="beam">) -->
        <xsl:call-template name="process-notes">
          <xsl:with-param name="notes" select="$part/note"/>
          <xsl:with-param name="pos" select="1"/>
        </xsl:call-template>

        <!-- Barline: use explicit right barline if present, else generate one -->
        <xsl:choose>
          <xsl:when test="$part/barline[@location = 'right']">
            <xsl:apply-templates select="$part/barline[@location = 'right']"/>
          </xsl:when>
          <xsl:when test="position() = last()">
            <span class="barline">&#x1D102;</span><!-- final barline -->
          </xsl:when>
          <xsl:otherwise>
            <span class="barline">&#x1D100;</span><!-- regular barline -->
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </div>
  </xsl:template>

  <!-- ============================================================
       Clef
       ============================================================ -->
  <xsl:template match="clef">
    <xsl:choose>
      <xsl:when test="sign = 'G'">
        <span class="clef-G">&#x1D11E;</span>
      </xsl:when>
      <xsl:when test="sign = 'F'">
        <span class="clef-F">&#x1D122;</span>
      </xsl:when>
      <xsl:when test="sign = 'C'">
        <span class="clef-C">&#x1D121;</span>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- ============================================================
       Time signature
       ============================================================ -->
  <xsl:template match="time">
    <span class="time-sig">
      <sup><xsl:value-of select="beats"/></sup>/<sub><xsl:value-of select="beat-type"/></sub>
    </span>
  </xsl:template>

  <!-- ============================================================
       Note dispatch
       ============================================================ -->
  <xsl:template match="note">
    <xsl:choose>
      <xsl:when test="rest">
        <xsl:call-template name="rest-glyph"/>
      </xsl:when>
      <xsl:when test="pitch">
        <xsl:call-template name="pitched-note"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- ============================================================
       Process notes, wrapping beam groups (from <beam>begin</beam>
       through <beam>end</beam>) inside <span class="beam">.
       ============================================================ -->
  <xsl:template name="process-notes">
    <xsl:param name="notes"/>
    <xsl:param name="pos"/>
    <xsl:if test="$pos &lt;= count($notes)">
      <xsl:variable name="current" select="$notes[$pos]"/>
      <xsl:choose>
        <xsl:when test="$current/beam = 'begin'">
          <!-- Find the position of the matching 'end' beam note. -->
          <xsl:variable name="end-pos">
            <xsl:call-template name="find-beam-end">
              <xsl:with-param name="notes" select="$notes"/>
              <xsl:with-param name="pos"   select="$pos + 1"/>
              <xsl:with-param name="total" select="count($notes)"/>
            </xsl:call-template>
          </xsl:variable>
          <!-- Beam line container class; derived from the end note's type. -->
          <xsl:variable name="beam-class">
            <xsl:choose>
              <xsl:when test="$notes[number($end-pos)]/type = 'eighth'">beam8</xsl:when>
              <xsl:when test="$notes[number($end-pos)]/type = '16th'">beam16</xsl:when>
              <xsl:when test="$notes[number($end-pos)]/type = '32nd'">beam32</xsl:when>
              <xsl:when test="$notes[number($end-pos)]/type = '64th'">beam64</xsl:when>
              <xsl:when test="$notes[number($end-pos)]/type = '128th'">beam128</xsl:when>
              <xsl:otherwise>beam8</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <span class="beam">
            <xsl:for-each select="$notes[position() &gt;= $pos and position() &lt;= number($end-pos)]">
              <xsl:apply-templates select="."/>
            </xsl:for-each>
            <span class="{$beam-class} beam-container beam-uphill"><div class="beam-skew"><xsl:text> </xsl:text></div></span>
            <span class="{$beam-class} beam-container beam-downhill"><div class="beam-skew"><xsl:text> </xsl:text></div></span>
          </span>
          <xsl:call-template name="process-notes">
            <xsl:with-param name="notes" select="$notes"/>
            <xsl:with-param name="pos"   select="number($end-pos) + 1"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="$current"/>
          <xsl:call-template name="process-notes">
            <xsl:with-param name="notes" select="$notes"/>
            <xsl:with-param name="pos"   select="$pos + 1"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!-- ============================================================
       Return the position (within $notes) of the next note whose
       <beam> child equals 'end'. Falls back to $total if none found.
       ============================================================ -->
  <xsl:template name="find-beam-end">
    <xsl:param name="notes"/>
    <xsl:param name="pos"/>
    <xsl:param name="total"/>
    <xsl:choose>
      <xsl:when test="$pos &gt; $total">
        <xsl:value-of select="$total"/>
      </xsl:when>
      <xsl:when test="$notes[$pos]/beam = 'end'">
        <xsl:value-of select="$pos"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="find-beam-end">
          <xsl:with-param name="notes" select="$notes"/>
          <xsl:with-param name="pos"   select="$pos + 1"/>
          <xsl:with-param name="total" select="$total"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ============================================================
       Pitched note
       CSS class: pitch-{Step}{Octave}  e.g. pitch-D4
       Stem rule: octave >= 5 → stem-down
       ============================================================ -->
  <xsl:template name="pitched-note">
    <xsl:variable name="step"        select="pitch/step"/>
    <xsl:variable name="octave"      select="number(pitch/octave)"/>
    <xsl:variable name="pitch-class" select="concat('pitch-', $step, $octave)"/>
    <xsl:variable name="glyph">
      <xsl:call-template name="note-glyph">
        <xsl:with-param name="type" select="type"/>
      </xsl:call-template>
    </xsl:variable>
    <span>
      <xsl:attribute name="class">
        <xsl:value-of select="$pitch-class"/>
        <xsl:if test="$octave >= 5"> stem-down</xsl:if>
        <xsl:if test="beam">
          <xsl:text> </xsl:text>
          <xsl:choose>
            <xsl:when test="type = 'eighth'">beam8</xsl:when>
            <xsl:when test="type = '16th'">beam16</xsl:when>
            <xsl:when test="type = '32nd'">beam32</xsl:when>
            <xsl:when test="type = '64th'">beam64</xsl:when>
            <xsl:when test="type = '128th'">beam128</xsl:when>
          </xsl:choose>
          <xsl:if test="beam = 'begin'"> beam-begin</xsl:if>
          <xsl:if test="beam = 'end'"> beam-end</xsl:if>
        </xsl:if>
      </xsl:attribute>
      <xsl:value-of select="$glyph"/>
    </span>
  </xsl:template>

  <!-- ============================================================
       Note type → Unicode glyph (precomposed stem+head)
       ============================================================ -->
  <xsl:template name="note-glyph">
    <xsl:param name="type"/>
    <xsl:choose>
      <xsl:when test="$type = 'whole'">&#x1D15D;</xsl:when>
      <xsl:when test="$type = 'half'">&#x1D15E;</xsl:when>
      <xsl:when test="$type = 'quarter'">&#x1D15F;</xsl:when>
      <!-- beamed eighth/shorter: beam replaces flag, use plain black notehead -->
      <xsl:when test="beam and ($type = 'eighth' or $type = '16th' or $type = '32nd' or $type = '64th' or $type = '128th')">&#x1D158;</xsl:when>
      <xsl:when test="$type = 'eighth'">&#x1D160;</xsl:when>
      <xsl:when test="$type = '16th'">&#x1D161;</xsl:when>
      <xsl:when test="$type = '32nd'">&#x1D162;</xsl:when>
      <xsl:when test="$type = '64th'">&#x1D163;</xsl:when>
      <xsl:when test="$type = '128th'">&#x1D164;</xsl:when>
      <xsl:otherwise>&#x1D15F;</xsl:otherwise><!-- fallback: quarter -->
    </xsl:choose>
  </xsl:template>

  <!-- ============================================================
       Rest glyph
       ============================================================ -->
  <xsl:template name="rest-glyph">
    <xsl:variable name="type" select="type"/>
    <xsl:variable name="class">
      <xsl:choose>
        <xsl:when test="$type = 'whole'">rest-whole</xsl:when>
        <xsl:when test="$type = 'half'">rest-half</xsl:when>
        <xsl:when test="$type = 'quarter'">rest-quarter</xsl:when>
        <xsl:when test="$type = 'eighth'">rest-eighth</xsl:when>
        <xsl:when test="$type = '16th'">rest-16th</xsl:when>
        <xsl:when test="$type = '32nd'">rest-32nd</xsl:when>
        <xsl:when test="$type = '64th'">rest-64th</xsl:when>
        <xsl:otherwise>rest-quarter</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="glyph">
      <xsl:choose>
        <xsl:when test="$type = 'whole'">&#x1D13B;</xsl:when>
        <xsl:when test="$type = 'half'">&#x1D13C;</xsl:when>
        <xsl:when test="$type = 'quarter'">&#x1D13D;</xsl:when>
        <xsl:when test="$type = 'eighth'">&#x1D13E;</xsl:when>
        <xsl:when test="$type = '16th'">&#x1D13F;</xsl:when>
        <xsl:when test="$type = '32nd'">&#x1D140;</xsl:when>
        <xsl:when test="$type = '64th'">&#x1D141;</xsl:when>
        <xsl:otherwise>&#x1D13D;</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <span class="{$class}"><xsl:value-of select="$glyph"/></span>
  </xsl:template>

  <!-- ============================================================
       Explicit barline element
       ============================================================ -->
  <xsl:template match="barline">
    <xsl:choose>
      <xsl:when test="repeat/@direction = 'forward'">
        <span class="barline">&#x1D105;</span>
      </xsl:when>
      <xsl:when test="repeat/@direction = 'backward'">
        <span class="barline">&#x1D104;</span>
      </xsl:when>
      <xsl:when test="bar-style = 'light-light'">
        <span class="barline">&#x1D101;</span>
      </xsl:when>
      <xsl:when test="bar-style = 'light-heavy'">
        <span class="barline">&#x1D102;</span>
      </xsl:when>
      <xsl:when test="bar-style = 'none'"/><!-- intentionally no output -->
      <xsl:otherwise>
        <span class="barline">&#x1D100;</span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
