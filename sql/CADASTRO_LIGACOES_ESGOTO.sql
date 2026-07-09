SELECT
	lesg.lesg_id AS "ID",
	lesg.lesg_dtligacao AS "DT IMPLANTACAO",
	rli.rlin_dsramallocalinstalcao AS "LOCAL DE INSTALACAO",
	lor.lgor_dsligacaoorigem AS "ORIGEM",
	led.legd_dsligacaoesgotodiametro AS "DIAMETRO",
	lem.legm_dsligacaoesgotomaterial AS "MATERIAL",
	lep.lepf_dsligacaoesgotoperfil AS "PERFIL DA LIGACAO",
	imo.imov_id AS "MATRICULA IMOVEL",
	les.lest_dsligacaoesgotosituacao AS "SITUACAO",
	prua.prua_dspavimentorua AS "PAVIMENTO RUA",
	pcal.pcal_dspavimentocalcada AS "PAVIMENTO CALCADA",
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
	mun.muni_nmmunicipio AS "MUNICIPIO"
FROM
	atendimentopublico.ligacao_esgoto lesg
	LEFT JOIN atendimentopublico.ramal_local_instalacao rli ON rli.rlin_id = lesg.rlin_id
	LEFT JOIN atendimentopublico.ligacao_origem lor ON lor.lgor_id = lesg.lgor_id
	LEFT JOIN atendimentopublico.ligacao_esgoto_diametro led ON led.legd_id = lesg.legd_id
	LEFT JOIN atendimentopublico.ligacao_esgoto_material lem ON lem.legm_id = lesg.legm_id
	LEFT JOIN atendimentopublico.ligacao_esgoto_perfil lep ON lep.lepf_id = lesg.lepf_id
	LEFT JOIN cadastro.imovel imo ON imo.imov_id = lesg.lesg_id
	LEFT JOIN atendimentopublico.ligacao_esgoto_situacao les ON les.lest_id = imo.lest_id
	LEFT JOIN cadastro.pavimento_rua prua ON prua.prua_id = imo.prua_id
	LEFT JOIN cadastro.pavimento_calcada pcal ON pcal.pcal_id = imo.pcal_id
	LEFT JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id AND loc.greg_id IN(1,2)
	LEFT JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
	LEFT JOIN cadastro.setor_comercial sec ON imo.stcm_id = sec.stcm_id
	LEFT JOIN cadastro.quadra qdr ON qdr.qdra_id = imo.qdra_id
	LEFT JOIN micromedicao.rota rot ON rot.rota_id = qdr.rota_id
	LEFT JOIN faturamento.faturamento_grupo ftg ON rot.ftgr_id = ftg.ftgr_id
	LEFT JOIN cadastro.logradouro_bairro lgb ON lgb.lgbr_id = imo.lgbr_id
	LEFT JOIN cadastro.logradouro logr ON lgb.logr_id = logr.logr_id
	LEFT JOIN cadastro.bairro bai ON bai.bair_id = lgb.bair_id
	LEFT JOIN cadastro.municipio mun ON mun.muni_id = bai.muni_id
	LEFT JOIN cadastro.logradouro_cep lgc ON lgc.lgcp_id = imo.lgcp_id
	LEFT JOIN cadastro.cep cep ON cep.cep_id = lgc.cep_id
	LEFT JOIN cadastro.logradouro_tipo lgt ON lgt.lgtp_id = logr.lgtp_id
WHERE
	les.lest_id = 3