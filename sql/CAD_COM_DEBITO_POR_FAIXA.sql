SELECT 
	imo.imov_id AS "MATRICULA",
	cli.clie_nmcliente AS "NOME",
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
	--TO_CHAR(con_atraso.vl_agua, '999G999G990D00') AS "VALOR AGUA DEVIDO",
	--TO_CHAR(con_atraso.vl_esgoto, '999G999G990D00') AS "VALOR ESGOTO DEVIDO",
	--TO_CHAR(con_atraso.vl_debitos, '999G999G990D00') AS "VALOR DEBITOS DEVIDO",
	--TO_CHAR(con_atraso.vl_creditos, '999G999G990D00') AS "VALOR CREDITOS DEVIDO",
	--TO_CHAR(con_atraso.vl_impostos, '999G999G990D00') AS "VALOR IMPOSTOS DEVIDO",
	TO_CHAR(con_atraso.valor, '999G999G990D00') AS "VALOR TOTAL DEVIDO",
	TO_CHAR(con_atraso.multa, '999G999G990D00') AS "MULTAS",
	TO_CHAR(con_atraso.juros, '999G999G990D00') AS "JUROS DE MORA",
	TO_CHAR(con_atraso.multa+con_atraso.juros, '999G999G990D00') AS "TOTAL ACRESCIMOS",
	TO_CHAR(con_atraso.valor+con_atraso.multa+con_atraso.juros, '999G999G990D00') AS "VALOR TOTAL COM ACRESCIMOSDEVIDO",
	--con_atraso.qtd AS "QTD. CONTAS DEVIDO",
	--con_atraso.min AS "MENOR REFERENCIA DEVIDO",
	--con_atraso.max AS "MAIOR REFERENCIA DEVIDO",
	--con_atraso.min_venc AS "MENOR VENCIMENTO",
	--con_atraso.max_venc AS "MAIOR VENCIMENTO",
	CURRENT_DATE - con_atraso.data_venc AS "DIAS DE ATRASO",
	--TO_CHAR(ROUND((CURRENT_DATE - con_atraso.data_venc) / 30.44)::INT, 'FM9999') || ' MESES' AS "TMP ATRASO MENOR VENCIMENTO"
	con_atraso.intervalo_atraso AS "TMP ATRASO MENOR VENCIMENTO"
