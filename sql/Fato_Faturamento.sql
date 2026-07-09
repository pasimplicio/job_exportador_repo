
-- trocar a referencia 202402

SELECT 
	imo.imov_id AS "MATRICULA",
	con_ult_fat.referencia AS "REFERENCIA",
	con_ult_fat.dt_faturamento AS "DATA FATURAMENTO",
	con_ult_fat.cagua AS "VOLUME AGUA",
	TO_CHAR(con_ult_fat.vl_agua, '999G999G990D00') AS "VALOR AGUA",
	con_ult_fat.cesg AS "VOLUME ESGOTO",
	TO_CHAR(con_ult_fat.vl_esgoto, '999G999G990D00') AS "VALOR ESGOTO",
	TO_CHAR(con_ult_fat.vl_debitos, '999G999G990D00') AS "OUTROS SERVICOS",
	TO_CHAR(con_ult_fat.vl_creditos, '999G999G990D00') AS "CREDITOS",
	TO_CHAR(con_ult_fat.vl_impostos, '999G999G990D00') AS "IMPOSTOS",
	TO_CHAR(con_ult_fat.valor, '999G999G990D00') AS "VALOR"
FROM 
	cadastro.imovel imo
	LEFT JOIN (	SELECT 
				con4.imov_id AS mat1,
				con4.cnta_amreferenciaconta AS referencia,
				con4.cnta_dtemissao AS dt_faturamento,
				con4.cnta_nnconsumoagua AS cagua,
				con4.cnta_vlagua AS vl_agua,
				con4.cnta_nnconsumoesgoto AS cesg,
				con4.cnta_vlesgoto AS vl_esgoto,
				con4.cnta_vldebitos AS vl_debitos,
				con4.cnta_vlcreditos AS vl_creditos,
				con4.cnta_vlimpostos AS vl_impostos,
				con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos AS valor
			FROM faturamento.conta con4 
				INNER JOIN faturamento.conta_impressao cni ON cni.cnta_id = con4.cnta_id
			WHERE
				con4.cnta_amreferenciaconta >= 202402 
			UNION
			SELECT 
				con4.imov_id AS mat1,
				con4.cnhi_amreferenciaconta AS referencia,
				con4.cnhi_dtemissao AS dt_faturamento,
				con4.cnhi_nnconsumoagua AS cagua,
				con4.cnhi_vlagua AS vl_agua,
				con4.cnhi_nnconsumoesgoto AS cesg,
				con4.cnhi_vlesgoto AS vl_esgoto,
				con4.cnhi_vldebitos AS vl_debitos,
				con4.cnhi_vlcreditos AS vl_creditos,
				con4.cnhi_vlimpostos AS vl_impostos,
				con4.cnhi_vlagua+con4.cnhi_vlesgoto+con4.cnhi_vldebitos-con4.cnhi_vlcreditos-con4.cnhi_vlimpostos AS valor
			FROM faturamento.conta_historico con4 
				INNER JOIN faturamento.conta_impressao cni ON cni.cnta_id = con4.cnta_id
			WHERE
				con4.cnhi_amreferenciaconta >= 202402 
			UNION
			SELECT 
				con4.imov_id AS mat1,
				con4.cnta_amreferenciaconta AS referencia,
				con4.cnta_dtemissao AS dt_faturamento,
				con4.cnta_nnconsumoagua AS cagua,
				con4.cnta_vlagua AS vl_agua,
				con4.cnta_nnconsumoesgoto AS cesg,
				con4.cnta_vlesgoto AS vl_esgoto,
				con4.cnta_vldebitos AS vl_debitos,
				con4.cnta_vlcreditos AS vl_creditos,
				con4.cnta_vlimpostos AS vl_impostos,
				con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos AS valor
			FROM faturamento.conta con4 
				INNER JOIN faturamento.mov_conta_prefaturada cni ON cni.cnta_id = con4.cnta_id
			WHERE
				con4.cnta_amreferenciaconta >= 202402 
			UNION
			SELECT 
				con4.imov_id AS mat1,
				con4.cnhi_amreferenciaconta AS referencia,
				con4.cnhi_dtemissao AS dt_faturamento,
				con4.cnhi_nnconsumoagua AS cagua,
				con4.cnhi_vlagua AS vl_agua,
				con4.cnhi_nnconsumoesgoto AS cesg,
				con4.cnhi_vlesgoto AS vl_esgoto,
				con4.cnhi_vldebitos AS vl_debitos,
				con4.cnhi_vlcreditos AS vl_creditos,
				con4.cnhi_vlimpostos AS vl_impostos,
				con4.cnhi_vlagua+con4.cnhi_vlesgoto+con4.cnhi_vldebitos-con4.cnhi_vlcreditos-con4.cnhi_vlimpostos AS valor
			FROM faturamento.conta_historico con4 
				INNER JOIN faturamento.mov_conta_prefaturada cni ON cni.cnta_id = con4.cnta_id
			WHERE
				con4.cnhi_amreferenciaconta >= 202402 
			) AS con_ult_fat ON con_ult_fat.mat1 = imo.imov_id
WHERE
	imo.imov_icexclusao = 2
	--AND imo.imov_id = 32948
	AND con_ult_fat.valor IS NOT NULL

ORDER BY
	"REFERENCIA"