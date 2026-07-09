SELECT
	imo.imov_id AS "MATRICULA",
	TO_CHAR(con_revisao_decreto.valor, '999G999G990D00') AS "VALOR TOTAL ISENTO",
	TO_CHAR(con_revisao_decreto.outros, '999G999G990D00') AS "VALOR SERVICOS ADIADO",
	TO_CHAR(con_revisao_decreto.creditos, '999G999G990D00') AS "VALOR CREDITOS ADIADO",
	con_revisao_decreto.qtd AS "QTD. CONTAS INSENTO",
	con_revisao_decreto.min AS "MENOR REFERENCIA ISENTA",
	con_revisao_decreto.max AS "MAIOR REFERENCIA ISENTA",
	TO_CHAR((
			SELECT
				MIN(opf.opef_tmultimaalteracao) AS ult_alt
			FROM
				seguranca.operacao_efetuada opf
				INNER JOIN seguranca.tabela_linha_alteracao tbl ON opf.opef_id = tbl.tref_id
				INNER JOIN seguranca.tab_linha_col_alteracao tbc ON tbl.tbla_id = tbc.tbla_id
			WHERE
				--tbl.tabe_id = 60
				--tbc.tbca_cncolunaanterior <> tbc.tbca_cncolunaatual
				--AND 
				tbc.tbco_id IN (271, 272, 275, 276, 701, 60, 4796, 23848, 23850, 1527, 1529, 1531, 1539, 2524, 2525, 2526, 2527, 2529)
				--AND tbc.tbca_tmultimaalteracao >= (CURRENT_DATE::TIMESTAMP)
				--AND usu.usur_nmlogin = 'YGOR'
				AND opf.opef_cnargumento = cli.clie_id
	),'DD/MM/YYYY') AS "ULTIMA ALTERACAO CADASTRO",
	TO_CHAR(pags_ult.valor, '999G999G990D00') AS "VALOR PAGO VAR_ARRECADACAO",
	pags_ult.qtd AS "QTD DOC PAGOS VAR_ARRECADACAO",
	TO_CHAR(pags_pen.valor, '999G999G990D00') AS "VALOR PAGO VAR_ARRECADACAO - 1",
	pags_pen.qtd AS "QTD DOC PAGOS VAR_ARRECADACAO - 1",
	TO_CHAR(pags_ant.valor, '999G999G990D00') AS "VALOR PAGO VAR_ARRECADACAO - 2",
	pags_ant.qtd AS "QTD DOC PAGOS VAR_ARRECADACAO - 2"
