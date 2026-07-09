SELECT 
	mdh.lagu_id AS "MATRICULA",
	mdh.mdhi_amleitura AS "REFERENCIA",
	loc.uneg_id AS "GERENCIA",
	une.uneg_nmunidadenegocio AS "NOME UNIDADE",
	lts.ltst_dsleiturasituacao AS "SITUACAO LEITURA",
	hid.hidr_nnhidrometro AS "NR HID.",
	mun.muni_nmmunicipio AS "MUNICIPIO",
	CASE 
	WHEN mun.muni_nmmunicipio IN ('AFONSO CUNHA', 'CHAPADINHA', 'DUQUE BACELAR', 'URBANO SANTOS', 'ACAILANDIA', 'ALTO PARNAIBA',
	'AMARANTE DO MARANHAO', 'ARAME', 'BURITICUPU', 'CIDELANDIA', 'DAVINOPOLIS', 'IMPERATRIZ', 'JOAO LISBOA', 'MONTES ALTOS',
	'RIACHAO', 'S F DO BREJAO', 'SAO PEDRO DA AGUA BRANCA', 'SENADOR LA ROQUE', 'ALCANTARA', 'LUIS DOMINGUES', 'PALMEIRANDIA', 
	'PINHEIRO', 'SAO BENTO', 'GOV. NEWTON BELLO', 'SANTA INES', 'SANTA LUZIA', 'SANTA LUZIA DO PARUA', 'VITORIA MEARIM', 'SAO LUIS',
	'ITAPECURU MIRIM', 'ENTRONCAMENTO', 'BACABEIRA', 'BARREIRINHAS', 'PRIMEIRA CRUZ', 'CANTANHEDE')
        THEN 'SIMULTANEA'
	ELSE 'MANUAL'
	END AS "IMPRESSAO",
	(CASE cost_a1.cstp_id
	WHEN 1	THEN 'REAL'
	WHEN 2	THEN 'AJUSTADO'
	WHEN 3	THEN 'MEDIA DO HIDRÔMETRO'
	WHEN 4	THEN 'INFORMADO'
	WHEN 5	THEN 'NAO MEDIDO'
	WHEN 6	THEN 'ESTIMADO'
	WHEN 7	THEN 'MINIMO FIXADO'
	WHEN 8	THEN 'SEM CONSUMO'
	WHEN 9	THEN 'MEDIA DO IMÓVEL'
	WHEN 10	THEN 'CONSUMO FIXO' 
	WHEN 11	THEN 'CONTRATO DEMANDA'
	ELSE
	   'INDEFINIDO'
	END) AS "TIPO DE CONSUMO",
	lai.ltan_dsleituraanormalidade AS "ANORM LEIT INFORMADA",
	laf.ltan_dsleituraanormalidade AS "ANORM LEIT FATURADA"
	--COUNT(mdh.mdhi_id) AS "QTD"	
		
