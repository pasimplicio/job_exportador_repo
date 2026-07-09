-- QUERY COMPLETA OTIMIZADA PARA EXECUÇÃO

WITH meio_solicitacao AS (
  SELECT DISTINCT ON (ra.imov_id)
    ra.imov_id,
    mes.meso_dsmeiosolicitacao
  FROM atendimentopublico.meio_solicitacao mes
  INNER JOIN atendimentopublico.registro_atendimento ra ON ra.meso_id = mes.meso_id
  INNER JOIN atendimentopublico.atend_motivo_encmt ate ON ate.amen_id = ra.amen_id
  WHERE ra.step_id IN (1062, 977)
    AND ra.rgat_tmregistroatendimento >= CURRENT_DATE - INTERVAL '7 days'
    AND ate.amen_icexecucao = 1
  ORDER BY ra.imov_id, ra.rgat_tmregistroatendimento DESC
),
contas_atraso AS (
  SELECT
    con4.imov_id AS mat1,
    MIN(con4.cnta_amreferenciaconta) AS min,
    MAX(con4.cnta_amreferenciaconta) AS max,
    COUNT(con4.cnta_id) AS qtd,
    SUM(con4.cnta_vlagua + con4.cnta_vlesgoto + con4.cnta_vldebitos - con4.cnta_vlcreditos - con4.cnta_vlimpostos) AS valor
  FROM faturamento.conta con4
  WHERE con4.dcst_idatual IN (0, 1, 2, 5)
    AND NOT EXISTS (
      SELECT 1 FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con4.cnta_id
    )
    AND con4.cnta_dtvencimentoconta BETWEEN '2025-11-01' AND CURRENT_DATE
    AND con4.cnta_dtrevisao IS NULL
    AND con4.iper_id <> 6
  GROUP BY con4.imov_id
),
contas_pagas AS (
  SELECT
    con4.imov_id AS mat1,
    MIN(con4.cnta_amreferenciaconta) AS min,
    MAX(con4.cnta_amreferenciaconta) AS max,
    COUNT(con4.cnta_id) AS qtd,
    SUM(con4.cnta_vlagua + con4.cnta_vlesgoto + con4.cnta_vldebitos - con4.cnta_vlcreditos - con4.cnta_vlimpostos) AS valor
  FROM faturamento.conta con4
  WHERE con4.dcst_idatual IN (0, 1, 2, 5)
    AND EXISTS (
      SELECT 1 FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con4.cnta_id
    )
    AND con4.cnta_dtvencimentoconta BETWEEN '2025-11-01' AND '2025-12-31'
    AND con4.cnta_dtrevisao IS NULL
    AND con4.iper_id <> 6
  GROUP BY con4.imov_id
),
valor_pago_parcelas AS (
  SELECT parc_id, qtd, SUM(valor_pago) AS valor_pago
  FROM (
    SELECT
      dch.parc_id,
      COUNT(DISTINCT dco.cnta_id) AS qtd,
      SUM(dco.dbcb_vlprestacao) AS valor_pago
    FROM faturamento.conta con
    INNER JOIN faturamento.debito_cobrado dco ON dco.cnta_id = con.cnta_id
    INNER JOIN faturamento.debito_a_cobrar_geral dcg ON dcg.dbac_id = dco.dbac_id
    INNER JOIN faturamento.debito_a_cobrar dch ON dch.dbac_id = dcg.dbac_id
    INNER JOIN arrecadacao.pagamento pgh ON pgh.cnta_id = con.cnta_id AND pgh.pgst_idatual IN (0, 1, 2, 5)
    INNER JOIN cobranca.parcelamento par ON par.parc_id = dch.parc_id
    WHERE par.parc_tmparcelamento >= '2025-11-01'
    GROUP BY dch.parc_id
  ) tmp
  GROUP BY parc_id, qtd
),
pago_inex AS (
  SELECT pagmat, SUM(valor_pago_inex) AS valor_pago_inex
  FROM (
    SELECT
      pag.imov_id AS pagmat,
      SUM(pag.pgmt_vlpagamento) AS valor_pago_inex
    FROM arrecadacao.pagamento pag
    LEFT JOIN faturamento.debito_tipo dbt ON dbt.dbtp_id = pag.dbtp_id
    WHERE pag.pgst_idatual = 2
      AND pag.pgmt_dtpagamento >= '2025-11-01'
      AND pag.dbtp_id IN (33, 9156)
    GROUP BY pag.imov_id
  ) tmp
  GROUP BY pagmat
)