FROM 
	cadastro.imovel imo
	INNER JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
	INNER JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
        INNER JOIN cadastro.cliente_tipo clitp ON clitp.cltp_id = cli.cltp_id	
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
	LEFT JOIN atendimentopublico.ligacao_agua_diametro lgd ON lgd.lagd_id = lagu.lagd_id
	LEFT JOIN micromedicao.hidrometro_inst_hist his ON lagu.hidi_id = his.hidi_id AND his.hidi_dtretiradahidrometro IS NULL
	LEFT JOIN micromedicao.hidrometro hid ON his.hidr_id = hid.hidr_id
	LEFT JOIN micromedicao.hidrometro_capacidade hic ON hic.hicp_id = hid.hicp_id
	LEFT JOIN micromedicao.hidrometro_diametro hdi ON hdi.hidm_id = hid.hidm_id
	LEFT JOIN micromedicao.hidrometro_marca hma ON hma.himc_id = hid.himc_id
	LEFT JOIN cadastro.imovel_cobranca_situacao ics ON ics.imov_id = imo.imov_id AND ics.iscb_dtretiradacobranca IS NULL AND ics.cbst_id IN (12,14,17)
	LEFT JOIN cadastro.imovel_cobranca_situacao ics_exi ON ics_exi.imov_id = imo.imov_id AND ics_exi.iscb_dtretiradacobranca IS NULL AND ics_exi.cbst_id = 23
	LEFT JOIN cobranca.cobranca_situacao cob ON cob.cbst_id = ics.cbst_id 
	LEFT JOIN cobranca.cobranca_situacao cob_exi ON cob_exi.cbst_id = ics_exi.cbst_id 
	LEFT JOIN cobranca.cobranca_situacao_hist csh ON csh.imov_id = imo.imov_id AND csh.cbsh_amcobrancaretirada IS NULL
	LEFT JOIN cobranca.cobranca_situacao_tipo cst ON csh.cbsp_id = cst.cbsp_id
	LEFT JOIN cobranca.cobranca_situacao_motivo csm ON csm.cbsm_id = csh.cbsm_id
	LEFT JOIN micromedicao.consumo_historico cosh_a1 ON cosh_a1.imov_id = imo.imov_id AND cosh_a1.cshi_amfaturamento = ${VAR_REFERENCIA} AND cosh_a1.lgti_id = 1
	LEFT JOIN micromedicao.consumo_tipo cost_a1 ON cost_a1.cstp_id = cosh_a1.cstp_id

	LEFT JOIN micromedicao.consumo_anormalidade cosa_a1 ON cosa_a1.csan_id = cosh_a1.csan_id
	LEFT JOIN micromedicao.consumo_historico cosh_e1 ON cosh_e1.imov_id = imo.imov_id AND cosh_e1.cshi_amfaturamento = ${VAR_REFERENCIA} AND cosh_e1.lgti_id = 2
	LEFT JOIN micromedicao.consumo_tipo cost_e1 ON cost_e1.cstp_id = cosh_e1.cstp_id
	LEFT JOIN micromedicao.consumo_anormalidade cosa_e1 ON cosa_e1.csan_id = cosh_e1.csan_id
	
	LEFT JOIN micromedicao.medicao_historico mdh ON mdh.hidi_id = his.hidi_id AND mdh.mdhi_amleitura = ${VAR_REFERENCIA}
	LEFT JOIN micromedicao.leitura_situacao lts ON lts.ltst_id = mdh.ltst_idleiturasituacaoatual
	LEFT JOIN micromedicao.leitura_anormalidade lai ON lai.ltan_id = mdh.ltan_idleitanorminformada
	LEFT JOIN micromedicao.leitura_anormalidade laf ON laf.ltan_id = mdh.ltan_idleitanormfatmt
	LEFT JOIN seguranca.usuario usu ON usu.usur_id = mdh.usur_idalteracao
	LEFT JOIN (	SELECT 
				con4.imov_id AS mat1,
				CASE
					WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, con4.cnta_dtvencimentoconta)) * 12 +
					EXTRACT(MONTH FROM AGE(CURRENT_DATE, con4.cnta_dtvencimentoconta)) BETWEEN 2 AND 36 THEN '2 meses a 3 anos'
					WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, con4.cnta_dtvencimentoconta)) * 12 +
					EXTRACT(MONTH FROM AGE(CURRENT_DATE, con4.cnta_dtvencimentoconta)) BETWEEN 37 AND 60 THEN '3 a 5 anos'
					WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, con4.cnta_dtvencimentoconta)) * 12 +
					EXTRACT(MONTH FROM AGE(CURRENT_DATE, con4.cnta_dtvencimentoconta)) > 60 THEN 'maior que 5 anos'
				END AS intervalo_atraso,
				--con4.cnta_amreferenciaconta as refer,
				--con4.cnta_dtvencimentoconta AS data_venc,
				SUM(con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos) AS valor,
				SUM(TRUNC(((con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos)*0.02)::NUMERIC,2)) AS multa,
				SUM(TRUNC(((con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos)*0.005*(((EXTRACT(YEAR FROM CURRENT_DATE::DATE)-EXTRACT(YEAR FROM con4.cnta_dtvencimentoconta))*12)+(EXTRACT(MONTH FROM CURRENT_DATE::DATE)-EXTRACT(MONTH FROM con4.cnta_dtvencimentoconta))))::NUMERIC, 2)) AS juros
			FROM faturamento.conta con4 
			WHERE 
				con4.dcst_idatual IN (0,1,2) AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con4.cnta_id) AND con4.cnta_dtvencimentoconta < CURRENT_DATE AND con4.cnta_dtrevisao IS NULL AND con4.iper_id <> 6
			GROUP BY 1,2,3) AS con_atraso ON con_atraso.mat1 = imo.imov_id
WHERE
	imo.imov_icexclusao = 2
	AND con_atraso.valor > 0
	--AND imo.imov_id = 12281972
	AND con_atraso.intervalo_atraso = ${VAR_INTERVALO1}
	AND une.uneg_id IN (${VAR_UNIDADE})
