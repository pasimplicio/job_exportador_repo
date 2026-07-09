/* =========================================================
   1) BASE DO RA (registro de atendimento)
   - Dados do RA, tipo, meio, usuarios/unidades de geracao e encerramento
   - Tempo de atendimento em horas = (encerramento - abertura)
   ========================================================= */
WITH ra_base AS (
    SELECT
        ra.rgat_id,
        ra.imov_id,
        ra.rgat_cdsituacao,
        ste.step_dssolcttipoespec,
        st.sotp_id,
        st.sotp_dssolicitacaotipo,
        mes.meso_dsmeiosolicitacao,
        ra.rgat_tmregistroatendimento,
        ra.rgat_tmencerramento,
        ra.rgat_dsobservacao,
        ra.rgat_dsparecerencerramento,
        ame.amen_dsmotivoencerramento,

        /* usuario e unidade de geracao */
        usu_geracao.usur_nmlogin   AS login_geracao,
        usu_geracao.usur_nmusuario AS usuario_geracao,
        uno_geracao.unid_dsunidade AS unidade_geracao,

        /* usuario e unidade de encerramento */
        usu_encerramento.usur_nmlogin   AS login_encerramento,
        usu_encerramento.usur_nmusuario AS usuario_encerramento,
        uno_encerramento.unid_dsunidade AS unidade_encerramento,

        /* unidade atual do RA */
        uno_atual.unid_dsunidade AS unidade_atual,

        /* tempo de atendimento em horas (encerramento - abertura) */
        CASE
            WHEN ra.rgat_tmencerramento IS NULL OR ra.rgat_tmregistroatendimento IS NULL THEN NULL
            ELSE EXTRACT(EPOCH FROM (ra.rgat_tmencerramento - ra.rgat_tmregistroatendimento)) / 3600
        END AS tempo_atendimento_horas

    FROM atendimentopublico.registro_atendimento ra
    LEFT JOIN atendimentopublico.solicitacao_tipo_espec ste
        ON ste.step_id = ra.step_id
    LEFT JOIN atendimentopublico.solicitacao_tipo st ON st.sotp_id = ste.sotp_id
    LEFT JOIN atendimentopublico.meio_solicitacao mes
        ON mes.meso_id = ra.meso_id

    /* unidade e usuario de geracao (attp_id = 1) */
    LEFT JOIN atendimentopublico.ra_unidade rau
        ON rau.rgat_id = ra.rgat_id
       AND rau.attp_id = 1
    LEFT JOIN cadastro.unidade_organizacional uno_geracao
        ON uno_geracao.unid_id = rau.unid_id
    LEFT JOIN seguranca.usuario usu_geracao
        ON usu_geracao.usur_id = rau.usur_id

    /* unidade e usuario de encerramento (attp_id = 3) */
    LEFT JOIN atendimentopublico.ra_unidade rau_enc
        ON rau_enc.rgat_id = ra.rgat_id
       AND rau_enc.attp_id = 3
    LEFT JOIN cadastro.unidade_organizacional uno_encerramento
        ON uno_encerramento.unid_id = rau_enc.unid_id
    LEFT JOIN seguranca.usuario usu_encerramento
        ON usu_encerramento.usur_id = rau_enc.usur_id

    /* unidade atual */
    LEFT JOIN cadastro.unidade_organizacional uno_atual
        ON uno_atual.unid_id = ra.unid_idatual

    LEFT JOIN atendimentopublico.atend_motivo_encmt ame
        ON ame.amen_id = ra.amen_id
),

/* =========================================================
   2) OS vinculadas ao RA
   ========================================================= */
os_vinculadas AS (
    SELECT
        os.rgat_id,
        COUNT(os.orse_id) AS qtd_os,
        STRING_AGG(os.orse_id::text, ',') AS lista_os
    FROM atendimentopublico.ordem_servico os
    GROUP BY os.rgat_id
),

/* =========================================================
   3) Pagamentos (tabela atual + historico)
   - Somente os campos necessarios para contar pagamentos
   ========================================================= */
