--VAR_REFERENCIA: Deve ser substituida pela referencia do faturamento que se deseja obter os dados
--15: Deve ser substituida pelo id da unidade de onde se quer obter os dados

SELECT 
	imo.imov_id AS "MATRICULA",
	cli.clie_nmcliente AS "NOME",
	cli.clie_nncpf AS "CPF",
	cli.clie_nncnpj AS "CNPJ",
	(CASE cli.clie_iccpfcnpjvalidado
	WHEN 0 THEN 'NAO'
	WHEN 1 THEN 'SIM'
	ELSE 'NAO'
	END) AS "DOC VALIDADO",
	(
		SELECT
			STRING_AGG('('||cfn.cfon_cdddd||')'||cfn.cfon_nnfone,' | ')
		FROM
			cadastro.cliente_fone cfn
			INNER JOIN cadastro.cliente cli2 ON cli2.clie_id = cfn.clie_id
			INNER JOIN cadastro.cliente_imovel cim2 ON cim2.clie_id = cli2.clie_id AND cim2.clim_dtrelacaofim IS NULL AND cim2.imov_id = imo.imov_id
	) AS "TELEFONES",
	cli2.clie_id AS "COD RESP",
	cli2.clie_nmcliente AS "NOME RESP",
	cli2.clie_nncpf AS "CPF RESP",
	cli2.clie_nncnpj AS "CNPJ RESP",
	cli3.clie_id AS "COD PAI",
	cli3.clie_nmcliente AS "NOME PAI",
	cli3.clie_nncpf AS "CPF PAI",
	cli3.clie_nncnpj AS "CNPJ PAI",
	imo.iper_id AS "PERFIL",
	(CASE imo.imov_idcategoriaprincipal 
	WHEN 1 THEN '1 - RESIDENCIAL'
	WHEN 2 THEN '2 - COMERCIAL'
	WHEN 3 THEN '3 - INDUSTRIAL'
	WHEN 4 THEN '4 - PUBLICO'
	ELSE 'NAO DEFINIDO'
	END) AS "CATEGORIA PRINCIPAL",
	(CASE imo.imov_idsubcategoriaprincipal 
	WHEN 1 THEN '1 - RESIDENCIAL'
	WHEN 2 THEN '2 - COMERCIAL'
	WHEN 3 THEN '3 - INDUSTRIAL'
	WHEN 4 THEN '4 - MUNICIPAL'
	WHEN 5 THEN '5 - ESTADUAL'
	WHEN 6 THEN '6 - FEDERAL'
	WHEN 7 THEN '7 - RES. POPULAR'
	WHEN 8 THEN '8 - PEQ. NEGOCIOS'
	WHEN 9 THEN '9 - ENT. FILANTROPICAS'
	WHEN 10 THEN '10 - SIST. OPERADO POR PREFEITURA'
	ELSE 'NAO DEFINIDO'
	END) AS "SUBCATEGORIA PRINCIPAL",
	imo.imov_qteconomia AS "ECONOMIAS",
	ftb.ftab_dsfonteabastecimento AS "ABASTECIMENTO",
	loc.uneg_id AS "GERENCIA",
	une.uneg_nmunidadenegocio AS "NOME UNIDADE",
	imo.loca_id AS "LOCALIDADE",
	loc.loca_nmlocalidade AS "NOME LOCALIDADE",
	sec.stcm_cdsetorcomercial AS "SETOR COMERCIAL",
	qdr.qdra_nnquadra AS "QUADRA",
	imo.imov_nnsequencialrota AS "SEQUENCIA",
	imo.imov_nnsublote AS "SUB LOTE",
	rot.rota_cdrota AS "ROTA",
	ftg.ftgr_dsfaturamentogrupo AS "GRUPO FATURAMENTO",
	lgt.lgtp_dslogradourotipo AS "TIPO LOGRADOURO",
	logr.logr_nmlogradouro AS "NOME LOGRADOURO",
	cep.cep_cdcep AS "CEP",
	imo.imov_dscomplementoendereco AS "COMPLEMENTO",
	bai.bair_nmbairro AS "BAIRRO",
	imo.imov_nnimovel AS "NR",
	mun.muni_nmmunicipio AS "MUNICIPIO",
	imo.last_id AS "ID SIT. AGUA",
	las.last_dsligacaoaguasituacao AS "SITUACAO AGUA",
	lgd.lagd_dsligacaoaguadiametro AS "DIAMETRO LIG AGUA",
	lagu.lagu_dtimplantacao AS "DT. IMPLANTACAO",
	lagu.lagu_dtcorte AS "DT. CORTE",
	lagu.lagu_dtsupressaoagua AS "DT. SUPRESSAO",
	imo.lest_id AS "ID SIT. ESG",
	les.lest_dsligacaoesgotosituacao AS "SITUACAO ESGOTO",
	imo.imov_nnareaconstruida AS "AREA",
	CAST(fat.ftst_id  AS TEXT) || ' - ' || fat.ftst_dsfaturamentosituacaotipo AS "SIT. FATURAMENTO",
	fsh.ftsh_amfatmtsitinicio AS "INICIO",
	fsh.ftsh_amfaturamentosituacaofim AS "FIM",
	hid.hidr_nnhidrometro AS "NR HID.",
	his.hidi_dtinstalacaohidrometro AS "DATA DE INSTALACAO HD.",
	hic.hicp_dshidrometrocapacidade AS "CAPACIDADE HD",
	hdi.hidm_dshidrometrodiametro AS "DIAMETRO HD",
	con_ult_fat.cagua AS "VOL AG VAR_REFERENCIA",
	con_ult_fat.vl_agua AS "VL AG VAR_REFERENCIA",
	con_ult_fat.cesg AS "VOL ES VAR_REFERENCIA",
	con_ult_fat.vl_esgoto AS "VL ES VAR_REFERENCIA",
	con_ult_fat.vl_debitos AS "OUTROS SERVICOS VAR_REFERENCIA",
	con_ult_fat.vl_creditos AS "CRED VAR_REFERENCIA",
	con_ult_fat.vl_impostos AS "IMPOSTOS VAR_REFERENCIA",
	con_ult_fat.valor AS "VALOR VAR_REFERENCIA",
	con_parcelamento.qtd AS "QTD PARCELAMENTO ATRASADO",
	con_parcelamento.valor AS "VALOR PARCELAMENTO ATRASADO",
	con_atraso.vl_agua AS "VALOR AGUA DEVIDO",
	con_atraso.vl_esgoto AS "VALOR ESGOTO DEVIDO",
	con_atraso.vl_debitos AS "VALOR DEBITOS DEVIDO",
	con_atraso.vl_creditos AS "VALOR CREDITOS DEVIDO",
	con_atraso.vl_impostos AS "VALOR IMPOSTOS DEVIDO",
	con_atraso.valor AS "VALOR TOTAL DEVIDO",
	con_atraso.qtd AS "QTD. CONTAS DEVIDO",
	con_atraso.min AS "MENOR REFERENCIA DEVIDO",
	con_atraso.max AS "MAIOR REFERENCIA DEVIDO",
	con_atraso.min_venc AS "MENOR VENCIMENTO",
	con_atraso.max_venc AS "MAIOR VENCIMENTO"
