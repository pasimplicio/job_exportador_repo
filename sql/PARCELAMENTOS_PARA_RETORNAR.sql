SELECT
	atrasados.*,
	TO_CHAR(par.parc_tmparcelamento,'dd/MM/yyyy') AS "DATA PARCELAMENTO",
	TO_CHAR(par.parc_tmparcelamento,'HH24:mm:ss') AS "HORA PARCELAMENTO",
	par.parc_vlentrada AS "ENTRADA",
	par.parc_vldebitoatualizado AS "VALOR TOTAL NEGOCIADO",
	par.parc_vlconta AS "VALOR CONTAS",
	par.parc_vlguiapapagamento AS "VL GUIAS",
	par.parc_vlcreditoarealizar AS "VL CREDITOS",
	par.parc_vlservicosacobrar AS "VALOR SERVICOS",
	par.parc_vlparcelamentosacobrar AS "VALOR PARC A COB",
	par.parc_vlcreditoarealizar AS "VALOR CREDITO",
	par.parc_nnprestacoes AS "QTD PARCELAS",
	par.parc_vlprestacao AS "VALOR PARCELA"
FROM
	(SELECT
		dch.imov_id AS imov_id,
		dch.parc_id AS parc_id,
		COUNT(distinct dco.cnta_id) AS qtd_parc,
		SUM(dco.dbcb_vlprestacao) AS valor
	FROM
		faturamento.conta con
		INNER JOIN faturamento.debito_cobrado dco ON dco.cnta_id = con.cnta_id
		INNER JOIN faturamento.debito_a_cobrar_geral dcg ON dcg.dbac_id = dco.dbac_id AND dcg.dage_ichistorico = 1
		INNER JOIN faturamento.deb_a_cobrar_hist dch ON dch.dbac_id = dcg.dbac_id
		INNER JOIN faturamento.debito_tipo dbt ON dbt.dbtp_id = dco.dbtp_id
	WHERE
		con.dcst_idatual IN (0,1,2) AND 
		NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con.cnta_id) AND 
		con.cnta_dtvencimentoconta < CURRENT_DATE - INTERVAL '15d' AND 
		con.cnta_dtrevisao IS NULL AND 
		con.iper_id <> 6 AND
		NOT dch.parc_id IS NULL
	GROUP BY 1,2) atrasados
	INNER JOIN cobranca.parcelamento par ON atrasados.parc_id = par.parc_id
WHERE
	atrasados.qtd_parc >= 3
	--AND atrasados.imov_id = 167 
	AND par.rdir_id IN (11,12,13,14,15,16)
	--AND par.parc_id = 196419
	AND par.pcst_id = 1