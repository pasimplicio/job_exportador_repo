SELECT
	res.rele_amreferencia AS "REFERENCIA",
	une.uneg_nmunidadenegocio AS "UNIDADE DE NEGOCIO",
	mun.muni_nmmunicipio AS "NOME MUNICIPIO",
	(CASE res.rele_ichidrometro
	WHEN 1 THEN 'COM HD'
	ELSE 'SEM HD'
	END) AS "INDICADOR HIDROMETRO",
	las.last_dsligacaoaguasituacao AS "SITUACAO AGUA",
	les.lest_dsligacaoesgotosituacao AS "SITUACAO ESGOTO",
	SUM(res.rele_qtligacoes) AS "LIGACOES CADASTRADAS",
	SUM(res.rele_qteconomias) AS "ECONOMIAS CADASTRADAS",
	fat.lig_fat AS "LIGACOES FATURADAS",
	mmd.lig_med AS "LIGACOES MEDIDAS",
	fat.ecn_fat AS "ECONOMIAS FATURADAS",
	mmd.ecn_med AS "ECONOMIAS MEDIDAS",
	fat.vol_ag AS "VOLUME AGUA FATURADO",
	mmd.vol_ag_med AS "VOLUME DE AGUA MEDIDO FATURADO",
	fat.vol_esg AS "VOLUME ESGOTO FATURADO",
	mmd.vol_es_med AS "VOLUME DE ESGOTO MEDIDO FATURADO",
	fat.vl_ag AS "VALOR AGUA FATURADO",
	fat.vl_esg AS "VALOR ESGOTO FATURADO",
	arr.lig_arr AS "DOCS ARRECADADOS",
	arr.vl_ag AS "VALOR AGUA ARRECADADO",
	arr.vl_esg AS "VALOR ESGOTO ARRECADADO",
	arr.vl_total AS "VALOR TOTAL ARRECADADO"
