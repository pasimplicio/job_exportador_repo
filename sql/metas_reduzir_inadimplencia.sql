WITH params AS (
  SELECT 
    DATE '2026-02-01' AS snap,
    202601 AS amref_faturando
),

/* Imóveis faturando + seus dados cadastrais */
imoveis_faturando AS (
  SELECT DISTINCT
    i.imov_id,
    i.imov_idcategoriaprincipal,
    l.loca_nmlocalidade AS nome_localidade,
    un.uneg_nmunidadenegocio AS nome_unidade,
    ipf.iper_dsimovelperfil AS nome_perfil,
    CASE i.imov_idcategoriaprincipal
      WHEN 1 THEN 'RESIDENCIAL'
      WHEN 2 THEN 'COMERCIAL'
      WHEN 3 THEN 'INDUSTRIAL'
      WHEN 4 THEN 'PUBLICO'
      ELSE 'OUTRA'
    END AS categoria,
    -- Limite de anos conforme categoria
    CASE WHEN i.imov_idcategoriaprincipal = 4 THEN 5 ELSE 10 END AS limite_anos
  FROM faturamento.conta c
  CROSS JOIN params p
  JOIN cadastro.imovel i ON i.imov_id = c.imov_id
  JOIN cadastro.localidade l ON i.loca_id = l.loca_id
  JOIN cadastro.unidade_negocio un ON l.uneg_id = un.uneg_id
  JOIN cadastro.imovel_perfil ipf ON i.iper_id = ipf.iper_id
  WHERE c.cnta_amreferenciaconta = p.amref_faturando
    AND c.dcst_idatual NOT IN (3,4,9)
  
  UNION
  
  SELECT DISTINCT
    i.imov_id,
    i.imov_idcategoriaprincipal,
    l.loca_nmlocalidade,
    un.uneg_nmunidadenegocio,
    ipf.iper_dsimovelperfil,
    CASE i.imov_idcategoriaprincipal
      WHEN 1 THEN 'RESIDENCIAL'
      WHEN 2 THEN 'COMERCIAL'
      WHEN 3 THEN 'INDUSTRIAL'
      WHEN 4 THEN 'PUBLICO'
      ELSE 'OUTRA'
    END,
    CASE WHEN i.imov_idcategoriaprincipal = 4 THEN 5 ELSE 10 END
  FROM faturamento.conta_historico ch
  CROSS JOIN params p
  JOIN cadastro.imovel i ON i.imov_id = ch.imov_id
  JOIN cadastro.localidade l ON i.loca_id = l.loca_id
  JOIN cadastro.unidade_negocio un ON l.uneg_id = un.uneg_id
  JOIN cadastro.imovel_perfil ipf ON i.iper_id = ipf.iper_id
  WHERE ch.cnhi_amreferenciaconta = p.amref_faturando
    AND ch.dcst_idatual NOT IN (3,4,9)
),

/* Todas as contas dos imóveis faturando (dentro do prazo por categoria) */
contas_candidatas AS (
  SELECT
    c.cnta_id,
    c.imov_id,
    c.cnta_amreferenciaconta::int AS amreferencia,
    c.cnta_dtvencimentoconta::date AS dt_vencimento,
    c.iper_id
  FROM faturamento.conta c
  JOIN imoveis_faturando imf ON imf.imov_id = c.imov_id
  CROSS JOIN params p
  WHERE c.dcst_idatual NOT IN (3,4,9)
    AND c.cnta_dtvencimentoconta::date BETWEEN 
        (p.snap - (imf.limite_anos::text || ' years')::INTERVAL) AND 
        (p.snap - INTERVAL '30 days')

  UNION ALL

  SELECT
    ch.cnta_id,
    ch.imov_id,
    ch.cnhi_amreferenciaconta::int,
    ch.cnhi_dtvencimentoconta::date,
    ch.iper_id
  FROM faturamento.conta_historico ch
  JOIN imoveis_faturando imf ON imf.imov_id = ch.imov_id
  CROSS JOIN params p
  WHERE ch.dcst_idatual NOT IN (3,4,9)
    AND ch.cnhi_dtvencimentoconta::date BETWEEN 
        (p.snap - (imf.limite_anos::text || ' years')::INTERVAL) AND 
        (p.snap - INTERVAL '30 days')
),

