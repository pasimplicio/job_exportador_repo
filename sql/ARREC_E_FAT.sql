	SELECT
		'ARRECADACAO' AS "TIPO",
		arr.uneg_id AS "COD UNIDADE",
		arr.nome_unidade AS "UNIDADE",
		arr.localidade_id AS "ID LOCALIDADE",
		arr.localidade AS "LOCALIDADE",
		arr.municipio AS "MUNICIPIO",
		arr.cdibge AS "COD IBGE",
		arr.zona AS "ZONA",
		arr.referencia AS "REFERENCIA",
		arr.categoria AS "CATEGORIA",
		arr.perfil AS "PERFIL",
		arr.tipodoc AS "TIPO DOCUMENTO",
		arr.banco AS "BANCO",
		arr.arrec_forma AS "FORMA DE ARRECADACAO",
		arr.doc_agg AS "DOC AGREGADOR",
		TO_CHAR(arr.data_pag, 'DD/MM/YYYY') AS "DATA PAG/VENC",
		TO_CHAR(arr.data_arrec, 'DD/MM/YYYY') AS "DATA ARREC/FAT",
		'' AS "DATA FAT",
		TO_CHAR(SUM(arr.qt_pagamentos), '999G999G990') AS "QTD PAGAMENTOS",
		TO_CHAR(SUM(arr.qt_documentos), '999G999G990') AS "QTD DOCUMENTOS PAGOS",
		TO_CHAR(SUM(arr.valor), 'L999G999G990D00') AS "VALOR PAG",
		TO_CHAR(SUM(arr.qt_devolucoes), '999G999G990') AS "QTD DEVOLUCOES",
		TO_CHAR(SUM(arr.qt_documentos_dev), '999G999G990') AS "QTD DOCUMENTOS DEVOLVIDOS",
		TO_CHAR(SUM(arr.valor_dev), 'L999G999G990D00') AS "VALOR DEV",
		TO_CHAR(SUM(arr.valor-arr.valor_dev), 'L999G999G990D00') AS "VALOR ARR",
		TO_CHAR((CASE 
		WHEN (arr.perfil = '6-VIVA AGUA' OR arr.categoria='PUBLICO') THEN SUM(arr.valor-arr.valor_dev)
		ELSE 0
		END), 'L999G999G990D00') AS "VALOR PB+VA",
		TO_CHAR((CASE 
		WHEN (arr.perfil <> '6-VIVA AGUA' AND arr.categoria<>'PUBLICO') THEN SUM(arr.valor-arr.valor_dev)
		ELSE 0
		END), 'L999G999G990D00') AS "VALOR S PB+VA",
		TO_CHAR(0, '999G999G990') AS "QTD CONTAS FATURADAS",
		TO_CHAR(0, 'L999G999G990D00') AS "VL FATURADO",
		TO_CHAR(0, 'L999G999G990D00') AS "FATURADO PB+VA",
		TO_CHAR(0, 'L999G999G990D00') AS "FATURADO S PB+VA"
	FROM
	(SELECT
		une.uneg_id AS uneg_id,
		une.uneg_nmunidadenegocio AS nome_unidade,
		arrecadacao.localidade_id AS localidade_id,
		arrecadacao.loca AS localidade,
		arrecadacao.muni AS municipio,
		arrecadacao.cdibge AS cdibge,
		arrecadacao.dist AS zona,
		arrecadacao.referencia AS referencia,
		cat.catg_dscategoria AS categoria,
		per.iper_id::TEXT || '-'||per.iper_dsimovelperfil AS perfil,
		arrecadacao.doc_tipo AS tipodoc,
		arrecadacao.banco AS banco,
		arrecadacao.arrec_forma AS arrec_forma,
		arrecadacao.doc_agg AS doc_agg,
		arrecadacao.data_pag AS data_pag,
		arrecadacao.data_arrec AS data_arrec,
		arrecadacao.qt_pagamentos AS qt_pagamentos,
		arrecadacao.qt_documentos AS qt_documentos,
		arrecadacao.valor AS valor,
		0 AS qt_devolucoes,
		0 AS qt_documentos_dev,
		0 AS valor_dev
	FROM
		cadastro.unidade_negocio une
		CROSS JOIN cadastro.categoria cat
		CROSS JOIN cadastro.imovel_perfil per
		LEFT JOIN 
		(
			SELECT
				res.uneg_id AS uneg_id,
				loc.loca_id AS localidade_id,
				loc.loca_nmlocalidade AS loca,
				mun.muni_nmmunicipio AS muni,
				mun.muni_cdibge AS cdibge,
				dis.diop_dsdistritooperacional AS dist,
				res.ardd_dtpagamento AS data_pag,
				CASE 
					WHEN EXTRACT(YEAR FROM res.ardd_dtpagamento) * 100 + EXTRACT(MONTH FROM res.ardd_dtpagamento) = res.ardd_amreferenciaarrecadacao THEN res.ardd_dtpagamento
					ELSE TO_DATE(CAST(res.ardd_amreferenciaarrecadacao AS VARCHAR) || '01', 'YYYYMMDD')
				END AS data_arrec,
				res.ardd_amreferenciaarrecadacao AS referencia,
				dot.dotp_dsdocumentotipo AS doc_tipo,
				doag.dotp_dsdocumentotipo AS doc_agg,
				res.catg_id AS catg_id,
				res.iper_id AS iper_id,
				cliban.clie_nmcliente AS banco,
				arf.arfm_dsarrecadacaoforma AS arrec_forma,
				res.ardd_qtpagamentos AS qt_pagamentos,
				res.ardd_qtdocumentos AS qt_documentos,
				SUM(res.ardd_vlpagamentos) AS valor
			FROM
				arrecadacao.arrec_dados_diarios res
				LEFT JOIN cadastro.quadra qdr ON qdr.qdra_id = res.qdra_id
				LEFT JOIN operacional.distrito_operacional dis ON dis.diop_id = qdr.diop_id-- AND dis.diop_id IN (5,6,7)
				LEFT JOIN cadastro.localidade loc ON loc.loca_id = res.loca_id
				LEFT JOIN cobranca.documento_tipo dot ON dot.dotp_id = res.dotp_id
				LEFT JOIN cobranca.documento_tipo doag ON doag.dotp_id = res.dotp_idagregador
				LEFT JOIN cadastro.municipio mun ON mun.muni_id = loc.muni_idprincipal
				LEFT JOIN arrecadacao.arrecadador ban ON ban.arrc_id = res.arrc_id
				LEFT JOIN cadastro.cliente cliban ON cliban.clie_id = ban.clie_id
				LEFT JOIN arrecadacao.arrecadacao_forma arf ON arf.arfm_id = res. arfm_id
			WHERE
				res.ardd_amreferenciaarrecadacao >= 202301
			GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17
		) AS arrecadacao ON une.uneg_id = arrecadacao.uneg_id AND cat.catg_id = arrecadacao.catg_id AND per.iper_id = arrecadacao.iper_id
	UNION
	SELECT
		une.uneg_id AS uneg_id,
		une.uneg_nmunidadenegocio AS nome_unidade,
		devolucoes.localidade_id AS localidade_id,
		devolucoes.loca AS localidade,
		devolucoes.muni AS municipio,
		devolucoes.cdibge AS cdibge,
		devolucoes.dist AS zona,
		devolucoes.referencia AS referencia,
		cat.catg_dscategoria AS categoria,
		per.iper_id::TEXT || '-'||per.iper_dsimovelperfil AS perfil,
		devolucoes.doc_tipo AS tipodoc,
		devolucoes.banco AS banco,
		devolucoes.arrec_forma AS arrec_forma,
		devolucoes.doc_agg AS doc_agg,
		devolucoes.data_pag AS data_pag,
		devolucoes.data_arrec AS data_arrec,
		0 AS qt_pagamentos,
		0 AS qt_documentos,
		0 AS valor,
		devolucoes.qt_devolucoes AS qt_devolucoes,
		devolucoes.qt_documentos_dev AS qt_documentos_dev,
		devolucoes.valor AS valor_dev
	FROM
		cadastro.unidade_negocio une
		CROSS JOIN cadastro.categoria cat
		CROSS JOIN cadastro.imovel_perfil per
		LEFT JOIN 
		(
			SELECT
				dev.uneg_id AS uneg_id,
				loc.loca_id AS localidade_id,
				loc.loca_nmlocalidade AS loca,
				mun.muni_nmmunicipio AS muni,
				mun.muni_cdibge AS cdibge,
				dis.diop_dsdistritooperacional AS dist,			
				dev.dvdd_dtdevolucao AS data_pag,
				CASE 
					WHEN EXTRACT(YEAR FROM dev.dvdd_dtdevolucao) * 100 + EXTRACT(MONTH FROM dev.dvdd_dtdevolucao) = dev.dvdd_amreferenciaarrecadacao THEN dev.dvdd_dtdevolucao
					ELSE TO_DATE(CAST(dev.dvdd_amreferenciaarrecadacao AS VARCHAR) || '01', 'YYYYMMDD')
				END AS data_arrec,
				dev.dvdd_amreferenciaarrecadacao AS referencia,
				dot.dotp_dsdocumentotipo AS doc_tipo,
				doag.dotp_dsdocumentotipo AS doc_agg,
				dev.catg_id AS catg_id,
				dev.iper_id AS iper_id,
				cliban.clie_nmcliente AS banco,
				arf.arfm_dsarrecadacaoforma AS arrec_forma,
				dev.dvdd_qtdevolucoes AS qt_devolucoes,
				dev.dvdd_qtdocumentos AS qt_documentos_dev,
				SUM(dev.dvdd_vldevolucoes) AS valor
			FROM
				arrecadacao.devolucao_dados_diarios dev
				LEFT JOIN cadastro.quadra qdr ON qdr.qdra_id = dev.qdra_id
				LEFT JOIN operacional.distrito_operacional dis ON dis.diop_id = qdr.diop_id --AND dis.diop_id IN (5,6,7)
				LEFT JOIN cadastro.localidade loc ON loc.loca_id = dev.loca_id
				LEFT JOIN cobranca.documento_tipo dot ON dot.dotp_id = dev.dotp_id
				LEFT JOIN cobranca.documento_tipo doag ON doag.dotp_id = dev.dotp_idagregador
				LEFT JOIN cadastro.municipio mun ON mun.muni_id = loc.muni_idprincipal
				LEFT JOIN arrecadacao.arrecadador ban ON ban.arrc_id = dev.arrc_id
				LEFT JOIN cadastro.cliente cliban ON cliban.clie_id = ban.clie_id
				LEFT JOIN arrecadacao.arrecadacao_forma arf ON arf.arfm_id = dev.arfm_id
			WHERE
				dev.dvdd_amreferenciaarrecadacao >= 202301
			GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17
		) AS devolucoes ON une.uneg_id = devolucoes.uneg_id AND cat.catg_id = devolucoes.catg_id AND per.iper_id = devolucoes.iper_id) AS arr
	GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,12,13,14,15,16,17
