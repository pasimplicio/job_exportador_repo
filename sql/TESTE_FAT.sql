


SELECT
	TO_CHAR(SUM(cnta_vlagua+cnta_vlesgoto+cnta_vldebitos-cnta_vlcreditos), '999G999G990D00') AS "valor"
FROM
	faturamento.conta
WHERE
	cnta_amreferenciaconta = 202401 AND dcst_idatual IN (0, 1, 2, 5)

UNION


SELECT
	TO_CHAR(SUM(cnhi_vlagua+cnhi_vlesgoto+cnhi_vldebitos-cnhi_vlcreditos), '999G999G990D00') AS "valor"
FROM
	faturamento.conta_historico
WHERE
	cnhi_amreferenciaconta = 202401 AND dcst_idatual IN (0, 1, 2, 5)