SELECT
	arr.uneg_id AS "COD UNIDADE",
	arr.nome_unidade AS "UNIDADE",
	arr.localidade AS "LOCALIDADE",
	arr.municipio AS "MUNICIPIO",
	arr.zona AS "ZONA",
	arr.referencia AS "REFERENCIA",
	arr.categoria AS "CATEGORIA",
	arr.perfil AS "PERFIL",
	arr.tipodoc AS "TIPO DOCUMENTO",
	arr.doc_agg AS "DOC AGREGADOR",
	arr.data_pag AS "DATA PAG",
	SUM(arr.valor) AS "VALOR PAG",
	SUM(arr.valor_dev) AS "VALOR DEV",
	SUM(arr.valor-arr.valor_dev) AS "VALOR ARR",
	(CASE 
	WHEN (arr.perfil = '6-VIVA AGUA' OR arr.categoria='PUBLICO') THEN SUM(arr.valor-arr.valor_dev)
	ELSE 0
	END) AS "VALOR PB+VA",
	(CASE 
	WHEN (arr.perfil <> '6-VIVA AGUA' AND arr.categoria<>'PUBLICO') THEN SUM(arr.valor-arr.valor_dev)
	ELSE 0
	END) AS "VALOR S PB+VA"
FROM
(SELECT
	une.uneg_id AS uneg_id,
	une.uneg_nmunidadenegocio AS nome_unidade,
	arrecadacao.loca AS localidade,
	arrecadacao.muni AS municipio,
	arrecadacao.dist AS zona,
	arrecadacao.referencia AS referencia,
	cat.catg_dscategoria AS categoria,
	per.iper_id::TEXT || '-'||per.iper_dsimovelperfil AS perfil,
	arrecadacao.doc_tipo AS tipodoc,
	arrecadacao.doc_agg AS doc_agg,
	arrecadacao.data_pag AS data_pag,
	arrecadacao.valor AS valor,
	0 AS valor_dev
FROM
	cadastro.unidade_negocio une
	CROSS JOIN cadastro.categoria cat
	CROSS JOIN cadastro.imovel_perfil per
	LEFT JOIN 
	(
		SELECT
			res.uneg_id AS uneg_id,
			loc.loca_nmlocalidade AS loca,
			mun.muni_nmmunicipio AS muni,
			dis.diop_dsdistritooperacional AS dist,
			res.ardd_dtpagamento AS data_pag,
			res.ardd_amreferenciaarrecadacao AS referencia,
			dot.dotp_dsdocumentotipo AS doc_tipo,
			doag.dotp_dsdocumentotipo AS doc_agg,
			res.catg_id AS catg_id,
			res.iper_id AS iper_id,
			SUM(res.ardd_vlpagamentos) AS valor
		FROM
			arrecadacao.arrec_dados_diarios res
			LEFT JOIN cadastro.quadra qdr ON qdr.qdra_id = res.qdra_id
			LEFT JOIN operacional.distrito_operacional dis ON dis.diop_id = qdr.diop_id-- AND dis.diop_id IN (5,6,7)
			LEFT JOIN cadastro.localidade loc ON loc.loca_id = res.loca_id
			LEFT JOIN cobranca.documento_tipo dot ON dot.dotp_id = res.dotp_id
			LEFT JOIN cobranca.documento_tipo doag ON doag.dotp_id = res.dotp_idagregador
			LEFT JOIN cadastro.municipio mun ON mun.muni_id = loc.muni_idprincipal
		WHERE
			res.ardd_amreferenciaarrecadacao >= TO_CHAR((CURRENT_DATE - INTERVAL '1y'),'yyyyMM')::INTEGER
		GROUP BY 1,2,3,4,5,6,7,8,9,10
	) AS arrecadacao ON une.uneg_id = arrecadacao.uneg_id AND cat.catg_id = arrecadacao.catg_id AND per.iper_id = arrecadacao.iper_id
UNION
SELECT
	une.uneg_id AS uneg_id,
	une.uneg_nmunidadenegocio AS nome_unidade,
	devolucoes.loca AS localidade,
	devolucoes.muni AS municipio,
	devolucoes.dist AS zona,
	devolucoes.referencia AS referencia,
	cat.catg_dscategoria AS categoria,
	per.iper_id::TEXT || '-'||per.iper_dsimovelperfil AS perfil,
	devolucoes.doc_tipo AS tipodoc,
	devolucoes.doc_agg AS doc_agg,
	devolucoes.data_pag AS data_pag,
	0 AS valor,
	devolucoes.valor AS valor_dev
FROM
	cadastro.unidade_negocio une
	CROSS JOIN cadastro.categoria cat
	CROSS JOIN cadastro.imovel_perfil per
	LEFT JOIN 
	(
		SELECT
			dev.uneg_id AS uneg_id,
			loc.loca_nmlocalidade AS loca,
			mun.muni_nmmunicipio AS muni,
			dis.diop_dsdistritooperacional AS dist,			
			dev.dvdd_dtdevolucao AS data_pag,
			dev.dvdd_amreferenciaarrecadacao AS referencia,
			dot.dotp_dsdocumentotipo AS doc_tipo,
			doag.dotp_dsdocumentotipo AS doc_agg,
			dev.catg_id AS catg_id,
			dev.iper_id AS iper_id,
			SUM(dev.dvdd_vldevolucoes) AS valor
		FROM
			arrecadacao.devolucao_dados_diarios dev
			LEFT JOIN cadastro.quadra qdr ON qdr.qdra_id = dev.qdra_id
			LEFT JOIN operacional.distrito_operacional dis ON dis.diop_id = qdr.diop_id --AND dis.diop_id IN (5,6,7)
			LEFT JOIN cadastro.localidade loc ON loc.loca_id = dev.loca_id
			LEFT JOIN cobranca.documento_tipo dot ON dot.dotp_id = dev.dotp_id
			LEFT JOIN cobranca.documento_tipo doag ON doag.dotp_id = dev.dotp_idagregador
			LEFT JOIN cadastro.municipio mun ON mun.muni_id = loc.muni_idprincipal
		WHERE
			dev.dvdd_amreferenciaarrecadacao >= TO_CHAR((CURRENT_DATE - INTERVAL '1y'),'yyyyMM')::INTEGER
		GROUP BY 1,2,3,4,5,6,7,8,9,10
	) AS devolucoes ON une.uneg_id = devolucoes.uneg_id AND cat.catg_id = devolucoes.catg_id AND per.iper_id = devolucoes.iper_id) AS arr
GROUP BY 1,2,3,4,5,6,7,8,9,10,11
