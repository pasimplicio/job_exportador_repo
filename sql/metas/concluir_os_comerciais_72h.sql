SELECT 
    os.orse_id AS "NR OS",
    une.uneg_nmunidadenegocio AS "NOME UNIDADE",
    imo.loca_id AS "LOCALIDADE",
    loc.loca_nmlocalidade AS "NOME LOCALIDADE",
    svt.svtp_dsservicotipo AS "TIPO SERVICO", 
    CASE svt.svtp_cdservicotipo
        WHEN 'C' THEN 'COMERCIAL'
        ELSE 'OPERACAO'
    END AS "RESPONSAVEL",
    uno_atual_os.unid_id::TEXT || ' - ' || uno_atual_os.unid_dsunidade AS "SETOR ATUAL O.S.",
    CASE os.orse_cdsituacao
        WHEN 1 THEN 'PENDENTE'
        WHEN 2 THEN 'ENCERRADA'
        ELSE 'INDETERMINADO'
    END AS "SITUACAO OS",
    os.orse_tmgeracao AS "DATA GERACAO",
    os.orse_tmencerramento AS "DATA ENCERRAMENTO"
FROM atendimentopublico.ordem_servico os
INNER JOIN atendimentopublico.servico_tipo svt 
    ON svt.svtp_id = os.svtp_id
INNER JOIN cadastro.imovel imo 
    ON imo.imov_id = os.imov_id
INNER JOIN cadastro.localidade loc 
    ON imo.loca_id = loc.loca_id
INNER JOIN cadastro.unidade_negocio une 
    ON une.uneg_id = loc.uneg_id
INNER JOIN cadastro.setor_comercial sec 
    ON imo.stcm_id = sec.stcm_id
INNER JOIN cadastro.quadra qdr 
    ON qdr.qdra_id = imo.qdra_id
INNER JOIN micromedicao.rota rot 
    ON rot.rota_id = qdr.rota_id
INNER JOIN cadastro.logradouro_bairro lgb 
    ON lgb.lgbr_id = imo.lgbr_id
INNER JOIN cadastro.logradouro logr 
    ON lgb.logr_id = logr.logr_id
INNER JOIN cadastro.bairro bai 
    ON bai.bair_id = lgb.bair_id
INNER JOIN cadastro.municipio mun 
    ON mun.muni_id = bai.muni_id
LEFT JOIN cadastro.logradouro_cep lgc 
    ON lgc.lgcp_id = imo.lgcp_id
LEFT JOIN cadastro.cep cep 
    ON cep.cep_id = lgc.cep_id
LEFT JOIN cadastro.logradouro_tipo lgt 
    ON lgt.lgtp_id = logr.lgtp_id
LEFT JOIN cadastro.unidade_organizacional uno_atual_os 
    ON uno_atual_os.unid_id = os.unid_idatual
LEFT JOIN atendimentopublico.ordem_servico_atividade osa 
    ON osa.orse_id = os.orse_id
LEFT JOIN atendimentopublico.os_ativ_periodo_execucao oae 
    ON oae.osat_id = osa.osat_id
LEFT JOIN atendimentopublico.os_execucao_equipe ose 
    ON oae.oape_id = ose.oape_id
LEFT JOIN atendimentopublico.ordem_servico_unidade osu_abrir 
    ON osu_abrir.orse_id = os.orse_id 
   AND osu_abrir.attp_id = 1
LEFT JOIN cadastro.unidade_organizacional uno_geracao 
    ON uno_geracao.unid_id = osu_abrir.unid_id
LEFT JOIN atendimentopublico.ordem_servico_unidade osu_ence 
    ON osu_ence.orse_id = os.orse_id 
   AND osu_ence.attp_id = 3
LEFT JOIN cadastro.unidade_organizacional uno_encerramento 
    ON uno_encerramento.unid_id = osu_ence.unid_id
LEFT JOIN seguranca.usuario usu_abrir 
    ON usu_abrir.usur_id = osu_abrir.usur_id
LEFT JOIN seguranca.usuario usu_ence 
    ON usu_ence.usur_id = osu_ence.usur_id
LEFT JOIN atendimentopublico.equipe eqp 
    ON eqp.eqpe_id = ose.eqpe_id
LEFT JOIN cobranca.cobranca_documento cdo 
    ON cdo.cbdo_id = os.cbdo_id
LEFT JOIN cadastro.empresa emp 
    ON emp.empr_id = cdo.empr_id
LEFT JOIN cobranca.cobranca_debito_situacao cds 
    ON cds.cdst_id = cdo.cdst_id
LEFT JOIN cobranca.cobranca_acao_situacao cas 
    ON cas.cast_id = cdo.cast_id
LEFT JOIN atendimentopublico.atend_motivo_encmt atm 
    ON atm.amen_id = os.amen_id
LEFT JOIN atendimentopublico.os_programacao osp 
    ON osp.orse_id = os.orse_id
LEFT JOIN atendimentopublico.equipe prgeqp 
    ON prgeqp.eqpe_id = osp.eqpe_id
LEFT JOIN seguranca.usuario usu_prog 
    ON usu_prog.usur_id = osp.usur_idprogramacao
LEFT JOIN atendimentopublico.programacao_roteiro prg 
    ON prg.pgrt_id = osp.pgrt_id
LEFT JOIN cadastro.unidade_organizacional uno_prog 
    ON uno_prog.unid_id = prg.unid_id
LEFT JOIN atendimentopublico.ligacao_agua lagu 
    ON lagu.lagu_id = imo.imov_id
LEFT JOIN atendimentopublico.ligacao_agua_situacao las 
    ON las.last_id = imo.last_id
LEFT JOIN atendimentopublico.ramal_local_instalacao rlia 
    ON rlia.rlin_id = lagu.rlin_id
LEFT JOIN atendimentopublico.ligacao_agua_diametro lad 
    ON lad.lagd_id = lagu.lagd_id
LEFT JOIN atendimentopublico.ligacao_agua_material lam 
    ON lam.lagm_id = lagu.lagm_id
LEFT JOIN atendimentopublico.ligacao_esgoto lesg 
    ON lesg.lesg_id = imo.imov_id
LEFT JOIN atendimentopublico.ligacao_esgoto_situacao les 
    ON les.lest_id = imo.lest_id
LEFT JOIN atendimentopublico.ramal_local_instalacao rlie 
    ON rlie.rlin_id = lesg.rlin_id
LEFT JOIN atendimentopublico.ligacao_esgoto_diametro legd 
    ON legd.legd_id = lesg.legd_id
LEFT JOIN atendimentopublico.ligacao_esgoto_material legm 
    ON legm.legm_id = lesg.legm_id
LEFT JOIN micromedicao.hidrometro_inst_hist his 
    ON lagu.hidi_id = his.hidi_id 
   AND his.hidi_dtretiradahidrometro IS NULL
LEFT JOIN micromedicao.hidrometro hid 
    ON his.hidr_id = hid.hidr_id
LEFT JOIN atendimentopublico.registro_atendimento ra 
    ON ra.rgat_id = os.rgat_id
WHERE 
     os.orse_tmgeracao >= '2026-01-01'
    AND (usu_ence.usur_nmusuario <> 'admin - GSAN')
    AND (uno_geracao.unid_dsunidade <> 'COORDENADORIA DE CADASTRO')
    AND (svt.svtp_dsservicotipo NOT LIKE '%ADM%')
ORDER BY 
    os.orse_tmgeracao DESC;