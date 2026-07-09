SELECT
    imov.imov_id AS MATRICULA,
    stcm.stcm_nmsetorcomercial AS SETOR,
    rota.rota_cdrota AS ROTA,
    imov.imov_nnlote AS LOTE,

    --pivot com case e group by
    SUM(CASE conta.REFERENCIA WHEN 202312 THEN conta.CONSUMO END) AS CONSUMO_202312,
    SUM(CASE conta.REFERENCIA WHEN 202401 THEN conta.CONSUMO END) AS CONSUMO_202401,
    SUM(CASE conta.REFERENCIA WHEN 202412 THEN conta.CONSUMO END) AS CONSUMO_202412,
    TO_CHAR(SUM(CASE conta.REFERENCIA WHEN 202312 THEN conta.VALOR END), '999G999G990D00') AS VALOR_202312,
    TO_CHAR(SUM(CASE conta.REFERENCIA WHEN 202401 THEN conta.VALOR END), '999G999G990D00') AS VALOR_202401,
    TO_CHAR(SUM(CASE conta.REFERENCIA WHEN 202412 THEN conta.VALOR END), '999G999G990D00') AS VALOR_202412,
    TO_CHAR(SUM(CASE pagto.REFERENCIA WHEN 202312 THEN pagto.VALOR END), '999G999G990D00') AS PAGO_202312,
    TO_CHAR(SUM(CASE pagto.REFERENCIA WHEN 202401 THEN pagto.VALOR END), '999G999G990D00') AS PAGO_202401,
    TO_CHAR(SUM(CASE pagto.REFERENCIA WHEN 202412 THEN pagto.VALOR END), '999G999G990D00') AS PAGO_202412

FROM
    cadastro.imovel imov
    INNER JOIN cadastro.quadra qdra ON qdra.qdra_id = imov.qdra_id
    INNER JOIN cadastro.setor_comercial stcm ON stcm.stcm_id = qdra.stcm_id
    INNER JOIN micromedicao.rota rota ON rota.rota_id = qdra.rota_id
    --subquery dados faturamento
    LEFT JOIN (
        SELECT
            imov_id,
            cnta.cnta_amreferenciaconta AS REFERENCIA,
            cnta.cnta_nnconsumoagua AS CONSUMO,
            SUM(cnta.cnta_vlagua + cnta.cnta_vlesgoto + cnta.cnta_vldebitos - cnta.cnta_vlcreditos - cnta.cnta_vlimpostos) AS VALOR
        FROM faturamento.conta cnta
        WHERE
            cnta.dcst_idatual IN (0,1,2)
        GROUP BY 1,2,3
        UNION
        SELECT
            imov_id,
            cnta.cnhi_amreferenciaconta AS REFERENCIA,
            cnta.cnhi_nnconsumoagua AS CONSUMO,
            SUM(cnta.cnhi_vlagua + cnta.cnhi_vlesgoto + cnta.cnhi_vldebitos - cnta.cnhi_vlcreditos - cnta.cnhi_vlimpostos) AS VALOR
        FROM faturamento.conta_historico cnta
        WHERE
            cnta.dcst_idatual IN (0,1,2)
        GROUP BY 1,2,3
    ) AS conta ON (imov.imov_id = conta.imov_id) 
    --subquery dados pagamento
    LEFT JOIN (
        SELECT
	    imov_id,
	    pgmt.pgmt_amreferenciapagamento as REFERENCIA,
	    pgmt.pgmt_vlpagamento as VALOR
  	FROM	
	    arrecadacao.pagamento pgmt
	WHERE
	    pgmt.pgst_idatual <> 1
	UNION
	SELECT
	    imov_id,
	    pgmt.pghi_amreferenciapagamento as REFERENCIA,
	    pgmt.pghi_vlpagamento as VALOR
  	FROM	
	    arrecadacao.pagamento_historico pgmt
	WHERE
	    pgmt.pgst_idatual <> 1
	) as pagto on pagto.imov_id = imov.imov_id AND conta.REFERENCIA = pagto.REFERENCIA
    --LEFT JOIN micromedicao.consumo_historico cshi on cshi.imov_id = imov.imov_id AND cshi.lgti_id = 1 AND conta.REFERENCIA = cshi.cshi_amfaturamento AND pagto.REFERENCIA = cshi.cshi_amfaturamento
    
WHERE
    --where aninhado para trazer as matrículas das rotas da litoranea
    (
        stcm.stcm_nmsetorcomercial = 107 
        AND 
        (
         (rota.rota_cdrota = 48 AND imov.imov_nnlote BETWEEN 720 AND 1855) 
         OR 
         (rota.rota_cdrota = 55 AND imov.imov_nnlote = 5497)
        )
    )
    OR
    (
        stcm.stcm_nmsetorcomercial = 110 
        AND 
        (
            rota.rota_cdrota = 19 
            AND 
            (
                imov.imov_nnlote BETWEEN 28 AND 916 
                or 
                imov.imov_nnlote BETWEEN 927 AND 1100
            )
            OR 
            (
                rota.rota_cdrota = 20 
                AND 
                (
                    imov.imov_nnlote BETWEEN 12 AND 104 
                    or 
                    imov.imov_nnlote BETWEEN 277 AND 935
                )
                  OR
                  (
                      rota.rota_cdrota = 34 AND imov.imov_nnlote BETWEEN 30 AND 1955
                  )
            )
        )
    )
    AND imov.imov_icexclusao = 2
    --AND mcpf.medt_id = 1
    --AND imov.imov_id = 3524035
    
GROUP BY 1, 2, 3, 4
ORDER BY
    setor, rota, lote;