-- A partir daqui insira os blocos SELECT correspondentes
-- UNION de PARCELAMENTO
-- Bloco: UNION de PARCELAMENTO
SELECT
    'PARCELAMENTO' AS modalidade,
    ms.meso_dsmeiosolicitacao AS meio_solicitacao,
    par.imov_id AS matricula,
    TO_CHAR(imo.imov_nncoordenadax, '990D999999999999999') AS latitude,
    TO_CHAR(imo.imov_nncoordenaday, '990D999999999999999') AS longitude,
    cat.catg_dscategoria AS categoria,
    CASE imo.iper_id 
        WHEN 1 THEN 'GRANDE'
        WHEN 2 THEN 'GRANDE DO MES'
        WHEN 3 THEN 'ESPECIAL'
        WHEN 4 THEN 'MUNICIPAL'
        WHEN 5 THEN 'NORMAL'
        WHEN 6 THEN 'VIVA AGUA'
        WHEN 7 THEN 'CONTRATOS PREFEIT.'
        WHEN 8 THEN 'COND RES VERTICAIS'
        WHEN 9 THEN 'ENT. FILANTROPICAS'
        WHEN 10 THEN 'LAVA JATO'
        ELSE 'NAO DEFINIDO'
    END AS nome_perfil,
    loc.uneg_id AS gerencia,
    une.uneg_nmunidadenegocio AS nome_unidade,
    imo.loca_id AS localidade,
    loc.loca_nmlocalidade AS nome_localidade,
    usu.usur_nmlogin AS login,
    usu.usur_nmusuario AS nome_usuario,
    uno.unid_dsunidade AS unidade_org,
    TO_CHAR(par.parc_tmparcelamento,'dd/MM/YYYY') AS data_opcao,
    TO_CHAR(par.parc_tmparcelamento,'hh24:mi') AS hora_opcao,
    TO_CHAR(par.parc_tmparcelamento,'hh24') AS hora_dia_opcao,
    TO_CHAR(par.parc_vldebitoatualizado,'999999999999990D00') AS valor_debito,
    TO_CHAR(par.parc_vlentrada,'999999999999990D00') AS valor_entrada,
    TO_CHAR(COALESCE(gpg_entrada.gpag_dtvencimento, gph_entrada_historico.gphi_dtvencimento),'dd/MM/YYYY') AS vencimento_entrada,
    TO_CHAR(COALESCE(pag_entrada.pgmt_dtpagamento, pag_entrada_historico.pghi_dtpagamento),'dd/MM/YYYY') AS data_pagamento_entrada,
    TO_CHAR(COALESCE(pag_entrada.pgmt_vlpagamento, pag_entrada_historico.pghi_vlpagamento, 0),'999999999999990D00') AS valor_pago_entrada,
    par.parc_nnprestacoes AS parcelas,
    TO_CHAR(par.parc_vlprestacao,'999999999999990D00') AS valor_parcela,
    TO_CHAR(par.parc_vlprestacao * par.parc_nnprestacoes,'999999999999990D00') AS vl_financiado_total,
    TO_CHAR((par.parc_vldebitoatualizado - ((par.parc_vlprestacao * par.parc_nnprestacoes) + par.parc_vlentrada)),'999999999999990D00') AS desconto_concedido_total,
    TO_CHAR(par.parc_vlentrada + (par.parc_vlprestacao * par.parc_nnprestacoes),'999999999999990D00') AS valor_final,
    '' AS vencimento_a_vista,
    '' AS data_pagamento_a_vista,
    TO_CHAR(0,'999999999999990D00') AS valor_pago_a_vista,
    cs.situacao AS sit_cobranca,
    TO_CHAR(COALESCE((par.parc_vljurosmora + par.parc_vlmulta),0),'999999999999990D00') AS valor_juros_multas,
    cli.clie_id AS id_cliente_titular,
    cli.clie_nmcliente AS nome_cliente_titular,
    CASE
        WHEN cli.clie_nncpf IS NOT NULL THEN
            CONCAT(SUBSTRING(cli.clie_nncpf,1,3),'.',SUBSTRING(cli.clie_nncpf,4,3),'.',SUBSTRING(cli.clie_nncpf,7,3),'-',SUBSTRING(cli.clie_nncpf,10,2))
        WHEN cli.clie_nncnpj IS NOT NULL THEN
            CONCAT(SUBSTRING(cli.clie_nncnpj,1,2),'.',SUBSTRING(cli.clie_nncnpj,3,3),'.',SUBSTRING(cli.clie_nncnpj,6,3),'/',SUBSTRING(cli.clie_nncnpj,9,4),'-',SUBSTRING(cli.clie_nncnpj,13,2))
        ELSE ''
    END AS documento_cliente_titular,
    cli_par.clie_id AS id_cliente_responsavel,
    cli_par.clie_nmcliente AS nome_cliente_responsavel,
    TO_CHAR(COALESCE(vpp.valor_pago,0),'999G999G990D00') AS valor_pago_parcelas,
    vpp.qtd AS qtd_parcelas_pagas,
    TO_CHAR(ca.valor,'999999999999990D00') AS valor_atraso,
    ca.qtd AS qtd_contas_atraso,
    ca.min AS menor_ref_atraso,
    ca.max AS maior_ref_atraso,
    TO_CHAR(pi.valor_pago_inex,'999999999999990D00') AS valor_inex_entrada,
    TO_CHAR(cp.valor,'999999999999990D00') AS faturas_pagas
