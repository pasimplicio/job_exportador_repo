WITH params AS (
    SELECT DATE '2026-01-31' AS snap
),

imoveis_atraso AS (

    -- Bloco 1: contas ativas (faturamento.conta)
    SELECT con.imov_id
    FROM faturamento.conta con
    CROSS JOIN params p
    WHERE con.cnta_dtvencimentoconta BETWEEN (p.snap - INTERVAL '90 days')
                                         AND (p.snap - INTERVAL '30 days')
      AND con.dcst_idatual IN (0, 1, 2)
      AND con.last_id       = 3 -- SITUACAO AGUA LIGADO
      AND con.iper_id      <> 6 -- EXCLUIR PERFIL AGUA
      AND NOT EXISTS (
          SELECT 1
          FROM arrecadacao.pagamento pag
          WHERE pag.cnta_id               = con.cnta_id
            AND pag.pgmt_dtpagamento::date < p.snap
      )
    GROUP BY con.imov_id
    HAVING SUM(
          con.cnta_vlagua
        + con.cnta_vlesgoto
        + con.cnta_vldebitos
        - con.cnta_vlcreditos
        - COALESCE(con.cnta_vlimpostos, 0)
    ) > 30

    UNION ALL

    -- Bloco 2: contas historicas (faturamento.conta_historico)
    SELECT ch.imov_id
    FROM faturamento.conta_historico ch
    CROSS JOIN params p
    WHERE ch.cnhi_dtvencimentoconta BETWEEN (p.snap - INTERVAL '90 days')
                                        AND (p.snap - INTERVAL '30 days')
      AND ch.dcst_idatual IN (0, 1, 2)
      AND ch.last_id       = 3
      AND ch.iper_id      <> 6
      AND NOT EXISTS (
          SELECT 1
          FROM arrecadacao.pagamento pag
          WHERE pag.cnta_id               = ch.cnta_id
            AND pag.pgmt_dtpagamento::date < p.snap
      )
      AND NOT EXISTS (
          SELECT 1
          FROM arrecadacao.pagamento_historico ph
          WHERE ph.cnta_id               = ch.cnta_id
            AND ph.pghi_dtpagamento::date < p.snap
      )
    GROUP BY ch.imov_id
    HAVING SUM(
          ch.cnhi_vlagua
        + ch.cnhi_vlesgoto
        + ch.cnhi_vldebitos
        - ch.cnhi_vlcreditos
        - COALESCE(ch.cnhi_vlimpostos, 0)
    ) > 30

)

SELECT DISTINCT
    ia.imov_id                    AS "MATRICULA_APTA",
    une.uneg_nmunidadenegocio     AS "UNIDADE",
    loc.loca_nmlocalidade         AS "LOCALIDADE",
    mun.muni_nmmunicipio          AS "MUNICIPIO"
FROM imoveis_atraso           ia
JOIN cadastro.imovel          imo ON imo.imov_id  = ia.imov_id
JOIN cadastro.localidade      loc ON loc.loca_id  = imo.loca_id
JOIN cadastro.unidade_negocio une ON une.uneg_id  = loc.uneg_id
JOIN cadastro.municipio       mun ON mun.muni_id  = loc.muni_idprincipal
WHERE imo.imov_icexclusao = 2                          -- apenas imoveis ativos (nao excluidos)
  AND loc.uneg_id NOT IN (17, 18, 19)                  -- exclui unidades de negocio especificas
  AND (imo.ftst_id IS NULL OR imo.ftst_id NOT IN (1, 5)) -- exclui situacoes especiais de faturamento 1 e 5
  AND NOT EXISTS (
      -- exclui imoveis com atendimento em aberto em:
                  --- CANCELAMENTO DE FATURA (971) 
                --- CANCELAMENTO DE FATURA (9012) 
                --- CANCELAMENTO DE FATURA JUDICIAL (1071) 
                --- CONTESTACAO DE DEBITO (940) 
                --- RETIFICACAO DE FATURA (978) 
                --- RETIFICACAO DE FATURA JUDICIAL (1070) 
                --- RETIFICACAO DE FATURAS (9014)
      SELECT 1
      FROM atendimentopublico.registro_atendimento ra
      WHERE ra.imov_id = imo.imov_id
        AND ra.step_id IN (971, 9012, 1071, 940, 978, 1070, 9014)
        AND ra.rgat_tmencerramento IS NULL
  )
ORDER BY "UNIDADE", "MUNICIPIO", "LOCALIDADE", "MATRICULA_APTA";
 
 
 	
