WITH RECURSIVE arvore AS (
		SELECT
			pai.clie_id AS id,
			pai.clie_nmcliente AS nome,
			pai.clie_nncpf AS cpf,
			pai.clie_nncnpj AS cnpj,
			pai.clie_cdclienteresponsavel AS pai,
			''::VARCHAR AS nome_pai,
			pai.clie_id::TEXT path,
			pai.clie_nmcliente::TEXT name_path
		FROM
			cadastro.cliente pai
		WHERE
			clie_cdclienteresponsavel IS NULL
			AND EXISTS (SELECT * FROM cadastro.cliente fil WHERE fil.clie_cdclienteresponsavel = pai.clie_id LIMIT 1)
	UNION
		SELECT
			fil.clie_id AS id,
			fil.clie_nmcliente AS nome,
			fil.clie_nncpf AS cpf,
			fil.clie_nncnpj AS cnpj,
			fil.clie_cdclienteresponsavel AS pai,
			pai.clie_nmcliente AS nome_pai,
			arv.path || '->' || fil.clie_id::TEXT path,
			arv.name_path || '->' || fil.clie_nmcliente name_path
		FROM
			cadastro.cliente fil
			INNER JOIN arvore arv ON arv.id = fil.clie_cdclienteresponsavel
			LEFT JOIN cadastro.cliente pai ON pai.clie_id = fil.clie_cdclienteresponsavel
)