/* Contas atrasadas = sem pagamento OU com pagamento >= snapshot (e nenhum pagamento pré-2026) */
contas_atrasadas AS (
  SELECT cc.*
  FROM contas_candidatas cc
  CROSS JOIN params p
  WHERE NOT EXISTS (
    -- Tem pagamento antes de 2026?
    SELECT 1 
    FROM arrecadacao.pagamento pgt
    WHERE pgt.cnta_id = cc.cnta_id 
      AND pgt.pgmt_dtpagamento::date < DATE '2026-01-01'
    UNION ALL
    SELECT 1 
    FROM arrecadacao.pagamento_historico ph
    WHERE ph.cnta_id = cc.cnta_id 
      AND ph.pghi_dtpagamento::date < DATE '2026-01-01'
  )
  AND (
    -- Não tem pagamento nenhum OU tem mas >= snapshot
    NOT EXISTS (
      SELECT 1 FROM arrecadacao.pagamento pgt WHERE pgt.cnta_id = cc.cnta_id
      UNION ALL
      SELECT 1 FROM arrecadacao.pagamento_historico ph WHERE ph.cnta_id = cc.cnta_id
    )
    OR EXISTS (
      SELECT 1 
      FROM arrecadacao.pagamento pgt
      WHERE pgt.cnta_id = cc.cnta_id 
        AND pgt.pgmt_dtpagamento::date >= p.snap
      UNION ALL
      SELECT 1 
      FROM arrecadacao.pagamento_historico ph
      WHERE ph.cnta_id = cc.cnta_id 
        AND ph.pghi_dtpagamento::date >= p.snap
    )
  )
)

SELECT
  TO_CHAR(DATE_TRUNC('month', p.snap - INTERVAL '1 month'), 'DD/MM/YYYY') AS mes_ref,
  ca.imov_id,
  imf.nome_unidade,
  imf.nome_localidade,
  imf.nome_perfil,
  imf.categoria,
  COUNT(*) AS qtd_cnta_id,
  (ARRAY_AGG(ca.cnta_id ORDER BY ca.amreferencia, ca.cnta_id))[1] AS cnta_id_mais_antigo,
  (ARRAY_AGG(ca.amreferencia ORDER BY ca.amreferencia, ca.cnta_id))[1] AS amreferencia_mais_antigo,
  TO_CHAR((ARRAY_AGG(ca.dt_vencimento ORDER BY ca.amreferencia, ca.cnta_id))[1], 'DD/MM/YYYY') AS dtvencimento_mais_antigo,
  (ARRAY_AGG(ca.iper_id ORDER BY ca.amreferencia, ca.cnta_id))[1] AS iper_id_mais_antigo,
  (ARRAY_AGG(ca.cnta_id ORDER BY ca.amreferencia DESC, ca.cnta_id DESC))[1] AS cnta_id_mais_novo,
  (ARRAY_AGG(ca.amreferencia ORDER BY ca.amreferencia DESC, ca.cnta_id DESC))[1] AS amreferencia_mais_novo,
  TO_CHAR((ARRAY_AGG(ca.dt_vencimento ORDER BY ca.amreferencia DESC, ca.cnta_id DESC))[1], 'DD/MM/YYYY') AS dtvencimento_mais_novo,
  (ARRAY_AGG(ca.iper_id ORDER BY ca.amreferencia DESC, ca.cnta_id DESC))[1] AS iper_id_mais_novo
FROM contas_atrasadas ca
CROSS JOIN params p
JOIN imoveis_faturando imf ON imf.imov_id = ca.imov_id
GROUP BY ca.imov_id, p.snap, imf.nome_unidade, imf.nome_localidade, imf.nome_perfil, imf.categoria
ORDER BY ca.imov_id;