	SELECT
		'ARRECADACAO' AS "TIPO",
		arr.uneg_id AS "COD UNIDADE",
		arr.nome_unidade AS "UNIDADE",
		arr.localidade AS "LOCALIDADE",
		arr.sec AS "SETOR COMERCIAL",
		arr.rota AS "ROTA",
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
		END) AS "VALOR S PB+VA",
		'' AS "VL FATURADO",
		0 AS "FATURADO PB+VA",
		0 AS "FATURADO S PB+VA"
	FROM
	(SELECT
		une.uneg_id AS uneg_id,
		une.uneg_nmunidadenegocio AS nome_unidade,
		arrecadacao.loca AS localidade,
		arrecadacao.sec AS sec,
		arrecadacao.rota AS rota,
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
				sec.stcm_cdsetorcomercial AS sec,
				rot.rota_cdrota AS rota,
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
				LEFT JOIN cadastro.setor_comercial sec ON res.stcm_id = sec.stcm_id
				LEFT JOIN micromedicao.rota rot ON rot.rota_id = res.rota_id
				LEFT JOIN cobranca.documento_tipo dot ON dot.dotp_id = res.dotp_id
				LEFT JOIN cobranca.documento_tipo doag ON doag.dotp_id = res.dotp_idagregador
				LEFT JOIN cadastro.municipio mun ON mun.muni_id = loc.muni_idprincipal
			WHERE
				res.ardd_amreferenciaarrecadacao >= TO_CHAR((CURRENT_DATE - INTERVAL '6Months'),'yyyyMM')::INTEGER
			GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12
		) AS arrecadacao ON une.uneg_id = arrecadacao.uneg_id AND cat.catg_id = arrecadacao.catg_id AND per.iper_id = arrecadacao.iper_id
	UNION
	SELECT
		une.uneg_id AS uneg_id,
		une.uneg_nmunidadenegocio AS nome_unidade,
		devolucoes.loca AS localidade,
		devolucoes.sec AS sec,
		devolucoes.rota AS rota,
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
				sec.stcm_cdsetorcomercial AS sec,
				rot.rota_cdrota AS rota,
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
				LEFT JOIN cadastro.setor_comercial sec ON dev.stcm_id = sec.stcm_id
				LEFT JOIN micromedicao.rota rot ON rot.rota_id = dev.rota_id
				LEFT JOIN cobranca.documento_tipo dot ON dot.dotp_id = dev.dotp_id
				LEFT JOIN cobranca.documento_tipo doag ON doag.dotp_id = dev.dotp_idagregador
				LEFT JOIN cadastro.municipio mun ON mun.muni_id = loc.muni_idprincipal
			WHERE
				dev.dvdd_amreferenciaarrecadacao >= TO_CHAR((CURRENT_DATE - INTERVAL '6Months'),'yyyyMM')::INTEGER
			GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12
		) AS devolucoes ON une.uneg_id = devolucoes.uneg_id AND cat.catg_id = devolucoes.catg_id AND per.iper_id = devolucoes.iper_id) AS arr
	GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14
