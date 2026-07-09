WITH arrec_base AS (
    SELECT
        res.loca_id AS localidade_id,
        CASE 
            WHEN EXTRACT(YEAR FROM res.ardd_dtpagamento) * 100 + EXTRACT(MONTH FROM res.ardd_dtpagamento) = res.ardd_amreferenciaarrecadacao 
                THEN res.ardd_dtpagamento
            ELSE TO_DATE(CAST(res.ardd_amreferenciaarrecadacao AS VARCHAR) || '01', 'YYYYMMDD')
        END AS data_arrec,
        res.ardd_amreferenciaarrecadacao AS referencia,
        res.catg_id,
        SUM(res.ardd_qtdocumentos) AS qt_documents,
        SUM(res.ardd_vlpagamentos) AS valor
    FROM arrecadacao.arrec_dados_diarios res
    WHERE res.ardd_amreferenciaarrecadacao >= 202601
    GROUP BY 1,2,3,4
),
devol_base AS (
    SELECT
        dev.loca_id AS localidade_id,
        CASE 
            WHEN EXTRACT(YEAR FROM dev.dvdd_dtdevolucao) * 100 + EXTRACT(MONTH FROM dev.dvdd_dtdevolucao) = dev.dvdd_amreferenciaarrecadacao 
                THEN dev.dvdd_dtdevolucao
            ELSE TO_DATE(CAST(dev.dvdd_amreferenciaarrecadacao AS VARCHAR) || '01', 'YYYYMMDD')
        END AS data_arrec,
        dev.dvdd_amreferenciaarrecadacao AS referencia,
        dev.catg_id,
        SUM(dev.dvdd_vldevolucoes) AS valor
    FROM arrecadacao.devolucao_dados_diarios dev
    WHERE dev.dvdd_amreferenciaarrecadacao >= 202601
    GROUP BY 1,2,3,4
)

SELECT
    'ARRECADACAO' AS "TIPO",
    a.localidade_id AS "LOCALIDADE",
    a.referencia AS "REFERENCIA",
    cat.catg_dscategoria AS "CATEGORIA",
    TO_CHAR(a.data_arrec, 'DD/MM/YYYY') AS "DATA ARREC/FAT",
    SUM(a.valor) AS "VALOR PAG",
    SUM(COALESCE(d.valor, 0)) AS "VALOR DEV",
    SUM(a.valor - COALESCE(d.valor, 0)) AS "VALOR ARR",
    SUM(a.qt_documents) AS "QTD"
FROM arrec_base a
LEFT JOIN devol_base d ON d.localidade_id = a.localidade_id 
    AND d.data_arrec = a.data_arrec 
    AND d.referencia = a.referencia 
    AND d.catg_id = a.catg_id
INNER JOIN cadastro.categoria cat ON cat.catg_id = a.catg_id
GROUP BY 1,2,3,4,5
ORDER BY 5 DESC, 2 ASC;