FROM
	cadastro.imovel imo
	INNER JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
	INNER JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
	INNER JOIN cadastro.localidade loc ON loc.loca_id = imo.loca_id
	LEFT JOIN (	SELECT 
				con4.imov_id AS mat1,
				COUNT(con4.cnta_id) AS qtd,
				MIN(con4.cnta_amreferenciaconta) AS min,
				MAX(con4.cnta_amreferenciaconta) AS max,
				SUM(con4.cnta_vlagua+con4.cnta_vlesgoto) AS valor,
				SUM(con4.cnta_vldebitos) AS outros,
				SUM(con4.cnta_vlcreditos) AS creditos
			FROM faturamento.conta con4 
			WHERE 
				con4.dcst_idatual IN (0,1,2) AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con4.cnta_id) AND NOT con4.cnta_dtrevisao IS NULL AND con4.cmrv_id = 114
			GROUP BY 1) AS con_revisao_decreto ON con_revisao_decreto.mat1 = imo.imov_id
	LEFT JOIN(
			SELECT
				pags.imov_id AS imov_id,
				SUM(pags.qtd) AS qtd,
				SUM(pags.valor) AS valor
			FROM		
				(SELECT 
						pag.imov_id AS imov_id,
						COUNT(pag.pgmt_id) AS qtd,
						SUM(pag.pgmt_vlpagamento) AS valor
					FROM
						arrecadacao.pagamento pag
						INNER JOIN cadastro.localidade loc ON loc.loca_id = pag.loca_id AND loc.uneg_id = 12
					WHERE
						pag.pgst_idatual IN (0,1)
						AND pag.pgmt_amreferenciaarrecadacao = VAR_ARRECADACAO
					GROUP BY 1
				UNION
					SELECT 
						pag.imov_id AS imov_id,
						COUNT(pag.pghi_id) AS qtd,
						SUM(pag.pghi_vlpagamento) AS valor
					FROM
						arrecadacao.pagamento_historico pag
						INNER JOIN cadastro.localidade loc ON loc.loca_id = pag.loca_id AND loc.uneg_id = 12
					WHERE
						pag.pgst_idatual IN (0,1)
						AND pag.pghi_amreferenciaarrecadacao = VAR_ARRECADACAO
					GROUP BY 1) pags
			GROUP BY 1
		) AS pags_ult ON pags_ult.imov_id = imo.imov_id
	LEFT JOIN (
			SELECT
				pags.imov_id AS imov_id,
				SUM(pags.qtd) AS qtd,
				SUM(pags.valor) AS valor
			FROM		
				(SELECT 
						pag.imov_id AS imov_id,
						COUNT(pag.pgmt_id) AS qtd,
						SUM(pag.pgmt_vlpagamento) AS valor
					FROM
						arrecadacao.pagamento pag
						INNER JOIN cadastro.localidade loc ON loc.loca_id = pag.loca_id AND loc.uneg_id = 12
					WHERE
						pag.pgst_idatual IN (0,1)
						AND pag.pgmt_amreferenciaarrecadacao = (
								SELECT 
									CASE (CAST(SUBSTRING(CAST(VAR_ARRECADACAO AS TEXT) FROM 5 FOR 6) AS INT))
										WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(VAR_ARRECADACAO AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
										ELSE CAST(VAR_ARRECADACAO-1 AS TEXT)
									END
							)
					GROUP BY 1
				UNION
					SELECT 
						pag.imov_id AS imov_id,
						COUNT(pag.pghi_id) AS qtd,
						SUM(pag.pghi_vlpagamento) AS valor
					FROM
						arrecadacao.pagamento_historico pag
						INNER JOIN cadastro.localidade loc ON loc.loca_id = pag.loca_id AND loc.uneg_id = 12
					WHERE
						pag.pgst_idatual IN (0,1)
						AND pag.pghi_amreferenciaarrecadacao = (
								SELECT 
									CASE (CAST(SUBSTRING(CAST(VAR_ARRECADACAO AS TEXT) FROM 5 FOR 6) AS INT))
										WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(VAR_ARRECADACAO AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
										ELSE CAST(VAR_ARRECADACAO-1 AS TEXT)
									END
							)
					GROUP BY 1) pags
			GROUP BY 1
		) AS pags_pen ON pags_pen.imov_id = imo.imov_id
	LEFT JOIN (
			SELECT
				pags.imov_id AS imov_id,
				SUM(pags.qtd) AS qtd,
				SUM(pags.valor) AS valor
			FROM		
				(SELECT 
						pag.imov_id AS imov_id,
						COUNT(pag.pgmt_id) AS qtd,
						SUM(pag.pgmt_vlpagamento) AS valor
					FROM
						arrecadacao.pagamento pag
						INNER JOIN cadastro.localidade loc ON loc.loca_id = pag.loca_id AND loc.uneg_id = 12
					WHERE
						pag.pgst_idatual IN (0,1)
						AND pag.pgmt_amreferenciaarrecadacao = (
								SELECT 
									CASE (CAST(SUBSTRING(CAST(VAR_ARRECADACAO AS TEXT) FROM 5 FOR 6) AS INT))
										WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(VAR_ARRECADACAO AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'11'
										WHEN 2 THEN CAST((CAST(SUBSTRING(CAST(VAR_ARRECADACAO AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
										ELSE CAST(VAR_ARRECADACAO-2 AS TEXT)
									END
							)
					GROUP BY 1
				UNION
					SELECT 
						pag.imov_id AS imov_id,
						COUNT(pag.pghi_id) AS qtd,
						SUM(pag.pghi_vlpagamento) AS valor
					FROM
						arrecadacao.pagamento_historico pag
						INNER JOIN cadastro.localidade loc ON loc.loca_id = pag.loca_id AND loc.uneg_id = 12
					WHERE
						pag.pgst_idatual IN (0,1)
						AND pag.pghi_amreferenciaarrecadacao = (
								SELECT 
									CASE (CAST(SUBSTRING(CAST(VAR_ARRECADACAO AS TEXT) FROM 5 FOR 6) AS INT))
										WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(VAR_ARRECADACAO AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'11'
										WHEN 2 THEN CAST((CAST(SUBSTRING(CAST(VAR_ARRECADACAO AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
										ELSE CAST(VAR_ARRECADACAO-2 AS TEXT)
									END
							)
					GROUP BY 1) pags
			GROUP BY 1
		) AS pags_ant ON pags_ant.imov_id = imo.imov_id
WHERE
	imo.imov_icexclusao = 2
	--loc.uneg_id >= 11 AND loc.uneg_id <= 15
	AND loc.uneg_id = VAR_UNIDADE