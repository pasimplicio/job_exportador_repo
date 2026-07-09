WITH
-- [1] Parametros centralizados
params AS (
    SELECT
        202601                          AS referencia_corte,
        DATE '2026-02-28'               AS dt_corte,
        30                              AS dias_inadimplencia,
        DATE '2026-02-28' - 30          AS dt_limite,
        DATE '2026-02-28' - (5 * 365)   AS dt_5_anos,
        DATE '2026-02-28' - (10 * 365)  AS dt_10_anos
),
-- [2] Funil: matriculas validas + atributos + dt_minima por categoria
--     dt_minima define o limite inferior de vencimento aceito por imovel:
--       categorias 1,2,3 -> ate 10 anos antes do corte
--       categoria 4      -> ate 5 anos antes do corte
--       demais/nulo      -> sem limite inferior (data minima do PostgreSQL)
imoveis_validos AS (
    SELECT
        f.imov_id,
        imo.loca_id,
        imo.imov_idcategoriaprincipal,
        imo.iper_id,
        CASE
            WHEN imo.imov_idcategoriaprincipal IN (1, 2, 3) THEN p.dt_10_anos
            WHEN imo.imov_idcategoriaprincipal = 4          THEN p.dt_5_anos
            ELSE DATE '-infinity'
        END AS dt_minima
    FROM (
        SELECT imov_id FROM faturamento.conta
        WHERE cnta_amreferenciaconta = (SELECT referencia_corte FROM params)
        UNION
        SELECT imov_id FROM faturamento.conta_historico
        WHERE cnhi_amreferenciaconta = (SELECT referencia_corte FROM params)
    ) f
    JOIN cadastro.imovel imo ON imo.imov_id = f.imov_id
    CROSS JOIN params p
    WHERE imo.imov_icexclusao = 2
      AND EXISTS (
          SELECT 1
          FROM cadastro.cliente_imovel cim
          JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
          WHERE cim.imov_id          = imo.imov_id
            AND cim.clim_dtrelacaofim IS NULL
            AND cim.clim_icnomeconta  = 1
      )
),
-- [3] Contas candidatas filtradas por dt_minima e dt_limite
--     dt_minima: limite inferior de vencimento (por categoria do imovel)
--     dt_limite: limite superior (data corte - dias inadimplencia)
contas_snapshot AS (
    SELECT DISTINCT ON (idconta)
        imov_id, idconta, vencimento, valor
    FROM (
        SELECT
            cnta.imov_id,
            cnta.cnta_id                AS idconta,
            cnta.cnta_dtvencimentoconta AS vencimento,
            (cnta.cnta_vlagua + cnta.cnta_vlesgoto + cnta.cnta_vldebitos
             - cnta.cnta_vlcreditos - COALESCE(cnta.cnta_vlimpostos, 0)) AS valor
        FROM faturamento.conta cnta
        JOIN imoveis_validos iv ON iv.imov_id = cnta.imov_id
        WHERE cnta.dcst_idatual IN (0, 1, 2)
          AND cnta.cnta_dtvencimentoconta BETWEEN iv.dt_minima
                                              AND (SELECT dt_limite FROM params)

        UNION ALL

        SELECT
            cnhi.imov_id,
            cnhi.cnta_id                 AS idconta,
            cnhi.cnhi_dtvencimentoconta  AS vencimento,
            (cnhi.cnhi_vlagua + cnhi.cnhi_vlesgoto + cnhi.cnhi_vldebitos
             - cnhi.cnhi_vlcreditos - COALESCE(cnhi.cnhi_vlimpostos, 0)) AS valor
        FROM faturamento.conta_historico cnhi
        JOIN imoveis_validos iv ON iv.imov_id = cnhi.imov_id
        WHERE cnhi.dcst_idatual IN (0, 1, 2)
          AND cnhi.cnhi_dtvencimentoconta BETWEEN iv.dt_minima
                                              AND (SELECT dt_limite FROM params)
    ) todas
    WHERE todas.valor > 0
    ORDER BY idconta
),
-- [4] Contas efetivamente devidas no retrato da data de corte
contas_devidas AS (
    SELECT cs.imov_id, cs.idconta
    FROM contas_snapshot cs
    WHERE NOT EXISTS (
        SELECT 1 FROM arrecadacao.pagamento pg
        WHERE pg.cnta_id          = cs.idconta
          AND pg.pgmt_dtpagamento <= (SELECT dt_corte FROM params)
    )
    AND NOT EXISTS (
        SELECT 1 FROM arrecadacao.pagamento_historico ph
        WHERE ph.cnta_id           = cs.idconta
          AND ph.pghi_dtpagamento  <= (SELECT dt_corte FROM params)
    )
)
-- [5] Consolidacao final
SELECT
    cd.imov_id                    AS "MATRICULA",
    iv.loca_id                    AS "LOCALIDADE",
    loc.loca_nmlocalidade         AS "NOME LOCALIDADE",
    catg.catg_dscategoria         AS "Categoria",
    iper.iper_dsimovelperfil      AS "Perfil",
    COUNT(*)                      AS "Qt. Contas Devidas"
FROM contas_devidas cd
JOIN imoveis_validos              iv   ON iv.imov_id   = cd.imov_id
JOIN cadastro.localidade          loc  ON loc.loca_id  = iv.loca_id
LEFT JOIN cadastro.categoria      catg ON catg.catg_id = iv.imov_idcategoriaprincipal
LEFT JOIN cadastro.imovel_perfil  iper ON iper.iper_id = iv.iper_id
GROUP BY cd.imov_id, iv.loca_id, loc.loca_nmlocalidade,
         catg.catg_dscategoria, iper.iper_dsimovelperfil
ORDER BY iv.loca_id, cd.imov_id;