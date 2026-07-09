SELECT
	rle.rele_amreferencia AS "REFERENCIA",
	COALESCE(mun.muni_nmmunicipio, 'SAO LUIS') AS "MUNICIPIO",
	COALESCE(bai.bair_nmbairro, rle.uneg_id::TEXT ||'-'|| rle.stcm_id::TEXT ||'-'|| rle.rota_id::TEXT ||'-'|| rle.qdra_id::TEXT) AS "BAIRRO",
	cat.catg_dscategoria AS "CATEGORIA DE CONSUMO",
	las.last_dsligacaoaguasituacao AS "SIT. AGUA",
	les.lest_dsligacaoesgotosituacao AS "SIT.ESGOTO",
	SUM(rle.rele_qtligacoes) AS "TOTAL LIGACOES",
	SUM(rle.rele_qteconomias) AS "QTD ECONOMIAS"
FROM
	cadastro.un_res_lig_econ rle
	LEFT JOIN cadastro.g_bairro bai ON bai.bair_id = rle.bair_id
	LEFT JOIN cadastro.g_municipio mun ON mun.muni_id = bai.muni_id
	LEFT JOIN atendimentopublico.g_ligacao_agua_situacao las ON las.last_id = rle.last_id
	LEFT JOIN atendimentopublico.g_lig_esgoto_sit les ON les.lest_id = rle.lest_id
	LEFT JOIN cadastro.g_categoria cat ON cat.catg_id = rle.catg_id
WHERE
	--mun.muni_nmmunicipio = 'SAO LUIS' AND
	rle.rele_amreferencia >= 201501 AND
	rle.uneg_id IN (11,12,13,14,15)
GROUP BY 1,2,3,4,5,6