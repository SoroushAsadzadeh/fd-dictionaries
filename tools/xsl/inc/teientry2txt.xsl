<?xml version='1.0' encoding='UTF-8'?>

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:include href="indent.xsl"/>
  <!-- if gender exists, do not print pos element (default: off) -->
  <xsl:param name="no-pos-if-noun" select="false()"/>

  <xsl:strip-space elements="entry form gramGrp sense trans eg"/>

  <!-- TEI entry specific templates -->
  <xsl:template match="entry">
    <!--<xsl:apply-templates select="form | gramGrp"/>-->
    <xsl:apply-templates select="form"/> <!-- force form before gramGrp -->
    <xsl:apply-templates select="gramGrp"/>
    <xsl:text>&#xa;</xsl:text>
    <xsl:apply-templates select="sense"/>

    <!-- For simple entries without separate senses and old FreeDict databases -->
    <xsl:for-each select="trans | def | note">
      <xsl:text> </xsl:text>
      <xsl:if test="not(last()=1)">
	<xsl:number value="position()"/>
	<xsl:text>. </xsl:text>
      </xsl:if>
      <xsl:apply-templates select="."/>
      <xsl:text>&#xa;</xsl:text>
    </xsl:for-each>

  </xsl:template>

  <xsl:template match="form">
    <xsl:variable name="paren" select="count(parent::form) = 1 or @type='infl'"/>
    <!-- parenthesised if nested or (ad hoc) if @type="infl" -->
    <xsl:if test="$paren">
      <xsl:text> (</xsl:text>
    </xsl:if>
    <xsl:apply-templates select="usg"/>     <!-- added to handle usg info in nested <form>s -->
    <xsl:for-each select="orth">
      <xsl:value-of select="."/>
      <xsl:if test="position() != last()">
	<xsl:text>, </xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:apply-templates select="pron"/>
  <xsl:if test="$paren">
      <xsl:text>)</xsl:text>
    </xsl:if>
    <xsl:apply-templates select="form"/>
    <xsl:if test="following-sibling::form and following-sibling::form[1][not(@type='infl')]">
      <xsl:text>, </xsl:text>
      <!-- cosmetics: no comma before parens  -->
    </xsl:if>
  </xsl:template>

  <xsl:template match="orth">
    <xsl:value-of select="."/>
    <xsl:if test="position() != last()">
      <xsl:text>, </xsl:text>
    </xsl:if>
    <xsl:apply-templates select="pron"/>
  </xsl:template>


  <xsl:template match="pron">
    <xsl:text> /</xsl:text><xsl:apply-templates/><xsl:text>/</xsl:text>
  </xsl:template>

  <xsl:template match="gramGrp">
    <xsl:text> &lt;</xsl:text>
    <xsl:choose>
      <xsl:when test="pos='n' and gen and $no-pos-if-noun">
	<!-- if gender exists, do not print pos element -->
	<xsl:for-each select="num | gen">
	  <xsl:apply-templates select="."/>
	  <xsl:if test="position()!=last()">
	    <xsl:text>, </xsl:text>
	  </xsl:if>
	</xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
	<xsl:for-each select="pos | num | gen">
	  <xsl:apply-templates select="."/>
	  <xsl:if test="position()!=last()">
	    <xsl:text>, </xsl:text>
	  </xsl:if>
	</xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>></xsl:text>
  </xsl:template>

  <xsl:template match="sense">
    <xsl:text> </xsl:text>
    <xsl:if test="not(last()=1)">
      <xsl:number value="position()"/>
      <xsl:text>. </xsl:text>
    </xsl:if>

    <xsl:if test="count(usg | trans | def)>0">
      <xsl:apply-templates select="usg | trans | def"/>
      <xsl:text>&#xa;</xsl:text>
    </xsl:if>

    <xsl:if test="count(eg)>0">
      <xsl:text>    </xsl:text>
      <xsl:apply-templates select="eg"/>
    </xsl:if>

    <xsl:if test="count(xr)>0">
      <xsl:text>    </xsl:text>
      <xsl:apply-templates select="xr"/>
      <xsl:text>&#xa;</xsl:text>
    </xsl:if>

    <xsl:apply-templates select="*[name() != 'usg' and name() != 'trans' and name() != 'def' and name() != 'eg' and name() != 'xr']"/>

  </xsl:template>

  <xsl:template match="usg[@type]">
    <xsl:text>[</xsl:text>
    <xsl:value-of select="." />
    <xsl:text>.] </xsl:text>
  </xsl:template>

  <xsl:template match="trans">
    <xsl:apply-templates/>
    <xsl:if test="not(position()=last())">, </xsl:if>
  </xsl:template>

  <xsl:template match="tr">
    <xsl:apply-templates/>
    <xsl:if test="not(position()=last())">, </xsl:if>
  </xsl:template>

  <xsl:template match="def">
    <xsl:call-template name="format">
      <xsl:with-param name="txt" select="normalize-space()"/>
      <xsl:with-param name="width" select="75"/>
      <xsl:with-param name="start" select="4"/>
    </xsl:call-template>
    <xsl:if test="not(position()=last())">&#xa;     </xsl:if>
  </xsl:template>

  <xsl:template match="eg">
    <xsl:text>&quot;</xsl:text>
    <xsl:call-template name="format">
      <xsl:with-param name="txt" select="concat(normalize-space(q), '&quot;')"/>
      <xsl:with-param name="width" select="75"/>
      <xsl:with-param name="start" select="4"/>
    </xsl:call-template>

    <xsl:if test="trans">
      <xsl:text>    (</xsl:text>
      <xsl:value-of select="trans/tr"/>
      <xsl:text>)&#xa;</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="xr">
    <xsl:choose>
      <xsl:when test="not(@type)">
	<xsl:text>See also</xsl:text>
      </xsl:when>
      <xsl:when test="@type='syn'">
	<xsl:text>Synonym</xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="@type"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>: {</xsl:text>
    <xsl:value-of select="ref"/>
    <xsl:text>}</xsl:text>
    <xsl:if test="not(position()=last())">, </xsl:if>
  </xsl:template>

  <xsl:template match="entry//p">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="entry//note">
    <xsl:choose>
      <xsl:when test="@resp='translator'">
	<xsl:text>&#xa;         Entry edited by: </xsl:text>
	<xsl:value-of select="."/>
	<xsl:text>&#xa;</xsl:text>
      </xsl:when>
      <xsl:when test="text()">
	<xsl:text>&#xa;         Note: </xsl:text>
	<xsl:value-of select="text()"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>

