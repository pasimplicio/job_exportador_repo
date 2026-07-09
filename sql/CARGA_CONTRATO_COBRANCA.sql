SELECT
	une.uneg_id AS "UNIDADE",
	une.uneg_nmunidadenegocio AS "NOME UNIDADE",
	ftg.ftgr_dsfaturamentogrupo AS "GRUPO FATURAMENTO",
	loc.loca_id AS "LOCALIDADE",
	loc.loca_nmlocalidade AS "NOME LOCALIDADE",
	rot.rota_cdrota AS "ROTA",
	imo.imov_nnsequencialrota AS "SEQUENCIAL ROTA",
	imo.imov_id AS "IMOVEL",
	cli.clie_nmcliente AS "NOME CLIENTE",
	cli.clie_nmabreviado AS "NOME FANTASIA",
	lgt.lgtp_dslogradourotipo || ' ' || logr.logr_nmlogradouro AS "NOME LOGRADOURO",
	imo.imov_nnimovel AS "NR IMOVEL",
	imo.imov_dscomplementoendereco AS "COMPLEMENTO",
	cep.cep_cdcep AS "CEP",
	bai.bair_nmbairro AS "BAIRRO",
	cfn.cfon_nnfone AS "TELEFONE",
	(CASE
		WHEN (NOT cli.clie_nncpf IS NULL AND TRIM(cli.clie_nncpf) <> '' AND cltp_icpessoafisicajuridica = 1) THEN TO_CHAR(cli.clie_nncpf::bigint,'000G000G000-00')
		WHEN (NOT cli.clie_nncnpj IS NULL AND TRIM(cli.clie_nncnpj) <> '' AND cltp_icpessoafisicajuridica = 2) THEN TO_CHAR(cli.clie_nncnpj::bigint,'00G000G000/0000-00')
		ELSE ''
	 END
	) AS "CPF/CNPJ",
	cli.clie_nnrg AS "RG",
	TO_CHAR(TO_DATE(TO_CHAR(ecc.ecco_amreferenciaconta,'000000'),'YYYYMM'),'MM/YYYY') AS "REFERENCIA",
	TO_CHAR(con.cnta_dtvencimentoconta,'DD/MM/YYYY') AS "VENCIMENTO",
	TO_CHAR(con.cnta_vlagua*100,'000000000000000') AS "VALOR AGUA",
	TO_CHAR(con.cnta_vlesgoto*100,'000000000000000') AS "VALOR ESGOTO",
	TO_CHAR(con.cnta_vldebitos*100,'000000000000000') AS "VALOR SERVICOS",
	TO_CHAR(con.cnta_vlcreditos*100,'000000000000000') AS "VALOR CREDITOS",
	TO_CHAR((con.cnta_vlagua+con.cnta_vlesgoto+con.cnta_vldebitos-con.cnta_vlcreditos-con.cnta_vlimpostos)*100,'000000000000000') AS "VALOR FATURA",
	TO_CHAR(TRUNC(ecc.ecco_amreferenciaconta/100),'0000') AS "ANO CONTROLE",
	con.cnta_id AS "CONTROLE",
	con.cnta_cdsetorcomercial AS "SETOR COMERCIAL",
	qdr.qdra_nnquadra AS "QUADRA",
	con.cnta_nnlote AS "LOTE",
	con.cnta_nnsublote AS "SUB LOTE",
	'' AS "TP LOGR",
	cli.clie_id AS "COD CLIENTE"
FROM
	cobranca.empresa_cobranca_conta ecc
	INNER JOIN cadastro.imovel imo ON imo.imov_id = ecc.imov_id
	INNER JOIN cadastro.cliente_conta clc ON clc.cnta_id = ecc.cnta_id AND clc.clct_icnomeconta = 1
	INNER JOIN cadastro.cliente cli ON cli.clie_id = clc.clie_id
	INNER JOIN faturamento.conta con ON con.cnta_id = ecc.cnta_id
	INNER JOIN cadastro.localidade loc ON loc.loca_id = con.loca_id
	INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
	INNER JOIN cadastro.setor_comercial sec ON imo.stcm_id = sec.stcm_id
	INNER JOIN cadastro.quadra qdr ON qdr.qdra_id = imo.qdra_id
	INNER JOIN micromedicao.rota rot ON rot.rota_id = qdr.rota_id
	INNER JOIN faturamento.faturamento_grupo ftg ON rot.ftgr_id = ftg.ftgr_id
	INNER JOIN cadastro.logradouro_bairro lgb ON lgb.lgbr_id = imo.lgbr_id
	INNER JOIN cadastro.logradouro logr ON lgb.logr_id = logr.logr_id
	INNER JOIN cadastro.logradouro_tipo lgt ON lgt.lgtp_id = logr.lgtp_id
	INNER JOIN cadastro.bairro bai ON bai.bair_id = lgb.bair_id
	INNER JOIN cadastro.municipio mun ON mun.muni_id = bai.muni_id
	LEFT JOIN cadastro.logradouro_cep lgc ON lgc.lgcp_id = imo.lgcp_id
	LEFT JOIN cadastro.cep cep ON cep.cep_id = lgc.cep_id
	LEFT JOIN cadastro.cliente_fone cfn ON cfn.clie_id = cli.clie_id AND cfn.cfon_icfonepadrao = 1
	LEFT JOIN cadastro.cliente_tipo clt ON clt.cltp_id = cli.cltp_id
WHERE
	ecc.ecco_dtretiradaconta IS NULL AND
	ecc.empr_id = VAR_EMPRESA AND
	NOT EXISTS (SELECT * FROM cobranca.empr_cobr_conta_pagto eccp WHERE eccp.ecco_id = ecc.ecco_id)