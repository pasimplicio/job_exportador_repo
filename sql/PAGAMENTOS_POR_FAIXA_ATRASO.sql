SELECT
	pags."ARRECADACAO" AS "ARRECADACAO",
	pags."UNIDADE" AS "UNDIADE",
	pags."CATEGORIA PRINCIPAL" AS "CATEGORIA PRINCIPAL",
	pags."PERFIL" AS "PERFIL",
	pags."FAIXA ATRASO" AS "FAIXA ATRASO",
	pags."TIPO DOC" AS "TIPO DOC",
	pags."TIPO DEBITO" AS "TIPO DEBITO",
	TO_CHAR(SUM(pags."QUANTIDADE PAGAMENTOS"),'999G999G990') AS "QUANTIDADE PAGAMENTOS",
	TO_CHAR(SUM(pags."VALOR"),'999G999G990D00') AS "VALOR"
FROM
(	SELECT 
		pag.pghi_amreferenciaarrecadacao AS "ARRECADACAO",
		une.uneg_nmunidadenegocio AS "UNIDADE",
		(CASE imo.imov_idcategoriaprincipal 
		WHEN 1 THEN '1 - RESIDENCIAL'
		WHEN 2 THEN '2 - COMERCIAL'
		WHEN 3 THEN '3 - INDUSTRIAL'
		WHEN 4 THEN '4 - PUBLICO'
		WHEN 5 THEN '5 - EXECUTIVO ESTADUAL'
		ELSE 'NAO DEFINIDO'
		END) AS "CATEGORIA PRINCIPAL",
		ipe.iper_dsimovelperfil AS "PERFIL",
		(CASE 
		WHEN pag.pghi_dtpagamento - con.cnhi_dtvencimentoconta <= 0 THEN '01 - EM DIA'
		WHEN pag.pghi_dtpagamento - con.cnhi_dtvencimentoconta <= 5  THEN '02 - ATE 5 DIAS DE ATRASO'
		WHEN pag.pghi_dtpagamento - con.cnhi_dtvencimentoconta <= 15  THEN '03 - ATE 15 DIAS DE ATRASO'
		WHEN pag.pghi_dtpagamento - con.cnhi_dtvencimentoconta <= 30  THEN '04 - ATE 30 DIAS DE ATRASO'
		WHEN pag.pghi_dtpagamento - con.cnhi_dtvencimentoconta <= 60  THEN '05 - ATE 60 DIAS DE ATRASO'
		WHEN pag.pghi_dtpagamento - con.cnhi_dtvencimentoconta <= 90  THEN '06 - ATE 90 DIAS DE ATRASO'
		WHEN pag.pghi_dtpagamento - con.cnhi_dtvencimentoconta <= 180  THEN '07 - ATE 180 DIAS DE ATRASO'
		WHEN pag.pghi_dtpagamento - con.cnhi_dtvencimentoconta <= 365  THEN '08 - ATE 365 DIAS DE ATRASO'
		WHEN pag.pghi_dtpagamento - con.cnhi_dtvencimentoconta <= 1825  THEN '09 - ATE 5 ANOS DE ATRASO'
		WHEN pag.pghi_dtpagamento - con.cnhi_dtvencimentoconta <= 3650  THEN '10 - ATE 10 ANOS DE ATRASO'
		WHEN pag.pghi_dtpagamento - con.cnhi_dtvencimentoconta > 3650  THEN '11 - ACIMA DE 10 ANOS DE ATRASO'
		END) AS "FAIXA ATRASO",
		dto.dotp_dsdocumentotipo AS "TIPO DOC",
		dbt.dbtp_dsdebitotipo AS "TIPO DEBITO",
		--pag.pghi_dtpagamento AS "DATA PAGAMENTO",
		--con.cnhi_dtvencimentoconta AS "VENCIMENTO DOCUMENTO",
		--pag4.pghi_dtpagamento - con.cnhi_dtvencimentooriginal AS "ATRASO",
		COUNT(pag.pghi_vlpagamento) AS "QUANTIDADE PAGAMENTOS",
		SUM(pag.pghi_vlpagamento) AS "VALOR"
	FROM 	
		arrecadacao.pagamento_historico pag
		INNER JOIN faturamento.conta_historico con ON con.cnta_id = pag.cnta_id
		LEFT JOIN cobranca.documento_tipo dto ON dto.dotp_id = pag.dotp_id
		LEFT JOIN cadastro.imovel imo ON imo.imov_id = pag.imov_id
		LEFT JOIN cadastro.imovel_perfil ipe ON ipe.iper_id = imo.iper_id
		LEFT JOIN cadastro.localidade loc ON loc.loca_id = imo.loca_id
		LEFT JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
		LEFT JOIN faturamento.debito_tipo dbt ON dbt.dbtp_id = pag.dbtp_id
	WHERE 
		pag.pgst_idatual = 0 AND pag.pghi_amreferenciaarrecadacao >= ${VAR_REFERENCIA}
	GROUP BY 1,2,3,4,5,6,7
UNION
	SELECT 
		pag.pgmt_amreferenciaarrecadacao AS "ARRECADACAO",
		une.uneg_nmunidadenegocio AS "UNIDADE",
		(CASE imo.imov_idcategoriaprincipal 
		WHEN 1 THEN '1 - RESIDENCIAL'
		WHEN 2 THEN '2 - COMERCIAL'
		WHEN 3 THEN '3 - INDUSTRIAL'
		WHEN 4 THEN '4 - PUBLICO'
		WHEN 5 THEN '5 - EXECUTIVO ESTADUAL'
		ELSE 'NAO DEFINIDO'
		END) AS "CATEGORIA PRINCIPAL",
		ipe.iper_dsimovelperfil AS "PERFIL",
		(CASE 
		WHEN pag.pgmt_dtpagamento - con.cnta_dtvencimentoconta <= 0 THEN '01 - EM DIA'
		WHEN pag.pgmt_dtpagamento - con.cnta_dtvencimentoconta <= 5  THEN '02 - ATE 5 DIAS DE ATRASO'
		WHEN pag.pgmt_dtpagamento - con.cnta_dtvencimentoconta <= 15  THEN '03 - ATE 15 DIAS DE ATRASO'
		WHEN pag.pgmt_dtpagamento - con.cnta_dtvencimentoconta <= 30  THEN '04 - ATE 30 DIAS DE ATRASO'
		WHEN pag.pgmt_dtpagamento - con.cnta_dtvencimentoconta <= 60  THEN '05 - ATE 60 DIAS DE ATRASO'
		WHEN pag.pgmt_dtpagamento - con.cnta_dtvencimentoconta <= 90  THEN '06 - ATE 90 DIAS DE ATRASO'
		WHEN pag.pgmt_dtpagamento - con.cnta_dtvencimentoconta <= 180  THEN '07 - ATE 180 DIAS DE ATRASO'
		WHEN pag.pgmt_dtpagamento - con.cnta_dtvencimentoconta <= 365  THEN '08 - ATE 365 DIAS DE ATRASO'
		WHEN pag.pgmt_dtpagamento - con.cnta_dtvencimentoconta <= 1825  THEN '09 - ATE 5 ANOS DE ATRASO'
		WHEN pag.pgmt_dtpagamento - con.cnta_dtvencimentoconta <= 3650  THEN '10 - ATE 10 ANOS DE ATRASO'
		WHEN pag.pgmt_dtpagamento - con.cnta_dtvencimentoconta > 3650  THEN '11 - ACIMA DE 10 ANOS DE ATRASO'
		END) AS "FAIXA ATRASO",
		dto.dotp_dsdocumentotipo AS "TIPO DOC",
		dbt.dbtp_dsdebitotipo AS "TIPO DEBITO",
		--pag.pghi_dtpagamento AS "DATA PAGAMENTO",
		--con.cnhi_dtvencimentoconta AS "VENCIMENTO DOCUMENTO",
		--pag4.pghi_dtpagamento - con.cnhi_dtvencimentooriginal AS "ATRASO",
		COUNT(pag.pgmt_vlpagamento) AS "QUANTIDADE PAGAMENTOS",
		SUM(pag.pgmt_vlpagamento) AS "VALOR"
	FROM 	
		arrecadacao.pagamento pag
		INNER JOIN faturamento.conta con ON con.cnta_id = pag.cnta_id
		LEFT JOIN cobranca.documento_tipo dto ON dto.dotp_id = pag.dotp_id
		LEFT JOIN cadastro.imovel imo ON imo.imov_id = pag.imov_id
		LEFT JOIN cadastro.imovel_perfil ipe ON ipe.iper_id = imo.iper_id
		LEFT JOIN cadastro.localidade loc ON loc.loca_id = imo.loca_id
		LEFT JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
		LEFT JOIN faturamento.debito_tipo dbt ON dbt.dbtp_id = pag.dbtp_id
	WHERE 
		pag.pgst_idatual = 0 AND pag.pgmt_amreferenciaarrecadacao >= ${VAR_REFERENCIA}
	GROUP BY 1,2,3,4,5,6,7
UNION
	SELECT 
		pag.pghi_amreferenciaarrecadacao AS "ARRECADACAO",
		une.uneg_nmunidadenegocio AS "UNIDADE",
		(CASE imo.imov_idcategoriaprincipal 
		WHEN 1 THEN '1 - RESIDENCIAL'
		WHEN 2 THEN '2 - COMERCIAL'
		WHEN 3 THEN '3 - INDUSTRIAL'
		WHEN 4 THEN '4 - PUBLICO'
		WHEN 5 THEN '5 - EXECUTIVO ESTADUAL'
		ELSE 'NAO DEFINIDO'
		END) AS "CATEGORIA PRINCIPAL",
		ipe.iper_dsimovelperfil AS "PERFIL",
		(CASE 
		WHEN pag.pghi_dtpagamento - con.cnta_dtvencimentoconta <= 0 THEN '01 - EM DIA'
		WHEN pag.pghi_dtpagamento - con.cnta_dtvencimentoconta <= 5  THEN '02 - ATE 5 DIAS DE ATRASO'
		WHEN pag.pghi_dtpagamento - con.cnta_dtvencimentoconta <= 15  THEN '03 - ATE 15 DIAS DE ATRASO'
		WHEN pag.pghi_dtpagamento - con.cnta_dtvencimentoconta <= 30  THEN '04 - ATE 30 DIAS DE ATRASO'
		WHEN pag.pghi_dtpagamento - con.cnta_dtvencimentoconta <= 60  THEN '05 - ATE 60 DIAS DE ATRASO'
		WHEN pag.pghi_dtpagamento - con.cnta_dtvencimentoconta <= 90  THEN '06 - ATE 90 DIAS DE ATRASO'
		WHEN pag.pghi_dtpagamento - con.cnta_dtvencimentoconta <= 180  THEN '07 - ATE 180 DIAS DE ATRASO'
		WHEN pag.pghi_dtpagamento - con.cnta_dtvencimentoconta <= 365  THEN '08 - ATE 365 DIAS DE ATRASO'
		WHEN pag.pghi_dtpagamento - con.cnta_dtvencimentoconta <= 1825  THEN '09 - ATE 5 ANOS DE ATRASO'
		WHEN pag.pghi_dtpagamento - con.cnta_dtvencimentoconta <= 3650  THEN '10 - ATE 10 ANOS DE ATRASO'
		WHEN pag.pghi_dtpagamento - con.cnta_dtvencimentoconta > 3650  THEN '11 - ACIMA DE 10 ANOS DE ATRASO'
		END) AS "FAIXA ATRASO",
		dto.dotp_dsdocumentotipo AS "TIPO DOC",
		dbt.dbtp_dsdebitotipo AS "TIPO DEBITO",
		--pag.pghi_dtpagamento AS "DATA PAGAMENTO",
		--con.cnhi_dtvencimentoconta AS "VENCIMENTO DOCUMENTO",
		--pag4.pghi_dtpagamento - con.cnhi_dtvencimentooriginal AS "ATRASO",
		COUNT(pag.pghi_vlpagamento) AS "QUANTIDADE PAGAMENTOS",
		SUM(pag.pghi_vlpagamento) AS "VALOR"
	FROM 	
		arrecadacao.pagamento_historico pag
		INNER JOIN faturamento.conta con ON con.cnta_id = pag.cnta_id
		LEFT JOIN cobranca.documento_tipo dto ON dto.dotp_id = pag.dotp_id
		LEFT JOIN cadastro.imovel imo ON imo.imov_id = pag.imov_id
		LEFT JOIN cadastro.imovel_perfil ipe ON ipe.iper_id = imo.iper_id
		LEFT JOIN cadastro.localidade loc ON loc.loca_id = imo.loca_id
		LEFT JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
		LEFT JOIN faturamento.debito_tipo dbt ON dbt.dbtp_id = pag.dbtp_id
	WHERE 
		pag.pgst_idatual = 0 AND pag.pghi_amreferenciaarrecadacao >= ${VAR_REFERENCIA}
	GROUP BY 1,2,3,4,5,6,7
UNION
	SELECT 
		pag.pgmt_amreferenciaarrecadacao AS "ARRECADACAO",
		une.uneg_nmunidadenegocio AS "UNIDADE",
		(CASE imo.imov_idcategoriaprincipal 
		WHEN 1 THEN '1 - RESIDENCIAL'
		WHEN 2 THEN '2 - COMERCIAL'
		WHEN 3 THEN '3 - INDUSTRIAL'
		WHEN 4 THEN '4 - PUBLICO'
		WHEN 5 THEN '5 - EXECUTIVO ESTADUAL'
		ELSE 'NAO DEFINIDO'
		END) AS "CATEGORIA PRINCIPAL",
		ipe.iper_dsimovelperfil AS "PERFIL",
		(CASE 
		WHEN pag.pgmt_dtpagamento - con.cnhi_dtvencimentoconta <= 0 THEN '01 - EM DIA'
		WHEN pag.pgmt_dtpagamento - con.cnhi_dtvencimentoconta <= 5  THEN '02 - ATE 5 DIAS DE ATRASO'
		WHEN pag.pgmt_dtpagamento - con.cnhi_dtvencimentoconta <= 15  THEN '03 - ATE 15 DIAS DE ATRASO'
		WHEN pag.pgmt_dtpagamento - con.cnhi_dtvencimentoconta <= 30  THEN '04 - ATE 30 DIAS DE ATRASO'
		WHEN pag.pgmt_dtpagamento - con.cnhi_dtvencimentoconta <= 60  THEN '05 - ATE 60 DIAS DE ATRASO'
		WHEN pag.pgmt_dtpagamento - con.cnhi_dtvencimentoconta <= 90  THEN '06 - ATE 90 DIAS DE ATRASO'
		WHEN pag.pgmt_dtpagamento - con.cnhi_dtvencimentoconta <= 180  THEN '07 - ATE 180 DIAS DE ATRASO'
		WHEN pag.pgmt_dtpagamento - con.cnhi_dtvencimentoconta <= 365  THEN '08 - ATE 365 DIAS DE ATRASO'
		WHEN pag.pgmt_dtpagamento - con.cnhi_dtvencimentoconta <= 1825  THEN '09 - ATE 5 ANOS DE ATRASO'
		WHEN pag.pgmt_dtpagamento - con.cnhi_dtvencimentoconta <= 3650  THEN '10 - ATE 10 ANOS DE ATRASO'
		WHEN pag.pgmt_dtpagamento - con.cnhi_dtvencimentoconta > 3650  THEN '11 - ACIMA DE 10 ANOS DE ATRASO'
		END) AS "FAIXA ATRASO",
		dto.dotp_dsdocumentotipo AS "TIPO DOC",
		dbt.dbtp_dsdebitotipo AS "TIPO DEBITO",
		--pag.pghi_dtpagamento AS "DATA PAGAMENTO",
		--con.cnhi_dtvencimentoconta AS "VENCIMENTO DOCUMENTO",
		--pag4.pghi_dtpagamento - con.cnhi_dtvencimentooriginal AS "ATRASO",
		COUNT(pag.pgmt_vlpagamento) AS "QUANTIDADE PAGAMENTOS",
		SUM(pag.pgmt_vlpagamento) AS "VALOR"
	FROM 	
		arrecadacao.pagamento pag
		INNER JOIN faturamento.conta_historico con ON con.cnta_id = pag.cnta_id
		LEFT JOIN cobranca.documento_tipo dto ON dto.dotp_id = pag.dotp_id
		LEFT JOIN cadastro.imovel imo ON imo.imov_id = pag.imov_id
		LEFT JOIN cadastro.imovel_perfil ipe ON ipe.iper_id = imo.iper_id
		LEFT JOIN cadastro.localidade loc ON loc.loca_id = imo.loca_id
		LEFT JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
		LEFT JOIN faturamento.debito_tipo dbt ON dbt.dbtp_id = pag.dbtp_id
	WHERE 
		pag.pgst_idatual = 0 AND pag.pgmt_amreferenciaarrecadacao >= ${VAR_REFERENCIA}
	GROUP BY 1,2,3,4,5,6,7) AS pags
GROUP BY 1,2,3,4,5,6,7