--202310: Deve ser substituida pela referencia do faturamento que se deseja obter os dados
--15: Deve ser substituida pelo id da unidade de onde se quer obter os dados

SELECT 
	imo.imov_id AS "Matricula",	
	imo.loca_id AS "Localidade",
	hid.hidr_nnhidrometro AS "Numero Hidrometro",
	hid.hidr_nnanofabricacao AS "Ano Hidrometro",
	his.hidi_dtinstalacaohidrometro AS "Data Instalacao Hidrometro",
	hic.hicp_dshidrometrocapacidade AS "Capacidade Hidrometro",
	hdi.hidm_dshidrometrodiametro AS "Diametro Hidrometro",
	hli.hili_dshidmtlocalinstalacao AS "Local Instalacao Hidrometro",
	mdh.mdhi_dtleitantfatmt AS "Data Leitura Anterior Faturada",
	mdh.mdhi_nnleitantfatmt AS "Leitura Anterior Faturada",
	mdh.mdhi_nnleitantinformada AS "Leitura Anterior Informada",
	mdh.mdhi_dtleituraatualinformada AS "Data Leitura Atual Informada",
	mdh.mdhi_nnleituraatualinformada AS "Leitura Atual Informada",
	mdh.mdhi_dtleituraatualfaturamento AS "Data Leitura Atual Faturada",
	mdh.mdhi_nnleituraatualfaturamento AS "Leitura Atual Faturada",
	mdh.mdhi_nnconsumomedidomes AS "Consumo Medido",
	mdh.mdhi_nnconsumoinformado AS "Consumo Informado",
	mdh.mdhi_nnconsumomediohidrometro AS "Consumo Medio Hidrometro",
	mdh.mdhi_dtleituracampo AS "Data Leitura Campo",
	mdh.mdhi_nnleituracampo AS "Leitura Campo",
	(CASE   mdh.mdhi_icanalisado
		WHEN 1 THEN 'SIM'
		WHEN 2 THEN 'NAO'
		WHEN 3 THEN 'SIM'
		ELSE 'NAO DEFINIDO'
	END) AS "Consumo Analisado?",
	usu.usur_nmusuario AS "Usuario Consistencia",
	lts.ltst_dsleiturasituacao AS "Situacao Leitura",
	lai.ltan_dsleituraanormalidade AS "Anormalidade Leitura Informada",
	laf.ltan_dsleituraanormalidade AS "Anormalidade Leitura Faturada",
	cost_a1.cstp_dsconsumotipo AS "Tipo Consumo Agua",
	cosa_a1.csan_dsconsumoanormalidade AS "Anormalidade Consumo Agua",
	cost_e1.cstp_dsconsumotipo AS "Tipo Consumo Esgoto",
	cosa_e1.csan_dsconsumoanormalidade AS "Anormalidade Consumo Esgoto",
	cosh_a1.cshi_nnconsumomedio AS "Consumo Medio Atual",
	con_ult_fat.sit AS "Status Conta Atual",
	con_ult_fat.impressao AS "Impressao Atual",
	con_ult_fat.cagua AS "Volume Agua Atual",
	TO_CHAR(con_ult_fat.vl_agua, '999G999G990D00') AS "Valor Agua Atual",
	con_ult_fat.cesg AS "Volume Esgoto Atual",
	TO_CHAR(con_ult_fat.vl_esgoto, '999G999G990D00') AS "Valor Esgoto Atual",
	TO_CHAR(con_ult_fat.valor, '999G999G990D00') AS "Valor Atual"
	--con_pen_fat.sit AS "Status Conta Anterior",
	--con_pen_fat.impressao AS "Impressao Anterior",
	--con_pen_fat.cagua AS "Volume Agua Anterior",
	--TO_CHAR(con_pen_fat.vl_agua, '999G999G990D00') AS "Valor Agua Anterior",
	--con_pen_fat.cesg AS "Volume Esgoto Anterior",
	--TO_CHAR(con_pen_fat.vl_esgoto, '999G999G990D00') AS "Valor Esgoto Anterior",
	--TO_CHAR(con_pen_fat.valor, '999G999G990D00') AS "Valor Anterior",
	--con_ant_fat.sit AS "Status Conta Anteanterior",
	--con_ant_fat.impressao AS "Impressao Anteanterior",
	--con_ant_fat.cagua AS "Volume Agua Anteanterior",
	--TO_CHAR(con_ant_fat.vl_agua, '999G999G990D00') AS "Valor Agua Anteanterior",
	--con_ant_fat.cesg AS "Volume Esgoto Anteanterior",
	--TO_CHAR(con_ant_fat.vl_esgoto, '999G999G990D00') AS "Valor Esgoto Anteanterior",
	--TO_CHAR(con_ant_fat.valor, '999G999G990D00') AS "Valor Anteanterior"
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
	LEFT JOIN micromedicao.hidrometro_local_inst hli ON hli.hili_id = his.hili_id
	LEFT JOIN micromedicao.hidrometro hid ON his.hidr_id = hid.hidr_id
	LEFT JOIN micromedicao.hidrometro_capacidade hic ON hic.hicp_id = hid.hicp_id
	LEFT JOIN micromedicao.hidrometro_diametro hdi ON hdi.hidm_id = hid.hidm_id
	LEFT JOIN micromedicao.hidrometro_marca hma ON hma.himc_id = hid.himc_id
	LEFT JOIN cadastro.imovel_cobranca_situacao ics ON ics.imov_id = imo.imov_id AND ics.iscb_dtretiradacobranca IS NULL AND ics.cbst_id IN (12,14,17)
	LEFT JOIN cobranca.cobranca_situacao cob ON cob.cbst_id = ics.cbst_id 
	LEFT JOIN cobranca.cobranca_situacao_hist csh ON csh.imov_id = imo.imov_id AND csh.cbsh_amcobrancaretirada IS NULL
	LEFT JOIN cobranca.cobranca_situacao_tipo cst ON csh.cbsp_id = cst.cbsp_id
	LEFT JOIN cobranca.cobranca_situacao_motivo csm ON csm.cbsm_id = csh.cbsm_id
	LEFT JOIN micromedicao.consumo_historico cosh_a1 ON cosh_a1.imov_id = imo.imov_id AND cosh_a1.cshi_amfaturamento = 202310 AND cosh_a1.lgti_id = 1
	LEFT JOIN micromedicao.consumo_tipo cost_a1 ON cost_a1.cstp_id = cosh_a1.cstp_id
	LEFT JOIN micromedicao.consumo_anormalidade cosa_a1 ON cosa_a1.csan_id = cosh_a1.csan_id
	LEFT JOIN micromedicao.consumo_historico cosh_e1 ON cosh_e1.imov_id = imo.imov_id AND cosh_e1.cshi_amfaturamento = 202310 AND cosh_e1.lgti_id = 2
	LEFT JOIN micromedicao.consumo_tipo cost_e1 ON cost_e1.cstp_id = cosh_e1.cstp_id
	LEFT JOIN micromedicao.consumo_anormalidade cosa_e1 ON cosa_e1.csan_id = cosh_e1.csan_id
	LEFT JOIN micromedicao.medicao_historico mdh ON mdh.lagu_id = imo.imov_id AND mdh.mdhi_amleitura = 202310
	LEFT JOIN micromedicao.leitura_situacao lts ON lts.ltst_id = mdh.ltst_idleiturasituacaoatual
	LEFT JOIN micromedicao.leitura_anormalidade lai ON lai.ltan_id = mdh.ltan_idleitanorminformada
	LEFT JOIN micromedicao.leitura_anormalidade laf ON laf.ltan_id = mdh.ltan_idleitanormfatmt
	LEFT JOIN seguranca.usuario usu ON usu.usur_id = mdh.usur_idalteracao
	LEFT JOIN (	SELECT 
				con4.imov_id AS mat1,
				COUNT(con4.cnta_id) AS qtd,
				MIN(con4.cnta_amreferenciaconta) AS min,
				MAX(con4.cnta_amreferenciaconta) AS max,
				SUM(con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos) AS valor
			FROM faturamento.conta con4 
				INNER JOIN cadastro.localidade loc4 ON loc4.loca_id = con4.loca_id 
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
				INNER JOIN cadastro.localidade loc4 ON loc4.loca_id = con4.loca_id
			WHERE 
				con4.dcst_idatual IN (0,1,2) AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con4.cnta_id) AND con4.cnta_dtvencimentoconta < CURRENT_DATE AND NOT con4.cnta_dtrevisao IS NULL
			GROUP BY 1) AS con_revisao ON con_revisao.mat1 = imo.imov_id
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
				INNER JOIN cadastro.localidade loc4 ON loc4.loca_id = con4.loca_id
			WHERE 
				con4.dcst_idatual IN (0,1,2) AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con4.cnta_id) AND con4.cnta_dtvencimentoconta < CURRENT_DATE AND con4.cnta_dtrevisao IS NULL AND con4.iper_id <> 6
			GROUP BY 1) AS con_atraso ON con_atraso.mat1 = imo.imov_id
	LEFT JOIN (	SELECT 
				con4.imov_id AS mat1,
				COUNT(distinct con4.cnta_id) AS qtd,
				SUM(dco.dbcb_vlprestacao) AS valor
			FROM faturamento.conta con4 
				INNER JOIN faturamento.debito_cobrado dco ON dco.cnta_id = con4.cnta_id AND dco.dbtp_id IN (40,43,44)
				INNER JOIN cadastro.localidade loc4 ON loc4.loca_id = con4.loca_id
			WHERE 
				con4.dcst_idatual IN (0,1,2) AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con4.cnta_id) AND con4.cnta_dtvencimentoconta < CURRENT_DATE AND con4.cnta_dtrevisao IS NULL AND con4.iper_id <> 6
			GROUP BY 1) AS con_parcelamento ON con_parcelamento.mat1 = imo.imov_id
	LEFT JOIN (	SELECT 
				(CASE
				 WHEN NOT cni2.cnta_id IS NULL THEN 'EMITIDA APOS RETENCAO'
				 ELSE 'GRAFICA'
				 END) AS impressao,
				dcs.dcst_dsdebitocreditosituacao AS sit,
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
				LEFT JOIN faturamento.debito_credito_situacao dcs ON dcs.dcst_id = con4.dcst_idatual
				LEFT JOIN faturamento.mov_conta_prefaturada cni2 ON cni2.mcpf_ammovimento = con4.cnta_amreferenciaconta AND cni2.imov_id = con4.imov_id
			WHERE
				con4.cnta_amreferenciaconta = 202310 AND NOT EXISTS (SELECT cni3.cnta_id FROM faturamento.mov_conta_prefaturada cni3 WHERE cni3.cnta_id = con4.cnta_id)
			UNION
			SELECT 
				(CASE
				 WHEN NOT cni2.cnta_id IS NULL THEN 'EMITIDA APOS RETENCAO'
				 ELSE 'GRAFICA'
				 END) AS impressao,
				dcs.dcst_dsdebitocreditosituacao AS sit,
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
				LEFT JOIN faturamento.debito_credito_situacao dcs ON dcs.dcst_id = con4.dcst_idatual
				LEFT JOIN faturamento.mov_conta_prefaturada cni2 ON cni2.mcpf_ammovimento = con4.cnhi_amreferenciaconta AND cni2.imov_id = con4.imov_id
			WHERE
				con4.cnhi_amreferenciaconta = 202310 AND NOT EXISTS (SELECT cni3.cnta_id FROM faturamento.mov_conta_prefaturada cni3 WHERE cni3.cnta_id = con4.cnta_id)
			UNION
			SELECT 
				(CASE
				 WHEN cni.mcpf_icemissaoconta = 1 THEN 'EMITIDA'
				 WHEN cni.mcpf_icemissaoconta = 2 THEN 'RETIDA'
				 ELSE 'NAO IDENTIFICADO'
				 END) AS impressao,
				dcs.dcst_dsdebitocreditosituacao AS sit,
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
				LEFT JOIN faturamento.debito_credito_situacao dcs ON dcs.dcst_id = con4.dcst_idatual
			WHERE
				con4.cnta_amreferenciaconta = 202310
			UNION
			SELECT 
				(CASE
				 WHEN cni.mcpf_icemissaoconta = 1 THEN 'EMITIDA'
				 WHEN cni.mcpf_icemissaoconta = 2 THEN 'RETIDA'
				 ELSE 'NAO IDENTIFICADO'
				 END) AS impressao,
				dcs.dcst_dsdebitocreditosituacao AS sit,
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
				LEFT JOIN faturamento.debito_credito_situacao dcs ON dcs.dcst_id = con4.dcst_idatual
			WHERE
				con4.cnhi_amreferenciaconta = 202310
			) AS con_ult_fat ON con_ult_fat.mat1 = imo.imov_id
	LEFT JOIN (	SELECT 
				(CASE
				 WHEN NOT cni2.cnta_id IS NULL THEN 'EMITIDA APOS RETENCAO'
				 ELSE 'GRAFICA'
				 END) AS impressao,
				dcs.dcst_dsdebitocreditosituacao AS sit,
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
				LEFT JOIN faturamento.debito_credito_situacao dcs ON dcs.dcst_id = con4.dcst_idatual
				LEFT JOIN faturamento.mov_conta_prefaturada cni2 ON cni2.mcpf_ammovimento = con4.cnta_amreferenciaconta AND cni2.imov_id = con4.imov_id
			WHERE
				con4.cnta_amreferenciaconta = (
					SELECT 
						CASE (CAST(SUBSTRING(CAST(202310 AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202310 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(202310-1 AS TEXT)
						END
				) AND NOT EXISTS (SELECT cni3.cnta_id FROM faturamento.mov_conta_prefaturada cni3 WHERE cni3.cnta_id = con4.cnta_id)
			UNION
			SELECT 
				(CASE
				 WHEN NOT cni2.cnta_id IS NULL THEN 'EMITIDA APOS RETENCAO'
				 ELSE 'GRAFICA'
				 END) AS impressao,
				dcs.dcst_dsdebitocreditosituacao AS sit,
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
				LEFT JOIN faturamento.debito_credito_situacao dcs ON dcs.dcst_id = con4.dcst_idatual
				LEFT JOIN faturamento.mov_conta_prefaturada cni2 ON cni2.mcpf_ammovimento = con4.cnhi_amreferenciaconta AND cni2.imov_id = con4.imov_id
			WHERE
				con4.cnhi_amreferenciaconta = (
					SELECT 
						CASE (CAST(SUBSTRING(CAST(202310 AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202310 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(202310-1 AS TEXT)
						END
				) AND NOT EXISTS (SELECT cni3.cnta_id FROM faturamento.mov_conta_prefaturada cni3 WHERE cni3.cnta_id = con4.cnta_id)
			UNION
			SELECT 
				(CASE
				 WHEN cni.mcpf_icemissaoconta = 1 THEN 'EMITIDA'
				 WHEN cni.mcpf_icemissaoconta = 2 THEN 'RETIDA'
				 ELSE 'NAO IDENTIFICADO'
				 END) AS impressao,
				dcs.dcst_dsdebitocreditosituacao AS sit,
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
				LEFT JOIN faturamento.debito_credito_situacao dcs ON dcs.dcst_id = con4.dcst_idatual
			WHERE
				con4.cnta_amreferenciaconta = (
					SELECT 
						CASE (CAST(SUBSTRING(CAST(202310 AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202310 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(202310-1 AS TEXT)
						END
				)
			UNION
			SELECT 
				(CASE
				 WHEN cni.mcpf_icemissaoconta = 1 THEN 'EMITIDA'
				 WHEN cni.mcpf_icemissaoconta = 2 THEN 'RETIDA'
				 ELSE 'NAO IDENTIFICADO'
				 END) AS impressao,
				dcs.dcst_dsdebitocreditosituacao AS sit,
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
				LEFT JOIN faturamento.debito_credito_situacao dcs ON dcs.dcst_id = con4.dcst_idatual
			WHERE
				con4.cnhi_amreferenciaconta = (
					SELECT 
						CASE (CAST(SUBSTRING(CAST(202310 AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202310 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(202310-1 AS TEXT)
						END
				)
			) AS con_pen_fat ON con_pen_fat.mat1 = imo.imov_id
		LEFT JOIN (	SELECT 
				(CASE
				 WHEN NOT cni2.cnta_id IS NULL THEN 'EMITIDA APOS RETENCAO'
				 ELSE 'GRAFICA'
				 END) AS impressao,
				dcs.dcst_dsdebitocreditosituacao AS sit,
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
				LEFT JOIN faturamento.debito_credito_situacao dcs ON dcs.dcst_id = con4.dcst_idatual
				LEFT JOIN faturamento.mov_conta_prefaturada cni2 ON cni2.mcpf_ammovimento = con4.cnta_amreferenciaconta AND cni2.imov_id = con4.imov_id
			WHERE
				con4.cnta_amreferenciaconta = (
					SELECT 
						CASE (CAST(SUBSTRING(CAST(202310 AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202310 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'11'
							WHEN 2 THEN CAST((CAST(SUBSTRING(CAST(202310 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(202310-2 AS TEXT)
						END
				) AND NOT EXISTS (SELECT cni3.cnta_id FROM faturamento.mov_conta_prefaturada cni3 WHERE cni3.cnta_id = con4.cnta_id)
			UNION
			SELECT 
				(CASE
				 WHEN NOT cni2.cnta_id IS NULL THEN 'EMITIDA APOS RETENCAO'
				 ELSE 'GRAFICA'
				 END) AS impressao,
				dcs.dcst_dsdebitocreditosituacao AS sit,
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
				LEFT JOIN faturamento.debito_credito_situacao dcs ON dcs.dcst_id = con4.dcst_idatual
				LEFT JOIN faturamento.mov_conta_prefaturada cni2 ON cni2.mcpf_ammovimento = con4.cnhi_amreferenciaconta AND cni2.imov_id = con4.imov_id
			WHERE
				con4.cnhi_amreferenciaconta = (
					SELECT 
						CASE (CAST(SUBSTRING(CAST(202310 AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202310 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'11'
							WHEN 2 THEN CAST((CAST(SUBSTRING(CAST(202310 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(202310-2 AS TEXT)
						END
				) AND NOT EXISTS (SELECT cni3.cnta_id FROM faturamento.mov_conta_prefaturada cni3 WHERE cni3.cnta_id = con4.cnta_id)
			UNION
			SELECT 
				(CASE
				 WHEN cni.mcpf_icemissaoconta = 1 THEN 'EMITIDA'
				 WHEN cni.mcpf_icemissaoconta = 2 THEN 'RETIDA'
				 ELSE 'NAO IDENTIFICADO'
				 END) AS impressao,
				dcs.dcst_dsdebitocreditosituacao AS sit,
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
				LEFT JOIN faturamento.debito_credito_situacao dcs ON dcs.dcst_id = con4.dcst_idatual
			WHERE
				con4.cnta_amreferenciaconta = (
					SELECT 
						CASE (CAST(SUBSTRING(CAST(202310 AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202310 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'11'
							WHEN 2 THEN CAST((CAST(SUBSTRING(CAST(202310 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(202310-2 AS TEXT)
						END
				)
			UNION
			SELECT 
				(CASE
				 WHEN cni.mcpf_icemissaoconta = 1 THEN 'EMITIDA'
				 WHEN cni.mcpf_icemissaoconta = 2 THEN 'RETIDA'
				 ELSE 'NAO IDENTIFICADO'
				 END) AS impressao,
				dcs.dcst_dsdebitocreditosituacao AS sit,
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
				LEFT JOIN faturamento.debito_credito_situacao dcs ON dcs.dcst_id = con4.dcst_idatual
			WHERE
				con4.cnhi_amreferenciaconta = (
					SELECT 
						CASE (CAST(SUBSTRING(CAST(202310 AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202310 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'11'
							WHEN 2 THEN CAST((CAST(SUBSTRING(CAST(202310 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(202310-2 AS TEXT)
						END
				)
			) AS con_ant_fat ON con_ant_fat.mat1 = imo.imov_id
WHERE
	imo.imov_icexclusao = 2 AND con_ult_fat.valor>0 AND imo.imov_id IN (
4201140,
3524035,
3524019,
3524515,
4201132,
4201124,
14773945,
4201116,
883565,
883727,
4200829,
4200810,
4200799,
4200810,
4200772,
3417255,
4200756,
3524302,
883310,
3524248,
3524493,
4200713,
883255,
3524396,
14797780,
14637545,
13577670,
13675893,
14170078,
14170051,
14797704,
14170035,
13886622,
14170019,
14797720,
14797747,
14797763,
11288833,
10195483,
10195548,
10195599,
10195440,
10195386,
4200799,
7050470,
883824,
883948,
883816)
ORDER BY "Matricula"