FROM
    cobranca.parcelamento par
    INNER JOIN cadastro.imovel imo ON imo.imov_id = par.imov_id
    LEFT JOIN meio_solicitacao ms ON ms.imov_id = imo.imov_id
    LEFT JOIN contas_atraso ca ON ca.mat1 = imo.imov_id
    LEFT JOIN contas_pagas cp ON cp.mat1 = imo.imov_id
    LEFT JOIN valor_pago_parcelas vpp ON vpp.parc_id = par.parc_id
    LEFT JOIN pago_inex pi ON pi.pagmat = imo.imov_id
    LEFT JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
    LEFT JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
    LEFT JOIN cadastro.categoria cat ON cat.catg_id = imo.imov_idcategoriaprincipal
    LEFT JOIN seguranca.usuario usu ON usu.usur_id = par.usur_id
    LEFT JOIN cadastro.unidade_organizacional uno ON uno.unid_id = usu.unid_id
    LEFT JOIN faturamento.guia_pagamento gpg_entrada ON gpg_entrada.parc_id = par.parc_id AND gpg_entrada.dbtp_id = 33 AND gpg_entrada.dcst_idatual IN (0,1,2)
    LEFT JOIN arrecadacao.pagamento pag_entrada ON pag_entrada.gpag_id = gpg_entrada.gpag_id
    LEFT JOIN faturamento.guia_pagamento_historico gph_entrada_historico ON gph_entrada_historico.parc_id = par.parc_id AND gph_entrada_historico.dbtp_id = 33 AND gph_entrada_historico.dcst_idatual IN (0,1,2)
    LEFT JOIN arrecadacao.pagamento_historico pag_entrada_historico ON pag_entrada_historico.gpag_id = gph_entrada_historico.gpag_id
    LEFT JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
    LEFT JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
    LEFT JOIN cadastro.cliente cli_par ON par.clie_id = cli_par.clie_id
    LEFT JOIN (
        SELECT
            ics.imov_id,
            STRING_AGG(cbs.cbst_dscobrancasituacao || '- ' ||TO_CHAR(ics.iscb_dtimplantacaocobranca,'dd/MM/YYYY'),';') AS situacao
        FROM
            cadastro.imovel_cobranca_situacao ics
            INNER JOIN cobranca.cobranca_situacao cbs ON cbs.cbst_id = ics.cbst_id
        WHERE
            ics.iscb_dtretiradacobranca IS NULL
            AND cbs.cbst_id IN (12,14,17,24,25,26)
        GROUP BY ics.imov_id
    ) cs ON cs.imov_id = imo.imov_id
