--202312: Deve ser substituida pela referencia do faturamento que se deseja obter os dados
--2, 3, 7: Deve ser substituida pelo id da unidade de onde se quer obter os dados

SELECT 
	imo.imov_id AS "MATRICULA",
	TO_CHAR(imo.imov_nncoordenadax,'990D999999999999999') AS "LATITUDE",
	TO_CHAR(imo.imov_nncoordenaday,'990D999999999999999') AS "LONGITUDE",
	imo.iper_id AS "PERFIL",
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
	une.uneg_nmunidadenegocio AS "NOME UNIDADE",
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
	lgd.lagd_dsligacaoaguadiametro AS "DIAMETRO LIG AGUA",
	lagu.lagu_dtimplantacao AS "DT. IMPLANTACAO",
	lagu.lagu_dtligacaoagua AS "DT. LIGACAO",
	lagu.lagu_dtcorte AS "DT. CORTE",
	lagu.lagu_dtreligacaoagua AS "DT. RELIGACAO",
	lagu.lagu_dtsupressaoagua AS "DT. SUPRESSAO",
	imo.lest_id AS "ID SIT. ESG",
	les.lest_dsligacaoesgotosituacao AS "SITUACAO ESGOTO",
	lesg.lesg_dtligacao AS "DT. LIGACAO ESGOTO",
	hid.hidr_nnhidrometro AS "NR HID.",
	hid.hidr_nnanofabricacao AS "ANO HD",
	his.hidi_dtinstalacaohidrometro AS "DATA DE INSTALACAO HD.",
	hic.hicp_dshidrometrocapacidade AS "CAPACIDADE HD",
	hdi.hidm_dshidrometrodiametro AS "DIAMETRO HD",
	lts.ltst_dsleiturasituacao AS "SITUACAO LEITURA",
	cost_a1.cstp_dsconsumotipo AS "TIPO CONSUMO AGUA",
	mdh.mdhi_nnconsumomedidomes AS "CONSUMO MEDIDO",
	mdh.mdhi_nnconsumoinformado AS "CONSUMO INFORMADO"
