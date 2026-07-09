SELECT
	imo.imov_id AS "Matricula",
	TO_CHAR(imo.imov_nncoordenadax,'990D999999999999999') AS "Latitude",
	TO_CHAR(imo.imov_nncoordenaday,'990D999999999999999') AS "Longitude",
	cli.clie_id AS "Codigo Cliente",
	ipe.iper_dsimovelperfil AS "Perfil",
	cat.catg_dscategoria AS "Categoria Principal",
	sca.scat_dssubcategoria AS "Subcategoria Principal",
	imo.imov_qteconomia AS "Economias",
	imo.loca_id AS "Codigo Localidade",
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
	AND imo.imov_id IN (
4201140,
3524035,
3524019,
3524515,
4201132,
4201124,
14773945,
4201116,
883565,
883727,
4200829,
4200810,
4200799,
4200810,
4200772,
3417255,
4200756,
3524302,
883310,
3524248,
3524493,
4200713,
883255,
3524396,
14797780,
14637545,
13577670,
13675893,
14170078,
14170051,
14797704,
14170035,
13886622,
14170019,
14797720,
14797747,
14797763,
11288833,
10195483,
10195548,
10195599,
10195440,
10195386,
4200799,
7050470,
883824,
883948,
883816)