WHERE
    par.parc_tmparcelamento >= '2025-11-01'
    AND par.rdir_id = 51
    AND par.pcst_id = 1

UNION
-- UNION de À VISTA PAGA

-- Bloco: UNION de À VISTA PAGA
SELECT
    'A VISTA' AS modalidade,
    COALESCE(ms.meso_dsmeiosolicitacao, 'BALCAO') AS meio_solicitacao,
    cdb.imov_id AS matricula,
    TO_CHAR(imo.imov_nncoordenadax, '990D999999999999999') AS latitude,
    TO_CHAR(imo.imov_nncoordenaday, '990D999999999999999') AS longitude,
    cat.catg_dscategoria AS categoria,
    CASE imo.iper_id 
        WHEN 1 THEN 'GRANDE'
        WHEN 2 THEN 'GRANDE DO MES'
        WHEN 3 THEN 'ESPECIAL'
        WHEN 4 THEN 'MUNICIPAL'
        WHEN 5 THEN 'NORMAL'
        WHEN 6 THEN 'VIVA AGUA'
        WHEN 7 THEN 'CONTRATOS PREFEIT.'
        WHEN 8 THEN 'COND RES VERTICAIS'
        WHEN 9 THEN 'ENT. FILANTROPICAS'
        WHEN 10 THEN 'LAVA JATO'
        ELSE 'NAO DEFINIDO'
    END AS nome_perfil,
    loc.uneg_id AS gerencia,
    une.uneg_nmunidadenegocio AS nome_unidade,
    imo.loca_id AS localidade,
    loc.loca_nmlocalidade AS nome_localidade,
    usu.usur_nmlogin AS login,
    usu.usur_nmusuario AS nome_usuario,
    uno.unid_dsunidade AS unidade_org,
    TO_CHAR(cdb.cbdo_tmemissao,'dd/MM/YYYY') AS data_opcao,
    TO_CHAR(cdb.cbdo_tmemissao,'hh24:mi') AS horario_opcao,
    TO_CHAR(cdb.cbdo_tmemissao,'hh24') AS hora_dia_opcao,
    TO_CHAR((cdb.cbdo_vldocumento+cdb.cbdo_vldesconto),'999999999999990D00') AS valor_debito,
    TO_CHAR(0,'999999999999990D00') AS valor_entrada,
    '' AS vencimento_entrada,
    '' AS data_pagamento_entrada,
    TO_CHAR(0,'999999999999990D00') AS valor_pago_entrada,
    0 AS parcelas,
    TO_CHAR(0,'999999999999990D00') AS valor_parcela,
    TO_CHAR(0,'999999999999990D00') AS vl_financiado_total,
    TO_CHAR(cdb.cbdo_vldesconto,'999999999999990D00') AS desconto_concedido_total,
    TO_CHAR(cdb.cbdo_vldocumento,'999999999999990D00') AS valor_final,
    TO_CHAR(cdb.cbdo_dtvalidade,'dd/MM/YYYY') AS vencimento_a_vista,
    TO_CHAR(COALESCE(pag.pgmt_dtpagamento, pgh.pghi_dtpagamento),'dd/MM/YYYY') AS data_pagamento_a_vista,
    TO_CHAR(cdb.cbdo_vldocumento,'999999999999990D00') AS valor_pago_a_vista,
    COALESCE((
        SELECT STRING_AGG(cbs.cbst_dscobrancasituacao || '- ' || TO_CHAR(ics.iscb_dtimplantacaocobranca,'dd/MM/YYYY'),';')
        FROM cadastro.imovel_cobranca_situacao ics
        INNER JOIN cobranca.cobranca_situacao cbs ON cbs.cbst_id = ics.cbst_id
        WHERE ics.iscb_dtretiradacobranca IS NULL
          AND cbs.cbst_id IN (12,14,17,24,25,26)
          AND ics.imov_id = imo.imov_id
    ),'') AS sit_cobranca,
    TO_CHAR(COALESCE(cdb.cbdo_vlacrescimos,0),'999999999999990D00') AS valor_juros_multas,
    cli.clie_id AS id_cliente_titular_imovel,
    cli.clie_nmcliente AS nome_cliente_titular,
    CASE
        WHEN cli.clie_nncpf IS NOT NULL THEN
            CONCAT(SUBSTRING(cli.clie_nncpf,1,3),'.',SUBSTRING(cli.clie_nncpf,4,3),'.',SUBSTRING(cli.clie_nncpf,7,3),'-',SUBSTRING(cli.clie_nncpf,10,2))
        WHEN cli.clie_nncnpj IS NOT NULL THEN
            CONCAT(SUBSTRING(cli.clie_nncnpj, 1, 2),'.',SUBSTRING(cli.clie_nncnpj,3,3),'.',SUBSTRING(cli.clie_nncnpj,6,3),'/',SUBSTRING(cli.clie_nncnpj,9,4),'-',SUBSTRING(cli.clie_nncnpj, 13, 2))
        ELSE ''
    END AS documento_cliente_titular,
    cli.clie_id AS id_cliente_responsavel_parcelamento,
    cli.clie_nmcliente AS nome_cliente_responsavel,
    TO_CHAR(0,'999G999G990D00') AS valor_pago_parcelas,
    0 AS qtd_parcelas_pagas,
    TO_CHAR(con_atraso.valor,'999999999999990D00') AS valor_atraso,
    con_atraso.qtd AS qtd_contas_atraso,
    con_atraso.min AS menor_ref_atraso,
    con_atraso.max AS maior_ref_atraso,
    TO_CHAR(0,'999999999999990D00') AS valor_inex_entrada,
    TO_CHAR(con_fat_pg.valor,'999999999999990D00') AS faturas_pagas
