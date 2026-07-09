SELECT
	TO_CHAR(ren.rneg_dtprocessamentoenvio,'yyyyMM') AS "REFERENCIA",
	TO_CHAR(rneg_dtprocessamentoenvio, 'dd/MM/yyyy') AS "DATA ENVIO",
	une.uneg_nmunidadenegocio AS "UNIDADE",
	(CASE
		WHEN ren.rneg_icnegativconfirmada = 1 THEN 'INCLUIDAS E CONFIRMADAS'
		WHEN ren.rneg_icnegativconfirmada = 2 THEN 'INCLUIDAS E NAO CONFIRMADAS'
		ELSE 'DESCONHECIDO'
	END) AS "CONFIRMACAO",
	cds.cdst_dssituacaodebito AS "COB SIT",
	SUM(ren.rneg_qtinclusoes) AS "INCLUSOES",
	SUM(ren.rneg_vldebito) AS "VALOR INCLUIDO",
	SUM(ren.rneg_vlpendente) AS "VALOR PENDENTE",
	SUM(ren.rneg_vlpago) AS "VALOR PAGO",
	SUM(ren.rneg_vlparcelado) AS "VALOR PARCELADO",
	SUM(ren.rneg_vlcancelado) AS "VALOR CANCELADO"
FROM
	cobranca.resumo_negativacao ren
	INNER JOIN cobranca.cobranca_debito_situacao cds on ren.cdst_id = cds.cdst_id
	LEFT JOIN cadastro.unidade_negocio une ON une.uneg_id = ren.uneg_id
WHERE
	ren.rneg_dtprocessamentoenvio >= CURRENT_DATE - INTERVAL '1y' AND ren.rneg_dtprocessamentoenvio <= CURRENT_DATE AND
	ren.rneg_nnexecresumonegat = (SELECT MAX(rneg_nnexecresumonegat) FROM cobranca.resumo_negativacao)
GROUP BY 1,2,3,4,5
ORDER BY 1,2,3,4,5