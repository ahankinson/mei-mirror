<?xml version="1.0" encoding="UTF-8"?>

<!-- ************************************************************** -->
<!--
  NAME:     Music Encoding Initiative (MEI) schema component:
            coConstraints.rng
  
  NOTICE:   Copyright (c) 2010 by the Music Encoding Initiative (MEI)
            Council.
  
            Licensed under the Educational Community License, Version
            2.0 (the "License"); you may not use this file except in
            compliance with the License. You may obtain a copy of the
            License at http://www.osedu.org/licenses/ECL-2.0.
            
            Unless required by applicable law or agreed to in writing,
            software distributed under the License is distributed on
            an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
            KIND, either express or implied. See the License for the
            specific language governing permissions and limitations
            under the License.
            
            This is a derivative work based on earlier versions of the
            schema copyright (c) 2001-2006 Perry Roland and the Rector
            and Visitors of the University of Virginia; licensed under
            the Educational Community License version 1.0.
  
  CONTACT:  contact@music-encoding.org 
-->

<sch:schema xmlns="http://purl.oclc.org/dsdl/schematron"
  xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:sch="http://purl.oclc.org/dsdl/schematron"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mei="http://www.music-encoding.org/ns/mei" queryBinding="xslt2">
  <sch:ns uri="http://www.music-encoding.org/ns/mei" prefix="mei"/>

  <sch:pattern>
    <sch:title>Check @when</sch:title>
    <sch:rule context="mei:*[@when]">
      <sch:assert test="@when = preceding::mei:when/@xml:id">The value of @when
        must be the ID of a when element.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>Check when/@since</sch:title>
    <sch:rule context="mei:when[@since]">
      <sch:let name="thissince" value="@since"/>
      <sch:assert
        test="@since = preceding-sibling::mei:when[@xml:id=$thissince]/@xml:id"
        >The value of @since must be the ID of a preceding sibling when
        element.</sch:assert>
      <sch:assert test="@interval and @unit">If @since is present, @interval and
        @unit are also required.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>Check @source</sch:title>
    <sch:rule context="mei:*[@source]">
      <sch:assert
        test="every $i in tokenize(@source, '\s+') satisfies
          $i=//mei:source/@xml:id"
        >The values in @source must match the IDs of source
        elements.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:rule context="mei:staffgrp">
      <sch:let name="countstaves" value="count(descendant::mei:staffdef)"/>
      <sch:let name="countuniqstaves"
        value="count(distinct-values(descendant::mei:staffdef/@n))"/>
      <sch:assert test="$countstaves eq $countuniqstaves">Each staffdef must
        have a unique value for the n attribute.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>Check staffdef/@n</sch:title>
    <sch:rule context="mei:staffdef">
      <sch:let name="thisstaff" value="@n"/>
      <sch:assert test="@n">A staffdef must have an n attribute.</sch:assert>
      <sch:assert
        test="@lines or preceding::mei:staffdef[@n=$thisstaff and @lines]">The
        first occurrence of a staff must declare the number of staff
        lines.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>Check clef position (staffdef)</sch:title>
    <sch:rule context="mei:staffdef[@clef.line and @lines]">
      <sch:assert test="number(@clef.line) &lt;= number(@lines)">The clef
        position must be less than or equal to the number of lines on the
        staff.</sch:assert>
    </sch:rule>
    <sch:rule context="mei:staffdef[@clef.line and not(@lines)]">
      <sch:let name="thisstaff" value="@n"/>
      <sch:let name="stafflines"
        value="preceding::mei:staffdef[@n=$thisstaff and @lines][1]/@lines"/>
      <sch:assert test="number(@clef.line) &lt;= number($stafflines)">The
        clef position must be less than or equal to the number of lines on the
        staff.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>Check clef position (clefchange)</sch:title>
    <sch:rule context="mei:clefchange[@line]">
      <sch:let name="thisstaff" value="ancestor::staff/@n"/>
      <sch:let name="staffpos"
        value="count(ancestor::mei:staff/preceding-sibling::mei:staff) + 1"/>
      <sch:assert
        test="number(@line) &lt;= number(preceding::mei:staffdef[@n=$thisstaff and @lines][1]/@lines) or 
        number(@line) &lt;= number(preceding::mei:staffdef[@n=$staffpos and @lines][1]/@lines)"
        >The clef position must be less than or equal to the number of lines on
        the staff.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>Check clef position (clef)</sch:title>
    <sch:rule context="mei:clef[ancestor::mei:staffdef[@lines]]">
      <sch:let name="thisstaff" value="ancestor::mei:staffdef/@n"/>
      <sch:assert
        test="number(@line) &lt;= number(ancestor::mei:staffdef[@n=$thisstaff and @lines][1]/@lines)"
        >The clef position must be less than or equal to the number of lines on
        the staff.</sch:assert>
    </sch:rule>
    <sch:rule context="mei:clef[ancestor::mei:staffdef[not(@lines)]]">
      <sch:let name="thisstaff" value="ancestor::mei:staffdef/@n"/>
      <sch:assert
        test="number(@line) &lt;= number(preceding::mei:staffdef[@n=$thisstaff and @lines][1]/@lines)"
        >The clef position must be less than or equal to the number of lines on
        the staff.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>Check expansion/@plist</sch:title>
    <sch:rule context="mei:expansion[@plist]">
      <sch:assert
        test="every $i in tokenize(@plist, '\s+') satisfies
          $i=ancestor::mei:section/descendant::mei:*[name()='section' or 
          name()='ending' or name()='rdg'][@xml:id]/@xml:id"
      />
    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>Check section[expansion]</sch:title>
    <sch:rule context="mei:section[mei:expansion]">
      <sch:assert
        test="descendant::mei:section|descendant::mei:ending|descendant::mei:rdg"
        >Must have descendant section, ending, or rdg elements that can be
        pointed to.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>Start-type attributes required on some control events</sch:title>
    <sch:rule
      context="mei:bend|mei:dir|mei:dynam|mei:fermata|mei:gliss|mei:harm|
        mei:harppedal|mei:mordent|mei:pedal|mei:trill">
      <sch:assert test="@startid or @tstamp or @tstamp.ges or @tstamp.real">
        Must have one of the attributes: startid, tstamp, tstamp.ges or
        tstamp.real</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>Start- and end-type attributes required on some control
      events</sch:title>
    <sch:rule
      context="mei:beamspan|mei:hairpin|mei:octave|mei:phrase|mei:slur|
        mei:tie|mei:tupletspan">
      <sch:assert test="@startid or @tstamp or @tstamp.ges or @tstamp.real">
        Must have one of the attributes: startid, tstamp, tstamp.ges or
        tstamp.real</sch:assert>
      <sch:assert test="@endid or @dur">Must have one of the attributes: dur or
        endid</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>Check rest/@line</sch:title>
    <sch:rule context="mei:rest[@line]">
      <sch:let name="thisstaff" value="ancestor::mei:staff/@n"/>
      <sch:assert
        test="number(@line) &lt;= number(preceding::mei:staffdef[@n=$thisstaff and @lines][1]/@lines)"
        >The value of @line must be less than or equal to the number of lines on
        the staff.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>Check barline/@taktplace</sch:title>
    <sch:rule context="mei:barline[@taktplace]">
      <sch:let name="staff" value="ancestor::mei:staff/@n"/>
      <sch:let name="staffpos"
        value="count(ancestor::mei:staff/preceding-sibling::mei:staff) + 1"/>
      <sch:assert
        test="number(@taktplace) &lt;= number(2 * preceding::mei:staffdef[@n=$staff and @lines][1]/@lines)"
      />
    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>Check @altsym</sch:title>
    <sch:rule context="mei:*[@altsym]">
      <sch:let name="thisaltsym" value="@altsym"/>
      <sch:assert
        test="@altsym = preceding::mei:symboldef[@xml:id=$thisaltsym]/@xml:id"
        >The value of @altsym must be the ID of a symboldef
        element.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>Check @xml:lang</sch:title>
    <sch:rule context="mei:*[starts-with(@xml:lang, 'x-')]">
      <sch:let name="thislang" value="@xml:lang"/>
      <sch:assert test="@xml:lang = //mei:language[@xml:id=$thislang]/@xml:id"
        >The value of @xml:lang must be the ID of a language
        element.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>Check measure/@join</sch:title>
    <sch:rule context="mei:measure[@join]">
      <sch:let name="thisjoin" value="@join"/>
      <sch:assert test="@join = //mei:measure[@xml:id=$thisjoin]/@xml:id">The
        value of @join must be the ID of a measure element.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>Check @classcode</sch:title>
    <sch:rule context="mei:*[@classcode]">
      <sch:let name="thisclasscode" value="@classcode"/>
      <sch:assert
        test="@classcode = preceding::mei:classcode[@xml:id=$thisclasscode]/@xml:id"
        >The value of @classcode must be the ID of a classcode
        element.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>Check handshift</sch:title>
    <sch:rule context="mei:handshift[@old]">
      <sch:let name="thisold" value="@old"/>
      <sch:assert test="@old = preceding::mei:hand[@xml:id=$thisold]/@xml:id"
        >The value of @old must be the ID of a hand element.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>Check handshift/@new</sch:title>
    <sch:rule context="mei:handshift[@new]">
      <sch:let name="thisnew" value="@new"/>
      <sch:assert test="@new = preceding::mei:hand[@xml:id=$thisnew]/@xml:id"
        >The value of @new must be the ID of a hand element.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>Check harm/@chordref</sch:title>
    <sch:rule context="mei:harm[@chordref]">
      <sch:let name="thischordref" value="@chordref"/>
      <sch:assert
        test="@chordref = preceding::mei:chorddef[@xml:id=$thischordref]/@xml:id"
        >The value of @chordref must be the ID of a chorddef
        element.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>Check @hand</sch:title>
    <sch:rule context="mei:*[@hand]">
      <sch:let name="thishand" value="@hand"/>
      <sch:assert test="@hand = preceding::mei:hand[@xml:id=$thishand]/@xml:id"
        >The value of @hand must be the ID of a hand element.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>Check custos/@target</sch:title>
    <sch:rule context="mei:custos[@target]">
      <sch:let name="thistarget" value="@target"/>
      <sch:assert
        test="@target = following::mei:note[@xml:id=$thistarget]/@xml:id">The
        value of @target must be the ID of a note element.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>Check @instr</sch:title>
    <sch:rule
      context="mei:chord[@instr]|mei:mrest[@instr]|mei:mspace[@instr]|mei:multirest[@instr]|
        mei:note[@instr]|mei:rest[@instr]">
      <sch:assert
        test="every $i in tokenize(@instr, '\s+') satisfies
          $i=preceding::mei:instrdef[@xml:id]/@xml:id"
      />
    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>Check barre/@startid and @endid</sch:title>
    <sch:rule context="mei:barre">
      <sch:let name="from" value="@startid"/>
      <sch:let name="to" value="@endid"/>
      <sch:assert
        test="@startid = preceding-sibling::mei:chordmember[@xml:id=$from]/@xml:id"
        >The value of @startid must be the ID of a chordmember
        element.</sch:assert>
      <sch:assert
        test="@endid = preceding-sibling::mei:chordmember[@xml:id=$to]/@xml:id"
        >The value of @endid must be the ID of a chordmember
        element.</sch:assert>
    </sch:rule>
  </sch:pattern>

  <sch:pattern>
    <sch:title>Check @resp</sch:title>
    <sch:rule context="mei:*[@resp]">
      <sch:let name="thisresp" value="@resp"/>
      <sch:assert
        test="@resp = //mei:persname[@xml:id=$thisresp and ancestor::mei:meihead]/@xml:id"
        >The value of @resp must be the ID of a persname element declared within
        the meiheader element.</sch:assert>
    </sch:rule>
  </sch:pattern>

</sch:schema>
