WITH contas_validas AS (
  SELECT 
    con.imov_id,
    imo.imov_idcategoriaprincipal AS categoria_principal, -- usa categoria atual do imóvel
    con.cnta_id AS codigoconta,
    con.cnta_amreferenciaconta AS referencia,
    con.cnta_dtvencimentoconta AS vencimento,
    con.cnta_nnconsumoagua AS cagua,
    con.cnta_nnconsumoesgoto AS cesg,    
    con.cnta_vlagua AS vl_agua,
    con.cnta_vlesgoto AS vl_esgoto,
    con.cnta_vldebitos AS vl_debitos,    
    con.cnta_vlcreditos AS vl_creditos,
    con.cnta_vlimpostos AS vl_impostos,

    -- valor base
    (con.cnta_vlagua + con.cnta_vlesgoto + con.cnta_vldebitos - con.cnta_vlcreditos - con.cnta_vlimpostos) AS valor,

    -- multa 2%
    trunc(
      (
        (
          con.cnta_vlagua + con.cnta_vlesgoto - con.cnta_vlcreditos - con.cnta_vlimpostos +
          coalesce((
              SELECT SUM(dco.dbcb_vlprestacao)::numeric
              FROM faturamento.debito_cobrado dco
              WHERE con.cnta_id = dco.cnta_id 
                AND dco.dbtp_id != 80
          ), 0)
        ) * 0.02
      )::numeric, 2
    ) AS multa,

    -- juros 0.5% ao mês
    trunc(
      (
        (
          (con.cnta_vlagua + con.cnta_vlesgoto + con.cnta_vldebitos - con.cnta_vlcreditos - con.cnta_vlimpostos)
          * 0.005 *
          (
            ((EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM con.cnta_dtvencimentoconta)) * 12) + 
            (EXTRACT(MONTH FROM CURRENT_DATE) - EXTRACT(MONTH FROM con.cnta_dtvencimentoconta))
          )
        )
      )::numeric, 2
    ) AS juros

  FROM faturamento.conta con
  JOIN faturamento.conta_categoria catg ON catg.cnta_id = con.cnta_id
  JOIN cadastro.imovel imo ON imo.imov_id = con.imov_id

  WHERE con.dcst_idatual IN (0,1,2)
    AND con.cnta_dtrevisao IS NULL
    AND con.cnta_dtvencimentoconta < CURRENT_DATE
    AND con.iper_id <> 6
    AND NOT EXISTS (
      SELECT 1 
      FROM arrecadacao.pagamento pag 
      WHERE pag.cnta_id = con.cnta_id
    )
    AND con.cnta_dtvencimentoconta > '2024-12-31'   
/*    -- Regras de prescrição conforme a categoria atual do imóvel
    AND (
         -- Públicos: até 5 anos
         (imo.imov_idcategoriaprincipal = 4 
          AND con.cnta_dtvencimentoconta >= CURRENT_DATE - INTERVAL '5 years')
         OR
         -- Demais: até 10 anos
         (imo.imov_idcategoriaprincipal IN (1,2,3)
          AND con.cnta_dtvencimentoconta >= CURRENT_DATE - INTERVAL '10 years')
        )*/
    --AND con.cnta_amreferenciaconta >= 202501
),

faturamento_final AS (
  SELECT
    imov_id,
    codigoconta,
    referencia,
    vencimento,
    cagua,
    cesg,   
    vl_agua,
    vl_esgoto,
    vl_debitos,
    vl_creditos,
    vl_impostos,
    valor,
    multa,
    juros
  FROM contas_validas
  GROUP BY imov_id, codigoconta,referencia, vencimento, vl_agua, vl_esgoto, vl_debitos, vl_creditos, vl_impostos, valor, multa, juros, cagua, cesg
)

-- SELECT principal
SELECT 
  imo.imov_id AS "MATRICULA",
  loc.loca_id AS "LOCALIDADE",
  ff.codigoconta AS "CODIGO CONTA",
  referencia AS "REFERENCIA",
  vencimento AS "VENCIMENTO CONTA",
  ff.cagua AS "CONSUMO AGUA",
  ff.cesg AS "CONSUMO ESGOTO",  
  TO_CHAR(ff.vl_agua, '999G999G990D00') AS "VALOR AGUA",
  TO_CHAR(ff.vl_esgoto, '999G999G990D00') AS "VALOR ESGOTO",
  TO_CHAR(ff.vl_debitos, '999G999G990D00') AS "DEBITOS",
  TO_CHAR(ff.vl_creditos, '999G999G990D00') AS "CREDITOS",
  TO_CHAR(ff.vl_impostos, '999G999G990D00') AS "IMPOSTOS",
  TO_CHAR(ff.valor, '999G999G990D00') AS "VALOR TOTAL",
  TO_CHAR(ff.multa, '999G999G990D00') AS "MULTA",
  TO_CHAR(ff.juros, '999G999G990D00') AS "JUROS"
FROM cadastro.imovel imo
  INNER JOIN cadastro.localidade loc 
    ON imo.loca_id = loc.loca_id 
    AND loc.greg_id IN (1, 2)
  LEFT JOIN faturamento_final ff ON ff.imov_id = imo.imov_id
WHERE ff.valor > 0
  --AND imo.imov_id = 489450
ORDER BY imo.imov_id DESC;
