SELECT 
	((CASE
		WHEN ("CPF RESP PARC" IS NULL AND "CNPJ RESP PARC" IS NULL) THEN 'CPF-CNPJ/'
		ELSE ''
	END) ||
	(CASE
		WHEN "DOC VALIDADO RESP PARC" = 'NAO' THEN 'VALIDACAO DOC/'
		ELSE ''
	END) ||
	(CASE
		WHEN "TELEFONES RESP PARC" IS NULL THEN 'TELEFONE/'
		ELSE ''
	END) ||
	(CASE
		WHEN "EMAIL RESP PARC" IS NULL THEN 'EMAIL/'
		ELSE ''
	END)) AS "DADOS PENDENTES RESP PARC",
	((CASE
		WHEN ("CPF IMOVEL" IS NULL AND "CNPJ IMOVEL" IS NULL) THEN 'CPF-CNPJ/'
		ELSE ''
	END) ||
	(CASE
		WHEN "DOC VALIDADO IMOVEL" = 'NAO' THEN 'VALIDACAO DOC/'
		ELSE ''
	END) ||
	(CASE
		WHEN "TELEFONES IMOVEL" IS NULL THEN 'TELEFONE/'
		ELSE ''
	END) ||
	(CASE
		WHEN "EMAIL IMOVEL" IS NULL THEN 'EMAIL/'
		ELSE ''
	END)) AS "DADOS PENDENTES TITULAR IMOVEL",
	(CASE
		WHEN (("CPF RESP PARC" IS NULL AND "CNPJ RESP PARC" IS NULL) OR "DOC VALIDADO RESP PARC" = 'NAO' OR "TELEFONES RESP PARC" IS NULL OR "EMAIL RESP PARC" IS NULL OR ("CPF IMOVEL" IS NULL AND "CNPJ IMOVEL" IS NULL) OR "DOC VALIDADO IMOVEL" = 'NAO' OR "TELEFONES IMOVEL" IS NULL OR "EMAIL IMOVEL" IS NULL) THEN 'NAO'
		ELSE 'SIM'
	 END) AS "ATUALIZADO",
	* 