SELECT
	arv.id AS "ID CLIENTE",
	arv.nome AS "NOME",
	arv.cpf AS "CPF",
	arv.cnpj AS "CNPJ",
	arv.pai AS "PAI",
	arv.nome_pai AS "NOME PAI",
	arv.path AS "ARVORE DE DESCENDENCIA",
	SPLIT_PART(arv.path,'->',1) AS "PATRIARCA",
	SPLIT_PART(arv.name_path,'->',1) AS "NOME PATRIARCA",
	imo.imov_id AS "MATRICULA VINCULADA",
	TO_CHAR(imo.imov_nncoordenadax,'990D999999999999999') AS "LATITUDE",
	TO_CHAR(imo.imov_nncoordenaday,'990D999999999999999') AS "LONGITUDE",
	crl.crtp_dsclienterelacaotipo AS "TIPO DE VINCULO",
	cim.clim_dtrelacaoinicio AS "INICIO DA RELACAO",
	cli.clie_nmcliente AS "CLIENTE TITULAR",
	cli.clie_nncpf AS "CPF TITULAR",
	cli.clie_nncnpj AS "CNPJ TITULAR",
	(CASE cli.clie_iccpfcnpjvalidado
	WHEN 0 THEN 'NAO'
	WHEN 1 THEN 'SIM'
	ELSE 'NAO'
	END) AS "DOC VALIDADO",
	(
		SELECT
			'('||cfn.cfon_cdddd||')'||cfn.cfon_nnfone
		FROM
			cadastro.cliente_fone cfn
		WHERE 
			cfn.clie_id = cli.clie_id AND cfn.cfon_id = (SELECT MAX(cfn2.cfon_id) FROM cadastro.cliente_fone cfn2 WHERE cfn2.clie_id = cli.clie_id)
		LIMIT 1
	) AS "TELEFONE MAIS RECENTE TITULAR",
	cli.clie_dsemail AS "EMAIL",
	cat.catg_dscategoria AS "CATEGORIA",
	sct.scat_dssubcategoria AS "SUBCATEGORIA",
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
	las.last_dsligacaoaguasituacao AS "SITUACAO AGUA",
	lgd.lagd_dsligacaoaguadiametro AS "DIAMETRO LIG AGUA",
	lagu.lagu_dtimplantacao AS "DT. IMPLANTACAO",
	lagu.lagu_dtligacaoagua AS "DT. LIGACAO",
	lagu.lagu_dtcorte AS "DT. CORTE",
	lagu.lagu_dtreligacaoagua AS "DT. RELIGACAO",
	lagu.lagu_dtsupressaoagua AS "DT. SUPRESSAO",
	imo.lest_id AS "ID SIT. ESG",
	les.lest_dsligacaoesgotosituacao AS "SITUACAO ESGOTO",
	TRIM(TO_CHAR(imo.imov_nnareaconstruida, '999G999G990D00')) AS "AREA",
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
	(
		SELECT
			STRING_AGG('INC: '|| TO_CHAR(ics.iscb_dtimplantacaocobranca, 'dd/MM/yyyy') ||' <-> EXC: '|| TO_CHAR(ics.iscb_dtretiradacobranca, 'dd/MM/yyyy'), ' | ')
		FROM
			cadastro.imovel_cobranca_situacao ics
		WHERE
			ics.imov_id = imo.imov_id AND ics.cbst_id IN (12,14,17,24,25,26)
			
	) AS "HISTORICO NEGATIVACAO",
	(
		SELECT
			STRING_AGG('EMS: '|| TO_CHAR(doc.cbdo_tmemissao, 'dd/MM/yyyy'), ' | ')
		FROM
			cobranca.cobranca_documento doc
		WHERE
			doc.imov_id = imo.imov_id AND doc.dotp_id = 12
			
	) AS "HISTORICO NOTIFICACAO",
	(
		SELECT
			STRING_AGG('EMS: '|| TO_CHAR(doc.cbdo_tmemissao, 'dd/MM/yyyy') || ' <-> SIT: ' || cas.cast_dssituacaoacao, ' | ')
		FROM
			cobranca.cobranca_documento doc
			INNER JOIN cobranca.cobranca_acao_situacao cas ON cas.cast_id = doc.cast_id
		WHERE
			doc.imov_id = imo.imov_id AND doc.dotp_id = 13
			
	) AS "HISTORICO ORDEM DE CORTE",
	(
		SELECT
			STRING_AGG('EMS: '|| TO_CHAR(doc.cbdo_tmemissao, 'dd/MM/yyyy') || ' <-> SIT: ' || cas.cast_dssituacaoacao, ' | ')
		FROM
			cobranca.cobranca_documento doc
			INNER JOIN cobranca.cobranca_acao_situacao cas ON cas.cast_id = doc.cast_id
		WHERE
			doc.imov_id = imo.imov_id AND doc.dotp_id = 13 AND cas.cast_id = 2
			
	) AS "HISTORICO ORDENS DE CORTE EXECUTADAS",
	(
		SELECT
			STRING_AGG('EMS: '|| TO_CHAR(par.parc_tmparcelamento, 'dd/MM/yyyy') || ' <-> SIT: ' || pcs.pcst_dsparcelamentosituacao, ' | ')
		FROM
			cobranca.parcelamento par
			INNER JOIN cobranca.parcelamento_situacao pcs ON pcs.pcst_id = par.pcst_id
		WHERE
			par.imov_id = imo.imov_id
	) AS "HISTORICO PARCELAMENTOS",
	(
		SELECT
			TO_CHAR(MAX(hir.hidi_dtretiradahidrometro), 'dd/MM/yyyy')
		FROM
			micromedicao.hidrometro_inst_hist hir
		WHERE
			hir.lagu_id = imo.imov_id
		LIMIT 1
	) AS "ULTIMA RETIRADA DE HIDRO",
	hid.hidr_nnhidrometro AS "NR HID.",
	hid.hidr_nnanofabricacao AS "ANO HD",
	his.hidi_dtinstalacaohidrometro AS "DATA DE INSTALACAO HD.",
	hic.hicp_dshidrometrocapacidade AS "CAPACIDADE HD",
	hdi.hidm_dshidrometrodiametro AS "DIAMETRO HD",
	cob.cbst_dscobrancasituacao AS "SIT. COBRANCA BOA VISTA",
	ics.iscb_dtimplantacaocobranca AS "DATA DE ENTRADA COBRANCA BOA VISTA",
	cob_ser.cbst_dscobrancasituacao AS "SIT. COBRANCA SERASA",
	ics_ser.iscb_dtimplantacaocobranca AS "DATA DE ENTRADA COBRANCA SERASA",
	cob_exi.cbst_dscobrancasituacao AS "SIT. COBRANCA EXITO",
	ics_exi.iscb_dtimplantacaocobranca AS "DATA DE ENTRADA COBRANCA EXITO",
	TO_CHAR(con_atraso.vl_agua, '999G999G990D00') AS "VALOR AGUA DEVIDO CONTAS",
	TO_CHAR(con_atraso.vl_esgoto, '999G999G990D00') AS "VALOR ESGOTO DEVIDO CONTAS",
	TO_CHAR(con_atraso.vl_debitos, '999G999G990D00') AS "VALOR DEBITOS DEVIDO CONTAS",
	TO_CHAR(con_atraso.vl_creditos, '999G999G990D00') AS "VALOR CREDITOS DEVIDO CONTAS",
	TO_CHAR(con_atraso.vl_impostos, '999G999G990D00') AS "VALOR IMPOSTOS DEVIDO CONTAS",
	TO_CHAR(con_atraso.valor, '999G999G990D00') AS "VALOR TOTAL DEVIDO CONTAS",
	con_atraso.qtd AS "QTD. DEVIDO CONTAS",
	con_atraso.min AS "MENOR REFERENCIA DEVIDO CONTAS",
	con_atraso.max AS "MAIOR REFERENCIA DEVIDO CONTAS",
	con_atraso.min_venc AS "MENOR VENCIMENTO DEVIDO CONTAS",
	con_atraso.max_venc AS "MAIOR VENCIMENTO DEVIDO CONTAS",
	TO_CHAR(con_atraso.multa, '999G999G990D00') AS "MULTAS DEVIDO CONTAS",
	TO_CHAR(con_atraso.juros, '999G999G990D00') AS "JUROS DEVIDO CONTAS",
	TO_CHAR((con_atraso.multa+con_atraso.juros+con_atraso.valor), '999G999G990D00') AS "VALOR TOTAL COM JUROS CONTAS",
	con_fat_1.cagua AS "VOL AG VAR_REFERENCIA - 1",
	TO_CHAR(con_fat_1.vl_agua, '999G999G990D00') AS "VL AG VAR_REFERENCIA - 1",
	con_fat_1.cesg AS "VOL ES VAR_REFERENCIA - 1",
	TO_CHAR(con_fat_1.vl_esgoto, '999G999G990D00') AS "VL ES VAR_REFERENCIA - 1",
	TO_CHAR(con_fat_1.vl_debitos, '999G999G990D00') AS "OUTROS SERVICOS VAR_REFERENCIA - 1",
	TO_CHAR(con_fat_1.vl_creditos, '999G999G990D00') AS "CRED VAR_REFERENCIA - 1",
	TO_CHAR(con_fat_1.vl_impostos, '999G999G990D00') AS "IMPOSTOS VAR_REFERENCIA - 1",
	TO_CHAR(con_fat_1.valor, '999G999G990D00') AS "VALOR VAR_REFERENCIA - 1",

	con_fat_2.cagua AS "VOL AG VAR_REFERENCIA - 2",
	TO_CHAR(con_fat_2.vl_agua, '999G999G990D00') AS "VL AG VAR_REFERENCIA - 2",
	con_fat_2.cesg AS "VOL ES VAR_REFERENCIA - 2",
	TO_CHAR(con_fat_2.vl_esgoto, '999G999G990D00') AS "VL ES VAR_REFERENCIA - 2",
	TO_CHAR(con_fat_2.vl_debitos, '999G999G990D00') AS "OUTROS SERVICOS VAR_REFERENCIA - 2",
	TO_CHAR(con_fat_2.vl_creditos, '999G999G990D00') AS "CRED VAR_REFERENCIA - 2",
	TO_CHAR(con_fat_2.vl_impostos, '999G999G990D00') AS "IMPOSTOS VAR_REFERENCIA - 2",
	TO_CHAR(con_fat_2.valor, '999G999G990D00') AS "VALOR VAR_REFERENCIA - 2",

	con_fat_3.cagua AS "VOL AG VAR_REFERENCIA - 3",
	TO_CHAR(con_fat_3.vl_agua, '999G999G990D00') AS "VL AG VAR_REFERENCIA - 3",
	con_fat_3.cesg AS "VOL ES VAR_REFERENCIA - 3",
	TO_CHAR(con_fat_3.vl_esgoto, '999G999G990D00') AS "VL ES VAR_REFERENCIA - 3",
	TO_CHAR(con_fat_3.vl_debitos, '999G999G990D00') AS "OUTROS SERVICOS VAR_REFERENCIA - 3",
	TO_CHAR(con_fat_3.vl_creditos, '999G999G990D00') AS "CRED VAR_REFERENCIA - 3",
	TO_CHAR(con_fat_3.vl_impostos, '999G999G990D00') AS "IMPOSTOS VAR_REFERENCIA - 3",
	TO_CHAR(con_fat_3.valor, '999G999G990D00') AS "VALOR VAR_REFERENCIA - 3",

	con_fat_4.cagua AS "VOL AG VAR_REFERENCIA - 4",
	TO_CHAR(con_fat_4.vl_agua, '999G999G990D00') AS "VL AG VAR_REFERENCIA - 4",
	con_fat_4.cesg AS "VOL ES VAR_REFERENCIA - 4",
	TO_CHAR(con_fat_4.vl_esgoto, '999G999G990D00') AS "VL ES VAR_REFERENCIA - 4",
	TO_CHAR(con_fat_4.vl_debitos, '999G999G990D00') AS "OUTROS SERVICOS VAR_REFERENCIA - 4",
	TO_CHAR(con_fat_4.vl_creditos, '999G999G990D00') AS "CRED VAR_REFERENCIA - 4",
	TO_CHAR(con_fat_4.vl_impostos, '999G999G990D00') AS "IMPOSTOS VAR_REFERENCIA - 4",
	TO_CHAR(con_fat_4.valor, '999G999G990D00') AS "VALOR VAR_REFERENCIA - 4",

	con_fat_5.cagua AS "VOL AG VAR_REFERENCIA - 5",
	TO_CHAR(con_fat_5.vl_agua, '999G999G990D00') AS "VL AG VAR_REFERENCIA - 5",
	con_fat_5.cesg AS "VOL ES VAR_REFERENCIA - 5",
	TO_CHAR(con_fat_5.vl_esgoto, '999G999G990D00') AS "VL ES VAR_REFERENCIA - 5",
	TO_CHAR(con_fat_5.vl_debitos, '999G999G990D00') AS "OUTROS SERVICOS VAR_REFERENCIA - 5",
	TO_CHAR(con_fat_5.vl_creditos, '999G999G990D00') AS "CRED VAR_REFERENCIA - 5",
	TO_CHAR(con_fat_5.vl_impostos, '999G999G990D00') AS "IMPOSTOS VAR_REFERENCIA - 5",
	TO_CHAR(con_fat_5.valor, '999G999G990D00') AS "VALOR VAR_REFERENCIA - 5",

	con_fat_6.cagua AS "VOL AG VAR_REFERENCIA - 6",
	TO_CHAR(con_fat_6.vl_agua, '999G999G990D00') AS "VL AG VAR_REFERENCIA - 6",
	con_fat_6.cesg AS "VOL ES VAR_REFERENCIA - 6",
	TO_CHAR(con_fat_6.vl_esgoto, '999G999G990D00') AS "VL ES VAR_REFERENCIA - 6",
	TO_CHAR(con_fat_6.vl_debitos, '999G999G990D00') AS "OUTROS SERVICOS VAR_REFERENCIA - 6",
	TO_CHAR(con_fat_6.vl_creditos, '999G999G990D00') AS "CRED VAR_REFERENCIA - 6",
	TO_CHAR(con_fat_6.vl_impostos, '999G999G990D00') AS "IMPOSTOS VAR_REFERENCIA - 6",
	TO_CHAR(con_fat_6.valor, '999G999G990D00') AS "VALOR VAR_REFERENCIA - 6",

	con_fat_7.cagua AS "VOL AG VAR_REFERENCIA - 7",
	TO_CHAR(con_fat_7.vl_agua, '999G999G990D00') AS "VL AG VAR_REFERENCIA - 7",
	con_fat_7.cesg AS "VOL ES VAR_REFERENCIA - 7",
	TO_CHAR(con_fat_7.vl_esgoto, '999G999G990D00') AS "VL ES VAR_REFERENCIA - 7",
	TO_CHAR(con_fat_7.vl_debitos, '999G999G990D00') AS "OUTROS SERVICOS VAR_REFERENCIA - 7",
	TO_CHAR(con_fat_7.vl_creditos, '999G999G990D00') AS "CRED VAR_REFERENCIA - 7",
	TO_CHAR(con_fat_7.vl_impostos, '999G999G990D00') AS "IMPOSTOS VAR_REFERENCIA - 7",
	TO_CHAR(con_fat_7.valor, '999G999G990D00') AS "VALOR VAR_REFERENCIA - 7",

	con_fat_8.cagua AS "VOL AG VAR_REFERENCIA - 8",
	TO_CHAR(con_fat_8.vl_agua, '999G999G990D00') AS "VL AG VAR_REFERENCIA - 8",
	con_fat_8.cesg AS "VOL ES VAR_REFERENCIA - 8",
	TO_CHAR(con_fat_8.vl_esgoto, '999G999G990D00') AS "VL ES VAR_REFERENCIA - 8",
	TO_CHAR(con_fat_8.vl_debitos, '999G999G990D00') AS "OUTROS SERVICOS VAR_REFERENCIA - 8",
	TO_CHAR(con_fat_8.vl_creditos, '999G999G990D00') AS "CRED VAR_REFERENCIA - 8",
	TO_CHAR(con_fat_8.vl_impostos, '999G999G990D00') AS "IMPOSTOS VAR_REFERENCIA - 8",
	TO_CHAR(con_fat_8.valor, '999G999G990D00') AS "VALOR VAR_REFERENCIA - 8",

	con_fat_9.cagua AS "VOL AG VAR_REFERENCIA - 9",
	TO_CHAR(con_fat_9.vl_agua, '999G999G990D00') AS "VL AG VAR_REFERENCIA - 9",
	con_fat_9.cesg AS "VOL ES VAR_REFERENCIA - 9",
	TO_CHAR(con_fat_9.vl_esgoto, '999G999G990D00') AS "VL ES VAR_REFERENCIA - 9",
	TO_CHAR(con_fat_9.vl_debitos, '999G999G990D00') AS "OUTROS SERVICOS VAR_REFERENCIA - 9",
	TO_CHAR(con_fat_9.vl_creditos, '999G999G990D00') AS "CRED VAR_REFERENCIA - 9",
	TO_CHAR(con_fat_9.vl_impostos, '999G999G990D00') AS "IMPOSTOS VAR_REFERENCIA - 9",
	TO_CHAR(con_fat_9.valor, '999G999G990D00') AS "VALOR VAR_REFERENCIA - 9",

	con_fat_10.cagua AS "VOL AG VAR_REFERENCIA - 10",
	TO_CHAR(con_fat_10.vl_agua, '999G999G990D00') AS "VL AG VAR_REFERENCIA - 10",
	con_fat_10.cesg AS "VOL ES VAR_REFERENCIA - 10",
	TO_CHAR(con_fat_10.vl_esgoto, '999G999G990D00') AS "VL ES VAR_REFERENCIA - 10",
	TO_CHAR(con_fat_10.vl_debitos, '999G999G990D00') AS "OUTROS SERVICOS VAR_REFERENCIA - 10",
	TO_CHAR(con_fat_10.vl_creditos, '999G999G990D00') AS "CRED VAR_REFERENCIA - 10",
	TO_CHAR(con_fat_10.vl_impostos, '999G999G990D00') AS "IMPOSTOS VAR_REFERENCIA - 10",
	TO_CHAR(con_fat_10.valor, '999G999G990D00') AS "VALOR VAR_REFERENCIA - 10",

	con_fat_11.cagua AS "VOL AG VAR_REFERENCIA - 11",
	TO_CHAR(con_fat_11.vl_agua, '999G999G990D00') AS "VL AG VAR_REFERENCIA - 11",
	con_fat_11.cesg AS "VOL ES VAR_REFERENCIA - 11",
	TO_CHAR(con_fat_11.vl_esgoto, '999G999G990D00') AS "VL ES VAR_REFERENCIA - 11",
	TO_CHAR(con_fat_11.vl_debitos, '999G999G990D00') AS "OUTROS SERVICOS VAR_REFERENCIA - 11",
	TO_CHAR(con_fat_11.vl_creditos, '999G999G990D00') AS "CRED VAR_REFERENCIA - 11",
	TO_CHAR(con_fat_11.vl_impostos, '999G999G990D00') AS "IMPOSTOS VAR_REFERENCIA - 11",
	TO_CHAR(con_fat_11.valor, '999G999G990D00') AS "VALOR VAR_REFERENCIA - 11",

	con_fat_12.cagua AS "VOL AG VAR_REFERENCIA - 12",
	TO_CHAR(con_fat_12.vl_agua, '999G999G990D00') AS "VL AG VAR_REFERENCIA - 12",
	con_fat_12.cesg AS "VOL ES VAR_REFERENCIA - 12",
	TO_CHAR(con_fat_12.vl_esgoto, '999G999G990D00') AS "VL ES VAR_REFERENCIA - 12",
	TO_CHAR(con_fat_12.vl_debitos, '999G999G990D00') AS "OUTROS SERVICOS VAR_REFERENCIA - 12",
	TO_CHAR(con_fat_12.vl_creditos, '999G999G990D00') AS "CRED VAR_REFERENCIA - 12",
	TO_CHAR(con_fat_12.vl_impostos, '999G999G990D00') AS "IMPOSTOS VAR_REFERENCIA - 12",
	TO_CHAR(con_fat_12.valor, '999G999G990D00') AS "VALOR VAR_REFERENCIA - 12"
