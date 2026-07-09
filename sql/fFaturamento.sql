WITH contas_ativas AS (
    SELECT
        cnta.imov_id,
        cnta.cnta_id AS idconta,
        cnta.cnta_amreferenciaconta AS referencia,
        cnta.cnta_dtvencimentooriginal AS vencimento,
        (cnta.cnta_vlagua + cnta.cnta_vlesgoto + cnta.cnta_vldebitos
         - cnta.cnta_vlcreditos - cnta.cnta_vlimpostos) AS valor
    FROM faturamento.conta cnta
    WHERE cnta.cnta_amreferenciaconta BETWEEN 202601 AND 202612
      AND cnta.dcst_idatual IN (0,1,2)
),

contas_historicas AS (
    SELECT
        cnhi.imov_id,
        cnhi.cnta_id AS idconta,
        cnhi.cnhi_amreferenciaconta AS referencia,
        cnhi.cnhi_dtvencimentooriginal AS vencimento,        
        (cnhi.cnhi_vlagua + cnhi.cnhi_vlesgoto + cnhi.cnhi_vldebitos
         - cnhi.cnhi_vlcreditos - cnhi.cnhi_vlimpostos) AS valor
    FROM faturamento.conta_historico cnhi
    WHERE cnhi.cnhi_amreferenciaconta BETWEEN 202601 AND 202612
      AND cnhi.dcst_idatual IN (0,1,2)
),

contas_consolidadas AS (
    SELECT * FROM contas_ativas
    UNION ALL
    SELECT * FROM contas_historicas
)

SELECT 
    imo.imov_id AS "MATRICULA",
    loc.loca_id AS "LOCALIDADE",
    subq.idconta AS "NUMERO CONTA",
    subq.referencia AS "REFERENCIA FATURAMENTO",
    subq.vencimento AS "DATA VENCIMENTO",
    TO_CHAR(subq.valor, '999G999G990D00') AS "VALOR FATURADO"

FROM contas_consolidadas subq
JOIN cadastro.imovel imo ON imo.imov_id = subq.imov_id
JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
JOIN cadastro.cliente_imovel cim 
  ON cim.imov_id = imo.imov_id
 AND cim.clim_dtrelacaofim IS NULL
 AND cim.clim_icnomeconta = 1
JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id

WHERE imo.imov_icexclusao = 2
  AND subq.valor > 0

ORDER BY loc.loca_id, imo.imov_id;
