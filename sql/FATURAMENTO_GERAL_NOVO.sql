--202108: Deve ser substituida pela referencia do faturamento que se deseja obter os dados
--VAR_UNIDADE: Deve ser substituida pelo id da unidade de onde se quer obter os dados

SELECT 
	imo.imov_id AS "MATRICULA",
	TO_CHAR(imo.imov_nncoordenadax, '990D009999999999') AS "LATITUDE",
	TO_CHAR(imo.imov_nncoordenaday, '990D009999999999') AS "LONGITUDE",
	cli.clie_nmcliente AS "NOME",
	imo.iper_id AS "PERFIL",
	rat.ratv_dsramoatividade AS "RAMO DE ATIVIDADE",
	(CASE imo.imov_idcategoriaprincipal 
	WHEN 1 THEN '1 - RESIDENCIAL'
	WHEN 2 THEN '2 - COMERCIAL'
	WHEN 3 THEN '3 - INDUSTRIAL'
	WHEN 4 THEN '4 - PUBLICO'
	ELSE 'NAO DEFINIDO'
	END) AS "CATEGORIA PRINCIPAL",
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
	ELSE 'NAO DEFINIDO'
	END) AS "SUBCATEGORIA PRINCIPAL",
	imo.imov_qteconomia AS "ECONOMIAS",
	ftb.ftab_dsfonteabastecimento AS "ABASTECIMENTO",
	loc.uneg_id AS "GERENCIA",
	une.uneg_nmunidadenegocio AS "NOME UNIDADE",
	imo.loca_id AS "LOCALIDADE",
	loc.loca_nmlocalidade AS "NOME LOCALIDADE",
	sec.stcm_cdsetorcomercial AS "SETOR COMERCIAL",
	qdr.qdra_nnquadra AS "QUADRA",
	imo.imov_nnsequencialrota AS "SEQUENCIA",
	imo.imov_nnsublote AS "SUB LOTE",
	rot.rota_cdrota AS "ROTA",
	ftg.ftgr_dsfaturamentogrupo AS "GRUPO FATURAMENTO",
	lgt.lgtp_dslogradourotipo AS "TIPO LOGRADOURO",
	logr.logr_nmlogradouro AS "NOME LOGRADOURO",
	cep.cep_cdcep AS "CEP",
	imo.imov_dscomplementoendereco AS "COMPLEMENTO",
	bai.bair_nmbairro AS "BAIRRO",
	imo.imov_nnimovel AS "NR",
	mun.muni_nmmunicipio AS "MUNICIPIO",
	imo.last_id AS "ID SIT. AGUA",
	las.last_dsligacaoaguasituacao AS "SITUACAO AGUA",
	lagu.lagu_dtimplantacao AS "DT. IMPLANTACAO",
	lagu.lagu_dtcorte AS "DT. CORTE",
	lagu.lagu_dtsupressaoagua AS "DT. SUPRESSAO",
	imo.lest_id AS "ID SIT. ESG",
	les.lest_dsligacaoesgotosituacao AS "SITUACAO ESGOTO",
	imo.imov_nnareaconstruida AS "AREA",
	CAST(fat.ftst_id  AS TEXT) || ' - ' || fat.ftst_dsfaturamentosituacaotipo AS "SIT. FATURAMENTO",
	fsh.ftsh_nnconsumoaguamedido AS "CONS FIX AG MEDIDO",
	fsh.ftsh_nnconsumoaguanaomedido AS "CONS FIX AG NAO MEDIDO",
	fsh.ftsh_nnvolumeesgotomedido AS "VOL FIX ES MEDIDO",
	fsh.ftsh_nnvolumeesgotonaomedido AS "VOL FIX ES NAO MEDIDO",
	fsh.ftsh_amfatmtsitinicio AS "INICIO",
	fsh.ftsh_amfaturamentosituacaofim AS "FIM",
	lagu.lagu_nnconsumominimoagua AS "CONS MIN AGUA",
	lesg.lesg_nnconsumominimoesgoto AS "CONS MIN ESG",
	hid.hidr_nnhidrometro AS "NR HID.",
	his.hidi_dtinstalacaohidrometro AS "DATA DE INSTALACAO HD.",
	con_ult_fat.cagua AS "VOL AG 202108",
	TO_CHAR(con_ult_fat.vl_agua,'99999999990D00') AS "VL AG 202108",
	con_ult_fat.cesg AS "VOL ES 202108",
	TO_CHAR(con_ult_fat.vl_esgoto,'99999999990D00') AS "VL ES 202108",
	TO_CHAR(con_ult_fat.vl_debitos,'99999999990D00') AS "OUTROS SERVICOS 202108",
	TO_CHAR(con_ult_fat.vl_creditos,'99999999990D00') AS "CRED 202108",
	TO_CHAR(con_ult_fat.vl_impostos,'99999999990D00') AS "IMPOSTOS 202108",
	TO_CHAR(con_ult_fat.valor,'99999999990D00') AS "VALOR 202108",
	con_ult_fat.tipo_tarifa AS "TIPO TARIFA",
	con_ult_fat.ecn_res AS "ECN RES",
	con_ult_fat.ecn_com AS "ECN COM",
	con_ult_fat.ecn_ind AS "ECN IND",
	con_ult_fat.ecn_pubm AS "ECN PUB M",
	con_ult_fat.ecn_pube AS "ECN PUB E",
	con_ult_fat.ecn_pubf AS "ECN PUB F",
	con_ult_fat.ecn_resp AS "ECN RES POP",
	con_ult_fat.ecn_comp AS "ECN COM PEQ",
	con_ult_fat.ecn_entf AS "ECN ENT FIL",
	con_ult_fat.ecn_sisn AS "ECN SIST NOP",
	con_ult_fat.ecn_out AS "ECN OUTROS"
