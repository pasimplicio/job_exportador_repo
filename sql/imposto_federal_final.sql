WITH pagamentos_unificados AS (
    SELECT cnta_id FROM arrecadacao.pagamento
    UNION
    SELECT cnta_id FROM arrecadacao.pagamento_historico
),

clientes_excluidos AS (
    SELECT UNNEST(ARRAY[
        150,160,175,473,11983260,12004758,12145479,12015991,10161945,450,459,455,460,470,
        472,493,474,475,499,11930509,11538925,11643916,11608589,11876175,11984584,
        8954860,496,453,800,14349922
    ]) AS clie_id
),

impostos_consolidados AS (
    SELECT
        cid.cnta_id,
        cid.imtp_id,
        cid.cnid_vlimposto AS valor_imposto
    FROM faturamento.conta_impostos_deduzidos cid

    UNION ALL

    SELECT
        cidh.cnta_id,
        cidh.imtp_id,
        cidh.cidh_vlimposto AS valor_imposto
    FROM faturamento.conta_impostos_dedz_hist cidh
),

impostos_agrupados AS (
    SELECT
        ic.cnta_id,
        SUM(CASE WHEN ic.imtp_id = 1 THEN ic.valor_imposto ELSE 0 END) AS imposto_renda,
        SUM(CASE WHEN ic.imtp_id = 2 THEN ic.valor_imposto ELSE 0 END) AS contribuicao_social,
        SUM(CASE WHEN ic.imtp_id = 3 THEN ic.valor_imposto ELSE 0 END) AS cofins,
        SUM(CASE WHEN ic.imtp_id = 4 THEN ic.valor_imposto ELSE 0 END) AS pis_pasep
    FROM impostos_consolidados ic
    GROUP BY ic.cnta_id
),

faturamento_filtrado AS (
    SELECT 
        c.imov_id AS matricula,
        c.cnta_id,
        catc.scat_id AS subcategoria,
        c.cnta_amreferenciaconta AS referencia,
        (c.cnta_amreferenciaconta / 100) AS ano,
        c.cnta_vlimpostos AS vlimpostos,
        (c.cnta_vlagua + c.cnta_vlesgoto + c.cnta_vldebitos 
         - c.cnta_vlcreditos - c.cnta_vlimpostos) AS valor,
        cli.clie_id,
        cli.clie_nmcliente,
        ia.cofins,
        ia.contribuicao_social,
        ia.imposto_renda,
        ia.pis_pasep,
        CASE 
            WHEN pu.cnta_id IS NOT NULL THEN 'PAGA'
            ELSE 'NAO PAGA'
        END AS situacao_conta
    FROM faturamento.conta c
    JOIN faturamento.conta_categoria catc 
        ON c.cnta_id = catc.cnta_id
    JOIN cadastro.cliente_imovel cim 
        ON cim.imov_id = c.imov_id 
       AND cim.clim_icnomeconta = 1
       AND cim.clim_dtrelacaofim IS NULL
    JOIN cadastro.cliente cli 
        ON cli.clie_id = cim.clie_id
    LEFT JOIN clientes_excluidos ce 
        ON ce.clie_id = cli.clie_id
    LEFT JOIN impostos_agrupados ia 
        ON ia.cnta_id = c.cnta_id
    LEFT JOIN pagamentos_unificados pu
        ON pu.cnta_id = c.cnta_id
    WHERE
        --c.imov_id = 13285
        ce.clie_id IS NULL
        AND c.cnta_amreferenciaconta BETWEEN '${VAR_REF_INICIAL}' AND '${VAR_REF_FINAL}'
        AND c.cnta_vlimpostos > 0

    UNION ALL

    SELECT 
        c.imov_id AS matricula,
        c.cnta_id,
        cath.scat_id AS subcategoria,
        c.cnhi_amreferenciaconta AS referencia,        
        (c.cnhi_amreferenciaconta / 100) AS ano,
        c.cnhi_vlimpostos AS vlimpostos,
        (c.cnhi_vlagua + c.cnhi_vlesgoto + c.cnhi_vldebitos 
         - c.cnhi_vlcreditos - c.cnhi_vlimpostos) AS valor,
        cli.clie_id,
        cli.clie_nmcliente,
        ia.cofins,
        ia.contribuicao_social,
        ia.imposto_renda,
        ia.pis_pasep,
        CASE 
            WHEN pu.cnta_id IS NOT NULL THEN 'PAGA'
            ELSE 'NAO PAGA'
        END AS situacao_conta
    FROM faturamento.conta_historico c
    JOIN faturamento.conta_catg_hist cath 
        ON c.cnta_id = cath.cnta_id
    JOIN cadastro.cliente_imovel cim 
        ON cim.imov_id = c.imov_id 
       AND cim.clim_icnomeconta = 1
       AND cim.clim_dtrelacaofim IS NULL
    JOIN cadastro.cliente cli 
        ON cli.clie_id = cim.clie_id
    LEFT JOIN clientes_excluidos ce 
        ON ce.clie_id = cli.clie_id
    LEFT JOIN impostos_agrupados ia 
        ON ia.cnta_id = c.cnta_id
    LEFT JOIN pagamentos_unificados pu
        ON pu.cnta_id = c.cnta_id
    WHERE
        ---c.imov_id = 13285
        ce.clie_id IS NULL
        AND c.cnhi_amreferenciaconta BETWEEN '${VAR_REF_INICIAL}' AND '${VAR_REF_FINAL}'
        AND c.cnhi_vlimpostos > 0
)