FROM
(SELECT
	par.parc_id AS "ID PARC/DOC",
	'PARCELADO' AS "TIPO NEGOCIACAO",
	cbf.cbfm_dscobrancaforma AS "FORMA COBRANCA",
	usu.usur_nmlogin AS "LOGIN",
	usu.usur_nmusuario AS "USUARIO",
	uno.unid_dsunidade AS "LOTACAO",
	par.imov_id AS "MATRICULA",
	imo.imov_nncoordenadax AS "LATITUDE",
	imo.imov_nncoordenaday AS "LONGITUDE",
	cli.clie_nmcliente AS "NOME RESP PARC",
	cli.clie_nncpf AS "CPF RESP PARC",
	cli.clie_nncnpj AS "CNPJ RESP PARC",
	(CASE cli.clie_iccpfcnpjvalidado
	WHEN 0 THEN 'NAO'
	WHEN 1 THEN 'SIM'
	ELSE 'NAO'
	END) AS "DOC VALIDADO RESP PARC",
	(
		SELECT
			STRING_AGG('('||cfn.cfon_cdddd||')'||cfn.cfon_nnfone,' | ')
		FROM
			cadastro.cliente_fone cfn 
		WHERE
			cfn.clie_id = cli.clie_id
	) AS "TELEFONES RESP PARC",
	cli.clie_dsemail AS "EMAIL RESP PARC",
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
	TO_CHAR(par.parc_vlconta,'999G999G990D00') AS "VL CONTA",
	TO_CHAR(par.parc_vlservicosacobrar,'999G999G990D00') AS "VL OUTROS SERV",
	TO_CHAR(par.parc_vlmulta,'999G999G990D00') AS "MULTA IMPONT",
	TO_CHAR(par.parc_vljurosmora,'999G999G990D00') AS "VL JUROS IMPONT",
	TO_CHAR(par.parc_vldebitoatualizado,'999G999G990D00') AS "VALOR DEBITO ORIGINAL",
	TO_CHAR(par.parc_vldescontodebtotal,'999G999G990D00') AS "VALOR DESCONTOS DEBITO",
	TO_CHAR((par.parc_vlentrada+(par.parc_nnprestacoes*par.parc_vlprestacao)),'999G999G990D00') AS "VALOR PARCELADO",
	TO_CHAR(par.parc_vlentrada,'999G999G990D00') AS "VALOR ENTRADA",
	TO_CHAR(par.parc_vljurosparcelamento,'999G999G990D00') AS "JUROS PARCELAMENTO",
	par.parc_nnprestacoes AS "NR PRESTACOES",
	TO_CHAR(par.parc_vlprestacao,'999G999G990D00') AS "VL PRESTACAO",	
	TO_CHAR(par.parc_vlprestacao * par.parc_nnprestacoes,'999G999G990D00') AS "VALOR TOTAL PARCELAS",
	'0,00' AS "DEVOLUCAO",
	TO_CHAR((par.parc_vldebitoatualizado - ((par.parc_vlentrada+(par.parc_nnprestacoes*par.parc_vlprestacao)))),'999G999G990D00') AS "VALOR TOTAL DE DESCONTOS",
	TO_CHAR(((par.parc_vlentrada+(par.parc_nnprestacoes*par.parc_vlprestacao))),'999G999G990D00') AS "VALOR FINAL NEGOCIADO",
	prt.qtd AS "QTD DOCS",
	COALESCE(pagn.dt_pag, pagh.dt_pag) AS "DATA PAGAMENTO",
	TO_CHAR((COALESCE(pagn.valor,0) + COALESCE(pagh.valor,0)),'999G999G990D00') AS "VALOR PAGO ENTRADA",
	TO_CHAR((COALESCE(pagn.dt_pag,pagh.dt_pag)),'DD/MM/YYYY') AS "DATA PAGAMENTO ENTRADA",
	(CASE
		WHEN COALESCE(pagn.dt_pag,pagh.dt_pag, NULL) IS NULL THEN TO_CHAR(CURRENT_DATE - (COALESCE(gpg.gpag_dtvencimento, gpgh.gphi_dtvencimento)::DATE),'9G990')
		ELSE 'PAGO'
	 END
	) AS "ATRASO ENTRADA",
	TO_CHAR(COALESCE(valor_pago_parcelas.valor_pago,0),'999G999G990D00') AS "VALOR PAGO PARCELAS",
	parcelas_atrasadas.qtd AS "QTD DE PARCELAS ATRASADAS",
	TO_CHAR(COALESCE(parcelas_atrasadas.valor,0),'999G999G990D00') AS "VALOR PARCELAS ATRASADAS",
	TO_CHAR(((COALESCE(pagn.valor,0) + COALESCE(pagh.valor,0)) + COALESCE(valor_pago_parcelas.valor_pago,0)),'999G999G990D00') AS "VALOR PAGO TOTAL"
FROM 
	cobranca.parcelamento par
	LEFT JOIN cadastro.cliente cli ON cli.clie_id = par.clie_id
	LEFT JOIN cadastro.cliente_imovel cim ON cim.imov_id = par.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
	LEFT JOIN cadastro.imovel imo ON imo.imov_id = cim.imov_id
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
	LEFT JOIN cobranca.cobranca_forma cbf ON cbf.cbfm_id = par.cbfm_id
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
					par.parc_tmparcelamento >= '2020-06-01'
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
					par.parc_tmparcelamento >= '2020-06-01'
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
					par.parc_tmparcelamento >= '2020-06-01'
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
					par.parc_tmparcelamento >= '2020-06-01'
				GROUP BY 1) AS TMP
				GROUP BY 1) AS valor_pago_parcelas ON valor_pago_parcelas.parc_id = par.parc_id
	LEFT JOIN(
		SELECT
			COALESCE(dac.parc_id, dch.parc_id)  AS parc_id,
			COUNT(distinct con.cnta_id) AS qtd,
			SUM(dco.dbcb_vlprestacao) AS valor
		FROM
			faturamento.debito_cobrado dco
			INNER JOIN faturamento.conta con ON con.cnta_id = dco.cnta_id
			LEFT JOIN faturamento.deb_a_cobrar_hist dch ON dch.dbac_id = dco.dbac_id
			LEFT JOIN faturamento.debito_a_cobrar dac ON dac.dbac_id = dco.dbac_id
			LEFT JOIN cobranca.parcelamento par ON par.parc_id = COALESCE(dac.parc_id, dch.parc_id)
		WHERE
			con.dcst_idatual IN (0,1,2) AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con.cnta_id) AND con.cnta_dtvencimentoconta < CURRENT_DATE AND con.cnta_dtrevisao IS NULL AND con.iper_id <> 6 AND
			par.parc_tmparcelamento >= '2020-06-01'
		GROUP BY 1
		) AS parcelas_atrasadas ON parcelas_atrasadas.parc_id = par.parc_id
