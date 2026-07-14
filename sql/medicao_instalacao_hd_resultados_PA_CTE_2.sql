WITH debitoAntAberto AS (
    SELECT 
        conta.imov_id,
        COUNT(conta.cnta_id) AS totalDevido,
        SUM(
            conta.cnta_vlagua 
          + conta.cnta_vlesgoto 
          + conta.cnta_vldebitos 
          - conta.cnta_vlcreditos 
          - conta.cnta_vlimpostos
        ) AS valorDevido
    FROM faturamento.conta conta
    INNER JOIN micromedicao.hidrometro_inst_hist hidi 
        ON hidi.lagu_id = conta.imov_id
    WHERE conta.dcst_idatual IN (0,1,2)
      AND conta.cnta_dtvencimentooriginal < hidi.hidi_dtinstalacaohidrometro
      AND conta.cnta_dtrevisao IS NULL
      AND NOT EXISTS (
            SELECT 1
            FROM arrecadacao.pagamento pgmt
            WHERE pgmt.cnta_id = conta.cnta_id
      )
    GROUP BY conta.imov_id
),

debitoAntPago AS (
    SELECT 
        pgmt.imov_id AS matDebAntPago,
        COUNT(pgmt.pgmt_id) AS qtdePagamento,
        SUM(pgmt.pgmt_vlpagamento) AS totalPago
    FROM arrecadacao.pagamento pgmt
    INNER JOIN micromedicao.hidrometro_inst_hist hidi 
        ON hidi.lagu_id = pgmt.imov_id
    INNER JOIN faturamento.conta conta 
        ON conta.cnta_id = pgmt.cnta_id
       AND conta.cnta_dtvencimentooriginal < hidi.hidi_dtinstalacaohidrometro
    WHERE pgmt.pgmt_dtpagamento > hidi.hidi_dtinstalacaohidrometro
    GROUP BY pgmt.imov_id
),

debitoPosAberto AS (
    SELECT 
        conta.imov_id AS matDebPosAberto,
        COUNT(conta.cnta_id) AS totalDevido,
        SUM(
            conta.cnta_vlagua 
          + conta.cnta_vlesgoto 
          + conta.cnta_vldebitos 
          - conta.cnta_vlcreditos 
          - conta.cnta_vlimpostos
        ) AS valorDevido
    FROM faturamento.conta conta
    INNER JOIN micromedicao.hidrometro_inst_hist hidi 
        ON hidi.lagu_id = conta.imov_id
    WHERE conta.dcst_idatual IN (0,1,2)
      AND conta.cnta_dtvencimentooriginal >= hidi.hidi_dtinstalacaohidrometro
      AND NOT EXISTS (
            SELECT 1
            FROM arrecadacao.pagamento pgmt
            WHERE pgmt.cnta_id = conta.cnta_id
      )
    GROUP BY conta.imov_id
),

debitoPosPago AS (
    SELECT 
        pgmt.imov_id AS matDebPosPago,
        COUNT(pgmt.pgmt_id) AS qtdePagamento,
        SUM(pgmt.pgmt_vlpagamento) AS totalPago
    FROM arrecadacao.pagamento pgmt
    INNER JOIN micromedicao.hidrometro_inst_hist hidi 
        ON hidi.lagu_id = pgmt.imov_id
    INNER JOIN faturamento.conta conta 
        ON conta.cnta_id = pgmt.cnta_id
       AND conta.cnta_dtvencimentooriginal >= hidi.hidi_dtinstalacaohidrometro
    WHERE pgmt.pgmt_dtpagamento > hidi.hidi_dtinstalacaohidrometro
    GROUP BY pgmt.imov_id
)

SELECT
    imov.imov_id AS "matricula",

    hidi.hidi_dtinstalacaohidrometro AS "data instalacao",

    (
        SELECT MAX(hidi2.hidi_dtretiradahidrometro)
        FROM micromedicao.hidrometro_inst_hist hidi2
        WHERE hidi2.lagu_id = imov.imov_id
    ) AS "Ultima Retirada HD",

    hid.hidr_nnhidrometro AS "NUMERO HIDROMETRO",

    CAST(fat.ftst_id AS TEXT) || ' - ' || fat.ftst_dsfaturamentosituacaotipo 
        AS "SIT. FATURAMENTO",

    las.last_dsligacaoaguasituacao AS "SITUACAO AGUA",

    COALESCE(debitoAntAberto.totalDevido,0)
        AS "total conta antes inst aberto",

    TO_CHAR(
        COALESCE(debitoAntAberto.valorDevido,0),
        '999G999G990D00'
    ) AS "valor debito antes inst aberto",

    COALESCE(debitoAntPago.qtdePagamento,0)
        AS "total conta antes inst pagas apos inst",

    TO_CHAR(
        COALESCE(debitoAntPago.totalPago,0),
        '999G999G990D00'
    ) AS "valor conta antes inst pago apos inst",

    COALESCE(debitoPosAberto.totalDevido,0)
        AS "total conta posterior inst aberto",

    TO_CHAR(
        COALESCE(debitoPosAberto.valorDevido,0),
        '999G999G990D00'
    ) AS "valor debito posterior inst aberto",

    COALESCE(debitoPosPago.qtdePagamento,0)
        AS "total conta posterior inst pago",

    TO_CHAR(
        COALESCE(debitoPosPago.totalPago,0),
        '999G999G990D00'
    ) AS "valor conta posterior inst pago"

FROM cadastro.imovel imov
LEFT JOIN cadastro.localidade loc ON imov.loca_id = loc.loca_id AND loc.greg_id IN (1, 2)
LEFT JOIN atendimentopublico.ligacao_agua lagu
    ON lagu.lagu_id = imov.imov_id

LEFT JOIN micromedicao.hidrometro_inst_hist hidi
    ON hidi.lagu_id = imov.imov_id
 
LEFT JOIN debitoAntAberto
    ON debitoAntAberto.imov_id = imov.imov_id

LEFT JOIN debitoAntPago
    ON debitoAntPago.matDebAntPago = imov.imov_id

LEFT JOIN debitoPosAberto
    ON debitoPosAberto.matDebPosAberto = imov.imov_id

LEFT JOIN debitoPosPago
    ON debitoPosPago.matDebPosPago = imov.imov_id

LEFT JOIN faturamento.fatur_situacao_hist fsh
    ON fsh.imov_id = imov.imov_id
   AND fsh.ftsh_amfaturamentoretirada IS NULL

LEFT JOIN faturamento.fatur_situacao_tipo fat
    ON fat.ftst_id = fsh.ftst_id

LEFT JOIN atendimentopublico.ligacao_agua_situacao las
    ON las.last_id = imov.last_id

LEFT JOIN micromedicao.hidrometro hid
    ON hidi.hidr_id = hid.hidr_id

WHERE imov.imov_icexclusao = 2
        -- Apenas registros cuja instalação ocorreu até 31/01/2026
     AND hidi.hidi_dtinstalacaohidrometro <= '2026-01-31'
        -- E que NÃO foram retirados antes de 31/01/2026:
        -- ou seja, retirada nula (ainda instalado) OU retirada após 31/01/2026
      AND (
            hidi.hidi_dtretiradahidrometro IS NULL
            OR hidi.hidi_dtretiradahidrometro > '2026-01-31'
        )
      AND COALESCE(loc.uneg_id, 0) NOT IN (17, 18, 19)        
ORDER BY imov.imov_id