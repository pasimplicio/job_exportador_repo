--202103: Deve ser substituida pela referencia do faturamento que se deseja obter os dados
--2,3,4,5,6,7,8,9,10,11,12,13,14,15: Deve ser substituida pelo id da unidade de onde se quer obter os dados

SELECT 
        TO_CHAR(COALESCE(((CASE cli.clie_iccpfcnpjvalidado
	 WHEN 1 THEN 0.9
	 ELSE 0.3
	 END)*
	(CASE ftb.ftab_id
	 WHEN 1 THEN 1.0
	 WHEN 3 THEN 0.7
	 ELSE 0.5
	 END)*
	(CASE 
	 WHEN hid.hidr_id IS NULL THEN 0.25
	 ELSE 0.5
	 END)*
	 (10.0/con_atraso.qtd::FLOAT) * 100),0)::NUMERIC,'9990D000') AS score_corte,
	(imo.loca_id::TEXT || '-' || sec.stcm_cdsetorcomercial::TEXT || '-' || rot.rota_cdrota::TEXT) AS "LOCALIZACAO",
	imo.imov_id AS "MATRICULA",
	(CASE imo.imov_icdebitoconta
	WHEN 2 THEN 'NAO'
	ELSE 'SIM'
	END) AS "DEBITO AUTOMATICO",
	imo.imov_nncoordenadax AS "LATITUDE",
	imo.imov_nncoordenaday AS "LONGITUDE",
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
	(
		SELECT
			'('||cfn.cfon_cdddd||')'||cfn.cfon_nnfone
		FROM
			cadastro.cliente_fone cfn
		WHERE 
			cfn.cfon_icfonepadrao = 1 AND cfn.clie_id = cli.clie_id
		LIMIT 1
	) AS "TELEFONE PADRAO TITULAR",
	(
		SELECT
			'('||cfn.cfon_cdddd||')'||cfn.cfon_nnfone
		FROM
			cadastro.cliente_fone cfn
		WHERE 
			cfn.clie_id = cli.clie_id AND cfn.cfon_id = (SELECT MAX(cfn2.cfon_id) FROM cadastro.cliente_fone cfn2 WHERE cfn2.clie_id = cli.clie_id)
		LIMIT 1
	) AS "TELEFONE MAIS RECENTE TITULAR",
	(
		SELECT
			'('||cfn.cfon_cdddd||')'||cfn.cfon_nnfone
		FROM
			cadastro.cliente_fone cfn
		WHERE 
			cfn.clie_id = cli.clie_id 
			AND LEFT(cfn.cfon_nnfone,1) = '9'
			AND cfn.cfon_id = (SELECT MAX(cfn2.cfon_id) FROM cadastro.cliente_fone cfn2 WHERE cfn2.clie_id = cli.clie_id AND LEFT(cfn2.cfon_nnfone,1) = '9')
		LIMIT 1
	) AS "CELULAR MAIS RECENTE TITULAR",
	(
		SELECT
			'('||cfn.cfon_cdddd||')'||cfn.cfon_nnfone
		FROM
			cadastro.cliente_fone cfn
		WHERE 
			cfn.clie_id = cli.clie_id 
			AND LEFT(cfn.cfon_nnfone,1) = '9'
			AND cfn.cfon_cdddd IN ('98','99')
			AND cfn.cfon_id = (SELECT MAX(cfn2.cfon_id) FROM cadastro.cliente_fone cfn2 WHERE cfn2.clie_id = cli.clie_id AND LEFT(cfn2.cfon_nnfone,1) = '9' AND cfn2.cfon_cdddd IN ('98','99'))
		LIMIT 1
	) AS "CELULAR MAIS RECENTE DDD MA",
	cli.clie_dsemail AS "EMAIL",
	TO_CHAR(cli.clie_dtnascimento,'DD/MM/YYYY') AS "DT NASCIMENTO",
	cli.clie_nnmae AS "NOME DA MAE",
	sex.psex_dspessoasexo AS "SEXO",
	cim.clim_dtrelacaoinicio AS "INICIO DA RELACAO",
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
	dis.diop_dsdistritooperacional AS "DISTR OPERACIONAL",
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
	lgd.lagd_dsligacaoaguadiametro AS "DIAMETRO LIG AGUA",
	lagu.lagu_dtimplantacao AS "DT. IMPLANTACAO",
	lagu.lagu_dtligacaoagua AS "DT. LIGACAO",
	lagu.lagu_dtcorte AS "DT. CORTE",
	lagu.lagu_dtreligacaoagua AS "DT. RELIGACAO",
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
	hid.hidr_nnanofabricacao AS "ANO HD",
	his.hidi_dtinstalacaohidrometro AS "DATA DE INSTALACAO HD.",
	hic.hicp_dshidrometrocapacidade AS "CAPACIDADE HD",
	hdi.hidm_dshidrometrodiametro AS "DIAMETRO HD",
	cob.cbst_dscobrancasituacao AS "SIT. COBRANCA",
	ics.iscb_dtimplantacaocobranca AS "DATA DE ENTRADA COBRANCA",
	cob_exi.cbst_dscobrancasituacao AS "SIT. COBRANCA",
	ics_exi.iscb_dtimplantacaocobranca AS "DATA DE ENTRADA COBRANCA",
	lts.ltst_dsleiturasituacao AS "SITUACAO LEITURA",
	lai.ltan_dsleituraanormalidade AS "ANORM LEIT INF",
	laf.ltan_dsleituraanormalidade AS "ANORM LEIT FAT",
	cost_a1.cstp_dsconsumotipo AS "TIPO CONSUMO AGUA",
	cosa_a1.csan_dsconsumoanormalidade AS "ANORM CONS AGUA",
	mdh.mdhi_nnconsumomedidomes AS "CONSUMO MEDIDO",
	mdh.mdhi_nnconsumoinformado AS "CONSUMO INFORMADO",
	mdh.mdhi_nnconsumomediohidrometro AS "CONSUMO MEDIO HD",
	con_ult_fat.cagua AS "VOL AG 202103",
	TO_CHAR(con_ult_fat.vl_agua, '999G999G990D00') AS "VL AG 202103",
	con_ult_fat.cesg AS "VOL ES 202103",
	TO_CHAR(con_ult_fat.vl_esgoto, '999G999G990D00') AS "VL ES 202103",
	TO_CHAR(con_ult_fat.vl_debitos, '999G999G990D00') AS "OUTROS SERVICOS 202103",
	TO_CHAR(con_ult_fat.vl_creditos, '999G999G990D00') AS "CRED 202103",
	TO_CHAR(con_ult_fat.vl_impostos, '999G999G990D00') AS "IMPOSTOS 202103",
	TO_CHAR(con_ult_fat.valor, '999G999G990D00') AS "VALOR 202103",
	con_pen_fat.cagua AS "VOL AG 202103 - 1",
	TO_CHAR(con_pen_fat.vl_agua, '999G999G990D00') AS "VL AG 202103 - 1",
	con_pen_fat.cesg AS "VOL ES 202103 - 1",
	TO_CHAR(con_pen_fat.vl_esgoto, '999G999G990D00') AS "VL ES 202103 - 1",
	TO_CHAR(con_pen_fat.vl_debitos, '999G999G990D00') AS "OUTROS SERVICOS 202103 - 1",
	TO_CHAR(con_pen_fat.vl_creditos, '999G999G990D00') AS "CRED 202103 - 1",
	TO_CHAR(con_pen_fat.vl_impostos, '999G999G990D00') AS "IMPOSTOS 202103 - 1",
	TO_CHAR(con_pen_fat.valor, '999G999G990D00') AS "VALOR 202103 - 1",
	con_ant_fat.cagua AS "VOL AG 202103 - 2",
	TO_CHAR(con_ant_fat.vl_agua, '999G999G990D00') AS "VL AG 202103 - 2",
	con_ant_fat.cesg AS "VOL ES 202103 - 2",
	TO_CHAR(con_ant_fat.vl_esgoto, '999G999G990D00') AS "VL ES 202103 - 2",
	TO_CHAR(con_ant_fat.vl_debitos, '999G999G990D00') AS "OUTROS SERVICOS 202103 - 2",
	TO_CHAR(con_ant_fat.vl_creditos, '999G999G990D00') AS "CRED 202103 - 2",
	TO_CHAR(con_ant_fat.vl_impostos, '999G999G990D00') AS "IMPOSTOS 202103 - 2",
	TO_CHAR(con_ant_fat.valor, '999G999G990D00') AS "VALOR 202103 - 2",
	TO_CHAR(con_vivaagua.valor, '999G999G990D00') AS "VALOR TOTAL VIVA AGUA",
	con_vivaagua.qtd AS "QTD. CONTAS VIVA AGUA",
	con_vivaagua.min AS "MENOR REFERENCIA VIVA AGUA",
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
	TO_CHAR(con_cobranca.vl_agua, '999G999G990D00') AS "VALOR AGUA EMP COB",
	TO_CHAR(con_cobranca.vl_esgoto, '999G999G990D00') AS "VALOR ESGOTO EMP COB",
	TO_CHAR(con_cobranca.vl_debitos, '999G999G990D00') AS "VALOR DEBITOS EMP COB",
	TO_CHAR(con_cobranca.vl_creditos, '999G999G990D00') AS "VALOR CREDITOS EMP COB",
	TO_CHAR(con_cobranca.vl_impostos, '999G999G990D00') AS "VALOR IMPOSTOS EMP COB",
	TO_CHAR(con_cobranca.valor, '999G999G990D00') AS "VALOR TOTAL EMP COB",
	con_cobranca.qtd AS "QTD. CONTAS EMP COB",
	con_cobranca.min AS "MENOR REFERENCIA EMP COB",
	con_cobranca.max AS "MAIOR REFERENCIA EMP COB",
	con_cobranca.min_venc AS "MENOR VENCIMENTO EMP COB",
	con_cobranca.max_venc AS "MAIOR VENCIMENTO EMP COB",
	TO_CHAR(con_revisao_decreto.valor, '999G999G990D00') AS "VALOR TOTAL ISENTO",
	TO_CHAR(con_revisao_decreto.outros, '999G999G990D00') AS "VALOR SERVICOS ADIADO",
	TO_CHAR(con_revisao_decreto.creditos, '999G999G990D00') AS "VALOR CREDITOS ADIADO",
	con_revisao_decreto.qtd AS "QTD. CONTAS INSENTO",
	con_revisao_decreto.min AS "MENOR REFERENCIA ISENTA",
	con_revisao_decreto.max AS "MAIOR REFERENCIA ISENTA",
	--TO_CHAR(ult_alt_cli.ult_alt, 'DD/MM/YYYY')
	TO_CHAR((
			SELECT
				MIN(opf.opef_tmultimaalteracao) AS ult_alt
			FROM
				seguranca.tabela_linha_alteracao tbl
				INNER JOIN seguranca.operacao_efetuada opf ON opf.opef_id = tbl.tref_id
				INNER JOIN seguranca.tab_linha_col_alteracao tbc ON tbl.tbla_id = tbc.tbla_id
			WHERE
				--tbl.tabe_id = 60
				--tbc.tbca_cncolunaanterior <> tbc.tbca_cncolunaatual
				--AND 
				tbc.tbco_id IN (271, 272, 275, 276, 701, 60, 4796, 23848, 23850, 1527, 1529, 1531, 1539, 2524, 2525, 2526, 2527, 2529)
				--AND tbc.tbca_tmultimaalteracao >= (CURRENT_DATE::TIMESTAMP)
				--AND usu.usur_nmlogin = 'YGOR'
				AND opf.opef_cnargumento = cli.clie_id
	),'DD/MM/YYYY') AS "ULTIMA ALTERACAO CADASTRO",
	TO_CHAR(pags_ult.valor, '999G999G990D00') AS "VALOR PAGO 202103",
	pags_ult.qtd AS "QTD DOC PAGOS 202103",
	TO_CHAR(pags_pen.valor, '999G999G990D00') AS "VALOR PAGO 202103 - 1",
	pags_pen.qtd AS "QTD DOC PAGOS 202103 - 1",
	TO_CHAR(pags_ant.valor, '999G999G990D00') AS "VALOR PAGO 202103 - 2",
	pags_ant.qtd AS "QTD DOC PAGOS 202103 - 2",
	TO_CHAR(pags_antp.valor, '999G999G990D00') AS "VALOR PAGO 202103 - 3",
	pags_antp.qtd AS "QTD DOC PAGOS 202103 - 3",
	TO_CHAR(pags_antant.valor, '999G999G990D00') AS "VALOR PAGO 202103 - 4",
	pags_antant.qtd AS "QTD DOC PAGOS 202103 - 4"
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
	LEFT JOIN micromedicao.consumo_historico cosh_a1 ON cosh_a1.imov_id = imo.imov_id AND cosh_a1.cshi_amfaturamento = 202103 AND cosh_a1.lgti_id = 1
	LEFT JOIN micromedicao.consumo_tipo cost_a1 ON cost_a1.cstp_id = cosh_a1.cstp_id
	LEFT JOIN micromedicao.consumo_anormalidade cosa_a1 ON cosa_a1.csan_id = cosh_a1.csan_id
	LEFT JOIN micromedicao.medicao_historico mdh ON mdh.hidi_id = his.hidi_id AND mdh.mdhi_amleitura = 202103
	LEFT JOIN micromedicao.leitura_situacao lts ON lts.ltst_id = mdh.ltst_idleiturasituacaoatual
	LEFT JOIN micromedicao.leitura_anormalidade lai ON lai.ltan_id = mdh.ltan_idleitanorminformada
	LEFT JOIN micromedicao.leitura_anormalidade laf ON laf.ltan_id = mdh.ltan_idleitanormfatmt
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
				SUM(con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos) AS valor
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
				con4.cnta_amreferenciaconta = 202103
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
				con4.cnhi_amreferenciaconta = 202103
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
				con4.cnta_amreferenciaconta = 202103
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
				con4.cnhi_amreferenciaconta = 202103
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
						CASE (CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(202103-1 AS TEXT)
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
						CASE (CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(202103-1 AS TEXT)
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
						CASE (CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(202103-1 AS TEXT)
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
						CASE (CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(202103-1 AS TEXT)
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
						CASE (CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'11'
							WHEN 2 THEN CAST((CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(202103-2 AS TEXT)
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
						CASE (CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'11'
							WHEN 2 THEN CAST((CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(202103-2 AS TEXT)
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
						CASE (CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'11'
							WHEN 2 THEN CAST((CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(202103-2 AS TEXT)
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
						CASE (CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 5 FOR 6) AS INT))
							WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'11'
							WHEN 2 THEN CAST((CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
							ELSE CAST(202103-2 AS TEXT)
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
						INNER JOIN cadastro.localidade loc ON loc.loca_id = pag.loca_id AND loc.uneg_id IN (2,3,4,5,6,7,8,9,10,11,12,13,14,15)
					WHERE
						pag.pgst_idatual IN (0,1)
						AND pag.pgmt_amreferenciaarrecadacao = 202103
					GROUP BY 1
				UNION
					SELECT 
						pag.imov_id AS imov_id,
						COUNT(pag.pghi_id) AS qtd,
						SUM(pag.pghi_vlpagamento) AS valor
					FROM
						arrecadacao.pagamento_historico pag
						INNER JOIN cadastro.localidade loc ON loc.loca_id = pag.loca_id AND loc.uneg_id IN (2,3,4,5,6,7,8,9,10,11,12,13,14,15)
					WHERE
						pag.pgst_idatual IN (0,1)
						AND pag.pghi_amreferenciaarrecadacao = 202103
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
						INNER JOIN cadastro.localidade loc ON loc.loca_id = pag.loca_id AND loc.uneg_id IN (2,3,4,5,6,7,8,9,10,11,12,13,14,15)
					WHERE
						pag.pgst_idatual IN (0,1)
						AND pag.pgmt_amreferenciaarrecadacao = (
								SELECT 
									CASE (CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 5 FOR 6) AS INT))
										WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
										ELSE CAST(202103-1 AS TEXT)
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
						INNER JOIN cadastro.localidade loc ON loc.loca_id = pag.loca_id AND loc.uneg_id IN (2,3,4,5,6,7,8,9,10,11,12,13,14,15)
					WHERE
						pag.pgst_idatual IN (0,1)
						AND pag.pghi_amreferenciaarrecadacao = (
								SELECT 
									CASE (CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 5 FOR 6) AS INT))
										WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
										ELSE CAST(202103-1 AS TEXT)
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
						INNER JOIN cadastro.localidade loc ON loc.loca_id = pag.loca_id AND loc.uneg_id IN (2,3,4,5,6,7,8,9,10,11,12,13,14,15)
					WHERE
						pag.pgst_idatual IN (0,1)
						AND pag.pgmt_amreferenciaarrecadacao = (
								SELECT 
									CASE (CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 5 FOR 6) AS INT))
										WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'11'
										WHEN 2 THEN CAST((CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
										ELSE CAST(202103-2 AS TEXT)
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
						INNER JOIN cadastro.localidade loc ON loc.loca_id = pag.loca_id AND loc.uneg_id IN (2,3,4,5,6,7,8,9,10,11,12,13,14,15)
					WHERE
						pag.pgst_idatual IN (0,1)
						AND pag.pghi_amreferenciaarrecadacao = (
								SELECT 
									CASE (CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 5 FOR 6) AS INT))
										WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'11'
										WHEN 2 THEN CAST((CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
										ELSE CAST(202103-2 AS TEXT)
									END
							)
					GROUP BY 1) pags
			GROUP BY 1
		) AS pags_ant ON pags_ant.imov_id = imo.imov_id
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
						INNER JOIN cadastro.localidade loc ON loc.loca_id = pag.loca_id AND loc.uneg_id IN (2,3,4,5,6,7,8,9,10,11,12,13,14,15)
					WHERE
						pag.pgst_idatual IN (0,1)
						AND pag.pgmt_amreferenciaarrecadacao = (
								SELECT 
									CASE (CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 5 FOR 6) AS INT))
										WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'10'
										WHEN 2 THEN CAST((CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'11'
										WHEN 3 THEN CAST((CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
										ELSE CAST(202103-3 AS TEXT)
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
						INNER JOIN cadastro.localidade loc ON loc.loca_id = pag.loca_id AND loc.uneg_id IN (2,3,4,5,6,7,8,9,10,11,12,13,14,15)
					WHERE
						pag.pgst_idatual IN (0,1)
						AND pag.pghi_amreferenciaarrecadacao = (
								SELECT 
									CASE (CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 5 FOR 6) AS INT))
										WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'10'
										WHEN 2 THEN CAST((CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'11'
										WHEN 3 THEN CAST((CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
										ELSE CAST(202103-3 AS TEXT)
									END
							)
					GROUP BY 1) pags
			GROUP BY 1
		) AS pags_antp ON pags_antp.imov_id = imo.imov_id
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
						INNER JOIN cadastro.localidade loc ON loc.loca_id = pag.loca_id AND loc.uneg_id IN (2,3,4,5,6,7,8,9,10,11,12,13,14,15)
					WHERE
						pag.pgst_idatual IN (0,1)
						AND pag.pgmt_amreferenciaarrecadacao = (
								SELECT 
									CASE (CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 5 FOR 6) AS INT))
										WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'09'
										WHEN 2 THEN CAST((CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'10'
										WHEN 3 THEN CAST((CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'11'
										WHEN 4 THEN CAST((CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
										ELSE CAST(202103-4 AS TEXT)
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
						INNER JOIN cadastro.localidade loc ON loc.loca_id = pag.loca_id AND loc.uneg_id IN (2,3,4,5,6,7,8,9,10,11,12,13,14,15)
					WHERE
						pag.pgst_idatual IN (0,1)
						AND pag.pghi_amreferenciaarrecadacao = (
								SELECT 
									CASE (CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 5 FOR 6) AS INT))
										WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'09'
										WHEN 2 THEN CAST((CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'10'
										WHEN 3 THEN CAST((CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'11'
										WHEN 4 THEN CAST((CAST(SUBSTRING(CAST(202103 AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
										ELSE CAST(202103-4 AS TEXT)
									END
							)
					GROUP BY 1) pags
			GROUP BY 1
		) AS pags_antant ON pags_antant.imov_id = imo.imov_id
WHERE
	imo.imov_icexclusao = 2
	--loc.uneg_id >= 11 AND loc.uneg_id <= 15
	 AND une.uneg_id IN (2,3,4,5,6,7,8,9,10,11,12,13,14,15)
	 AND (pags_ult.qtd > 0 OR pags_pen.qtd>0 OR pags_ant.qtd>0 OR pags_antp.qtd >0 OR pags_antant.qtd >0)
	--AND imo.imov_id = 19
ORDER BY "LOCALIDADE","SETOR COMERCIAL","ROTA","QUADRA","SEQUENCIA","SUB LOTE"