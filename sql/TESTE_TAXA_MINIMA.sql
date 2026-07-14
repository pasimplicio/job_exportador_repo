SELECT
    mat1,
    referencia,
    subcategoria,
    valor
FROM (

    SELECT 
        con.imov_id AS mat1,
        con.cnta_amreferenciaconta AS referencia,
        catc.scat_id AS subcategoria,
        (
            CASE

                WHEN con.cnta_amreferenciaconta BETWEEN 201511 AND 201604 THEN
                    CASE
                        WHEN catc.catg_id = 1 THEN
                            CASE WHEN catc.scat_id IN (7,9) THEN 12.78 ELSE 16.85 END
                        WHEN catc.catg_id = 2 THEN
                            CASE WHEN catc.scat_id = 8 THEN 52.42 ELSE 87.54 END
                        WHEN catc.catg_id = 3 THEN 89.74
                        WHEN catc.catg_id = 4 THEN 89.92
                        ELSE 0
                    END


                WHEN con.cnta_amreferenciaconta BETWEEN 201605 AND 201608 THEN
                    CASE
                        WHEN catc.catg_id = 1 THEN
                            CASE WHEN catc.scat_id IN (7,9) THEN 14.31 ELSE 18.87 END
                        WHEN catc.catg_id = 2 THEN
                            CASE WHEN catc.scat_id = 8 THEN 58.71 ELSE 98.04 END
                        WHEN catc.catg_id = 3 THEN 100.51
                        WHEN catc.catg_id = 4 THEN 100.71
                        ELSE 0
                    END

 
                WHEN con.cnta_amreferenciaconta BETWEEN 201609 AND 201901 THEN
                    CASE
                        WHEN catc.catg_id = 1 THEN
                            CASE WHEN catc.scat_id IN (7,9) THEN 15.80 ELSE 20.84 END
                        WHEN catc.catg_id = 2 THEN
                            CASE WHEN catc.scat_id = 8 THEN 64.83 ELSE 108.27 END
                        WHEN catc.catg_id = 3 THEN 110.99
                        WHEN catc.catg_id = 4 THEN 111.21
                        ELSE 0
                    END

 
                WHEN con.cnta_amreferenciaconta BETWEEN 201902 AND 202312 THEN
                    CASE
                        WHEN catc.catg_id = 1 THEN
                            CASE WHEN catc.scat_id IN (7,9) THEN 19.33 ELSE 25.49 END
                        WHEN catc.catg_id = 2 THEN
                            CASE WHEN catc.scat_id = 8 THEN 79.31 ELSE 132.45 END
                        WHEN catc.catg_id = 3 THEN 135.77
                        WHEN catc.catg_id = 4 THEN 136.04
                        ELSE 0
                    END

                 WHEN con.cnta_amreferenciaconta BETWEEN 202401 AND 202601 THEN
                    CASE
                        WHEN catc.catg_id = 1 THEN
                            CASE WHEN catc.scat_id IN (7,9) THEN 25.42 ELSE 33.58 END
                        WHEN catc.catg_id = 2 THEN
                            CASE WHEN catc.scat_id = 8 THEN 104.50 ELSE 174.42 END
                        WHEN catc.catg_id = 3 THEN 178.77
                        WHEN catc.catg_id = 4 THEN 179.16
                        ELSE 0
                    END
                ELSE 0
            END
            + con.cnta_vldebitos
            - con.cnta_vlcreditos
            - con.cnta_vlimpostos
        ) AS valor
    FROM faturamento.conta con
    JOIN cadastro.imovel imo ON imo.imov_id = con.imov_id
    JOIN faturamento.conta_categoria catc ON catc.cnta_id = con.cnta_id
    
    WHERE con.dcst_idatual IN (0,1,2)
      AND con.imov_id IN (5932,
5959,
5975,
5983,
6009
)
      AND con.cnta_dtrevisao IS NULL
      AND con.cnta_dtvencimentoconta < CURRENT_DATE
      AND con.cnta_amreferenciaconta BETWEEN 201511 AND 202601
      AND NOT EXISTS (
          SELECT 1 FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con.cnta_id
      )

    UNION ALL


    SELECT 
        con.imov_id,
        con.cnhi_amreferenciaconta,
        cath.scat_id,
        (
            CASE
                WHEN con.cnhi_amreferenciaconta BETWEEN 201511 AND 201604 THEN
                    CASE
                        WHEN cath.catg_id = 1 THEN
                            CASE WHEN cath.scat_id IN (7,9) THEN 12.78 ELSE 16.85 END
                        WHEN cath.catg_id = 2 THEN
                            CASE WHEN cath.scat_id = 8 THEN 52.42 ELSE 87.54 END
                        WHEN cath.catg_id = 3 THEN 89.74
                        WHEN cath.catg_id = 4 THEN 89.92
                        ELSE 0
                    END
                WHEN con.cnhi_amreferenciaconta BETWEEN 201605 AND 201608 THEN
                    CASE
                        WHEN cath.catg_id = 1 THEN
                            CASE WHEN cath.scat_id IN (7,9) THEN 14.31 ELSE 18.87 END
                        WHEN cath.catg_id = 2 THEN
                            CASE WHEN cath.scat_id = 8 THEN 58.71 ELSE 98.04 END
                        WHEN cath.catg_id = 3 THEN 100.51
                        WHEN cath.catg_id = 4 THEN 100.71
                        ELSE 0
                    END
                WHEN con.cnhi_amreferenciaconta BETWEEN 201609 AND 201901 THEN
                    CASE
                        WHEN cath.catg_id = 1 THEN
                            CASE WHEN cath.scat_id IN (7,9) THEN 15.80 ELSE 20.84 END
                        WHEN cath.catg_id = 2 THEN
                            CASE WHEN cath.scat_id = 8 THEN 64.83 ELSE 108.27 END
                        WHEN cath.catg_id = 3 THEN 110.99
                        WHEN cath.catg_id = 4 THEN 111.21
                        ELSE 0
                    END
                WHEN con.cnhi_amreferenciaconta BETWEEN 201902 AND 202312 THEN
                    CASE
                        WHEN cath.catg_id = 1 THEN
                            CASE WHEN cath.scat_id IN (7,9) THEN 19.33 ELSE 25.49 END
                        WHEN cath.catg_id = 2 THEN
                            CASE WHEN cath.scat_id = 8 THEN 79.31 ELSE 132.45 END
                        WHEN cath.catg_id = 3 THEN 135.77
                        WHEN cath.catg_id = 4 THEN 136.04
                        ELSE 0
                    END
                WHEN con.cnhi_amreferenciaconta BETWEEN 202401 AND 202601 THEN
                    CASE
                        WHEN cath.catg_id = 1 THEN
                            CASE WHEN cath.scat_id IN (7,9) THEN 25.42 ELSE 33.58 END
                        WHEN cath.catg_id = 2 THEN
                            CASE WHEN cath.scat_id = 8 THEN 104.50 ELSE 174.42 END
                        WHEN cath.catg_id = 3 THEN 178.77
                        WHEN cath.catg_id = 4 THEN 179.16
                        ELSE 0
                    END
                ELSE 0
            END
            + con.cnhi_vldebitos
            - con.cnhi_vlcreditos
            - con.cnhi_vlimpostos
        )
    FROM faturamento.conta_historico con
    JOIN cadastro.imovel imo ON imo.imov_id = con.imov_id
    JOIN faturamento.conta_catg_hist cath ON cath.cnta_id = con.cnta_id
    WHERE con.dcst_idatual IN (0,1,2)
      AND con.imov_id IN (5932,
5959,
5975,
5983,
6009
)
      AND con.cnhi_dtrevisao IS NULL
      AND con.cnhi_dtvencimentoconta < CURRENT_DATE
      AND con.cnhi_amreferenciaconta BETWEEN 201511 AND 202601
      AND NOT EXISTS (
          SELECT 1 FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con.cnta_id
      )
) y
