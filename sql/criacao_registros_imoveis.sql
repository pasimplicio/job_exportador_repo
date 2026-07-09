WITH ops AS (
    SELECT
        CAST(oe.opef_cnargumento AS BIGINT)      AS imov_id,
        op.oper_dsoperacao                      AS descricao_operacao,
        MIN(oe.opef_tmultimaalteracao)          AS ts_operacao
    FROM seguranca.operacao_efetuada oe
    JOIN seguranca.operacao op ON op.oper_id = oe.oper_id
    WHERE oe.oper_id = 9
      AND oe.opef_tmultimaalteracao BETWEEN DATE '2025-01-01' AND CURRENT_DATE
      AND oe.opef_cnargumento IS NOT NULL
    GROUP BY CAST(oe.opef_cnargumento AS BIGINT), op.oper_dsoperacao
),

his_ativo AS (
    SELECT
        his.*,
        ROW_NUMBER() OVER (
            PARTITION BY his.lagu_id
            ORDER BY his.hidi_dtinstalacaohidrometro DESC, his.hidi_id DESC
        ) AS rn
    FROM micromedicao.hidrometro_inst_hist his
),

faturamento_ref_raw AS (
    SELECT 
        con.imov_id,
        con.cnta_amreferenciaconta AS referencia,
        con.cnta_vlagua + con.cnta_vlesgoto + con.cnta_vldebitos - con.cnta_vlcreditos - con.cnta_vlimpostos AS valor
    FROM faturamento.conta con
    WHERE con.dcst_idatual IN (0,1,2,5)
      AND con.cnta_amreferenciaconta >= 202501

    UNION ALL

    SELECT 
        con.imov_id,
        con.cnhi_amreferenciaconta AS referencia,
        con.cnhi_vlagua + con.cnhi_vlesgoto + con.cnhi_vldebitos - con.cnhi_vlcreditos - con.cnhi_vlimpostos AS valor
    FROM faturamento.conta_historico con
    WHERE con.dcst_idatual IN (0,1,2,5)
      AND con.cnhi_amreferenciaconta >= 202501
),

faturamento_ref AS (
    SELECT
        imov_id,
        COUNT(*) AS qtd,
        MIN(referencia) AS menorreferencia,
        MAX(referencia) AS maiorreferencia,
        SUM(valor) AS valor
    FROM faturamento_ref_raw
    GROUP BY imov_id
),

faturamento_atual AS (
    SELECT 
        con.imov_id,
        con.cnta_amreferenciaconta AS referencia,
        con.cnta_vlagua + con.cnta_vlesgoto + con.cnta_vldebitos - con.cnta_vlcreditos - con.cnta_vlimpostos AS valor
    FROM faturamento.conta con
    WHERE con.dcst_idatual IN (0,1,2,5)
      AND con.cnta_amreferenciaconta = 202508

    UNION ALL

    SELECT 
        con.imov_id,
        con.cnhi_amreferenciaconta AS referencia,
        con.cnhi_vlagua + con.cnhi_vlesgoto + con.cnhi_vldebitos - con.cnhi_vlcreditos - con.cnhi_vlimpostos AS valor
    FROM faturamento.conta_historico con
    WHERE con.dcst_idatual IN (0,1,2,5)
      AND con.cnhi_amreferenciaconta = 202508
),
pivot_faturamento AS (
    SELECT 
        imov_id,
        SUM(CASE WHEN referencia = 202508 THEN valor ELSE 0 END) AS valor_202508
    FROM faturamento_atual
    GROUP BY imov_id
)