FROM micromedicao.medicao_historico mdh
	INNER JOIN cadastro.imovel imo ON mdh.lagu_id = imo.imov_id
	INNER JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
	INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
	INNER JOIN cadastro.setor_comercial sec ON imo.stcm_id = sec.stcm_id
	INNER JOIN cadastro.quadra qdr ON qdr.qdra_id = imo.qdra_id
	INNER JOIN micromedicao.rota rot ON rot.rota_id = qdr.rota_id
	INNER JOIN faturamento.faturamento_grupo ftg ON rot.ftgr_id = ftg.ftgr_id
	INNER JOIN cadastro.logradouro_bairro lgb ON lgb.lgbr_id = imo.lgbr_id
	INNER JOIN cadastro.logradouro logr ON lgb.logr_id = logr.logr_id
	INNER JOIN cadastro.bairro bai ON bai.bair_id = lgb.bair_id
	INNER JOIN cadastro.municipio mun ON mun.muni_id = bai.muni_id
	INNER JOIN cadastro.fonte_abastecimento ftb ON ftb.ftab_id = imo.ftab_id
	INNER JOIN atendimentopublico.ligacao_agua_situacao las ON las.last_id = imo.last_id
	INNER JOIN atendimentopublico.ligacao_esgoto_situacao les ON les.lest_id = imo.lest_id
	LEFT JOIN operacional.distrito_operacional dis ON dis.diop_id = qdr.diop_id
	LEFT JOIN cadastro.cliente_imovel cim2 ON cim2.imov_id = imo.imov_id AND cim2.clim_dtrelacaofim IS NULL AND cim2.crtp_id  = 3
	LEFT JOIN cadastro.cliente cli2 ON cli2.clie_id = cim2.clie_id
	LEFT JOIN cadastro.cliente cli3 ON cli3.clie_id = cli2.clie_cdclienteresponsavel
	LEFT JOIN cadastro.logradouro_cep lgc ON lgc.lgcp_id = imo.lgcp_id
	LEFT JOIN cadastro.cep cep ON cep.cep_id = lgc.cep_id
	LEFT JOIN cadastro.logradouro_tipo lgt ON lgt.lgtp_id = logr.lgtp_id
	LEFT JOIN faturamento.fatur_situacao_hist fsh ON fsh.imov_id = imo.imov_id AND fsh.ftsh_amfaturamentoretirada IS NULL
	LEFT JOIN faturamento.fatur_situacao_tipo fat ON fat.ftst_id = fsh.ftst_id
	LEFT JOIN faturamento.fatur_situacao_motivo ftm ON fsh.ftsm_id = ftm.ftsm_id
	LEFT JOIN atendimentopublico.ligacao_agua lagu ON lagu.lagu_id = imo.imov_id
	LEFT JOIN atendimentopublico.ligacao_agua_diametro lgd ON lgd.lagd_id = lagu.lagd_id
	LEFT JOIN micromedicao.hidrometro_inst_hist his ON lagu.hidi_id = his.hidi_id AND his.hidi_dtretiradahidrometro IS NULL
	LEFT JOIN micromedicao.hidrometro hid ON his.hidr_id = hid.hidr_id
	LEFT JOIN micromedicao.hidrometro_capacidade hic ON hic.hicp_id = hid.hicp_id
	LEFT JOIN micromedicao.hidrometro_diametro hdi ON hdi.hidm_id = hid.hidm_id
	LEFT JOIN micromedicao.hidrometro_marca hma ON hma.himc_id = hid.himc_id
	LEFT JOIN cadastro.imovel_cobranca_situacao ics ON ics.imov_id = imo.imov_id AND ics.iscb_dtretiradacobranca IS NULL AND ics.cbst_id IN (12,14,17)
	LEFT JOIN cadastro.imovel_cobranca_situacao ics_exi ON ics_exi.imov_id = imo.imov_id AND ics_exi.iscb_dtretiradacobranca IS NULL AND ics_exi.cbst_id = 23
	LEFT JOIN cobranca.cobranca_situacao cob ON cob.cbst_id = ics.cbst_id 
	LEFT JOIN cobranca.cobranca_situacao cob_exi ON cob_exi.cbst_id = ics_exi.cbst_id 
	LEFT JOIN cobranca.cobranca_situacao_hist csh ON csh.imov_id = imo.imov_id AND csh.cbsh_amcobrancaretirada IS NULL
	LEFT JOIN cobranca.cobranca_situacao_tipo cst ON csh.cbsp_id = cst.cbsp_id
	LEFT JOIN cobranca.cobranca_situacao_motivo csm ON csm.cbsm_id = csh.cbsm_id
	LEFT JOIN micromedicao.consumo_historico cosh_a1 ON cosh_a1.imov_id = imo.imov_id AND cosh_a1.cshi_amfaturamento = VAR_REFERENCIA AND cosh_a1.lgti_id = 1
	LEFT JOIN micromedicao.consumo_tipo cost_a1 ON cost_a1.cstp_id = cosh_a1.cstp_id
	LEFT JOIN micromedicao.consumo_anormalidade cosa_a1 ON cosa_a1.csan_id = cosh_a1.csan_id
	LEFT JOIN micromedicao.consumo_historico cosh_e1 ON cosh_e1.imov_id = imo.imov_id AND cosh_e1.cshi_amfaturamento = VAR_REFERENCIA AND cosh_e1.lgti_id = 2
	LEFT JOIN micromedicao.consumo_tipo cost_e1 ON cost_e1.cstp_id = cosh_e1.cstp_id
	LEFT JOIN micromedicao.consumo_anormalidade cosa_e1 ON cosa_e1.csan_id = cosh_e1.csan_id	
	LEFT JOIN micromedicao.leitura_situacao lts ON lts.ltst_id = mdh.ltst_idleiturasituacaoatual
	LEFT JOIN micromedicao.leitura_anormalidade lai ON lai.ltan_id = mdh.ltan_idleitanorminformada
	LEFT JOIN micromedicao.leitura_anormalidade laf ON laf.ltan_id = mdh.ltan_idleitanormfatmt
	LEFT JOIN seguranca.usuario usu ON usu.usur_id = mdh.usur_idalteracao