UNION
SELECT 
	imo.imov_id AS "MATRICULA",
	cli.clie_nmcliente AS "NOME",
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
	--TO_CHAR(con_atraso.vl_agua, '999G999G990D00') AS "VALOR AGUA DEVIDO",
	--TO_CHAR(con_atraso.vl_esgoto, '999G999G990D00') AS "VALOR ESGOTO DEVIDO",
	--TO_CHAR(con_atraso.vl_debitos, '999G999G990D00') AS "VALOR DEBITOS DEVIDO",
	--TO_CHAR(con_atraso.vl_creditos, '999G999G990D00') AS "VALOR CREDITOS DEVIDO",
	--TO_CHAR(con_atraso.vl_impostos, '999G999G990D00') AS "VALOR IMPOSTOS DEVIDO",
	TO_CHAR(con_atraso.valor, '999G999G990D00') AS "VALOR TOTAL DEVIDO",
	TO_CHAR(con_atraso.multa, '999G999G990D00') AS "MULTAS",
	TO_CHAR(con_atraso.juros, '999G999G990D00') AS "JUROS DE MORA",
	TO_CHAR(con_atraso.multa+con_atraso.juros, '999G999G990D00') AS "TOTAL ACRESCIMOS",
	TO_CHAR(con_atraso.valor+con_atraso.multa+con_atraso.juros, '999G999G990D00') AS "VALOR TOTAL COM ACRESCIMOSDEVIDO",
	--con_atraso.qtd AS "QTD. CONTAS DEVIDO",
	--con_atraso.min AS "MENOR REFERENCIA DEVIDO",
	--con_atraso.max AS "MAIOR REFERENCIA DEVIDO",
	--con_atraso.min_venc AS "MENOR VENCIMENTO",
	--con_atraso.max_venc AS "MAIOR VENCIMENTO",
	CURRENT_DATE - con_atraso.data_venc AS "DIAS DE ATRASO",
	--TO_CHAR(ROUND((CURRENT_DATE - con_atraso.data_venc) / 30.44)::INT, 'FM9999') || ' MESES' AS "TMP ATRASO MENOR VENCIMENTO"
	con_atraso.intervalo_atraso AS "TMP ATRASO MENOR VENCIMENTO"