SELECT 
    f.matricula AS "MATRICULA",
    f.clie_id AS "ID CLIENTE",
    f.clie_nmcliente AS "NOME CLIENTE",
    f.ano AS "ANO",
    f.situacao_conta AS "STATUS CONTA",
    (CASE f.subcategoria
        WHEN 1 THEN '1 - RESIDENCIAL'
        WHEN 2 THEN '2 - COMERCIAL'
        WHEN 3 THEN '3 - INDUSTRIAL'
        WHEN 4 THEN '4 - MUNICIPAL'
        WHEN 5 THEN '5 - ESTADUAL'
        WHEN 6 THEN '6 - FEDERAL'
        WHEN 7 THEN '7 - RES. POPULAR'
        WHEN 8 THEN '8 - PEQ. NEGOCIOS'
        WHEN 9 THEN '9 - ENT. FILANTROPICAS'
        WHEN 10 THEN '10 - SIST. OPERADO POR PREFEITURA'
        ELSE 'NAO DEFINIDO'
    END) AS "SUBCATEGORIA PRINCIPAL",
    f.referencia AS "REFERENCIA",

    TO_CHAR(SUM(f.vlimpostos), '999G999G990D00') AS "TOTAL IMPOSTOS",
    TO_CHAR(SUM(f.valor), '999G999G990D00') AS "TOTAL FATURADO",

    TO_CHAR(SUM(COALESCE(f.cofins, 0)), '999G999G990D00') AS "COFINS",
    TO_CHAR(SUM(COALESCE(f.contribuicao_social, 0)), '999G999G990D00') AS "CONTRIBUICAO SOCIAL",
    TO_CHAR(SUM(COALESCE(f.imposto_renda, 0)), '999G999G990D00') AS "IMPOSTO DE RENDA",
    TO_CHAR(SUM(COALESCE(f.pis_pasep, 0)), '999G999G990D00') AS "PIS/PASEP"

FROM faturamento_filtrado f
GROUP BY 
    f.matricula, 
    f.clie_id, 
    f.clie_nmcliente, 
    f.ano, 
    f.situacao_conta,
    f.subcategoria, 
    f.referencia
ORDER BY 
    f.matricula, 
    f.clie_nmcliente, 
    f.ano, 
    f.referencia;
