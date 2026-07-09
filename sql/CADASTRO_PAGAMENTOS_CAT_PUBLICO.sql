SELECT 
	imo.imov_id AS "MATRICULA",
	(CASE imo.imov_icdebitoconta
	WHEN 2 THEN 'NAO'
	ELSE 'SIM'
	END) AS "DEBITO AUTOMATICO",
	imo.imov_nncoordenadax AS "LATITUDE",
	imo.imov_nncoordenaday AS "LONGITUDE",
	cli.clie_id AS "CODIGO CLIENTE",
	cli.clie_nmcliente AS "NOME",
	CASE
	    WHEN 
		cli.clie_nncpf IS NOT NULL THEN
		CONCAT(SUBSTRING(cli.clie_nncpf,1,3),'.',SUBSTRING(cli.clie_nncpf,4,3),'.',SUBSTRING(cli.clie_nncpf,7,3),'-',SUBSTRING(cli.clie_nncpf,10,2))
	ELSE
		''
	END AS "CPF",
	CASE
	    WHEN 
		cli.clie_nncnpj IS NOT NULL THEN
		CONCAT(SUBSTRING(cli.clie_nncnpj, 1, 2),'.',SUBSTRING(cli.clie_nncnpj,3,3),'.',SUBSTRING(cli.clie_nncnpj,6,3),'/',SUBSTRING(cli.clie_nncnpj,9,4),'-',SUBSTRING(cli.clie_nncnpj, 13, 2))
	ELSE
		''
	END AS "CNPJ",
	cli.clie_dsemail AS "EMAIL",
	TO_CHAR(cli.clie_dtnascimento,'DD/MM/YYYY') AS "DT NASCIMENTO",
	cli.clie_nnmae AS "NOME DA MAE",
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
	cli2.clie_id AS "CODIGO RESP",
	cli2.clie_nmcliente AS "NOME RESP",
	CASE
	    WHEN 
		cli2.clie_nncpf IS NOT NULL THEN
		CONCAT(SUBSTRING(cli2.clie_nncpf,1,3),'.',SUBSTRING(cli2.clie_nncpf,4,3),'.',SUBSTRING(cli2.clie_nncpf,7,3),'-',SUBSTRING(cli2.clie_nncpf,10,2))
	ELSE
		''
	END AS "CPF",
	CASE
	    WHEN 
		cli2.clie_nncnpj IS NOT NULL THEN
		CONCAT(SUBSTRING(cli2.clie_nncnpj, 1, 2),'.',SUBSTRING(cli2.clie_nncnpj,3,3),'.',SUBSTRING(cli2.clie_nncnpj,6,3),'/',SUBSTRING(cli2.clie_nncnpj,9,4),'-',SUBSTRING(cli2.clie_nncnpj, 13, 2))
	ELSE
		''
	END AS "CNPJ",
	cli3.clie_id AS "CODIGO PAI",
	cli3.clie_nmcliente AS "NOME PAI",
	CASE
	    WHEN 
		cli3.clie_nncpf IS NOT NULL THEN
		CONCAT(SUBSTRING(cli3.clie_nncpf,1,3),'.',SUBSTRING(cli3.clie_nncpf,4,3),'.',SUBSTRING(cli3.clie_nncpf,7,3),'-',SUBSTRING(cli3.clie_nncpf,10,2))
	ELSE
		''
	END AS "CPF",
	CASE
	    WHEN 
		cli3.clie_nncnpj IS NOT NULL THEN
		CONCAT(SUBSTRING(cli3.clie_nncnpj, 1, 2),'.',SUBSTRING(cli3.clie_nncnpj,3,3),'.',SUBSTRING(cli3.clie_nncnpj,6,3),'/',SUBSTRING(cli3.clie_nncnpj,9,4),'-',SUBSTRING(cli3.clie_nncnpj, 13, 2))
	ELSE
		''
	END AS "CNPJ",
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
	las.last_dsligacaoaguasituacao AS "SITUACAO AGUA",
	lagu.lagu_dtcorte AS "DT. CORTE",
	les.lest_dsligacaoesgotosituacao AS "SITUACAO ESGOTO",
	imo.imov_nnareaconstruida AS "AREA",
	CAST(fat.ftst_id  AS TEXT) || ' - ' || fat.ftst_dsfaturamentosituacaotipo AS "SIT. FATURAMENTO",
	fsh.ftsh_amfatmtsitinicio AS "INICIO",
	fsh.ftsh_amfaturamentosituacaofim AS "FIM",
	ftm.ftsm_dsfatsitmotivo AS "MOTIVO",
	hid.hidr_nnhidrometro AS "NR HID.",
	hid.hidr_nnanofabricacao AS "ANO HD",
	his.hidi_dtinstalacaohidrometro AS "DATA DE INSTALACAO HD.",
	hic.hicp_dshidrometrocapacidade AS "CAPACIDADE HD",
	hdi.hidm_dshidrometrodiametro AS "DIAMETRO HD",
	pag_contas.dtpag AS "DATA PAGAMENTO",
	TO_CHAR(pag_contas.valor, '999G999G990D00') AS "VALOR PAGO"
FROM cadastro.imovel imo
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
	LEFT JOIN micromedicao.consumo_historico cosh_a1 ON cosh_a1.imov_id = imo.imov_id AND cosh_a1.cshi_amfaturamento = VAR_REFERENCIA AND cosh_a1.lgti_id = 1
	LEFT JOIN micromedicao.consumo_tipo cost_a1 ON cost_a1.cstp_id = cosh_a1.cstp_id
	LEFT JOIN micromedicao.consumo_anormalidade cosa_a1 ON cosa_a1.csan_id = cosh_a1.csan_id
	LEFT JOIN micromedicao.consumo_historico cosh_e1 ON cosh_e1.imov_id = imo.imov_id AND cosh_e1.cshi_amfaturamento = VAR_REFERENCIA AND cosh_e1.lgti_id = 2
	LEFT JOIN micromedicao.consumo_tipo cost_e1 ON cost_e1.cstp_id = cosh_e1.cstp_id
	LEFT JOIN micromedicao.consumo_anormalidade cosa_e1 ON cosa_e1.csan_id = cosh_e1.csan_id	
	LEFT JOIN micromedicao.medicao_historico mdh ON mdh.hidi_id = his.hidi_id AND mdh.mdhi_amleitura = VAR_REFERENCIA
	LEFT JOIN micromedicao.leitura_situacao lts ON lts.ltst_id = mdh.ltst_idleiturasituacaoatual
	LEFT JOIN micromedicao.leitura_anormalidade lai ON lai.ltan_id = mdh.ltan_idleitanorminformada
	LEFT JOIN micromedicao.leitura_anormalidade laf ON laf.ltan_id = mdh.ltan_idleitanormfatmt
	LEFT JOIN (	SELECT 
			pag4.imov_id AS mat1,
			pag4.pgmt_dtpagamento AS dtpag,
			pag4.pgmt_vlpagamento AS valor
			FROM
				arrecadacao.pagamento pag4
			WHERE 
				pag4.pgst_idatual IN (0,1) AND pag4.pgmt_dtpagamento  >= 'VAR_DATA_BEGIN' AND pag4.pgmt_dtpagamento  <= 'VAR_DATA_END'
			) AS pag_contas ON pag_contas.mat1 = imo.imov_id

WHERE 
	imo.imov_icexclusao = 2
	AND imo.imov_idcategoriaprincipal = 4
	AND pag_contas.valor > 0
	
ORDER BY "LOCALIDADE","SETOR COMERCIAL","ROTA","QUADRA","SEQUENCIA","SUB LOTE"