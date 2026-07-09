WITH contas_consolidadas AS (
SELECT
      subq.imov_id,
      subq.idconta,
      subq.referencia,
      subq.data_pagamento,
      subq.valor_pago
FROM
    (SELECT 
        pag4.imov_id,
        pag4.cnta_id AS idconta,
        pag4.pgmt_amreferenciapagamento AS referencia,
        pag4.pgmt_dtpagamento AS data_pagamento,
        pag4.pgmt_vlpagamento AS valor_pago
    FROM arrecadacao.pagamento pag4
    WHERE 
        pag4.pgst_idatual IN (0,1,2)
        AND pag4.pgmt_dtpagamento >= '2026-01-01'
        AND pag4.pgmt_dtpagamento <= CURRENT_DATE
        UNION ALL
    SELECT 
        pag4.imov_id,
        pag4.cnta_id AS idconta,
        pag4.pghi_amreferenciapagamento AS referencia,
        pag4.pghi_dtpagamento AS data_pagamento,
        pag4.pghi_vlpagamento AS valor_pago
    FROM arrecadacao.pagamento_historico pag4
    WHERE 
        pag4.pgst_idatual IN (0,1,2)
        AND pag4.pghi_dtpagamento >= '2026-01-01'
        AND pag4.pghi_dtpagamento <= CURRENT_DATE
       
    ) AS subq
)

SELECT 
    imo.imov_id AS "MATRICULA",
    loc.loca_id AS "LOCALIDADE",
    subq.idconta AS "NUMERO CONTA",    
    subq.referencia AS "REFERENCIA PAGAMENTO",
    subq.data_pagamento AS "DATA PAGAMENTO",    
    TO_CHAR(subq.valor_pago, '999G999G990D00') AS "VALOR PAGAMENTO"

FROM 
    cadastro.imovel imo
    INNER JOIN cadastro.cliente_imovel cim 
        ON cim.imov_id = imo.imov_id 
       AND cim.clim_dtrelacaofim IS NULL 
       AND cim.clim_icnomeconta = 1
    INNER JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
    LEFT JOIN cadastro.cliente_imovel cim2 
        ON cim2.imov_id = imo.imov_id 
       AND cim2.clim_dtrelacaofim IS NULL 
       AND cim2.crtp_id = 3
    LEFT JOIN cadastro.cliente cli2 ON cli2.clie_id = cim2.clie_id
    LEFT JOIN cadastro.cliente cli3 ON cli3.clie_id = cli2.clie_cdclienteresponsavel
    INNER JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
    INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
    INNER JOIN cadastro.logradouro_bairro lgb ON lgb.lgbr_id = imo.lgbr_id
    INNER JOIN cadastro.logradouro logr ON lgb.logr_id = logr.logr_id	
    INNER JOIN cadastro.bairro bai ON bai.bair_id = lgb.bair_id
    INNER JOIN cadastro.municipio mun ON mun.muni_id = bai.muni_id
    LEFT JOIN cadastro.logradouro_cep lgc ON lgc.lgcp_id = imo.lgcp_id
    LEFT JOIN cadastro.cep cep ON cep.cep_id = lgc.cep_id
    LEFT JOIN contas_consolidadas subq ON subq.imov_id = imo.imov_id

WHERE
    imo.imov_icexclusao = 2
    --AND imo.imov_idcategoriaprincipal = 4
    AND subq.valor_pago > 0
ORDER BY loc.loca_id, imo.imov_id
