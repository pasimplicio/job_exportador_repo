WITH
-- =========================
-- BASE DE ARRECADAÇÃO
-- =========================
arrec_base AS (
	SELECT
		loc.loca_id AS localidade_id,
		CASE 
			WHEN EXTRACT(YEAR FROM res.ardd_dtpagamento) * 100 + EXTRACT(MONTH FROM res.ardd_dtpagamento) = res.ardd_amreferenciaarrecadacao 
				THEN res.ardd_dtpagamento
			ELSE TO_DATE(CAST(res.ardd_amreferenciaarrecadacao AS VARCHAR) || '01', 'YYYYMMDD')
		END AS data_arrec,
		res.ardd_amreferenciaarrecadacao AS referencia,
		res.catg_id,
		res.iper_id,
		cliban.clie_nmcliente AS banco,
		arf.arfm_dsarrecadacaoforma AS arrec_forma,
		res.ardd_qtdocumentos AS qt_documentos,
		SUM(res.ardd_vlpagamentos) AS valor
	FROM arrecadacao.arrec_dados_diarios res
		LEFT JOIN cadastro.quadra qdr ON qdr.qdra_id = res.qdra_id
		LEFT JOIN operacional.distrito_operacional dis ON dis.diop_id = qdr.diop_id
		LEFT JOIN cadastro.localidade loc ON loc.loca_id = res.loca_id
		LEFT JOIN cobranca.documento_tipo dot ON dot.dotp_id = res.dotp_id
		LEFT JOIN cobranca.documento_tipo doag ON doag.dotp_id = res.dotp_idagregador
		LEFT JOIN cadastro.municipio mun ON mun.muni_id = loc.muni_idprincipal
		LEFT JOIN arrecadacao.arrecadador ban ON ban.arrc_id = res.arrc_id
		LEFT JOIN cadastro.cliente cliban ON cliban.clie_id = ban.clie_id
		LEFT JOIN arrecadacao.arrecadacao_forma arf ON arf.arfm_id = res.arfm_id
	WHERE res.ardd_amreferenciaarrecadacao >= 202601
	GROUP BY 1,2,3,4,5,6,7,8
),

-- =========================
-- BASE DE DEVOLUÇÃO
-- =========================
devol_base AS (
	SELECT
		loc.loca_id AS localidade_id,
		CASE 
			WHEN EXTRACT(YEAR FROM dev.dvdd_dtdevolucao) * 100 + EXTRACT(MONTH FROM dev.dvdd_dtdevolucao) = dev.dvdd_amreferenciaarrecadacao 
				THEN dev.dvdd_dtdevolucao
			ELSE TO_DATE(CAST(dev.dvdd_amreferenciaarrecadacao AS VARCHAR) || '01', 'YYYYMMDD')
		END AS data_arrec,
		dev.dvdd_amreferenciaarrecadacao AS referencia,
		dev.catg_id,
		dev.iper_id,
		cliban.clie_nmcliente AS banco,
		arf.arfm_dsarrecadacaoforma AS arrec_forma,
		SUM(dev.dvdd_vldevolucoes) AS valor
	FROM arrecadacao.devolucao_dados_diarios dev
		LEFT JOIN cadastro.quadra qdr ON qdr.qdra_id = dev.qdra_id
		LEFT JOIN operacional.distrito_operacional dis ON dis.diop_id = qdr.diop_id
		LEFT JOIN cadastro.localidade loc ON loc.loca_id = dev.loca_id
		LEFT JOIN cobranca.documento_tipo dot ON dot.dotp_id = dev.dotp_id
		LEFT JOIN cobranca.documento_tipo doag ON doag.dotp_id = dev.dotp_idagregador
		LEFT JOIN cadastro.municipio mun ON mun.muni_id = loc.muni_idprincipal
		LEFT JOIN arrecadacao.arrecadador ban ON ban.arrc_id = dev.arrc_id
		LEFT JOIN cadastro.cliente cliban ON cliban.clie_id = ban.clie_id
		LEFT JOIN arrecadacao.arrecadacao_forma arf ON arf.arfm_id = dev.arfm_id
	WHERE dev.dvdd_amreferenciaarrecadacao >= 202601
	GROUP BY 1,2,3,4,5,6,7
),

-- =========================
-- ARRECADAÇÃO + DEVOLUÇÃO
-- =========================
arr AS (
	SELECT
		arrec.localidade_id,
		arrec.referencia,
		cat.catg_dscategoria AS categoria,
		per.iper_id::TEXT || '-'||per.iper_dsimovelperfil AS perfil,
		arrec.banco,
		arrec.arrec_forma,
		arrec.data_arrec,
		arrec.qt_documentos,
		arrec.valor,
		0 AS valor_dev
	FROM arrec_base arrec
	INNER JOIN cadastro.categoria cat ON cat.catg_id = arrec.catg_id
	INNER JOIN cadastro.imovel_perfil per ON per.iper_id = arrec.iper_id

	UNION ALL

	SELECT
		dev.localidade_id,
		dev.referencia,
		cat.catg_dscategoria AS categoria,
		per.iper_id::TEXT || '-'||per.iper_dsimovelperfil AS perfil,
		dev.banco,
		dev.arrec_forma,
		dev.data_arrec,
		0 AS qt_documentos,
		0 AS valor,
		dev.valor AS valor_dev
	FROM devol_base dev
	INNER JOIN cadastro.categoria cat ON cat.catg_id = dev.catg_id
	INNER JOIN cadastro.imovel_perfil per ON per.iper_id = dev.iper_id
)

-- =========================
-- SELECT FINAL (MESMO DA ORIGINAL)
-- =========================
SELECT
	'ARRECADACAO' AS "TIPO",
	arr.localidade_id AS "ID LOCALIDADE",
	arr.referencia AS "REFERENCIA",
	arr.categoria AS "CATEGORIA",
	arr.perfil AS "PERFIL",
	arr.banco AS "BANCO",
	arr.arrec_forma AS "FORMA DE ARRECADACAO",
	TO_CHAR(arr.data_arrec, 'DD/MM/YYYY') AS "DATA ARREC/FAT",
	'' AS "DATA FAT",
	TO_CHAR(SUM(arr.qt_documentos), '999G999G990') AS "QTD DOCUMENTOS PAGOS",
	TO_CHAR(SUM(arr.valor), 'L999G999G990D00') AS "VALOR PAG",
	TO_CHAR(SUM(arr.valor_dev), 'L999G999G990D00') AS "VALOR DEV",
	TO_CHAR(SUM(arr.valor - arr.valor_dev), 'L999G999G990D00') AS "VALOR ARR",
	TO_CHAR(0, 'L999G999G990D00') AS "VL FATURADO"
FROM arr
GROUP BY 1,2,3,4,5,6,7,8