SELECT
    imo.imov_id AS "Imovel",
    ipe.iper_dsimovelperfil AS "Perfil",    
    CASE imo.imov_idcategoriaprincipal 
        WHEN 1 THEN 'RESIDENCIAL'
        WHEN 2 THEN 'COMERCIAL'
        WHEN 3 THEN 'INDUSTRIAL'
        WHEN 4 THEN 'PUBLICO'
        ELSE 'NAO DEFINIDO'
    END AS "CATEGORIA PRINCIPAL",        
    o.descricao_operacao AS "Operacao",
    TO_CHAR(o.ts_operacao,'DD/MM/YYYY') AS "Data criacao",
    loc.loca_id AS "Codigo localidade",  
    loc.loca_nmlocalidade AS "Nome da localidade",
    sec.stcm_cdsetorcomercial AS "Setor comercial",
    qdr.qdra_nnquadra AS "Quadra",
    imo.imov_nnsequencialrota AS "Sequencia",
    imo.imov_nnsublote AS "Sub lote",
    rot.rota_cdrota AS "Rota",
    lgt.lgtp_dslogradourotipo AS "Tipo logradouro",
    logr.logr_nmlogradouro AS "Nome logradouro",
    cep.cep_cdcep AS "Cep",
    imo.imov_dscomplementoendereco AS "Complemento",
    bai.bair_nmbairro AS "Bairro",
    imo.imov_nnimovel AS "Numero",
    mun.muni_nmmunicipio AS "Municipio",
    hid.hidr_nnhidrometro AS "Numero hidrometro",
    ha.hidi_dtinstalacaohidrometro AS "Data instalacao hidrometro",
    las.last_dsligacaoaguasituacao AS "Situacao da agua",
    lagu.lagu_dtligacaoagua AS "Data ligacao",
    ref.qtd AS "Qtd. Faturadas",
    ref.menorreferencia AS "Menor Ref Faturadas",
    ref.maiorreferencia AS "Maior Ref Faturadas",
    TO_CHAR(ref.valor, '999G999G990D00') AS "Valor Faturado",
    TO_CHAR(pf.valor_202508, '999G999G990D00') AS "Valor 202508"    

FROM ops o
    INNER JOIN cadastro.imovel imo ON imo.imov_id = o.imov_id
    LEFT JOIN cadastro.imovel_perfil ipe ON imo.iper_id = ipe.iper_id
    LEFT JOIN pivot_faturamento pf ON pf.imov_id = o.imov_id
    LEFT JOIN faturamento_ref ref ON ref.imov_id = o.imov_id
    INNER JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
    INNER JOIN cadastro.setor_comercial sec ON imo.stcm_id = sec.stcm_id
    INNER JOIN cadastro.quadra qdr ON qdr.qdra_id = imo.qdra_id
    INNER JOIN micromedicao.rota rot ON rot.rota_id = qdr.rota_id
    INNER JOIN faturamento.faturamento_grupo ftg ON rot.ftgr_id = ftg.ftgr_id
    INNER JOIN cadastro.logradouro_bairro lgb ON lgb.lgbr_id = imo.lgbr_id
    INNER JOIN cadastro.logradouro logr ON lgb.logr_id = logr.logr_id
    INNER JOIN cadastro.bairro bai ON bai.bair_id = lgb.bair_id
    INNER JOIN cadastro.municipio mun ON mun.muni_id = bai.muni_id
    LEFT JOIN atendimentopublico.ligacao_agua_situacao las ON las.last_id = imo.last_id
    LEFT JOIN cadastro.logradouro_cep lgc ON lgc.lgcp_id = imo.lgcp_id
    LEFT JOIN cadastro.cep cep ON cep.cep_id = lgc.cep_id
    LEFT JOIN cadastro.logradouro_tipo lgt ON lgt.lgtp_id = logr.lgtp_id
    LEFT JOIN atendimentopublico.ligacao_agua lagu ON lagu.lagu_id = imo.imov_id
    LEFT JOIN his_ativo ha ON ha.lagu_id = lagu.lagu_id AND ha.rn = 1
    LEFT JOIN micromedicao.hidrometro hid ON hid.hidr_id = ha.hidr_id
WHERE imo.imov_icexclusao = 2



