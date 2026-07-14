SELECT 
	DISTINCT imo.imov_id AS "MATRICULA",
	cli.clie_nmcliente AS "NOME",
	cli.clie_nncpf AS "CPF",
	cli.clie_nncnpj AS "CNPJ",
	(CASE cli.clie_iccpfcnpjvalidado
	WHEN 0 THEN 'NAO'
	WHEN 1 THEN 'SIM'
	ELSE 'NAO'
	END) AS "DOC VALIDADO",
	(
		SELECT
			STRING_AGG('('||cfn.cfon_cdddd||')'||cfn.cfon_nnfone,' | ')
		FROM
			cadastro.cliente_fone cfn
			INNER JOIN cadastro.cliente cli2 ON cli2.clie_id = cfn.clie_id
			INNER JOIN cadastro.cliente_imovel cim2 ON cim2.clie_id = cli2.clie_id AND cim2.clim_dtrelacaofim IS NULL AND cim2.imov_id = imo.imov_id
	) AS "TELEFONES",
	cli2.clie_id AS "COD RESP",
	cli2.clie_nmcliente AS "NOME RESP",
	cli2.clie_nncpf AS "CPF RESP",
	cli2.clie_nncnpj AS "CNPJ RESP",
	cli3.clie_id AS "COD PAI",
	cli3.clie_nmcliente AS "NOME PAI",
	cli3.clie_nncpf AS "CPF PAI",
	cli3.clie_nncnpj AS "CNPJ PAI",
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
	ftg_alternativo.ftgr_dsfaturamentogrupo AS "GRUPO FAT ALTERNATIVO",
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
	lagu.lagu_dtcorte AS "DT. CORTE",
	lagu.lagu_dtsupressaoagua AS "DT. SUPRESSAO",
	imo.lest_id AS "ID SIT. ESG",
	les.lest_dsligacaoesgotosituacao AS "SITUACAO ESGOTO",
	imo.imov_nnareaconstruida AS "AREA",
	CAST(fat.ftst_id  AS TEXT) || ' - ' || fat.ftst_dsfaturamentosituacaotipo AS "SIT. FATURAMENTO",
	fsh.ftsh_amfatmtsitinicio AS "INICIO",
	fsh.ftsh_amfaturamentosituacaofim AS "FIM",
	ftm.ftsm_dsfatsitmotivo AS "MOTIVO",
	cst.cbsp_id AS "COD SIT.",
	CAST(cst.cbsp_id AS TEXT) || ' - ' || cst.cbsp_dscobrancasituacaotipo AS "SIT. ESPECIAL DE COBRANCA",
	csh.cbsh_amcobrancasituacaoinicio AS "INICIO",
	csh.cbsh_amcobrancasituacaofim AS "FIM",
	csm.cbsm_dscobrancasituacaomotivo AS "MOTIVO",
	csh.cbsh_dsobservacaoinforma AS "OBS",
	hid.hidr_nnhidrometro AS "NR HID.",
	his.hidi_dtinstalacaohidrometro AS "DATA DE INSTALACAO HD.",
	hic.hicp_dshidrometrocapacidade AS "CAPACIDADE HD",
	hdi.hidm_dshidrometrodiametro AS "DIAMETRO HD",
        mdh.mdhi_dtleitantfatmt AS "DATA LEIT ANTERIOR FATURADA",
	mdh.mdhi_nnleitantfatmt AS "LEIT ANTERIOR FATURADA",
	mdh.mdhi_nnleitantinformada AS "LEIT ANTERIOR INFORMADA",
	mdh.mdhi_dtleituraatualinformada AS "DATA LEIT ATUAL INFORMADA",
	mdh.mdhi_nnleituraatualinformada AS "LEIT ATUAL INFORMADA",
	mdh.mdhi_dtleituraatualfaturamento AS "DATA LEIT ATUAL FATURADA",
	mdh.mdhi_nnleituraatualfaturamento AS "LEIT ATUAL FATURADA",
	mdh.mdhi_nnconsumomedidomes AS "CONSUMO MEDIDO",
	mdh.mdhi_nnconsumoinformado AS "CONSUMO INFORMADO",
	mdh.mdhi_nnconsumomediohidrometro AS "CONSUMO MEDIO HD",
	mdh.mdhi_dtleituracampo AS "DATA DA LEITURA CAMPO",
	mdh.mdhi_nnleituracampo AS "LEITURA DE CAMPO",
	mdh.mdhi_icanalisado AS "IC ANALISADO",
	(CASE   mdh.mdhi_icanalisado
		WHEN 1 THEN '2 VEZES'
		WHEN 2 THEN 'NAO'
		WHEN 3 THEN '1 VEZ'
		ELSE 'NAO DEFINIDO'
	END) AS "CONSUMO ANALISADO?",
	cost_a1.cstp_dsconsumotipo AS "TIPO CONSUMO AGUA",
	cosa_a1.csan_dsconsumoanormalidade AS "ANORM CONS AGUA",
	cost_e1.cstp_dsconsumotipo AS "TIPO CONSUMO ESGOTO",
	cosa_e1.csan_dsconsumoanormalidade AS "ANORM CONS ESGOTO",
	cosh_a1.cshi_nnconsumomedio AS "CONSUMO MEDIO AGUA EM ${VAR_REFERENCIA}",
	cob.cbst_dscobrancasituacao AS "SIT. COBRANCA",
	cob.cbst_dscobrancasituacao AS "SIT. COBRANCA",
	ics.iscb_dtimplantacaocobranca AS "DATA DE ENTRADA COBRANCA",
	TO_CHAR(con_ult_fat.cagua, '999G999G990D00') AS "VOL AG ${VAR_REFERENCIA}",
	TO_CHAR(con_ult_fat.vl_agua, '999G999G990D00') AS "VL AG ${VAR_REFERENCIA}",
	con_ult_fat.cesg AS "VOL ES ${VAR_REFERENCIA}",
	con_ult_fat.vl_esgoto AS "VL ES ${VAR_REFERENCIA}",
	TO_CHAR(con_ult_fat.vl_debitos, '999G999G990D00') AS "OUTROS SERVICOS ${VAR_REFERENCIA}",
	TO_CHAR(con_ult_fat.vl_creditos, '999G999G990D00') AS "CRED ${VAR_REFERENCIA}",
	TO_CHAR(con_ult_fat.vl_impostos, '999G999G990D00') AS "IMPOSTOS ${VAR_REFERENCIA}",
	TO_CHAR(con_ult_fat.valor, '999G999G990D00') AS "VALOR ${VAR_REFERENCIA}",
	TO_CHAR(con_pen_fat.cagua, '999G999G990D00') AS "VOL AG ${VAR_REFERENCIA} - 1",
	TO_CHAR(con_pen_fat.vl_agua, '999G999G990D00') AS "VL AG ${VAR_REFERENCIA} - 1",
	TO_CHAR(con_pen_fat.cesg, '999G999G990D00') AS "VOL ES ${VAR_REFERENCIA} - 1",
	TO_CHAR(con_pen_fat.vl_esgoto, '999G999G990D00') AS "VL ES ${VAR_REFERENCIA} - 1",
	TO_CHAR(con_pen_fat.vl_debitos, '999G999G990D00') AS "OUTROS SERVICOS ${VAR_REFERENCIA} - 1",
	TO_CHAR(con_pen_fat.vl_creditos, '999G999G990D00') AS "CRED ${VAR_REFERENCIA} - 1",
	TO_CHAR(con_pen_fat.vl_impostos, '999G999G990D00') AS "IMPOSTOS ${VAR_REFERENCIA} - 1",
	TO_CHAR(con_pen_fat.valor, '999G999G990D00') AS "VALOR ${VAR_REFERENCIA} - 1",
	TO_CHAR(con_ant_fat.cagua, '999G999G990D00') AS "VOL AG ${VAR_REFERENCIA} - 2",
	TO_CHAR(con_ant_fat.vl_agua, '999G999G990D00') AS "VL AG ${VAR_REFERENCIA} - 2",
	TO_CHAR(con_ant_fat.cesg, '999G999G990D00') AS "VOL ES ${VAR_REFERENCIA} - 2",
	TO_CHAR(con_ant_fat.vl_esgoto, '999G999G990D00') AS "VL ES ${VAR_REFERENCIA} - 2",
	TO_CHAR(con_ant_fat.vl_debitos, '999G999G990D00') AS "OUTROS SERVICOS ${VAR_REFERENCIA} - 2",
	TO_CHAR(con_ant_fat.vl_creditos, '999G999G990D00') AS "CRED ${VAR_REFERENCIA} - 2",
	TO_CHAR(con_ant_fat.vl_impostos, '999G999G990D00') AS "IMPOSTOS ${VAR_REFERENCIA} - 2",
	TO_CHAR(con_ant_fat.valor, '999G999G990D00') AS "VALOR ${VAR_REFERENCIA} - 2",
	TO_CHAR(con_vivaagua.valor, '999G999G990D00') AS "VALOR TOTAL VIVA AGUA",
	con_vivaagua.qtd AS "QTD. CONTAS VIVA AGUA",
	TO_CHAR(con_vivaagua.min, '999G999G990D00') AS "MENOR REFERENCIA VIVA AGUA",
	con_vivaagua.max AS "MAIOR REFERENCIA VIVA AGUA",
	TO_CHAR(con_revisao.valor, '999G999G990D00') AS "VALOR TOTAL EM REVISAO",
	con_revisao.qtd AS "QTD. CONTAS REVISAO",
	con_revisao.min AS "MENOR REFERENCIA REVISAO",
	con_revisao.max AS "MAIOR REFERENCIA REVISAO",
	con_parcelamento.qtd AS "QTD PARCELAMENTO ATRASADO",
	TO_CHAR(con_parcelamento.valor, '999G999G990D00') AS "VALOR PARCELAMENTO ATRASADO",
	TO_CHAR(con_atraso.vl_agua, '999G999G990D00') AS "VALOR AGUA DEVIDO",
	TO_CHAR(con_atraso.vl_esgoto, '999G999G990D00') AS "VALOR ESGOTO DEVIDO",
	TO_CHAR(con_atraso.vl_debitos, '999G999G990D00') AS "VALOR DEBITOS DEVIDO",
	TO_CHAR(con_atraso.vl_creditos, '999G999G990D00') AS "VALOR CREDITOS DEVIDO",
	TO_CHAR(con_atraso.vl_impostos, '999G999G990D00') AS "VALOR IMPOSTOS DEVIDO",
	TO_CHAR(con_atraso.valor, '999G999G990D00') AS "VALOR TOTAL DEVIDO",
	con_atraso.qtd AS "QTD. CONTAS DEVIDO",
	con_atraso.min AS "MENOR REFERENCIA DEVIDO",
	con_atraso.max AS "MAIOR REFERENCIA DEVIDO",
	con_atraso.min_venc AS "MENOR VENCIMENTO",
	con_atraso.max_venc AS "MAIOR VENCIMENTO",
	pag_contas.ultpag AS "ULTIMO PAGAMENTO ATUAL",
	pag_contas.qtd AS "ULTIMO QTD PAGAMENTO ATUAL",
	TO_CHAR(pag_contas.valor, '999G999G990D00') AS "ULTIMO VALOR ATUAL",
	imo.imov_cddebitoautomatico AS "CD DEBITO AUT",
	imo.imov_icdebitoconta AS "IND DEB EM CONTA",
	debacob.qtdpar AS "QTD TOTAL PARCELAS",
	debacob.parcelas AS "QTD PARCELAS A COBRAR",
	TO_CHAR(debacob.valor, '999G999G990D00') AS "VALOR TOTAL CONTRATO",
	debacob.valor_prest AS "VALOR PARCELA",
	debacop.valor_pend AS "VALOR DEVIDO PARCELAMENTO",
	debacob.valor_pend AS "VALOR DEB A COBRAR",
	debguia.valor AS "DEBITO GUIAS",
	TO_CHAR((con_atraso.multas+con_atraso.juros), '999G999G990D00')  AS "ACRESCIMOS POR ATRASO"
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
	LEFT JOIN micromedicao.rota rota_alternativa ON rota_alternativa.rota_id = imo.rota_idalternativa
	LEFT JOIN faturamento.faturamento_grupo ftg_alternativo ON rota_alternativa.ftgr_id = ftg_alternativo.ftgr_id
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
	LEFT JOIN micromedicao.consumo_historico cosh_a1 ON cosh_a1.imov_id = imo.imov_id AND cosh_a1.cshi_amfaturamento = ${VAR_REFERENCIA} AND cosh_a1.lgti_id = 1
	LEFT JOIN micromedicao.consumo_tipo cost_a1 ON cost_a1.cstp_id = cosh_a1.cstp_id
	LEFT JOIN micromedicao.consumo_anormalidade cosa_a1 ON cosa_a1.csan_id = cosh_a1.csan_id
	LEFT JOIN micromedicao.consumo_historico cosh_e1 ON cosh_e1.imov_id = imo.imov_id AND cosh_e1.cshi_amfaturamento = ${VAR_REFERENCIA} AND cosh_e1.lgti_id = 2
	LEFT JOIN micromedicao.consumo_tipo cost_e1 ON cost_e1.cstp_id = cosh_e1.cstp_id
	LEFT JOIN micromedicao.consumo_anormalidade cosa_e1 ON cosa_e1.csan_id = cosh_e1.csan_id	
        LEFT JOIN micromedicao.medicao_historico mdh ON mdh.hidi_id = his.hidi_id AND mdh.mdhi_amleitura = ${VAR_REFERENCIA}	
	LEFT JOIN cadastro.imovel_cobranca_situacao ics ON ics.imov_id = imo.imov_id AND ics.iscb_dtretiradacobranca IS NULL AND ics.cbst_id IN (12,14,17)
	LEFT JOIN cobranca.cobranca_situacao cob ON cob.cbst_id = ics.cbst_id 
	LEFT JOIN cobranca.cobranca_situacao_hist csh ON csh.imov_id = imo.imov_id AND csh.cbsh_amcobrancaretirada IS NULL
	LEFT JOIN cobranca.cobranca_situacao_tipo cst ON csh.cbsp_id = cst.cbsp_id
	LEFT JOIN cobranca.cobranca_situacao_motivo csm ON csm.cbsm_id = csh.cbsm_id
	LEFT JOIN (	SELECT 
				con4.imov_id AS mat1,
				COUNT(con4.cnta_id) AS qtd,
				MIN(con4.cnta_amreferenciaconta) AS min,
				MAX(con4.cnta_amreferenciaconta) AS max,
				SUM(con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos) AS valor
			FROM faturamento.conta con4 
				INNER JOIN cadastro.localidade loc4 ON loc4.loca_id = con4.loca_id AND loc4.greg_id IN (1,2) 
			WHERE 
				con4.dcst_idatual IN (0,1,2) AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con4.cnta_id) AND con4.cnta_dtvencimentoconta <= CURRENT_DATE AND con4.cnta_amreferenciaconta > 201309 AND con4.iper_id = 6
			GROUP BY 1) AS con_vivaagua ON con_vivaagua.mat1 = imo.imov_id
	LEFT JOIN (	SELECT 
				con4.imov_id AS mat1,
				COUNT(con4.cnta_id) AS qtd,
				MIN(con4.cnta_amreferenciaconta) AS min,
				MAX(con4.cnta_amreferenciaconta) AS max,
				SUM(con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos) AS valor
			FROM faturamento.conta con4 
				INNER JOIN cadastro.localidade loc4 ON loc4.loca_id = con4.loca_id AND loc4.greg_id IN (1,2)
			WHERE 
				con4.dcst_idatual IN (0,1,2) AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con4.cnta_id) AND con4.cnta_dtvencimentoconta <= CURRENT_DATE AND con4.cnta_amreferenciaconta > 201309 AND NOT con4.cnta_dtrevisao IS NULL
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
				SUM(con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos) AS valor,
				SUM(TRUNC(((con4.cnta_vlagua+con4.cnta_vlesgoto-con4.cnta_vlcreditos-con4.cnta_vlimpostos)*0.02)+((con4.cnta_vldebitos)*0.0074)::NUMERIC,2)) AS multas,
				SUM(TRUNC(((con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos)*0.005*(((EXTRACT(YEAR FROM CURRENT_DATE::DATE)-EXTRACT(YEAR FROM con4.cnta_dtvencimentoconta))*12)+(EXTRACT(MONTH FROM CURRENT_DATE::DATE)-EXTRACT(MONTH FROM con4.cnta_dtvencimentoconta))))::NUMERIC,2)) AS juros
			FROM faturamento.conta con4 
				INNER JOIN cadastro.localidade loc4 ON loc4.loca_id = con4.loca_id AND loc4.greg_id IN (1,2)
			WHERE 
				con4.dcst_idatual IN (0,1,2) AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con4.cnta_id) AND con4.cnta_dtvencimentoconta <= CURRENT_DATE AND con4.cnta_amreferenciaconta > 201309 AND con4.cnta_dtrevisao IS NULL AND con4.iper_id <> 6
			GROUP BY 1) AS con_atraso ON con_atraso.mat1 = imo.imov_id
	LEFT JOIN (	SELECT 
				con4.imov_id AS mat1,
				COUNT(distinct con4.cnta_id) AS qtd,
				SUM(dco.dbcb_vlprestacao) AS valor
			FROM faturamento.conta con4 
				INNER JOIN faturamento.debito_cobrado dco ON dco.cnta_id = con4.cnta_id AND dco.dbtp_id IN (40,43,44)
				INNER JOIN cadastro.localidade loc4 ON loc4.loca_id = con4.loca_id AND loc4.greg_id IN (1,2)
			WHERE 
				con4.dcst_idatual IN (0,1,2) AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con4.cnta_id) AND con4.cnta_dtvencimentoconta <= CURRENT_DATE AND con4.cnta_amreferenciaconta > 201309 AND con4.cnta_dtrevisao IS NULL AND con4.iper_id <> 6
			GROUP BY 1) AS con_parcelamento ON con_parcelamento.mat1 = imo.imov_id
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
				INNER JOIN cadastro.localidade loc4 ON loc4.loca_id = con4.loca_id AND loc4.greg_id IN (1,2)
			WHERE
				con4.cnta_amreferenciaconta = ${VAR_REFERENCIA}
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
				INNER JOIN cadastro.localidade loc4 ON loc4.loca_id = con4.loca_id AND loc4.greg_id IN (1,2)
			WHERE
				con4.cnhi_amreferenciaconta = ${VAR_REFERENCIA}
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
				INNER JOIN cadastro.localidade loc4 ON loc4.loca_id = con4.loca_id AND loc4.greg_id IN (1,2)
			WHERE
				con4.cnta_amreferenciaconta = (
					SELECT 
						CASE (CAST(SUBSTRING(CAST(${VAR_REFERENCIA} AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(${VAR_REFERENCIA} AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(${VAR_REFERENCIA}-1 AS TEXT)
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
				INNER JOIN cadastro.localidade loc4 ON loc4.loca_id = con4.loca_id AND loc4.greg_id IN (1,2)
			WHERE
				con4.cnhi_amreferenciaconta = (
					SELECT 
						CASE (CAST(SUBSTRING(CAST(${VAR_REFERENCIA} AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(${VAR_REFERENCIA} AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(${VAR_REFERENCIA}-1 AS TEXT)
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
				INNER JOIN cadastro.localidade loc4 ON loc4.loca_id = con4.loca_id AND loc4.greg_id IN (1,2)
			WHERE
				con4.cnta_amreferenciaconta = (
					SELECT 
						CASE (CAST(SUBSTRING(CAST(${VAR_REFERENCIA} AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(${VAR_REFERENCIA} AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'11'
							WHEN 2 THEN CAST((CAST(SUBSTRING(CAST(${VAR_REFERENCIA} AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(${VAR_REFERENCIA}-2 AS TEXT)
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
				INNER JOIN cadastro.localidade loc4 ON loc4.loca_id = con4.loca_id AND loc4.greg_id IN (1,2)
			WHERE
				con4.cnhi_amreferenciaconta = (
					SELECT 
						CASE (CAST(SUBSTRING(CAST(${VAR_REFERENCIA} AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(${VAR_REFERENCIA} AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'11'
							WHEN 2 THEN CAST((CAST(SUBSTRING(CAST(${VAR_REFERENCIA} AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(${VAR_REFERENCIA}-2 AS TEXT)
						END
				)
			) AS con_ant_fat ON con_ant_fat.mat1 = imo.imov_id
	LEFT JOIN (	SELECT 
				pag4.imov_id AS mat1,
				pag4.pgmt_dtpagamento AS ultpag,
				COUNT(pag4.pgmt_id) AS qtd,
				SUM(pag4.pgmt_vlpagamento) AS valor
			FROM
				arrecadacao.pagamento pag4
			WHERE 
				pag4.pgst_idatual IN (0,1) AND pag4.pgmt_dtpagamento  >= CURRENT_DATE - INTERVAL '40d'
			GROUP BY 1,2) AS pag_contas ON pag_contas.mat1 = imo.imov_id
	LEFT JOIN (	SELECT 
				dcp.imov_id AS mat1,
				SUM(dcp.dbac_nnprestacaodebito) AS qtdpar,
				SUM(dcp.dbac_nnprestacaodebito-dcp.dbac_nnprestacaocobradas) AS parcelas,
				SUM(dcp.dbac_vldebito) AS valor,
				TO_CHAR(SUM(dcp.dbac_vldebito/dcp.dbac_nnprestacaodebito), '999999999D00') AS valor_prest,
				TO_CHAR(SUM((dcp.dbac_vldebito/dcp.dbac_nnprestacaodebito)*(dcp.dbac_nnprestacaodebito-dcp.dbac_nnprestacaocobradas)),'999999999D00') AS valor_pend
			FROM 
				faturamento.debito_a_cobrar dcp
			WHERE
				dcp.dbtp_id = 9152
								
			GROUP BY 1) AS debacop ON debacop.mat1 = imo.imov_id			
	LEFT JOIN (	SELECT 
				dco.imov_id AS mat1,
				SUM(dco.dbac_nnprestacaodebito) AS qtdpar,
				SUM(dco.dbac_nnprestacaodebito-dco.dbac_nnprestacaocobradas) AS parcelas,
				SUM(dco.dbac_vldebito) AS valor,
				TO_CHAR(SUM(dco.dbac_vldebito/dco.dbac_nnprestacaodebito), '999999999D00') AS valor_prest,
				TO_CHAR(SUM((dco.dbac_vldebito/dco.dbac_nnprestacaodebito)*(dco.dbac_nnprestacaodebito-dco.dbac_nnprestacaocobradas)),'999999999D00') AS valor_pend
			FROM 
				faturamento.debito_a_cobrar dco
			WHERE
				dco.dbtp_id <> 9152
								
			GROUP BY 1) AS debacob ON debacob.mat1 = imo.imov_id
	LEFT JOIN (	SELECT 
				dgp.imov_id AS mat1,
				dgp.gpag_id AS npag,
				TO_CHAR(SUM(dgp.gpag_vldebito), '999999999D00') AS valor
			FROM 
				faturamento.guia_pagamento dgp
			WHERE 
				dgp.dcst_idatual IN (0,1,2) AND NOT EXISTS ( SELECT pag.gpag_id FROM arrecadacao.pagamento pag WHERE pag.gpag_id = dgp.gpag_id) AND dgp.gpag_dtvencimento <= CURRENT_DATE
			GROUP BY 1,2) AS debguia ON debguia.mat1 = imo.imov_id			
WHERE
	imo.imov_icexclusao = 2 
	AND (cli.clie_id IN (47020,
42130,
43020,
44040,
46180,
44080,
46420,
47200,
47030,
42050,
46150,
42360,
11630721,
48040,
48250,
43240,
45110,
49020,
48300,
45070,
44430,
46050,
47060,
42020,
42070,
45040,
47250,
43310,
46230,
43710,
48050,
43700,
42010,
47090,
42060,
45030,
44410,
44110,
47080,
49030,
42100,
44050,
45210,
49040,
43720,
49050,
49060,
49070,
49160,
46170,
49080,
43030,
48310,
48070,
44150,
47010,
48010,
45270,
47040,
49250,
44120,
44170,
44160,
44290,
45120,
43730,
42040,
46460,
42080,
43090,
48090,
45180,
48100,
43190,
46080,
47070,
48110,
42400,
45200,
46030,
43390,
45090,
42140,
46440,
44010,
43680,
43010,
44330,
46020,
43630,
46060,
48140,
44130,
43620,
49010,
48150,
48160,
48320,
47190,
48330,
45170,
49100,
43080,
46010,
46090,
46140,
48170,
42030,
49110,
42110,
43060,
42090,
45190,
49120,
45260,
47050,
45130,
43150,
45010,
49130,
100,
44030,
48180,
47260,
45150,
43070,
46430,
49180,
47100,
45050,
45250,
47210,
44300,
44020,
46160,
49150,
42350,
42120,
42410,
46260,
46500,
46070) OR cli2.clie_id IN (47020,
42130,
43020,
44040,
46180,
44080,
46420,
47200,
47030,
42050,
46150,
42360,
11630721,
48040,
48250,
43240,
45110,
49020,
48300,
45070,
44430,
46050,
47060,
42020,
42070,
45040,
47250,
43310,
46230,
43710,
48050,
43700,
42010,
47090,
42060,
45030,
44410,
44110,
47080,
49030,
42100,
44050,
45210,
49040,
43720,
49050,
49060,
49070,
49160,
46170,
49080,
43030,
48310,
48070,
44150,
47010,
48010,
45270,
47040,
49250,
44120,
44170,
44160,
44290,
45120,
43730,
42040,
46460,
42080,
43090,
48090,
45180,
48100,
43190,
46080,
47070,
48110,
42400,
45200,
46030,
43390,
45090,
42140,
46440,
44010,
43680,
43010,
44330,
46020,
43630,
46060,
48140,
44130,
43620,
49010,
48150,
48160,
48320,
47190,
48330,
45170,
49100,
43080,
46010,
46090,
46140,
48170,
42030,
49110,
42110,
43060,
42090,
45190,
49120,
45260,
47050,
45130,
43150,
45010,
49130,
100,
44030,
48180,
47260,
45150,
43070,
46430,
49180,
47100,
45050,
45250,
47210,
44300,
44020,
46160,
49150,
42350,
42120,
42410,
46260,
46500,
46070) OR cli3.clie_id IN (47020,
42130,
43020,
44040,
46180,
44080,
46420,
47200,
47030,
42050,
46150,
42360,
11630721,
48040,
48250,
43240,
45110,
49020,
48300,
45070,
44430,
46050,
47060,
42020,
42070,
45040,
47250,
43310,
46230,
43710,
48050,
43700,
42010,
47090,
42060,
45030,
44410,
44110,
47080,
49030,
42100,
44050,
45210,
49040,
43720,
49050,
49060,
49070,
49160,
46170,
49080,
43030,
48310,
48070,
44150,
47010,
48010,
45270,
47040,
49250,
44120,
44170,
44160,
44290,
45120,
43730,
42040,
46460,
42080,
43090,
48090,
45180,
48100,
43190,
46080,
47070,
48110,
42400,
45200,
46030,
43390,
45090,
42140,
46440,
44010,
43680,
43010,
44330,
46020,
43630,
46060,
48140,
44130,
43620,
49010,
48150,
48160,
48320,
47190,
48330,
45170,
49100,
43080,
46010,
46090,
46140,
48170,
42030,
49110,
42110,
43060,
42090,
45190,
49120,
45260,
47050,
45130,
43150,
45010,
49130,
100,
44030,
48180,
47260,
45150,
43070,
46430,
49180,
47100,
45050,
45250,
47210,
44300,
44020,
46160,
49150,
42350,
42120,
42410,
46260,
46500,
46070))	
	
ORDER BY "LOCALIDADE","SETOR COMERCIAL","ROTA","QUADRA","SEQUENCIA","SUB LOTE"