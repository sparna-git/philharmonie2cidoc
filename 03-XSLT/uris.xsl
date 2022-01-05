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
	
	<xsl:function name="mus:reference_personne">
		<xsl:param name="idReference" />
		<xsl:value-of select="concat('http://data.phlharmonie/AIC1/',$idReference)"/>
	</xsl:function>
	
	<xsl:function name="mus:reference_collectivite">
		<xsl:param name="idReference" />
		<xsl:value-of select="concat('http://data.phlharmonie/AIC2/',$idReference)"/>
	</xsl:function>
	
	<xsl:function name="mus:reference_thesaurus">
		<xsl:param name="idReference" />
		<xsl:value-of select="concat('http://data.phlharmonie/AIC90/',$idReference)"/>
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
		<xsl:param name="qualificatif"/>
		<xsl:variable name="metadata" select="$AIC14_file/NOTICE[@id = $idAIC14 and @type='AIC:14']/champs[@UnimarcTag=$idBalise]"/>
		<xsl:choose>
			<xsl:when test="$idBalise = '322'">	
				<xsl:variable name="count322" select="count($AIC14_file/NOTICE[@id = $idAIC14 and @type='AIC:14']/champs[@UnimarcTag=$idBalise])"/>
				
				<xsl:variable name="data_result">
					<xsl:choose>
						<xsl:when test="$count322 = 1">
							<xsl:value-of select="concat($metadata/SOUSCHAMP[@UnimarcSubfield='322$a']/data,',',$metadata/SOUSCHAMP[@UnimarcSubfield='322$m']/data)"/>
						</xsl:when>
						<xsl:when test="$count322 &gt; 1">
							<xsl:for-each select="$metadata">
								<xsl:variable name="data" select="."/>
								<xsl:variable name="data_a" select="$data/SOUSCHAMP[@UnimarcSubfield='322$a']/data"/>
								<xsl:variable name="data_m" select="$data/SOUSCHAMP[@UnimarcSubfield='322$m']/data"/>
								<xsl:value-of select="concat($data_a,',',$data_m,' - ')"/>
							</xsl:for-each>
						</xsl:when>
					</xsl:choose>
				</xsl:variable>						
				
				<xsl:choose>
					<xsl:when test="$count322 &gt; 1">
						<xsl:value-of select="substring($data_result,1,string-length($data_result)-2)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$data_result"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$idBalise = '144' or $idBalise ='444'">
				<xsl:variable name="Count" select="count($AIC14_file/NOTICE[@id = $idAIC14 and @type='AIC:14']/champs[@UnimarcTag=$idBalise])"/>
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
				<xsl:variable name="Balise_u" select="concat($idBalise,'$','u')"/>
				<xsl:choose>					
					<xsl:when test="$Count = 1">
						<xsl:variable name="oeuvre_data_a"><xsl:if test="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_a]"><xsl:value-of select="normalize-space($metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_a]/data)"/></xsl:if></xsl:variable>
						<xsl:variable name="oeuvre_data_c"><xsl:if test="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_c]"><xsl:value-of select="normalize-space($metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_c]/data)"/></xsl:if></xsl:variable>
						
						<xsl:variable name="oeuvre_data_g"><xsl:if test="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_g]"><xsl:value-of select="normalize-space($metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_g]/data)"/></xsl:if></xsl:variable>
							
						<xsl:variable name="oeuvre_data_h"><xsl:if test="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_h]"><xsl:value-of select="normalize-space($metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_h]/data)"/></xsl:if></xsl:variable>
						<xsl:variable name="oeuvre_data_i"><xsl:if test="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_i]"><xsl:value-of select="normalize-space($metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_i]/data)"/></xsl:if></xsl:variable>
						
						<xsl:variable name="oeuvre_data_k"><xsl:if test="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_k]"><xsl:value-of select="normalize-space($metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_k]/data)"/></xsl:if></xsl:variable>
						<xsl:variable name="oeuvre_data_n"><xsl:if test="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_n]"><xsl:value-of select="normalize-space($metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_n]/data)"/></xsl:if></xsl:variable>
						<xsl:variable name="oeuvre_data_p"><xsl:if test="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_p]"><xsl:value-of select="normalize-space($metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_p]/data)"/></xsl:if></xsl:variable>
						<xsl:variable name="oeuvre_data_q"><xsl:if test="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_q]"><xsl:value-of select="normalize-space($metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_q]/data)"/></xsl:if></xsl:variable>
						<xsl:variable name="oeuvre_data_r"><xsl:if test="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_r]"><xsl:value-of select="normalize-space($metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_r]/data)"/></xsl:if></xsl:variable>
						<xsl:variable name="oeuvre_data_t"><xsl:if test="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_t]"><xsl:value-of select="normalize-space($metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_t]/data)"/></xsl:if></xsl:variable>
						<xsl:variable name="oeuvre_data_u"><xsl:if test="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_u]"><xsl:value-of select="normalize-space($metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_u]/data)"/></xsl:if></xsl:variable>
							 
						<xsl:choose>
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
							<xsl:when test="string-length($oeuvre_data_g) = 0 and
											string-length($oeuvre_data_c) = 0 and 
											string-length($oeuvre_data_h) = 0 and 
											string-length($oeuvre_data_i) = 0 ">
								
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
						 			<xsl:variable name="oeuvre_data_e">
										<xsl:if test="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_e]">
											<xsl:variable name="nCount" select="count($metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_e]/data)"/>
											<xsl:choose>
												<xsl:when test="$nCount &gt; 1">
													<xsl:for-each select="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_e]/data">
														<xsl:variable name="data_e" select="."/>
															<xsl:value-of select="concat($data_e,';')"/>
													</xsl:for-each>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="concat($metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_e]/data,';')"/>
												</xsl:otherwise>
											</xsl:choose>																														
										</xsl:if>
									</xsl:variable>
										
									<xsl:variable name="oeuvre_data_j">
										<xsl:if test="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_j]">
											<xsl:variable name="nCount" select="count($metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_j]/data)"/>
											<xsl:choose>
												<xsl:when test="$nCount &gt; 1">
													<xsl:for-each select="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_j]/data">
														<xsl:variable name="data_j" select="."/>
															<xsl:value-of select="concat($data_j,';')"/>
													</xsl:for-each>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="concat($metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_j]/data,';')"/>
												</xsl:otherwise>
											</xsl:choose>																														
										</xsl:if>
									</xsl:variable>
									
									
									<xsl:if test="string-length($oeuvre_data_e) &gt; 0 or
											string-length($oeuvre_data_j) &gt; 0 or
											string-length($oeuvre_data_q) &gt; 0">
											
											<xsl:variable name="section2" select="concat(
														$oeuvre_data_e,
														sparnaf:isTrueParenthesis($oeuvre_data_g),
														$oeuvre_data_j
													)"/>
											
											<xsl:if test="$section2">
													<xsl:value-of select="concat('[(', 
																			substring($section2,1,string-length($section2)-1),																	
																		')]')"/>
											</xsl:if>
									</xsl:if>
						 		</xsl:variable>
						 		
						 		<xsl:if test="$data_a or $data_b ">
									<xsl:value-of select="concat($data_a,$data_b)"/>
								</xsl:if>
						 	</xsl:when>
						 	<!-- Cas 2
							
								Si $i ou $h sont remplis mais que $g ou $c sont vides : 
								Reprendre les instructions précédentes et ajouter à la fin, séparés par un point et un espace : $h. $i.
						
							-->
						 	<xsl:when test="(string-length($oeuvre_data_i) &gt; 0 or
											 string-length($oeuvre_data_h) &gt; 0) and
											 (string-length($oeuvre_data_g) = 0 or
											  string-length($oeuvre_data_c) = 0)">
								<xsl:variable name="data_a">		
									<xsl:value-of select="normalize-space(
															concat(
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
						 			<xsl:variable name="oeuvre_data_e">
										<xsl:if test="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_e]">
											<xsl:variable name="nCount" select="count($metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_e]/data)"/>
											<xsl:choose>
												<xsl:when test="$nCount &gt; 1">
													<xsl:for-each select="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_e]/data">
														<xsl:variable name="data_e" select="."/>
															<xsl:value-of select="concat($data_e,';')"/>
													</xsl:for-each>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="concat($metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_e]/data,';')"/>
												</xsl:otherwise>
											</xsl:choose>																														
										</xsl:if>
									</xsl:variable>
										
									<xsl:variable name="oeuvre_data_j">
										<xsl:if test="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_j]">
											<xsl:variable name="nCount" select="count($metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_j]/data)"/>
											<xsl:choose>
												<xsl:when test="$nCount &gt; 1">
													<xsl:for-each select="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_j]/data">
														<xsl:variable name="data_j" select="."/>
															<xsl:value-of select="concat($data_j,';')"/>
													</xsl:for-each>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="concat($metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_j]/data,';')"/>
												</xsl:otherwise>
											</xsl:choose>																														
										</xsl:if>
									</xsl:variable>
									
									
									<xsl:if test="string-length($oeuvre_data_e) &gt; 0 or
											string-length($oeuvre_data_j) &gt; 0 or
											string-length($oeuvre_data_q) &gt; 0">
											
										<xsl:variable name="section2" select="concat(
														$oeuvre_data_e,
														sparnaf:isTrueParenthesis($oeuvre_data_g),
														$oeuvre_data_j
													)"/>
											
										<xsl:if test="$section2">
											<xsl:value-of select="concat('[(', 
																		substring($section2,1,string-length($section2)-1),																	
																		')]')"/>
										</xsl:if>
									</xsl:if>
								</xsl:variable>						 	
						 	</xsl:when>	
						 	<!-- Cas 3
						 		S i $g ou $c ne sont pas vides :   $a. $g. $c. $i. $h. $r. $n. $k. $p. $t . $u
								(si besoin, voici la signification des sous-champs : 
								$a (titre), 
								$c (Titre original de l'oeuvre), 
								$e (qualificatif), 
								$g (Auteur du thème adapté), 
								$h (Numéro de partie), 
								$i (titre de partie), 
								$j (année), 
								$k (cat.thématique), 
								$n (n° d'ordre), 
								$p (opus), 
								$q (version), 
								$r (instrumentation),  
								$t (tonalité), 
								$u (surnom).

								c- Elément additionnel présent dans la notice de la partition
								   Dans la notice UNI5, un qualificatif est parfois ajouté à la suite du titre uniforme musical en 500$w. 
								   Lorsque c’est le cas, l’ajouter dans la variante de titre, à la suite des autres formes.:
						 	 -->	
						 	 <xsl:when test="string-length($oeuvre_data_g) &gt; 0 or
											  string-length($oeuvre_data_c) &gt; 0">
								<xsl:value-of select="concat('[',
														sparnaf:isTrue($oeuvre_data_a), 
														sparnaf:isTrue($oeuvre_data_g),
														sparnaf:isTrue($oeuvre_data_c),
														sparnaf:isTrue($qualificatif),
														sparnaf:isTrue($oeuvre_data_i),
														sparnaf:isTrue($oeuvre_data_h),
														sparnaf:isTrue($oeuvre_data_r),
														sparnaf:isTrue($oeuvre_data_n),
														sparnaf:isTrue($oeuvre_data_k),
														sparnaf:isTrue($oeuvre_data_p),
														sparnaf:isTrue($oeuvre_data_t),
														sparnaf:isTrue($oeuvre_data_u),														
														']')"/>						 	 
						 	 </xsl:when>				 	
						</xsl:choose>
					</xsl:when>
					
				</xsl:choose>
				
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
		<xsl:if test="$valeur !=''">
			<xsl:for-each select="$valeur">
				<xsl:variable name="data" select="."/>
				<xsl:value-of select="concat($data,';')"/>
			</xsl:for-each>
		</xsl:if>
		
	</xsl:function>

</xsl:stylesheet>