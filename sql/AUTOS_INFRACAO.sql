SELECT
	aut.auif_id AS "ID AUTO DE INFRACAO",
	TO_CHAR(aut.auif_dtemissao, 'yyyyMM')::INTEGER AS "REFERENCIA",
	TO_CHAR(aut.auif_dtemissao, 'dd/MM/yyyy') AS "DATA",
	fun.func_id::TEXT || ' - ' || fun.func_nmfuncionario AS "FUNCIONARIO",
	uno.unid_dsunidade AS "UNIDADE FUNCIONARIO",
	aut.imov_id AS "IMOVEL AUTUADO",
	fzs.fzst_dsfiscalizacaosituacao AS "FRAUDE ECONTRADA",
	imo.imov_nncoordenadax AS "LATITUDE",
	imo.imov_nncoordenaday AS "LONGITUDE",
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
	cli.clie_dsemail AS "EMAIL",
	TO_CHAR(cli.clie_dtnascimento,'DD/MM/YYYY') AS "DT NASCIMENTO",
	cli.clie_nnmae AS "NOME DA MAE",
	cim.clim_dtrelacaoinicio AS "INICIO DA RELACAO",
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
	las.last_dsligacaoaguasituacao AS "SITUACAO AGUA",
	les.lest_dsligacaoesgotosituacao AS "SITUACAO ESGOTO",
	ors.orse_id AS "ORDEM DE SERVICO",
	ors.orse_dsparecerencerramento AS "PARECER ENCERRAMENTO"
FROM
	faturamento.autos_infracao aut
	INNER JOIN cadastro.funcionario fun ON fun.func_id = aut.func_id
	INNER JOIN cadastro.unidade_organizacional uno ON uno.unid_id = fun.unid_id
	LEFT JOIN atendimentopublico.fiscalizacao_situacao fzs ON fzs.fzst_id = aut.fzst_id
	LEFT JOIN atendimentopublico.ordem_servico ors ON ors.orse_id = aut.orse_id
	LEFT JOIN cadastro.imovel imo ON imo.imov_id = aut.imov_id
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
WHERE
	aut.auif_dtemissao>= '2021-01-01'
ORDER BY 4 DESC