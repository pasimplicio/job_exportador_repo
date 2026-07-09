WITH contas_validas AS (
SELECT
      uniao.imov_id,
      uniao.cnta_id AS cnta_id,
      uniao.pgst_idatual AS situacao,
      uniao.ref_pagamento AS referencia,
      uniao.data_pagamento AS vencimento,
      uniao.valor_pago AS valor
FROM
    (SELECT 
        pag4.imov_id,
        pag4.cnta_id,
	pag4.pgst_idatual,
	pag4.pgmt_amreferenciapagamento AS ref_pagamento,
        pag4.pgmt_dtpagamento AS data_pagamento,
        pag4.pgmt_vlpagamento AS valor_pago
    FROM arrecadacao.pagamento pag4
    WHERE 
        pag4.pgst_idatual IN (0,1,2)
        AND pag4.pgmt_dtpagamento >= '2025-01-01'
        AND pag4.pgmt_dtpagamento <= CURRENT_DATE
        UNION ALL
    SELECT 
        pag4.imov_id,
        pag4.cnta_id,        
	pag4.pgst_idatual,        
	pag4.pghi_amreferenciapagamento AS ref_pagamento,
        pag4.pghi_dtpagamento AS data_pagamento,
        pag4.pghi_vlpagamento AS valor_pago
    FROM arrecadacao.pagamento_historico pag4
    WHERE 
        pag4.pgst_idatual IN (0,1,2)
        AND pag4.pghi_dtpagamento >= '2025-01-01'
        AND pag4.pghi_dtpagamento <= CURRENT_DATE
       
    ) AS uniao
),

pagamento_final AS (
  SELECT
    imov_id,
    cnta_id,
    situacao,
    referencia,
    vencimento,   
    valor
  FROM contas_validas
)

-- SELECT principal
SELECT 
  imo.imov_id AS "MATRICULA",
  loc.loca_id AS "LOCALIDADE",
  ff.cnta_id AS "CODIGO CONTA",
  ff.referencia AS "REFERENCIA",
  ff.vencimento AS "DATA PAGAMENTO",
  TO_CHAR(ff.valor, '999G999G990D00') AS "VALOR PAGAMENTO"
FROM cadastro.imovel imo
  INNER JOIN cadastro.localidade loc 
    ON imo.loca_id = loc.loca_id 
    AND loc.greg_id IN (1, 2)
  LEFT JOIN pagamento_final ff ON ff.imov_id = imo.imov_id
WHERE ff.valor > 0
AND ff.cnta_id IS NOT NULL
ORDER BY ff.vencimento, imo.imov_id DESC;
