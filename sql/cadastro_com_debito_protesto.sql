WITH imoveis_com_conta_aberta_12m AS (
    SELECT DISTINCT
        con.imov_id
    FROM faturamento.conta con
    WHERE con.dcst_idatual IN (0,1,2)
      AND NOT EXISTS (
            SELECT 1
            FROM arrecadacao.pagamento pag
            WHERE pag.cnta_id = con.cnta_id
      )
      AND con.cnta_dtrevisao IS NULL
      AND con.cnta_dtvencimentoconta >= CURRENT_DATE - INTERVAL '1 year'
      AND con.cnta_dtvencimentoconta < CURRENT_DATE
      AND con.iper_id <> 6
      AND con.cnta_dtrevisao IS NULL
),

faturamento_final AS (
    SELECT 
        con.imov_id,
        COUNT(con.cnta_id) AS qtd_contas,
        MIN(con.cnta_amreferenciaconta) AS referencia_inicial,
        MAX(con.cnta_amreferenciaconta) AS referencia_final,
        SUM(con.cnta_vlagua) AS vl_agua,
        SUM(con.cnta_vlesgoto) AS vl_esgoto,
        SUM(con.cnta_vldebitos) AS vl_debitos,
        SUM(con.cnta_vlcreditos) AS vl_creditos,
        SUM(con.cnta_vlimpostos) AS vl_impostos,
        SUM(
            con.cnta_vlagua
            + con.cnta_vlesgoto
            + con.cnta_vldebitos
            - con.cnta_vlcreditos
            - con.cnta_vlimpostos
        ) AS valor,
        SUM(
            TRUNC(
                (
                    (
                        con.cnta_vlagua
                        + con.cnta_vlesgoto
                        + con.cnta_vldebitos
                        - con.cnta_vlcreditos
                        - con.cnta_vlimpostos
                    ) * 0.02
                )::NUMERIC,
                2
            )
        ) AS juros,
        SUM(
            TRUNC(
                (
                    (
                        con.cnta_vlagua
                        + con.cnta_vlesgoto
                        + con.cnta_vldebitos
                        - con.cnta_vlcreditos
                        - con.cnta_vlimpostos
                    ) * 0.005 * (
                        (
                            (EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM con.cnta_dtvencimentoconta)) * 12
                        ) + (
                            EXTRACT(MONTH FROM CURRENT_DATE) - EXTRACT(MONTH FROM con.cnta_dtvencimentoconta)
                        )
                    )
                )::NUMERIC,
                2
            )
        ) AS multas
    FROM faturamento.conta con
    INNER JOIN imoveis_com_conta_aberta_12m i12
        ON i12.imov_id = con.imov_id
    WHERE con.dcst_idatual IN (0,1,2)
      AND NOT EXISTS (
            SELECT 1
            FROM arrecadacao.pagamento pag
            WHERE pag.cnta_id = con.cnta_id
      )
      AND con.cnta_dtrevisao IS NULL
      AND con.cnta_dtvencimentoconta >= CURRENT_DATE - INTERVAL '10 years'
      AND con.cnta_dtvencimentoconta < CURRENT_DATE
      AND con.iper_id <> 6
      AND con.cnta_dtrevisao IS NULL      
    GROUP BY con.imov_id
),

ultima_fatura_atraso AS (
    SELECT
        x.imov_id,
        x.cnta_dtvencimentoconta AS data_vencimento_ultima_fatura_atraso,
        x.cnta_dtemissao AS data_emissao_ultima_fatura_atraso
    FROM (
        SELECT
            con.imov_id,
            con.cnta_id,
            con.cnta_dtvencimentoconta,
            con.cnta_dtemissao,
            ROW_NUMBER() OVER (
                PARTITION BY con.imov_id
                ORDER BY con.cnta_dtvencimentoconta DESC, con.cnta_id DESC
            ) AS rn
        FROM faturamento.conta con
        INNER JOIN imoveis_com_conta_aberta_12m i12
            ON i12.imov_id = con.imov_id
        WHERE con.dcst_idatual IN (0,1,2)
          AND NOT EXISTS (
                SELECT 1
                FROM arrecadacao.pagamento pag
                WHERE pag.cnta_id = con.cnta_id
          )
          AND con.cnta_dtrevisao IS NULL
          AND con.cnta_dtvencimentoconta >= CURRENT_DATE - INTERVAL '10 years'
          AND con.cnta_dtvencimentoconta < CURRENT_DATE
          AND con.iper_id <> 6
    ) x
    WHERE x.rn = 1
),