WHERE 
	une.uneg_id IN (2,3,4,5,6,7,8,9,10,11,12,13,14,15)
	--AND cost_a1.cstp_id > 0
	AND mdh.mdhi_amleitura = VAR_REFERENCIA
	--AND hid.hidr_nnhidrometro IS NOT NULL
UNION
SELECT 
	imo.imov_id AS "MATRICULA",
	con_fatura.refer AS "REFERENCIA",
	loc.uneg_id AS "GERENCIA",
	une.uneg_nmunidadenegocio AS "NOME UNIDADE",
	lts.ltst_dsleiturasituacao AS "SITUACAO LEITURA",
	hid.hidr_nnhidrometro AS "NR HID.",
	mun.muni_nmmunicipio AS "MUNICIPIO",
	CASE 
	WHEN mun.muni_nmmunicipio IN ('AFONSO CUNHA', 'CHAPADINHA', 'DUQUE BACELAR', 'URBANO SANTOS', 'ACAILANDIA', 'ALTO PARNAIBA',
	'AMARANTE DO MARANHAO', 'ARAME', 'BURITICUPU', 'CIDELANDIA', 'DAVINOPOLIS', 'IMPERATRIZ', 'JOAO LISBOA', 'MONTES ALTOS',
	'RIACHAO', 'S F DO BREJAO', 'SAO PEDRO DA AGUA BRANCA', 'SENADOR LA ROQUE', 'ALCANTARA', 'LUIS DOMINGUES', 'PALMEIRANDIA', 
	'PINHEIRO', 'SAO BENTO', 'GOV. NEWTON BELLO', 'SANTA INES', 'SANTA LUZIA', 'SANTA LUZIA DO PARUA', 'VITORIA MEARIM', 'SAO LUIS',
	'ITAPECURU MIRIM', 'ENTRONCAMENTO', 'BACABEIRA', 'BARREIRINHAS', 'PRIMEIRA CRUZ', 'CANTANHEDE')
        THEN 'SIMULTANEA'
	ELSE 'MANUAL'
	END AS "IMPRESSAO",
	(CASE cost_a1.cstp_id
	WHEN 1	THEN 'REAL'
	WHEN 2	THEN 'AJUSTADO'
	WHEN 3	THEN 'MEDIA DO HIDRÔMETRO'
	WHEN 4	THEN 'INFORMADO'
	WHEN 5	THEN 'NAO MEDIDO'
	WHEN 6	THEN 'ESTIMADO'
	WHEN 7	THEN 'MINIMO FIXADO'
	WHEN 8	THEN 'SEM CONSUMO'
	WHEN 9	THEN 'MEDIA DO IMÓVEL'
	WHEN 10	THEN 'CONSUMO FIXO' 
	WHEN 11	THEN 'CONTRATO DEMANDA'
	ELSE
	   'INDEFINIDO'
	END) AS "TIPO DE CONSUMO",
	lai.ltan_dsleituraanormalidade AS "ANORM LEIT INFORMADA",
	laf.ltan_dsleituraanormalidade AS "ANORM LEIT FATURADA"
	--COUNT(mdh.mdhi_id) AS "QTD"	
