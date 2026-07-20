-- Imoveis com R.A. de retificacao pendente (step 978, situacao 1): o cliente esta contestando
-- a conta, entao o corte nao deve ser executado.
-- Era uma subquery correlacionada, que varria registro_atendimento uma vez por imovel
-- (custo 120 por linha, o mais caro da query). Agora e um passo unico, ligado por hash:
-- existe R.A. pendente = SIM, nao existe = NAO (o COALESCE na coluna).
WITH ret_pendente AS (
	SELECT DISTINCT ON (ra.imov_id)
		ra.imov_id,
		'SIM'::TEXT AS retificacao
	FROM atendimentopublico.registro_atendimento ra
	WHERE ra.rgat_cdsituacao = 1
	  AND ra.step_id = 978
	ORDER BY ra.imov_id, ra.rgat_tmregistroatendimento DESC
)
--VAR_REFERENCIA: Deve ser substituida pela referencia do faturamento que se deseja obter os dados
--15: Deve ser substituida pelo id da unidade de onde se quer obter os dados

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
		--TO_CHAR(dab.deba_dtinclusao, 'dd/MM/yyyy') AS "DEB AUT DATA INCLUSAO",

	(
		SELECT
			STRING_AGG('INC: '|| TO_CHAR(dab.deba_dtinclusao, 'dd/MM/yyyy')||' ID BAN:' || dab.deba_dsidentificacaoclientebco ||' BANCO:' || ban.bnco_nmbanco ||' <-> EXC: '|| TO_CHAR(dab.deba_dtexclusao, 'dd/MM/yyyy'), ' | ')
		FROM
			arrecadacao.debito_automatico dab
			LEFT JOIN arrecadacao.agencia age ON age.agen_id = dab.agen_id
			LEFT JOIN arrecadacao.banco ban ON ban.bnco_id = age.bnco_id
		WHERE
			dab.imov_id = imo.imov_id
			
	) AS "HISTORICO DEB AUTO",
	
	
	COALESCE(ret_pend.retificacao, 'NAO') AS "RETIFICACAO PENDENTE",

	
	--TO_CHAR(dab.deba_dtexclusao, 'dd/MM/yyyy') AS "DEB AUT DATA EXCLUSAO",
