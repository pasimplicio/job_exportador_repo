

SELECT
	imov.imov_id AS "Matricula",
	muni.muni_nmmunicipio AS "Municipio",
	stcm.stcm_cdsetorcomercial AS "Setor Comercial",
	rota.rota_cdrota AS "Rota",
	cnhi.cnhi_nnconsumoagua AS "Consumo Medido 202310"
FROM
	cadastro.imovel imov
	INNER JOIN cadastro.municipio muni ON imov.municipio_caema = muni.muni_id
	LEFT JOIN faturamento.conta_historico cnhi ON imov.imov_id = cnhi.imov_id
	INNER JOIN cadastro.setor_comercial stcm ON imov.stcm_id = stcm.stcm_id
	INNER JOIN cadastro.quadra qdra ON qdra.qdra_id = imov.qdra_id
	INNER JOIN micromedicao.rota rota ON rota.rota_id = qdra.rota_id
	
WHERE
	cnhi.cnhi_amreferenciaconta = 202310
	AND muni.muni_id IN (1, 3, 145)
	--and imov.imov_id = 7152779