FROM
	cadastro.un_res_lig_econ res
	INNER JOIN cadastro.g_localidade loc ON loc.loca_id = res.loca_id
	INNER JOIN cadastro.g_municipio mun ON mun.muni_id = loc.muni_idprincipal
	INNER JOIN cadastro.g_unidade_negocio une ON une.uneg_id = loc.uneg_id
	LEFT JOIN atendimentopublico.g_ligacao_agua_situacao las ON las.last_id = res.last_id
	LEFT JOIN atendimentopublico.g_lig_esgoto_sit les ON les.lest_id = res.lest_id
	LEFT JOIN (
		SELECT
			fat.refa_amreferencia AS refe,
			une.uneg_id AS uneg_id,
			mun.muni_id AS muni_id,
			fat.refa_ichidrometro AS ichd,
			las.last_id AS last_id,
			les.lest_id AS lest_id,
			SUM(fat.refa_qtcontasemitidas) AS lig_fat,
			SUM(fat.refa_qteconomiasfaturadas) AS ecn_fat,
			SUM(fat.refa_vofaturadoagua) AS vol_ag,
			SUM(fat.refa_vofaturadoesgoto) AS vol_esg,
			SUM(fat.refa_vlfaturadoagua) AS vl_ag,
			SUM(fat.refa_vlfaturadoesgoto) AS vl_esg
		FROM
			faturamento.un_resumo_faturamento fat
			LEFT JOIN cadastro.g_localidade loc ON loc.loca_id = fat.loca_id
			LEFT JOIN cadastro.g_municipio mun ON mun.muni_id = loc.muni_idprincipal
			LEFT JOIN cadastro.g_unidade_negocio une ON une.uneg_id = loc.uneg_id
			LEFT JOIN atendimentopublico.g_ligacao_agua_situacao las ON las.last_id = fat.last_id
			LEFT JOIN atendimentopublico.g_lig_esgoto_sit les ON les.lest_id = fat.lest_id
		WHERE
			fat.refa_amreferencia >=202101 AND fat.refa_amreferencia <= 202112
		GROUP BY 1,2,3,4,5,6
	) AS fat ON fat.refe = res.rele_amreferencia AND fat.uneg_id = une.uneg_id AND fat.muni_id = mun.muni_id AND fat.ichd = res.rele_ichidrometro
	AND fat.last_id = las.last_id AND fat.lest_id = les.lest_id
	LEFT JOIN (
		SELECT
			arr.rear_amreferencia AS refe,
			une.uneg_id AS uneg_id,
			mun.muni_id AS muni_id,
			arr.rear_ichidrometro AS ichd,
			las.last_id AS last_id,
			les.lest_id AS lest_id,
			SUM(arr.rear_qtcontas) AS lig_arr,
			SUM(arr.rear_vlagua) AS vl_ag,
			SUM(arr.rear_vlesgoto) AS vl_esg,
			SUM(arr.rear_vldocsrecebidosoutros) AS vl_outros,
			SUM(arr.rear_vlnaoidentificado) AS vl_niden,
			SUM(arr.rear_vldocsrecebidoscredito) AS vl_cred,
			SUM(arr.rear_vlimpostos) AS vl_impos,
			SUM(arr.rear_vldevolucoesclassificadas) AS vl_dev_class,
			SUM(arr.rear_vldevolucoesnaoclassif) AS vl_dev_n_class,
			SUM(arr.rear_vlagua+arr.rear_vlesgoto+arr.rear_vldocsrecebidosoutros+arr.rear_vlnaoidentificado-arr.rear_vldocsrecebidoscredito-arr.rear_vlimpostos-arr.rear_vldevolucoesclassificadas-arr.rear_vldevolucoesnaoclassif) AS vl_total
		FROM
			arrecadacao.un_resumo_arrecadacao arr
			LEFT JOIN cadastro.g_localidade loc ON loc.loca_id = arr.loca_id
			LEFT JOIN cadastro.g_municipio mun ON mun.muni_id = loc.muni_idprincipal
			LEFT JOIN cadastro.g_unidade_negocio une ON une.uneg_id = loc.uneg_id
			LEFT JOIN atendimentopublico.g_ligacao_agua_situacao las ON las.last_id = arr.last_id
			LEFT JOIN atendimentopublico.g_lig_esgoto_sit les ON les.lest_id = arr.lest_id
		WHERE
			arr.rear_amreferencia >= 202101 AND arr.rear_amreferencia <= 202112
		GROUP BY 1,2,3,4,5,6
	) AS arr ON arr.refe = res.rele_amreferencia AND arr.uneg_id = une.uneg_id AND arr.muni_id = mun.muni_id AND arr.ichd = res.rele_ichidrometro
	AND arr.last_id = las.last_id AND arr.lest_id = les.lest_id
	LEFT JOIN(
		SELECT
			mmd.reca_amreferencia AS refe,
			une.uneg_id AS uneg_id,
			mun.muni_id AS muni_id,
			1 AS ichd,
			las.last_id AS last_id,
			les.lest_id AS lest_id,
			SUM(mmd.reca_qtligacoes_com_med_real) AS lig_med,
			SUM(mmd.reca_qteconomias_com_med_real) AS ecn_med,
			SUM(mmd.reca_consumoagua_com_med_real) AS vol_ag_med,
			SUM(mmd.rece_vofaturadoesgotomedido) AS vol_es_med
		FROM
			micromedicao.un_resi_des_mmd mmd
			LEFT JOIN cadastro.g_localidade loc ON loc.loca_id = mmd.loca_id
			LEFT JOIN cadastro.g_municipio mun ON mun.muni_id = loc.muni_idprincipal
			LEFT JOIN cadastro.g_unidade_negocio une ON une.uneg_id = loc.uneg_id
			LEFT JOIN atendimentopublico.g_ligacao_agua_situacao las ON las.last_id = mmd.last_id
			LEFT JOIN atendimentopublico.g_lig_esgoto_sit les ON les.lest_id = mmd.lest_id
		WHERE
			mmd.reca_amreferencia >=202101 AND mmd.reca_amreferencia <= 202112
		GROUP BY 1,2,3,4,5,6
	) AS mmd ON mmd.refe = res.rele_amreferencia AND mmd.uneg_id = une.uneg_id AND mmd.muni_id = mun.muni_id AND mmd.ichd = res.rele_ichidrometro
	AND mmd.last_id = las.last_id AND mmd.lest_id = les.lest_id
WHERE
	res.rele_amreferencia >=202101 AND res.rele_amreferencia <= 202112
GROUP BY 1,2,3,4,5,6,9,10,11,12,13,14,15,16,17,18,19,20,21,22