ra_mais_recente_1059 AS (
    SELECT
        x.imov_id,
        x.rgat_id AS numero_ra_mais_recente_1059
    FROM (
        SELECT
            ra.imov_id,
            ra.rgat_id,
            ROW_NUMBER() OVER (
                PARTITION BY ra.imov_id
                ORDER BY ra.rgat_id DESC
            ) AS rn
        FROM atendimentopublico.registro_atendimento ra
        WHERE ra.imov_id IS NOT NULL
          AND ra.step_id = 1059
    ) x
    WHERE x.rn = 1
),

ra_pendente_mais_recente AS (
    SELECT
        x.imov_id,
        x.rgat_id AS numero_ra_pendente_mais_recente
    FROM (
        SELECT
            ra.imov_id,
            ra.rgat_id,
            ROW_NUMBER() OVER (
                PARTITION BY ra.imov_id
                ORDER BY ra.rgat_id DESC
            ) AS rn
        FROM atendimentopublico.registro_atendimento ra
        WHERE ra.imov_id IS NOT NULL
          AND ra.step_id = 978
          AND ra.rgat_cdsituacao = 1
    ) x
    WHERE x.rn = 1
)

SELECT 
    imo.imov_id AS "MATRICULA",
    cli.clie_nmcliente AS "NOME CLIENTE",
    cli.clie_nncpf AS "CPF",
    cli.clie_nncnpj AS "CNPJ",
    (
        SELECT
            '(' || cfn.cfon_cdddd || ')' || cfn.cfon_nnfone
        FROM cadastro.cliente_fone cfn
        WHERE cfn.clie_id = cli.clie_id
          AND cfn.cfon_id = (
                SELECT MAX(cfn2.cfon_id)
                FROM cadastro.cliente_fone cfn2
                WHERE cfn2.clie_id = cli.clie_id
          )
        LIMIT 1
    ) AS "TELEFONE MAIS RECENTE TITULAR",
    CASE imo.imov_idcategoriaprincipal
        WHEN 1 THEN '1 - RESIDENCIAL'
        WHEN 2 THEN '2 - COMERCIAL'
        WHEN 3 THEN '3 - INDUSTRIAL'
        ELSE 'NAO DEFINIDO'
    END AS "CATEGORIA PRINCIPAL",
    lgt.lgtp_dslogradourotipo AS "TIPO LOGRADOURO",
    logr.logr_nmlogradouro AS "NOME LOGRADOURO",
    cep.cep_cdcep AS "CEP",
    imo.imov_dscomplementoendereco AS "COMPLEMENTO",
    bai.bair_nmbairro AS "BAIRRO",
    imo.imov_nnimovel AS "NR",
    mun.muni_nmmunicipio AS "MUNICIPIO",
    CAST(cst.cbsp_id AS TEXT) || ' - ' || cst.cbsp_dscobrancasituacaotipo AS "SIT. ESPECIAL DE COBRANCA",
    csh.cbsh_amcobrancasituacaoinicio AS "INICIO",
    csh.cbsh_amcobrancasituacaofim AS "FIM",
    csm.cbsm_dscobrancasituacaomotivo AS "MOTIVO",
    csh.cbsh_dsobservacaoinforma AS "OBS",
    ufa.data_vencimento_ultima_fatura_atraso AS "DATA VENCIMENTO ULTIMA FATURA EM ATRASO",
    ufa.data_emissao_ultima_fatura_atraso AS "DATA EMISSÃO ULTIMA FATURA EM ATRASO",
    rapr.numero_ra_mais_recente_1059 AS "RA PROTESTO",
    rap.numero_ra_pendente_mais_recente AS "RA RETIFICACAO PENDENTE",
    ff.referencia_inicial AS "REF INICIAL",
    ff.referencia_final AS "REF FINAL",
    TO_CHAR(ff.valor, '999G999G990D00') AS "VALOR DEBITO",
    TO_CHAR(ff.valor + ff.juros + ff.multas, '999G999G990D00') AS "VALOR DEBITO COM JUROS E MULTAS"
