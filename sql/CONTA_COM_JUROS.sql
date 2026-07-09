SELECT
	con4.cnhi_dtvencimentoconta AS vencimento,
	con4.cnhi_vlagua+con4.cnhi_vlesgoto+con4.cnhi_vldebitos-con4.cnhi_vlcreditos-con4.cnhi_vlimpostos AS valor,
	TRUNC(((con4.cnhi_vlagua+con4.cnhi_vlesgoto+con4.cnhi_vldebitos-con4.cnhi_vlcreditos-con4.cnhi_vlimpostos)*0.02)::NUMERIC,2) AS "MULTA POR IMPONTUALIDADE",
	TRUNC(((con4.cnhi_vlagua+con4.cnhi_vlesgoto+con4.cnhi_vldebitos-con4.cnhi_vlcreditos-con4.cnhi_vlimpostos)*0.005*(((EXTRACT(YEAR FROM CURRENT_DATE)-EXTRACT(YEAR FROM con4.cnhi_dtvencimentoconta))*12)+(EXTRACT(MONTH FROM CURRENT_DATE)-EXTRACT(MONTH FROM con4.cnhi_dtvencimentoconta))))::NUMERIC, 2) AS "JUROS DE MORA"
FROM
	faturamento.conta_historico con4
WHERE
	cnta_id = VAR_CONTA