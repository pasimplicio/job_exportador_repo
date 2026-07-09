SELECT
	imo.imov_id AS "Matricula",
	TO_CHAR(imo.imov_nncoordenaday,'990D999999999999999') AS "Latitude",
	TO_CHAR(imo.imov_nncoordenadax,'990D999999999999999') AS "Longitude",
	cli.clie_id AS "Codigo Cliente",
	ipe.iper_dsimovelperfil AS "Perfil",
	cat.catg_dscategoria AS "Categoria Principal",
	sca.scat_dssubcategoria AS "Subcategoria Principal",
	imo.imov_qteconomia AS "Economias",
	imo.loca_id AS "Localidade",
	bai.bair_nmbairro AS "Bairro",
	las.last_dsligacaoaguasituacao AS "Situacao Agua",
	les.lest_dsligacaoesgotosituacao AS "Situacao Esgoto"

FROM
	cadastro.imovel imo
	INNER JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
	INNER JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
	INNER JOIN atendimentopublico.ligacao_agua_situacao las ON las.last_id = imo.last_id
	INNER JOIN atendimentopublico.ligacao_esgoto_situacao les ON les.lest_id = imo.lest_id
	INNER JOIN cadastro.logradouro_bairro lgb ON lgb.lgbr_id = imo.lgbr_id
	INNER JOIN cadastro.bairro bai ON bai.bair_id = lgb.bair_id
	LEFT JOIN atendimentopublico.ligacao_agua lagu ON lagu.lagu_id = imo.imov_id
	LEFT JOIN cadastro.imovel_perfil ipe ON imo.iper_id = ipe.iper_id
	LEFT JOIN cadastro.categoria cat ON imo.imov_idcategoriaprincipal = cat.catg_id
	LEFT JOIN cadastro.subcategoria sca ON imo.imov_idsubcategoriaprincipal = sca.scat_id

WHERE
	imo.imov_icexclusao = 2