FROM cadastro.imovel imo
INNER JOIN imoveis_com_conta_aberta_12m i12
    ON i12.imov_id = imo.imov_id
INNER JOIN faturamento_final ff
    ON ff.imov_id = imo.imov_id
INNER JOIN cadastro.localidade loc
    ON imo.loca_id = loc.loca_id
INNER JOIN cadastro.unidade_negocio une
    ON une.uneg_id = loc.uneg_id
INNER JOIN cadastro.cliente_imovel cim
    ON cim.imov_id = imo.imov_id
   AND cim.clim_dtrelacaofim IS NULL
   AND cim.clim_icnomeconta = 1
INNER JOIN cadastro.cliente cli
    ON cli.clie_id = cim.clie_id
INNER JOIN cadastro.logradouro_bairro lgb
    ON lgb.lgbr_id = imo.lgbr_id
INNER JOIN cadastro.bairro bai
    ON bai.bair_id = lgb.bair_id
INNER JOIN cadastro.municipio mun
    ON mun.muni_id = bai.muni_id
LEFT JOIN cadastro.logradouro logr
    ON logr.logr_id = lgb.logr_id
LEFT JOIN cadastro.logradouro_tipo lgt
    ON lgt.lgtp_id = logr.lgtp_id
LEFT JOIN cadastro.logradouro_cep lgc 
    ON lgc.lgcp_id = imo.lgcp_id
LEFT JOIN cadastro.cep cep 
    ON cep.cep_id = lgc.cep_id
LEFT JOIN cadastro.imovel_cobranca_situacao ics
    ON ics.imov_id = imo.imov_id
   AND ics.iscb_dtretiradacobranca IS NULL
   AND ics.cbst_id IN (12,14,17)
LEFT JOIN cobranca.cobranca_situacao cob
    ON cob.cbst_id = ics.cbst_id
LEFT JOIN cadastro.imovel_cobranca_situacao ics_exi
    ON ics_exi.imov_id = imo.imov_id
   AND ics_exi.iscb_dtretiradacobranca IS NULL
   AND ics_exi.cbst_id = 23
LEFT JOIN cobranca.cobranca_situacao cob_exi
    ON cob_exi.cbst_id = ics_exi.cbst_id
LEFT JOIN cadastro.imovel_cobranca_situacao ics_ser
    ON ics_ser.imov_id = imo.imov_id
   AND ics_ser.iscb_dtretiradacobranca IS NULL
   AND ics_ser.cbst_id IN (24,25,26)
LEFT JOIN cobranca.cobranca_situacao cob_ser
    ON cob_ser.cbst_id = ics_ser.cbst_id
LEFT JOIN cobranca.cobranca_situacao_hist csh
    ON csh.imov_id = imo.imov_id
   AND csh.cbsh_amcobrancaretirada IS NULL
LEFT JOIN cobranca.cobranca_situacao_tipo cst
    ON csh.cbsp_id = cst.cbsp_id
LEFT JOIN cobranca.cobranca_situacao_motivo csm
    ON csm.cbsm_id = csh.cbsm_id
LEFT JOIN ultima_fatura_atraso ufa
    ON ufa.imov_id = imo.imov_id
LEFT JOIN ra_mais_recente_1059 rapr
    ON rapr.imov_id = imo.imov_id
LEFT JOIN ra_pendente_mais_recente rap
    ON rap.imov_id = imo.imov_id
WHERE imo.imov_icexclusao = 2
  AND imo.imov_idcategoriaprincipal <> 4
  AND une.uneg_id IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,20,21)
ORDER BY imo.imov_id