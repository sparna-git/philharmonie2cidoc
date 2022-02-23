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

	<!-- AIC14 -->
	<xsl:param name="TUM_DIR">../input/tum</xsl:param>
	<xsl:param name="AIC14_file" select="document(concat($TUM_DIR,'/', 'ExportTUM.xml'))/NOTICES" />

	<!-- Languages -->
	<xsl:param name="SHARED_XML_DIR">.</xsl:param>
	<xsl:param name="language_codes" select="document(concat($SHARED_XML_DIR,'/', 'languages-codes.xml'))/languages/language" />
	
	<!-- Call sources files RDF -->
	<xsl:param name="SHARED_RDF_DIR">../work/controlled_vocabularies_rdf-xml</xsl:param>
	<xsl:param name="Niveau_difficulte" select="document(concat($SHARED_RDF_DIR,'/', 'educational-level.rdf'))/rdf:RDF" />
	<xsl:param name="mimo_vocab" select="document(concat($SHARED_RDF_DIR,'/', 'mimo.rdf'))/rdf:RDF" />
	<xsl:param name="iaml_vocab" select="document(concat($SHARED_RDF_DIR,'/', 'iaml.rdf'))/rdf:RDF" />
	<xsl:param name="rol_vocab" select="document(concat($SHARED_RDF_DIR,'/', 'role.rdf'))/rdf:RDF" />
	
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
		<xsl:param name="typeNotice" />
		<xsl:choose>
			<xsl:when test="$typeNotice='UNI:5'"><xsl:value-of select="concat('https://ark.philharmoniedeparis.fr/ark/49250/',$idReferenceNotice,'#identifier_',$idTypeIdentifier,'_',$idIdentifier)" /></xsl:when>
			<xsl:when test="$typeNotice='UNI:45'"><xsl:value-of select="concat('/identifier_',$idTypeIdentifier,'_',$idIdentifier)"/></xsl:when>
		</xsl:choose>
		
	</xsl:function>
	
	<!-- URI Title -->
	<xsl:function name="mus:URI-Title">
		<xsl:param name="idReferenceNotice" />
		<xsl:param name="idSequence" />
		<xsl:param name="typeNotice" />
		<xsl:param name="idNotice" />
		<xsl:choose>
			<xsl:when test="$typeNotice='UNI:5'"><xsl:value-of select="concat(mus:URI-Publication_Expression($idReferenceNotice),'#title-statement_',$idSequence)" /></xsl:when>
			<xsl:when test="$typeNotice='UNI:45'"><xsl:value-of select="concat(mus:URI-Publication_Expression_Fragment($idNotice,$idReferenceNotice),'/title-statement_',$idSequence)" /></xsl:when>
		</xsl:choose>
		
	</xsl:function>
	
	<!-- URI Title Parallel-->
	<xsl:function name="mus:URI-Title_parallel">
		<xsl:param name="idReferenceNotice" />
		<xsl:param name="idSequence" />
		<xsl:param name="typeNotice" />
		<xsl:param name="idNotice" />
		<xsl:choose>
			<xsl:when test="$typeNotice='UNI:5'"><xsl:value-of select="concat(mus:URI-Publication_Expression($idReferenceNotice),'#title-parallel_',$idSequence)" /></xsl:when>
			<xsl:when test="$typeNotice='UNI:45'"><xsl:value-of select="concat(mus:URI-Publication_Expression_Fragment($idNotice,$idReferenceNotice),'/title-parallel_',$idSequence)" /></xsl:when>
		</xsl:choose>		
	</xsl:function>
	
	<!-- URI Title Variant -->
	<xsl:function name="mus:URI-Title_variant">
		<xsl:param name="idReferenceNotice" />
		<xsl:param name="idSequence" />
		<xsl:param name="typeNotice" />
		<xsl:param name="idNotice" />
		<xsl:choose>
			<xsl:when test="$typeNotice='UNI:5'"><xsl:value-of select="concat(mus:URI-Publication_Expression($idReferenceNotice),'#title-variant_',$idSequence)" /></xsl:when>
			<xsl:when test="$typeNotice='UNI:45'"><xsl:value-of select="concat(mus:URI-Publication_Expression_Fragment($idNotice,$idReferenceNotice),'/title-variant_',$idSequence)" /></xsl:when>
		</xsl:choose>		
	</xsl:function>
	
	<!-- URI Responsibility -->
	<xsl:function name="mus:URI-Responsability">
		<xsl:param name="idReferenceNotice" />
		<xsl:param name="idSequence" />
		<xsl:param name="typeNotice" />
		<xsl:param name="idNotice" />
		<xsl:choose>
			<xsl:when test="$typeNotice='UNI:5'"><xsl:value-of select="concat(mus:URI-Publication_Expression($idReferenceNotice),'#responsibility_',$idSequence)" /></xsl:when>
			<xsl:when test="$typeNotice='UNI:45'"><xsl:value-of select="concat(mus:URI-Publication_Expression_Fragment($idNotice,$idReferenceNotice),'/responsibility_',$idSequence)" /></xsl:when>
		</xsl:choose>		
	</xsl:function>
	
	<!-- URI Edition Statement-->
	<xsl:function name="mus:URI-Edition_Statement">
		<xsl:param name="idReferenceNotice" />
		<xsl:param name="idSequence"/>
		<xsl:param name="typeNotice" />
		<xsl:param name="idNotice" />
		<xsl:choose>
			<xsl:when test="$typeNotice='UNI:5'"><xsl:value-of select="concat(mus:URI-Publication_Expression($idReferenceNotice),'#edition_',$idSequence)" /></xsl:when>
			<xsl:when test="$typeNotice='UNI:45'"><xsl:value-of select="concat(mus:URI-Publication_Expression_Fragment($idNotice,$idReferenceNotice),'/edition_',$idSequence)" /></xsl:when>
		</xsl:choose>		
	</xsl:function>
	
	<!-- URI Format-->
	<xsl:function name="mus:URI-Format">
		<xsl:param name="idReferenceNotice" />
		<xsl:param name="idSequence"/>
		<xsl:param name="typeNotice" />
		<xsl:param name="idNotice" />
		<xsl:choose>
			<xsl:when test="$typeNotice='UNI:5'"><xsl:value-of select="concat(mus:URI-Publication_Expression($idReferenceNotice),'#format_',$idSequence)" /></xsl:when>
			<xsl:when test="$typeNotice='UNI:45'"><xsl:value-of select="concat(mus:URI-Publication_Expression_Fragment($idNotice,$idReferenceNotice),'/format_',$idSequence)" /></xsl:when>
		</xsl:choose>
	</xsl:function>
	
	<!-- URI Publication-->
	<xsl:function name="mus:URI-Publication">
		<xsl:param name="idReferenceNotice" />
		<xsl:param name="idSequence"/>
		<xsl:param name="typeNotice" />
		<xsl:param name="idNotice" />
		<xsl:choose>
			<xsl:when test="$typeNotice='UNI:5'"><xsl:value-of select="concat(mus:URI-Publication_Expression($idReferenceNotice),'#publication_',$idSequence)" /></xsl:when>
			<xsl:when test="$typeNotice='UNI:45'"><xsl:value-of select="concat(mus:URI-Publication_Expression_Fragment($idNotice,$idReferenceNotice),'/publication_',$idSequence)" /></xsl:when>
		</xsl:choose>		
	</xsl:function>
	
	
	<!-- URI Publication Event-->
	<xsl:function name="mus:URI-Publication_Event">
		<xsl:param name="idReferenceNotice" />
		<xsl:value-of select="concat('https://ark.philharmoniedeparis.fr/ark/49250/',$idReferenceNotice,'#event')" />
	</xsl:function>
	
	<!-- URI Publication Event - Activity -->
	<xsl:function name="mus:URI-Publication_Event_Activity">
		<xsl:param name="idReferenceNotice" />
		<xsl:param name="idPersonne" />
		<xsl:param name="idfunction" />
		<xsl:value-of select="concat(mus:URI-Publication_Event($idReferenceNotice),'/activity_',$idPersonne,'_',$idfunction)" />
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
		<xsl:param name="typeNotice" />
		<xsl:param name="idNotice" />
		<xsl:choose>
			<xsl:when test="$typeNotice='UNI:5'"><xsl:value-of select="concat(mus:URI-Publication_Expression($idReferenceNotice),'#casting_',$idCasting)" /></xsl:when>
			<xsl:when test="$typeNotice='UNI:45'"><xsl:value-of select="concat(mus:URI-Publication_Expression_Fragment($idNotice,$idReferenceNotice),'/casting_',$idCasting)" /></xsl:when>
		</xsl:choose>		
	</xsl:function>
	
	<!-- URI Publication_Expression Casting Detail -->
	<xsl:function name="mus:URI-Casting_Detail">
		<xsl:param name="idReferenceNotice" />
		<xsl:param name="idCasting" />
		<xsl:param name="idCastingDetail" />
		<xsl:param name="typeNotice" />
		<xsl:param name="idNotice" />
		<xsl:choose>
			<xsl:when test="$typeNotice='UNI:5'"><xsl:value-of select="concat(mus:URI-Casting($idReferenceNotice,$idCasting,'UNI:5',''),'/detail_',$idCastingDetail)" /></xsl:when>
			<xsl:when test="$typeNotice='UNI:45'"><xsl:value-of select="concat(mus:URI-Publication_Expression_Fragment($idNotice,$idReferenceNotice),'/casting_',$idCasting,'/detail_',$idCastingDetail)" /></xsl:when>
		</xsl:choose>		
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
		<xsl:value-of select="concat('https://ark.philharmoniedeparis.fr/ark/49250/',$idReference)"/>
	</xsl:function>
	
	<xsl:function name="mus:role_vocab">
		<xsl:param name="idfunction"/>
		<xsl:variable name="source" select="$rol_vocab/rdf:Description[
										skos:notation[@rdf:datatype='https://ark.philharmoniedeparis.fr/ark/49250/type/philharmonie']=$idfunction]/@rdf:about"/>		
		<xsl:choose>
			<xsl:when test="count($source)=1">
				<xsl:value-of select="$source"/>
			</xsl:when>
			<xsl:when test="count($source) &gt; 1">
				<xsl:message>L'id: <xsl:value-of select="$idfunction"/>, a trouvé deux valeurs, on prendra seulement 1.</xsl:message>
				<xsl:value-of select="$source[1]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>
					Warning!!, L'id: <xsl:value-of select="$idfunction"/>, ne se trouve pas dans la source d'information du vocabularies. 
				</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	
	<!-- URI Thesaurus ? Valider -->
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
						<xsl:variable name="oeuvre_data_a"><xsl:if test="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_a]"><xsl:value-of select="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_a]/normalize-space(data)"/></xsl:if></xsl:variable>
						<xsl:variable name="oeuvre_data_c"><xsl:if test="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_c]"><xsl:value-of select="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_c]/normalize-space(data)"/></xsl:if></xsl:variable>
						
						<xsl:variable name="oeuvre_data_g"><xsl:if test="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_g]"><xsl:value-of select="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_g]/normalize-space(data)"/></xsl:if></xsl:variable>
							
						<xsl:variable name="oeuvre_data_h"><xsl:if test="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_h]"><xsl:value-of select="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_h]/normalize-space(data)"/></xsl:if></xsl:variable>
						<xsl:variable name="oeuvre_data_i"><xsl:if test="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_i]"><xsl:value-of select="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_i]/normalize-space(data)"/></xsl:if></xsl:variable>
						
						<xsl:variable name="oeuvre_data_k"><xsl:if test="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_k]"><xsl:value-of select="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_k]/data"/></xsl:if></xsl:variable>
						
						<xsl:variable name="oeuvre_data_n"><xsl:if test="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_n]"><xsl:value-of select="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_n]/normalize-space(data)"/></xsl:if></xsl:variable>
						<xsl:variable name="oeuvre_data_p"><xsl:if test="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_p]"><xsl:value-of select="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_p]/normalize-space(data)"/></xsl:if></xsl:variable>
						<xsl:variable name="oeuvre_data_q"><xsl:if test="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_q]"><xsl:value-of select="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_q]/normalize-space(data)"/></xsl:if></xsl:variable>
						<xsl:variable name="oeuvre_data_r"><xsl:if test="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_r]"><xsl:value-of select="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_r]/normalize-space(data)"/></xsl:if></xsl:variable>
						<xsl:variable name="oeuvre_data_t"><xsl:if test="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_t]"><xsl:value-of select="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_t]/normalize-space(data)"/></xsl:if></xsl:variable>
						<xsl:variable name="oeuvre_data_u"><xsl:if test="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_u]"><xsl:value-of select="$metadata/SOUSCHAMP[@UnimarcSubfield=$Balise_u]/normalize-space(data)"/></xsl:if></xsl:variable>
							 
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
	
	<!-- function for the validate if the variable is not empty -->
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
		<xsl:variable name="inputNiveau" select="normalize-space(substring-after(substring-before($idText,' dans'),'Niveau '))"/>
		<xsl:variable name="match_niveau" select="$Niveau_difficulte/skos:Concept[skos:altLabel=$inputNiveau]/@rdf:about"/>
		<xsl:choose>
			<xsl:when test="count($match_niveau) = 1">
				<xsl:value-of select="$match_niveau"/>
			</xsl:when>
			<xsl:when test="count($match_niveau) &gt; 1">
				<xsl:message>L'information: <xsl:value-of select="$inputNiveau"/> à trouvé 2 resultat, On prends le premier resultat. </xsl:message>
				<xsl:value-of select="$match_niveau[1]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>Le contenu du niveua: <xsl:value-of select="$idText"/>, ne se trouve pas dans le réferentiel.</xsl:message>
			</xsl:otherwise>
		</xsl:choose>	
	</xsl:function>

	<!-- Enlever à la fin Mimo RDF -->
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
			<!-- not match and finding the similarity value mimo or iaml		
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
			-->				
			<xsl:otherwise><xsl:value-of select="$idMedium_input"/></xsl:otherwise>
		</xsl:choose>	
	</xsl:function>
	
	
	<!-- funtion qui retourner la valeur de type numeric et 
		 transformer les proprietes qui arrivent avec:
			- la valeur NaN 
			- De type Alpha				
		-->
	<xsl:function name="sparnaf:isNumber">
		<xsl:param name="Valeur"/>
		<xsl:variable name="result" select="0"/>
		<xsl:choose>
			<xsl:when test="string($Valeur) = 'NaN'">
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
	
	<!-- chercher l'instrument ou la voix -->
	<xsl:function name="mus:medium">
		<xsl:param name="mots_medium"/>
		<xsl:variable name="mot_medium">
			<xsl:choose>
				<xsl:when test="contains($mots_medium,'_')">
					<xsl:value-of select="normalize-space(translate($mots_medium,'_',' '))"/>										
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space($mots_medium)"/>
				</xsl:otherwise>
			</xsl:choose>		
		</xsl:variable>
		<xsl:variable name="mimo_medium_simple" select="mus:mimo_vocabulary_simple($mot_medium)"/>
		<xsl:variable name="iaml_medium_simple" select="mus:iaml_vocabulary_simple($mot_medium)"/>
		<xsl:choose>
			<xsl:when test="$mimo_medium_simple and $iaml_medium_simple">
				<xsl:value-of select="$mimo_medium_simple"/>
			</xsl:when>
			<xsl:when test="$mimo_medium_simple and not($iaml_medium_simple)">
				<xsl:value-of select="$mimo_medium_simple"/>
			</xsl:when>
			<xsl:when test="not($mimo_medium_simple) and $iaml_medium_simple">
				<xsl:value-of select="$iaml_medium_simple"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>Le medium : <xsl:value-of select="$mots_medium"/> ,ne se trouve pas dans l'information de vocabularie mimo ou iaml. </xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="mus:mimo_vocabulary_simple">
		<xsl:param name="mots_instrument"/>
		<xsl:variable name="mimo_resultat" select="$mimo_vocab/skos:Concept[lower-case(skos:prefLabel[@xml:lang='fr'])=$mots_instrument]/@rdf:about"/>
		<xsl:choose>
			<xsl:when test="count($mimo_resultat) = 1"><xsl:value-of select="$mimo_resultat"/></xsl:when>
			<xsl:when test="count($mimo_resultat) &gt; 1">
				<xsl:message>Le medium: <xsl:value-of select="$mots_instrument"/> à trouvé 2 resultat, On prends le premier resultat. </xsl:message>
				<xsl:value-of select="$mimo_resultat[1]"/>
			</xsl:when>
		</xsl:choose>			
	</xsl:function>
	
	<xsl:function name="mus:iaml_vocabulary_simple">
		<xsl:param name="mots_instrument"/>
		<xsl:variable name="ialm_resultat" select="$iaml_vocab/skos:Concept[skos:prefLabel[@xml:lang='fr']=$mots_instrument]/@rdf:about"/>		
		<xsl:choose>
			<xsl:when test="count($ialm_resultat) = 1"><xsl:value-of select="$ialm_resultat"/></xsl:when>
			<xsl:when test="count($ialm_resultat) &gt; 1">
				<xsl:message>Le medium: <xsl:value-of select="$mots_instrument"/> à trouvé 2 resultat, On prends le premier resultat. </xsl:message>
				<xsl:value-of select="$ialm_resultat[1]"/>
			</xsl:when>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="mus:chercher_medium_complex">
		<xsl:param name="mots_medium"/>
		<xsl:variable name="mot_medium">
			<xsl:choose>
				<xsl:when test="contains($mots_medium,'_')">
					<xsl:value-of select="normalize-space(translate($mots_medium,'_',' '))"/>										
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space($mots_medium)"/>
				</xsl:otherwise>
			</xsl:choose>		
		</xsl:variable>
		
		<!-- Mimo -->
		<xsl:variable name="mimo_vocabulary" select="$mimo_vocab/skos:Concept[lower-case(skos:prefLabel[@xml:lang='fr'])=tokenize($mot_medium,' ')[1]]/@rdf:about"/>
		
		<!-- ialm -->
		<xsl:variable name="iaml_vocabulary" select="$iaml_vocab/skos:Concept[skos:prefLabel[@xml:lang='fr']=tokenize($mot_medium,' ')[1]]/@rdf:about"/>
		
		<xsl:choose>
			<xsl:when test="$mimo_vocabulary and $iaml_vocabulary">
				<xsl:value-of select="$mimo_vocabulary[1]"/>
			</xsl:when>
			<xsl:when test="$mimo_vocabulary and $iaml_vocabulary=''">
				<xsl:value-of select="$mimo_vocabulary[1]"/>
			</xsl:when>
			<xsl:when test="$mimo_vocabulary='' and $iaml_vocabulary!=''">
				<xsl:value-of select="$iaml_vocabulary[1]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>Le medium : <xsl:value-of select="$mots_medium"/> ,ne se trouve pas dans l'information de vocabularie mimo ou iaml. </xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<!-- funtion utilisé par le casting alternatif -->
	<xsl:function name="sparnaf:split_text">
		<xsl:param name="text"/>
		<xsl:variable name="text_clean" select="translate($text,',.()','')"/>
		<xsl:if test="contains($text_clean,' ou ') and (index-of(tokenize($text_clean,' '),'ou') &gt; 1)">
			<xsl:for-each select="tokenize($text_clean,' ou ')">
				<xsl:variable name="instrument" select="normalize-space(.)"/>
				<xsl:choose>
					<xsl:when test="string-length(mus:medium(lower-case($instrument))) &gt; 1">
						<xsl:value-of select="$instrument"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="split2">
							<xsl:for-each select="tokenize($instrument,' ')">
								<xsl:variable name="instrument_split_space" select="."/>
								<xsl:variable name="existe_catalogo" select="mus:medium(lower-case($instrument_split_space))"/>
								<xsl:if test="string-length($existe_catalogo) &gt; 0">
									<xsl:value-of select="$instrument_split_space"/>
								</xsl:if>
							</xsl:for-each>
						</xsl:variable>
						<xsl:if test="$split2">
							<xsl:value-of select="$split2"/>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:if>		
	</xsl:function>
	
	
	<!-- translation language -->
	<xsl:function name="mus:Lookup_Language_3LettersCode">
		<xsl:param name="idCode" />
		<xsl:variable name="language" select="$language_codes[
			a3b = $idCode or
			a3t = $idCode
		]"/>
		<xsl:choose>
			<xsl:when test="count($language) = 0">
				<xsl:message>Warning : cannot find language "<xsl:value-of select="$idCode" /></xsl:message>
			</xsl:when>
			<xsl:when test="count($language) &gt; 1">
				<xsl:message>Warning : find <xsl:value-of select="count($language)" /> languages with code "<xsl:value-of select="$idCode" /> - Taking first one.</xsl:message>
				<xsl:value-of select="concat('http://lexvo.org/id/iso639-3/',$language[1]/a3t)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('http://lexvo.org/id/iso639-3/',$language[1]/a3t)"/>
			</xsl:otherwise>
		</xsl:choose>	
	</xsl:function>
	
</xsl:stylesheet>