FROM 
	cadastro.imovel imo
	INNER JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
	INNER JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
	INNER JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
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
	LEFT JOIN cadastro.pessoa_sexo sex ON sex.psex_id = cli.psex_id
	LEFT JOIN operacional.distrito_operacional dis ON dis.diop_id = qdr.diop_id
	LEFT JOIN cadastro.cliente_imovel cim2 ON cim2.imov_id = imo.imov_id AND cim2.clim_dtrelacaofim IS NULL AND cim2.crtp_id  = 3
	LEFT JOIN cadastro.cliente cli2 ON cli2.clie_id = cim2.clie_id
	LEFT JOIN cadastro.cliente cli3 ON cli3.clie_id = cli2.clie_cdclienteresponsavel
	LEFT JOIN cadastro.logradouro_cep lgc ON lgc.lgcp_id = imo.lgcp_id
	LEFT JOIN cadastro.cep cep ON cep.cep_id = lgc.cep_id
	LEFT JOIN cadastro.logradouro_tipo lgt ON lgt.lgtp_id = logr.lgtp_id
	LEFT JOIN faturamento.fatur_situacao_hist fsh ON fsh.imov_id = imo.imov_id AND fsh.ftsh_amfaturamentoretirada IS NULL
	LEFT JOIN faturamento.fatur_situacao_tipo fat ON fat.ftst_id = fsh.ftst_id
	LEFT JOIN faturamento.fatur_situacao_motivo ftm ON fsh.ftsm_id = ftm.ftsm_id
	LEFT JOIN atendimentopublico.ligacao_agua lagu ON lagu.lagu_id = imo.imov_id
	LEFT JOIN atendimentopublico.ligacao_esgoto lesg ON lesg.lesg_id = imo.imov_id
	LEFT JOIN atendimentopublico.ligacao_agua_diametro lgd ON lgd.lagd_id = lagu.lagd_id
	LEFT JOIN micromedicao.hidrometro_inst_hist his ON lagu.hidi_id = his.hidi_id AND his.hidi_dtretiradahidrometro IS NULL
	LEFT JOIN micromedicao.medicao_tipo mtp ON mtp.medt_id = his.medt_id
	LEFT JOIN micromedicao.hidrometro hid ON his.hidr_id = hid.hidr_id
	LEFT JOIN micromedicao.hidrometro_capacidade hic ON hic.hicp_id = hid.hicp_id
	LEFT JOIN micromedicao.hidrometro_diametro hdi ON hdi.hidm_id = hid.hidm_id
	LEFT JOIN micromedicao.hidrometro_marca hma ON hma.himc_id = hid.himc_id
	LEFT JOIN cadastro.imovel_cobranca_situacao ics ON ics.imov_id = imo.imov_id AND ics.iscb_dtretiradacobranca IS NULL AND ics.cbst_id IN (12,14,17)
	LEFT JOIN cobranca.cobranca_situacao cob ON cob.cbst_id = ics.cbst_id 
	LEFT JOIN cadastro.imovel_cobranca_situacao ics_exi ON ics_exi.imov_id = imo.imov_id AND ics_exi.iscb_dtretiradacobranca IS NULL AND ics_exi.cbst_id = 23
	LEFT JOIN cobranca.cobranca_situacao cob_exi ON cob_exi.cbst_id = ics_exi.cbst_id 
	LEFT JOIN cadastro.imovel_cobranca_situacao ics_ser ON ics_ser.imov_id = imo.imov_id AND ics_ser.iscb_dtretiradacobranca IS NULL AND ics_ser.cbst_id IN (24,25,26)
	LEFT JOIN cobranca.cobranca_situacao cob_ser ON cob_ser.cbst_id = ics_ser.cbst_id 
	LEFT JOIN cobranca.cobranca_situacao_hist csh ON csh.imov_id = imo.imov_id AND csh.cbsh_amcobrancaretirada IS NULL
	LEFT JOIN cobranca.cobranca_situacao_tipo cst ON csh.cbsp_id = cst.cbsp_id
	LEFT JOIN cobranca.cobranca_situacao_motivo csm ON csm.cbsm_id = csh.cbsm_id
	LEFT JOIN micromedicao.consumo_historico cosh_a1 ON cosh_a1.imov_id = imo.imov_id AND cosh_a1.cshi_amfaturamento = 202312 AND cosh_a1.lgti_id = 1
	LEFT JOIN micromedicao.consumo_tipo cost_a1 ON cost_a1.cstp_id = cosh_a1.cstp_id
	LEFT JOIN micromedicao.consumo_anormalidade cosa_a1 ON cosa_a1.csan_id = cosh_a1.csan_id
	LEFT JOIN micromedicao.medicao_historico mdh ON mdh.hidi_id = his.hidi_id AND mdh.mdhi_amleitura = 202312
	LEFT JOIN micromedicao.leitura_situacao lts ON lts.ltst_id = mdh.ltst_idleiturasituacaoatual
	LEFT JOIN micromedicao.leitura_anormalidade lai ON lai.ltan_id = mdh.ltan_idleitanorminformada
	LEFT JOIN micromedicao.leitura_anormalidade laf ON laf.ltan_id = mdh.ltan_idleitanormfatmt
	--LEFT JOIN arrecadacao.debito_automatico dab ON dab.imov_id = imo.imov_id AND dab.deba_dtexclusao IS NULL
	--LEFT JOIN arrecadacao.agencia age ON age.agen_id = dab.agen_id
	--LEFT JOIN arrecadacao.banco ban ON ban.bnco_id = age.bnco_id
	LEFT JOIN (	SELECT 
				con4.imov_id AS mat1,
				COUNT(con4.cnta_id) AS qtd,
				MIN(con4.cnta_amreferenciaconta) AS min,
				MAX(con4.cnta_amreferenciaconta) AS max,
				SUM(con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos) AS valor
			FROM faturamento.conta con4 
			WHERE 
				con4.dcst_idatual IN (0,1,2) AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con4.cnta_id) AND con4.cnta_dtvencimentoconta < CURRENT_DATE AND con4.iper_id = 6
			GROUP BY 1) AS con_vivaagua ON con_vivaagua.mat1 = imo.imov_id
	LEFT JOIN (	SELECT 
				con4.imov_id AS mat1,
				COUNT(con4.cnta_id) AS qtd,
				MIN(con4.cnta_amreferenciaconta) AS min,
				MAX(con4.cnta_amreferenciaconta) AS max,
				SUM(con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos) AS valor
			FROM faturamento.conta con4 
			WHERE 
				con4.dcst_idatual IN (0,1,2) AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con4.cnta_id) AND NOT con4.cnta_dtrevisao IS NULL
			GROUP BY 1) AS con_revisao ON con_revisao.mat1 = imo.imov_id
	LEFT JOIN (	SELECT 
				con4.imov_id AS mat1,
				COUNT(con4.cnta_id) AS qtd,
				MIN(con4.cnta_amreferenciaconta) AS min,
				MAX(con4.cnta_amreferenciaconta) AS max,
				SUM(con4.cnta_vlagua+con4.cnta_vlesgoto) AS valor,
				SUM(con4.cnta_vldebitos) AS outros,
				SUM(con4.cnta_vlcreditos) AS creditos
			FROM faturamento.conta con4 
			WHERE 
				con4.dcst_idatual IN (0,1,2) AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con4.cnta_id) AND NOT con4.cnta_dtrevisao IS NULL AND con4.cmrv_id = 114
			GROUP BY 1) AS con_revisao_decreto ON con_revisao_decreto.mat1 = imo.imov_id
	LEFT JOIN (	SELECT 
				con4.imov_id AS mat1,
				SUM(con4.cnta_vlagua) AS vl_agua,
				SUM(con4.cnta_vlesgoto) AS vl_esgoto,
				SUM(con4.cnta_vldebitos) AS vl_debitos,
				SUM(con4.cnta_vlcreditos) AS vl_creditos,
				SUM(con4.cnta_vlimpostos) AS vl_impostos,
				COUNT(con4.cnta_id) AS qtd,
				MIN(con4.cnta_amreferenciaconta) AS min,
				MAX(con4.cnta_amreferenciaconta) AS max,
				MIN(con4.cnta_dtvencimentoconta) AS min_venc,
				MAX(con4.cnta_dtvencimentoconta) AS max_venc,
				SUM(con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos) AS valor,
				SUM(TRUNC(((con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos)*0.02)::NUMERIC,2)) AS multa,
				SUM(TRUNC(((con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos)*0.005*(((EXTRACT(YEAR FROM CURRENT_DATE::DATE)-EXTRACT(YEAR FROM con4.cnta_dtvencimentoconta))*12)+(EXTRACT(MONTH FROM CURRENT_DATE::DATE)-EXTRACT(MONTH FROM con4.cnta_dtvencimentoconta))))::NUMERIC, 2)) AS juros
			FROM faturamento.conta con4 
			WHERE 
				con4.dcst_idatual IN (0,1,2) AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con4.cnta_id) AND con4.cnta_dtvencimentoconta < CURRENT_DATE AND con4.cnta_dtrevisao IS NULL AND con4.iper_id <> 6
			GROUP BY 1) AS con_atraso ON con_atraso.mat1 = imo.imov_id
	LEFT JOIN (	SELECT 
				con4.imov_id AS mat1,
				COUNT(distinct con4.cnta_id) AS qtd,
				SUM(dco.dbcb_vlprestacao) AS valor
			FROM faturamento.conta con4 
				INNER JOIN faturamento.debito_cobrado dco ON dco.cnta_id = con4.cnta_id AND dco.dbtp_id IN (40,43,44)
			WHERE 
				con4.dcst_idatual IN (0,1,2) AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con4.cnta_id) AND con4.cnta_dtvencimentoconta < CURRENT_DATE AND con4.cnta_dtrevisao IS NULL AND con4.iper_id <> 6
			GROUP BY 1) AS con_parcelamento ON con_parcelamento.mat1 = imo.imov_id
	LEFT JOIN (	SELECT 
				con4.imov_id AS mat1,
				SUM(con4.cnta_vlagua) AS vl_agua,
				SUM(con4.cnta_vlesgoto) AS vl_esgoto,
				SUM(con4.cnta_vldebitos) AS vl_debitos,
				SUM(con4.cnta_vlcreditos) AS vl_creditos,
				SUM(con4.cnta_vlimpostos) AS vl_impostos,
				COUNT(con4.cnta_id) AS qtd,
				MIN(con4.cnta_amreferenciaconta) AS min,
				MAX(con4.cnta_amreferenciaconta) AS max,
				MIN(con4.cnta_dtvencimentoconta) AS min_venc,
				MAX(con4.cnta_dtvencimentoconta) AS max_venc,
				SUM(con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos) AS valor
			FROM faturamento.conta con4 
				INNER JOIN cobranca.empresa_cobranca_conta ecc ON ecc.cnta_id = con4.cnta_id
			WHERE 
				ecc.ecco_dtretiradaconta IS NULL AND con4.dcst_idatual IN (0,1,2) AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con4.cnta_id) AND con4.cnta_dtvencimentoconta < CURRENT_DATE AND con4.cnta_dtrevisao IS NULL AND con4.iper_id <> 6
			GROUP BY 1) AS con_cobranca ON con_cobranca.mat1 = imo.imov_id
	LEFT JOIN (	SELECT 
				con4.imov_id AS mat1,
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
				con4.cnta_amreferenciaconta = 202312
			UNION
			SELECT 
				con4.imov_id AS mat1,
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
				con4.cnhi_amreferenciaconta = 202312
			UNION
			SELECT 
				con4.imov_id AS mat1,
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
				con4.cnta_amreferenciaconta = 202312
			UNION
			SELECT 
				con4.imov_id AS mat1,
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
				con4.cnhi_amreferenciaconta = 202312
			) AS con_ult_fat ON con_ult_fat.mat1 = imo.imov_id
	LEFT JOIN (	SELECT 
				con4.imov_id AS mat1,
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
				con4.cnta_amreferenciaconta = (
					SELECT 
						CASE (CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(202312-1 AS TEXT)
						END
				)
			UNION
			SELECT 
				con4.imov_id AS mat1,
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
				con4.cnhi_amreferenciaconta = (
					SELECT 
						CASE (CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(202312-1 AS TEXT)
						END
				)
			UNION
			SELECT 
				con4.imov_id AS mat1,
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
				con4.cnta_amreferenciaconta = (
					SELECT 
						CASE (CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(202312-1 AS TEXT)
						END
				)
			UNION
			SELECT 
				con4.imov_id AS mat1,
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
				con4.cnhi_amreferenciaconta = (
					SELECT 
						CASE (CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(202312-1 AS TEXT)
						END
				)
			) AS con_pen_fat ON con_pen_fat.mat1 = imo.imov_id
		LEFT JOIN (	SELECT 
				con4.imov_id AS mat1,
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
				con4.cnta_amreferenciaconta = (
					SELECT 
						CASE (CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'11'
							WHEN 2 THEN CAST((CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(202312-2 AS TEXT)
						END
				)
			UNION
			SELECT 
				con4.imov_id AS mat1,
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
				con4.cnhi_amreferenciaconta = (
					SELECT 
						CASE (CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'11'
							WHEN 2 THEN CAST((CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(202312-2 AS TEXT)
						END
				)
			UNION
			SELECT 
				con4.imov_id AS mat1,
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
				con4.cnta_amreferenciaconta = (
					SELECT 
						CASE (CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'11'
							WHEN 2 THEN CAST((CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(202312-2 AS TEXT)
						END
				)
			UNION
			SELECT 
				con4.imov_id AS mat1,
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
				con4.cnhi_amreferenciaconta = (
					SELECT 
						CASE (CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'11'
							WHEN 2 THEN CAST((CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(202312-2 AS TEXT)
						END
				)
			) AS con_ant_fat ON con_ant_fat.mat1 = imo.imov_id
	LEFT JOIN(
			SELECT
				pags.imov_id AS imov_id,
				SUM(pags.qtd) AS qtd,
				SUM(pags.valor) AS valor
			FROM		
				(SELECT 
						pag.imov_id AS imov_id,
						COUNT(pag.pgmt_id) AS qtd,
						SUM(pag.pgmt_vlpagamento) AS valor
					FROM
						arrecadacao.pagamento pag
						INNER JOIN cadastro.localidade loc ON loc.loca_id = pag.loca_id AND loc.uneg_id IN (2, 3, 7)
					WHERE
						pag.pgst_idatual IN (0,1)
						AND pag.pgmt_amreferenciaarrecadacao = 202312
					GROUP BY 1
				UNION
					SELECT 
						pag.imov_id AS imov_id,
						COUNT(pag.pghi_id) AS qtd,
						SUM(pag.pghi_vlpagamento) AS valor
					FROM
						arrecadacao.pagamento_historico pag
						INNER JOIN cadastro.localidade loc ON loc.loca_id = pag.loca_id AND loc.uneg_id IN (2, 3, 7)
					WHERE
						pag.pgst_idatual IN (0,1)
						AND pag.pghi_amreferenciaarrecadacao = 202312
					GROUP BY 1) pags
			GROUP BY 1
		) AS pags_ult ON pags_ult.imov_id = imo.imov_id
	LEFT JOIN (
			SELECT
				pags.imov_id AS imov_id,
				SUM(pags.qtd) AS qtd,
				SUM(pags.valor) AS valor
			FROM		
				(SELECT 
						pag.imov_id AS imov_id,
						COUNT(pag.pgmt_id) AS qtd,
						SUM(pag.pgmt_vlpagamento) AS valor
					FROM
						arrecadacao.pagamento pag
						INNER JOIN cadastro.localidade loc ON loc.loca_id = pag.loca_id AND loc.uneg_id IN (2, 3, 7)
					WHERE
						pag.pgst_idatual IN (0,1)
						AND pag.pgmt_amreferenciaarrecadacao = (
								SELECT 
									CASE (CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 5 FOR 6) AS INT))
										WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
										ELSE CAST(202312-1 AS TEXT)
									END
							)
					GROUP BY 1
				UNION
					SELECT 
						pag.imov_id AS imov_id,
						COUNT(pag.pghi_id) AS qtd,
						SUM(pag.pghi_vlpagamento) AS valor
					FROM
						arrecadacao.pagamento_historico pag
						INNER JOIN cadastro.localidade loc ON loc.loca_id = pag.loca_id AND loc.uneg_id IN (2, 3, 7)
					WHERE
						pag.pgst_idatual IN (0,1)
						AND pag.pghi_amreferenciaarrecadacao = (
								SELECT 
									CASE (CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 5 FOR 6) AS INT))
										WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
										ELSE CAST(202312-1 AS TEXT)
									END
							)
					GROUP BY 1) pags
			GROUP BY 1
		) AS pags_pen ON pags_pen.imov_id = imo.imov_id
	LEFT JOIN (
			SELECT
				pags.imov_id AS imov_id,
				SUM(pags.qtd) AS qtd,
				SUM(pags.valor) AS valor
			FROM		
				(SELECT 
						pag.imov_id AS imov_id,
						COUNT(pag.pgmt_id) AS qtd,
						SUM(pag.pgmt_vlpagamento) AS valor
					FROM
						arrecadacao.pagamento pag
						INNER JOIN cadastro.localidade loc ON loc.loca_id = pag.loca_id AND loc.uneg_id IN (2, 3, 7)
					WHERE
						pag.pgst_idatual IN (0,1)
						AND pag.pgmt_amreferenciaarrecadacao = (
								SELECT 
									CASE (CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 5 FOR 6) AS INT))
										WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'11'
										WHEN 2 THEN CAST((CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
										ELSE CAST(202312-2 AS TEXT)
									END
							)
					GROUP BY 1
				UNION
					SELECT 
						pag.imov_id AS imov_id,
						COUNT(pag.pghi_id) AS qtd,
						SUM(pag.pghi_vlpagamento) AS valor
					FROM
						arrecadacao.pagamento_historico pag
						INNER JOIN cadastro.localidade loc ON loc.loca_id = pag.loca_id AND loc.uneg_id IN (2, 3, 7)
					WHERE
						pag.pgst_idatual IN (0,1)
						AND pag.pghi_amreferenciaarrecadacao = (
								SELECT 
									CASE (CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 5 FOR 6) AS INT))
										WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'11'
										WHEN 2 THEN CAST((CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
										ELSE CAST(202312-2 AS TEXT)
									END
							)
					GROUP BY 1) pags
			GROUP BY 1
		) AS pags_ant ON pags_ant.imov_id = imo.imov_id
	LEFT JOIN (	SELECT
				sum_fat.uneg_id AS uneg_id,
				sum_fat.scat_id AS scat_id,
				SUM(sum_fat.cagua)/SUM(sum_fat.econ) AS cagu_econ,
				SUM(sum_fat.vl_agua)/SUM(sum_fat.econ) AS vlag_econ,
				SUM(sum_fat.cesg)/SUM(sum_fat.econ) AS cesg_econ,
				SUM(sum_fat.vl_esgoto)/SUM(sum_fat.econ) AS vles_econ
			FROM	
				(SELECT 
					une.uneg_id AS uneg_id,
					imo.imov_idsubcategoriaprincipal AS scat_id,
					SUM(imo.imov_qteconomia) AS econ,
					SUM(con4.cnta_nnconsumoagua) AS cagua,
					SUM(con4.cnta_vlagua) AS vl_agua,
					SUM(con4.cnta_nnconsumoesgoto) AS cesg,
					SUM(con4.cnta_vlesgoto) AS vl_esgoto
				FROM faturamento.conta con4 
					INNER JOIN faturamento.conta_impressao cni ON cni.cnta_id = con4.cnta_id
					INNER JOIN cadastro.imovel imo ON imo.imov_id = con4.imov_id
					INNER JOIN cadastro.localidade loc ON loc.loca_id = imo.loca_id
					INNER JOIN cadastro.unidade_negocio une ON loc.uneg_id = une.uneg_id
				WHERE
					con4.cnta_amreferenciaconta = (
					SELECT 
						CASE (CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(202312-1 AS TEXT)
						END
					)
				GROUP BY 1,2
			UNION
				SELECT 
					une.uneg_id AS uneg_id,
					imo.imov_idsubcategoriaprincipal AS scat_id,
					SUM(imo.imov_qteconomia) AS econ,
					SUM(con4.cnhi_nnconsumoagua) AS cagua,
					SUM(con4.cnhi_vlagua) AS vl_agua,
					SUM(con4.cnhi_nnconsumoesgoto) AS cesg,
					SUM(con4.cnhi_vlesgoto) AS vl_esgoto
				FROM faturamento.conta_historico con4 
					INNER JOIN faturamento.conta_impressao cni ON cni.cnta_id = con4.cnta_id
					INNER JOIN cadastro.imovel imo ON imo.imov_id = con4.imov_id
					INNER JOIN cadastro.localidade loc ON loc.loca_id = imo.loca_id
					INNER JOIN cadastro.unidade_negocio une ON loc.uneg_id = une.uneg_id
				WHERE
					con4.cnhi_amreferenciaconta = (
					SELECT 
						CASE (CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(202312-1 AS TEXT)
						END
					)
				GROUP BY 1,2
			UNION
				SELECT 
					une.uneg_id AS uneg_id,
					imo.imov_idsubcategoriaprincipal AS scat_id,
					SUM(imo.imov_qteconomia) AS econ,
					SUM(con4.cnta_nnconsumoagua) AS cagua,
					SUM(con4.cnta_vlagua) AS vl_agua,
					SUM(con4.cnta_nnconsumoesgoto) AS cesg,
					SUM(con4.cnta_vlesgoto) AS vl_esgoto
				FROM faturamento.conta con4 
					INNER JOIN faturamento.mov_conta_prefaturada cni ON cni.cnta_id = con4.cnta_id
					INNER JOIN cadastro.imovel imo ON imo.imov_id = con4.imov_id
					INNER JOIN cadastro.localidade loc ON loc.loca_id = imo.loca_id
					INNER JOIN cadastro.unidade_negocio une ON loc.uneg_id = une.uneg_id
				WHERE
					con4.cnta_amreferenciaconta = (
					SELECT 
						CASE (CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(202312-1 AS TEXT)
						END
					)
				GROUP BY 1,2
			UNION
				SELECT 
					une.uneg_id AS uneg_id,
					imo.imov_idsubcategoriaprincipal AS scat_id,
					SUM(imo.imov_qteconomia) AS econ,
					SUM(con4.cnhi_nnconsumoagua) AS cagua,
					SUM(con4.cnhi_vlagua) AS vl_agua,
					SUM(con4.cnhi_nnconsumoesgoto) AS cesg,
					SUM(con4.cnhi_vlesgoto) AS vl_esgoto
				FROM faturamento.conta_historico con4 
					INNER JOIN faturamento.mov_conta_prefaturada cni ON cni.cnta_id = con4.cnta_id
					INNER JOIN cadastro.imovel imo ON imo.imov_id = con4.imov_id
					INNER JOIN cadastro.localidade loc ON loc.loca_id = imo.loca_id
					INNER JOIN cadastro.unidade_negocio une ON loc.uneg_id = une.uneg_id
				WHERE
					con4.cnhi_amreferenciaconta = (
					SELECT 
						CASE (CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(202312-1 AS TEXT)
						END
					)
				GROUP BY 1,2) AS sum_fat
			GROUP BY 1,2) AS fat_med ON une.uneg_id = fat_med.uneg_id AND imo.imov_idsubcategoriaprincipal = fat_med.scat_id
LEFT JOIN (
			SELECT
				con.imov_id AS "MATRICULA",
				pag.pghi_dtpagamento - con.cnhi_dtvencimentoconta AS "ATRASO",
				con.cnhi_amreferenciaconta AS "REFERENCIA",
				pag.pghi_dtpagamento AS "DATA PAGAMENTO",
				con.cnhi_dtvencimentoconta AS "VENCIMENTO",
				con.cnhi_dtvencimentooriginal AS "VENCIMENTO ORIGINAL",
				pag.pghi_dtpagamento - con.cnhi_dtvencimentooriginal AS "ATRASO VENCIMENTO ORIGINAL",
				(CASE 
				WHEN pag.pghi_dtpagamento - con.cnhi_dtvencimentooriginal <= 0 THEN '01 - EM DIA'
				WHEN pag.pghi_dtpagamento - con.cnhi_dtvencimentooriginal <= 5  THEN '02 - ATE 5 DIAS DE ATRASO'
				WHEN pag.pghi_dtpagamento - con.cnhi_dtvencimentooriginal <= 15  THEN '03 - ATE 15 DIAS DE ATRASO'
				WHEN pag.pghi_dtpagamento - con.cnhi_dtvencimentooriginal <= 30  THEN '04 - ATE 30 DIAS DE ATRASO'
				WHEN pag.pghi_dtpagamento - con.cnhi_dtvencimentooriginal <= 60  THEN '05 - ATE 60 DIAS DE ATRASO'
				WHEN pag.pghi_dtpagamento - con.cnhi_dtvencimentooriginal <= 90  THEN '06 - ATE 90 DIAS DE ATRASO'
				WHEN pag.pghi_dtpagamento - con.cnhi_dtvencimentooriginal <= 180  THEN '07 - ATE 180 DIAS DE ATRASO'
				WHEN pag.pghi_dtpagamento - con.cnhi_dtvencimentooriginal <= 365  THEN '08 - ATE 365 DIAS DE ATRASO'
				WHEN pag.pghi_dtpagamento - con.cnhi_dtvencimentooriginal <= 1825  THEN '09 - ATE 5 ANOS DE ATRASO'
				WHEN pag.pghi_dtpagamento - con.cnhi_dtvencimentooriginal <= 3650  THEN '10 - ATE 10 ANOS DE ATRASO'
				WHEN pag.pghi_dtpagamento - con.cnhi_dtvencimentooriginal > 3650  THEN '11 - ACIMA DE 10 ANOS DE ATRASO'
				END) AS "FAIXA ATRASO",
				con.cnhi_nnconsumoagua AS "VOL AGUA",
				con.cnhi_nnconsumoesgoto AS "VOL ESGOTO",
				TO_CHAR((con.cnhi_vlagua),'L999G999G990D00') AS "VL AGUA",
				TO_CHAR((con.cnhi_vlesgoto), 'L999G999G990D00') AS "VL ESGOTO",
				TO_CHAR((con.cnhi_vldebitos), 'L999G999G990D00') AS "VL DEBITOS",
				TO_CHAR((con.cnhi_vlcreditos), 'L999G999G990D00') AS "VL CREDITOS",
				TO_CHAR((con.cnhi_vlimpostos), 'L999G999G990D00') AS "VL IMPOSTOS",
				TO_CHAR((pag.pghi_vlpagamento), 'L999G999G990D00') AS "VALOR",
				'PAGO' AS "STATUS"
			FROM
				arrecadacao.pagamento_historico pag
				INNER JOIN faturamento.conta_historico con ON con.cnta_id = pag.cnta_id
			WHERE
				con.cnhi_amreferenciaconta = (
					SELECT 
						CASE (CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(202312-1 AS TEXT)
						END
					)
		UNION
			SELECT
				con.imov_id AS "MATRICULA",
				pag.pgmt_dtpagamento - con.cnhi_dtvencimentoconta AS "ATRASO",
				con.cnhi_amreferenciaconta AS "REFERENCIA",
				pag.pgmt_dtpagamento AS "DATA PAGAMENTO",
				con.cnhi_dtvencimentoconta AS "VENCIMENTO",
				con.cnhi_dtvencimentooriginal AS "VENCIMENTO ORIGINAL",
				pag.pgmt_dtpagamento - con.cnhi_dtvencimentooriginal AS "ATRASO VENCIMENTO ORIGINAL",
				(CASE 
				WHEN pag.pgmt_dtpagamento - con.cnhi_dtvencimentooriginal <= 0 THEN '01 - EM DIA'
				WHEN pag.pgmt_dtpagamento - con.cnhi_dtvencimentooriginal <= 5  THEN '02 - ATE 5 DIAS DE ATRASO'
				WHEN pag.pgmt_dtpagamento - con.cnhi_dtvencimentooriginal <= 15  THEN '03 - ATE 15 DIAS DE ATRASO'
				WHEN pag.pgmt_dtpagamento - con.cnhi_dtvencimentooriginal <= 30  THEN '04 - ATE 30 DIAS DE ATRASO'
				WHEN pag.pgmt_dtpagamento - con.cnhi_dtvencimentooriginal <= 60  THEN '05 - ATE 60 DIAS DE ATRASO'
				WHEN pag.pgmt_dtpagamento - con.cnhi_dtvencimentooriginal <= 90  THEN '06 - ATE 90 DIAS DE ATRASO'
				WHEN pag.pgmt_dtpagamento - con.cnhi_dtvencimentooriginal <= 180  THEN '07 - ATE 180 DIAS DE ATRASO'
				WHEN pag.pgmt_dtpagamento - con.cnhi_dtvencimentooriginal <= 365  THEN '08 - ATE 365 DIAS DE ATRASO'
				WHEN pag.pgmt_dtpagamento - con.cnhi_dtvencimentooriginal <= 1825  THEN '09 - ATE 5 ANOS DE ATRASO'
				WHEN pag.pgmt_dtpagamento - con.cnhi_dtvencimentooriginal <= 3650  THEN '10 - ATE 10 ANOS DE ATRASO'
				WHEN pag.pgmt_dtpagamento - con.cnhi_dtvencimentooriginal > 3650  THEN '11 - ACIMA DE 10 ANOS DE ATRASO'
				END) AS "FAIXA ATRASO",
				con.cnhi_nnconsumoagua AS "VOL AGUA",
				con.cnhi_nnconsumoesgoto AS "VOL ESGOTO",
				TO_CHAR((con.cnhi_vlagua),'L999G999G990D00') AS "VL AGUA",
				TO_CHAR((con.cnhi_vlesgoto), 'L999G999G990D00') AS "VL ESGOTO",
				TO_CHAR((con.cnhi_vldebitos), 'L999G999G990D00') AS "VL DEBITOS",
				TO_CHAR((con.cnhi_vlcreditos), 'L999G999G990D00') AS "VL CREDITOS",
				TO_CHAR((con.cnhi_vlimpostos), 'L999G999G990D00') AS "VL IMPOSTOS",
				TO_CHAR((pag.pgmt_vlpagamento), 'L999G999G990D00') AS "VALOR",
				'PAGO' AS "STATUS"
			FROM
				arrecadacao.pagamento pag
				INNER JOIN faturamento.conta_historico con ON con.cnta_id = pag.cnta_id
			WHERE
				con.cnhi_amreferenciaconta = (
					SELECT 
						CASE (CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(202312-1 AS TEXT)
						END
					)
		UNION
			SELECT
				con.imov_id AS "MATRICULA",
				pag.pghi_dtpagamento - con.cnta_dtvencimentoconta AS "ATRASO",
				con.cnta_amreferenciaconta AS "REFERENCIA",
				pag.pghi_dtpagamento AS "DATA PAGAMENTO",
				con.cnta_dtvencimentoconta AS "VENCIMENTO",
				con.cnta_dtvencimentooriginal AS "VENCIMENTO ORIGINAL",
				pag.pghi_dtpagamento - con.cnta_dtvencimentooriginal AS "ATRASO VENCIMENTO ORIGINAL",
				(CASE 
				WHEN pag.pghi_dtpagamento - con.cnta_dtvencimentooriginal <= 0 THEN '01 - EM DIA'
				WHEN pag.pghi_dtpagamento - con.cnta_dtvencimentooriginal <= 5  THEN '02 - ATE 5 DIAS DE ATRASO'
				WHEN pag.pghi_dtpagamento - con.cnta_dtvencimentooriginal <= 15  THEN '03 - ATE 15 DIAS DE ATRASO'
				WHEN pag.pghi_dtpagamento - con.cnta_dtvencimentooriginal <= 30  THEN '04 - ATE 30 DIAS DE ATRASO'
				WHEN pag.pghi_dtpagamento - con.cnta_dtvencimentooriginal <= 60  THEN '05 - ATE 60 DIAS DE ATRASO'
				WHEN pag.pghi_dtpagamento - con.cnta_dtvencimentooriginal <= 90  THEN '06 - ATE 90 DIAS DE ATRASO'
				WHEN pag.pghi_dtpagamento - con.cnta_dtvencimentooriginal <= 180  THEN '07 - ATE 180 DIAS DE ATRASO'
				WHEN pag.pghi_dtpagamento - con.cnta_dtvencimentooriginal <= 365  THEN '08 - ATE 365 DIAS DE ATRASO'
				WHEN pag.pghi_dtpagamento - con.cnta_dtvencimentooriginal <= 1825  THEN '09 - ATE 5 ANOS DE ATRASO'
				WHEN pag.pghi_dtpagamento - con.cnta_dtvencimentooriginal <= 3650  THEN '10 - ATE 10 ANOS DE ATRASO'
				WHEN pag.pghi_dtpagamento - con.cnta_dtvencimentooriginal > 3650  THEN '11 - ACIMA DE 10 ANOS DE ATRASO'
				END) AS "FAIXA ATRASO",
				con.cnta_nnconsumoagua AS "VOL AGUA",
				con.cnta_nnconsumoesgoto AS "VOL ESGOTO",
				TO_CHAR((con.cnta_vlagua),'L999G999G990D00') AS "VL AGUA",
				TO_CHAR((con.cnta_vlesgoto), 'L999G999G990D00') AS "VL ESGOTO",
				TO_CHAR((con.cnta_vldebitos), 'L999G999G990D00') AS "VL DEBITOS",
				TO_CHAR((con.cnta_vlcreditos), 'L999G999G990D00') AS "VL CREDITOS",
				TO_CHAR((con.cnta_vlimpostos), 'L999G999G990D00') AS "VL IMPOSTOS",
				TO_CHAR((pag.pghi_vlpagamento), 'L999G999G990D00') AS "VALOR",
				'PAGO' AS "STATUS"
			FROM
				arrecadacao.pagamento_historico pag
				INNER JOIN faturamento.conta con ON con.cnta_id = pag.cnta_id
			WHERE
				con.cnta_amreferenciaconta = (
					SELECT 
						CASE (CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(202312-1 AS TEXT)
						END
					)
		UNION
			SELECT
				con.imov_id AS "MATRICULA",
				pag.pgmt_dtpagamento - con.cnta_dtvencimentoconta AS "ATRASO",
				con.cnta_amreferenciaconta AS "REFERENCIA",
				pag.pgmt_dtpagamento AS "DATA PAGAMENTO",
				con.cnta_dtvencimentoconta AS "VENCIMENTO",
				con.cnta_dtvencimentooriginal AS "VENCIMENTO ORIGINAL",
				pag.pgmt_dtpagamento - con.cnta_dtvencimentooriginal AS "ATRASO VENCIMENTO ORIGINAL",
				(CASE 
				WHEN pag.pgmt_dtpagamento - con.cnta_dtvencimentooriginal <= 0 THEN '01 - EM DIA'
				WHEN pag.pgmt_dtpagamento - con.cnta_dtvencimentooriginal <= 5  THEN '02 - ATE 5 DIAS DE ATRASO'
				WHEN pag.pgmt_dtpagamento - con.cnta_dtvencimentooriginal <= 15  THEN '03 - ATE 15 DIAS DE ATRASO'
				WHEN pag.pgmt_dtpagamento - con.cnta_dtvencimentooriginal <= 30  THEN '04 - ATE 30 DIAS DE ATRASO'
				WHEN pag.pgmt_dtpagamento - con.cnta_dtvencimentooriginal <= 60  THEN '05 - ATE 60 DIAS DE ATRASO'
				WHEN pag.pgmt_dtpagamento - con.cnta_dtvencimentooriginal <= 90  THEN '06 - ATE 90 DIAS DE ATRASO'
				WHEN pag.pgmt_dtpagamento - con.cnta_dtvencimentooriginal <= 180  THEN '07 - ATE 180 DIAS DE ATRASO'
				WHEN pag.pgmt_dtpagamento - con.cnta_dtvencimentooriginal <= 365  THEN '08 - ATE 365 DIAS DE ATRASO'
				WHEN pag.pgmt_dtpagamento - con.cnta_dtvencimentooriginal <= 1825  THEN '09 - ATE 5 ANOS DE ATRASO'
				WHEN pag.pgmt_dtpagamento - con.cnta_dtvencimentooriginal <= 3650  THEN '10 - ATE 10 ANOS DE ATRASO'
				WHEN pag.pgmt_dtpagamento - con.cnta_dtvencimentooriginal > 3650  THEN '11 - ACIMA DE 10 ANOS DE ATRASO'
				END) AS "FAIXA ATRASO",
				con.cnta_nnconsumoagua AS "VOL AGUA",
				con.cnta_nnconsumoesgoto AS "VOL ESGOTO",
				TO_CHAR((con.cnta_vlagua),'L999G999G990D00') AS "VL AGUA",
				TO_CHAR((con.cnta_vlesgoto),'L999G999G990D00') AS "VL ESGOTO",
				TO_CHAR((con.cnta_vldebitos),'L999G999G990D00') AS "VL DEBITOS",
				TO_CHAR((con.cnta_vlcreditos),'L999G999G990D00') AS "VL CREDITOS",
				TO_CHAR((con.cnta_vlimpostos),'L999G999G990D00') AS "VL IMPOSTOS",
				TO_CHAR((pag.pgmt_vlpagamento),'L999G999G990D00') AS "VALOR",
				'PAGO' AS "STATUS"
				
			FROM
				arrecadacao.pagamento pag
				INNER JOIN faturamento.conta con ON con.cnta_id = pag.cnta_id
			WHERE
				con.cnta_amreferenciaconta = (
					SELECT 
						CASE (CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(202312-1 AS TEXT)
						END
					)
		UNION
			SELECT
				con.imov_id AS "MATRICULA",
				CURRENT_DATE - con.cnta_dtvencimentoconta AS "ATRASO",
				con.cnta_amreferenciaconta AS "REFERENCIA",
				NULL AS "DATA PAGAMENTO",
				con.cnta_dtvencimentoconta AS "VENCIMENTO",
				con.cnta_dtvencimentooriginal AS "VENCIMENTO ORIGINAL",
				CURRENT_DATE - con.cnta_dtvencimentooriginal AS "ATRASO VENCIMENTO ORIGINAL",
				(CASE 
				WHEN CURRENT_DATE - con.cnta_dtvencimentooriginal <= 0 THEN '01 - EM DIA'
				WHEN CURRENT_DATE - con.cnta_dtvencimentooriginal <= 5  THEN '02 - ATE 5 DIAS DE ATRASO'
				WHEN CURRENT_DATE - con.cnta_dtvencimentooriginal <= 15  THEN '03 - ATE 15 DIAS DE ATRASO'
				WHEN CURRENT_DATE - con.cnta_dtvencimentooriginal <= 30  THEN '04 - ATE 30 DIAS DE ATRASO'
				WHEN CURRENT_DATE - con.cnta_dtvencimentooriginal <= 60  THEN '05 - ATE 60 DIAS DE ATRASO'
				WHEN CURRENT_DATE - con.cnta_dtvencimentooriginal <= 90  THEN '06 - ATE 90 DIAS DE ATRASO'
				WHEN CURRENT_DATE - con.cnta_dtvencimentooriginal <= 180  THEN '07 - ATE 180 DIAS DE ATRASO'
				WHEN CURRENT_DATE - con.cnta_dtvencimentooriginal <= 365  THEN '08 - ATE 365 DIAS DE ATRASO'
				WHEN CURRENT_DATE - con.cnta_dtvencimentooriginal <= 1825  THEN '09 - ATE 5 ANOS DE ATRASO'
				WHEN CURRENT_DATE - con.cnta_dtvencimentooriginal <= 3650  THEN '10 - ATE 10 ANOS DE ATRASO'
				WHEN CURRENT_DATE - con.cnta_dtvencimentooriginal > 3650  THEN '11 - ACIMA DE 10 ANOS DE ATRASO'
				END) AS "FAIXA ATRASO",
				con.cnta_nnconsumoagua AS "VOL AGUA",
				con.cnta_nnconsumoesgoto AS "VOL ESGOTO",
				TO_CHAR((con.cnta_vlagua),'L999G999G990D00') AS "VL AGUA",
				TO_CHAR((con.cnta_vlesgoto),'L999G999G990D00') AS "VL ESGOTO",
				TO_CHAR((con.cnta_vldebitos),'L999G999G990D00') AS "VL DEBITOS",
				TO_CHAR((con.cnta_vlcreditos),'L999G999G990D00') AS "VL CREDITOS",
				TO_CHAR((con.cnta_vlimpostos),'L999G999G990D00') AS "VL IMPOSTOS",
				TO_CHAR((con.cnta_vlagua+con.cnta_vlesgoto+con.cnta_vldebitos-con.cnta_vlcreditos-con.cnta_vlimpostos),'L999G999G990D00') AS "VALOR",
				'EM ABERTO' AS "STATUS"
			FROM
				faturamento.conta con
				INNER JOIN cadastro.imovel imo ON con.imov_id = imo.imov_id
			WHERE
				con.cnta_amreferenciaconta = (
					SELECT 
						CASE (CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(202312-1 AS TEXT)
						END
					) AND 
				con.dcst_idatual IN (0,1,2) AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con.cnta_id) AND con.cnta_dtrevisao IS NULL
		UNION
			SELECT
				con.imov_id AS "MATRICULA",
				CURRENT_DATE - con.cnta_dtvencimentoconta AS "ATRASO",
				con.cnta_amreferenciaconta AS "REFERENCIA",
				NULL AS "DATA PAGAMENTO",
				con.cnta_dtvencimentoconta AS "VENCIMENTO",
				con.cnta_dtvencimentooriginal AS "VENCIMENTO ORIGINAL",
				CURRENT_DATE - con.cnta_dtvencimentooriginal AS "ATRASO VENCIMENTO ORIGINAL",
				(CASE 
				WHEN CURRENT_DATE - con.cnta_dtvencimentooriginal <= 0 THEN '01 - EM DIA'
				WHEN CURRENT_DATE - con.cnta_dtvencimentooriginal <= 5  THEN '02 - ATE 5 DIAS DE ATRASO'
				WHEN CURRENT_DATE - con.cnta_dtvencimentooriginal <= 15  THEN '03 - ATE 15 DIAS DE ATRASO'
				WHEN CURRENT_DATE - con.cnta_dtvencimentooriginal <= 30  THEN '04 - ATE 30 DIAS DE ATRASO'
				WHEN CURRENT_DATE - con.cnta_dtvencimentooriginal <= 60  THEN '05 - ATE 60 DIAS DE ATRASO'
				WHEN CURRENT_DATE - con.cnta_dtvencimentooriginal <= 90  THEN '06 - ATE 90 DIAS DE ATRASO'
				WHEN CURRENT_DATE - con.cnta_dtvencimentooriginal <= 180  THEN '07 - ATE 180 DIAS DE ATRASO'
				WHEN CURRENT_DATE - con.cnta_dtvencimentooriginal <= 365  THEN '08 - ATE 365 DIAS DE ATRASO'
				WHEN CURRENT_DATE - con.cnta_dtvencimentooriginal <= 1825  THEN '09 - ATE 5 ANOS DE ATRASO'
				WHEN CURRENT_DATE - con.cnta_dtvencimentooriginal <= 3650  THEN '10 - ATE 10 ANOS DE ATRASO'
				WHEN CURRENT_DATE - con.cnta_dtvencimentooriginal > 3650  THEN '11 - ACIMA DE 10 ANOS DE ATRASO'
				END) AS "FAIXA ATRASO",
				con.cnta_nnconsumoagua AS "VOL AGUA",
				con.cnta_nnconsumoesgoto AS "VOL ESGOTO",
				TO_CHAR((con.cnta_vlagua),'L999G999G990D00') AS "VL AGUA",
				TO_CHAR((con.cnta_vlesgoto),'L999G999G990D00') AS "VL ESGOTO",
				TO_CHAR((con.cnta_vldebitos),'L999G999G990D00') AS "VL DEBITOS",
				TO_CHAR((con.cnta_vlcreditos),'L999G999G990D00') AS "VL CREDITOS",
				TO_CHAR((con.cnta_vlimpostos),'L999G999G990D00') AS "VL IMPOSTOS",
				TO_CHAR((con.cnta_vlagua+con.cnta_vlesgoto+con.cnta_vldebitos-con.cnta_vlcreditos-con.cnta_vlimpostos),'L999G999G990D00') AS "VALOR",
				'REVISAO' AS "STATUS"
			FROM
				faturamento.conta con
				INNER JOIN cadastro.imovel imo ON con.imov_id = imo.imov_id
			WHERE
				con.cnta_amreferenciaconta = (
					SELECT 
						CASE (CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(202312-1 AS TEXT)
						END
					) AND 
				NOT con.cnta_dtrevisao IS NULL
		UNION
			SELECT
				con.imov_id AS "MATRICULA",
				COALESCE(par.parc_tmparcelamento::DATE, CURRENT_DATE) - con.cnhi_dtvencimentoconta AS "ATRASO",
				con.cnhi_amreferenciaconta AS "REFERENCIA",
				COALESCE(par.parc_tmparcelamento::DATE, CURRENT_DATE) AS "DATA PAGAMENTO",
				con.cnhi_dtvencimentoconta AS "VENCIMENTO",
				con.cnhi_dtvencimentooriginal AS "VENCIMENTO ORIGINAL",
				COALESCE(par.parc_tmparcelamento::DATE, CURRENT_DATE) - con.cnhi_dtvencimentooriginal AS "ATRASO VENCIMENTO ORIGINAL",
				(CASE 
				WHEN COALESCE(par.parc_tmparcelamento::DATE, CURRENT_DATE) - con.cnhi_dtvencimentooriginal <= 0 THEN '01 - EM DIA'
				WHEN COALESCE(par.parc_tmparcelamento::DATE, CURRENT_DATE) - con.cnhi_dtvencimentooriginal <= 5  THEN '02 - ATE 5 DIAS DE ATRASO'
				WHEN COALESCE(par.parc_tmparcelamento::DATE, CURRENT_DATE) - con.cnhi_dtvencimentooriginal <= 15  THEN '03 - ATE 15 DIAS DE ATRASO'
				WHEN COALESCE(par.parc_tmparcelamento::DATE, CURRENT_DATE) - con.cnhi_dtvencimentooriginal <= 30  THEN '04 - ATE 30 DIAS DE ATRASO'
				WHEN COALESCE(par.parc_tmparcelamento::DATE, CURRENT_DATE) - con.cnhi_dtvencimentooriginal <= 60  THEN '05 - ATE 60 DIAS DE ATRASO'
				WHEN COALESCE(par.parc_tmparcelamento::DATE, CURRENT_DATE) - con.cnhi_dtvencimentooriginal <= 90  THEN '06 - ATE 90 DIAS DE ATRASO'
				WHEN COALESCE(par.parc_tmparcelamento::DATE, CURRENT_DATE) - con.cnhi_dtvencimentooriginal <= 180  THEN '07 - ATE 180 DIAS DE ATRASO'
				WHEN COALESCE(par.parc_tmparcelamento::DATE, CURRENT_DATE) - con.cnhi_dtvencimentooriginal <= 365  THEN '08 - ATE 365 DIAS DE ATRASO'
				WHEN COALESCE(par.parc_tmparcelamento::DATE, CURRENT_DATE) - con.cnhi_dtvencimentooriginal <= 1825  THEN '09 - ATE 5 ANOS DE ATRASO'
				WHEN COALESCE(par.parc_tmparcelamento::DATE, CURRENT_DATE) - con.cnhi_dtvencimentooriginal <= 3650  THEN '10 - ATE 10 ANOS DE ATRASO'
				WHEN COALESCE(par.parc_tmparcelamento::DATE, CURRENT_DATE) - con.cnhi_dtvencimentooriginal > 3650  THEN '11 - ACIMA DE 10 ANOS DE ATRASO'
				END) AS "FAIXA ATRASO",
				con.cnhi_nnconsumoagua AS "VOL AGUA",
				con.cnhi_nnconsumoesgoto AS "VOL ESGOTO",
				TO_CHAR((con.cnhi_vlagua),'L999G999G990D00') AS "VL AGUA",
				TO_CHAR((con.cnhi_vlesgoto),'L999G999G990D00') AS "VL ESGOTO",
				TO_CHAR((con.cnhi_vldebitos),'L999G999G990D00') AS "VL DEBITOS",
				TO_CHAR((con.cnhi_vlcreditos),'L999G999G990D00') AS "VL CREDITOS",
				TO_CHAR((con.cnhi_vlimpostos),'L999G999G990D00') AS "VL IMPOSTOS",
				TO_CHAR((con.cnhi_vlagua+con.cnhi_vlesgoto+con.cnhi_vldebitos-con.cnhi_vlcreditos-con.cnhi_vlimpostos),'L999G999G990D00') AS "VALOR",
				'PARCELADO' AS "STATUS"
			FROM
				faturamento.conta_historico con
				LEFT JOIN cobranca.parcelamento_item pci ON pci.cnta_id = con.cnta_id
				LEFT JOIN cobranca.parcelamento par ON par.parc_id = pci.parc_id
			WHERE
				con.cnhi_amreferenciaconta = (
					SELECT 
						CASE (CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202312 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(202312-1 AS TEXT)
						END
					) AND 
				con.dcst_idatual = 5
		) AS pag_referencia ON pag_referencia."MATRICULA" = imo.imov_id
WHERE
	imo.imov_icexclusao = 2
	--loc.uneg_id >= 11 AND loc.uneg_id <= 15
	 AND une.uneg_id IN (2, 3, 7)
	 AND imo.loca_id IN (201, 363, 701)
	--AND imo.imov_id = 19
ORDER BY "SETOR COMERCIAL","ROTA","QUADRA","SEQUENCIA","SUB LOTE"