FROM
	arvore arv
	LEFT JOIN cadastro.cliente_imovel cim_vinc ON cim_vinc.clie_id = arv.id AND cim_vinc.clim_dtrelacaofim IS NULL
	LEFT JOIN cadastro.cliente_relacao_tipo crl ON crl.crtp_id = cim_vinc.crtp_id
	LEFT JOIN cadastro.imovel imo ON imo.imov_id = cim_vinc.imov_id
	LEFT JOIN cadastro.categoria cat ON cat.catg_id = imo.imov_idcategoriaprincipal
	LEFT JOIN cadastro.subcategoria sct ON sct.scat_id = imo.imov_idsubcategoriaprincipal
	LEFT JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
	LEFT JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
	LEFT JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
	LEFT JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
	LEFT JOIN cadastro.setor_comercial sec ON imo.stcm_id = sec.stcm_id
	LEFT JOIN cadastro.quadra qdr ON qdr.qdra_id = imo.qdra_id
	LEFT JOIN micromedicao.rota rot ON rot.rota_id = qdr.rota_id
	LEFT JOIN faturamento.faturamento_grupo ftg ON rot.ftgr_id = ftg.ftgr_id
	LEFT JOIN cadastro.logradouro_bairro lgb ON lgb.lgbr_id = imo.lgbr_id
	LEFT JOIN cadastro.logradouro logr ON lgb.logr_id = logr.logr_id
	LEFT JOIN cadastro.bairro bai ON bai.bair_id = lgb.bair_id
	LEFT JOIN cadastro.municipio mun ON mun.muni_id = bai.muni_id
	LEFT JOIN cadastro.fonte_abastecimento ftb ON ftb.ftab_id = imo.ftab_id
	LEFT JOIN operacional.distrito_operacional dis ON dis.diop_id = qdr.diop_id
	LEFT JOIN atendimentopublico.ligacao_agua_situacao las ON las.last_id = imo.last_id
	LEFT JOIN atendimentopublico.ligacao_esgoto_situacao les ON les.lest_id = imo.lest_id
	LEFT JOIN cadastro.logradouro_cep lgc ON lgc.lgcp_id = imo.lgcp_id
	LEFT JOIN cadastro.cep cep ON cep.cep_id = lgc.cep_id
	LEFT JOIN cadastro.logradouro_tipo lgt ON lgt.lgtp_id = logr.lgtp_id
	LEFT JOIN atendimentopublico.ligacao_agua lagu ON lagu.lagu_id = imo.imov_id
	LEFT JOIN atendimentopublico.ligacao_agua_diametro lgd ON lgd.lagd_id = lagu.lagd_id
	LEFT JOIN faturamento.fatur_situacao_hist fsh ON fsh.imov_id = imo.imov_id AND fsh.ftsh_amfaturamentoretirada IS NULL
	LEFT JOIN faturamento.fatur_situacao_tipo fat ON fat.ftst_id = fsh.ftst_id
	LEFT JOIN faturamento.fatur_situacao_motivo ftm ON fsh.ftsm_id = ftm.ftsm_id
	LEFT JOIN cobranca.cobranca_situacao_hist csh ON csh.imov_id = imo.imov_id AND csh.cbsh_amcobrancaretirada IS NULL
	LEFT JOIN cobranca.cobranca_situacao_tipo cst ON csh.cbsp_id = cst.cbsp_id
	LEFT JOIN cobranca.cobranca_situacao_motivo csm ON csm.cbsm_id = csh.cbsm_id
	LEFT JOIN micromedicao.hidrometro_inst_hist his ON lagu.hidi_id = his.hidi_id AND his.hidi_dtretiradahidrometro IS NULL
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
				con4.cnta_amreferenciaconta = VAR_REFERENCIA
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
				con4.cnhi_amreferenciaconta = VAR_REFERENCIA
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
				con4.cnta_amreferenciaconta = VAR_REFERENCIA
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
				con4.cnhi_amreferenciaconta = VAR_REFERENCIA
			) AS con_fat_0 ON con_fat_0.mat1 = imo.imov_id
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
				con4.cnta_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '1months','YYYYMM')::INT
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
				con4.cnhi_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '1months','YYYYMM')::INT
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
				con4.cnta_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '1months','YYYYMM')::INT
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
				con4.cnhi_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '1months','YYYYMM')::INT
			) AS con_fat_1 ON con_fat_1.mat1 = imo.imov_id
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
				con4.cnta_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '2months','YYYYMM')::INT
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
				con4.cnhi_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '2months','YYYYMM')::INT
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
				con4.cnta_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '2months','YYYYMM')::INT
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
				con4.cnhi_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '2months','YYYYMM')::INT
			) AS con_fat_2 ON con_fat_2.mat1 = imo.imov_id
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
				con4.cnta_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '3months','YYYYMM')::INT
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
				con4.cnhi_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '3months','YYYYMM')::INT
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
				con4.cnta_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '3months','YYYYMM')::INT
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
				con4.cnhi_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '3months','YYYYMM')::INT
			) AS con_fat_3 ON con_fat_3.mat1 = imo.imov_id
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
				con4.cnta_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '4months','YYYYMM')::INT
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
				con4.cnhi_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '4months','YYYYMM')::INT
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
				con4.cnta_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '4months','YYYYMM')::INT
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
				con4.cnhi_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '4months','YYYYMM')::INT
			) AS con_fat_4 ON con_fat_4.mat1 = imo.imov_id
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
				con4.cnta_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '5months','YYYYMM')::INT
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
				con4.cnhi_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '5months','YYYYMM')::INT
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
				con4.cnta_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '5months','YYYYMM')::INT
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
				con4.cnhi_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '5months','YYYYMM')::INT
			) AS con_fat_5 ON con_fat_5.mat1 = imo.imov_id
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
				con4.cnta_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '6months','YYYYMM')::INT
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
				con4.cnhi_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '6months','YYYYMM')::INT
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
				con4.cnta_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '6months','YYYYMM')::INT
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
				con4.cnhi_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '6months','YYYYMM')::INT
			) AS con_fat_6 ON con_fat_6.mat1 = imo.imov_id
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
				con4.cnta_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '7months','YYYYMM')::INT
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
				con4.cnhi_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '7months','YYYYMM')::INT
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
				con4.cnta_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '7months','YYYYMM')::INT
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
				con4.cnhi_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '7months','YYYYMM')::INT
			) AS con_fat_7 ON con_fat_7.mat1 = imo.imov_id
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
				con4.cnta_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '8months','YYYYMM')::INT
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
				con4.cnhi_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '8months','YYYYMM')::INT
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
				con4.cnta_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '8months','YYYYMM')::INT
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
				con4.cnhi_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '8months','YYYYMM')::INT
			) AS con_fat_8 ON con_fat_8.mat1 = imo.imov_id
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
				con4.cnta_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '9months','YYYYMM')::INT
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
				con4.cnhi_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '9months','YYYYMM')::INT
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
				con4.cnta_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '9months','YYYYMM')::INT
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
				con4.cnhi_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '9months','YYYYMM')::INT
			) AS con_fat_9 ON con_fat_9.mat1 = imo.imov_id
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
				con4.cnta_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '10months','YYYYMM')::INT
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
				con4.cnhi_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '10months','YYYYMM')::INT
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
				con4.cnta_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '10months','YYYYMM')::INT
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
				con4.cnhi_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '10months','YYYYMM')::INT
			) AS con_fat_10 ON con_fat_10.mat1 = imo.imov_id
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
				con4.cnta_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '11months','YYYYMM')::INT
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
				con4.cnhi_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '11months','YYYYMM')::INT
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
				con4.cnta_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '11months','YYYYMM')::INT
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
				con4.cnhi_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '11months','YYYYMM')::INT
			) AS con_fat_11 ON con_fat_11.mat1 = imo.imov_id
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
				con4.cnta_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '12months','YYYYMM')::INT
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
				con4.cnhi_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '12months','YYYYMM')::INT
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
				con4.cnta_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '12months','YYYYMM')::INT
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
				con4.cnhi_amreferenciaconta = TO_CHAR(TO_DATE(VAR_REFERENCIA,'YYYYMM') - INTERVAL '12months','YYYYMM')::INT
			) AS con_fat_12 ON con_fat_12.mat1 = imo.imov_id