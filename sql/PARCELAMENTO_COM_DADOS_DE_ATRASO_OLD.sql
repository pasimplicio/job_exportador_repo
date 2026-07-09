SELECT 	
	TMP.*,
	con_parcelamento.qtd AS "QTD PARCELAMENTO ATRASADO",
	con_parcelamento.valor AS "VALOR PARCELAMENTO ATRASADO",
	con_atraso.vl_agua AS "VALOR AGUA DEVIDO",
	con_atraso.vl_esgoto AS "VALOR ESGOTO DEVIDO",
	con_atraso.vl_debitos AS "VALOR DEBITOS DEVIDO",
	con_atraso.vl_creditos AS "VALOR CREDITOS DEVIDO",
	con_atraso.vl_impostos AS "VALOR IMPOSTOS DEVIDO",
	con_atraso.valor AS "VALOR TOTAL DEVIDO",
	con_atraso.qtd AS "QTD. CONTAS DEVIDO",
	con_atraso.min AS "MENOR REFERENCIA DEVIDO",
	con_atraso.max AS "MAIOR REFERENCIA DEVIDO",
	con_atraso.min_venc AS "MENOR VENCIMENTO",
	con_atraso.max_venc AS "MAIOR VENCIMENTO"
FROM
(SELECT
	par.parc_id AS "ID PARC",
	usu.usur_nmlogin AS "LOGIN",
	usu.usur_nmusuario AS "USUARIO",
	uno.unid_dsunidade AS "LOTACAO",
	par.imov_id AS "MATRICULA",
	cli.clie_nmcliente AS "NOME RESP",
	cli.clie_nncpf AS "CPF RESP",
	cli.clie_nncnpj AS "CNPJ RESP",
	(CASE cli.clie_iccpfcnpjvalidado
	WHEN 0 THEN 'NAO'
	WHEN 1 THEN 'SIM'
	ELSE 'NAO'
	END) AS "DOC VALIDADO RESP",
	(
		SELECT
			STRING_AGG('('||cfn.cfon_cdddd||')'||cfn.cfon_nnfone,' | ')
		FROM
			cadastro.cliente_fone cfn 
		WHERE
			cfn.clie_id = cli.clie_id
	) AS "TELEFONES RESP",
	cli.clie_dsemail AS "EMAIL RESP",
	cli_usu.clie_nmcliente AS "NOME IMOVEL",
	cli_usu.clie_nncpf AS "CPF IMOVEL",
	cli_usu.clie_nncnpj AS "CNPJ IMOVEL",
	(CASE cli_usu.clie_iccpfcnpjvalidado
	WHEN 0 THEN 'NAO'
	WHEN 1 THEN 'SIM'
	ELSE 'NAO'
	END) AS "DOC VALIDADO IMOVEL",
	(
		SELECT
			STRING_AGG('('||cfn.cfon_cdddd||')'||cfn.cfon_nnfone,' | ')
		FROM
			cadastro.cliente_fone cfn 
		WHERE
			cfn.clie_id = cli_usu.clie_id
	) AS "TELEFONES IMOVEL",
	cli_usu.clie_dsemail AS "EMAIL IMOVEL",
	une.uneg_id AS "GERENCIA",
	une.uneg_nmunidadenegocio AS "NOME UNIDADE",
	loc.loca_id AS "LOCALIDADE",
	loc.loca_nmlocalidade AS "NOME LOCALIDADE",
	rdi.rdir_nnresolucaodiretoria AS "RESOLUCAO DIRETORIA",
	ra.rgat_id AS "JUST ESPECIAL",
	TO_CHAR(par.parc_amreferenciafaturamento,'999999') AS "REFERENCIA PARC",
	pmd.pmdz_dsparcmtmotivodesfazer AS "MOTIVO DESF",
	TO_CHAR(par.parc_tmparcelamento,'dd/MM/yyyy') AS "DIA PARC",
	par.parc_vlconta AS "VL CONTA",
	par.parc_vlservicosacobrar AS "VL OUTROS SERV",
	par.parc_vlmulta AS "MULTA IMPONT",
	par.parc_vljurosmora AS "VL JUROS IMPONT",
	par.parc_vldebitoatualizado AS "VALOR DEBITO TOTAL",
	par.parc_vldescontodebtotal AS "VALOR DESCONTOS DEBITO",
	(par.parc_vlentrada+(par.parc_nnprestacoes*par.parc_vlprestacao)) AS "VALOR PARCELADO",
	par.parc_vlentrada AS "VALOR ENTRADA",
	par.parc_vljurosparcelamento AS "JUROS PARCELAMENTO",
	par.parc_nnprestacoes AS "NR PRESTACOES",
	par.parc_vlprestacao AS "VL PRESTACAO",	
	0.00 AS "DEVOLUCAO",
	((par.parc_vlentrada+(par.parc_nnprestacoes*par.parc_vlprestacao))) AS "VALOR TOTAL NEGOCIADO",
	prt.qtd AS "QTD DOCS",
	COALESCE(pagn.dt_pag, pagh.dt_pag) AS "DATA PAGAMENTO",
	(COALESCE(pagn.valor,0) + COALESCE(pagh.valor,0)) AS "VALOR PAGO ENTRADA",
	valor_pago_parcelas.valor_pago AS "VALOR PAGO PARCELAS"
FROM 
	cobranca.parcelamento par
	LEFT JOIN cadastro.cliente cli ON cli.clie_id = par.clie_id
	LEFT JOIN cadastro.cliente_imovel cim ON cim.imov_id = par.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
	LEFT JOIN cadastro.cliente cli_usu ON cli_usu.clie_id = cim.clie_id
	LEFT JOIN cadastro.localidade loc ON loc.loca_id = par.loca_id
	LEFT JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
	LEFT JOIN cobranca.resolucao_diretoria rdi ON rdi.rdir_id = par.rdir_id
	LEFT JOIN cobranca.parcel_motivo_desfazer pmd ON pmd.pmdz_id = par.pmdz_id
	LEFT JOIN faturamento.guia_pagamento gpg ON gpg.parc_id = par.parc_id
	LEFT JOIN faturamento.guia_pagamento_historico gpgh ON gpgh.parc_id = par.parc_id
	LEFT JOIN seguranca.usuario usu ON usu.usur_id = par.usur_id
	LEFT JOIN cadastro.unidade_organizacional uno ON uno.unid_id = usu.unid_id
	LEFT JOIN atendimentopublico.registro_atendimento ra ON ra.imov_id = par.imov_id AND ra.step_id = 942 AND TO_CHAR(ra.rgat_tmregistroatendimento, 'dd/MM/yyyy') = TO_CHAR(par.parc_tmparcelamento, 'dd/MM/yyyy')
	LEFT JOIN 
	(SELECT
		pag.gpag_id AS id,
		pag.pgmt_dtpagamento AS dt_pag,
		SUM(pag.pgmt_vlpagamento) AS valor
	 FROM 
		arrecadacao.pagamento pag
		INNER JOIN faturamento.guia_pagamento gpg ON gpg.gpag_id = pag.gpag_id AND NOT gpg.parc_id IS NULL
	 WHERE
		NOT pag.gpag_id IS NULL
	 GROUP BY 1,2
	) AS pagn ON pagn.id = gpg.gpag_id
	LEFT JOIN 
	(SELECT
		pag.gpag_id AS id,
		pag.pghi_dtpagamento AS dt_pag,
		SUM(pag.pghi_vlpagamento) AS valor
	 FROM 
		arrecadacao.pagamento_historico pag
		INNER JOIN faturamento.guia_pagamento_historico gpg ON gpg.gpag_id = pag.gpag_id AND NOT gpg.parc_id IS NULL
	 WHERE
		NOT pag.gpag_id IS NULL
	 GROUP BY 1,2
	) AS pagh ON pagh.id = gpgh.gpag_id
	LEFT JOIN (
			SELECT
				pct.parc_id AS parc_id,
				COUNT(pct.pcit_id) AS qtd
			FROM
				cobranca.parcelamento_item pct
			GROUP BY 1) prt ON prt.parc_id = par.parc_id
	LEFT JOIN (
			SELECT
				parc_id,
				SUM(valor_pago) as valor_pago
			FROM
			(SELECT
					dch.parc_id AS parc_id,
					SUM(dco.dbhi_vlprestacao) AS valor_pago
				FROM
					faturamento.conta_historico con
					INNER JOIN faturamento.debito_cobrado_historico dco ON dco.cnta_id = con.cnta_id
					INNER JOIN faturamento.debito_a_cobrar_geral dcg ON dcg.dbac_id = dco.dbac_id AND dcg.dage_ichistorico = 1
					INNER JOIN faturamento.deb_a_cobrar_hist dch ON dch.dbac_id = dcg.dbac_id
					INNER JOIN arrecadacao.pagamento_historico pgh ON pgh.cnta_id = con.cnta_id AND pgh.pgst_idatual = 0
					INNER JOIN cobranca.parcelamento par ON par.parc_id = dch.parc_id
				WHERE
					par.parc_tmparcelamento >= '2019-10-01'
				GROUP BY 1
			UNION
				SELECT
					dch.parc_id AS parc_id,
					SUM(dco.dbhi_vlprestacao) AS valor_pago
				FROM
					faturamento.conta_historico con
					INNER JOIN faturamento.debito_cobrado_historico dco ON dco.cnta_id = con.cnta_id
					INNER JOIN faturamento.debito_a_cobrar_geral dcg ON dcg.dbac_id = dco.dbac_id AND dcg.dage_ichistorico = 2
					INNER JOIN faturamento.debito_a_cobrar dch ON dch.dbac_id = dcg.dbac_id
					INNER JOIN arrecadacao.pagamento_historico pgh ON pgh.cnta_id = con.cnta_id AND pgh.pgst_idatual = 0
					INNER JOIN cobranca.parcelamento par ON par.parc_id = dch.parc_id
				WHERE
					par.parc_tmparcelamento >= '2019-10-01'
				GROUP BY 1
			UNION
				SELECT
					dch.parc_id AS parc_id,
					SUM(dco.dbcb_vlprestacao) AS valor_pago
				FROM
					faturamento.conta con
					INNER JOIN faturamento.debito_cobrado dco ON dco.cnta_id = con.cnta_id
					INNER JOIN faturamento.debito_a_cobrar_geral dcg ON dcg.dbac_id = dco.dbac_id AND dcg.dage_ichistorico = 2
					INNER JOIN faturamento.debito_a_cobrar dch ON dch.dbac_id = dcg.dbac_id
					INNER JOIN arrecadacao.pagamento pgh ON pgh.cnta_id = con.cnta_id AND pgh.pgst_idatual = 0
					INNER JOIN cobranca.parcelamento par ON par.parc_id = dch.parc_id
				WHERE
					par.parc_tmparcelamento >= '2019-10-01'
				GROUP BY 1
			UNION
				SELECT
					dch.parc_id AS parc_id,
					SUM(dco.dbcb_vlprestacao) AS valor_pago
				FROM
					faturamento.conta con
					INNER JOIN faturamento.debito_cobrado dco ON dco.cnta_id = con.cnta_id
					INNER JOIN faturamento.debito_a_cobrar_geral dcg ON dcg.dbac_id = dco.dbac_id AND dcg.dage_ichistorico = 1
					INNER JOIN faturamento.deb_a_cobrar_hist dch ON dch.dbac_id = dcg.dbac_id
					INNER JOIN arrecadacao.pagamento pgh ON pgh.cnta_id = con.cnta_id AND pgh.pgst_idatual = 0
					INNER JOIN cobranca.parcelamento par ON par.parc_id = dch.parc_id
				WHERE
					par.parc_tmparcelamento >= '2019-10-01'
				GROUP BY 1) AS TMP
				GROUP BY 1) AS valor_pago_parcelas ON valor_pago_parcelas.parc_id = par.parc_id
WHERE
	(par.parc_tmparcelamento >= '2019-10-01')
UNION
SELECT
	cdb.cbdo_id AS "ID PARC",
	usu.usur_nmlogin AS "LOGIN",
	usu.usur_nmusuario AS "USUARIO",
	uno.unid_dsunidade AS "LOTACAO",
	cdb.imov_id AS "MATRICULA",
	cli.clie_nmcliente AS "NOME RESP",
	cli.clie_nncpf AS "CPF RESP",
	cli.clie_nncnpj AS "CNPJ RESP",
	(CASE cli.clie_iccpfcnpjvalidado
	WHEN 0 THEN 'NAO'
	WHEN 1 THEN 'SIM'
	ELSE 'NAO'
	END) AS "DOC VALIDADO RESP",
	(
		SELECT
			STRING_AGG('('||cfn.cfon_cdddd||')'||cfn.cfon_nnfone,' | ')
		FROM
			cadastro.cliente_fone cfn 
		WHERE
			cfn.clie_id = cli.clie_id
	) AS "TELEFONES RESP",
	cli.clie_dsemail AS "EMAIL",
	cli.clie_nmcliente AS "NOME IMOVEL",
	cli.clie_nncpf AS "CPF IMOVEL",
	cli.clie_nncnpj AS "CNPJ IMOVEL",
	(CASE cli.clie_iccpfcnpjvalidado
	WHEN 0 THEN 'NAO'
	WHEN 1 THEN 'SIM'
	ELSE 'NAO'
	END) AS "DOC VALIDADO IMOVEL",
	(
		SELECT
			STRING_AGG('('||cfn.cfon_cdddd||')'||cfn.cfon_nnfone,' | ')
		FROM
			cadastro.cliente_fone cfn 
		WHERE
			cfn.clie_id = cli.clie_id
	) AS "TELEFONES IMOVEL",
	cli.clie_dsemail AS "EMAIL IMOVEL",
	une.uneg_id AS "GERENCIA",
	une.uneg_nmunidadenegocio AS "NOME UNIDADE",
	loc.loca_id AS "LOCALIDADE",
	loc.loca_nmlocalidade AS "NOME LOCALIDADE",
	rdi.rdir_nnresolucaodiretoria AS "RESOLUCAO DIRETORIA",
	ra.rgat_id AS "JUST ESPECIAL",
	TO_CHAR(cdb.cbdo_tmemissao,'yyyyMM') AS "REFERENCIA PARC",
	'EXTRATO' AS "MOTIVO DESF",
	TO_CHAR(cdb.cbdo_tmemissao,'dd/MM/yyyy') AS "DIA PARC",
	0.00 AS "VL CONTA",
	0.00 AS "VL OUTROS SERV",
	0.00 AS "MULTA IMPONT",
	0.00 AS "VL JUROS IMPONT",
	0.00 AS "VALOR DEBITO TOTAL",
	cdb.cbdo_vldesconto AS "VALOR DESCONTOS DEBITO",
	cdb.cbdo_vldocumento AS "VALOR PARCELADO",
	cdb.cbdo_vldocumento AS "VALOR ENTRADA",
	0.00 AS "JUROS PARCELAMENTO",
	0 AS "NR PRESTACOES",
	0.00 AS "VL PRESTACAO",
	COALESCE(devolucao.valor,0)+COALESCE(devolucaoh.valor,0) AS "DEVOLUCAO",
	(cdb.cbdo_vldesconto+cdb.cbdo_vldocumento) AS "VALOR TOTAL NEGOCIADO",
	cbi.qtd AS "QTD DOCS",
	COALESCE(pagn.dt_pag, pagh.dt_pag) AS "DATA PAGAMENTO",
	(COALESCE(pagn.valor,0) + COALESCE(pagh.valor,0)) AS "VALOR PAGO ENTRADA",
	0.00 AS "VALOR PAGO PARCELAS"
FROM 
	cobranca.cobranca_documento cdb
	INNER JOIN cobranca.resolucao_diretoria rdi ON rdi.rdir_id = cdb.rdir_id
	LEFT JOIN cadastro.cliente_imovel cim ON cim.imov_id = cdb.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
	LEFT JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
	LEFT JOIN cadastro.localidade loc ON loc.loca_id = cdb.loca_id
	LEFT JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
	LEFT JOIN seguranca.usuario usu ON usu.usur_id = cdb.usur_id
	LEFT JOIN cadastro.unidade_organizacional uno ON uno.unid_id = usu.unid_id
	LEFT JOIN atendimentopublico.registro_atendimento ra ON ra.imov_id = cdb.imov_id AND ra.step_id = 942 AND TO_CHAR(ra.rgat_tmregistroatendimento, 'dd/MM/yyyy') = TO_CHAR(cdb.cbdo_tmemissao, 'dd/MM/yyyy')
	LEFT JOIN 
	(SELECT
		pag.cbdo_id AS id,
		pag.pgmt_dtpagamento AS dt_pag,
		SUM(pag.pgmt_vlpagamento) AS valor
	 FROM 
		arrecadacao.pagamento pag
		INNER JOIN cobranca.cobranca_documento cdb ON cdb.cbdo_id = pag.cbdo_id AND NOT cdb.rdir_id IS NULL
	 WHERE
		NOT pag.cbdo_id IS NULL
	 GROUP BY 1,2
	) AS pagn ON pagn.id = cdb.cbdo_id
	LEFT JOIN 
	(SELECT
		pag.cbdo_id AS id,
		pag.pghi_dtpagamento AS dt_pag,
		SUM(pag.pghi_vlpagamento) AS valor
	 FROM 
		arrecadacao.pagamento_historico pag
		INNER JOIN cobranca.cobranca_documento cdb ON cdb.cbdo_id = pag.cbdo_id AND NOT cdb.rdir_id IS NULL
	 WHERE
		NOT pag.cbdo_id IS NULL
	 GROUP BY 1,2
	) AS pagh ON pagh.id = cdb.cbdo_id
	LEFT JOIN 
	(SELECT
		dev.cbdo_id AS id,
		SUM(dev.devl_vldevolucao) AS valor
	 FROM 
		arrecadacao.devolucao dev
	 GROUP BY 1
	) AS devolucao ON devolucao.id = cdb.cbdo_id
	LEFT JOIN 
	(SELECT
		dev.cbdo_id AS id,
		SUM(dev.dehi_vldevolucao) AS valor
	 FROM 
		arrecadacao.devolucao_historico dev
	 GROUP BY 1
	) AS devolucaoh ON devolucaoh.id = cdb.cbdo_id
	LEFT JOIN (
		SELECT
			cbi.cbdo_id AS cbdo_id,
			COUNT(cbi.cdit_id) AS qtd
		FROM
			cobranca.cobranca_documento_item cbi
		GROUP BY 1) cbi ON cbi.cbdo_id = cdb.cbdo_id
WHERE
	cdb.cbdo_tmemissao >= '2019-10-01') AS TMP
	LEFT JOIN (	SELECT 
				con4.imov_id AS mat1,
				SUM(con4.cnta_vlagua) AS vl_agua,
				SUM(con4.cnta_vlesgoto) AS vl_esgoto,
				SUM(con4.cnta_vldebitos) AS vl_debitos,
				SUM(con4.cnta_vlcreditos) AS vl_creditos,
				SUM(con4.cnta_vlimpostos) AS vl_impostos,
				COUNT(con4.cnta_id) AS qtd,
				MIN(con4.cnta_amreferenciaconta) AS min,
				MAX(con4.cnta_amreferenciaconta) AS max,
				MIN(con4.cnta_dtvencimentoconta) AS min_venc,
				MAX(con4.cnta_dtvencimentoconta) AS max_venc,
				SUM(con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos) AS valor
			FROM faturamento.conta con4 
			WHERE 
				con4.dcst_idatual IN (0,1,2) AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con4.cnta_id) AND con4.cnta_dtvencimentoconta < CURRENT_DATE AND con4.cnta_dtrevisao IS NULL AND con4.iper_id <> 6
			GROUP BY 1) AS con_atraso ON con_atraso.mat1 = TMP."MATRICULA"
	LEFT JOIN (	SELECT 
				con4.imov_id AS mat1,
				COUNT(distinct con4.cnta_id) AS qtd,
				SUM(dco.dbcb_vlprestacao) AS valor
			FROM faturamento.conta con4 
				INNER JOIN faturamento.debito_cobrado dco ON dco.cnta_id = con4.cnta_id AND dco.dbtp_id IN (40,43,44)
			WHERE 
				con4.dcst_idatual IN (0,1,2) AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con4.cnta_id) AND con4.cnta_dtvencimentoconta < CURRENT_DATE AND con4.cnta_dtrevisao IS NULL AND con4.iper_id <> 6
			GROUP BY 1) AS con_parcelamento ON con_parcelamento.mat1 = TMP."MATRICULA"
ORDER BY 2