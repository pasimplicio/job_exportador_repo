SELECT
	TO_CHAR(datas.dat,'dd/MM/yyyy') AS "DATA",
	cat.catg_dscategoria AS "CATEGORIA",
	une.uneg_id AS "UNEG_ID",
	une.uneg_nmunidadenegocio AS "UNIDADE",
	loc.loca_nmlocalidade AS "LOCALIDADE",
	rot.rota_cdrota AS "ROTA",
	qdr.qdra_nnquadra AS "QUADRA",
	TO_CHAR((COALESCE(arr."VALOR PAGAMENTOS",0) - COALESCE(dev."VALOR DEVOLUCAO",0)),'999G999G990D00') AS "ARRECADACAO",
	TO_CHAR(SUM(COALESCE(fat."VALOR FAT",0)),'999G999G990D00') AS "VALOR FATURAMENTO"
FROM
	(SELECT date_trunc('day', dat):: date AS dat FROM generate_series( '2021-03-01'::DATE, '2021-03-31'::DATE, '1 day'::interval) AS dat) AS datas
	CROSS JOIN cadastro.quadra qdr
	CROSS JOIN cadastro.categoria cat
	LEFT JOIN micromedicao.rota rot ON rot.rota_id = qdr.rota_id
	LEFT JOIN cadastro.setor_comercial stc ON stc.stcm_id = rot.stcm_id
	LEFT JOIN cadastro.localidade loc ON loc.loca_id = stc.loca_id
	LEFT JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
	LEFT JOIN
		(SELECT 
			datas.dat AS "DATA",
			res.catg_id AS "CATEGORIA",
			res.qdra_id AS "QUADRA",
			SUM(res.ardd_qtpagamentos) AS "QTD PAGAMENTOS",
			SUM(res.ardd_vlpagamentos) AS "VALOR PAGAMENTOS"
		FROM
			(SELECT date_trunc('day', dat):: date AS dat FROM generate_series( '2021-03-01'::DATE, '2021-03-31'::DATE, '1 day'::interval) AS dat) AS datas
			INNER JOIN arrecadacao.arrec_dados_diarios res ON res.ardd_dtpagamento = datas.dat
		GROUP BY 1,2,3) AS arr ON arr."DATA" = datas.dat AND cat.catg_id = arr."CATEGORIA" AND arr."QUADRA" = qdr.qdra_id
	LEFT JOIN
		(SELECT 
			datas.dat AS "DATA",
			dev.catg_id AS "CATEGORIA",
			dev.qdra_id AS "QUADRA",
			SUM(dev.dvdd_qtdevolucoes) AS "QTD PAGAMENTOS",
			SUM(dev.dvdd_vldevolucoes) AS "VALOR DEVOLUCAO"
		FROM
			(SELECT date_trunc('day', dat):: date AS dat FROM generate_series( '2021-03-01'::DATE, '2021-03-31'::DATE, '1 day'::interval) AS dat) AS datas
			INNER JOIN arrecadacao.devolucao_dados_diarios dev ON dev.dvdd_dtdevolucao = datas.dat
		GROUP BY 1,2,3) AS dev ON dev."DATA" = datas.dat AND dev."QUADRA" = qdr.qdra_id AND cat.catg_id = dev."CATEGORIA"
	LEFT JOIN
		(SELECT 
			datas.dat AS "DATA",
			cat.catg_id AS "CATEGORIA",
			con4.qdra_id AS "QUADRA",
			COUNT(con4.cnta_id) AS "QTD CONTAS",
			SUM(con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos) AS "VALOR FAT"
		FROM
			(SELECT date_trunc('day', dat):: date AS dat FROM generate_series( '2021-03-01'::DATE, '2021-03-31'::DATE, '1 day'::interval) AS dat) AS datas
			INNER JOIN faturamento.conta con4 ON con4.cnta_dtemissao = datas.dat
			INNER JOIN faturamento.conta_impressao cni ON cni.cnta_id = con4.cnta_id
			INNER JOIN cadastro.imovel imo ON imo.imov_id = con4.imov_id
			INNER JOIN cadastro.categoria cat ON cat.catg_id = imo.imov_idcategoriaprincipal
		WHERE
			con4.dcst_idatual <> 9
		GROUP BY 1,2,3
		UNION
		SELECT 
			datas.dat AS "DATA",
			cat.catg_id AS "CATEGORIA",
			con4.qdra_id AS "QUADRA",
			COUNT(con4.cnta_id) AS "QTD CONTAS",
			SUM(con4.cnhi_vlagua+con4.cnhi_vlesgoto+con4.cnhi_vldebitos-con4.cnhi_vlcreditos-con4.cnhi_vlimpostos) AS "VALOR FAT"
		FROM
			(SELECT date_trunc('day', dat):: date AS dat FROM generate_series( '2021-03-01'::DATE, '2021-03-31'::DATE, '1 day'::interval) AS dat) AS datas
			INNER JOIN faturamento.conta_historico con4 ON con4.cnhi_dtemissao = datas.dat
			INNER JOIN faturamento.conta_impressao cni ON cni.cnta_id = con4.cnta_id
			INNER JOIN cadastro.imovel imo ON imo.imov_id = con4.imov_id
			INNER JOIN cadastro.categoria cat ON cat.catg_id = imo.imov_idcategoriaprincipal
		WHERE
			con4.dcst_idatual <> 9
		GROUP BY 1,2,3
		UNION
		SELECT 
			datas.dat AS "DATA",
			cat.catg_id AS "CATEGORIA",
			con4.qdra_id AS "QUADRA",
			COUNT(con4.cnta_id) AS "QTD CONTAS",
			SUM(con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos) AS "VALOR FAT"
		FROM
			(SELECT date_trunc('day', dat):: date AS dat FROM generate_series( '2021-03-01'::DATE, '2021-03-31'::DATE, '1 day'::interval) AS dat) AS datas
			INNER JOIN faturamento.conta con4 ON con4.cnta_dtemissao = datas.dat
			INNER JOIN faturamento.mov_conta_prefaturada cni ON cni.cnta_id = con4.cnta_id
			INNER JOIN cadastro.imovel imo ON imo.imov_id = con4.imov_id
			INNER JOIN cadastro.categoria cat ON cat.catg_id = imo.imov_idcategoriaprincipal
		WHERE
			con4.dcst_idatual <> 9
		GROUP BY 1,2,3
		UNION
		SELECT 
			datas.dat AS "DATA",
			cat.catg_id AS "CATEGORIA",
			con4.qdra_id AS "QUADRA",
			COUNT(con4.cnta_id) AS "QTD CONTAS",
			SUM(con4.cnhi_vlagua+con4.cnhi_vlesgoto+con4.cnhi_vldebitos-con4.cnhi_vlcreditos-con4.cnhi_vlimpostos) AS "VALOR FAT"
		FROM
			(SELECT date_trunc('day', dat):: date AS dat FROM generate_series( '2021-03-01'::DATE, '2021-03-31'::DATE, '1 day'::interval) AS dat) AS datas
			INNER JOIN faturamento.conta_historico con4 ON con4.cnhi_dtemissao = datas.dat
			INNER JOIN faturamento.mov_conta_prefaturada cni ON cni.cnta_id = con4.cnta_id
			INNER JOIN cadastro.imovel imo ON imo.imov_id = con4.imov_id
			INNER JOIN cadastro.categoria cat ON cat.catg_id = imo.imov_idcategoriaprincipal
		WHERE
			con4.dcst_idatual <> 9
		GROUP BY 1,2,3) AS fat ON fat."DATA" = datas.dat AND fat."QUADRA" = qdr.qdra_id AND cat.catg_id = fat."CATEGORIA"
WHERE
	(arr."VALOR PAGAMENTOS">0 OR dev."VALOR DEVOLUCAO">0 OR fat."VALOR FAT">0)
GROUP BY 1,2,3,4,5,6,7,8