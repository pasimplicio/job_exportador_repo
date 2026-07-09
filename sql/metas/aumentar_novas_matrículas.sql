WITH operacoes AS (
  SELECT
    imov.imov_id AS matricula,
    imov.loca_id,
    imov.imov_idcategoriaprincipal,
    DATE(opef.opef_tmultimaalteracao) AS data_operacao,
    oper.oper_dsoperacao AS nome_operacao
  FROM cadastro.imovel imov
  JOIN seguranca.operacao_efetuada opef ON opef.opef_cnargumento = imov.imov_id
  JOIN seguranca.operacao oper ON oper.oper_id = opef.oper_id
  WHERE oper.oper_id = 9
    AND DATE(opef.opef_tmultimaalteracao) >= '2026-01-01'
)
SELECT
  TO_CHAR(o.data_operacao, 'DD/MM/YYYY') AS "DATA DE INSERCAO",
  o.matricula AS "MATRICULA",
  CASE
    WHEN o.imov_idcategoriaprincipal = 1 THEN 'RESIDENCIAL'
    WHEN o.imov_idcategoriaprincipal = 2 THEN 'COMERCIAL'
    WHEN o.imov_idcategoriaprincipal = 3 THEN 'INDUSTRIAL'
    WHEN o.imov_idcategoriaprincipal = 4 THEN 'PUBLICO'
    ELSE 'Outra'
  END AS "CATEGORIA",
  l.loca_nmlocalidade AS "NOME LOCALIDADE",
  un.uneg_nmunidadenegocio AS "NOME REGIONAL",
  CASE WHEN EXISTS (
    SELECT 1 FROM faturamento.conta c 
    WHERE c.imov_id = o.matricula 
      AND c.cnta_amreferenciaconta = 202601
      AND c.dcst_idatual NOT IN (3,4,9)
    UNION
    SELECT 1 FROM faturamento.conta_historico ch
    WHERE ch.imov_id = o.matricula 
      AND ch.cnhi_amreferenciaconta = 202601
      AND ch.dcst_idatual NOT IN (3,4,9)
  ) THEN 'SIM' ELSE 'NAO' END AS "FATURANDO"
FROM operacoes o
LEFT JOIN cadastro.localidade l ON o.loca_id = l.loca_id
LEFT JOIN cadastro.unidade_negocio un ON l.uneg_id = un.uneg_id
ORDER BY o.matricula, o.data_operacao;
 
 
 	
WITH operacoes AS (
  SELECT
    imov.imov_id AS matricula,
    imov.loca_id,
    imov.imov_idcategoriaprincipal,
    DATE(opef.opef_tmultimaalteracao) AS data_operacao,
    oper.oper_dsoperacao AS nome_operacao
  FROM cadastro.imovel imov
  JOIN seguranca.operacao_efetuada opef ON opef.opef_cnargumento = imov.imov_id
  JOIN seguranca.operacao oper ON oper.oper_id = opef.oper_id
  WHERE oper.oper_id = 9
    AND DATE(opef.opef_tmultimaalteracao) >= '2026-01-01'
)
SELECT
  TO_CHAR(o.data_operacao, 'DD/MM/YYYY') AS "DATA DE INSERCAO",
  o.matricula AS "MATRICULA",
  CASE
    WHEN o.imov_idcategoriaprincipal = 1 THEN 'RESIDENCIAL'
    WHEN o.imov_idcategoriaprincipal = 2 THEN 'COMERCIAL'
    WHEN o.imov_idcategoriaprincipal = 3 THEN 'INDUSTRIAL'
    WHEN o.imov_idcategoriaprincipal = 4 THEN 'PUBLICO'
    ELSE 'Outra'
  END AS "CATEGORIA",
  l.loca_nmlocalidade AS "NOME LOCALIDADE",
  un.uneg_nmunidadenegocio AS "NOME REGIONAL",
  CASE WHEN EXISTS (
    SELECT 1 FROM faturamento.conta c 
    WHERE c.imov_id = o.matricula 
      AND c.cnta_amreferenciaconta = 202601
      AND c.dcst_idatual NOT IN (3,4,9)
    UNION
    SELECT 1 FROM faturamento.conta_historico ch
    WHERE ch.imov_id = o.matricula 
      AND ch.cnhi_amreferenciaconta = 202601
      AND ch.dcst_idatual NOT IN (3,4,9)
  ) THEN 'SIM' ELSE 'NAO' END AS "FATURANDO"
FROM operacoes o
LEFT JOIN cadastro.localidade l ON o.loca_id = l.loca_id
LEFT JOIN cadastro.unidade_negocio un ON l.uneg_id = un.uneg_id
ORDER BY o.matricula, o.data_operacao;
