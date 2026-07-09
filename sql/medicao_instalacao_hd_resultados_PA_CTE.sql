-- =============================================================================
-- RELATÓRIO HISTÓRICO COMPLETO DE HIDRÔMETROS POR MATRÍCULA
-- =============================================================================
-- OBJETIVO: Listar todos os hidrômetros que já estiveram instalados em cada
--           matrícula, com suas respectivas datas de instalação/retirada,
--           situação atual e o serviço associado a cada período
-- =============================================================================
-- LÓGICA: Cada hidrômetro instalado gera uma linha. O serviço é vinculado
--         quando a data de encerramento da OS está dentro do período em que
--         o hidrômetro esteve ativo (entre instalação e retirada)
-- =============================================================================

-- =============================================================================
-- 1. CTE historico: Busca TODO o histórico de instalações de hidrômetros
-- =============================================================================
WITH historico AS (
    SELECT
        COALESCE(hidi.imov_id, hidi.lagu_id) AS matricula,  -- ID do imóvel ou ligação
        hidi.hidi_id,                                        -- ID do registro de instalação
        hidi.hidr_id,                                        -- ID do hidrômetro
        hidi.hidi_dtinstalacaohidrometro,                    -- Data da instalação
        hidi.hidi_dtretiradahidrometro                       -- Data da retirada (NULL se ativo)
    FROM micromedicao.hidrometro_inst_hist hidi
),

-- =============================================================================
-- 2. CTE base: Aplica filtros de negócio (imóveis ativos e unidades permitidas)
-- =============================================================================
base AS (
    SELECT
        h.matricula,
        h.hidi_id,
        h.hidr_id,
        h.hidi_dtinstalacaohidrometro,
        h.hidi_dtretiradahidrometro
    FROM historico h
    -- Apenas imóveis não excluídos (icexclusao = 2)
    JOIN cadastro.imovel im
        ON im.imov_id = h.matricula
       AND im.imov_icexclusao = 2
    -- Junta com localidade para filtrar unidades de negócio
    JOIN cadastro.localidade lo
        ON lo.loca_id = im.loca_id
    WHERE COALESCE(lo.uneg_id, 0) NOT IN (17, 18, 19)  -- Exclui unidades específicas
     -- AND lo.uneg_id = 5                               -- (Opcional) filtra por unidade
),

-- =============================================================================
-- 3. CTE servico: Classifica os tipos de serviço e mantém dados da OS
-- =============================================================================
servico AS (
    SELECT
        os.imov_id AS matricula,
        os.orse_id,                                    -- ID da ordem de serviço
        os.orse_tmencerramento,                        -- Data/hora de encerramento da OS
        st.svtp_dsservicotipo,                         -- Descrição do serviço
        -- Classifica o tipo de serviço baseado no svtp_id
        CASE
            -- INSTALAÇÃO: quando o hidrômetro é instalado pela primeira vez
            WHEN os.svtp_id IN (
                910,842,845,866,877,879,876,865,
                727,95,726,728,729,730,731,
                9123,918,725,916,857,891,
                887,884,886,885,888
            ) THEN 'INSTALACAO'
            -- SUBSTITUIÇÃO: quando o hidrômetro é trocado por outro
            WHEN os.svtp_id IN (
                843,846,870,873,880,872,871,
                9122,892,64,921,925,94,74,
                67,66,69,68,70,65,71,72,9150
            ) THEN 'SUBSTITUICAO'
            -- RETIRADA: quando o hidrômetro é removido sem reposição
            WHEN os.svtp_id IN (
                92,919,9130,9131,920
            ) THEN 'RETIRADA'
        END AS tipo_servico
    FROM atendimentopublico.ordem_servico os
    INNER JOIN atendimentopublico.servico_tipo st
        ON st.svtp_id = os.svtp_id
    -- Filtra apenas os tipos de serviço relevantes para hidrômetro
    WHERE os.svtp_id IN (
        910,842,845,866,877,879,876,865,
        727,95,726,728,729,730,731,
        9123,918,725,916,857,891,
        887,884,886,885,888,
        843,846,870,873,880,872,871,
        9122,892,64,921,925,94,74,
        67,66,69,68,70,65,71,72,9150,
        92,919,9130,9131,920
    )
)

-- =============================================================================
-- 4. SELECT PRINCIPAL: Monta o resultado final
-- =============================================================================
SELECT
    -- Dados da matrícula e hidrômetro
    b.matricula                                AS "matricula",
    b.hidi_dtinstalacaohidrometro              AS "data instalacao",
    b.hidi_dtretiradahidrometro                AS "ultima retirada hd",
    hd.hidr_nnhidrometro                       AS "numero hidrometro",
    
    -- Situações atuais do imóvel
    CAST(ft.ftst_id AS TEXT)
        || ' - ' || ft.ftst_dsfaturamentosituacaotipo
                                               AS "sit. faturamento",
    la.last_dsligacaoaguasituacao              AS "situacao agua",
    
    -- Dados do serviço vinculado ao período
    s.svtp_dsservicotipo                       AS "servico",
    s.tipo_servico                             AS "tipo servico"

FROM base b

-- =============================================================================
-- 5. JOINs: Tabelas de apoio e complementares
-- =============================================================================

-- Junta com hidrômetro para obter o número de série
JOIN micromedicao.hidrometro hd
    ON hd.hidr_id = b.hidr_id

-- Dados complementares do imóvel
LEFT JOIN cadastro.imovel im
    ON im.imov_id = b.matricula

-- Situação atual da ligação de água (LIGADO/DESLIGADO)
LEFT JOIN atendimentopublico.ligacao_agua_situacao la
    ON la.last_id = im.last_id

-- Situação atual de faturamento
LEFT JOIN faturamento.fatur_situacao_tipo ft
    ON ft.ftst_id = im.ftst_id

-- =============================================================================
-- 6. JOIN do SERVIÇO: Regra de vinculação temporal
-- =============================================================================
-- Um serviço pertence ao hidrômetro se a data de encerramento da OS estiver
-- DENTRO do período em que o hidrômetro esteve instalado.
--
-- REGRAS:
-- 1. A OS deve ser encerrada APÓS ou na data de instalação do hidrômetro
-- 2. Se o hidrômetro foi retirado, a OS deve ser encerrada ATÉ a data de retirada
-- 3. Se o hidrômetro ainda está instalado (retirada = NULL), considera-se ativo
-- =============================================================================
LEFT JOIN servico s
    ON s.matricula = b.matricula
   AND DATE(s.orse_tmencerramento) >= DATE(b.hidi_dtinstalacaohidrometro)  -- OS após instalação
   AND (b.hidi_dtretiradahidrometro IS NULL                                 -- Ainda instalado
        OR DATE(s.orse_tmencerramento) <= DATE(b.hidi_dtretiradahidrometro)) -- OS antes da retirada

-- =============================================================================
-- 7. FILTROS OPCIONAIS (descomente para usar)
-- =============================================================================
-- WHERE b.matricula = 2358832        -- Filtra uma matrícula específica

-- =============================================================================
-- 8. ORDENAÇÃO: Por data de instalação (mais antiga primeiro) e ID da OS
-- =============================================================================
ORDER BY b.hidi_dtinstalacaohidrometro, s.orse_id