FROM 
	cadastro.imovel imo
	INNER JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
	INNER JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
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
	LEFT JOIN (	SELECT 
				con4.imov_id AS mat1,
				SUM(con4.cnta_vlagua) AS vl_agua,
				SUM(con4.cnta_vlesgoto) AS vl_esgoto,
				SUM(con4.cnta_vldebitos) AS vl_debitos,
				SUM(con4.cnta_vlcreditos) AS vl_creditos,
				SUM(con4.cnta_vlimpostos) AS vl_impostos,
				COUNT(con4.cnta_id) AS qtd,
				MIN(con4.cnta_amreferenciaconta) AS min,
				MAX(con4.cnta_amreferenciaconta) AS max,
				MIN(con4.cnta_dtvencimentoconta) AS min_venc,
				MAX(con4.cnta_dtvencimentoconta) AS max_venc,
				SUM(con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos) AS valor
			FROM faturamento.conta con4 
				INNER JOIN cadastro.localidade loc4 ON loc4.loca_id = con4.loca_id
			WHERE 
				con4.dcst_idatual IN (0,1,2) 
				AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con4.cnta_id) 
				AND con4.cnta_dtvencimentoconta < CURRENT_DATE - INTERVAL 'VAR_MINDIASd'
				AND con4.cnta_dtvencimentoconta >= (CURRENT_DATE - INTERVAL 'VAR_MINANOSy')
				AND con4.cnta_dtrevisao IS NULL 
				AND con4.iper_id <> 6 
				AND con4.cnta_amreferenciaconta <= VAR_REFERENCIA
			GROUP BY 1) AS con_atraso ON con_atraso.mat1 = imo.imov_id
	LEFT JOIN (	SELECT 
				con4.imov_id AS mat1,
				COUNT(distinct con4.cnta_id) AS qtd,
				SUM(dco.dbcb_vlprestacao) AS valor
			FROM faturamento.conta con4 
				INNER JOIN faturamento.debito_cobrado dco ON dco.cnta_id = con4.cnta_id AND dco.dbtp_id IN (40,43,44)
				INNER JOIN cadastro.localidade loc4 ON loc4.loca_id = con4.loca_id
			WHERE 
				con4.dcst_idatual IN (0,1,2) AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con4.cnta_id) AND con4.cnta_dtvencimentoconta < CURRENT_DATE AND con4.cnta_dtrevisao IS NULL AND con4.iper_id <> 6
			GROUP BY 1) AS con_parcelamento ON con_parcelamento.mat1 = imo.imov_id
	LEFT JOIN (	SELECT 
					con4.imov_id AS mat1,
					con4.cnta_nnconsumoagua AS cagua,
					con4.cnta_vlagua AS vl_agua,
					con4.cnta_nnconsumoesgoto AS cesg,
					con4.cnta_vlesgoto AS vl_esgoto,
					con4.cnta_vldebitos AS vl_debitos,
					con4.cnta_vlcreditos AS vl_creditos,
					con4.cnta_vlimpostos AS vl_impostos,
					con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos AS valor
				FROM faturamento.conta con4 
					INNER JOIN faturamento.conta_impressao cni ON cni.cnta_id = con4.cnta_id
				WHERE
					con4.cnta_amreferenciaconta = VAR_REFERENCIA
				UNION
				SELECT 
					con4.imov_id AS mat1,
					con4.cnhi_nnconsumoagua AS cagua,
					con4.cnhi_vlagua AS vl_agua,
					con4.cnhi_nnconsumoesgoto AS cesg,
					con4.cnhi_vlesgoto AS vl_esgoto,
					con4.cnhi_vldebitos AS vl_debitos,
					con4.cnhi_vlcreditos AS vl_creditos,
					con4.cnhi_vlimpostos AS vl_impostos,
					con4.cnhi_vlagua+con4.cnhi_vlesgoto+con4.cnhi_vldebitos-con4.cnhi_vlcreditos-con4.cnhi_vlimpostos AS valor
				FROM faturamento.conta_historico con4 
					INNER JOIN faturamento.conta_impressao cni ON cni.cnta_id = con4.cnta_id
				WHERE
					con4.cnhi_amreferenciaconta = VAR_REFERENCIA
				UNION
				SELECT 
					con4.imov_id AS mat1,
					con4.cnta_nnconsumoagua AS cagua,
					con4.cnta_vlagua AS vl_agua,
					con4.cnta_nnconsumoesgoto AS cesg,
					con4.cnta_vlesgoto AS vl_esgoto,
					con4.cnta_vldebitos AS vl_debitos,
					con4.cnta_vlcreditos AS vl_creditos,
					con4.cnta_vlimpostos AS vl_impostos,
					con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos AS valor
				FROM faturamento.conta con4 
					INNER JOIN faturamento.mov_conta_prefaturada cni ON cni.cnta_id = con4.cnta_id
				WHERE
					con4.cnta_amreferenciaconta = VAR_REFERENCIA
				UNION
				SELECT 
					con4.imov_id AS mat1,
					con4.cnhi_nnconsumoagua AS cagua,
					con4.cnhi_vlagua AS vl_agua,
					con4.cnhi_nnconsumoesgoto AS cesg,
					con4.cnhi_vlesgoto AS vl_esgoto,
					con4.cnhi_vldebitos AS vl_debitos,
					con4.cnhi_vlcreditos AS vl_creditos,
					con4.cnhi_vlimpostos AS vl_impostos,
					con4.cnhi_vlagua+con4.cnhi_vlesgoto+con4.cnhi_vldebitos-con4.cnhi_vlcreditos-con4.cnhi_vlimpostos AS valor
				FROM faturamento.conta_historico con4 
					INNER JOIN faturamento.mov_conta_prefaturada cni ON cni.cnta_id = con4.cnta_id
				WHERE
					con4.cnhi_amreferenciaconta = VAR_REFERENCIA
				) AS con_ult_fat ON con_ult_fat.mat1 = imo.imov_id