--	dab.deba_dsidentificacaoclientebco AS "IDENTIFICACAO BANCARIA",
--	ban.bnco_nmbanco AS "NOME BANCO",
	TO_CHAR(imo.imov_nncoordenadax,'990D999999999999999') AS "LATITUDE",
	TO_CHAR(imo.imov_nncoordenaday,'990D999999999999999') AS "LONGITUDE",
	cli.clie_id AS "CODIGO CLIENTE",
	cli.clie_nmcliente AS "NOME USUARIO",
	CASE
	    WHEN 
		cli.clie_nncpf IS NOT NULL THEN
		CONCAT(SUBSTRING(cli.clie_nncpf,1,3),'.',SUBSTRING(cli.clie_nncpf,4,3),'.',SUBSTRING(cli.clie_nncpf,7,3),'-',SUBSTRING(cli.clie_nncpf,10,2))
	ELSE
		''
	END AS "CPF USUARIO",
	CASE
	    WHEN 
		cli2.clie_nncnpj IS NOT NULL THEN
		CONCAT(SUBSTRING(cli.clie_nncnpj, 1, 2),'.',SUBSTRING(cli.clie_nncnpj,3,3),'.',SUBSTRING(cli.clie_nncnpj,6,3),'/',SUBSTRING(cli.clie_nncnpj,9,4),'-',SUBSTRING(cli.clie_nncnpj, 13, 2))
	ELSE
		''
	END AS "CNPJ USUARIO",
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
	cim.clim_dtrelacaoinicio AS "INICIO DA RELACAO",
	imp.iper_dsimovelperfil AS "PERFIL",
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
	une.uneg_nmunidadenegocio AS "UNIDADE DE NEGOCIOS",
	imo.loca_id AS "LOCALIDADE",
	loc.loca_nmlocalidade AS "NOME LOCALIDADE",
	sec.stcm_cdsetorcomercial AS "SETOR COMERCIAL",
	qdr.qdra_nnquadra AS "QUADRA",
	imo.imov_nnsequencialrota AS "SEQUENCIA",
	imo.imov_nnsublote AS "SUB LOTE",
	rot.rota_cdrota AS "ROTA",
	ftg.ftgr_dsfaturamentogrupo AS "GRUPO FATURAMENTO",
	CAST(fat.ftst_id  AS TEXT) || ' - ' || fat.ftst_dsfaturamentosituacaotipo AS "SIT. FATURAMENTO",
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
	imo.lest_id AS "ID SIT. ESG",
	les.lest_dsligacaoesgotosituacao AS "SITUACAO ESGOTO",
	imo.imov_nnareaconstruida AS "AREA",
	hid.hidr_nnhidrometro AS "NR HID.",
	his.hidi_dtinstalacaohidrometro AS "DATA DE INSTALACAO HD.",
	hic.hicp_dshidrometrocapacidade AS "CAPACIDADE HD",
	hdi.hidm_dshidrometrodiametro AS "DIAMETRO HD",
	pav.prua_dspavimentorua AS "PAVIMENTO RUA",
	CAST(pvf.pisc_vomenorfaixa AS TEXT) || ' - ' || CAST(pvf.pisc_vomaiorfaixa AS TEXT) AS "VOL PISC(m3)",
	poc.poco_dspocotipo AS "TIPO POCO",
	ith.imha_dstipohabitacao AS "TIPO DE HABITACAO",
	itp.impr_dstipopropriedade AS "TIPO PROPRIEDADE",
	itc.imco_dstipoconstrucao AS "TIPO DE CONSTRUCAO",
	imc.imcb_dstipocobertura AS "TIPO DE COBERTURA",
	pvc.pcal_dspavimentocalcada AS "PAVIMENTO CALCADA",
	dep.depj_dsdespejo AS "TIPO DE DESPEJO",
	CAST(cst.cbsp_id AS TEXT) || ' - ' || cst.cbsp_dscobrancasituacaotipo AS "SIT. ESPECIAL DE COBRANCA",
	csh.cbsh_dsobservacaoinforma AS "OBSERVAÇÃO",
	SUBSTRING(csh.cbsh_amcobrancasituacaoinicio,5,2) || '/' || SUBSTRING(csh.cbsh_amcobrancasituacaoinicio,1,4) AS "INICIO",
	SUBSTRING(csh.cbsh_amcobrancasituacaofim,5,2) || '/' || SUBSTRING(csh.cbsh_amcobrancasituacaofim,1,4) AS "FIM",
	cob.cbst_dscobrancasituacao AS "SIT. COBRANCA BOA VISTA",
	ics.iscb_dtimplantacaocobranca AS "DATA DE ENTRADA COBRANCA BOA VISTA",
	cob_ser.cbst_dscobrancasituacao AS "SIT. COBRANCA SERASA",
	ics_ser.iscb_dtimplantacaocobranca AS "DATA DE ENTRADA COBRANCA SERASA",
	con_parcelamento.qtd AS "QTD PARCELAMENTO ATRASADO",
	TO_CHAR(con_parcelamento.valor, '999G999G990D00') AS "VALOR PARCELAMENTO ATRASADO",
	TO_CHAR(con_atraso.vl_debitos, '999G999G990D00') AS "VALOR DEBITOS DEVIDO CORTE",
	TO_CHAR(con_atraso.valor, '999G999G990D00') AS "VALOR TOTAL DEVIDO CORTE",
	con_referencia.qtd AS "QTD. CONTAS DEVIDO",
	con_referencia.min AS "MENOR REFERENCIA DEVIDO",
	con_referencia.max AS "MAIOR REFERENCIA DEVIDO",
	con_referencia.min_venc AS "MENOR VENCIMENTO",
	con_referencia.max_venc AS "MAIOR VENCIMENTO",
	TO_CHAR(con_atraso90.vl_debitos, '999G999G990D00') AS "VALOR DEBITOS DEVIDO ANTERIORES",
	TO_CHAR(con_atraso90.valor, '999G999G990D00') AS "VALOR TOTAL DEVIDO ANTERIORES"
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
	LEFT JOIN faturamento.fatur_situacao_hist fsh ON fsh.imov_id = imo.imov_id AND fsh.ftsh_amfaturamentoretirada IS NULL
	LEFT JOIN faturamento.fatur_situacao_tipo fat ON fat.ftst_id = fsh.ftst_id
	LEFT JOIN cadastro.cliente_imovel cim2 ON cim2.imov_id = imo.imov_id AND cim2.clim_dtrelacaofim IS NULL AND cim2.crtp_id  = 3
	LEFT JOIN cadastro.cliente cli2 ON cli2.clie_id = cim2.clie_id
	LEFT JOIN cadastro.cliente_imovel cim3 ON cim3.imov_id = imo.imov_id AND cim3.clim_dtrelacaofim IS NULL AND cim3.crtp_id  = 2
	LEFT JOIN cadastro.cliente cli3 ON cli3.clie_id = cim3.clie_id
	LEFT JOIN cadastro.logradouro_cep lgc ON lgc.lgcp_id = imo.lgcp_id
	LEFT JOIN cadastro.cep cep ON cep.cep_id = lgc.cep_id
	LEFT JOIN cadastro.logradouro_tipo lgt ON lgt.lgtp_id = logr.lgtp_id
	LEFT JOIN atendimentopublico.ligacao_agua lagu ON lagu.lagu_id = imo.imov_id
	LEFT JOIN atendimentopublico.ligacao_agua_diametro lgd ON lgd.lagd_id = lagu.lagd_id
	LEFT JOIN micromedicao.hidrometro_inst_hist his ON lagu.hidi_id = his.hidi_id AND his.hidi_dtretiradahidrometro IS NULL
	LEFT JOIN micromedicao.hidrometro hid ON his.hidr_id = hid.hidr_id
	LEFT JOIN micromedicao.hidrometro_capacidade hic ON hic.hicp_id = hid.hicp_id
	LEFT JOIN micromedicao.hidrometro_diametro hdi ON hdi.hidm_id = hid.hidm_id
	LEFT JOIN micromedicao.hidrometro_marca hma ON hma.himc_id = hid.himc_id
	LEFT JOIN cadastro.imovel_perfil imp ON imp.iper_id = imo.iper_id
	LEFT JOIN cadastro.pavimento_rua pav ON pav.prua_id = imo.prua_id
	LEFT JOIN cadastro.piscina_volume_faixa pvf ON pvf.pisc_id = imo.pisc_id
	LEFT JOIN cadastro.poco_tipo poc ON poc.poco_id = imo.imov_id
	LEFT JOIN cadastro.imovel_tipo_habitacao ith ON ith.imha_id = imo.imha_id
	LEFT JOIN cadastro.imovel_tipo_propriedade itp ON itp.impr_id = imo.impr_id
	LEFT JOIN cadastro.imovel_tipo_construcao itc ON itc.imco_id = imo.imco_id
	LEFT JOIN cadastro.imovel_tipo_cobertura imc ON imc.imcb_id = imo.imcb_id
	LEFT JOIN cadastro.pavimento_calcada pvc ON pvc.pcal_id = imo.pcal_id
	LEFT JOIN cadastro.despejo dep ON dep.depj_id = imo.depj_id
	LEFT JOIN cobranca.cobranca_situacao_hist csh ON csh.imov_id = imo.imov_id AND csh.cbsh_amcobrancaretirada IS NULL	
	LEFT JOIN cobranca.cobranca_situacao_tipo cst ON csh.cbsp_id = cst.cbsp_id
	LEFT JOIN cadastro.imovel_cobranca_situacao ics_exi ON ics_exi.imov_id = imo.imov_id AND ics_exi.iscb_dtretiradacobranca IS NULL AND ics_exi.cbst_id = 23
	LEFT JOIN cobranca.cobranca_situacao cob_exi ON cob_exi.cbst_id = ics_exi.cbst_id
	LEFT JOIN cadastro.imovel_cobranca_situacao ics_ser ON ics_ser.imov_id = imo.imov_id AND ics_ser.iscb_dtretiradacobranca IS NULL AND ics_ser.cbst_id IN (24,25,26)
	LEFT JOIN cobranca.cobranca_situacao cob_ser ON cob_ser.cbst_id = ics_ser.cbst_id 
	LEFT JOIN cadastro.imovel_cobranca_situacao ics ON ics.imov_id = imo.imov_id AND ics.iscb_dtretiradacobranca IS NULL AND ics.cbst_id IN (12,14,17)
	LEFT JOIN cobranca.cobranca_situacao cob ON cob.cbst_id = ics.cbst_id 
	--LEFT JOIN arrecadacao.debito_automatico dab ON dab.imov_id = imo.imov_id AND dab.deba_dtexclusao IS NULL
	--LEFT JOIN arrecadacao.agencia age ON age.agen_id = dab.agen_id
	--LEFT JOIN arrecadacao.banco ban ON ban.bnco_id = age.bnco_id
	LEFT JOIN (	SELECT 
				con4.imov_id AS mat1,
				COUNT(distinct con4.cnta_id) AS qtd,
				SUM(dco.dbcb_vlprestacao) AS valor
			FROM faturamento.conta con4 
				INNER JOIN faturamento.debito_cobrado dco ON dco.cnta_id = con4.cnta_id AND dco.dbtp_id IN (40,43,44)
				INNER JOIN cadastro.localidade loc ON loc.loca_id = con4.loca_id
			WHERE
				loc.uneg_id = 11 AND
				con4.dcst_idatual IN (0,1,2) AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con4.cnta_id) AND con4.cnta_dtvencimentoconta < CURRENT_DATE AND con4.cnta_dtrevisao IS NULL AND con4.iper_id <> 6
			GROUP BY 1) AS con_parcelamento ON con_parcelamento.mat1 = imo.imov_id
	LEFT JOIN (	SELECT 
				con4.imov_id AS mat1,
				SUM(con4.cnta_vldebitos) AS vl_debitos,
				COUNT(con4.cnta_id) AS qtd,
				SUM(con4.cnta_vlagua + con4.cnta_vlesgoto + con4.cnta_vldebitos - con4.cnta_vlcreditos - con4.cnta_vlimpostos) AS valor
			FROM faturamento.conta con4 
			WHERE 
				con4.cnta_dtvencimentoconta BETWEEN CURRENT_DATE - INTERVAL '90 days' AND CURRENT_DATE - INTERVAL '30 days'
				AND con4.dcst_idatual IN (0,1,2) AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con4.cnta_id) AND con4.cnta_dtrevisao IS NULL AND con4.iper_id <> 6
				AND con4.cnta_dtrevisao IS NULL 
				AND con4.iper_id <> 6
				GROUP BY 1) AS con_atraso ON con_atraso.mat1 = imo.imov_id
	LEFT JOIN (	SELECT 
				con4.imov_id AS mat1,
				SUM(con4.cnta_vldebitos) AS vl_debitos,
				COUNT(con4.cnta_id) AS qtd,
				SUM(con4.cnta_vlagua + con4.cnta_vlesgoto + con4.cnta_vldebitos - con4.cnta_vlcreditos - con4.cnta_vlimpostos) AS valor
			FROM faturamento.conta con4 
			WHERE 
				con4.cnta_dtvencimentoconta <= CURRENT_DATE - INTERVAL '90 days'
				AND con4.dcst_idatual IN (0,1,2) AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con4.cnta_id) AND con4.cnta_dtrevisao IS NULL AND con4.iper_id <> 6
				AND con4.cnta_dtrevisao IS NULL 
				AND con4.iper_id <> 6
				GROUP BY 1) AS con_atraso90 ON con_atraso90.mat1 = imo.imov_id
	LEFT JOIN (	SELECT 
				con4.imov_id AS mat1,
				COUNT(con4.cnta_id) AS qtd,
				MIN(con4.cnta_amreferenciaconta) AS min,
				MAX(con4.cnta_amreferenciaconta) AS max,
				MIN(con4.cnta_dtvencimentoconta) AS min_venc,
				MAX(con4.cnta_dtvencimentoconta) AS max_venc,
				SUM(con4.cnta_vlagua + con4.cnta_vlesgoto + con4.cnta_vldebitos - con4.cnta_vlcreditos - con4.cnta_vlimpostos) AS valor
			FROM faturamento.conta con4 
			WHERE 
				con4.cnta_dtvencimentoconta <= CURRENT_DATE - INTERVAL '30 days'
				AND con4.dcst_idatual IN (0,1,2) AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con4.cnta_id) AND con4.cnta_dtrevisao IS NULL AND con4.iper_id <> 6
				AND con4.cnta_dtrevisao IS NULL 
				AND con4.iper_id <> 6
				GROUP BY 1) AS con_referencia ON con_referencia.mat1 = imo.imov_id

	LEFT JOIN ret_pendente ret_pend ON ret_pend.imov_id = imo.imov_id
WHERE
	imo.imov_icexclusao = 2 
	--AND imo.imov_id IN (38539)
	AND imo.iper_id <> 6
	AND loc.uneg_id IN (${VAR_UNIDADE})
	AND imo.imov_idcategoriaprincipal <> 4
	AND con_atraso.valor > 30
	--AND con_atraso.intervalo_corte = 'CORTE'

ORDER BY "NOME USUARIO","LOCALIDADE","SETOR COMERCIAL","ROTA","QUADRA","SEQUENCIA","SUB LOTE"