UNION
	SELECT
		'FATURAMENTO' AS "TIPO",
		faturamento.uneg_id AS "COD UNIDADE",
		faturamento.unidade AS "UNIDADE",
		faturamento.localidade_id AS "ID LOCALIDADE",
		faturamento.localidade AS "LOCALIDADE",
		faturamento.municipio AS "MUNICIPIO",
		faturamento.cdibge AS "COD IBGE",
		faturamento.zona AS "ZONA",
		faturamento.referencia AS "REFERENCIA",
		faturamento.categoria AS "CATEGORIA",
		faturamento.perfil AS "PERFIL",
		'CONTA' AS "TIPO DOCUMENTO",
		'CONTA' AS "DOC AGREGADOR",
		'' AS "BANCO",
		'' AS "FORMA DE ARRECADACAO",
		TO_CHAR(faturamento.dtvencimentooriginal,'DD/MM/YYYY') AS "DATA PAG/VENC",
		TO_CHAR(faturamento.datafatref,'DD/MM/YYYY') AS "DATA ARREC/FAT",
		TO_CHAR(faturamento.dtemissao,'DD/MM/YYYY') AS "DATA FAT",
		TO_CHAR(0, '999G999G990') AS "QTD PAGAMENTOS",
		TO_CHAR(0, '999G999G990') AS "QTD DOCUMENTOS PAGOS",
		TO_CHAR(0, 'L999G999G990D00') AS "VALOR PAG",
		TO_CHAR(0, '999G999G990') AS "QTD DEVOLUCOES",
		TO_CHAR(0, '999G999G990') AS "QTD DOCUMENTOS DEVOLVIDOS",
		TO_CHAR(0, 'L999G999G990D00') AS "VALOR DEV",
		TO_CHAR(0, 'L999G999G990D00') AS "VALOR ARR",
		TO_CHAR(0, 'L999G999G990D00') AS "VALOR PB+VA",
		TO_CHAR(0, 'L999G999G990D00') AS "VALOR S PB+VA",
		TO_CHAR(faturamento.qt_contas, '999G999G990') AS "QTD CONTAS FATURADAS",
		TO_CHAR(faturamento.valor_faturado, 'L999G999G990D00') AS "VL FATURADO",
		TO_CHAR((CASE 
		WHEN (faturamento.perfil = '6-VIVA AGUA' OR faturamento.categoria='PUBLICO') THEN faturamento.valor_faturado
		ELSE 0
		END), 'L999G999G990D00') AS "FATURADO PB+VA",
		TO_CHAR((CASE 
		WHEN (faturamento.perfil <> '6-VIVA AGUA' AND faturamento.categoria<>'PUBLICO') THEN faturamento.valor_faturado
		ELSE 0
		END), 'L999G999G990D00') AS "FATURADO S PB+VA"
	FROM
		(SELECT 
			fat.cod_unidade AS uneg_id,
			fat.unidade AS unidade,
			fat.localidade_id AS localidade_id,	
			fat.localidade AS localidade,
			fat.referencia AS referencia,
			fat.perfil AS perfil,
			fat.categoria AS categoria,
			fat.muni AS municipio,
			fat.cdibge AS cdibge,
			fat.dist AS zona,
			fat.cnta_dtvencimentooriginal AS dtvencimentooriginal,
			fat.cnta_dtemissao AS dtemissao,
			fat.data_fatref AS datafatref,
			SUM(fat.qtd_contas) AS qt_contas,
			SUM(COALESCE(fat.valor_faturado,0)) AS valor_faturado
		FROM
		(	
			SELECT 
				une.uneg_id AS cod_unidade,
				une.uneg_nmunidadenegocio AS unidade,
				loc.loca_id AS localidade_id,
				loc.loca_nmlocalidade AS localidade,
				con4.cnta_amreferenciaconta AS referencia,
				ipe.iper_id::TEXT || '-'||ipe.iper_dsimovelperfil AS perfil,
				cat.catg_dscategoria AS categoria,
				mun.muni_nmmunicipio AS muni,
				mun.muni_cdibge AS cdibge,
				dis.diop_dsdistritooperacional AS dist,
				con4.cnta_dtvencimentooriginal AS cnta_dtvencimentooriginal,
				con4.cnta_dtemissao AS cnta_dtemissao,
				CASE 
					WHEN EXTRACT(YEAR FROM con4.cnta_dtemissao) * 100 + EXTRACT(MONTH FROM con4.cnta_dtemissao) = con4.cnta_amreferenciaconta THEN con4.cnta_dtemissao
					ELSE TO_DATE(CAST(con4.cnta_amreferenciaconta AS VARCHAR) || '01', 'YYYYMMDD')
				END AS data_fatref,
				COUNT(con4.cnta_id) AS qtd_contas,
				SUM(con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos) AS valor_faturado
			FROM faturamento.conta con4 
				INNER JOIN faturamento.conta_impressao cni ON cni.cnta_id = con4.cnta_id
				INNER JOIN cadastro.localidade loc ON loc.loca_id = con4.loca_id
				INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
				INNER JOIN cadastro.imovel imo ON imo.imov_id = con4.imov_id
				INNER JOIN cadastro.quadra qdr ON qdr.qdra_id = imo.qdra_id
				LEFT JOIN operacional.distrito_operacional dis ON dis.diop_id = qdr.diop_id --AND dis.diop_id IN (5,6,7)
				LEFT JOIN cadastro.imovel_perfil ipe ON ipe.iper_id = con4.iper_id
				LEFT JOIN cadastro.categoria cat ON cat.catg_id = imo.imov_idcategoriaprincipal
				LEFT JOIN cadastro.municipio mun ON mun.muni_id = loc.muni_idprincipal
			WHERE
				con4.cnta_amreferenciaconta >= 202301
				AND con4.dcst_idatual <> 9
			GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13
			UNION
			SELECT 
				une.uneg_id AS cod_unidade,
				une.uneg_nmunidadenegocio AS unidade,
				loc.loca_id AS localidade_id,
				loc.loca_nmlocalidade AS localidade,
				con4.cnhi_amreferenciaconta AS referencia,
				ipe.iper_id::TEXT || '-'||ipe.iper_dsimovelperfil AS perfil,
				cat.catg_dscategoria AS categoria,
				mun.muni_nmmunicipio AS muni,
				mun.muni_cdibge AS cdibge,
				dis.diop_dsdistritooperacional AS dist,
				con4.cnhi_dtvencimentooriginal AS cnta_dtvencimentooriginal,
				con4.cnhi_dtemissao AS cnta_dtemissao,
				CASE 
					WHEN EXTRACT(YEAR FROM con4.cnhi_dtemissao) * 100 + EXTRACT(MONTH FROM con4.cnhi_dtemissao) = con4.cnhi_amreferenciaconta THEN con4.cnhi_dtemissao
					ELSE TO_DATE(CAST(con4.cnhi_amreferenciaconta AS VARCHAR) || '01', 'YYYYMMDD')
				END AS data_fatref,				
				COUNT(con4.cnta_id) AS qtd_contas,
				SUM(con4.cnhi_vlagua+con4.cnhi_vlesgoto+con4.cnhi_vldebitos-con4.cnhi_vlcreditos-con4.cnhi_vlimpostos) AS valor_faturado
			FROM faturamento.conta_historico con4 
				INNER JOIN faturamento.conta_impressao cni ON cni.cnta_id = con4.cnta_id
				INNER JOIN cadastro.localidade loc ON loc.loca_id = con4.loca_id
				INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
				INNER JOIN cadastro.imovel imo ON imo.imov_id = con4.imov_id
				INNER JOIN cadastro.quadra qdr ON qdr.qdra_id = imo.qdra_id
				LEFT JOIN operacional.distrito_operacional dis ON dis.diop_id = qdr.diop_id --AND dis.diop_id IN (5,6,7)
				LEFT JOIN cadastro.imovel_perfil ipe ON ipe.iper_id = con4.iper_id
				LEFT JOIN cadastro.categoria cat ON cat.catg_id = imo.imov_idcategoriaprincipal
				LEFT JOIN cadastro.municipio mun ON mun.muni_id = loc.muni_idprincipal
			WHERE
				con4.cnhi_amreferenciaconta >= 202301
				AND con4.dcst_idatual <> 9
			GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13
			UNION
			SELECT 
				une.uneg_id AS cod_unidade,
				une.uneg_nmunidadenegocio AS unidade,
				loc.loca_id AS localidade_id,
				loc.loca_nmlocalidade AS localidade,
				con4.cnta_amreferenciaconta AS referencia,
				ipe.iper_id::TEXT || '-'||ipe.iper_dsimovelperfil AS perfil,
				cat.catg_dscategoria AS categoria,
				mun.muni_nmmunicipio AS muni,
				mun.muni_cdibge AS cdibge,
				dis.diop_dsdistritooperacional AS dist,
				con4.cnta_dtvencimentooriginal AS cnta_dtvencimentooriginal,
				con4.cnta_dtemissao AS cnta_dtemissao,
				CASE 
					WHEN EXTRACT(YEAR FROM con4.cnta_dtemissao) * 100 + EXTRACT(MONTH FROM con4.cnta_dtemissao) = con4.cnta_amreferenciaconta THEN con4.cnta_dtemissao
					ELSE TO_DATE(CAST(con4.cnta_amreferenciaconta AS VARCHAR) || '01', 'YYYYMMDD')
				END AS data_fatref,
				COUNT(con4.cnta_id) AS qtd_contas,
				SUM(con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos) AS valor_faturado
			FROM faturamento.conta con4 
				INNER JOIN faturamento.mov_conta_prefaturada cni ON cni.cnta_id = con4.cnta_id
				INNER JOIN cadastro.localidade loc ON loc.loca_id = con4.loca_id
				INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
				INNER JOIN cadastro.imovel imo ON imo.imov_id = con4.imov_id
				INNER JOIN cadastro.quadra qdr ON qdr.qdra_id = imo.qdra_id
				LEFT JOIN operacional.distrito_operacional dis ON dis.diop_id = qdr.diop_id --AND dis.diop_id IN (5,6,7)
				LEFT JOIN cadastro.imovel_perfil ipe ON ipe.iper_id = con4.iper_id
				LEFT JOIN cadastro.categoria cat ON cat.catg_id = imo.imov_idcategoriaprincipal
				LEFT JOIN cadastro.municipio mun ON mun.muni_id = loc.muni_idprincipal
			WHERE
				con4.cnta_amreferenciaconta >= 202301
				AND con4.dcst_idatual <> 9
			GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13
			UNION
			SELECT 
				une.uneg_id AS cod_unidade,
				une.uneg_nmunidadenegocio AS unidade,
				loc.loca_id AS localidade_id,
				loc.loca_nmlocalidade AS localidade,
				con4.cnhi_amreferenciaconta AS referencia,
				ipe.iper_id::TEXT || '-'||ipe.iper_dsimovelperfil AS perfil,
				cat.catg_dscategoria AS categoria,
				mun.muni_nmmunicipio AS muni,
				mun.muni_cdibge AS cdibge,
				dis.diop_dsdistritooperacional AS dist,
				con4.cnhi_dtvencimentooriginal AS cnta_dtvencimentooriginal,
				con4.cnhi_dtemissao AS cnta_dtemissao,
				CASE 
					WHEN EXTRACT(YEAR FROM con4.cnhi_dtemissao) * 100 + EXTRACT(MONTH FROM con4.cnhi_dtemissao) = con4.cnhi_amreferenciaconta THEN con4.cnhi_dtemissao
					ELSE TO_DATE(CAST(con4.cnhi_amreferenciaconta AS VARCHAR) || '01', 'YYYYMMDD')
				END AS data_fatref,
				COUNT(con4.cnta_id) AS qtd_contas,
				SUM(con4.cnhi_vlagua+con4.cnhi_vlesgoto+con4.cnhi_vldebitos-con4.cnhi_vlcreditos-con4.cnhi_vlimpostos) AS valor_faturado
			FROM faturamento.conta_historico con4 
				INNER JOIN faturamento.mov_conta_prefaturada cni ON cni.cnta_id = con4.cnta_id
				INNER JOIN cadastro.localidade loc ON loc.loca_id = con4.loca_id
				INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
				INNER JOIN cadastro.imovel imo ON imo.imov_id = con4.imov_id
				INNER JOIN cadastro.quadra qdr ON qdr.qdra_id = imo.qdra_id
				LEFT JOIN operacional.distrito_operacional dis ON dis.diop_id = qdr.diop_id --AND dis.diop_id IN (5,6,7)
				LEFT JOIN cadastro.imovel_perfil ipe ON ipe.iper_id = con4.iper_id
				LEFT JOIN cadastro.categoria cat ON cat.catg_id = imo.imov_idcategoriaprincipal
				LEFT JOIN cadastro.municipio mun ON mun.muni_id = loc.muni_idprincipal
			WHERE
				con4.cnhi_amreferenciaconta >= 202301
				AND con4.dcst_idatual <> 9
			GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13
		) AS fat
		GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13) AS faturamento