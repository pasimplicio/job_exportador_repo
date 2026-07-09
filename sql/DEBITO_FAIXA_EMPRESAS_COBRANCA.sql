SELECT
	sup.greg_nmregional AS "SUPERINTENDENCIA",
	une.uneg_nmunidadenegocio AS "UNIDADE",
	emp.empr_nmempresa AS "EMPRESA",
	(CASE imo.imov_idsubcategoriaprincipal 
	WHEN 1 THEN '1 - RESIDENCIAL'
	WHEN 2 THEN '2 - COMERCIAL'
	WHEN 3 THEN '3 - INDUSTRIAL'
	WHEN 4 THEN '4 - MUNICIPAL'
	WHEN 5 THEN '5 - ESTADUAL'
	WHEN 6 THEN '6 - FEDERAL'
	WHEN 7 THEN '7 - RES. POPULAR'
	WHEN 8 THEN '8 - PEQ. NEGOCIOS'
	WHEN 9 THEN '9 - ENT. FILANTROPICAS'
	WHEN 10 THEN '10 - SIST. OPERADO POR PREFEITURA'
	WHEN 11 THEN '11 - OUTROS'
	ELSE 'NAO DEFINIDO'
	END) AS "SUBCATEGORIA PRINCIPAL",
	ipe.iper_dsimovelperfil AS "PERFIL",
	(CASE 
	WHEN con.cnta_dtvencimentoconta < CURRENT_DATE::DATE AND con.cnta_dtvencimentoconta >= CURRENT_DATE::DATE - INTERVAL '45d' THEN '1 - ATÉ 45 DIAS'
	WHEN con.cnta_dtvencimentoconta < CURRENT_DATE::DATE - INTERVAL '45d' AND con.cnta_dtvencimentoconta >= CURRENT_DATE::DATE - INTERVAL '90d' THEN '2 - DE 45 A 90 DIAS'
	WHEN con.cnta_dtvencimentoconta < CURRENT_DATE::DATE - INTERVAL '90d' AND con.cnta_dtvencimentoconta >= CURRENT_DATE::DATE - INTERVAL '180d' THEN '3 - DE 90 A 180 DIAS'
	WHEN con.cnta_dtvencimentoconta < CURRENT_DATE::DATE - INTERVAL '180d' AND con.cnta_dtvencimentoconta >= CURRENT_DATE::DATE - INTERVAL '1y' THEN '4 - DE 180 DIAS A 1 ANO'
	WHEN con.cnta_dtvencimentoconta < CURRENT_DATE::DATE - INTERVAL '1y' AND con.cnta_dtvencimentoconta >= CURRENT_DATE::DATE - INTERVAL '5y' THEN '5 - DE 1 A 5 ANOS'
	WHEN con.cnta_dtvencimentoconta < CURRENT_DATE::DATE - INTERVAL '5y' AND con.cnta_dtvencimentoconta >= CURRENT_DATE::DATE - INTERVAL '10y' THEN '6 - DE 5 A 10 ANOS'
	WHEN con.cnta_dtvencimentoconta < CURRENT_DATE::DATE - INTERVAL '10y' THEN '7 - ACIMA DE 10 ANOS'
	END) AS "FAIXA ATRASO",
	(CURRENT_DATE::DATE - con.cnta_dtvencimentoconta) AS "ATRASO",
	COUNT(con.cnta_id) AS "QTD DE CONTAS",
	COUNT(distinct con.imov_id) AS "QTD DE IMOVEIS",
	SUM(con.cnta_vlagua) AS "VALOR AGUA",
	SUM(con.cnta_vlesgoto) AS "VALOR ESGOTO",
	SUM(con.cnta_vldebitos) AS "VALOR OUTROS SERVICOS",
	SUM(con.cnta_vlcreditos) AS "VALOR CREDITOS",
	SUM(con.cnta_vlimpostos) AS "VALOR IMPOSTOS",
	SUM(con.cnta_vlagua+con.cnta_vlesgoto+con.cnta_vldebitos-con.cnta_vlcreditos-con.cnta_vlimpostos) AS "VALOR CONTA",
	SUM(TRUNC(((con.cnta_vlagua+con.cnta_vlesgoto+con.cnta_vldebitos-con.cnta_vlcreditos-con.cnta_vlimpostos)*0.02)::NUMERIC,2)) AS "MULTA POR IMPONTUALIDADE",
	SUM(TRUNC(((con.cnta_vlagua+con.cnta_vlesgoto+con.cnta_vldebitos-con.cnta_vlcreditos-con.cnta_vlimpostos)*0.005*(((EXTRACT(YEAR FROM CURRENT_DATE::DATE)-EXTRACT(YEAR FROM con.cnta_dtvencimentoconta))*12)+(EXTRACT(MONTH FROM CURRENT_DATE::DATE)-EXTRACT(MONTH FROM con.cnta_dtvencimentoconta))))::NUMERIC, 2)) AS "JUROS DE MORA"
FROM
	faturamento.conta con
	INNER JOIN cadastro.imovel imo ON imo.imov_id = con.imov_id
	INNER JOIN cadastro.imovel_perfil ipe ON ipe.iper_id = con.iper_id
	INNER JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
	INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
	INNER JOIN cadastro.gerencia_regional sup ON sup.greg_id = loc.greg_id
	INNER JOIN cobranca.empresa_cobranca_conta ecc ON ecc.cnta_id = con.cnta_id AND ecc.ecco_dtretiradaconta IS NULL
	LEFT JOIN cadastro.empresa emp ON emp.empr_id = ecc.empr_id
WHERE
	con.dcst_idatual IN (0,1,2) AND
	NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con.cnta_id) AND 
	con.cnta_dtvencimentoconta < CURRENT_DATE::DATE AND 
	imo.imov_icexclusao = 2 AND
	--con.cnta_amreferenciaconta <= 201906 AND
	con.cnta_dtrevisao IS NULL
GROUP BY 1,2,3,4,5,6,7
ORDER BY 3,2,1