pagamentos_uniao AS (
    SELECT
        p.imov_id,
        p.pgmt_dtpagamento AS data_pagamento
    FROM arrecadacao.pagamento p
    WHERE p.pgst_idatual IN (0,1,2)

    UNION ALL

    SELECT
        ph.imov_id,
        ph.pghi_dtpagamento AS data_pagamento
    FROM arrecadacao.pagamento_historico ph
    WHERE ph.pgst_idatual IN (0,1,2)
),

/* =========================================================
   4) Quantidade de pagamentos ate 5 dias apos encerramento do RA
   ========================================================= */
pagamentos_apos_ra AS (
    SELECT
        ra.rgat_id,
        CASE 
           WHEN p.data_pagamento = ra.rgat_tmregistroatendimento
           THEN 'SIM'
        ELSE
            'NAO'
        END AS mesmodia,
        COUNT(*) AS qtd_pagamentos_5dias
    FROM ra_base ra
    JOIN pagamentos_uniao p
      ON p.imov_id = ra.imov_id
    WHERE ra.rgat_tmencerramento IS NOT NULL
      AND p.data_pagamento >= ra.rgat_tmencerramento
      AND p.data_pagamento <  ra.rgat_tmencerramento + INTERVAL '5 days'
    GROUP BY ra.rgat_id, mesmodia
)

/* =========================================================
   5) SELECT final (somente quantidade de pagamentos)
   ========================================================= */
SELECT
    ra.rgat_id AS "RA",
    ra.imov_id AS "MATRICULA",
    ra.sotp_dssolicitacaotipo AS "TIPO DE SOLICITACAO",
    ra.step_dssolcttipoespec  AS "TIPO ATENDIMENTO",
    ra.meso_dsmeiosolicitacao AS "MEIO SOLICITACAO",

    ra.unidade_geracao AS "UNIDADE GERACAO",
    ra.unidade_encerramento AS "UNIDADE ENCERRAMENTO",
    ra.unidade_atual AS "UNIDADE ATUAL",

    ra.login_geracao AS "LOGIN GERACAO",
    ra.usuario_geracao AS "USUARIO GERACAO",
    ra.login_encerramento AS "LOGIN ENCERRAMENTO",
    ra.usuario_encerramento AS "USUARIO ENCERRAMENTO",

    TO_CHAR(ra.rgat_tmregistroatendimento, 'dd/MM/yyyy') AS "DATA ATENDIMENTO",
    TO_CHAR(ra.rgat_tmencerramento, 'dd/MM/yyyy') AS "DATA ENCERRAMENTO",
    ROUND(ra.tempo_atendimento_horas::numeric, 2) AS "TEMPO ATENDIMENTO HORAS",

    ra.rgat_dsobservacao AS "OBSERVACAO",
    ra.rgat_dsparecerencerramento AS "PARECER ENCERRAMENTO",
    ra.amen_dsmotivoencerramento AS "MOTIVO ENCERRAMENTO",

    COALESCE(os.qtd_os, 0) AS "QTD OS VINCULADAS",
    os.lista_os AS "LISTA OS",

    COALESCE(pg.qtd_pagamentos_5dias, 0) AS "QTD PAGAMENTOS ATE 5 DIAS",

    CASE
        WHEN COALESCE(pg.qtd_pagamentos_5dias, 0) > 0 THEN 'SIM'
        ELSE 'NAO'
    END AS "HOUVE PAGAMENTO EM ATE 5 DIAS"

FROM ra_base ra
     LEFT JOIN os_vinculadas os
         ON os.rgat_id = ra.rgat_id
     LEFT JOIN pagamentos_apos_ra pg
         ON pg.rgat_id = ra.rgat_id
WHERE
     ra.rgat_tmregistroatendimento BETWEEN '2026-01-01' AND '2026-01-31'
     AND ra.sotp_id IN (76,77,78,79,80,81,83)

ORDER BY ra.rgat_tmregistroatendimento DESC