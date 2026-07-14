SELECT
	une.uneg_nmunidadenegocio AS "UNIDADE",
	refs."REFERENCIA" AS "REFERENCIA",
	TO_CHAR(indice_hidrometracao."QTD FATURADO",'999G999G990') AS "QTD LIG FATURADAS MES",
	TO_CHAR(indice_hidrometracao."QTD COM HD", '999G999G990') AS "QTD LIG FATURADAS COM HD MES",
	TO_CHAR((indice_hidrometracao."QTD COM HD"/indice_hidrometracao."QTD FATURADO"*100),'999G999G990D00') AS "INDICE DE HIDROMETRACAO MES",
	--TO_CHAR(indice_hidrometracao."QTD FATURADO ACM",'999G999G990') AS "QTD LIG FATURADAS ACUMULADO ANO",
	--TO_CHAR(indice_hidrometracao."QTD COM HD ACM", '999G999G990') AS "QTD LIG FATURADAS COM HD ACUMULADO ANO",
	--TO_CHAR((indice_hidrometracao."QTD COM HD ACM"/indice_hidrometracao."QTD FATURADO ACM"*100),'999G999G990D00') AS "INDICE DE HIDROMETRACAO ACUMULADO ANO",
	TO_CHAR(faturamento_acm_2019."VALOR MES", '999G999G990D00') AS "FATURADO 2019 MESMA MES",
	TO_CHAR(faturamento_acm_2020."VALOR MES", '999G999G990D00') AS "FATURADO ANO ATUAL ESTE MES",
	TO_CHAR((((faturamento_acm_2020."VALOR MES"/faturamento_acm_2019."VALOR MES")-1)*100),'999G999G990D00') AS "INDICE DE INCREMENTO FATURAMENTO MES",
	TO_CHAR(faturamento_acm_2019."VALOR ACM", '999G999G990D00') AS "FATURADO 2019 ACUMULADO MESMO PERIODO",
	TO_CHAR(faturamento_acm_2020."VALOR ACM", '999G999G990D00') AS "FATURADO ANO ATUAL ACUMULADO ATE ESTE MES",
	TO_CHAR((((faturamento_acm_2020."VALOR ACM"/faturamento_acm_2019."VALOR ACM")-1)*100),'999G999G990D00') AS "INDICE DE INCREMENTO FATURAMENTO ACUMULADO",
	--TO_CHAR(ind_refat."VALOR ORIGINAL",'999G999G990D00') AS "VALOR ORIGINAL CONTAS REFATURADAS/CANCELADAS MES",
	--TO_CHAR(ind_refat."VALOR FINAL",'999G999G990D00') AS "VALOR FINAL CONTAS REFATURADAS/CANCELADA MES",
	TO_CHAR(ind_refat."VALOR REFATURADO/CANCELADO",'999G999G990D00') AS "VALOR REFATURADO/CANCELADO CONTAS REFATURADAS/CANCELADAS MES",
	--TO_CHAR(ind_refat."VALOR ORIGINAL ACM",'999G999G990D00') AS "VALOR ORIGINAL CONTAS REFATURADAS/CANCELADAS ACUMULADO ANO",
	--TO_CHAR(ind_refat."VALOR FINAL ACM",'999G999G990D00') AS "VALOR FINAL CONTAS REFATURADAS/CANCELADAS ACUMULADO ANO",
	TO_CHAR(ind_refat."VALOR REFATURADO/CANCELADO ACM",'999G999G990D00') AS "VALOR REFATURADO/CANCELADO CONTAS REFATURADAS/CANCELADAS ACUMULADO ANO",
	TO_CHAR(((1-(ind_refat."VALOR REFATURADO/CANCELADO"/faturamento_acm_2020."VALOR MES"))*100),'999G999G990D00') AS "INDICE REFATURAMENTO/CANCELAMENTO MES",
	TO_CHAR(((1-(ind_refat."VALOR REFATURADO/CANCELADO ACM"/faturamento_acm_2020."VALOR ACM"))*100),'999G999G990D00') AS "INDICE REFATURAMENTO/CANCELAMENTO ACUMULADO ANO",
	TO_CHAR(ind_cadastro."QTD CLIENTES ATUALIZADOS",'999G999G990') AS "QTD CLIENTES ATUALIZADOS",
	TO_CHAR(ind_cadastro."QTD CLIENTES ATUALIZADOS ACM",'999G999G990') AS "QTD CLIENTES ATUALIZADOS ACUMULADO",
	TO_CHAR(arrecadacao_acm_2019."VALOR MES", '999G999G990D00') AS "ARRECADACAO 2019 MESMO MES",
	TO_CHAR(arrecadacao_acm_2020."VALOR MES", '999G999G990D00') AS "ARRECADACAO ANO ATUAL ESTE MES",
	TO_CHAR((((arrecadacao_acm_2020."VALOR MES"/arrecadacao_acm_2019."VALOR MES")-1)*100),'999G999G990D00') AS "INDICE DE INCREMENTO ARRECADACAO MES",
	TO_CHAR(arrecadacao_acm_2019."VALOR ACM", '999G999G990D00') AS "ARRECADACAO 2019 ACUMULADO MESMO PERIODO",
	TO_CHAR(arrecadacao_acm_2020."VALOR ACM", '999G999G990D00') AS "ARRECADACAO ANO ATUAL ACUMULADO ATE ESTE MES",
	TO_CHAR((((arrecadacao_acm_2020."VALOR ACM"/arrecadacao_acm_2019."VALOR ACM")-1)*100),'999G999G990D00') AS "INDICE DE INCREMENTO ARRECADACAO ACUMULADO"
	FROM
		cadastro.unidade_negocio une
		CROSS JOIN (SELECT  referencia AS "REFERENCIA" FROM generate_series(202001, ${VAR_REFERENCIA}) referencia) AS refs
		LEFT JOIN
			(
				SELECT 		
				ind.uneg_id AS uneg_id,
				ind."REFERENCIA" AS "REFERENCIA",
				SUM(ind."QTD FATURADO") AS "QTD FATURADO",
				SUM(ind."QTD COM HD") AS "QTD COM HD",
				SUM(SUM(ind."QTD FATURADO")) OVER (PARTITION BY ind.uneg_id ORDER BY ind."REFERENCIA") AS "QTD FATURADO ACM",
				SUM(SUM(ind."QTD COM HD")) OVER (PARTITION BY ind.uneg_id ORDER BY ind."REFERENCIA") AS "QTD COM HD ACM"
			FROM
				(
				SELECT
					une.uneg_id AS uneg_id,
					con.cnta_amreferenciaconta AS "REFERENCIA",
					COUNT(con.cnta_id) AS "QTD FATURADO",
					COUNT(his.hidi_id) AS "QTD COM HD"
				FROM
					faturamento.conta con
					INNER JOIN faturamento.conta_impressao cni ON cni.cnta_id = con.cnta_id
					INNER JOIN cadastro.localidade loc ON con.loca_id = loc.loca_id
					INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
					LEFT JOIN micromedicao.hidrometro_inst_hist his ON con.imov_id = his.lagu_id AND hidi_dtinstalacaohidrometro <= con.cnta_dtemissao AND (his.hidi_dtretiradahidrometro IS NULL OR his.hidi_dtretiradahidrometro>con.cnta_dtemissao)
				WHERE
					con.cnta_amreferenciaconta>=((TO_CHAR(CURRENT_DATE, 'YYYY')||'01')::INTEGER) AND con.cnta_amreferenciaconta<=(TO_CHAR(CURRENT_DATE, 'YYYYMM')::INTEGER) 
				GROUP BY 1,2
			UNION
				SELECT
					une.uneg_id AS uneg_id,
					con.cnhi_amreferenciaconta AS "REFERENCIA",
					COUNT(con.cnta_id) AS "QTD FATURADO",
					COUNT(his.hidi_id) AS "QTD COM HD"
				FROM
					faturamento.conta_historico con
					INNER JOIN faturamento.conta_impressao cni ON cni.cnta_id = con.cnta_id
					INNER JOIN cadastro.localidade loc ON con.loca_id = loc.loca_id
					INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
					LEFT JOIN micromedicao.hidrometro_inst_hist his ON con.imov_id = his.lagu_id AND hidi_dtinstalacaohidrometro <= con.cnhi_dtemissao AND (his.hidi_dtretiradahidrometro IS NULL OR his.hidi_dtretiradahidrometro>con.cnhi_dtemissao)
				WHERE
					con.cnhi_amreferenciaconta>=((TO_CHAR(CURRENT_DATE, 'YYYY')||'01')::INTEGER) AND con.cnhi_amreferenciaconta<=(TO_CHAR(CURRENT_DATE, 'YYYYMM')::INTEGER) 
				GROUP BY 1,2
			UNION
				SELECT
						une.uneg_id AS uneg_id,
						con.cnta_amreferenciaconta AS "REFERENCIA",
						COUNT(con.cnta_id) AS "QTD FATURADO",
						COUNT(his.hidi_id) AS "QTD COM HD"
					FROM
						faturamento.conta con
						INNER JOIN faturamento.mov_conta_prefaturada cni ON cni.cnta_id = con.cnta_id
						INNER JOIN cadastro.localidade loc ON con.loca_id = loc.loca_id
						INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
						LEFT JOIN micromedicao.hidrometro_inst_hist his ON con.imov_id = his.lagu_id AND hidi_dtinstalacaohidrometro <= con.cnta_dtemissao AND (his.hidi_dtretiradahidrometro IS NULL OR his.hidi_dtretiradahidrometro>con.cnta_dtemissao)
					WHERE
						con.cnta_amreferenciaconta>=((TO_CHAR(CURRENT_DATE, 'YYYY')||'01')::INTEGER) AND con.cnta_amreferenciaconta<=(TO_CHAR(CURRENT_DATE, 'YYYYMM')::INTEGER) 
					GROUP BY 1,2
				UNION
					SELECT
						une.uneg_id AS uneg_id,
						con.cnhi_amreferenciaconta AS "REFERENCIA",
						COUNT(con.cnta_id) AS "QTD FATURADO",
						COUNT(his.hidi_id) AS "QTD COM HD"
					FROM
						faturamento.conta_historico con
						INNER JOIN faturamento.mov_conta_prefaturada cni ON cni.cnta_id = con.cnta_id
						INNER JOIN cadastro.localidade loc ON con.loca_id = loc.loca_id
						INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
						LEFT JOIN micromedicao.hidrometro_inst_hist his ON con.imov_id = his.lagu_id AND hidi_dtinstalacaohidrometro <= con.cnhi_dtemissao AND (his.hidi_dtretiradahidrometro IS NULL OR his.hidi_dtretiradahidrometro>con.cnhi_dtemissao)
					WHERE
						con.cnhi_amreferenciaconta>=((TO_CHAR(CURRENT_DATE, 'YYYY')||'01')::INTEGER) AND con.cnhi_amreferenciaconta<=(TO_CHAR(CURRENT_DATE, 'YYYYMM')::INTEGER) 
					GROUP BY 1,2) AS ind 
			GROUP BY 1,2) AS indice_hidrometracao ON une.uneg_id = indice_hidrometracao.uneg_id AND indice_hidrometracao."REFERENCIA" = refs."REFERENCIA"
		LEFT JOIN
			(
				SELECT
					ind.uneg_id AS uneg_id,
					ind."REFERENCIA" AS "REFERENCIA",
					SUM(ind."VALOR MES") AS "VALOR MES",
					SUM(SUM(ind."VALOR MES")) OVER (PARTITION BY ind.uneg_id ORDER BY ind."REFERENCIA")  AS "VALOR ACM"
				FROM(
					SELECT
							une.uneg_id AS uneg_id,
							con.cnta_amreferenciaconta AS "REFERENCIA",
							SUM(con.cnta_vlagua+con.cnta_vlesgoto+con.cnta_vldebitos-con.cnta_vlcreditos-con.cnta_vlimpostos) AS "VALOR MES"
						FROM
							faturamento.conta con
							INNER JOIN faturamento.conta_impressao cni ON cni.cnta_id = con.cnta_id
							INNER JOIN cadastro.localidade loc ON con.loca_id = loc.loca_id
							INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
						WHERE
							con.cnta_amreferenciaconta>=201901 AND con.cnta_amreferenciaconta<= ('2019'||TO_CHAR(CURRENT_DATE, 'MM'))::INTEGER
						GROUP BY 1,2
					UNION
						SELECT
							une.uneg_id AS uneg_id,
							con.cnhi_amreferenciaconta AS "REFERENCIA",
							SUM(con.cnhi_vlagua+con.cnhi_vlesgoto+con.cnhi_vldebitos-con.cnhi_vlcreditos-con.cnhi_vlimpostos) AS "VALOR MES"
						FROM
							faturamento.conta_historico con
							INNER JOIN faturamento.conta_impressao cni ON cni.cnta_id = con.cnta_id
							INNER JOIN cadastro.localidade loc ON con.loca_id = loc.loca_id
							INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
						WHERE
							con.cnhi_amreferenciaconta>=201901 AND con.cnhi_amreferenciaconta<= ('2019'||TO_CHAR(CURRENT_DATE, 'MM'))::INTEGER
						GROUP BY 1,2
					UNION
						SELECT
							une.uneg_id AS uneg_id,
							con.cnta_amreferenciaconta AS "REFERENCIA",
							SUM(con.cnta_vlagua+con.cnta_vlesgoto+con.cnta_vldebitos-con.cnta_vlcreditos-con.cnta_vlimpostos) AS "VALOR MES"
						FROM
							faturamento.conta con
							INNER JOIN faturamento.mov_conta_prefaturada cni ON cni.cnta_id = con.cnta_id
							INNER JOIN cadastro.localidade loc ON con.loca_id = loc.loca_id
							INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
						WHERE
							con.cnta_amreferenciaconta>=201901 AND con.cnta_amreferenciaconta<= ('2019'||TO_CHAR(CURRENT_DATE, 'MM'))::INTEGER
						GROUP BY 1,2
					UNION
						SELECT
							une.uneg_id AS uneg_id,
							con.cnhi_amreferenciaconta AS "REFERENCIA",
							SUM(con.cnhi_vlagua+con.cnhi_vlesgoto+con.cnhi_vldebitos-con.cnhi_vlcreditos-con.cnhi_vlimpostos) AS "VALOR MES"
						FROM
							faturamento.conta_historico con
							INNER JOIN faturamento.mov_conta_prefaturada cni ON cni.cnta_id = con.cnta_id
							INNER JOIN cadastro.localidade loc ON con.loca_id = loc.loca_id
							INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
						WHERE
							con.cnhi_amreferenciaconta>=201901 AND con.cnhi_amreferenciaconta<= ('2019'||TO_CHAR(CURRENT_DATE, 'MM'))::INTEGER
						GROUP BY 1,2) AS ind
					GROUP BY 1,2) AS faturamento_acm_2019 ON faturamento_acm_2019.uneg_id = une.uneg_id AND faturamento_acm_2019."REFERENCIA" = refs."REFERENCIA"-100
		LEFT JOIN
			(
				SELECT
					ind.uneg_id AS uneg_id,
					ind."REFERENCIA" AS "REFERENCIA",
					SUM(ind."VALOR MES") AS "VALOR MES",
					SUM(SUM(ind."VALOR MES")) OVER (PARTITION BY ind.uneg_id ORDER BY ind."REFERENCIA")  AS "VALOR ACM"
				FROM(
					SELECT
							une.uneg_id AS uneg_id,
							con.cnta_amreferenciaconta AS "REFERENCIA",
							SUM(con.cnta_vlagua+con.cnta_vlesgoto+con.cnta_vldebitos-con.cnta_vlcreditos-con.cnta_vlimpostos) AS "VALOR MES"
						FROM
							faturamento.conta con
							INNER JOIN faturamento.conta_impressao cni ON cni.cnta_id = con.cnta_id
							INNER JOIN cadastro.localidade loc ON con.loca_id = loc.loca_id
							INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
						WHERE
							con.cnta_amreferenciaconta>=((TO_CHAR(CURRENT_DATE, 'YYYY')||'01')::INTEGER) AND con.cnta_amreferenciaconta<= (TO_CHAR(CURRENT_DATE, 'YYYYMM')::INTEGER)
						GROUP BY 1,2
					UNION
						SELECT
							une.uneg_id AS uneg_id,
							con.cnhi_amreferenciaconta AS "REFERENCIA",
							SUM(con.cnhi_vlagua+con.cnhi_vlesgoto+con.cnhi_vldebitos-con.cnhi_vlcreditos-con.cnhi_vlimpostos) AS "VALOR MES"
						FROM
							faturamento.conta_historico con
							INNER JOIN faturamento.conta_impressao cni ON cni.cnta_id = con.cnta_id
							INNER JOIN cadastro.localidade loc ON con.loca_id = loc.loca_id
							INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
						WHERE
							con.cnhi_amreferenciaconta>=((TO_CHAR(CURRENT_DATE, 'YYYY')||'01')::INTEGER) AND con.cnhi_amreferenciaconta<= (TO_CHAR(CURRENT_DATE, 'YYYYMM')::INTEGER)
						GROUP BY 1,2
					UNION
						SELECT
								une.uneg_id AS uneg_id,
								con.cnta_amreferenciaconta AS "REFERENCIA",
								SUM(con.cnta_vlagua+con.cnta_vlesgoto+con.cnta_vldebitos-con.cnta_vlcreditos-con.cnta_vlimpostos) AS "VALOR MES"
							FROM
								faturamento.conta con
								INNER JOIN faturamento.mov_conta_prefaturada cni ON cni.cnta_id = con.cnta_id
								INNER JOIN cadastro.localidade loc ON con.loca_id = loc.loca_id
								INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
							WHERE
								con.cnta_amreferenciaconta>=((TO_CHAR(CURRENT_DATE, 'YYYY')||'01')::INTEGER) AND con.cnta_amreferenciaconta<= (TO_CHAR(CURRENT_DATE, 'YYYYMM')::INTEGER)
							GROUP BY 1,2
						UNION
							SELECT
								une.uneg_id AS uneg_id,
								con.cnhi_amreferenciaconta AS "REFERENCIA",
								SUM(con.cnhi_vlagua+con.cnhi_vlesgoto+con.cnhi_vldebitos-con.cnhi_vlcreditos-con.cnhi_vlimpostos) AS "VALOR MES"
							FROM
								faturamento.conta_historico con
								INNER JOIN faturamento.mov_conta_prefaturada cni ON cni.cnta_id = con.cnta_id
								INNER JOIN cadastro.localidade loc ON con.loca_id = loc.loca_id
								INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
							WHERE
								con.cnhi_amreferenciaconta>=((TO_CHAR(CURRENT_DATE, 'YYYY')||'01')::INTEGER) AND con.cnhi_amreferenciaconta<= (TO_CHAR(CURRENT_DATE, 'YYYYMM')::INTEGER)
							GROUP BY 1,2) AS ind
					GROUP BY 1,2) AS faturamento_acm_2020 ON faturamento_acm_2020.uneg_id = une.uneg_id AND faturamento_acm_2020."REFERENCIA" = refs."REFERENCIA"
		LEFT JOIN
			(
				SELECT 		
					ind.uneg_id AS uneg_id,
					ind."REFERENCIA" AS "REFERENCIA",
					SUM(ind."VALOR ORIGINAL") AS "VALOR ORIGINAL",
					SUM(ind."VALOR FINAL") AS "VALOR FINAL",
					SUM(ind."VALOR REFATURADO") AS "VALOR REFATURADO/CANCELADO",
					SUM(SUM(ind."VALOR ORIGINAL")) OVER (PARTITION BY ind.uneg_id ORDER BY ind."REFERENCIA") AS "VALOR ORIGINAL ACM",
					SUM(SUM(ind."VALOR FINAL")) OVER (PARTITION BY ind.uneg_id ORDER BY ind."REFERENCIA") AS "VALOR FINAL ACM",
					SUM(SUM(ind."VALOR REFATURADO")) OVER (PARTITION BY ind.uneg_id ORDER BY ind."REFERENCIA") AS "VALOR REFATURADO/CANCELADO ACM"
				FROM
				(	SELECT
						loc.uneg_id AS uneg_id,
						TO_CHAR(con.cnta_dtretificacao, 'YYYYMM')::INTEGER AS "REFERENCIA",
						SUM(con_orig.cnta_vlagua+con_orig.cnta_vlesgoto+con_orig.cnta_vldebitos-con_orig.cnta_vlcreditos-con_orig.cnta_vlimpostos) AS "VALOR ORIGINAL",
						SUM(con.cnta_vlagua+con.cnta_vlesgoto+con.cnta_vldebitos-con.cnta_vlcreditos-con.cnta_vlimpostos) AS "VALOR FINAL",
						SUM((con_orig.cnta_vlagua+con_orig.cnta_vlesgoto+con_orig.cnta_vldebitos-con_orig.cnta_vlcreditos-con_orig.cnta_vlimpostos)-(con.cnta_vlagua+con.cnta_vlesgoto+con.cnta_vldebitos-con.cnta_vlcreditos-con.cnta_vlimpostos)) AS "VALOR REFATURADO"
					FROM
						faturamento.conta con
						INNER JOIN faturamento.conta con_orig ON con_orig.cnta_amreferenciaconta = con.cnta_amreferenciaconta AND con_orig.imov_id = con.imov_id AND con_orig.cnta_id <> con.cnta_id AND con_orig.dcst_idatual = 4
						INNER JOIN cadastro.imovel imo ON imo.imov_id = con.imov_id
						INNER JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
					WHERE
						con.dcst_idatual IN (1,5) AND
						TO_CHAR(con.cnta_dtretificacao, 'YYYYMM')::INTEGER>=((TO_CHAR(CURRENT_DATE, 'YYYY')||'01')::INTEGER) AND TO_CHAR(con.cnta_dtretificacao, 'YYYYMM')::INTEGER<=(TO_CHAR(CURRENT_DATE, 'YYYYMM')::INTEGER)
					GROUP BY 1,2
				UNION
					SELECT
						loc.uneg_id AS uneg_id,
						TO_CHAR(con.cnhi_dtretificacao, 'YYYYMM')::INTEGER AS "REFERENCIA",
						SUM(con_orig.cnta_vlagua+con_orig.cnta_vlesgoto+con_orig.cnta_vldebitos-con_orig.cnta_vlcreditos-con_orig.cnta_vlimpostos) AS "VALOR ORIGINAL",
						SUM(con.cnhi_vlagua+con.cnhi_vlesgoto+con.cnhi_vldebitos-con.cnhi_vlcreditos-con.cnhi_vlimpostos) AS "VALOR FINAL",
						SUM((con_orig.cnta_vlagua+con_orig.cnta_vlesgoto+con_orig.cnta_vldebitos-con_orig.cnta_vlcreditos-con_orig.cnta_vlimpostos)-(con.cnhi_vlagua+con.cnhi_vlesgoto+con.cnhi_vldebitos-con.cnhi_vlcreditos-con.cnhi_vlimpostos)) AS "VALOR REFATURADO"
					FROM
						faturamento.conta_historico con
						INNER JOIN faturamento.conta con_orig ON con_orig.cnta_amreferenciaconta = con.cnhi_amreferenciaconta AND con_orig.imov_id = con.imov_id AND con_orig.cnta_id <> con.cnta_id AND con_orig.dcst_idatual = 4
						INNER JOIN cadastro.imovel imo ON imo.imov_id = con.imov_id
						INNER JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
					WHERE
						con.dcst_idatual IN (1,5) AND
						TO_CHAR(con.cnhi_dtretificacao, 'YYYYMM')::INTEGER>=((TO_CHAR(CURRENT_DATE, 'YYYY')||'01')::INTEGER) AND TO_CHAR(con.cnhi_dtretificacao, 'YYYYMM')::INTEGER<=(TO_CHAR(CURRENT_DATE, 'YYYYMM')::INTEGER)
					GROUP BY 1,2
				UNION
					SELECT
						loc.uneg_id AS uneg_id,
						TO_CHAR(con.cnta_dtretificacao, 'YYYYMM')::INTEGER AS "REFERENCIA",
						SUM(con_orig.cnhi_vlagua+con_orig.cnhi_vlesgoto+con_orig.cnhi_vldebitos-con_orig.cnhi_vlcreditos-con_orig.cnhi_vlimpostos) AS "VALOR ORIGINAL",
						SUM(con.cnta_vlagua+con.cnta_vlesgoto+con.cnta_vldebitos-con.cnta_vlcreditos-con.cnta_vlimpostos) AS "VALOR FINAL",
						SUM((con_orig.cnhi_vlagua+con_orig.cnhi_vlesgoto+con_orig.cnhi_vldebitos-con_orig.cnhi_vlcreditos-con_orig.cnhi_vlimpostos)-(con.cnta_vlagua+con.cnta_vlesgoto+con.cnta_vldebitos-con.cnta_vlcreditos-con.cnta_vlimpostos)) AS "VALOR REFATURADO"
					FROM
						faturamento.conta con
						INNER JOIN faturamento.conta_historico con_orig ON con_orig.cnhi_amreferenciaconta = con.cnta_amreferenciaconta AND con_orig.imov_id = con.imov_id AND con_orig.cnta_id <> con.cnta_id AND con_orig.dcst_idatual = 4
						INNER JOIN cadastro.imovel imo ON imo.imov_id = con.imov_id
						INNER JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
					WHERE
						con.dcst_idatual IN (1,5) AND
						TO_CHAR(con.cnta_dtretificacao, 'YYYYMM')::INTEGER>=((TO_CHAR(CURRENT_DATE, 'YYYY')||'01')::INTEGER) AND TO_CHAR(con.cnta_dtretificacao, 'YYYYMM')::INTEGER<=(TO_CHAR(CURRENT_DATE, 'YYYYMM')::INTEGER)
					GROUP BY 1,2
				UNION
					SELECT
						loc.uneg_id AS uneg_id,
						TO_CHAR(con.cnhi_dtretificacao, 'YYYYMM')::INTEGER AS "REFERENCIA",
						SUM(con_orig.cnhi_vlagua+con_orig.cnhi_vlesgoto+con_orig.cnhi_vldebitos-con_orig.cnhi_vlcreditos-con_orig.cnhi_vlimpostos) AS "VALOR ORIGINAL",
						SUM(con.cnhi_vlagua+con.cnhi_vlesgoto+con.cnhi_vldebitos-con.cnhi_vlcreditos-con.cnhi_vlimpostos) AS "VALOR FINAL",
						SUM((con_orig.cnhi_vlagua+con_orig.cnhi_vlesgoto+con_orig.cnhi_vldebitos-con_orig.cnhi_vlcreditos-con_orig.cnhi_vlimpostos)-(con.cnhi_vlagua+con.cnhi_vlesgoto+con.cnhi_vldebitos-con.cnhi_vlcreditos-con.cnhi_vlimpostos)) AS "VALOR REFATURADO"
					FROM
						faturamento.conta_historico con
						INNER JOIN faturamento.conta_historico con_orig ON con_orig.cnhi_amreferenciaconta = con.cnhi_amreferenciaconta AND con_orig.imov_id = con.imov_id AND con_orig.cnta_id <> con.cnta_id AND con_orig.dcst_idatual = 4
						INNER JOIN cadastro.imovel imo ON imo.imov_id = con.imov_id
						INNER JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
					WHERE
						con.dcst_idatual IN (1,5) AND
						TO_CHAR(con.cnhi_dtretificacao, 'YYYYMM')::INTEGER>=((TO_CHAR(CURRENT_DATE, 'YYYY')||'01')::INTEGER) AND TO_CHAR(con.cnhi_dtretificacao, 'YYYYMM')::INTEGER<=(TO_CHAR(CURRENT_DATE, 'YYYYMM')::INTEGER)
					GROUP BY 1,2
				UNION
					SELECT
						loc.uneg_id AS uneg_id,
						TO_CHAR(con.cnta_dtcancelamento, 'YYYYMM')::INTEGER AS "REFERENCIA",
						SUM(con.cnta_vlagua+con.cnta_vlesgoto+con.cnta_vldebitos-con.cnta_vlcreditos-con.cnta_vlimpostos) AS "VALOR ORIGINAL",
						SUM(0) AS "VALOR FINAL",
						SUM(con.cnta_vlagua+con.cnta_vlesgoto+con.cnta_vldebitos-con.cnta_vlcreditos-con.cnta_vlimpostos) AS "VALOR REFATURADO"
					FROM
						faturamento.conta con
						INNER JOIN cadastro.imovel imo ON imo.imov_id = con.imov_id
						INNER JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
					WHERE
						con.dcst_idatual = 3 AND
						TO_CHAR(con.cnta_dtcancelamento, 'YYYYMM')::INTEGER>=((TO_CHAR(CURRENT_DATE, 'YYYY')||'01')::INTEGER) AND TO_CHAR(con.cnta_dtcancelamento, 'YYYYMM')::INTEGER<=(TO_CHAR(CURRENT_DATE, 'YYYYMM')::INTEGER)
					GROUP BY 1,2
				UNION
					SELECT
						loc.uneg_id AS uneg_id,
						TO_CHAR(con.cnhi_dtcancelamento, 'YYYYMM')::INTEGER AS "REFERENCIA",
						SUM(con.cnhi_vlagua+con.cnhi_vlesgoto+con.cnhi_vldebitos-con.cnhi_vlcreditos-con.cnhi_vlimpostos) AS "VALOR ORIGINAL",
						SUM(0) AS "VALOR FINAL",
						SUM(con.cnhi_vlagua+con.cnhi_vlesgoto+con.cnhi_vldebitos-con.cnhi_vlcreditos-con.cnhi_vlimpostos) AS "VALOR REFATURADO"
					FROM
						faturamento.conta_historico con
						INNER JOIN cadastro.imovel imo ON imo.imov_id = con.imov_id
						INNER JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
					WHERE
						con.dcst_idatual = 3 AND
						TO_CHAR(con.cnhi_dtcancelamento, 'YYYYMM')::INTEGER>=((TO_CHAR(CURRENT_DATE, 'YYYY')||'01')::INTEGER) AND TO_CHAR(con.cnhi_dtcancelamento, 'YYYYMM')::INTEGER<=(TO_CHAR(CURRENT_DATE, 'YYYYMM')::INTEGER)
					GROUP BY 1,2) AS ind
				GROUP BY 1,2) AS ind_refat ON ind_refat.uneg_id = une.uneg_id AND ind_refat."REFERENCIA" = refs."REFERENCIA"
		LEFT JOIN
		(
			SELECT
				ind.uneg_id AS uneg_id,
				ind."REFERENCIA" AS "REFERENCIA",
				ind."QTD CLIENTES ATUALIZADOS" AS "QTD CLIENTES ATUALIZADOS",
				SUM(ind."QTD CLIENTES ATUALIZADOS") OVER (PARTITION BY ind.uneg_id ORDER BY ind."REFERENCIA") AS "QTD CLIENTES ATUALIZADOS ACM"
			FROM
				(
					SELECT
						loc.uneg_id,
						TO_CHAR(tbc.tbca_tmultimaalteracao,'YYYYMM')::INTEGER AS "REFERENCIA",
						COUNT(distinct cli.clie_id) AS "QTD CLIENTES ATUALIZADOS"
					FROM
						seguranca.tabela_linha_alteracao tbl
						INNER JOIN seguranca.operacao_efetuada opf ON opf.opef_id = tbl.tref_id
						INNER JOIN seguranca.tab_linha_col_alteracao tbc ON tbl.tbla_id = tbc.tbla_id
						INNER JOIN seguranca.tabela_coluna tco ON tco.tbco_id = tbc.tbco_id
						INNER JOIN cadastro.cliente cli ON cli.clie_id = opf.opef_cnargumento
						INNER JOIN cadastro.cliente_imovel cim ON cim.clie_id = cli.clie_id AND cim.clim_dtrelacaofim IS NULL
						INNER JOIN cadastro.imovel imo ON imo.imov_id = cim.imov_id
						INNER JOIN cadastro.localidade loc ON loc.loca_id = imo.loca_id
					WHERE
						--tbl.tabe_id = 60
						--AND tbc.tbca_cncolunaanterior <> tbc.tbca_cncolunaatual
						--AND 
						tbc.tbco_id IN (271, 272, 275, 276, 701, 60, 4796, 23848, 23850, 1527, 1529, 1531, 1539, 2524, 2525, 2526, 2527, 2529)
						--AND tbc.tbca_tmultimaalteracao >= (CURRENT_DATE::TIMESTAMP)
						AND TO_CHAR(tbc.tbca_tmultimaalteracao,'YYYYMM')::INTEGER>=((TO_CHAR(CURRENT_DATE, 'YYYY')||'01')::INTEGER) AND TO_CHAR(tbc.tbca_tmultimaalteracao,'YYYYMM')::INTEGER<=(TO_CHAR(CURRENT_DATE, 'YYYYMM')::INTEGER)
						--AND usu.usur_nmlogin = 'YGOR'
					GROUP BY 1,2
					ORDER BY 2 DESC) AS ind
		) AS ind_cadastro ON ind_cadastro.uneg_id = une.uneg_id AND ind_cadastro."REFERENCIA" = refs."REFERENCIA"
		LEFT JOIN
			(
				SELECT
					ind.uneg_id AS uneg_id,
					ind."REFERENCIA" AS "REFERENCIA",
					SUM(ind."VALOR MES") AS "VALOR MES",
					SUM(SUM(ind."VALOR MES")) OVER (PARTITION BY ind.uneg_id ORDER BY ind."REFERENCIA")  AS "VALOR ACM"
				FROM(
					SELECT
						loc.uneg_id AS uneg_id,
						res.ardd_amreferenciaarrecadacao AS "REFERENCIA",
						SUM(res.ardd_vlpagamentos) AS "VALOR MES"
					FROM
						arrecadacao.arrec_dados_diarios res
						LEFT JOIN cadastro.localidade loc ON loc.loca_id = res.loca_id
					WHERE
						res.ardd_amreferenciaarrecadacao>=201901 AND res.ardd_amreferenciaarrecadacao<= ('2019'||TO_CHAR(CURRENT_DATE, 'MM'))::INTEGER
					GROUP BY 1,2) AS ind
					GROUP BY 1,2) AS arrecadacao_acm_2019 ON arrecadacao_acm_2019.uneg_id = une.uneg_id AND arrecadacao_acm_2019."REFERENCIA" = refs."REFERENCIA"-100
		LEFT JOIN
			(
				SELECT
					ind.uneg_id AS uneg_id,
					ind."REFERENCIA" AS "REFERENCIA",
					SUM(ind."VALOR MES") AS "VALOR MES",
					SUM(SUM(ind."VALOR MES")) OVER (PARTITION BY ind.uneg_id ORDER BY ind."REFERENCIA")  AS "VALOR ACM"
				FROM(
					SELECT
						loc.uneg_id AS uneg_id,
						res.ardd_amreferenciaarrecadacao AS "REFERENCIA",
						SUM(res.ardd_vlpagamentos) AS "VALOR MES"
					FROM
						arrecadacao.arrec_dados_diarios res
						LEFT JOIN cadastro.localidade loc ON loc.loca_id = res.loca_id
					WHERE
						res.ardd_amreferenciaarrecadacao >= ((TO_CHAR(CURRENT_DATE, 'YYYY')||'01')::INTEGER) AND res.ardd_amreferenciaarrecadacao <= (TO_CHAR(CURRENT_DATE, 'YYYYMM')::INTEGER)
					GROUP BY 1,2) AS ind
					GROUP BY 1,2) AS arrecadacao_acm_2020 ON arrecadacao_acm_2020.uneg_id = une.uneg_id AND arrecadacao_acm_2020."REFERENCIA" = refs."REFERENCIA"
ORDER BY 2,1