WITH params AS (
    SELECT DATE '2026-01-31' AS snap
),

imoveis_atraso AS (

    -- Bloco 1: contas ativas (faturamento.conta)
    SELECT con.imov_id
    FROM faturamento.conta con
    CROSS JOIN params p
    WHERE con.cnta_dtvencimentoconta BETWEEN (p.snap - INTERVAL '90 days')
                                         AND (p.snap - INTERVAL '30 days')
      AND con.dcst_idatual IN (0, 1, 2)
      AND con.last_id       = 3 -- SITUACAO AGUA LIGADO
      AND con.iper_id      <> 6 -- EXCLUIR PERFIL AGUA
      AND NOT EXISTS (
          SELECT 1
          FROM arrecadacao.pagamento pag
          WHERE pag.cnta_id               = con.cnta_id
            AND pag.pgmt_dtpagamento::date < p.snap
      )
    GROUP BY con.imov_id
    HAVING SUM(
          con.cnta_vlagua
        + con.cnta_vlesgoto
        + con.cnta_vldebitos
        - con.cnta_vlcreditos
        - COALESCE(con.cnta_vlimpostos, 0)
    ) > 30

    UNION ALL

    -- Bloco 2: contas historicas (faturamento.conta_historico)
    SELECT ch.imov_id
    FROM faturamento.conta_historico ch
    CROSS JOIN params p
    WHERE ch.cnhi_dtvencimentoconta BETWEEN (p.snap - INTERVAL '90 days')
                                        AND (p.snap - INTERVAL '30 days')
      AND ch.dcst_idatual IN (0, 1, 2)
      AND ch.last_id       = 3
      AND ch.iper_id      <> 6
      AND NOT EXISTS (
          SELECT 1
          FROM arrecadacao.pagamento pag
          WHERE pag.cnta_id               = ch.cnta_id
            AND pag.pgmt_dtpagamento::date < p.snap
      )
      AND NOT EXISTS (
          SELECT 1
          FROM arrecadacao.pagamento_historico ph
          WHERE ph.cnta_id               = ch.cnta_id
            AND ph.pghi_dtpagamento::date < p.snap
      )
    GROUP BY ch.imov_id
    HAVING SUM(
          ch.cnhi_vlagua
        + ch.cnhi_vlesgoto
        + ch.cnhi_vldebitos
        - ch.cnhi_vlcreditos
        - COALESCE(ch.cnhi_vlimpostos, 0)
    ) > 30

)

SELECT DISTINCT
    ia.imov_id                    AS "MATRICULA_APTA",
    une.uneg_nmunidadenegocio     AS "UNIDADE",
    loc.loca_nmlocalidade         AS "LOCALIDADE",
    mun.muni_nmmunicipio          AS "MUNICIPIO"
FROM imoveis_atraso           ia
JOIN cadastro.imovel          imo ON imo.imov_id  = ia.imov_id
JOIN cadastro.localidade      loc ON loc.loca_id  = imo.loca_id
JOIN cadastro.unidade_negocio une ON une.uneg_id  = loc.uneg_id
JOIN cadastro.municipio       mun ON mun.muni_id  = loc.muni_idprincipal
WHERE imo.imov_icexclusao = 2                          -- apenas imoveis ativos (nao excluidos)
  AND loc.uneg_id NOT IN (17, 18, 19)                  -- exclui unidades de negocio especificas
  AND (imo.ftst_id IS NULL OR imo.ftst_id NOT IN (1, 5)) -- exclui situacoes especiais de faturamento 1 e 5
  AND NOT EXISTS (
      -- exclui imoveis com atendimento em aberto em:
                  --- CANCELAMENTO DE FATURA (971) 
                --- CANCELAMENTO DE FATURA (9012) 
                --- CANCELAMENTO DE FATURA JUDICIAL (1071) 
                --- CONTESTACAO DE DEBITO (940) 
                --- RETIFICACAO DE FATURA (978) 
                --- RETIFICACAO DE FATURA JUDICIAL (1070) 
                --- RETIFICACAO DE FATURAS (9014)
      SELECT 1
      FROM atendimentopublico.registro_atendimento ra
      WHERE ra.imov_id = imo.imov_id
        AND ra.step_id IN (971, 9012, 1071, 940, 978, 1070, 9014)
        AND ra.rgat_tmencerramento IS NULL
  )
ORDER BY "UNIDADE", "MUNICIPIO", "LOCALIDADE", "MATRICULA_APTA"