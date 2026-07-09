SELECT
	SUM(valor_pago)
FROM
	(	SELECT
			'HISTORICO 1' AS origem,
			con.cnhi_amreferenciaconta AS referencia,
			SUM(dco.dbhi_vlprestacao) AS valor_pago
		FROM
			faturamento.conta_historico con
			INNER JOIN faturamento.debito_cobrado_historico dco ON dco.cnta_id = con.cnta_id
			INNER JOIN faturamento.debito_a_cobrar_geral dcg ON dcg.dbac_id = dco.dbac_id AND dcg.dage_ichistorico = 1
			INNER JOIN faturamento.deb_a_cobrar_hist dch ON dch.dbac_id = dcg.dbac_id
			INNER JOIN arrecadacao.pagamento_historico pgh ON pgh.cnta_id = con.cnta_id AND pgh.pgst_idatual = 0
		WHERE
			dch.parc_id = VAR_PARCELAMENTO
		GROUP BY 1,2
	UNION
		SELECT
			'HISTORICO 2' AS origem,
			con.cnhi_amreferenciaconta AS referencia,
			SUM(dco.dbhi_vlprestacao) AS valor_pago
		FROM
			faturamento.conta_historico con
			INNER JOIN faturamento.debito_cobrado_historico dco ON dco.cnta_id = con.cnta_id
			INNER JOIN faturamento.debito_a_cobrar_geral dcg ON dcg.dbac_id = dco.dbac_id AND dcg.dage_ichistorico = 2
			INNER JOIN faturamento.debito_a_cobrar dch ON dch.dbac_id = dcg.dbac_id
			INNER JOIN arrecadacao.pagamento_historico pgh ON pgh.cnta_id = con.cnta_id AND pgh.pgst_idatual = 0
		WHERE
			dch.parc_id = VAR_PARCELAMENTO
		GROUP BY 1,2
	UNION
		SELECT
			'ATUAL 2' AS origem,
			con.cnta_amreferenciaconta AS referencia,
			SUM(dco.dbcb_vlprestacao) AS valor_pago
		FROM
			faturamento.conta con
			INNER JOIN faturamento.debito_cobrado dco ON dco.cnta_id = con.cnta_id
			INNER JOIN faturamento.debito_a_cobrar_geral dcg ON dcg.dbac_id = dco.dbac_id AND dcg.dage_ichistorico = 2
			INNER JOIN faturamento.debito_a_cobrar dch ON dch.dbac_id = dcg.dbac_id
			INNER JOIN arrecadacao.pagamento pgh ON pgh.cnta_id = con.cnta_id AND pgh.pgst_idatual = 0
		WHERE
			dch.parc_id = VAR_PARCELAMENTO
		GROUP BY 1,2
	UNION
		SELECT
			'ATUAL 1' AS origem,
			con.cnta_amreferenciaconta AS referencia,
			SUM(dco.dbcb_vlprestacao) AS valor_pago
		FROM
			faturamento.conta con
			INNER JOIN faturamento.debito_cobrado dco ON dco.cnta_id = con.cnta_id
			INNER JOIN faturamento.debito_a_cobrar_geral dcg ON dcg.dbac_id = dco.dbac_id AND dcg.dage_ichistorico = 1
			INNER JOIN faturamento.deb_a_cobrar_hist dch ON dch.dbac_id = dcg.dbac_id
			INNER JOIN arrecadacao.pagamento pgh ON pgh.cnta_id = con.cnta_id AND pgh.pgst_idatual = 0
		WHERE
			dch.parc_id = VAR_PARCELAMENTO
		GROUP BY 1,2
	UNION
		SELECT
			'ENTRADA HISTORICO 2' AS origem,
			gpg.gphi_amreferenciacontabil AS referencia,
			pag.pghi_vlpagamento AS valor_pago
		FROM
			faturamento.guia_pagamento_historico gpg
			INNER JOIN arrecadacao.pagamento_historico pag ON pag.gpag_id = gpg.gpag_id AND pag.pgst_idatual = 0
		WHERE
			parc_id = VAR_PARCELAMENTO
	UNION
		SELECT
			'ENTRADA HISTORICO 1' AS origem,
			gpg.gpag_amreferenciacontabil AS referencia,
			pag.pghi_vlpagamento AS valor_pago
		FROM
			faturamento.guia_pagamento gpg
			INNER JOIN arrecadacao.pagamento_historico pag ON pag.gpag_id = gpg.gpag_id AND pag.pgst_idatual = 0
		WHERE
			parc_id = VAR_PARCELAMENTO
	UNION
		SELECT
			'ENTRADA ATUAL 1' AS origem,
			gpg.gpag_amreferenciacontabil AS referencia,
			pag.pgmt_vlpagamento AS valor_pago
		FROM
			faturamento.guia_pagamento gpg
			INNER JOIN arrecadacao.pagamento pag ON pag.gpag_id = gpg.gpag_id AND pag.pgst_idatual = 0
		WHERE
			parc_id = VAR_PARCELAMENTO
	UNION
		SELECT
			'ENTRADA ATUAL 2' AS origem,
			gpg.gphi_amreferenciacontabil AS referencia,
			pag.pgmt_vlpagamento AS valor_pago
		FROM
			faturamento.guia_pagamento_historico gpg
			INNER JOIN arrecadacao.pagamento pag ON pag.gpag_id = gpg.gpag_id AND pag.pgst_idatual = 0
		WHERE
			parc_id = VAR_PARCELAMENTO) AS pagos