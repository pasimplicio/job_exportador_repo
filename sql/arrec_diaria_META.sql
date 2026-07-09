-- This query aims to find data on daily payments, using CTE's.
 WITH pagamentos AS 
    (SELECT ardd.loca_id AS loca, 
            TO_CHAR(TO_DATE(ardd.ardd_amreferenciaarrecadacao::text, 'YYYYMM'), 'MM/YYYY') AS referencia, 
            catg.catg_dscategoria AS catg, 
            --iper.iper_dsimovelperfil AS iper, 
            --bnco.bnco_nmbanco AS bnco, 
            --arfm.arfm_dsarrecadacaoforma AS arfm, 
            ardd.ardd_dtpagamento AS data, 
            --SUM(ardd.ardd_qtdocumentos) AS docs,  
            SUM(ardd.ardd_vlpagamentos) AS pagamento 
     FROM arrecadacao.arrec_dados_diarios ardd 
     INNER JOIN cadastro.categoria catg ON catg.catg_id = ardd.catg_id 
     --INNER JOIN cadastro.imovel_perfil iper ON iper.iper_id = ardd.iper_id 
     --INNER JOIN arrecadacao.banco bnco ON bnco.bnco_id = ardd.arrc_id 
     --INNER JOIN arrecadacao.arrecadacao_forma arfm ON arfm.arfm_id = ardd.arfm_id 
     WHERE ardd.ardd_amreferenciaarrecadacao >= '202401' 
     GROUP BY 1, 
              2, 
              3, 
              4), 
      devolucoes AS 
    (SELECT dvdd.loca_id AS loca, 
            TO_CHAR(TO_DATE(dvdd.dvdd_amreferenciaarrecadacao::text, 'YYYYMM'), 'MM/YYYY') AS referencia, 
            catg.catg_dscategoria AS catg, 
            --iper.iper_dsimovelperfil AS iper, 
            --bnco.bnco_nmbanco AS bnco, 
            --arfm.arfm_dsarrecadacaoforma AS arfm, 
            dvdd.dvdd_dtdevolucao AS data, 
            --SUM(dvdd.dvdd_qtdocumentos) AS docs, 
            SUM(dvdd.dvdd_vldevolucoes) AS devolucao 
     FROM arrecadacao.devolucao_dados_diarios dvdd 
     INNER JOIN cadastro.categoria catg ON catg.catg_id = dvdd.catg_id 
     --INNER JOIN cadastro.imovel_perfil iper ON iper.iper_id = dvdd.iper_id 
     --INNER JOIN arrecadacao.banco bnco ON bnco.bnco_id = dvdd.arrc_id 
     --INNER JOIN arrecadacao.arrecadacao_forma arfm ON arfm.arfm_id = dvdd.arfm_id 
     WHERE dvdd.dvdd_amreferenciaarrecadacao >= '202401' 
     GROUP BY 1, 
              2, 
              3, 
              4)
SELECT COALESCE(p.loca, d.loca) AS "ID LOCALIDADE", 
       COALESCE(p.referencia, d.referencia) AS "REFERENCIA", 
       COALESCE(p.catg, d.catg) AS "CATEGORIA", 
       --COALESCE(p.iper, d.iper) AS "PERFIL", 
       --COALESCE(p.bnco, d.bnco) AS "BANCO", 
       --COALESCE(p.arfm, d.arfm) AS "FORMA DE ARRECADACAO", 
       TO_CHAR(COALESCE(p.data, d.data), 'DD/MM/YYYY') AS "DATA DE PAGAMENTO", 
       --COALESCE(p.docs, d.docs) AS "QTD DOCUMENTOS PAGOS", 
       TO_CHAR(COALESCE(p.pagamento, 0), 'L999G999G990D00') AS "VALOR PAG", 
       TO_CHAR(COALESCE(d.devolucao, 0), 'L999G999G990D00') AS "VALOR DEV", 
       TO_CHAR(COALESCE(p.pagamento, 0) - COALESCE(d.devolucao, 0), 'L999G999G990D00') AS "VALOR ARR"
FROM pagamentos p
FULL OUTER JOIN devolucoes d ON (p.loca = d.loca
                                 AND p.referencia = d.referencia
                                 AND p.catg = d.catg
                                 --AND p.iper = d.iper
                                 --AND p.bnco = d.bnco
                                 --AND p.arfm = d.arfm
                                 AND p.data = d.data
                                 --AND p.docs = d.docs
                                 )
ORDER BY 2;

