SELECT
	une.uneg_nmunidadenegocio AS "UNIDADE",
	cat.catg_dscategoria AS "CATEGORIA",
	sct.scat_dssubcategoria AS "SUBCATEGORIA PRINCIPAL",
	ipe.iper_dsimovelperfil AS "PERFIL",
	(CASE 
	WHEN CURRENT_DATE - con.cnta_dtvencimentoconta <= 0 THEN '01 - EM DIA'
	WHEN CURRENT_DATE - con.cnta_dtvencimentoconta <= 5  THEN '02 - ATE 5 DIAS DE ATRASO'
	WHEN CURRENT_DATE - con.cnta_dtvencimentoconta <= 15  THEN '03 - ATE 15 DIAS DE ATRASO'
	WHEN CURRENT_DATE - con.cnta_dtvencimentoconta <= 30  THEN '04 - ATE 30 DIAS DE ATRASO'
	WHEN CURRENT_DATE - con.cnta_dtvencimentoconta <= 60  THEN '05 - ATE 60 DIAS DE ATRASO'
	WHEN CURRENT_DATE - con.cnta_dtvencimentoconta <= 90  THEN '06 - ATE 90 DIAS DE ATRASO'
	WHEN CURRENT_DATE - con.cnta_dtvencimentoconta <= 180  THEN '07 - ATE 180 DIAS DE ATRASO'
	WHEN CURRENT_DATE - con.cnta_dtvencimentoconta <= 365  THEN '08 - ATE 365 DIAS DE ATRASO'
	WHEN CURRENT_DATE - con.cnta_dtvencimentoconta <= 1825  THEN '09 - ATE 5 ANOS DE ATRASO'
	WHEN CURRENT_DATE - con.cnta_dtvencimentoconta <= 3650  THEN '10 - ATE 10 ANOS DE ATRASO'
	WHEN CURRENT_DATE - con.cnta_dtvencimentoconta > 3650  THEN '11 - ACIMA DE 10 ANOS DE ATRASO'
	END) AS "FAIXA ATRASO",
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
	LEFT JOIN cadastro.categoria cat ON cat.catg_id = imo.imov_idcategoriaprincipal
	LEFT JOIN cadastro.subcategoria sct ON sct.scat_id = imo.imov_idsubcategoriaprincipal
WHERE
	con.dcst_idatual IN (0,1,2) AND
	NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con.cnta_id) AND 
	con.cnta_dtvencimentoconta < CURRENT_DATE AND 
	imo.imov_icexclusao = 2
	--con.cnta_amreferenciaconta <= 201906 AND
GROUP BY 1,2,3,4,5
ORDER BY 3,2,1