FROM 
	cadastro.imovel imo
	INNER JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
	INNER JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
    INNER JOIN cadastro.cliente_tipo clitp ON clitp.cltp_id = cli.cltp_id	
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
	LEFT JOIN atendimentopublico.ligacao_agua_diametro lgd ON lgd.lagd_id = lagu.lagd_id
	LEFT JOIN micromedicao.hidrometro_inst_hist his ON lagu.hidi_id = his.hidi_id AND his.hidi_dtretiradahidrometro IS NULL
	LEFT JOIN micromedicao.hidrometro hid ON his.hidr_id = hid.hidr_id
	LEFT JOIN micromedicao.hidrometro_capacidade hic ON hic.hicp_id = hid.hicp_id
	LEFT JOIN micromedicao.hidrometro_diametro hdi ON hdi.hidm_id = hid.hidm_id
	LEFT JOIN micromedicao.hidrometro_marca hma ON hma.himc_id = hid.himc_id
	LEFT JOIN cadastro.imovel_cobranca_situacao ics ON ics.imov_id = imo.imov_id AND ics.iscb_dtretiradacobranca IS NULL AND ics.cbst_id IN (12,14,17)
	LEFT JOIN cadastro.imovel_cobranca_situacao ics_exi ON ics_exi.imov_id = imo.imov_id AND ics_exi.iscb_dtretiradacobranca IS NULL AND ics_exi.cbst_id = 23
	LEFT JOIN cobranca.cobranca_situacao cob ON cob.cbst_id = ics.cbst_id 
	LEFT JOIN cobranca.cobranca_situacao cob_exi ON cob_exi.cbst_id = ics_exi.cbst_id 
	LEFT JOIN cobranca.cobranca_situacao_hist csh ON csh.imov_id = imo.imov_id AND csh.cbsh_amcobrancaretirada IS NULL
	LEFT JOIN cobranca.cobranca_situacao_tipo cst ON csh.cbsp_id = cst.cbsp_id
	LEFT JOIN cobranca.cobranca_situacao_motivo csm ON csm.cbsm_id = csh.cbsm_id
	LEFT JOIN micromedicao.consumo_historico cosh_a1 ON cosh_a1.imov_id = imo.imov_id AND cosh_a1.cshi_amfaturamento = ${VAR_REFERENCIA} AND cosh_a1.lgti_id = 1
	LEFT JOIN micromedicao.consumo_tipo cost_a1 ON cost_a1.cstp_id = cosh_a1.cstp_id

	LEFT JOIN micromedicao.consumo_anormalidade cosa_a1 ON cosa_a1.csan_id = cosh_a1.csan_id
	LEFT JOIN micromedicao.consumo_historico cosh_e1 ON cosh_e1.imov_id = imo.imov_id AND cosh_e1.cshi_amfaturamento = ${VAR_REFERENCIA} AND cosh_e1.lgti_id = 2
	LEFT JOIN micromedicao.consumo_tipo cost_e1 ON cost_e1.cstp_id = cosh_e1.cstp_id
	LEFT JOIN micromedicao.consumo_anormalidade cosa_e1 ON cosa_e1.csan_id = cosh_e1.csan_id
	
	LEFT JOIN micromedicao.medicao_historico mdh ON mdh.hidi_id = his.hidi_id AND mdh.mdhi_amleitura = ${VAR_REFERENCIA}
	LEFT JOIN micromedicao.leitura_situacao lts ON lts.ltst_id = mdh.ltst_idleiturasituacaoatual
	LEFT JOIN micromedicao.leitura_anormalidade lai ON lai.ltan_id = mdh.ltan_idleitanorminformada
	LEFT JOIN micromedicao.leitura_anormalidade laf ON laf.ltan_id = mdh.ltan_idleitanormfatmt
	LEFT JOIN seguranca.usuario usu ON usu.usur_id = mdh.usur_idalteracao
	LEFT JOIN (	SELECT 
				con4.imov_id AS mat1,
				CASE
					WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, con4.cnta_dtvencimentoconta)) * 12 +
					EXTRACT(MONTH FROM AGE(CURRENT_DATE, con4.cnta_dtvencimentoconta)) BETWEEN 2 AND 36 THEN '2 meses a 3 anos'
					WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, con4.cnta_dtvencimentoconta)) * 12 +
					EXTRACT(MONTH FROM AGE(CURRENT_DATE, con4.cnta_dtvencimentoconta)) BETWEEN 37 AND 60 THEN '3 a 5 anos'
					WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, con4.cnta_dtvencimentoconta)) * 12 +
					EXTRACT(MONTH FROM AGE(CURRENT_DATE, con4.cnta_dtvencimentoconta)) > 60 THEN 'maior que 5 anos'
				END AS intervalo_atraso,
				--con4.cnta_amreferenciaconta as refer,
				--con4.cnta_dtvencimentoconta AS data_venc,
				SUM(con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos) AS valor,
				SUM(TRUNC(((con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos)*0.02)::NUMERIC,2)) AS multa,
				SUM(TRUNC(((con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos)*0.005*(((EXTRACT(YEAR FROM CURRENT_DATE::DATE)-EXTRACT(YEAR FROM con4.cnta_dtvencimentoconta))*12)+(EXTRACT(MONTH FROM CURRENT_DATE::DATE)-EXTRACT(MONTH FROM con4.cnta_dtvencimentoconta))))::NUMERIC, 2)) AS juros
			FROM faturamento.conta con4 
			WHERE 
				con4.dcst_idatual IN (0,1,2) AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con4.cnta_id) AND con4.cnta_dtvencimentoconta < CURRENT_DATE AND con4.cnta_dtrevisao IS NULL AND con4.iper_id <> 6
			GROUP BY 1,2,3) AS con_atraso ON con_atraso.mat1 = imo.imov_id			
WHERE
	imo.imov_icexclusao = 2
	AND con_atraso.valor > 0
	--AND imo.imov_id = 12281972
	AND con_atraso.intervalo_atraso = ${VAR_INTERVALO2}
	AND une.uneg_id IN (${VAR_UNIDADE})
