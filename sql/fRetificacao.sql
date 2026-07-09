	SELECT
		con.imov_id AS "Matricula",
		TO_CHAR(con.cnta_dtretificacao, 'dd/MM/yyyy') AS "Data Retificacao",
		imo.loca_id AS "Localidade",
		TO_CHAR((con.cnta_vlagua + con.cnta_vlesgoto + con.cnta_vldebitos - con.cnta_vlcreditos - con.cnta_vlimpostos), '999G999G990D00') AS "Valor Fatura Retificado"
	FROM
		faturamento.conta con
		INNER JOIN cadastro.imovel imo ON imo.imov_id = con.imov_id
		LEFT JOIN atendimentopublico.ligacao_agua lagu ON lagu.lagu_id = imo.imov_id
		LEFT JOIN micromedicao.hidrometro_inst_hist his ON lagu.hidi_id = his.hidi_id AND his.hidi_dtretiradahidrometro IS NULL
		LEFT JOIN micromedicao.hidrometro hid ON his.hidr_id = hid.hidr_id
	WHERE
		con.dcst_idatual = 1 AND
		con.cnta_amreferenciaconta = '${VAR_REFERENCIA}' AND
		hid.hidr_nnhidrometro <> ''
		--con.cnta_dtretificacao >= '2020-01-01'
		--AND con.imov_id = 5327741
	ORDER BY 1