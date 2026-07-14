SELECT 
	os.orse_id AS "NR OS",
	ra.rgat_id AS "NR RA",
	svt.svtp_dsservicotipo AS "TIPO SERVICO", 
	(CASE os.orse_cdsituacao
		WHEN 1 THEN 'PENDENTE'
		WHEN 2 THEN 'ENCERRADA'
		ELSE 'INDETERMINADO'
	END) AS "SITUACAO OS",
	(CASE svt.svtp_cdservicotipo
		WHEN 'C' THEN 'COMERCIAL'
		ELSE 'OPERACAO'
	END) AS "RESPONSAVEL",	 
	atm.amen_dsmotivoencerramento AS "TIPO DE ENCERRAMENTO",
	os.orse_dsobservacao AS "OBSERVACAO", 
	os.orse_dsparecerencerramento AS "PARECER", 
	os.imov_id AS "MATRICULA",
	las.last_dsligacaoaguasituacao AS "SIT. AGUA",
	rlia.rlin_dsramallocalinstalcao AS "LOCAL RAMAL AGUA",
	lad.lagd_dsligacaoaguadiametro AS "DIAMETRO RAMAL AGUA",
	lam.lagm_dsligacaoaguamaterial AS "MATERIAL RAMAL AGUA",
	les.lest_dsligacaoesgotosituacao AS "SIT. ESGOTO",
	rlie.rlin_dsramallocalinstalcao AS "LOCAL RAMAL ESGOTO",
	legd.legd_dsligacaoesgotodiametro AS "DIAMETRO RAMAL ESGOTO",
	legm.legm_dsligacaoesgotomaterial AS "MATERIAL RAMAL ESGOTO",	
	TO_CHAR(os.orse_tmgeracao, 'dd/MM/yyyy') AS "DATA GERACAO",
	CASE
		WHEN os.orse_cdsituacao = 1 THEN (CURRENT_DATE - os.orse_tmgeracao::DATE)::TEXT
		ELSE '' 
	END AS "DIAS PENDENTE",
	TO_CHAR(os.orse_tmencerramento, 'dd/MM/yyyy') AS "DATA ENCERRAMENTO",
	loc.uneg_id AS "GERENCIA",
	une.uneg_nmunidadenegocio AS "NOME UNIDADE",
	imo.loca_id AS "LOCALIDADE",
	loc.loca_nmlocalidade AS "NOME LOCALIDADE",
	sec.stcm_cdsetorcomercial AS "SETOR COMERCIAL",
	qdr.qdra_nnquadra AS "QUADRA",
	imo.imov_nnsequencialrota AS "SEQUENCIA",
	imo.imov_nnsublote AS "SUB LOTE",
	rot.rota_cdrota AS "ROTA",
	lgt.lgtp_dslogradourotipo AS "TIPO LOGRADOURO",
	logr.logr_nmlogradouro AS "NOME LOGRADOURO",
	cep.cep_cdcep AS "CEP",
	imo.imov_dscomplementoendereco AS "COMPLEMENTO",
	bai.bair_nmbairro AS "BAIRRO",
	imo.imov_nnimovel AS "NR",
	mun.muni_nmmunicipio AS "MUNICIPIO",
	uno_geracao.unid_dsunidade AS "SETOR DE GERACAO",
	usu_abrir.usur_nmlogin || ' - ' || usu_abrir.usur_nmusuario AS "USUARIO GERACAO",
	TO_CHAR(prg.pgrt_tmroteiro, 'dd/MM/YYYY') AS "DATA PROGRAMADA",
	uno_prog.unid_dsunidade AS "EXECUTOR PROGRAMADO",
	prgeqp.eqpe_nmequipe AS "EQUIPE PROGRAMADA",
	osp.ospg_nnseqprogramacao AS "SEQUENCIA PROGRAMADA",
	usu_prog.usur_nmlogin || ' - ' || usu_prog.usur_nmusuario AS "USUARIO PROGRAMADOR",
	uno_atual_os.unid_id::TEXT || ' - ' || uno_atual_os.unid_dsunidade AS "SETOR ATUAL O.S.",
	CASE
		WHEN os.orse_cdsituacao = 1 THEN (CURRENT_DATE - tra.tram_tmtramite::DATE)::TEXT
		ELSE '' 
	END AS "DIAS PENDENTE NO SETOR",
	uno_encerramento.unid_dsunidade AS "SETOR DE ENCERRAMENTO",
	usu_ence.usur_nmlogin || ' - ' || usu_ence.usur_nmusuario AS "USUARIO ENCERRAMENTO",
	TO_CHAR(oae.oape_tmexecucaoinicio, 'dd/MM/YYYY HH24:MI:ss') AS "INICIO EXECUCAO ATIVIDADE",
	TO_CHAR(oae.oape_tmexecucaofim, 'dd/MM/YYYY HH24:MI:ss') AS "FIM EXECUCAO ATIVIDADE",
	eqp.eqpe_nmequipe AS "EQUIPE ENCERRAMENTO",
	TO_CHAR(cdo.cbdo_vldocumento, 'L999G999G990D00') AS "VALOR COBRANCA",
	emp.empr_nmempresa AS "NOME EMPRESA",
	cds.cdst_dssituacaodebito AS "SIT DEBITO",
	cas.cast_dssituacaoacao AS "SIT ACAO COBRANCA",
	hid.hidr_nnhidrometro AS "NR HID.",
	hid.hidr_nnanofabricacao AS "ANO HD",
	his.hidi_dtinstalacaohidrometro AS "DATA DE INSTALACAO HD.",
	(
		SELECT
			TO_CHAR(MAX(hir.hidi_dtretiradahidrometro), 'dd/MM/yyyy')
		FROM
			micromedicao.hidrometro_inst_hist hir
		WHERE
			hir.lagu_id = imo.imov_id
		LIMIT 1
	) AS "ULTIMA RETIRADA DE HIDRO",
	(
		SELECT
			STRING_AGG('EMS: '|| TO_CHAR(par.parc_tmparcelamento, 'dd/MM/yyyy') || ' <-> SIT: ' || pcs.pcst_dsparcelamentosituacao, ' | ')
		FROM
			cobranca.parcelamento par
			INNER JOIN cobranca.parcelamento_situacao pcs ON pcs.pcst_id = par.pcst_id
		WHERE
			par.imov_id = imo.imov_id
	) AS "HISTORICO PARCELAMENTOS"