UNION
SELECT 
	imo.imov_id AS "MATRICULA",
	cli.clie_nmcliente AS "NOME",
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
	--TO_CHAR(con_atraso.vl_agua, '999G999G990D00') AS "VALOR AGUA DEVIDO",
	--TO_CHAR(con_atraso.vl_esgoto, '999G999G990D00') AS "VALOR ESGOTO DEVIDO",
	--TO_CHAR(con_atraso.vl_debitos, '999G999G990D00') AS "VALOR DEBITOS DEVIDO",
	--TO_CHAR(con_atraso.vl_creditos, '999G999G990D00') AS "VALOR CREDITOS DEVIDO",
	--TO_CHAR(con_atraso.vl_impostos, '999G999G990D00') AS "VALOR IMPOSTOS DEVIDO",
	TO_CHAR(con_atraso.valor, '999G999G990D00') AS "VALOR TOTAL DEVIDO",
	TO_CHAR(con_atraso.multa, '999G999G990D00') AS "MULTAS",
	TO_CHAR(con_atraso.juros, '999G999G990D00') AS "JUROS DE MORA",
	TO_CHAR(con_atraso.multa+con_atraso.juros, '999G999G990D00') AS "TOTAL ACRESCIMOS",
	TO_CHAR(con_atraso.valor+con_atraso.multa+con_atraso.juros, '999G999G990D00') AS "VALOR TOTAL COM ACRESCIMOSDEVIDO",
	--con_atraso.qtd AS "QTD. CONTAS DEVIDO",
	--con_atraso.min AS "MENOR REFERENCIA DEVIDO",
	--con_atraso.max AS "MAIOR REFERENCIA DEVIDO",
	--con_atraso.min_venc AS "MENOR VENCIMENTO",
	--con_atraso.max_venc AS "MAIOR VENCIMENTO",
	CURRENT_DATE - con_atraso.data_venc AS "DIAS DE ATRASO",
	--TO_CHAR(ROUND((CURRENT_DATE - con_atraso.data_venc) / 30.44)::INT, 'FM9999') || ' MESES' AS "TMP ATRASO MENOR VENCIMENTO"
	con_atraso.intervalo_atraso AS "TMP ATRASO MENOR VENCIMENTO"
