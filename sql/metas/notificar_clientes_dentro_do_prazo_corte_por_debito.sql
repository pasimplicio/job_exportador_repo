SELECT DISTINCT
    cob.imov_id                  AS "MATRICULA_NOTIFICADA",
    imo.loca_id                  AS "ID_LOCALIDADE",
    acao.cbac_dscobrancaacao     AS "TIPO_NOTIFICACAO",
    cob.cbdo_tmemissao           AS "DT_EMISSAO_NOTIFICACAO"
FROM cobranca.cobranca_documento cob
JOIN cobranca.cobranca_acao acao
  ON acao.cbac_id = cob.cbac_id
JOIN cadastro.imovel imo
  ON imo.imov_id = cob.imov_id
WHERE cob.cbdo_tmemissao >= TIMESTAMP '2026-01-01 00:00:00'
  AND cob.cbdo_tmemissao <  TIMESTAMP '2026-02-01 00:00:00'
  AND acao.cbac_id IN (1, 20)
ORDER BY "MATRICULA_NOTIFICADA", "TIPO_NOTIFICACAO", "DT_EMISSAO_NOTIFICACAO";