FROM
    cobranca.cobranca_documento cdb
    INNER JOIN cadastro.imovel imo ON cdb.imov_id = imo.imov_id
    INNER JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
    INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
    LEFT JOIN cadastro.categoria cat ON cat.catg_id = imo.imov_idcategoriaprincipal
    LEFT JOIN seguranca.usuario usu ON usu.usur_id = cdb.usur_id
    LEFT JOIN cadastro.unidade_organizacional uno ON uno.unid_id = usu.unid_id
    LEFT JOIN arrecadacao.pagamento pag ON pag.cbdo_id = cdb.cbdo_id
    LEFT JOIN arrecadacao.pagamento_historico pgh ON pgh.cbdo_id = cdb.cbdo_id
    LEFT JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
    LEFT JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
    LEFT JOIN meio_solicitacao ms ON ms.imov_id = imo.imov_id
    LEFT JOIN contas_atraso con_atraso ON con_atraso.mat1 = imo.imov_id
    LEFT JOIN contas_pagas con_fat_pg ON con_fat_pg.mat1 = imo.imov_id
WHERE
    cdb.rdir_id = 51
    AND cdb.cbdo_tmemissao > '2025-11-01'
    AND COALESCE(pag.pgmt_vlpagamento, pgh.pghi_vlpagamento) > 0

