WITH 
-- CTE para filtrar as matrículas com situação de faturamento suspenso
suspensoes AS (
    SELECT 
        fsh.imov_id AS imov_id, 
        ftm.ftsm_id AS id_motivo,
        CAST(fat.ftst_id AS TEXT) || ' - ' || fat.ftst_dsfaturamentosituacaotipo AS sit_faturamento,
        fsh.ftsh_amfatmtsitinicio AS inicio,
        fsh.ftsh_amfaturamentosituacaofim AS fim,
        ftm.ftsm_dsfatsitmotivo AS motivo,
	fsh.ftsh_amfaturamentoretirada AS ret       
    FROM faturamento.fatur_situacao_hist fsh
	LEFT JOIN faturamento.fatur_situacao_tipo fat ON fat.ftst_id = fsh.ftst_id
	LEFT JOIN faturamento.fatur_situacao_motivo ftm ON fsh.ftsm_id = ftm.ftsm_id
),

-- CTE para encontrar o último faturamento de cada matrícula
faturamento_final AS (
    SELECT 
        uniao.imov_id,
        uniao.referencia,
        uniao.valor
    FROM (
        -- União das tabelas faturamento.conta e faturamento.conta_historico
        SELECT 
            con.imov_id,
            con.cnta_amreferenciaconta AS referencia,
            con.cnta_vlagua + con.cnta_vlesgoto + con.cnta_vldebitos - con.cnta_vlcreditos - con.cnta_vlimpostos AS valor
        FROM faturamento.conta con
        UNION ALL
        SELECT 
            con.imov_id,
            con.cnhi_amreferenciaconta AS referencia,
            con.cnhi_vlagua + con.cnhi_vlesgoto + con.cnhi_vldebitos - con.cnhi_vlcreditos - con.cnhi_vlimpostos AS valor
        FROM faturamento.conta_historico con
    ) AS uniao
    -- Filtro para trazer apenas a última referência de cada matrícula
    WHERE (uniao.imov_id, uniao.referencia) IN (
        SELECT 
            referencias.imov_id,
            MAX(referencias.referencia) AS ultima_referencia
        FROM (
            SELECT 
                con.imov_id,
                con.cnta_amreferenciaconta AS referencia
            FROM faturamento.conta con
            UNION ALL
            SELECT 
                con.imov_id,
                con.cnhi_amreferenciaconta AS referencia
            FROM faturamento.conta_historico con
        ) AS referencias
        GROUP BY referencias.imov_id
    )
 ),

-- CTE para obter o último pagamento de cada matrícula
ultimo_pagamento AS (
    SELECT 
        pag.imov_id,
        (SELECT MAX(p.pgmt_amreferenciapagamento) 
         FROM arrecadacao.pagamento p 
         WHERE p.imov_id = pag.imov_id) AS referencia,
        pag.pgmt_vlpagamento AS valor
    FROM arrecadacao.pagamento pag
    INNER JOIN cadastro.localidade loc ON pag.loca_id = loc.loca_id
    WHERE pag.pgmt_amreferenciapagamento = (
        SELECT MAX(p2.pgmt_amreferenciapagamento)
        FROM arrecadacao.pagamento p2
        WHERE p2.imov_id = pag.imov_id
    )
)

-- Consulta principal que junta os dados das CTEs e a tabela cadastro.imovel
SELECT 
    imo.imov_id AS "MATRICULA",
    TO_CHAR(imo.imov_nncoordenadax,'990D999999999999999') AS "LATITUDE",
    TO_CHAR(imo.imov_nncoordenaday,'990D999999999999999') AS "LONGITUDE",     
    imo.imov_qteconomia AS "ECONOMIAS",    
    (CASE imo.imov_idcategoriaprincipal 
        WHEN 1 THEN '1 - RESIDENCIAL'
        WHEN 2 THEN '2 - COMERCIAL'
        WHEN 3 THEN '3 - INDUSTRIAL'
        WHEN 4 THEN '4 - PUBLICO'
        ELSE 'NAO DEFINIDO'
    END) AS "CATEGORIA PRINCIPAL",    
    cli.clie_nmcliente AS "NOME CLIENTE",
    loc.loca_id AS "CODIGO LOCALIDADE",
    une.uneg_nmunidadenegocio AS "NOME UNIDADE",
    bai.bair_nmbairro AS "BAIRRO",
    mun.muni_nmmunicipio AS "MUNICIPIO",
    
    -- Suspensões
    s.sit_faturamento AS "SIT. FATURAMENTO",
    s.inicio AS "INICIO SUSPENSAO",
    s.fim AS "FIM SUSPENSAO",
    s.ret AS "REF RETIRADA",
    s.motivo AS "MOTIVO SUSPENSAO",
    
    -- Faturamento Final
    ff.referencia AS "ULTIMA REF FATURADA",
    TO_CHAR(ff.valor, '999G999G990D00')  AS "ULTIMO VALOR FATURADO",

    -- Último Pagamento
    up.referencia AS "ULTIMA REF PAGO",
    TO_CHAR(up.valor, '999G999G990D00') AS "ULTIMO VALOR PAGO",
    
-- Campo de Faturamento Taxa Mínima
   (CASE 
	WHEN imo.imov_idcategoriaprincipal = 1 THEN TO_CHAR(imo.imov_qteconomia * 33.58, '999G999G990D00') -- Residencial
	WHEN imo.imov_idcategoriaprincipal = 2 THEN TO_CHAR(174.42, '999G999G990D00') -- Comercial
	WHEN imo.imov_idcategoriaprincipal = 3 THEN TO_CHAR(178.77, '999G999G990D00') -- Industrial
	WHEN imo.imov_idcategoriaprincipal = 4 THEN TO_CHAR(179.16, '999G999G990D00') -- Pública
	WHEN imo.imov_idcategoriaprincipal = 5 THEN TO_CHAR(imo.imov_qteconomia * 25.42, '999G999G990D00') -- Residencial Popular
	WHEN imo.imov_idcategoriaprincipal = 6 THEN TO_CHAR(imo.imov_qteconomia * 25.42, '999G999G990D00') -- Entidades Filantrópicas
	WHEN imo.imov_idcategoriaprincipal = 7 THEN TO_CHAR(104.50, '999G999G990D00') -- Comercial Pequenos Negócios
    ELSE 
        TO_CHAR(0.00, '999G999G990D00') -- Caso não haja uma categoria definida
    END) AS "FATURAMENTO TAXA MINIMA"
    
    
FROM cadastro.imovel imo
-- Join com as CTEs
	LEFT JOIN suspensoes s ON s.imov_id = imo.imov_id AND s.ret IS NULL -- Alterei para o alias correto
	LEFT JOIN faturamento_final ff ON ff.imov_id = imo.imov_id
	LEFT JOIN ultimo_pagamento up ON up.imov_id = imo.imov_id
-- Outras tabelas já existentes na consulta
	INNER JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
	INNER JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
	INNER JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id AND loc.greg_id IN (1, 2)
	INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
	INNER JOIN cadastro.logradouro_bairro lgb ON lgb.lgbr_id = imo.lgbr_id
	INNER JOIN cadastro.bairro bai ON bai.bair_id = lgb.bair_id
	INNER JOIN cadastro.municipio mun ON mun.muni_id = bai.muni_id
WHERE imo.imov_icexclusao = 2
--AND une.uneg_id IN (11,12,13,14,15)
ORDER BY imo.imov_id;
