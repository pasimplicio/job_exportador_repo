SELECT 
	ecp.eccp_id AS "ID ECCP",
	ecp.eccp_ampagamento AS "REFERENCIA PAG",
	ecp.eccp_dtpagamento AS "DT PAGAMENTO",
	dbt.dbtp_dsdebitotipo AS "TIPO DO DEBITO",
	TO_CHAR(ecp.eccp_vlpagamentomes,'999G999G990D00') AS "VALOR PAGO",
	(
		CASE ecp.eccp_ictipopagamento
			WHEN 1 THEN 'A VISTA'
			WHEN 2 THEN 'PARCELADO'
		END
	) AS "MODALIDADE",
	TO_CHAR(COALESCE(par.parc_tmparcelamento,par2.parc_tmparcelamento),'DD/MM/YYYY') AS "DATA PARCELAMENTO",
	--TO_CHAR(par.parc_tmparcelamento,'DD/MM/YYYY') AS "DATA PARCELAMENTO",
	--par2.parc_tmparcelamento,
	COALESCE(pas.pcst_dsparcelamentosituacao,pas2.pcst_dsparcelamentosituacao) AS "SITUACAO PARCELAMENTO",
	ecp.eccp_nnparcelaatual AS "PARCELA ATUAL",
	ecp.eccp_nntotalparcelas AS "TOTAL PARCELAS",
	emp.empr_nmempresa AS "EMPRESA",
	(CASE
		WHEN (emp.empr_id >= 34 AND emp.empr_id <=42) THEN 'AZUL'
		WHEN emp.empr_id = 33 THEN 'COMAP'
		WHEN (emp.empr_id >= 29 AND emp.empr_id <= 32) THEN 'EXPONENCIAL'
		ELSE 'UNKNOWN'
	END) AS "EMPRESA 1",
	TO_CHAR(ecc.ecco_pcempresaconta,'999G999G990D00') AS "PERC EMP",
	TO_CHAR((ecp.eccp_vlpagamentomes*(ecc.ecco_pcempresaconta/100)),'999G999G990D00') AS "REMUNERAÇÃO",
	ecp.imov_id AS "IMOVEL",
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
	dis.diop_dsdistritooperacional AS "DISTR OPERACIONAL",
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
	ftm.ftsm_dsfatsitmotivo AS "MOTIVO",
	cst.cbsp_id AS "COD SIT.",
	CAST(cst.cbsp_id AS TEXT) || ' - ' || cst.cbsp_dscobrancasituacaotipo AS "SIT. ESPECIAL DE COBRANCA",
	csh.cbsh_amcobrancasituacaoinicio AS "INICIO",
	csh.cbsh_amcobrancasituacaofim AS "FIM",
	csm.cbsm_dscobrancasituacaomotivo AS "MOTIVO",
	csh.cbsh_dsobservacaoinforma AS "OBS",
	hid.hidr_nnhidrometro AS "NR HID.",
	hid.hidr_nnanofabricacao AS "ANO HD",
	his.hidi_dtinstalacaohidrometro AS "DATA DE INSTALACAO HD.",
	hic.hicp_dshidrometrocapacidade AS "CAPACIDADE HD",
	hdi.hidm_dshidrometrodiametro AS "DIAMETRO HD",
	cob.cbst_dscobrancasituacao AS "SIT. COBRANCA",
	cob.cbst_dscobrancasituacao AS "SIT. COBRANCA",
	ics.iscb_dtimplantacaocobranca AS "DATA DE ENTRADA COBRANCA"
