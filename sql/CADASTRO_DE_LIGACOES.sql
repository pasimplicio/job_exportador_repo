SELECT
	lagu.lagu_id AS "ID",
	lagu.lagu_dtimplantacao AS "DT IMPLANTACAO",
	rli.rlin_dsramallocalinstalcao AS "LOCAL DE INSTALACAO",
	lor.lgor_dsligacaoorigem AS "ORIGEM",
	lad.lagd_dsligacaoaguadiametro AS "DIAMETRO",
	lam.lagm_dsligacaoaguamaterial AS "MATERIAL",
	lap.lapf_dsligacaoaguaperfil AS "PERFIL DA LIGACAO",
	imo.imov_id AS "MATRICULA IMOVEL",
	las.last_dsligacaoaguasituacao AS "SITUACAO",
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
	atendimentopublico.ligacao_agua lagu
	LEFT JOIN atendimentopublico.ramal_local_instalacao rli ON rli.rlin_id = lagu.rlin_id
	LEFT JOIN atendimentopublico.ligacao_origem lor ON lor.lgor_id = lagu.lgor_id
	LEFT JOIN atendimentopublico.ligacao_agua_diametro lad ON lad.lagd_id = lagu.lagd_id
	LEFT JOIN atendimentopublico.ligacao_agua_material lam ON lam.lagm_id = lagu.lagm_id
	LEFT JOIN atendimentopublico.ligacao_agua_perfil lap ON lap.lapf_id = lagu.lapf_id
	LEFT JOIN cadastro.imovel imo ON imo.imov_id = lagu.lagu_id
	LEFT JOIN atendimentopublico.ligacao_agua_situacao las ON las.last_id = imo.last_id
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
	--LIMIT 1000
	