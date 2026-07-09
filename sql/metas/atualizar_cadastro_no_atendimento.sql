-- =============================================================================
-- RELATÓRIO DE REGISTROS DE ATENDIMENTO
-- =============================================================================
SELECT
    -- Matrícula atendida
    ra.imov_id AS "MATRICULA ATENDIDA",

    -- Número do registro de atendimento
    ra.rgat_id AS "NR REGISTRO ATENDIMENTO",

    -- Nome da localidade
    l.loca_nmlocalidade AS "NOME LOCALIDADE",

    -- Município
    m.muni_nmmunicipio AS "MUNICIPIO",

    -- Nome da unidade
    un.uneg_nmunidadenegocio AS "NOME UNIDADE",

    -- Nome do serviço
    ste.step_dssolcttipoespec AS "NOME TIPO DE SERVICO",

    -- Categoria do imóvel
    CASE
        WHEN i.imov_idcategoriaprincipal = 1 THEN 'RESIDENCIAL'
        WHEN i.imov_idcategoriaprincipal = 2 THEN 'COMERCIAL'
        WHEN i.imov_idcategoriaprincipal = 3 THEN 'INDUSTRIAL'
        WHEN i.imov_idcategoriaprincipal = 4 THEN 'PUBLICO'
        ELSE 'OUTRA'
    END AS "CATEGORIA",

    -- Perfil do imóvel
    ipf.iper_dsimovelperfil AS "PERFIL",

    -- Data de atendimento
    TO_CHAR(ra.rgat_tmregistroatendimento, 'DD/MM/YYYY HH24:MI:SS') AS "DATA DE ATENDIMENTO",

    -- Data de encerramento
    TO_CHAR(ra.rgat_tmencerramento, 'DD/MM/YYYY HH24:MI:SS') AS "DATA DE ENCERRAMENTO",
    
    ra.rgat_dsobservacao AS "OBSERVACAO",
    ra.rgat_dsparecerencerramento AS "OBS ENCERRAMENTO",

    -- Quantidade de clientes ativos do imóvel
    (
        SELECT COUNT(DISTINCT clim2.clie_id)
        FROM cadastro.cliente_imovel clim2
        WHERE clim2.imov_id = ra.imov_id
          AND clim2.clim_dtrelacaofim IS NULL
    ) AS "QTD CLIENTES ATIVOS",

    -- Verificação de CPF/CNPJ dos clientes, ao menos um dos clientes vinculados com CPF/CNPJ cadastrado
    CASE
      WHEN NOT EXISTS (
        SELECT 1
        FROM cadastro.cliente_imovel clim
        JOIN cadastro.cliente c ON c.clie_id = clim.clie_id
        WHERE clim.imov_id = ra.imov_id
          AND clim.clim_dtrelacaofim IS NULL
          AND (c.clie_nncpf IS NOT NULL OR c.clie_nncnpj IS NOT NULL)
      ) THEN 'SEM CPF/CNPJ'
      ELSE 'OK'
    END AS "CPF OU CNPJ"

FROM
    atendimentopublico.registro_atendimento ra

    -- Join com imóvel para obter categoria e localidade
    INNER JOIN cadastro.imovel i
        ON ra.imov_id = i.imov_id

    -- Join com localidade para obter nome da localidade e uneg_id
    INNER JOIN cadastro.localidade l
        ON i.loca_id = l.loca_id

    -- Município
    LEFT JOIN cadastro.municipio m
        ON m.muni_id = l.muni_idprincipal

    -- Join com Perfil
    INNER JOIN cadastro.imovel_perfil ipf
        ON i.iper_id = ipf.iper_id

    -- Join com unidade de negócio
    INNER JOIN cadastro.unidade_negocio un
        ON l.uneg_id = un.uneg_id

    -- Join com solicitação tipo especificação (origem do nome do serviço)
    INNER JOIN atendimentopublico.solicitacao_tipo_espec ste
        ON ra.step_id = ste.step_id

WHERE
    i.iper_id <> 6                                          -- Expurgar Viva Água
    AND ra.meso_id = 1                                      -- Apenas Atendimento no Balcao (meso_id = 1)
    AND ra.rgat_tmregistroatendimento >= DATE '2026-01-01'  -- data de atendimento >= 01/01/2026
    AND ra.rgat_tmencerramento IS NOT NULL                  -- data de encerramento não nula, apenas atendimentos encerrados

    -- Expurgos solicitados:
    AND i.imov_icexclusao <> 1                              -- Expurgar imoveis excluidos
    AND l.uneg_id NOT IN (17, 18, 19)                       -- Expurgar unidades 17, 18 e 19 ENORSUL

    -- Expurga qualquer imovel que tenha o tipo MUDANCA DE TITULARIDADE (966) não encerrado
    AND NOT EXISTS (
        SELECT 1
        FROM atendimentopublico.registro_atendimento ra966
        WHERE ra966.imov_id = ra.imov_id
          AND ra966.step_id = 966
          AND ra966.rgat_tmencerramento IS NOT NULL
    )

ORDER BY
    ra.rgat_tmregistroatendimento DESC,
    ra.imov_id;