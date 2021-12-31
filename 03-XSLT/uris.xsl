<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	xmlns:sparnaf="http://data.sparna.fr/function/sparnaf#"
	xmlns:mus="http://data.doremus.org/ontology#"
	xmlns:efrbroo="http://erlangen-crm.org/efrbroo/"
	xmlns:ecrm="http://erlangen-crm.org/current/"
>

	<!-- Call sources files -->
	<xsl:param name="SHARED_XML_DIR">.</xsl:param>
	
	<!-- AIC14 -->
	<xsl:param name="AIC14_file"
		select="document(concat($SHARED_XML_DIR,'/', 'ExportTUM-pretty.xml'))/NOTICES" />

	
	<xsl:function name="mus:URI-F24_Expression">
		<xsl:param name="idReferenceNotice" />
		<xsl:value-of select="concat('http://data.philharmoniedeparis.fr/',$idReferenceNotice)" />
	</xsl:function>
	
	<!--  -->
	<xsl:function name="ecrm:has_time">
		<xsl:param name="idNotice"/>
		<xsl:param name="data_find_year"/>
		<xsl:variable name="data_Time">
			<xsl:if test="not(contains($data_find_year,'impr.'))
							and
							translate($data_find_year,translate($data_find_year, '0123456789', ''),'')">
				<xsl:value-of select="translate($data_find_year,translate($data_find_year, '0123456789', ''),'')"/>
			</xsl:if>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="string-length($data_Time) = 4">
				<xsl:value-of select="$data_Time"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>Noticie <xsl:value-of select="$idNotice"/>,La valeur n'est pas une valeur de type d'année: <xsl:value-of select="$data_find_year"/> </xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<!-- Chercher l'information dans AIC14  -->
	<xsl:function name="mus:Titre_Uniforme_Musical">
		<xsl:param name="idNotice"/>
		<xsl:param name="idAIC14"/>
		<xsl:param name="idBalise"/>
		<xsl:variable name="data" select="$AIC14_file/NOTICE[@id = $idAIC14 and @type='AIC:14']/champs[@UnimarcTag=$idBalise]"/>
		<xsl:choose>
			<xsl:when test="$data">	
				<xsl:if test="$idBalise = '322'">	
					<xsl:variable name="count322a" select="count($data/SOUSCHAMP[@UnimarcSubfield='322$a'])"/>
					<xsl:variable name="data_result">		
						<xsl:for-each select="$data">
							<xsl:variable name="dataComp" select="."/>
								<xsl:choose>
									<xsl:when test="($dataComp/SOUSCHAMP[@UnimarcSubfield='322$a']/data and $dataComp/SOUSCHAMP[@UnimarcSubfield='322$m']/data) and $count322a = 1">
										<xsl:value-of select="concat($dataComp/SOUSCHAMP[@UnimarcSubfield='322$a']/data,',',$dataComp/SOUSCHAMP[@UnimarcSubfield='322$m']/data,'. -')"/>
									</xsl:when>
									<xsl:when test="($dataComp/SOUSCHAMP[@UnimarcSubfield='322$a']/data and $dataComp/SOUSCHAMP[@UnimarcSubfield='322$m']/data) and $count322a &gt; 1">
										<xsl:value-of select="concat($dataComp/SOUSCHAMP[@UnimarcSubfield='322$a']/data,',',$dataComp/SOUSCHAMP[@UnimarcSubfield='322$m']/data,' - ')"/>
									</xsl:when>							
								</xsl:choose>
								
						</xsl:for-each>	
					</xsl:variable>	
					
					<xsl:choose>
						<xsl:when test="$count322a &gt; 1">
							<xsl:value-of select="concat(substring($data_result,0,(string-length($data_result))-1),'. -')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$data_result"/>
						</xsl:otherwise>
					</xsl:choose>						
				</xsl:if>		
			
			
				<!-- Données : 
					AIC14:144 ou AIC14:444
					$a $c $e $g $h $i $j $k $n $p $q $r $t $u.
					
					Cas 1- si 144 ou 444 $g, $c, $h et $i sont vides (le plus courant  pour reconstituer un TUM ) :  
						 concaténer les sous-zones suivantes  (si elles sont remplies), 
						 en respectant l'ordre indiqué et en séparant chaque occurence par un point et un espace : 
						 $a. $r. $n. $k. $p. $t. $u
						 puis (si $e, $j ou $q ne sont pas vides), ajouter à la suite : une parenthèse, 
						 chaque occurrence non vides (séparées par un point-virgule) de $e; $q); $j puis fermer la parenthèse. 
				 -->
				<xsl:if test="$idBalise = '144' or $idBalise ='444'">
					<xsl:for-each select="$data">
						<xsl:variable name="dataOeuvre" select="."/>
						
						<xsl:variable name="Balise_a" select="concat($idBalise,'$','a')"/>
						<xsl:variable name="Balise_c" select="concat($idBalise,'$','c')"/>
						<xsl:variable name="Balise_e" select="concat($idBalise,'$','e')"/>
						<xsl:variable name="Balise_g" select="concat($idBalise,'$','g')"/>
						<xsl:variable name="Balise_h" select="concat($idBalise,'$','h')"/>
						<xsl:variable name="Balise_i" select="concat($idBalise,'$','i')"/>
						<xsl:variable name="Balise_j" select="concat($idBalise,'$','j')"/>
						<xsl:variable name="Balise_k" select="concat($idBalise,'$','k')"/>
						<xsl:variable name="Balise_n" select="concat($idBalise,'$','n')"/>
						<xsl:variable name="Balise_p" select="concat($idBalise,'$','p')"/>
						<xsl:variable name="Balise_q" select="concat($idBalise,'$','q')"/>
						<xsl:variable name="Balise_r" select="concat($idBalise,'$','r')"/>
						<xsl:variable name="Balise_t" select="concat($idBalise,'$','t')"/>
						<xsl:variable name="Balise_u" select="concat($idBalise,'$','u')"/>>
						
						
						<xsl:variable name="oeuvre_data_a"><xsl:if test="$dataOeuvre/SOUSCHAMP[@UnimarcSubfield=$Balise_a]"><xsl:value-of select="normalize-space($dataOeuvre/SOUSCHAMP[@UnimarcSubfield=$Balise_a]/data)"/></xsl:if></xsl:variable>
						<xsl:variable name="oeuvre_data_c"><xsl:if test="$dataOeuvre/SOUSCHAMP[@UnimarcSubfield=$Balise_c]"><xsl:value-of select="normalize-space($dataOeuvre/SOUSCHAMP[@UnimarcSubfield=$Balise_c]/data)"/></xsl:if></xsl:variable>
						<xsl:variable name="oeuvre_data_e"><xsl:if test="$dataOeuvre/SOUSCHAMP[@UnimarcSubfield=$Balise_e]"><xsl:value-of select="normalize-space($dataOeuvre/SOUSCHAMP[@UnimarcSubfield=$Balise_e]/data)"/></xsl:if></xsl:variable>
						<xsl:variable name="oeuvre_data_g"><xsl:if test="$dataOeuvre/SOUSCHAMP[@UnimarcSubfield=$Balise_g]"><xsl:value-of select="normalize-space($dataOeuvre/SOUSCHAMP[@UnimarcSubfield=$Balise_g]/data)"/></xsl:if></xsl:variable>
						<xsl:variable name="oeuvre_data_h"><xsl:if test="$dataOeuvre/SOUSCHAMP[@UnimarcSubfield=$Balise_h]"><xsl:value-of select="normalize-space($dataOeuvre/SOUSCHAMP[@UnimarcSubfield=$Balise_h]/data)"/></xsl:if></xsl:variable>
						<xsl:variable name="oeuvre_data_i"><xsl:if test="$dataOeuvre/SOUSCHAMP[@UnimarcSubfield=$Balise_i]"><xsl:value-of select="normalize-space($dataOeuvre/SOUSCHAMP[@UnimarcSubfield=$Balise_i]/data)"/></xsl:if></xsl:variable>
						<xsl:variable name="oeuvre_data_j"><xsl:if test="$dataOeuvre/SOUSCHAMP[@UnimarcSubfield=$Balise_j]"><xsl:value-of select="normalize-space($dataOeuvre/SOUSCHAMP[@UnimarcSubfield=$Balise_j]/data)"/></xsl:if></xsl:variable>
						<xsl:variable name="oeuvre_data_k"><xsl:if test="$dataOeuvre/SOUSCHAMP[@UnimarcSubfield=$Balise_k]"><xsl:value-of select="normalize-space($dataOeuvre/SOUSCHAMP[@UnimarcSubfield=$Balise_k]/data)"/></xsl:if></xsl:variable>
						<xsl:variable name="oeuvre_data_n"><xsl:if test="$dataOeuvre/SOUSCHAMP[@UnimarcSubfield=$Balise_n]"><xsl:value-of select="normalize-space($dataOeuvre/SOUSCHAMP[@UnimarcSubfield=$Balise_n]/data)"/></xsl:if></xsl:variable>
						<xsl:variable name="oeuvre_data_p"><xsl:if test="$dataOeuvre/SOUSCHAMP[@UnimarcSubfield=$Balise_p]"><xsl:value-of select="normalize-space($dataOeuvre/SOUSCHAMP[@UnimarcSubfield=$Balise_p]/data)"/></xsl:if></xsl:variable>
						<xsl:variable name="oeuvre_data_q"><xsl:if test="$dataOeuvre/SOUSCHAMP[@UnimarcSubfield=$Balise_q]"><xsl:value-of select="normalize-space($dataOeuvre/SOUSCHAMP[@UnimarcSubfield=$Balise_q]/data)"/></xsl:if></xsl:variable>
						<xsl:variable name="oeuvre_data_r"><xsl:if test="$dataOeuvre/SOUSCHAMP[@UnimarcSubfield=$Balise_r]"><xsl:value-of select="normalize-space($dataOeuvre/SOUSCHAMP[@UnimarcSubfield=$Balise_r]/data)"/></xsl:if></xsl:variable>
						<xsl:variable name="oeuvre_data_t"><xsl:if test="$dataOeuvre/SOUSCHAMP[@UnimarcSubfield=$Balise_t]"><xsl:value-of select="normalize-space($dataOeuvre/SOUSCHAMP[@UnimarcSubfield=$Balise_t]/data)"/></xsl:if></xsl:variable>
						<xsl:variable name="oeuvre_data_u"><xsl:if test="$dataOeuvre/SOUSCHAMP[@UnimarcSubfield=$Balise_u]"><xsl:value-of select="normalize-space($dataOeuvre/SOUSCHAMP[@UnimarcSubfield=$Balise_u]/data)"/></xsl:if></xsl:variable>
					
						<xsl:choose>
							<!--  
							Cas 1- si 144 ou 444 
									$g, $c, $h et $i sont vides (le plus courant  pour reconstituer un TUM ) :  
												 concaténer les sous-zones suivantes  (si elles sont remplies), 
												 en respectant l'ordre indiqué et en séparant chaque occurence par un point et un espace : 
												 $a. $r. $n. $k. $p. $t. $u
								 puis (si $e, $j ou $q ne sont pas vides), ajouter à la suite : une parenthèse, 
								 chaque occurrence non vides (séparées par un point-virgule) de $e; $q); $j puis fermer la parenthèse. 
							 -->
							<xsl:when test="string-length($oeuvre_data_g) = 0 and
											string-length($oeuvre_data_c) = 0 and 
											string-length($oeuvre_data_h) = 0 and 
											string-length($oeuvre_data_i) = 0 
											">
									<xsl:message> ****Condition**** </xsl:message>
									<xsl:variable name="data_a">		
										<xsl:value-of select="normalize-space(concat(
																sparnaf:isTrue($oeuvre_data_a),
																sparnaf:isTrue($oeuvre_data_r),
																sparnaf:isTrue($oeuvre_data_n),
																sparnaf:isTrue($oeuvre_data_k),
																sparnaf:isTrue($oeuvre_data_p),
																sparnaf:isTrue($oeuvre_data_t),
																sparnaf:isTrue($oeuvre_data_u)
																)
																)"/>
									</xsl:variable>
									<xsl:variable name="data_b">
										<xsl:if test="(string-length($oeuvre_data_e) &gt; 0 and
												string-length($oeuvre_data_j) &gt; 0) or
												string-length($oeuvre_data_q) &gt; 0">
																							
												<xsl:variable name="section2" select="concat(
															sparnaf:isTrueParenthesis($oeuvre_data_e),
															sparnaf:isTrueParenthesis($oeuvre_data_g),
															sparnaf:isTrueParenthesis($oeuvre_data_j)
															)"/>
												
												<xsl:variable name="data_b">			
													<xsl:if test="$section2">
														<xsl:value-of select="concat(':',substring($section2,0,string-length($section2)-1),')')"/>
													</xsl:if>
												</xsl:variable>		
										</xsl:if>
									</xsl:variable>
									
									<xsl:if test="$data_a or $data_b ">
										<xsl:value-of select="concat($data_a,$data_b)"/>
									</xsl:if>
									
							</xsl:when>
							<xsl:otherwise>
								<xsl:message> ****General**** </xsl:message>
								<xsl:value-of select="normalize-space(concat(
														sparnaf:isTrue($oeuvre_data_a),
														sparnaf:isTrue($oeuvre_data_r),
														sparnaf:isTrue($oeuvre_data_n),
														sparnaf:isTrue($oeuvre_data_k),
														sparnaf:isTrue($oeuvre_data_p),
														sparnaf:isTrue($oeuvre_data_t),
														sparnaf:isTrue($oeuvre_data_u)
														)
														)"/>
							</xsl:otherwise>
						</xsl:choose>
						
					
					
					</xsl:for-each>					
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>Noticie <xsl:value-of select="$idNotice"/>,Le code AIC14: <xsl:value-of select="$idAIC14"/>, ne se trouve pas dans le fichier.</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="sparnaf:isTrue">
		<xsl:param name="valeur"/>
		<xsl:choose>
			<xsl:when test="$valeur !='' or string-length($valeur) &gt; 0">
				<xsl:value-of select="concat($valeur,'. ')"/>
			</xsl:when>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="sparnaf:isTrueParenthesis">
		<xsl:param name="valeur"/>
		<xsl:choose>
			<xsl:when test="$valeur !='' or string-length($valeur) &gt; 0">
				<xsl:value-of select="concat($valeur,';')"/>
			</xsl:when>
		</xsl:choose>
	</xsl:function>

</xsl:stylesheet>