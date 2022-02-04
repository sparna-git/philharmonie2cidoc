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
	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
>

	<!-- Call sources files XML -->
	<xsl:param name="SHARED_XML_DIR">.</xsl:param>
	
	<!-- AIC14 -->
	<xsl:param name="AIC14_file" select="document(concat($SHARED_XML_DIR,'/', 'ExportTUM-pretty.xml'))/NOTICES" />
	
	<!-- Call sources files RDF -->
	<xsl:param name="SHARED_RDF_DIR">../07-CONTROLLED_VOCABULARIES_RDF-XML</xsl:param>
	<xsl:param name="Niveau_difficulte" select="document(concat($SHARED_RDF_DIR,'/', 'educational-level.rdf'))/rdf:RDF" />
	<xsl:param name="mimo_vocab" select="document(concat($SHARED_RDF_DIR,'/', 'mop-mimo.rdf'))/rdf:RDF" />
	<xsl:param name="iaml_vocab" select="document(concat($SHARED_RDF_DIR,'/', 'mop-iaml.rdf'))/rdf:RDF" />
	
	
	<!-- URIS Class -->

	<!-- URI Publication Expression -->
	<xsl:function name="mus:URI-Publication_Expression">
		<xsl:param name="idReferenceNotice" />
		<xsl:value-of select="concat('https://ark.philharmoniedeparis.fr/ark/49250/',$idReferenceNotice)" />
	</xsl:function>
	
	<!-- URI Identifier -->
	<xsl:function name="mus:URI-Identifier">
		<xsl:param name="idReferenceNotice" />
		<xsl:param name="idIdentifier" />
		<xsl:param name="idTypeIdentifier" />		
		<xsl:value-of select="concat('https://ark.philharmoniedeparis.fr/ark/49250/',$idReferenceNotice,'#identifier_',$idTypeIdentifier,'_',$idIdentifier)" />
	</xsl:function>
	
	<!-- URI Title -->
	<xsl:function name="mus:URI-Title">
		<xsl:param name="idReferenceNotice" />
		<xsl:param name="idSequence" />
		<xsl:value-of select="concat(mus:URI-Publication_Expression($idReferenceNotice),'#title-statement_',$idSequence)" />
	</xsl:function>
	
	<!-- URI Title Parallel-->
	<xsl:function name="mus:URI-Title_parallel">
		<xsl:param name="idReferenceNotice" />
		<xsl:param name="idSequence" />
		<xsl:value-of select="concat(mus:URI-Publication_Expression($idReferenceNotice),'#title-parallel_',$idSequence)" />
	</xsl:function>
	
	<!-- URI Title Variant -->
	<xsl:function name="mus:URI-Title_variant">
		<xsl:param name="idReferenceNotice" />
		<xsl:param name="idSequence" />
		<xsl:value-of select="concat(mus:URI-Publication_Expression($idReferenceNotice),'#title-variant_',$idSequence)" />
	</xsl:function>
	
	<!-- URI Responsibility -->
	<xsl:function name="mus:URI-Responsability">
		<xsl:param name="idReferenceNotice" />
		<xsl:param name="idSequence" />
		<xsl:value-of select="concat(mus:URI-Publication_Expression($idReferenceNotice),'#responsibility_',$idSequence)" />
	</xsl:function>
	
	<!-- URI Edition Statement-->
	<xsl:function name="mus:URI-Edition_Statement">
		<xsl:param name="idReferenceNotice" />
		<xsl:param name="idSequence"/>
		<xsl:value-of select="concat(mus:URI-Publication_Expression($idReferenceNotice),'#edition_',$idSequence)" />
	</xsl:function>
	
	<!-- URI Format-->
	<xsl:function name="mus:URI-Format">
		<xsl:param name="idReferenceNotice" />
		<xsl:param name="idSequence"/>
		<xsl:value-of select="concat(mus:URI-Publication_Expression($idReferenceNotice),'#format_',$idSequence)" />
	</xsl:function>
	
	<!-- URI Publication-->
	<xsl:function name="mus:URI-Publication">
		<xsl:param name="idReferenceNotice" />
		<xsl:param name="idSequence"/>
		<xsl:value-of select="concat(mus:URI-Publication_Expression($idReferenceNotice),'#publication_',$idSequence)" />
	</xsl:function>
	
	
	<!-- URI Publication Event-->
	<xsl:function name="mus:URI-Publication_Event">
		<xsl:param name="idReferenceNotice" />
		<xsl:value-of select="concat('https://ark.philharmoniedeparis.fr/ark/49250/',$idReferenceNotice,'#event')" />
	</xsl:function>
	
	<!-- URI Publication_Expression_Fragment -->
	<xsl:function name="mus:URI-Publication_Expression_Fragment">
		<xsl:param name="idReferenceNotice" />
		<xsl:param name="idReferencePartition" />
		<xsl:value-of select="concat(mus:URI-Publication_Expression($idReferenceNotice),'#subpart_',$idReferencePartition)" />
	</xsl:function>
	
	<!-- URI Publication_Expression Casting -->
	<xsl:function name="mus:URI-Casting">
		<xsl:param name="idReferenceNotice" />
		<xsl:param name="idCasting" />
		<xsl:value-of select="concat(mus:URI-Publication_Expression($idReferenceNotice),'#casting_',$idCasting)" />
	</xsl:function>
	
	<!-- URI Publication_Expression Casting Detail -->
	<xsl:function name="mus:URI-Casting_Detail">
		<xsl:param name="idReferenceNotice" />
		<xsl:param name="idCasting" />
		<xsl:param name="idCastingDetail" />
		<xsl:value-of select="concat(mus:URI-Casting($idReferenceNotice,$idCasting),'/detail_',$idCastingDetail)" />
	</xsl:function>
	
	
	<!-- URI Activity -->
	<xsl:function name="mus:URI-Activity">
		<xsl:param name="idReferenceNotice" />
		<xsl:param name="idActivity" />
		<xsl:value-of select="concat(mus:URI-Publication_Event($idReferenceNotice),'/activity/',$idActivity)" />
	</xsl:function>
	
	
	<!-- URI Actor Function -->
	<xsl:function name="mus:URI-Actor_Function">
		<xsl:param name="idReferenceNotice" />
		<xsl:param name="idActivity" />
		<xsl:param name="idFunction" />
		<xsl:value-of select="concat(mus:URI-Activity($idReferenceNotice,$idActivity),'/function/',$idFunction)" />
	</xsl:function>
	
	
	<!-- URI Personne -->
	<xsl:function name="mus:reference_personne">
		<xsl:param name="idReference" />
		<xsl:value-of select="concat('https://ark.philharmoniedeparis.fr/ark/49250/',$idReference)"/>
	</xsl:function>
	
	<!-- URI Collectivité -->
	<xsl:function name="mus:reference_collectivite">
		<xsl:param name="idReference" />
		<xsl:value-of select="concat('http://data.phlharmonie/AIC2/',$idReference)"/>
	</xsl:function>
	
	
	<!-- URI Thesaurus -->
	<xsl:function name="mus:reference_thesaurus">
		<xsl:param name="idReference" />
		<xsl:value-of select="concat('https://ark.philharmoniedeparis.fr/ark/49250/',$idReference)"/>
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
	
	<!-- function for the validate if the variable not empty -->
	<xsl:function name="sparnaf:isTrue">
		<xsl:param name="valeur"/>
		<xsl:choose>
			<xsl:when test="$valeur !='' or string-length($valeur) &gt; 0">
				<xsl:value-of select="concat($valeur,'. ')"/>
			</xsl:when>
		</xsl:choose>
	</xsl:function>
	
	<!-- building the value concated with the parentheses -->
	<xsl:function name="sparnaf:isTrueParenthesis">
		<xsl:param name="valeur"/>
		<xsl:if test="$valeur !=''">
			<xsl:for-each select="$valeur">
				<xsl:variable name="data" select="."/>
				<xsl:value-of select="concat($data,';')"/>
			</xsl:for-each>
		</xsl:if>		
	</xsl:function>


	<xsl:function name="mus:DataCastingDetail_a">
		<xsl:param name="data"/>
		<xsl:value-of select="normalize-space(substring-before($data,'('))"/>		
	</xsl:function>
	
	<xsl:function name="mus:NoInstrument">
		<xsl:param name="data"/>
		<xsl:variable name="Valeur_str_int" select="normalize-space(substring-before(substring-after($data,'('),')'))"/>
		<xsl:choose>
			<xsl:when test="number($Valeur_str_int)">
				<xsl:value-of select="$Valeur_str_int"/>
			</xsl:when>
			<xsl:when test="$Valeur_str_int='9+'">
				<xsl:value-of select="99"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>L'information <xsl:value-of select="$data"/>, ne contien pas un No d'Instrument. </xsl:message>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:function>
	
	<xsl:function name="mus:NiveauDifficulte">
		<xsl:param name="idText"/>
		<xsl:for-each select="$Niveau_difficulte/skos:Concept/skos:altLabel">
			<xsl:if test="contains($idText,normalize-space(.))">
				<xsl:variable name="idCle_text" select="normalize-space(
														substring($idText,
																  string-length(substring-before($idText,normalize-space(.)))+1,
																  string-length(normalize-space(.))+1
																  )
																)"/>
				<xsl:choose>
					<xsl:when test="normalize-space(.)=$idCle_text">
						<xsl:value-of select="normalize-space($Niveau_difficulte/skos:Concept[
												skos:altLabel=$idCle_text
												]/skos:prefLabel)"/>
						
					</xsl:when>	
					<xsl:otherwise>
						<xsl:message>Le contenu du niveua du text <xsl:value-of select="$idText"/>, ne se trouve pas dans le réferentiel.</xsl:message>
					</xsl:otherwise>				
				</xsl:choose>
			</xsl:if>					
		</xsl:for-each>
	</xsl:function>

	<!-- Mimo RDF -->
	<xsl:function name="mus:medium_vocabulary">
		<xsl:param name="idMedium"/>
		<xsl:variable name="idMedium_input">
			<xsl:choose>
				<xsl:when test="contains($idMedium,'_')"><xsl:value-of select="translate($idMedium,'_',' ')"/></xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$idMedium"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<!-- Match -->
			<xsl:when test="$mimo_vocab/skos:Concept[lower-case(skos:prefLabel[@xml:lang='fr'])=$idMedium_input]"><xsl:value-of select="$mimo_vocab/skos:Concept[lower-case(skos:prefLabel[@xml:lang='fr'])=$idMedium_input]/@rdf:about"/></xsl:when>
			<xsl:when test="$iaml_vocab/skos:Concept[skos:prefLabel[@xml:lang='fr']=lower-case($idMedium_input)]"><xsl:value-of select="$iaml_vocab/skos:Concept[skos:prefLabel[@xml:lang='fr']=$idMedium_input]/@rdf:about"/></xsl:when>
			<!-- not match and finding the similarity value mimo or iaml-->			
			<xsl:when test="not($mimo_vocab/skos:Concept[lower-case(skos:prefLabel[@xml:lang='fr'])=$idMedium_input]) and
						not($iaml_vocab/skos:Concept[skos:prefLabel[@xml:lang='fr']=$idMedium_input])">
				<xsl:variable name="mimo_data_similarity">
					<xsl:for-each select="$mimo_vocab/skos:Concept/skos:prefLabel[@xml:lang='fr']">
						<xsl:variable name="idPrefLabel" select="normalize-space(.)"/>
						<xsl:if test="contains($idMedium_input,$idPrefLabel)">
							<xsl:message>ValidarContainer MIMO: <xsl:value-of select="$idMedium_input"/>'-'<xsl:value-of select="$idPrefLabel"/></xsl:message>
						</xsl:if>															
					</xsl:for-each>
				</xsl:variable>
				<xsl:if test="string-length($mimo_data_similarity)=0">
					<xsl:message>ValidarContainer IALM:</xsl:message>
					<xsl:for-each select="$iaml_vocab/skos:Concept/skos:prefLabel[@xml:lang='fr']">
						<xsl:variable name="idPrefLabel" select="normalize-space(.)"/>						
						<xsl:choose>
							<xsl:when test="lower-case($idMedium_input)=$idPrefLabel">
								<xsl:message>ValidarContainer equal IALM: <xsl:value-of select="$idMedium_input"/>'-'<xsl:value-of select="$idPrefLabel"/></xsl:message>
								<xsl:value-of select="$iaml_vocab/skos:Concept[skos:prefLabel[@xml:lang='fr']=$idMedium_input]/@rdf:about"/>
							</xsl:when>
							<xsl:when test="contains(lower-case($idMedium_input),$idPrefLabel)">
								<xsl:message>ValidarContainer IALM: <xsl:value-of select="$idMedium_input"/>'-'<xsl:value-of select="$idPrefLabel"/></xsl:message>
							</xsl:when>
						</xsl:choose>
					</xsl:for-each>
				</xsl:if>
			</xsl:when>			
			<xsl:otherwise><xsl:value-of select="$idMedium_input"/></xsl:otherwise>
		</xsl:choose>	
	</xsl:function>
	
	<xsl:function name="mus:casting_alternatif_note">
		<xsl:param name="text"/>
		<xsl:if test="contains($text,'ou')">
			<xsl:variable name="npositionWord" select="index-of(tokenize($text,' '),'ou')"/>
			<xsl:choose>
				<xsl:when test="$npositionWord = 1">
					<xsl:value-of select="0"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:message>Mots id: <xsl:value-of select="$text"/></xsl:message>
					<xsl:for-each select="tokenize($text,'ou ')">
						<xsl:variable name="mots" select="normalize-space(.)"/>
						<xsl:choose>
							<xsl:when test="contains($mots,'(') or contains($mots,')')">
								<xsl:message>Le mots trouve n'est pas valide pour le traiter: <xsl:value-of select="$mots"/> 
							</xsl:message></xsl:when>
							<xsl:otherwise>
							<!--  <xsl:value-of select="concat($mots,',')"/> -->
								<xsl:choose>
									<xsl:when test="not(contains($mots,'et'))">
										<xsl:message>Mots <xsl:value-of select="$mots"/>, Valeur trouve: <xsl:value-of select="mus:medium($mots)"/></xsl:message>
									</xsl:when>
									<xsl:when test="contains($mots,'et')">
										<xsl:for-each select="tokenize($mots,'et')">
											<xsl:message>Mots <xsl:value-of select="."/>, Valeur trouve:  <xsl:value-of select="mus:medium(.)"/></xsl:message>
										</xsl:for-each>
									</xsl:when>
								</xsl:choose>																
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>					
		</xsl:if>			
	</xsl:function>
		
	
	<xsl:function name="sparnaf:isNumber">
		<xsl:param name="Valeur"/>
		<xsl:variable name="result" select="0"/>
		<xsl:choose>
			<xsl:when test="string($Valeur) = 'NaN' or string-length($Valeur)=0">
				<xsl:value-of select="number($result)"/>								
			</xsl:when>
			<xsl:when test="(string($Valeur) &gt; 'A' and string($Valeur) &lt; 'Z') or (string($Valeur) &gt; 'a' and string($Valeur) &lt; 'z')">
				<xsl:message>La valeur n'est pas un chiffre <xsl:value-of select="$Valeur"/>.</xsl:message>
				<xsl:value-of select="number($result)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="number($Valeur)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="sparnaf:split_text">
		<xsl:param name="text"/>
		<!-- Tokenize premier validation -->		
		<xsl:variable name="source" select="tokenize($text,'ou')"/>
		<!-- Translate chaque mot, ici saura une space pour embellir -->
		<xsl:variable name="mot_refuser" select="('ou','et',',','.')" as="xsd:string*"/>
		<!-- Nettoyer données -->
		<xsl:variable name="result_split">
			<xsl:for-each select="$source">
				<xsl:variable name="mot" select="normalize-space(.)"/>
				<xsl:variable name="notExist_mot">
					<xsl:for-each select="$mot_refuser">
						<xsl:if test="normalize-space(.) = $mot">
							<xsl:value-of select="'1'"/>
						</xsl:if>
					</xsl:for-each>			
				</xsl:variable>
				<xsl:if test="$notExist_mot != '1'">
					<xsl:value-of select="concat($mot,',')"/>		
				</xsl:if>			
			</xsl:for-each>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$result_split">
				<xsl:value-of select="substring($result_split,1,(string-length($result_split)-1))"/>
			</xsl:when>
		</xsl:choose>		
	</xsl:function>
	
	<xsl:function name="sparnaf:validate_text">
		<xsl:param name="text"/>
		<xsl:choose>
			<xsl:when test="normalize-space($text)">
			
			</xsl:when>
		</xsl:choose>
	</xsl:function>
	
	
	<!-- chercher l'instrument ou la voix -->
	<xsl:function name="mus:medium">
		<xsl:param name="mots_medium"/>
		<xsl:variable name="mimo_medium_simple" select="mus:mimo_vocabulary_simple($mots_medium)"/>
		<xsl:variable name="iaml_medium_simple" select="mus:iaml_vocabulary_simple($mots_medium)"/>
		<xsl:choose>
			<xsl:when test="not($mimo_medium_simple) and not($iaml_medium_simple)">
				<xsl:message>Le medium ne se trouve pas dans l'information de vocabularie <xsl:value-of select="$mots_medium"/></xsl:message>
			</xsl:when>
			<xsl:when test="$mimo_medium_simple">
				<xsl:value-of select="$mimo_medium_simple"/>
			</xsl:when>
			<xsl:when test="$iaml_medium_simple">
				<xsl:value-of select="$mimo_medium_simple"/>
			</xsl:when>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="mus:mimo_vocabulary_simple">
		<xsl:param name="mots_instrument"/>
		<xsl:value-of select="$mimo_vocab/skos:Concept[lower-case(skos:prefLabel[@xml:lang='fr'])=$mots_instrument]/@rdf:about"/>
	</xsl:function>
	
	<xsl:function name="mus:iaml_vocabulary_simple">
		<xsl:param name="mots_instrument"/>
		<xsl:value-of select="$iaml_vocab/skos:Concept[skos:prefLabel[@xml:lang='fr']=$mots_instrument]/@rdf:about"/>
	</xsl:function>
	
	<xsl:function name="mus:mimo_vocabulary_complex">
		<xsl:param name="mots_instrument"/>
		<xsl:choose>
			<xsl:when test="contains($mots_instrument,' ')">
				<xsl:for-each select="1"></xsl:for-each>
			</xsl:when>
		</xsl:choose>
		<xsl:value-of select="$mimo_vocab/skos:Concept[lower-case(skos:prefLabel[@xml:lang='fr'])=$mots_instrument]/@rdf:about"/>
	</xsl:function>
	
</xsl:stylesheet>