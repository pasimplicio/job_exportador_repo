-- =============================================================================
-- RELATÓRIO DE INSTALAÇÃO DE HIDRÔMETROS
-- =============================================================================
-- Identificar o último registro de cada matrícula (lagu_id)
WITH ultimo_registro AS (
    SELECT
        lagu_id,
        hidi_id,
        hidi_dtinstalacaohidrometro,
        hidi_dtretiradahidrometro,
        ROW_NUMBER() OVER (
            PARTITION BY lagu_id 
            ORDER BY hidi_dtinstalacaohidrometro DESC, hidi_id DESC
        ) AS rn
    FROM 
        micromedicao.hidrometro_inst_hist
    WHERE 
        lagu_id IS NOT NULL
)
-- Consulta principal
SELECT
    -- Identificação da matrícula
    i.imov_id AS MATRICULA,
    
    -- Categoria do imóvel
    CASE
        WHEN i.imov_idcategoriaprincipal = 1 THEN 'RESIDENCIAL'
        WHEN i.imov_idcategoriaprincipal = 2 THEN 'COMERCIAL'
        WHEN i.imov_idcategoriaprincipal = 3 THEN 'INDUSTRIAL'
        WHEN i.imov_idcategoriaprincipal = 4 THEN 'PUBLICO'
        ELSE 'Outra'
    END AS "CATEGORIA",
    
    -- Informações de localização
    mu.muni_nmmunicipio AS "MUNICIPIO",
    l.loca_nmlocalidade AS "NOME LOCALIDADE",
    un.uneg_nmunidadenegocio AS "NOME UNIDADE",
    
    -- Informações do último registro
    ur.hidi_id AS "ULTIMO ID HID",
    
    -- Hidrômetro instalado (último registro sem data de retirada)
    CASE
        WHEN ur.hidi_dtretiradahidrometro IS NULL THEN 'SIM'
        ELSE 'NAO'
    END AS "INSTALADO?",
    
    -- Data de instalação do último registro
    TO_CHAR(ur.hidi_dtinstalacaohidrometro, 'DD/MM/YYYY') AS "DATA DE INSTALACAO DO ULTIMO HID",
    
    -- Primeira instalação de todos os registros
    TO_CHAR(MIN(h.hidi_dtinstalacaohidrometro), 'DD/MM/YYYY') AS "PRIMEIRA DATA DE INSTALACAO",
    
    -- Última retirada de todos os registros
    TO_CHAR(MAX(h.hidi_dtretiradahidrometro), 'DD/MM/YYYY') AS "ULTIMA DATA DE RETIRADA",
    
    -- Situação da ligação de água
    las.last_dsligacaoaguasituacao AS "SITUACAO AGUA"

FROM
    cadastro.imovel i

    -- Join com o histórico de hidrômetros
    INNER JOIN micromedicao.hidrometro_inst_hist h
        ON h.lagu_id = i.imov_id

    -- Obter apenas o último registro por matrícula
    INNER JOIN ultimo_registro ur 
        ON ur.lagu_id = i.imov_id 
        AND ur.rn = 1

    -- Join com localidade
    INNER JOIN cadastro.localidade l 
        ON i.loca_id = l.loca_id

    -- Join com município via localidade
    INNER JOIN cadastro.municipio mu
        ON l.muni_idprincipal = mu.muni_id

    -- Join com unidade de negócio
    INNER JOIN cadastro.unidade_negocio un 
        ON l.uneg_id = un.uneg_id

    -- Join para situação de água
    INNER JOIN atendimentopublico.ligacao_agua_situacao las 
        ON i.last_id = las.last_id

GROUP BY
    i.imov_id,
    i.imov_idcategoriaprincipal,
    mu.muni_nmmunicipio,
    l.loca_nmlocalidade,
    un.uneg_nmunidadenegocio,
    las.last_dsligacaoaguasituacao,
    ur.hidi_id,
    ur.hidi_dtinstalacaohidrometro,
    ur.hidi_dtretiradahidrometro