WHERE
	imo.imov_icexclusao = 2 AND
	con_atraso.qtd > 0 AND
	NOT EXISTS( SELECT  ics.cbst_id FROM cadastro.imovel_cobranca_situacao ics WHERE ics.imov_id = imo.imov_id AND ics.iscb_dtretiradacobranca IS NULL AND ics.cbst_id IN (12,14,17,24,25,26)) AND
	NOT EXISTS( SELECT  csh.imov_id FROM cobranca.cobranca_situacao_hist csh WHERE csh.imov_id = imo.imov_id AND csh.cbsh_amcobrancaretirada IS NULL) AND
	cli.clie_iccpfcnpjvalidado = 2 AND
	imo.imov_idcategoriaprincipal < 4 AND
	imo.iper_id <> 6 AND
	con_atraso.valor > VAR_VALOR AND
	con_atraso.min <= VAR_REFERENCIA AND
	une.uneg_id IN (VAR_UNIDADE) AND
	TRIM(COALESCE(cli.clie_nncpf,'') || COALESCE(cli.clie_nncnpj,''))<>'' AND
	NOT EXISTS( 
	SELECT 
		ngc.ngcm_id 
	FROM 
		cobranca.negativacao_comando ngc 
		INNER JOIN cobranca.negativacao_comando_imov ngi ON ngc.ngcm_id = ngi.ngcm_id
	WHERE
		ngc.ngcm_tmrealizacao IS NULL AND
		ngi.imov_id = imo.imov_id
	)
ORDER BY "LOCALIDADE","SETOR COMERCIAL","ROTA","QUADRA","SEQUENCIA","SUB LOTE"