FROM 
	cadastro.imovel imo
	INNER JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
	INNER JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
        INNER JOIN cadastro.cliente_tipo clitp ON clitp.cltp_id = cli.cltp_id	
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
	LEFT JOIN atendimentopublico.ligacao_agua_diametro lgd ON lgd.lagd_id = lagu.lagd_id
	LEFT JOIN micromedicao.hidrometro_inst_hist his ON lagu.hidi_id = his.hidi_id AND his.hidi_dtretiradahidrometro IS NULL
	LEFT JOIN micromedicao.hidrometro hid ON his.hidr_id = hid.hidr_id
	LEFT JOIN micromedicao.hidrometro_capacidade hic ON hic.hicp_id = hid.hicp_id
	LEFT JOIN micromedicao.hidrometro_diametro hdi ON hdi.hidm_id = hid.hidm_id
	LEFT JOIN micromedicao.hidrometro_marca hma ON hma.himc_id = hid.himc_id
	LEFT JOIN cadastro.imovel_cobranca_situacao ics ON ics.imov_id = imo.imov_id AND ics.iscb_dtretiradacobranca IS NULL AND ics.cbst_id IN (12,14,17)
	LEFT JOIN cadastro.imovel_cobranca_situacao ics_exi ON ics_exi.imov_id = imo.imov_id AND ics_exi.iscb_dtretiradacobranca IS NULL AND ics_exi.cbst_id = 23
	LEFT JOIN cobranca.cobranca_situacao cob ON cob.cbst_id = ics.cbst_id 
	LEFT JOIN cobranca.cobranca_situacao cob_exi ON cob_exi.cbst_id = ics_exi.cbst_id 
	LEFT JOIN cobranca.cobranca_situacao_hist csh ON csh.imov_id = imo.imov_id AND csh.cbsh_amcobrancaretirada IS NULL
	LEFT JOIN cobranca.cobranca_situacao_tipo cst ON csh.cbsp_id = cst.cbsp_id
	LEFT JOIN cobranca.cobranca_situacao_motivo csm ON csm.cbsm_id = csh.cbsm_id
	LEFT JOIN micromedicao.consumo_historico cosh_a1 ON cosh_a1.imov_id = imo.imov_id AND cosh_a1.cshi_amfaturamento = ${VAR_REFERENCIA} AND cosh_a1.lgti_id = 1
	LEFT JOIN micromedicao.consumo_tipo cost_a1 ON cost_a1.cstp_id = cosh_a1.cstp_id

	LEFT JOIN micromedicao.consumo_anormalidade cosa_a1 ON cosa_a1.csan_id = cosh_a1.csan_id
	LEFT JOIN micromedicao.consumo_historico cosh_e1 ON cosh_e1.imov_id = imo.imov_id AND cosh_e1.cshi_amfaturamento = ${VAR_REFERENCIA} AND cosh_e1.lgti_id = 2
	LEFT JOIN micromedicao.consumo_tipo cost_e1 ON cost_e1.cstp_id = cosh_e1.cstp_id
	LEFT JOIN micromedicao.consumo_anormalidade cosa_e1 ON cosa_e1.csan_id = cosh_e1.csan_id
	
	LEFT JOIN micromedicao.medicao_historico mdh ON mdh.hidi_id = his.hidi_id AND mdh.mdhi_amleitura = ${VAR_REFERENCIA}
	LEFT JOIN micromedicao.leitura_situacao lts ON lts.ltst_id = mdh.ltst_idleiturasituacaoatual
	LEFT JOIN micromedicao.leitura_anormalidade lai ON lai.ltan_id = mdh.ltan_idleitanorminformada
	LEFT JOIN micromedicao.leitura_anormalidade laf ON laf.ltan_id = mdh.ltan_idleitanormfatmt
	LEFT JOIN seguranca.usuario usu ON usu.usur_id = mdh.usur_idalteracao
	LEFT JOIN (	SELECT 
				con4.imov_id AS mat1,
				CASE
					WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, con4.cnta_dtvencimentoconta)) * 12 +
					EXTRACT(MONTH FROM AGE(CURRENT_DATE, con4.cnta_dtvencimentoconta)) BETWEEN 2 AND 36 THEN '2 meses a 3 anos'
					WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, con4.cnta_dtvencimentoconta)) * 12 +
					EXTRACT(MONTH FROM AGE(CURRENT_DATE, con4.cnta_dtvencimentoconta)) BETWEEN 37 AND 60 THEN '3 a 5 anos'
					WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, con4.cnta_dtvencimentoconta)) * 12 +
					EXTRACT(MONTH FROM AGE(CURRENT_DATE, con4.cnta_dtvencimentoconta)) > 60 THEN 'maior que 5 anos'
				END AS intervalo_atraso,
				--con4.cnta_amreferenciaconta as refer,
				--con4.cnta_dtvencimentoconta AS data_venc,
				SUM(con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos) AS valor,
				SUM(TRUNC(((con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos)*0.02)::NUMERIC,2)) AS multa,
				SUM(TRUNC(((con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos)*0.005*(((EXTRACT(YEAR FROM CURRENT_DATE::DATE)-EXTRACT(YEAR FROM con4.cnta_dtvencimentoconta))*12)+(EXTRACT(MONTH FROM CURRENT_DATE::DATE)-EXTRACT(MONTH FROM con4.cnta_dtvencimentoconta))))::NUMERIC, 2)) AS juros
			FROM faturamento.conta con4 
			WHERE 
				con4.dcst_idatual IN (0,1,2) AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con4.cnta_id) AND con4.cnta_dtvencimentoconta < CURRENT_DATE AND con4.cnta_dtrevisao IS NULL AND con4.iper_id <> 6
			GROUP BY 1,2,3) AS con_atraso ON con_atraso.mat1 = imo.imov_id			
WHERE
	imo.imov_icexclusao = 2
	AND con_atraso.valor > 0
	--AND imo.imov_id = 12281972
	AND con_atraso.intervalo_atraso = ${VAR_INTERVALO3}
	AND une.uneg_id IN (${VAR_UNIDADE})