FROM 
	cobranca.empr_cobr_conta_pagto ecp
	LEFT JOIN cobranca.empresa_cobranca_conta ecc ON ecc.ecco_id = ecp.ecco_id
	LEFT JOIN cadastro.empresa emp ON emp.empr_id = ecc.empr_id
	LEFT JOIN faturamento.debito_tipo dbt ON ecp.dbtp_id = dbt.dbtp_id
	LEFT JOIN cadastro.imovel imo ON imo.imov_id = ecp.imov_id
	LEFT JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
	LEFT JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
	LEFT JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
	LEFT JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
	LEFT JOIN cadastro.setor_comercial sec ON imo.stcm_id = sec.stcm_id
	LEFT JOIN cadastro.quadra qdr ON qdr.qdra_id = imo.qdra_id
	LEFT JOIN micromedicao.rota rot ON rot.rota_id = qdr.rota_id
	LEFT JOIN faturamento.faturamento_grupo ftg ON rot.ftgr_id = ftg.ftgr_id
	LEFT JOIN cadastro.logradouro_bairro lgb ON lgb.lgbr_id = imo.lgbr_id
	LEFT JOIN cadastro.logradouro logr ON lgb.logr_id = logr.logr_id
	LEFT JOIN cadastro.bairro bai ON bai.bair_id = lgb.bair_id
	LEFT JOIN cadastro.municipio mun ON mun.muni_id = bai.muni_id
	LEFT JOIN cadastro.fonte_abastecimento ftb ON ftb.ftab_id = imo.ftab_id
	LEFT JOIN atendimentopublico.ligacao_agua_situacao las ON las.last_id = imo.last_id
	LEFT JOIN atendimentopublico.ligacao_esgoto_situacao les ON les.lest_id = imo.lest_id
	LEFT JOIN operacional.distrito_operacional dis ON dis.diop_id = qdr.diop_id
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
	LEFT JOIN cobranca.cobranca_situacao cob ON cob.cbst_id = ics.cbst_id 
	LEFT JOIN cobranca.cobranca_situacao_hist csh ON csh.imov_id = imo.imov_id AND csh.cbsh_amcobrancaretirada IS NULL
	LEFT JOIN cobranca.cobranca_situacao_tipo cst ON csh.cbsp_id = cst.cbsp_id
	LEFT JOIN cobranca.cobranca_situacao_motivo csm ON csm.cbsm_id = csh.cbsm_id
	LEFT JOIN cobranca.parcelamento_item pai ON pai.cnta_id = ecc.cnta_id
	LEFT JOIN cobranca.parcelamento par ON par.parc_id = pai.parc_id AND par.pcst_id = 1
--	LEFT JOIN cobranca.parcelamento par2 ON par2.imov_id = imo.imov_id AND par2.pcst_id = 1 AND par2.parc_id <> COALESCE(par.parc_id,-1) AND par2.parc_nnprestacoes = ecp.eccp_nntotalparcelas
	LEFT JOIN cobranca.parcelamento_situacao pas ON pas.pcst_id = par.pcst_id
	--LEFT JOIN cobranca.parcelamento par2 ON par2.parc_id = dac.parc_id
	LEFT JOIN cobranca.parcelamento par2 ON par2.parc_id = (
			SELECT
				DISTINCT par3.parc_id AS parc_id
			FROM
				cobranca.parcelamento par3
				INNER JOIN faturamento.debito_a_cobrar dac ON par3.parc_id = dac.parc_id
				INNER JOIN faturamento.debito_cobrado_historico dch ON dac.dbac_id = dch.dbac_id
				INNER JOIN arrecadacao.pagamento_historico pgh ON dch.cnta_id = pgh.cnta_id
			WHERE
				pgh.pgst_idatual IN (0,5,10) AND
				pgh.imov_id = imo.imov_id AND pgh.pghi_dtpagamento = ecp.eccp_dtpagamento AND pgh.pgst_idatual IN (0,5,10)
			LIMIT 1
		)
	LEFT JOIN cobranca.parcelamento_situacao pas2 ON pas2.pcst_id = par2.pcst_id
WHERE 
	ecp.eccp_ampagamento >= 201901 AND ecp.eccp_ampagamento <= 201912 AND --imo.imov_id = 3980669 AND
	((emp.empr_id >= 34 AND emp.empr_id <=42 AND ecp.eccp_dtpagamento > '2019-05-01') OR
	(emp.empr_id = 33 AND ecp.eccp_dtpagamento > '2019-05-09') OR
	(emp.empr_id >= 29 AND emp.empr_id <= 32 AND ecp.eccp_dtpagamento > '2019-04-22'))