FROM cadastro.imovel imo
	INNER JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
	INNER JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
        INNER JOIN cadastro.cliente_tipo clitp ON clitp.cltp_id = cli.cltp_id	
	INNER JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
	INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
	INNER JOIN cadastro.setor_comercial sec ON imo.stcm_id = sec.stcm_id
	INNER JOIN cadastro.quadra qdr ON qdr.qdra_id = imo.qdra_id
	INNER JOIN micromedicao.rota rot ON rot.rota_id = qdr.rota_id
	INNER JOIN faturamento.faturamento_grupo ftg ON rot.ftgr_id = ftg.ftgr_id
	INNER JOIN cadastro.logradouro_bairro lgb ON lgb.lgbr_id = imo.lgbr_id
	INNER JOIN cadastro.logradouro logr ON lgb.logr_id = logr.logr_id
	INNER JOIN cadastro.bairro bai ON bai.bair_id = lgb.bair_id
	INNER JOIN cadastro.municipio mun ON mun.muni_id = bai.muni_id
	INNER JOIN cadastro.fonte_abastecimento ftb ON ftb.ftab_id = imo.ftab_id
	INNER JOIN atendimentopublico.ligacao_agua_situacao las ON las.last_id = imo.last_id
	INNER JOIN atendimentopublico.ligacao_esgoto_situacao les ON les.lest_id = imo.lest_id
	LEFT JOIN cadastro.pessoa_sexo sex ON sex.psex_id = cli.psex_id
	LEFT JOIN operacional.distrito_operacional dis ON dis.diop_id = qdr.diop_id
	LEFT JOIN cadastro.cliente_imovel cim2 ON cim2.imov_id = imo.imov_id AND cim2.clim_dtrelacaofim IS NULL AND cim2.crtp_id  = 3
	LEFT JOIN cadastro.cliente cli2 ON cli2.clie_id = cim2.clie_id
	LEFT JOIN cadastro.cliente cli3 ON cli3.clie_id = cli2.clie_cdclienteresponsavel
	LEFT JOIN cadastro.logradouro_cep lgc ON lgc.lgcp_id = imo.lgcp_id
	LEFT JOIN cadastro.cep cep ON cep.cep_id = lgc.cep_id
	LEFT JOIN cadastro.logradouro_tipo lgt ON lgt.lgtp_id = logr.lgtp_id
	LEFT JOIN faturamento.fatur_situacao_hist fsh ON fsh.imov_id = imo.imov_id AND fsh.ftsh_amfaturamentoretirada IS NULL
	LEFT JOIN faturamento.fatur_situacao_tipo fat ON fat.ftst_id = fsh.ftst_id
	LEFT JOIN faturamento.fatur_situacao_motivo ftm ON fsh.ftsm_id = ftm.ftsm_id
	LEFT JOIN atendimentopublico.ligacao_agua lagu ON lagu.lagu_id = imo.imov_id
	LEFT JOIN atendimentopublico.ligacao_agua_diametro lgd ON lgd.lagd_id = lagu.lagd_id
	LEFT JOIN micromedicao.hidrometro_inst_hist his ON lagu.hidi_id = his.hidi_id AND his.hidi_dtretiradahidrometro IS NULL
	LEFT JOIN micromedicao.hidrometro hid ON his.hidr_id = hid.hidr_id
	LEFT JOIN micromedicao.hidrometro_capacidade hic ON hic.hicp_id = hid.hicp_id
	LEFT JOIN micromedicao.hidrometro_diametro hdi ON hdi.hidm_id = hid.hidm_id
	LEFT JOIN micromedicao.hidrometro_marca hma ON hma.himc_id = hid.himc_id
	LEFT JOIN cadastro.imovel_cobranca_situacao ics ON ics.imov_id = imo.imov_id AND ics.iscb_dtretiradacobranca IS NULL AND ics.cbst_id IN (12,14,17)
	LEFT JOIN cadastro.imovel_cobranca_situacao ics_exi ON ics_exi.imov_id = imo.imov_id AND ics_exi.iscb_dtretiradacobranca IS NULL AND ics_exi.cbst_id = 23
	LEFT JOIN cobranca.cobranca_situacao cob ON cob.cbst_id = ics.cbst_id 
	LEFT JOIN cobranca.cobranca_situacao cob_exi ON cob_exi.cbst_id = ics_exi.cbst_id 
	LEFT JOIN cobranca.cobranca_situacao_hist csh ON csh.imov_id = imo.imov_id AND csh.cbsh_amcobrancaretirada IS NULL
	LEFT JOIN cobranca.cobranca_situacao_tipo cst ON csh.cbsp_id = cst.cbsp_id
	LEFT JOIN cobranca.cobranca_situacao_motivo csm ON csm.cbsm_id = csh.cbsm_id
	LEFT JOIN micromedicao.consumo_historico cosh_a1 ON cosh_a1.imov_id = imo.imov_id AND cosh_a1.cshi_amfaturamento = VAR_REFERENCIA AND cosh_a1.lgti_id = 1
	LEFT JOIN micromedicao.consumo_tipo cost_a1 ON cost_a1.cstp_id = cosh_a1.cstp_id
	LEFT JOIN micromedicao.consumo_anormalidade cosa_a1 ON cosa_a1.csan_id = cosh_a1.csan_id
	LEFT JOIN micromedicao.consumo_historico cosh_e1 ON cosh_e1.imov_id = imo.imov_id AND cosh_e1.cshi_amfaturamento = VAR_REFERENCIA AND cosh_e1.lgti_id = 2
	LEFT JOIN micromedicao.consumo_tipo cost_e1 ON cost_e1.cstp_id = cosh_e1.cstp_id
	LEFT JOIN micromedicao.consumo_anormalidade cosa_e1 ON cosa_e1.csan_id = cosh_e1.csan_id	
	LEFT JOIN micromedicao.medicao_historico mdh ON mdh.hidi_id = his.hidi_id AND mdh.mdhi_amleitura = VAR_REFERENCIA
	LEFT JOIN micromedicao.leitura_situacao lts ON lts.ltst_id = mdh.ltst_idleiturasituacaoatual
	LEFT JOIN micromedicao.leitura_anormalidade lai ON lai.ltan_id = mdh.ltan_idleitanorminformada
	LEFT JOIN micromedicao.leitura_anormalidade laf ON laf.ltan_id = mdh.ltan_idleitanormfatmt
	LEFT JOIN seguranca.usuario usu ON usu.usur_id = mdh.usur_idalteracao
	LEFT JOIN (SELECT 
				con.imov_id AS mat1,
				con.cnta_amreferenciaconta AS refer,
				con.cnta_nnconsumoagua AS vol_agua,
				con.cnta_vlagua AS vl_agua,
				con.cnta_nnconsumoesgoto AS vol_esg,
				con.cnta_vlesgoto AS vl_esgoto,
				con.cnta_vldebitos AS vl_debitos,
				con.cnta_vlcreditos AS vl_creditos,
				con.cnta_vlimpostos AS vl_impostos,
				con.cnta_vlagua+con.cnta_vlesgoto+con.cnta_vldebitos-con.cnta_vlcreditos-con.cnta_vlimpostos AS valor
			FROM faturamento.conta con 
				INNER JOIN faturamento.conta_impressao cni ON cni.cnta_id = con.cnta_id
			WHERE
				con.dcst_idatual IN (0,1,2,5) AND con.cnta_amreferenciaconta = VAR_REFERENCIA
			UNION
			SELECT 
				con.imov_id AS mat1,
				con.cnhi_amreferenciaconta AS refer,
				con.cnhi_nnconsumoagua AS vol_agua,
				con.cnhi_vlagua AS vl_agua,
				con.cnhi_nnconsumoesgoto AS vol_esg,
				con.cnhi_vlesgoto AS vl_esgoto,
				con.cnhi_vldebitos AS vl_debitos,
				con.cnhi_vlcreditos AS vl_creditos,
				con.cnhi_vlimpostos AS vl_impostos,
				con.cnhi_vlagua+con.cnhi_vlesgoto+con.cnhi_vldebitos-con.cnhi_vlcreditos-con.cnhi_vlimpostos AS valor
			FROM faturamento.conta_historico con 
				INNER JOIN faturamento.conta_impressao cni ON cni.cnta_id = con.cnta_id
			WHERE
				con.dcst_idatual IN (0,1,2,5) AND con.cnhi_amreferenciaconta = VAR_REFERENCIA
			UNION
			SELECT 
				con.imov_id AS mat1,
				con.cnta_amreferenciaconta AS refer,
				con.cnta_nnconsumoagua AS vol_agua,
				con.cnta_vlagua AS vl_agua,
				con.cnta_nnconsumoesgoto AS vol_esg,
				con.cnta_vlesgoto AS vl_esgoto,
				con.cnta_vldebitos AS vl_debitos,
				con.cnta_vlcreditos AS vl_creditos,
				con.cnta_vlimpostos AS vl_impostos,
				con.cnta_vlagua+con.cnta_vlesgoto+con.cnta_vldebitos-con.cnta_vlcreditos-con.cnta_vlimpostos AS valor
			FROM faturamento.conta con 
				INNER JOIN faturamento.mov_conta_prefaturada cni ON cni.cnta_id = con.cnta_id
			WHERE
				con.dcst_idatual IN (0,1,2,5) AND con.cnta_amreferenciaconta = VAR_REFERENCIA
			UNION
			SELECT 
				con.imov_id AS mat1,
				con.cnhi_amreferenciaconta AS refer,
				con.cnhi_nnconsumoagua AS vol_agua,
				con.cnhi_vlagua AS vl_agua,
				con.cnhi_nnconsumoesgoto AS vol_esg,
				con.cnhi_vlesgoto AS vl_esgoto,
				con.cnhi_vldebitos AS vl_debitos,
				con.cnhi_vlcreditos AS vl_creditos,
				con.cnhi_vlimpostos AS vl_impostos,
				con.cnhi_vlagua+con.cnhi_vlesgoto+con.cnhi_vldebitos-con.cnhi_vlcreditos-con.cnhi_vlimpostos AS valor
			FROM faturamento.conta_historico con 
				INNER JOIN faturamento.mov_conta_prefaturada cni ON cni.cnta_id = con.cnta_id
			WHERE
				con.dcst_idatual IN (0,1,2,5) AND con.cnhi_amreferenciaconta = VAR_REFERENCIA

			) AS con_fatura ON con_fatura.mat1 = imo.imov_id
	
WHERE 
	imo.imov_icexclusao = 2
	AND une.uneg_id IN (2,3,4,5,6,7,8,9,10,11,12,13,14,15)
	--AND cost_a1.cstp_id > 0
	AND cost_a1.cstp_id = 5
	AND con_fatura.refer = VAR_REFERENCIA
	--AND cosa_a1.csan_dsabrvconsanormalidade IS NOT NULL --IN ('FL','CA','CI','CR','BC','LP','LM','HS','MF','FF','HN','FA','VH','AL','AC','EC','EM','C.L.C')
	--AND imo.iper_id = 1
	--AND imo.imov_id = 90433
	--AND hid.hidr_nnhidrometro IS NOT NULL