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
FROM 
	atendimentopublico.ordem_servico os
	INNER JOIN atendimentopublico.servico_tipo svt ON svt.svtp_id = os.svtp_id
	LEFT JOIN cadastro.imovel imo ON imo.imov_id = os.imov_id
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
WHERE 
    os.orse_tmgeracao >= DATE '2026-01-01'
    AND (usu_ence.usur_nmusuario <> 'admin - GSAN' OR usu_ence.usur_nmusuario IS NULL)
    AND uno_geracao.unid_dsunidade <> 'COORDENADORIA DE CADASTRO'
    AND svt.svtp_dsservicotipo NOT LIKE '%ADM%'
    AND (os.imov_id is null OR os.imov_id is not null)

ORDER BY 
    os.orse_tmgeracao DESC;