FROM 
	cadastro.imovel imo
	INNER JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
	INNER JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id	
	INNER JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id AND loc.greg_id IN (1,2)
	INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
	INNER JOIN cadastro.setor_comercial sec ON imo.stcm_id = sec.stcm_id
	INNER JOIN cadastro.quadra qdr ON qdr.qdra_id = imo.qdra_id
	INNER JOIN micromedicao.rota rot ON rot.rota_id = qdr.rota_id
	INNER JOIN faturamento.faturamento_grupo ftg ON rot.ftgr_id = ftg.ftgr_id
	INNER JOIN cadastro.logradouro_bairro lgb ON lgb.lgbr_id = imo.lgbr_id
	INNER JOIN cadastro.logradouro logr ON lgb.logr_id = logr.logr_id
	INNER JOIN cadastro.bairro bai ON bai.bair_id = lgb.bair_id
	INNER JOIN cadastro.municipio mun ON mun.muni_id = bai.muni_id
	INNER JOIN cadastro.fonte_abastecimento ftb ON ftb.ftab_id = imo.ftab_id
	INNER JOIN atendimentopublico.ligacao_agua_situacao las ON las.last_id = imo.last_id
	INNER JOIN atendimentopublico.ligacao_esgoto_situacao les ON les.lest_id = imo.lest_id
	LEFT JOIN cadastro.imovel_ramo_atividade ira ON ira.imov_id = imo.imov_id
	LEFT JOIN cadastro.ramo_atividade rat ON rat.ratv_id = ira.ratv_id
	LEFT JOIN cadastro.logradouro_cep lgc ON lgc.lgcp_id = imo.lgcp_id
	LEFT JOIN cadastro.cep cep ON cep.cep_id = lgc.cep_id
	LEFT JOIN cadastro.logradouro_tipo lgt ON lgt.lgtp_id = logr.lgtp_id
	LEFT JOIN faturamento.fatur_situacao_hist fsh ON fsh.imov_id = imo.imov_id AND fsh.ftsh_amfaturamentoretirada IS NULL
	LEFT JOIN faturamento.fatur_situacao_tipo fat ON fat.ftst_id = fsh.ftst_id
	LEFT JOIN faturamento.fatur_situacao_motivo ftm ON fsh.ftsm_id = ftm.ftsm_id
	LEFT JOIN atendimentopublico.ligacao_agua lagu ON lagu.lagu_id = imo.imov_id
	LEFT JOIN atendimentopublico.ligacao_esgoto lesg ON lesg.lesg_id = imo.imov_id
	LEFT JOIN micromedicao.hidrometro_inst_hist his ON lagu.hidi_id = his.hidi_id AND his.hidi_dtretiradahidrometro IS NULL
	LEFT JOIN micromedicao.hidrometro hid ON his.hidr_id = hid.hidr_id
	LEFT JOIN (	SELECT 
				con4.imov_id AS mat1,
				con4.cstf_id AS tipo_tarifa,
				cc1.ctcg_qteconomia AS ecn_res,
				cc2.ctcg_qteconomia AS ecn_com,
				cc3.ctcg_qteconomia AS ecn_ind,
				cc4.ctcg_qteconomia AS ecn_pubm,
				cc5.ctcg_qteconomia AS ecn_pube,
				cc6.ctcg_qteconomia AS ecn_pubf,
				cc7.ctcg_qteconomia AS ecn_resp,
				cc8.ctcg_qteconomia AS ecn_comp,
				cc9.ctcg_qteconomia AS ecn_entf,
				cc10.ctcg_qteconomia AS ecn_sisn,
				cc11.ctcg_qteconomia AS ecn_out,
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
				LEFT JOIN faturamento.conta_categoria cc1 ON cc1.cnta_id = con4.cnta_id AND cc1.scat_id = 1
				LEFT JOIN faturamento.conta_categoria cc2 ON cc2.cnta_id = con4.cnta_id AND cc2.scat_id = 2
				LEFT JOIN faturamento.conta_categoria cc3 ON cc3.cnta_id = con4.cnta_id AND cc3.scat_id = 3
				LEFT JOIN faturamento.conta_categoria cc4 ON cc4.cnta_id = con4.cnta_id AND cc4.scat_id = 4
				LEFT JOIN faturamento.conta_categoria cc5 ON cc5.cnta_id = con4.cnta_id AND cc5.scat_id = 5
				LEFT JOIN faturamento.conta_categoria cc6 ON cc6.cnta_id = con4.cnta_id AND cc6.scat_id = 6
				LEFT JOIN faturamento.conta_categoria cc7 ON cc7.cnta_id = con4.cnta_id AND cc7.scat_id = 7
				LEFT JOIN faturamento.conta_categoria cc8 ON cc8.cnta_id = con4.cnta_id AND cc8.scat_id = 8
				LEFT JOIN faturamento.conta_categoria cc9 ON cc9.cnta_id = con4.cnta_id AND cc9.scat_id = 9
				LEFT JOIN faturamento.conta_categoria cc10 ON cc10.cnta_id = con4.cnta_id AND cc10.scat_id = 10
				LEFT JOIN faturamento.conta_categoria cc11 ON cc11.cnta_id = con4.cnta_id AND cc11.scat_id = 11
			WHERE
				con4.cnta_amreferenciaconta = 202108
			UNION
			SELECT 
				con4.imov_id AS mat1,
				con4.cstf_id AS tipo_tarifa,
				cc1.ctch_qteconomia AS ecn_res,
				cc2.ctch_qteconomia AS ecn_com,
				cc3.ctch_qteconomia AS ecn_ind,
				cc4.ctch_qteconomia AS ecn_pubm,
				cc5.ctch_qteconomia AS ecn_pube,
				cc6.ctch_qteconomia AS ecn_pubf,
				cc7.ctch_qteconomia AS ecn_resp,
				cc8.ctch_qteconomia AS ecn_comp,
				cc9.ctch_qteconomia AS ecn_entf,
				cc10.ctch_qteconomia AS ecn_sisn,
				cc11.ctch_qteconomia AS ecn_out,
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
				LEFT JOIN faturamento.conta_catg_hist cc1 ON cc1.cnta_id = con4.cnta_id AND cc1.scat_id = 1
				LEFT JOIN faturamento.conta_catg_hist cc2 ON cc2.cnta_id = con4.cnta_id AND cc2.scat_id = 2
				LEFT JOIN faturamento.conta_catg_hist cc3 ON cc3.cnta_id = con4.cnta_id AND cc3.scat_id = 3
				LEFT JOIN faturamento.conta_catg_hist cc4 ON cc4.cnta_id = con4.cnta_id AND cc4.scat_id = 4
				LEFT JOIN faturamento.conta_catg_hist cc5 ON cc5.cnta_id = con4.cnta_id AND cc5.scat_id = 5
				LEFT JOIN faturamento.conta_catg_hist cc6 ON cc6.cnta_id = con4.cnta_id AND cc6.scat_id = 6
				LEFT JOIN faturamento.conta_catg_hist cc7 ON cc7.cnta_id = con4.cnta_id AND cc7.scat_id = 7
				LEFT JOIN faturamento.conta_catg_hist cc8 ON cc8.cnta_id = con4.cnta_id AND cc8.scat_id = 8
				LEFT JOIN faturamento.conta_catg_hist cc9 ON cc9.cnta_id = con4.cnta_id AND cc9.scat_id = 9
				LEFT JOIN faturamento.conta_catg_hist cc10 ON cc10.cnta_id = con4.cnta_id AND cc10.scat_id = 10
				LEFT JOIN faturamento.conta_catg_hist cc11 ON cc11.cnta_id = con4.cnta_id AND cc11.scat_id = 11
			WHERE
				con4.cnhi_amreferenciaconta = 202108
			UNION
			SELECT 
				con4.imov_id AS mat1,
				con4.cstf_id AS tipo_tarifa,
				cc1.ctch_qteconomia AS ecn_res,
				cc2.ctch_qteconomia AS ecn_com,
				cc3.ctch_qteconomia AS ecn_ind,
				cc4.ctch_qteconomia AS ecn_pubm,
				cc5.ctch_qteconomia AS ecn_pube,
				cc6.ctch_qteconomia AS ecn_pubf,
				cc7.ctch_qteconomia AS ecn_resp,
				cc8.ctch_qteconomia AS ecn_comp,
				cc9.ctch_qteconomia AS ecn_entf,
				cc10.ctch_qteconomia AS ecn_sisn,
				cc11.ctch_qteconomia AS ecn_out,
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
				LEFT JOIN faturamento.conta_catg_hist cc1 ON cc1.cnta_id = con4.cnta_id AND cc1.scat_id = 1
				LEFT JOIN faturamento.conta_catg_hist cc2 ON cc2.cnta_id = con4.cnta_id AND cc2.scat_id = 2
				LEFT JOIN faturamento.conta_catg_hist cc3 ON cc3.cnta_id = con4.cnta_id AND cc3.scat_id = 3
				LEFT JOIN faturamento.conta_catg_hist cc4 ON cc4.cnta_id = con4.cnta_id AND cc4.scat_id = 4
				LEFT JOIN faturamento.conta_catg_hist cc5 ON cc5.cnta_id = con4.cnta_id AND cc5.scat_id = 5
				LEFT JOIN faturamento.conta_catg_hist cc6 ON cc6.cnta_id = con4.cnta_id AND cc6.scat_id = 6
				LEFT JOIN faturamento.conta_catg_hist cc7 ON cc7.cnta_id = con4.cnta_id AND cc7.scat_id = 7
				LEFT JOIN faturamento.conta_catg_hist cc8 ON cc8.cnta_id = con4.cnta_id AND cc8.scat_id = 8
				LEFT JOIN faturamento.conta_catg_hist cc9 ON cc9.cnta_id = con4.cnta_id AND cc9.scat_id = 9
				LEFT JOIN faturamento.conta_catg_hist cc10 ON cc10.cnta_id = con4.cnta_id AND cc10.scat_id = 10
				LEFT JOIN faturamento.conta_catg_hist cc11 ON cc11.cnta_id = con4.cnta_id AND cc11.scat_id = 11
			WHERE
				con4.cnhi_amreferenciaconta = 202108
			UNION
			SELECT 
				con4.imov_id AS mat1,
				con4.cstf_id AS tipo_tarifa,
				cc1.ctcg_qteconomia AS ecn_res,
				cc2.ctcg_qteconomia AS ecn_com,
				cc3.ctcg_qteconomia AS ecn_ind,
				cc4.ctcg_qteconomia AS ecn_pubm,
				cc5.ctcg_qteconomia AS ecn_pube,
				cc6.ctcg_qteconomia AS ecn_pubf,
				cc7.ctcg_qteconomia AS ecn_resp,
				cc8.ctcg_qteconomia AS ecn_comp,
				cc9.ctcg_qteconomia AS ecn_entf,
				cc10.ctcg_qteconomia AS ecn_sisn,
				cc11.ctcg_qteconomia AS ecn_out,
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
				LEFT JOIN faturamento.conta_categoria cc1 ON cc1.cnta_id = con4.cnta_id AND cc1.scat_id = 1
				LEFT JOIN faturamento.conta_categoria cc2 ON cc2.cnta_id = con4.cnta_id AND cc2.scat_id = 2
				LEFT JOIN faturamento.conta_categoria cc3 ON cc3.cnta_id = con4.cnta_id AND cc3.scat_id = 3
				LEFT JOIN faturamento.conta_categoria cc4 ON cc4.cnta_id = con4.cnta_id AND cc4.scat_id = 4
				LEFT JOIN faturamento.conta_categoria cc5 ON cc5.cnta_id = con4.cnta_id AND cc5.scat_id = 5
				LEFT JOIN faturamento.conta_categoria cc6 ON cc6.cnta_id = con4.cnta_id AND cc6.scat_id = 6
				LEFT JOIN faturamento.conta_categoria cc7 ON cc7.cnta_id = con4.cnta_id AND cc7.scat_id = 7
				LEFT JOIN faturamento.conta_categoria cc8 ON cc8.cnta_id = con4.cnta_id AND cc8.scat_id = 8
				LEFT JOIN faturamento.conta_categoria cc9 ON cc9.cnta_id = con4.cnta_id AND cc9.scat_id = 9
				LEFT JOIN faturamento.conta_categoria cc10 ON cc10.cnta_id = con4.cnta_id AND cc10.scat_id = 10
				LEFT JOIN faturamento.conta_categoria cc11 ON cc11.cnta_id = con4.cnta_id AND cc11.scat_id = 11
			WHERE
				con4.cnta_amreferenciaconta = 202108
			) AS con_ult_fat ON con_ult_fat.mat1 = imo.imov_id
WHERE
	imo.imov_icexclusao = 2 AND
	con_ult_fat.valor > 0
ORDER BY "LOCALIDADE","SETOR COMERCIAL","ROTA","QUADRA","SEQUENCIA","SUB LOTE"