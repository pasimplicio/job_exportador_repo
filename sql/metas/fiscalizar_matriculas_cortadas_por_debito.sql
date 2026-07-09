
WITH
/* =====================================================
   1 - MATRÍCULAS CORTADAS ELEGÍVEIS
   ===================================================== */
cortados_elegiveis AS (
    SELECT
        i.imov_id,
        i.loca_id,
        lo.uneg_id,
        la.lagu_dtcorte
    FROM cadastro.imovel i
    INNER JOIN atendimentopublico.ligacao_agua la
        ON la.lagu_id = i.imov_id
    INNER JOIN cadastro.localidade lo
        ON lo.loca_id = i.loca_id
    WHERE la.mtco_id IN (2, 5, 6)
      AND (
            la.lagu_dtcorte > la.lagu_dtreligacaoagua
            OR (la.lagu_dtreligacaoagua IS NULL AND la.lagu_dtcorte IS NOT NULL)
          )
      AND (i.ftst_id  NOT IN (1, 5) OR i.ftst_id IS NULL)
      AND i.iper_id  <> 6
      AND lo.uneg_id NOT IN (17, 18, 19)
      AND NOT EXISTS (
            SELECT 1
            FROM atendimentopublico.ordem_servico os
            WHERE os.imov_id = i.imov_id
              AND os.svtp_id IN (917, 927, 928, 863, 7165, 898, 661,
                                  59,  60,  61,  23,  34, 859,  58, 56)
              AND os.orse_tmencerramento IS NULL
      )
),
/* =====================================================
   2 - ORDEM DE SERVICO DE FISCALIZACAO
   - svtp_id 351 - FISCALIZAÇÃO DE IRREGULARIDADE
   - OS gerada em 2026
   - Excluir motivos de encerramento: 5, 27, 32
   - Se houver mais de uma OS válida, pega a mais recente
   ===================================================== */
os_fiscalizacao AS (
    SELECT
        os.imov_id,
        MAX(os.orse_tmgeracao) AS dt_fiscalizacao
    FROM atendimentopublico.ordem_servico os
    INNER JOIN cortados_elegiveis ce
        ON ce.imov_id = os.imov_id
    WHERE os.orse_tmgeracao >= DATE '2026-01-01'
      AND os.svtp_id = 351
      AND NOT EXISTS (
            SELECT 1
            FROM atendimentopublico.atend_motivo_encmt ame
            WHERE ame.amen_id = os.amen_id
              AND ame.amen_id IN (5, 27, 32)
      )
    GROUP BY os.imov_id
)
/* =====================================================
   3 - RESULTADO FINAL
   ===================================================== */
SELECT
    ce.imov_id                                                                                                         AS "MATRICULA",
    ce.loca_id                                                                                                         AS "ID LOCALIDADE",
    une.uneg_nmunidadenegocio                                    AS "UNIDADE",
    ce.lagu_dtcorte                                              AS "DATA DE CORTE",
    CASE WHEN osf.imov_id IS NOT NULL THEN 'Sim' ELSE 'Não' END  AS "FISCALIZADO?",
    osf.dt_fiscalizacao                                          AS "DATA DE FISCALIZACAO"
FROM cortados_elegiveis ce
INNER JOIN cadastro.unidade_negocio une
    ON une.uneg_id = ce.uneg_id
LEFT JOIN os_fiscalizacao osf
    ON osf.imov_id = ce.imov_id
ORDER BY
    une.uneg_nmunidadenegocio,
    ce.loca_id;

 	
WITH
/* =====================================================
   1 - MATRÍCULAS CORTADAS ELEGÍVEIS
   ===================================================== */
cortados_elegiveis AS (
    SELECT
        i.imov_id,
        i.loca_id,
        lo.uneg_id,
        la.lagu_dtcorte
    FROM cadastro.imovel i
    INNER JOIN atendimentopublico.ligacao_agua la
        ON la.lagu_id = i.imov_id
    INNER JOIN cadastro.localidade lo
        ON lo.loca_id = i.loca_id
    WHERE la.mtco_id IN (2, 5, 6)
      AND (
            la.lagu_dtcorte > la.lagu_dtreligacaoagua
            OR (la.lagu_dtreligacaoagua IS NULL AND la.lagu_dtcorte IS NOT NULL)
          )
      AND (i.ftst_id  NOT IN (1, 5) OR i.ftst_id IS NULL)
      AND i.iper_id  <> 6
      AND lo.uneg_id NOT IN (17, 18, 19)
      AND NOT EXISTS (
            SELECT 1
            FROM atendimentopublico.ordem_servico os
            WHERE os.imov_id = i.imov_id
              AND os.svtp_id IN (917, 927, 928, 863, 7165, 898, 661,
                                  59,  60,  61,  23,  34, 859,  58, 56)
              AND os.orse_tmencerramento IS NULL
      )
),
/* =====================================================
   2 - ORDEM DE SERVICO DE FISCALIZACAO
   - svtp_id 351 - FISCALIZAÇÃO DE IRREGULARIDADE
   - OS gerada em 2026
   - Excluir motivos de encerramento: 5, 27, 32
   - Se houver mais de uma OS válida, pega a mais recente
   ===================================================== */
os_fiscalizacao AS (
    SELECT
        os.imov_id,
        MAX(os.orse_tmgeracao) AS dt_fiscalizacao
    FROM atendimentopublico.ordem_servico os
    INNER JOIN cortados_elegiveis ce
        ON ce.imov_id = os.imov_id
    WHERE os.orse_tmgeracao >= DATE '2026-01-01'
      AND os.svtp_id = 351
      AND NOT EXISTS (
            SELECT 1
            FROM atendimentopublico.atend_motivo_encmt ame
            WHERE ame.amen_id = os.amen_id
              AND ame.amen_id IN (5, 27, 32)
      )
    GROUP BY os.imov_id
)
/* =====================================================
   3 - RESULTADO FINAL
   ===================================================== */
SELECT
    ce.imov_id                                                                                                         AS "MATRICULA",
    ce.loca_id                                                                                                         AS "ID LOCALIDADE",
    une.uneg_nmunidadenegocio                                    AS "UNIDADE",
    ce.lagu_dtcorte                                              AS "DATA DE CORTE",
    CASE WHEN osf.imov_id IS NOT NULL THEN 'Sim' ELSE 'Não' END  AS "FISCALIZADO?",
    osf.dt_fiscalizacao                                          AS "DATA DE FISCALIZACAO"
FROM cortados_elegiveis ce
INNER JOIN cadastro.unidade_negocio une
    ON une.uneg_id = ce.uneg_id
LEFT JOIN os_fiscalizacao osf
    ON osf.imov_id = ce.imov_id
ORDER BY
    une.uneg_nmunidadenegocio,
    ce.loca_id;