/*	TO_CHAR(con_atraso.vl_agua, '999G999G990D00') AS "VALOR AGUA DEVIDO",
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
	TO_CHAR(con_atraso.multa, '999G999G990D00') AS "MULTAS",
	TO_CHAR(con_atraso.juros, '999G999G990D00') AS "JUROS",
	TO_CHAR((con_atraso.multa+con_atraso.juros+con_atraso.valor), '999G999G990D00') AS "VALOR TOTAL COM JUROS",
	TO_CHAR(gpg.valor, '999G999G990D00') AS "VALOR GUIAS"*/
FROM 
	atendimentopublico.ordem_servico os
	INNER JOIN atendimentopublico.servico_tipo svt ON svt.svtp_id = os.svtp_id
	INNER JOIN cadastro.imovel imo ON imo.imov_id = os.imov_id
	INNER JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
	INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
	INNER JOIN cadastro.setor_comercial sec ON imo.stcm_id = sec.stcm_id
	INNER JOIN cadastro.quadra qdr ON qdr.qdra_id = imo.qdra_id
	INNER JOIN micromedicao.rota rot ON rot.rota_id = qdr.rota_id
	INNER JOIN cadastro.logradouro_bairro lgb ON lgb.lgbr_id = imo.lgbr_id
	INNER JOIN cadastro.logradouro logr ON lgb.logr_id = logr.logr_id
	INNER JOIN cadastro.bairro bai ON bai.bair_id = lgb.bair_id
	INNER JOIN cadastro.municipio mun ON mun.muni_id = bai.muni_id
	LEFT JOIN cadastro.logradouro_cep lgc ON lgc.lgcp_id = imo.lgcp_id
	LEFT JOIN cadastro.cep cep ON cep.cep_id = lgc.cep_id
	LEFT JOIN cadastro.logradouro_tipo lgt ON lgt.lgtp_id = logr.lgtp_id
	LEFT JOIN cadastro.unidade_organizacional uno_atual_os ON uno_atual_os.unid_id = os.unid_idatual
	LEFT JOIN atendimentopublico.ordem_servico_atividade osa ON osa.orse_id = os.orse_id
	LEFT JOIN atendimentopublico.os_ativ_periodo_execucao oae ON oae.osat_id = osa.osat_id
	LEFT JOIN atendimentopublico.os_execucao_equipe ose ON oae.oape_id = ose.oape_id
	LEFT JOIN atendimentopublico.ordem_servico_unidade osu_abrir ON osu_abrir.orse_id = os.orse_id AND osu_abrir.attp_id = 1
	LEFT JOIN cadastro.unidade_organizacional uno_geracao ON uno_geracao.unid_id = osu_abrir.unid_id
	LEFT JOIN atendimentopublico.ordem_servico_unidade osu_ence ON osu_ence.orse_id = os.orse_id AND osu_ence.attp_id = 3
	LEFT JOIN cadastro.unidade_organizacional uno_encerramento ON uno_encerramento.unid_id = osu_ence.unid_id
	LEFT JOIN seguranca.usuario usu_abrir ON usu_abrir.usur_id = osu_abrir.usur_id
	LEFT JOIN seguranca.usuario usu_ence ON usu_ence.usur_id = osu_ence.usur_id
	LEFT JOIN atendimentopublico.equipe eqp ON eqp.eqpe_id = ose.eqpe_id
	LEFT JOIN cobranca.cobranca_documento cdo ON cdo.cbdo_id = os.cbdo_id
	LEFT JOIN cadastro.empresa emp ON emp.empr_id = cdo.empr_id
	LEFT JOIN cobranca.cobranca_debito_situacao cds ON cds.cdst_id = cdo.cdst_id
	LEFT JOIN cobranca.cobranca_acao_situacao cas ON cas.cast_id = cdo.cast_id
	LEFT JOIN atendimentopublico.atend_motivo_encmt atm ON atm.amen_id = os.amen_id
	LEFT JOIN atendimentopublico.os_programacao osp ON osp.orse_id = os.orse_id
	LEFT JOIN atendimentopublico.equipe prgeqp ON prgeqp.eqpe_id = osp.eqpe_id
	LEFT JOIN seguranca.usuario usu_prog ON usu_prog.usur_id = osp.usur_idprogramacao
	LEFT JOIN atendimentopublico.programacao_roteiro prg ON prg.pgrt_id = osp.pgrt_id
	LEFT JOIN cadastro.unidade_organizacional uno_prog ON uno_prog.unid_id = prg.unid_id
	LEFT JOIN atendimentopublico.ligacao_agua lagu ON lagu.lagu_id = imo.imov_id
	
	LEFT JOIN atendimentopublico.ligacao_agua_situacao las ON las.last_id = imo.last_id
	LEFT JOIN atendimentopublico.ramal_local_instalacao rlia ON rlia.rlin_id = lagu.rlin_id
	LEFT JOIN atendimentopublico.ligacao_agua_diametro lad ON lad.lagd_id = lagu.lagd_id
	LEFT JOIN atendimentopublico.ligacao_agua_material lam ON lam.lagm_id = lagu.lagm_id

	LEFT JOIN atendimentopublico.ligacao_esgoto lesg ON lesg.lesg_id = imo.imov_id
	LEFT JOIN atendimentopublico.ligacao_esgoto_situacao les ON les.lest_id = imo.lest_id
	LEFT JOIN atendimentopublico.ramal_local_instalacao rlie ON rlie.rlin_id = lesg.rlin_id
	LEFT JOIN atendimentopublico.ligacao_esgoto_diametro legd ON legd.legd_id = lesg.legd_id
	LEFT JOIN atendimentopublico.ligacao_esgoto_material legm ON legm.legm_id = lesg.legm_id

	LEFT JOIN micromedicao.hidrometro_inst_hist his ON lagu.hidi_id = his.hidi_id AND his.hidi_dtretiradahidrometro IS NULL
	LEFT JOIN micromedicao.hidrometro hid ON his.hidr_id = hid.hidr_id
	LEFT JOIN atendimentopublico.registro_atendimento ra ON ra.rgat_id = os.rgat_id
	LEFT JOIN atendimentopublico.tramite tra ON tra.tram_id = (SELECT MAX(tra.tram_id) FROM atendimentopublico.tramite tra WHERE tra.rgat_id = ra.rgat_id AND tra.unid_iddestino = os.unid_idatual)
