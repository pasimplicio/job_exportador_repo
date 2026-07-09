SELECT
	TO_CHAR(datas.dat,'dd/MM/yyyy') AS "DATA",
	une.uneg_id AS "UNEG_ID",
	une.uneg_nmunidadenegocio AS "UNIDADE",
	cat.catg_dscategoria AS "CATEGORIA",
	TO_CHAR((COALESCE(arr."VALOR PAGAMENTOS",0) - COALESCE(dev."VALOR DEVOLUCAO",0)),'999G999G990D00') AS "ARRECADACAO",
	TO_CHAR(SUM(COALESCE(fat."VALOR FAT",0)),'999G999G990D00') AS "VALOR FATURAMENTO"
FROM
	(SELECT date_trunc('day', dat):: date AS dat FROM generate_series( '2020-01-01'::DATE, '2020-12-31'::DATE, '1 day'::interval) AS dat) AS datas
	CROSS JOIN cadastro.unidade_negocio une
	CROSS JOIN cadastro.categoria cat
	LEFT JOIN
		(SELECT 
			datas.dat AS "DATA",
			une.uneg_id AS "UNIDADE",
			cat.catg_id AS "CATEGORIA",
			SUM(res.ardd_vlpagamentos) AS "VALOR PAGAMENTOS"
		FROM
			(SELECT date_trunc('day', dat):: date AS dat FROM generate_series( '2020-01-01'::DATE, '2020-12-31'::DATE, '1 day'::interval) AS dat) AS datas
			INNER JOIN arrecadacao.arrec_dados_diarios res ON res.ardd_dtpagamento = datas.dat
			INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = res.uneg_id
			INNER JOIN cadastro.categoria cat ON cat.catg_id = res.catg_id
		GROUP BY 1,2,3) AS arr ON arr."DATA" = datas.dat AND arr."UNIDADE" = une.uneg_id AND cat.catg_id = arr."CATEGORIA"
	LEFT JOIN
		(SELECT 
			datas.dat AS "DATA",
			une.uneg_id AS "UNIDADE",
			cat.catg_id AS "CATEGORIA",
			SUM(dev.dvdd_vldevolucoes) AS "VALOR DEVOLUCAO"
		FROM
			(SELECT date_trunc('day', dat):: date AS dat FROM generate_series( '2020-01-01'::DATE, '2020-12-31'::DATE, '1 day'::interval) AS dat) AS datas
			INNER JOIN arrecadacao.devolucao_dados_diarios dev ON dev.dvdd_dtdevolucao = datas.dat
			INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = dev.uneg_id
			INNER JOIN cadastro.categoria cat ON cat.catg_id = dev.catg_id
		GROUP BY 1,2,3) AS dev ON dev."DATA" = datas.dat AND dev."UNIDADE" = une.uneg_id AND cat.catg_id = dev."CATEGORIA"
	LEFT JOIN
		(SELECT 
			datas.dat AS "DATA",
			une.uneg_id AS "UNIDADE",
			cat.catg_id AS "CATEGORIA",
			SUM(con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos) AS "VALOR FAT"
		FROM
			(SELECT date_trunc('day', dat):: date AS dat FROM generate_series( '2020-01-01'::DATE, '2020-12-31'::DATE, '1 day'::interval) AS dat) AS datas
			INNER JOIN faturamento.conta con4 ON con4.cnta_dtemissao = datas.dat
			INNER JOIN faturamento.conta_impressao cni ON cni.cnta_id = con4.cnta_id
			INNER JOIN cadastro.localidade loc ON loc.loca_id = con4.loca_id
			INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
			INNER JOIN cadastro.imovel imo ON imo.imov_id = con4.imov_id
			INNER JOIN cadastro.categoria cat ON cat.catg_id = imo.imov_idcategoriaprincipal
		WHERE
			con4.dcst_idatual <> 9
		GROUP BY 1,2,3
		UNION
		SELECT 
			datas.dat AS "DATA",
			une.uneg_id AS "UNIDADE",
			cat.catg_id AS "CATEGORIA",
			SUM(con4.cnhi_vlagua+con4.cnhi_vlesgoto+con4.cnhi_vldebitos-con4.cnhi_vlcreditos-con4.cnhi_vlimpostos) AS "VALOR FAT"
		FROM
			(SELECT date_trunc('day', dat):: date AS dat FROM generate_series( '2020-01-01'::DATE, '2020-12-31'::DATE, '1 day'::interval) AS dat) AS datas
			INNER JOIN faturamento.conta_historico con4 ON con4.cnhi_dtemissao = datas.dat
			INNER JOIN faturamento.conta_impressao cni ON cni.cnta_id = con4.cnta_id
			INNER JOIN cadastro.localidade loc ON loc.loca_id = con4.loca_id
			INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
			INNER JOIN cadastro.imovel imo ON imo.imov_id = con4.imov_id
			INNER JOIN cadastro.categoria cat ON cat.catg_id = imo.imov_idcategoriaprincipal
		WHERE
			con4.dcst_idatual <> 9
		GROUP BY 1,2,3
		UNION
		SELECT 
			datas.dat AS "DATA",
			une.uneg_id AS "UNIDADE",
			cat.catg_id AS "CATEGORIA",
			SUM(con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos) AS "VALOR FAT"
		FROM
			(SELECT date_trunc('day', dat):: date AS dat FROM generate_series( '2020-01-01'::DATE, '2020-12-31'::DATE, '1 day'::interval) AS dat) AS datas
			INNER JOIN faturamento.conta con4 ON con4.cnta_dtemissao = datas.dat
			INNER JOIN faturamento.mov_conta_prefaturada cni ON cni.cnta_id = con4.cnta_id
			INNER JOIN cadastro.localidade loc ON loc.loca_id = con4.loca_id
			INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
			INNER JOIN cadastro.imovel imo ON imo.imov_id = con4.imov_id
			INNER JOIN cadastro.categoria cat ON cat.catg_id = imo.imov_idcategoriaprincipal
		WHERE
			con4.dcst_idatual <> 9
		GROUP BY 1,2,3
		UNION
		SELECT 
			datas.dat AS "DATA",
			une.uneg_id AS "UNIDADE",
			cat.catg_id AS "CATEGORIA",
			SUM(con4.cnhi_vlagua+con4.cnhi_vlesgoto+con4.cnhi_vldebitos-con4.cnhi_vlcreditos-con4.cnhi_vlimpostos) AS "VALOR FAT"
		FROM
			(SELECT date_trunc('day', dat):: date AS dat FROM generate_series( '2020-01-01'::DATE, '2020-12-31'::DATE, '1 day'::interval) AS dat) AS datas
			INNER JOIN faturamento.conta_historico con4 ON con4.cnhi_dtemissao = datas.dat
			INNER JOIN faturamento.mov_conta_prefaturada cni ON cni.cnta_id = con4.cnta_id
			INNER JOIN cadastro.localidade loc ON loc.loca_id = con4.loca_id
			INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
			INNER JOIN cadastro.imovel imo ON imo.imov_id = con4.imov_id
			INNER JOIN cadastro.categoria cat ON cat.catg_id = imo.imov_idcategoriaprincipal
		WHERE
			con4.dcst_idatual <> 9
		GROUP BY 1,2,3) AS fat ON fat."DATA" = datas.dat AND fat."UNIDADE" = une.uneg_id AND cat.catg_id = fat."CATEGORIA"
GROUP BY 1,2,3,4,5