WHERE
	(par.parc_tmparcelamento >= '2020-06-01')
UNION
SELECT
	cdb.cbdo_id AS "ID PARC/DOC",
	'EXTRATO PARA PAGAMENTO A VISTA' AS "TIPO NEGOCIACAO",
	'EXTRATO' AS "FORMA COBRANCA",
	usu.usur_nmlogin AS "LOGIN",
	usu.usur_nmusuario AS "USUARIO",
	uno.unid_dsunidade AS "LOTACAO",
	cdb.imov_id AS "MATRICULA",
	imo.imov_nncoordenadax AS "LATITUDE",
	imo.imov_nncoordenaday AS "LONGITUDE",
	cli.clie_nmcliente AS "NOME RESP PARC",
	cli.clie_nncpf AS "CPF RESP PARC",
	cli.clie_nncnpj AS "CNPJ RESP PARC",
	(CASE cli.clie_iccpfcnpjvalidado
	WHEN 0 THEN 'NAO'
	WHEN 1 THEN 'SIM'
	ELSE 'NAO'
	END) AS "DOC VALIDADO RESP PARC",
	(
		SELECT
			STRING_AGG('('||cfn.cfon_cdddd||')'||cfn.cfon_nnfone,' | ')
		FROM
			cadastro.cliente_fone cfn 
		WHERE
			cfn.clie_id = cli.clie_id
	) AS "TELEFONES RESP PARC",
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
	'' AS "MOTIVO DESF",
	TO_CHAR(cdb.cbdo_tmemissao,'dd/MM/yyyy') AS "DIA PARC",
	'0,00' AS "VL CONTA",
	'0,00' AS "VL OUTROS SERV",
	'0,00' AS "MULTA IMPONT",
	'0,00' AS "VL JUROS IMPONT",
	TO_CHAR((cdb.cbdo_vldesconto+cdb.cbdo_vldocumento),'999G999G990D00') AS "VALOR DEBITO ORIGINAL",
	TO_CHAR(cdb.cbdo_vldesconto,'999G999G990D00') AS "VALOR DESCONTOS DEBITO",
	'0,00' AS "VALOR PARCELADO",
	TO_CHAR(cdb.cbdo_vldocumento,'999G999G990D00') AS "VALOR ENTRADA",
	'0,00' AS "JUROS PARCELAMENTO",
	0 AS "NR PRESTACOES",
	'0,00' AS "VL PRESTACAO",
	'0,00' AS "VALOR TOTAL PARCELAS",
	TO_CHAR(COALESCE(devolucao.valor,0)+COALESCE(devolucaoh.valor,0),'999G999G990D00') AS "DEVOLUCAO",
	TO_CHAR(cdb.cbdo_vldesconto,'999G999G990D00') AS "VALOR TOTAL DE DESCONTOS",
	TO_CHAR(cdb.cbdo_vldocumento,'999G999G990D00') AS "VALOR FINAL NEGOCIADO",
	cbi.qtd AS "QTD DOCS",
	COALESCE(pagn.dt_pag, pagh.dt_pag) AS "DATA PAGAMENTO",
	TO_CHAR((COALESCE(pagn.valor,0) + COALESCE(pagh.valor,0)),'999G999G990D00') AS "VALOR PAGO ENTRADA",
	TO_CHAR((COALESCE(pagn.dt_pag,pagh.dt_pag)),'DD/MM/YYYY') AS "DATA PAGAMENTO ENTRADA",
	(CASE
		WHEN COALESCE(pagn.dt_pag,pagh.dt_pag, NULL) IS NULL THEN TO_CHAR(CURRENT_DATE - cdb.cbdo_dtvalidade, '9G990')
		ELSE 'PAGO'
	 END
	) AS "ATRASO ENTRADA",
	'0,00' AS "VALOR PAGO PARCELAS",
	0 AS "QTD DE PARCELAS ATRASADAS",
	'0,00' AS "VALOR PARCELAS ATRASADAS",
	'0,00' AS "VALOR PAGO TOTAL"
FROM 
	cobranca.cobranca_documento cdb
	INNER JOIN cobranca.resolucao_diretoria rdi ON rdi.rdir_id = cdb.rdir_id
	LEFT JOIN cadastro.cliente_imovel cim ON cim.imov_id = cdb.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
	LEFT JOIN cadastro.imovel imo ON imo.imov_id = cim.imov_id
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
	cdb.cbdo_tmemissao >= '2020-06-01') AS TMP
ORDER BY 28 DESC