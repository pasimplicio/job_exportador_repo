SELECT
	SUM(valor)
FROM
	(SELECT 
		con4.imov_id AS mat1,
		COUNT(distinct con4.cnta_id) AS qtd,
		SUM(dco.dbcb_vlprestacao) AS valor
	FROM faturamento.conta con4 
		INNER JOIN faturamento.debito_cobrado dco ON dco.cnta_id = con4.cnta_id
		INNER JOIN faturamento.debito_a_cobrar dac ON dac.dbac_id = dco.dbac_id
	WHERE 
		con4.dcst_idatual IN (0,1,2) 
		AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con4.cnta_id)
		AND dac.parc_id = VAR_PARCELAMENTO
	GROUP BY 1
UNION
	SELECT 
		con4.imov_id AS mat1,
		COUNT(distinct con4.cnta_id) AS qtd,
		SUM(dco.dbcb_vlprestacao) AS valor
	FROM faturamento.conta con4 
		INNER JOIN faturamento.debito_cobrado dco ON dco.cnta_id = con4.cnta_id
		INNER JOIN faturamento.deb_a_cobrar_hist dac ON dac.dbac_id = dco.dbac_id
	WHERE 
		con4.dcst_idatual IN (0,1,2) 
		AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con4.cnta_id)
		AND dac.parc_id = VAR_PARCELAMENTO
	GROUP BY 1) AS faturado