-- UNION de À VISTA NÃO PAGA
UNION
-- Bloco: UNION de À VISTA NÃO PAGA
SELECT
    'A VISTA' AS modalidade,
    COALESCE(ms.meso_dsmeiosolicitacao, 'BALCAO') AS meio_solicitacao,
    cdb.imov_id AS matricula,
    TO_CHAR(imo.imov_nncoordenadax, '990D999999999999999') AS latitude,
    TO_CHAR(imo.imov_nncoordenaday, '990D999999999999999') AS longitude,
    cat.catg_dscategoria AS categoria,
    CASE imo.iper_id
        WHEN 1 THEN 'GRANDE'
        WHEN 2 THEN 'GRANDE DO MES'
        WHEN 3 THEN 'ESPECIAL'
        WHEN 4 THEN 'MUNICIPAL'
        WHEN 5 THEN 'NORMAL'
        WHEN 6 THEN 'VIVA AGUA'
        WHEN 7 THEN 'CONTRATOS PREFEIT.'
        WHEN 8 THEN 'COND RES VERTICAIS'
        WHEN 9 THEN 'ENT. FILANTROPICAS'
        WHEN 10 THEN 'LAVA JATO'
        ELSE 'NAO DEFINIDO'
    END AS nome_perfil,
    loc.uneg_id AS gerencia,
    une.uneg_nmunidadenegocio AS nome_unidade,
    imo.loca_id AS localidade,
    loc.loca_nmlocalidade AS nome_localidade,
    usu.usur_nmlogin AS login,
    usu.usur_nmusuario AS nome_usuario,
    uno.unid_dsunidade AS unidade_org,
    TO_CHAR(cdb.cbdo_tmemissao, 'dd/MM/YYYY') AS data_opcao,
    TO_CHAR(cdb.cbdo_tmemissao, 'hh24:mi') AS horario_opcao,
    TO_CHAR(cdb.cbdo_tmemissao, 'hh24') AS hora_dia_opcao,
    TO_CHAR((cdb.cbdo_vldocumento + cdb.cbdo_vldesconto), '999999999999990D00') AS valor_debito,
    TO_CHAR(0, '999999999999990D00') AS valor_entrada,
    '' AS vencimento_entrada,
    '' AS data_pagamento_entrada,
    TO_CHAR(0, '999999999999990D00') AS valor_pago_entrada,
    0 AS parcelas,
    TO_CHAR(0, '999999999999990D00') AS valor_parcela,
    TO_CHAR(0, '999999999999990D00') AS vl_financiado_total,
    TO_CHAR(cdb.cbdo_vldesconto, '999999999999990D00') AS desconto_concedido_total,
    TO_CHAR(cdb.cbdo_vldocumento, '999999999999990D00') AS valor_final,
    TO_CHAR(cdb.cbdo_dtvalidade, 'dd/MM/YYYY') AS vencimento_a_vista,
    '' AS data_pagamento_a_vista,
    TO_CHAR(0, '999999999999990D00') AS valor_pago_a_vista,
    '' AS sit_cobranca,
    TO_CHAR(COALESCE(cdb.cbdo_vlacrescimos, 0), '999999999999990D00') AS valor_juros_multas,
    cli.clie_id AS id_cliente_titular,
    cli.clie_nmcliente AS nome_cliente_titular,
    CASE
        WHEN cli.clie_nncpf IS NOT NULL THEN
            CONCAT(SUBSTRING(cli.clie_nncpf, 1, 3), '.', SUBSTRING(cli.clie_nncpf, 4, 3), '.', SUBSTRING(cli.clie_nncpf, 7, 3), '-', SUBSTRING(cli.clie_nncpf, 10, 2))
        WHEN cli.clie_nncnpj IS NOT NULL THEN
            CONCAT(SUBSTRING(cli.clie_nncnpj, 1, 2), '.', SUBSTRING(cli.clie_nncnpj, 3, 3), '.', SUBSTRING(cli.clie_nncnpj, 6, 3), '/', SUBSTRING(cli.clie_nncnpj, 9, 4), '-', SUBSTRING(cli.clie_nncnpj, 13, 2))
        ELSE ''
    END AS documento_cliente_titular,
    cli.clie_id AS id_cliente_responsavel,
    cli.clie_nmcliente AS nome_cliente_responsavel,
    TO_CHAR(0, '999G999G990D00') AS valor_pago_parcelas,
    0 AS qtd_parcelas_pagas,
    TO_CHAR(0, '999999999999990D00') AS valor_atraso,
    0 AS qtd_contas_atraso,
    0 AS menor_ref_atraso,
    0 AS maior_ref_atraso,
    TO_CHAR(0, '999999999999990D00') AS valor_inex_entrada,
    TO_CHAR(0, '999999999999990D00') AS faturas_pagas