UNION
	SELECT
		'FATURAMENTO' AS "TIPO",
		faturamento.uneg_id AS "COD UNIDADE",
		faturamento.unidade AS "UNIDADE",
		faturamento.localidade AS "LOCALIDADE",
		faturamento.sec AS "SETOR",
		faturamento.rota AS "ROTA",
		faturamento.municipio AS "MUNICIPIO",
		faturamento.zona AS "ZONA",
		faturamento.referencia AS "REFERENCIA",
		faturamento.categoria AS "CATEGORIA",
		faturamento.perfil AS "PERFIL",
		'CONTA' AS "TIPO DOCUMENTO",
		'CONTA' AS "DOC AGREGADOR",
		NULL AS "DATA PAG",
		0 AS "VALOR PAG",
		0 AS "VALOR DEV",
		0 AS "VALOR ARR",
		0 AS "VALOR PB+VA",
		0 AS "VALOR S PB+VA",
		TO_CHAR(faturamento.valor_faturado, 'L999G999G990D00') AS "VL FATURADO",
		(CASE 
		WHEN (faturamento.perfil = '6-VIVA AGUA' OR faturamento.categoria='PUBLICO') THEN faturamento.valor_faturado
		ELSE 0
		END) AS "FATURADO PB+VA",
		(CASE 
		WHEN (faturamento.perfil <> '6-VIVA AGUA' AND faturamento.categoria<>'PUBLICO') THEN faturamento.valor_faturado
		ELSE 0
		END) AS "FATURADO S PB+VA"
	FROM
		(SELECT 
			fat.cod_unidade AS uneg_id,
			fat.unidade AS unidade,
			fat.localidade AS localidade,
			fat.sec AS sec,
			fat.rota AS rota,
			fat.referencia AS referencia,
			fat.perfil AS perfil,
			fat.categoria AS categoria,
			fat.muni AS municipio,
			fat.dist AS zona,
			fat.cnta_dtemissao AS dtemissao,
			SUM(COALESCE(fat.valor_faturado,0)) AS valor_faturado
		FROM
		(	
			SELECT 
				une.uneg_id AS cod_unidade,
				une.uneg_nmunidadenegocio AS unidade,
				loc.loca_nmlocalidade AS localidade,
				sec.stcm_cdsetorcomercial AS sec,
				rot.rota_cdrota AS rota,
				con4.cnta_amreferenciaconta AS referencia,
				ipe.iper_id::TEXT || '-'||ipe.iper_dsimovelperfil AS perfil,
				cat.catg_dscategoria AS categoria,
				mun.muni_nmmunicipio AS muni,
				dis.diop_dsdistritooperacional AS dist,
				con4.cnta_dtemissao AS cnta_dtemissao,
				SUM(con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos) AS valor_faturado
			FROM faturamento.conta con4 
				INNER JOIN faturamento.conta_impressao cni ON cni.cnta_id = con4.cnta_id
				INNER JOIN cadastro.localidade loc ON loc.loca_id = con4.loca_id
				INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
				INNER JOIN cadastro.imovel imo ON imo.imov_id = con4.imov_id
				INNER JOIN cadastro.setor_comercial sec ON imo.stcm_id = sec.stcm_id
				INNER JOIN cadastro.quadra qdr ON qdr.qdra_id = imo.qdra_id
				INNER JOIN micromedicao.rota rot ON rot.rota_id = qdr.rota_id
				LEFT JOIN operacional.distrito_operacional dis ON dis.diop_id = qdr.diop_id --AND dis.diop_id IN (5,6,7)
				LEFT JOIN cadastro.imovel_perfil ipe ON ipe.iper_id = con4.iper_id
				LEFT JOIN cadastro.categoria cat ON cat.catg_id = imo.imov_idcategoriaprincipal
				LEFT JOIN cadastro.municipio mun ON mun.muni_id = loc.muni_idprincipal
			WHERE
				con4.cnta_amreferenciaconta >= TO_CHAR((CURRENT_DATE - INTERVAL '6Months'),'yyyyMM')::INTEGER
				AND con4.dcst_idatual <> 9
			GROUP BY 1,2,3,4,5,6,7,8,9,10,11
			UNION
			SELECT 
				une.uneg_id AS cod_unidade,
				une.uneg_nmunidadenegocio AS unidade,
				loc.loca_nmlocalidade AS localidade,
				sec.stcm_cdsetorcomercial AS sec,
				rot.rota_cdrota AS rota,
				con4.cnhi_amreferenciaconta AS referencia,
				ipe.iper_id::TEXT || '-'||ipe.iper_dsimovelperfil AS perfil,
				cat.catg_dscategoria AS categoria,
				mun.muni_nmmunicipio AS muni,
				dis.diop_dsdistritooperacional AS dist,
				con4.cnhi_dtemissao AS cnta_dtemissao,
				SUM(con4.cnhi_vlagua+con4.cnhi_vlesgoto+con4.cnhi_vldebitos-con4.cnhi_vlcreditos-con4.cnhi_vlimpostos) AS valor_faturado
			FROM faturamento.conta_historico con4 
				INNER JOIN faturamento.conta_impressao cni ON cni.cnta_id = con4.cnta_id
				INNER JOIN cadastro.localidade loc ON loc.loca_id = con4.loca_id
				INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
				INNER JOIN cadastro.imovel imo ON imo.imov_id = con4.imov_id
				INNER JOIN cadastro.setor_comercial sec ON imo.stcm_id = sec.stcm_id
				INNER JOIN cadastro.quadra qdr ON qdr.qdra_id = imo.qdra_id
				INNER JOIN micromedicao.rota rot ON rot.rota_id = qdr.rota_id
				LEFT JOIN operacional.distrito_operacional dis ON dis.diop_id = qdr.diop_id --AND dis.diop_id IN (5,6,7)
				LEFT JOIN cadastro.imovel_perfil ipe ON ipe.iper_id = con4.iper_id
				LEFT JOIN cadastro.categoria cat ON cat.catg_id = imo.imov_idcategoriaprincipal
				LEFT JOIN cadastro.municipio mun ON mun.muni_id = loc.muni_idprincipal
			WHERE
				con4.cnhi_amreferenciaconta >= TO_CHAR((CURRENT_DATE - INTERVAL '6Months'),'yyyyMM')::INTEGER
				AND con4.dcst_idatual <> 9
			GROUP BY 1,2,3,4,5,6,7,8,9,10,11
		) AS fat
		GROUP BY 1,2,3,4,5,6,7,8,9,10,11) AS faturamento