ORDER BY
    i.imov_id;
 
 
 	
-- =============================================================================
-- RELATÓRIO DE INSTALAÇÃO DE HIDRÔMETROS
-- =============================================================================
-- Identificar o último registro de cada matrícula (lagu_id)
WITH ultimo_registro AS (
    SELECT
        lagu_id,
        hidi_id,
        hidi_dtinstalacaohidrometro,
        hidi_dtretiradahidrometro,
        ROW_NUMBER() OVER (
            PARTITION BY lagu_id 
            ORDER BY hidi_dtinstalacaohidrometro DESC, hidi_id DESC
        ) AS rn
    FROM 
        micromedicao.hidrometro_inst_hist
    WHERE 
        lagu_id IS NOT NULL
)
-- Consulta principal
SELECT
    -- Identificação da matrícula
    i.imov_id AS MATRICULA,
    
    -- Categoria do imóvel
    CASE
        WHEN i.imov_idcategoriaprincipal = 1 THEN 'RESIDENCIAL'
        WHEN i.imov_idcategoriaprincipal = 2 THEN 'COMERCIAL'
        WHEN i.imov_idcategoriaprincipal = 3 THEN 'INDUSTRIAL'
        WHEN i.imov_idcategoriaprincipal = 4 THEN 'PUBLICO'
        ELSE 'Outra'
    END AS "CATEGORIA",
    
    -- Informações de localização
    mu.muni_nmmunicipio AS "MUNICIPIO",
    l.loca_nmlocalidade AS "NOME LOCALIDADE",
    un.uneg_nmunidadenegocio AS "NOME UNIDADE",
    
    -- Informações do último registro
    ur.hidi_id AS "ULTIMO ID HID",
    
    -- Hidrômetro instalado (último registro sem data de retirada)
    CASE
        WHEN ur.hidi_dtretiradahidrometro IS NULL THEN 'SIM'
        ELSE 'NAO'
    END AS "INSTALADO?",
    
    -- Data de instalação do último registro
    TO_CHAR(ur.hidi_dtinstalacaohidrometro, 'DD/MM/YYYY') AS "DATA DE INSTALACAO DO ULTIMO HID",
    
    -- Primeira instalação de todos os registros
    TO_CHAR(MIN(h.hidi_dtinstalacaohidrometro), 'DD/MM/YYYY') AS "PRIMEIRA DATA DE INSTALACAO",
    
    -- Última retirada de todos os registros
    TO_CHAR(MAX(h.hidi_dtretiradahidrometro), 'DD/MM/YYYY') AS "ULTIMA DATA DE RETIRADA",
    
    -- Situação da ligação de água
    las.last_dsligacaoaguasituacao AS "SITUACAO AGUA"

FROM
    cadastro.imovel i

    -- Join com o histórico de hidrômetros
    INNER JOIN micromedicao.hidrometro_inst_hist h
        ON h.lagu_id = i.imov_id

    -- Obter apenas o último registro por matrícula
    INNER JOIN ultimo_registro ur 
        ON ur.lagu_id = i.imov_id 
        AND ur.rn = 1

    -- Join com localidade
    INNER JOIN cadastro.localidade l 
        ON i.loca_id = l.loca_id

    -- Join com município via localidade
    INNER JOIN cadastro.municipio mu
        ON l.muni_idprincipal = mu.muni_id

    -- Join com unidade de negócio
    INNER JOIN cadastro.unidade_negocio un 
        ON l.uneg_id = un.uneg_id

    -- Join para situação de água
    INNER JOIN atendimentopublico.ligacao_agua_situacao las 
        ON i.last_id = las.last_id

GROUP BY
    i.imov_id,
    i.imov_idcategoriaprincipal,
    mu.muni_nmmunicipio,
    l.loca_nmlocalidade,
    un.uneg_nmunidadenegocio,
    las.last_dsligacaoaguasituacao,
    ur.hidi_id,
    ur.hidi_dtinstalacaohidrometro,
    ur.hidi_dtretiradahidrometro

ORDER BY
    i.imov_id;