FROM
    cobranca.cobranca_documento cdb
    INNER JOIN cadastro.imovel imo ON cdb.imov_id = imo.imov_id
    INNER JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
    INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
    LEFT JOIN cadastro.categoria cat ON cat.catg_id = imo.imov_idcategoriaprincipal
    LEFT JOIN seguranca.usuario usu ON usu.usur_id = cdb.usur_id
    LEFT JOIN cadastro.unidade_organizacional uno ON uno.unid_id = usu.unid_id
    LEFT JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
    LEFT JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
    LEFT JOIN meio_solicitacao ms ON ms.imov_id = imo.imov_id
    LEFT JOIN contas_atraso con_atraso ON con_atraso.mat1 = imo.imov_id
    LEFT JOIN contas_pagas con_fat_pg ON con_fat_pg.mat1 = imo.imov_id
WHERE
    cdb.rdir_id = 51
    AND cdb.cbdo_tmemissao > '2025-11-01'
    AND NOT EXISTS (
        SELECT 1
        FROM cobranca.cobranca_documento cdb_pago
        LEFT JOIN arrecadacao.pagamento pag ON pag.cbdo_id = cdb_pago.cbdo_id
        LEFT JOIN arrecadacao.pagamento_historico pgh ON pgh.cbdo_id = cdb_pago.cbdo_id
        WHERE COALESCE(pag.pgmt_vlpagamento, pgh.pghi_vlpagamento, 0) > 0
          AND cdb_pago.imov_id = cdb.imov_id
          AND cdb_pago.rdir_id = cdb.rdir_id
          AND TO_CHAR(cdb_pago.cbdo_tmemissao, 'dd/MM/YYYY') = TO_CHAR(cdb.cbdo_tmemissao, 'dd/MM/YYYY')
    )
    AND cdb.cbdo_id = (
        SELECT MAX(cdb2.cbdo_id)
        FROM cobranca.cobranca_documento cdb2
        LEFT JOIN arrecadacao.pagamento pag ON pag.cbdo_id = cdb2.cbdo_id
        LEFT JOIN arrecadacao.pagamento_historico pgh ON pgh.cbdo_id = cdb2.cbdo_id
        WHERE cdb2.imov_id = cdb.imov_id
          AND COALESCE(pag.pgmt_vlpagamento, pgh.pghi_vlpagamento, 0) = 0
          AND cdb2.rdir_id = cdb.rdir_id
          AND TO_CHAR(cdb2.cbdo_tmemissao, 'dd/MM/YYYY') = TO_CHAR(cdb.cbdo_tmemissao, 'dd/MM/YYYY')
    )
    AND NOT EXISTS (
        SELECT 1
        FROM cobranca.parcelamento par
        WHERE par.imov_id = cdb.imov_id
          AND par.rdir_id = 51
          AND par.pcst_id = 1
    )