/*	LEFT JOIN (	SELECT 
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
	LEFT JOIN(
			SELECT 
				gpg.imov_id AS imov_id,
				SUM(gpg.gpag_vldebito) AS valor
			FROM 
				faturamento.guia_pagamento gpg 
			WHERE
				gpg.dcst_idatual = 0 
				AND NOT EXISTS ( SELECT pag.gpag_id FROM arrecadacao.pagamento pag WHERE pag.gpag_id = gpg.gpag_id)
			GROUP BY 1) AS gpg ON gpg.imov_id = imo.imov_id*/
WHERE 
	os.orse_tmgeracao between '2021-01-01' and current_date
	AND une.uneg_id IN (2,3,4,5,6,7,8,9,10,11,12,13,14,15,20,21)
	AND (os.imov_id IS NULL or os.imov_id IS NOT NULL)
/*	--and os.orse_cdsituacao = 1
UNION
SELECT 
	os.orse_id AS "NR OS",
	ra.rgat_id AS "NR RA",
	svt.svtp_dsservicotipo AS "TIPO SERVICO",
	(CASE os.orse_cdsituacao
		WHEN 1 THEN 'PENDENTE'
		WHEN 2 THEN 'ENCERRADA'
		ELSE 'INDETERMINADO'
	END) AS "SITUACAO OS",
	(CASE svt.svtp_cdservicotipo
		WHEN 'C' THEN 'COMERCIAL'
		ELSE 'OPERACAO'
	END) AS "RESPONSAVEL",	 	 
	atm.amen_dsmotivoencerramento AS "TIPO DE ENCERRAMENTO",
	os.orse_dsobservacao AS "OBSERVACAO", 
	os.orse_dsparecerencerramento AS "PARECER", 
	os.imov_id AS "MATRICULA",
	'' AS "SIT. AGUA",
	'' AS "LOCAL RAMAL AGUA",
	'' AS "DIAMETRO RAMAL AGUA",
	'' AS "MATERIAL RAMAL AGUA",
	'' AS "SIT. ESGOTO",
	'' AS "LOCAL RAMAL ESGOTO",
	'' AS "DIAMETRO RAMAL ESGOTO",
	'' AS "MATERIAL RAMAL ESGOTO",	
	'' AS "DATA GERACAO",
	CASE
		WHEN os.orse_cdsituacao = 1 THEN (CURRENT_DATE - os.orse_tmgeracao::DATE)::TEXT
		ELSE '' 
	END AS "DIAS PENDENTE",
	TO_CHAR(os.orse_tmencerramento, 'dd/MM/yyyy') AS "DATA ENCERRAMENTO",
	loc.uneg_id AS "GERENCIA",
	une.uneg_nmunidadenegocio AS "NOME UNIDADE",
	imo.loca_id AS "LOCALIDADE",
	loc.loca_nmlocalidade AS "NOME LOCALIDADE",
	sec.stcm_cdsetorcomercial AS "SETOR COMERCIAL",
	qdr.qdra_nnquadra AS "QUADRA",
	imo.imov_nnsequencialrota AS "SEQUENCIA",
	imo.imov_nnsublote AS "SUB LOTE",
	rot.rota_cdrota AS "ROTA",
	lgt.lgtp_dslogradourotipo AS "TIPO LOGRADOURO",
	logr.logr_nmlogradouro AS "NOME LOGRADOURO",
	cep.cep_cdcep AS "CEP",
	imo.imov_dscomplementoendereco AS "COMPLEMENTO",
	bai.bair_nmbairro AS "BAIRRO",
	imo.imov_nnimovel AS "NR",
	mun.muni_nmmunicipio AS "MUNICIPIO",
	uno_geracao.unid_dsunidade AS "SETOR DE GERACAO",
	usu_abrir.usur_nmlogin || ' - ' || usu_abrir.usur_nmusuario AS "USUARIO GERACAO",
	TO_CHAR(prg.pgrt_tmroteiro, 'dd/MM/YYYY') AS "DATA PROGRAMADA",
	uno_prog.unid_dsunidade AS "EXECUTOR PROGRAMADO",
	prgeqp.eqpe_nmequipe AS "EQUIPE PROGRAMADA",
	osp.ospg_nnseqprogramacao AS "SEQUENCIA PROGRAMADA",
	usu_prog.usur_nmlogin || ' - ' || usu_prog.usur_nmusuario AS "USUARIO PROGRAMADOR",
	uno_atual_os.unid_id::TEXT || ' - ' || uno_atual_os.unid_dsunidade AS "SETOR ATUAL O.S.",
	CASE
		WHEN os.orse_cdsituacao = 1 THEN (CURRENT_DATE - tra.tram_tmtramite::DATE)::TEXT
		ELSE '' 
	END AS "DIAS PENDENTE NO SETOR",
	uno_encerramento.unid_dsunidade AS "SETOR DE ENCERRAMENTO",
	usu_ence.usur_nmlogin || ' - ' || usu_ence.usur_nmusuario AS "USUARIO ENCERRAMENTO",
	TO_CHAR(oae.oape_tmexecucaoinicio, 'dd/MM/YYYY HH24:MI:ss') AS "INICIO EXECUCAO ATIVIDADE",
	TO_CHAR(oae.oape_tmexecucaofim, 'dd/MM/YYYY HH24:MI:ss') AS "FIM EXECUCAO ATIVIDADE",
	eqp.eqpe_nmequipe AS "EQUIPE ENCERRAMENTO",
	TO_CHAR(cdo.cbdo_vldocumento, 'L999G999G990D00') AS "VALOR COBRANCA",
	emp.empr_nmempresa AS "NOME EMPRESA",
	cds.cdst_dssituacaodebito AS "SIT DEBITO",
	cas.cast_dssituacaoacao AS "SIT ACAO COBRANCA",
	'' "NR HID.",
	0 AS "ANO HD",
	CAST(NULL AS DATE) AS "DATA DE INSTALACAO HD.",
	'' AS "ULTIMA RETIRADA DE HIDRO",
	'' AS "HISTORICO PARCELAMENTOS",
	CAST(NULL AS VARCHAR) AS "VALOR AGUA DEVIDO",
	CAST(NULL AS VARCHAR) AS "VALOR ESGOTO DEVIDO",
	CAST(NULL AS VARCHAR) AS "VALOR DEBITOS DEVIDO",
	CAST(NULL AS VARCHAR) AS "VALOR CREDITOS DEVIDO",
	CAST(NULL AS VARCHAR) AS "VALOR IMPOSTOS DEVIDO",
	CAST(NULL AS VARCHAR) AS "VALOR TOTAL DEVIDO",
	0 AS "QTD. CONTAS DEVIDO",
	0 AS "MENOR REFERENCIA DEVIDO",
	0 AS "MAIOR REFERENCIA DEVIDO",
	CAST(NULL AS DATE) AS "MENOR VENCIMENTO",
	CAST(NULL AS DATE) AS "MAIOR VENCIMENTO",
	CAST(NULL AS VARCHAR) AS "MULTAS",
	CAST(NULL AS VARCHAR) AS "JUROS",
	CAST(NULL AS VARCHAR) AS "VALOR TOTAL COM JUROS",
	CAST(NULL AS VARCHAR) AS "VALOR GUIAS"
FROM 
	atendimentopublico.ordem_servico os
	INNER JOIN atendimentopublico.servico_tipo svt ON svt.svtp_id = os.svtp_id
	INNER JOIN cadastro.imovel imo ON imo.imov_id = os.imov_id
	INNER JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
	INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
	INNER JOIN cadastro.setor_comercial sec ON imo.stcm_id = sec.stcm_id
	INNER JOIN cadastro.quadra qdr ON qdr.qdra_id = imo.qdra_id
	INNER JOIN micromedicao.rota rot ON rot.rota_id = qdr.rota_id
	INNER JOIN cadastro.logradouro_bairro lgb ON lgb.lgbr_id = imo.lgbr_id
	INNER JOIN cadastro.logradouro logr ON lgb.logr_id = logr.logr_id
	INNER JOIN cadastro.bairro bai ON bai.bair_id = lgb.bair_id
	INNER JOIN cadastro.municipio mun ON mun.muni_id = bai.muni_id
	LEFT JOIN cadastro.logradouro_cep lgc ON lgc.lgcp_id = imo.lgcp_id
	LEFT JOIN cadastro.cep cep ON cep.cep_id = lgc.cep_id
	LEFT JOIN cadastro.logradouro_tipo lgt ON lgt.lgtp_id = logr.lgtp_id
	LEFT JOIN cadastro.unidade_organizacional uno_atual_os ON uno_atual_os.unid_id = os.unid_idatual
	LEFT JOIN atendimentopublico.ordem_servico_atividade osa ON osa.orse_id = os.orse_id
	LEFT JOIN atendimentopublico.os_ativ_periodo_execucao oae ON oae.osat_id = osa.osat_id
	LEFT JOIN atendimentopublico.os_execucao_equipe ose ON oae.oape_id = ose.oape_id
	LEFT JOIN atendimentopublico.ordem_servico_unidade osu_abrir ON osu_abrir.orse_id = os.orse_id AND osu_abrir.attp_id = 1
	LEFT JOIN cadastro.unidade_organizacional uno_geracao ON uno_geracao.unid_id = osu_abrir.unid_id
	LEFT JOIN atendimentopublico.ordem_servico_unidade osu_ence ON osu_ence.orse_id = os.orse_id AND osu_ence.attp_id = 3
	LEFT JOIN cadastro.unidade_organizacional uno_encerramento ON uno_encerramento.unid_id = osu_ence.unid_id
	LEFT JOIN seguranca.usuario usu_abrir ON usu_abrir.usur_id = osu_abrir.usur_id
	LEFT JOIN seguranca.usuario usu_ence ON usu_ence.usur_id = osu_ence.usur_id
	LEFT JOIN atendimentopublico.equipe eqp ON eqp.eqpe_id = ose.eqpe_id
	LEFT JOIN cobranca.cobranca_documento cdo ON cdo.cbdo_id = os.cbdo_id
	LEFT JOIN cadastro.empresa emp ON emp.empr_id = cdo.empr_id
	LEFT JOIN cobranca.cobranca_debito_situacao cds ON cds.cdst_id = cdo.cdst_id
	LEFT JOIN cobranca.cobranca_acao_situacao cas ON cas.cast_id = cdo.cast_id
	LEFT JOIN atendimentopublico.atend_motivo_encmt atm ON atm.amen_id = os.amen_id
	LEFT JOIN atendimentopublico.os_programacao osp ON osp.orse_id = os.orse_id
	LEFT JOIN atendimentopublico.equipe prgeqp ON prgeqp.eqpe_id = osp.eqpe_id
	LEFT JOIN seguranca.usuario usu_prog ON usu_prog.usur_id = osp.usur_idprogramacao
	LEFT JOIN atendimentopublico.programacao_roteiro prg ON prg.pgrt_id = osp.pgrt_id
	LEFT JOIN cadastro.unidade_organizacional uno_prog ON uno_prog.unid_id = prg.unid_id
	--LEFT JOIN atendimentopublico.ligacao_agua lagu ON lagu.lagu_id = imo.imov_id
--	
	--LEFT JOIN atendimentopublico.ligacao_agua_situacao las ON las.last_id = imo.last_id
	--LEFT JOIN atendimentopublico.ramal_local_instalacao rlia ON rlia.rlin_id = lagu.rlin_id
	--LEFT JOIN atendimentopublico.ligacao_agua_diametro lad ON lad.lagd_id = lagu.lagd_id
	--LEFT JOIN atendimentopublico.ligacao_agua_material lam ON lam.lagm_id = lagu.lagm_id

	--LEFT JOIN atendimentopublico.ligacao_esgoto lesg ON lesg.lesg_id = imo.imov_id
	--LEFT JOIN atendimentopublico.ligacao_esgoto_situacao les ON les.lest_id = imo.lest_id
	--LEFT JOIN atendimentopublico.ramal_local_instalacao rlie ON rlie.rlin_id = lesg.rlin_id
	--LEFT JOIN atendimentopublico.ligacao_esgoto_diametro legd ON legd.legd_id = lesg.legd_id
	--LEFT JOIN atendimentopublico.ligacao_esgoto_material legm ON legm.legm_id = lesg.legm_id
--
--	LEFT JOIN micromedicao.hidrometro_inst_hist his ON lagu.hidi_id = his.hidi_id AND his.hidi_dtretiradahidrometro IS NULL
--	LEFT JOIN micromedicao.hidrometro hid ON his.hidr_id = hid.hidr_id
	LEFT JOIN atendimentopublico.registro_atendimento ra ON ra.rgat_id = os.rgat_id
	LEFT JOIN atendimentopublico.tramite tra ON tra.tram_id = (SELECT MAX(tra.tram_id) FROM atendimentopublico.tramite tra WHERE tra.rgat_id = ra.rgat_id AND tra.unid_iddestino = os.unid_idatual)
WHERE 
	os.orse_tmgeracao between '2021-01-01' and current_date
	AND os.imov_id IS NULL
	--and os.orse_cdsituacao = 1
	AND une.uneg_id IN (2,3,4,5,6,7,8,9,10,11,12,13,14,15,20,21)*/