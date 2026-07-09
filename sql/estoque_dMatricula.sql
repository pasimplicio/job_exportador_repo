SELECT
    imo.imov_id AS "MATRICULA",
    TO_CHAR(imo.imov_nncoordenaday, '990D999999999999999') AS "LATITUDE",
    TO_CHAR(imo.imov_nncoordenadax, '990D999999999999999') AS "LONGITUDE",
    cli.clie_id AS "CODIGO CLIENTE",
    cli.clie_nmcliente AS "NOME CLIENTE",
    cli.clie_nncpf AS "CPF",
    cli.clie_nncnpj AS "CNPJ",
    cli2.clie_id AS "COD_RESP",
    cli2.clie_nmcliente AS "NOME RESP",
    cli2.clie_nncpf AS "CPF RESP",
    cli2.clie_nncnpj AS "CNPJ RESP",
    cli3.clie_id AS "COD PAI",
    cli3.clie_nmcliente AS "NOME PAI",
    cli3.clie_nncpf AS "CPF PAI",
    cli3.clie_nncnpj AS "CNPJ PAI",
    CASE imo.iper_id
        WHEN 1 THEN 'GRANDE'
        WHEN 2 THEN 'GRANDE DO MES'
        WHEN 3 THEN 'ESPECIAL'
        WHEN 4 THEN 'TARIFA SOCIAL'
        WHEN 5 THEN 'NORMAL'
        WHEN 6 THEN 'VIVA AGUA'
        WHEN 7 THEN 'CONTRATOS PREFEIT.'
        WHEN 8 THEN 'CONDOMINIOS VERTICAIS'
        WHEN 9 THEN 'AGUA LEGAL'
        WHEN 10 THEN 'LAVA JATO'
        ELSE 'NAO DEFINIDO'
    END AS "PERFIL IMOVEL",
   
    -- CATEGORIAS
    (CASE imo.imov_idcategoriaprincipal 
        WHEN 1 THEN '1 - RESIDENCIAL'
        WHEN 2 THEN '2 - COMERCIAL'
        WHEN 3 THEN '3 - INDUSTRIAL'
        WHEN 4 THEN '4 - PUBLICO'
        ELSE 'NAO DEFINIDO'
    END) AS "CATEGORIA_PRINCIPAL",
    (CASE imo.imov_idsubcategoriaprincipal 
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
    END) AS "SUBCATEGORIA_PRINCIPAL",

    -- LOCALIDADE E ENDEREÇO
    loc.loca_id AS "LOCALIDADE",
    loc.loca_nmlocalidade AS "NOME LOCALIDADE",
    une.uneg_nmunidadenegocio AS "NOME UNIDADE",
    sec.stcm_cdsetorcomercial AS "SETOR COMERCIAL",
    qdr.qdra_nnquadra AS "QUADRA",
    imo.imov_nnsequencialrota AS "SEQUENCIA",
    imo.imov_nnsublote AS "SUB LOTE",
    rot.rota_cdrota AS "ROTA",
    lgt.lgtp_dslogradourotipo AS "TIPO LOGRADOURO",
    logr.logr_nmlogradouro AS "NOME LOGRADOURO",
    cep.cep_cdcep AS "CEP",
    imo.imov_dscomplementoendereco AS "COMPLEMENTO",
    bai.bair_nmbairro AS "BAIRRO",
    imo.imov_nnimovel AS "NUMERO",
    mun.muni_nmmunicipio AS "MUNICIPIO",
    
    -- SITUAÇÕES E CARACTERÍSTICAS
    las.last_dsligacaoaguasituacao AS "SITUACAO AGUA",
    les.lest_dsligacaoesgotosituacao AS "SITUACAO ESGOTO",
    hid.hidr_nnhidrometro AS "NUMERO HIDROMETRO",
    imo.imov_nnareaconstruida AS "AREA CONSTRUIDA",
    imo.imov_qteconomia AS "ECONOMIAS",
    ftg.ftgr_dsfaturamentogrupo AS "GRUPO FATURAMENTO"

FROM cadastro.imovel imo
    INNER JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id 
        AND cim.clim_dtrelacaofim IS NULL 
        AND cim.clim_icnomeconta = 1
    INNER JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
    LEFT JOIN cadastro.cliente_imovel cim2 ON cim2.imov_id = imo.imov_id 
        AND cim2.clim_dtrelacaofim IS NULL 
        AND cim2.crtp_id = 3
    LEFT JOIN cadastro.cliente cli2 ON cli2.clie_id = cim2.clie_id
    LEFT JOIN cadastro.cliente cli3 ON cli3.clie_id = cli2.clie_cdclienteresponsavel
    INNER JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
    INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
    INNER JOIN cadastro.setor_comercial sec ON imo.stcm_id = sec.stcm_id
    INNER JOIN cadastro.quadra qdr ON qdr.qdra_id = imo.qdra_id
    INNER JOIN micromedicao.rota rot ON rot.rota_id = qdr.rota_id
    INNER JOIN faturamento.faturamento_grupo ftg ON rot.ftgr_id = ftg.ftgr_id
    INNER JOIN cadastro.logradouro_bairro lgb ON lgb.lgbr_id = imo.lgbr_id
    INNER JOIN cadastro.logradouro logr ON lgb.logr_id = logr.logr_id
    INNER JOIN cadastro.bairro bai ON bai.bair_id = lgb.bair_id
    INNER JOIN cadastro.municipio mun ON mun.muni_id = bai.muni_id
    INNER JOIN cadastro.fonte_abastecimento ftb ON ftb.ftab_id = imo.ftab_id
    INNER JOIN atendimentopublico.ligacao_agua_situacao las ON las.last_id = imo.last_id
    INNER JOIN atendimentopublico.ligacao_esgoto_situacao les ON les.lest_id = imo.lest_id
    LEFT JOIN cadastro.logradouro_tipo lgt ON lgt.lgtp_id = logr.lgtp_id
    LEFT JOIN cadastro.logradouro_cep lgc ON lgc.lgcp_id = imo.lgcp_id
    LEFT JOIN cadastro.cep cep ON cep.cep_id = lgc.cep_id      
    LEFT JOIN atendimentopublico.ligacao_agua lagu ON lagu.lagu_id = imo.imov_id
    LEFT JOIN atendimentopublico.ligacao_esgoto lesg ON lesg.lesg_id = imo.imov_id    
    LEFT JOIN micromedicao.hidrometro_inst_hist his ON lagu.hidi_id = his.hidi_id AND his.hidi_dtretiradahidrometro IS NULL
    LEFT JOIN micromedicao.hidrometro hid ON his.hidr_id = hid.hidr_id
WHERE imo.imov_icexclusao = 2