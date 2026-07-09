-- Faturas até referência 202501 (conta e histórico)
WITH faturamento_final AS (
    SELECT 
        uniao.imov_id,
        uniao.cnta_id,
        uniao.referencia,        
        uniao.vencimento,
        uniao.valor
    FROM (
        -- União das tabelas faturamento.conta e faturamento.conta_historico
        SELECT 
            con.imov_id,
            con.cnta_id,
            con.cnta_amreferenciaconta AS referencia,
            con.cnta_dtvencimentoconta AS vencimento,
            con.cnta_vlagua + con.cnta_vlesgoto + con.cnta_vldebitos - con.cnta_vlcreditos - con.cnta_vlimpostos AS valor
        FROM faturamento.conta con
        WHERE con.dcst_idatual IN (0,1,2,5)
              AND con.iper_id = 6
              AND con.cnta_amreferenciaconta >= 202501
        UNION ALL
        SELECT 
            con.imov_id,
            con.cnta_id,        
            con.cnhi_amreferenciaconta AS referencia,
            con.cnhi_dtvencimentoconta AS vencimento,            
            con.cnhi_vlagua + con.cnhi_vlesgoto + con.cnhi_vldebitos - con.cnhi_vlcreditos - con.cnhi_vlimpostos AS valor
        FROM faturamento.conta_historico con
      WHERE con.dcst_idatual IN (0,1,2,5)
              AND con.iper_id = 6
              AND con.cnhi_amreferenciaconta >= 202501        
        ) AS uniao
 )

SELECT 
    imo.imov_id AS "MATRICULA",
    fr.cnta_id AS "CODIGO CONTA",
    loc.loca_id AS "LOCALIDADE",
    fr.referencia AS "REFERENCIA",
    fr.vencimento AS "VENCIMENTO FATURA",     
    TO_CHAR(fr.valor, '999G999G990D00') AS "VALOR FATURAS"

FROM cadastro.imovel imo
JOIN faturamento_final fr ON imo.imov_id = fr.imov_id
-- Cliente titular
JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id 
  AND cim.clim_dtrelacaofim IS NULL 
  AND cim.clim_icnomeconta = 1
JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
-- Localização e unidade
JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id AND loc.greg_id IN (1, 2)
JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
-- Endereço e município
JOIN cadastro.logradouro_bairro lgb ON lgb.lgbr_id = imo.lgbr_id
JOIN cadastro.bairro bai ON bai.bair_id = lgb.bair_id
JOIN cadastro.municipio mun ON mun.muni_id = bai.muni_id
-- Situação de ligação
JOIN atendimentopublico.ligacao_agua_situacao las ON las.last_id = imo.last_id
JOIN atendimentopublico.ligacao_esgoto_situacao les ON les.lest_id = imo.lest_id

WHERE imo.imov_icexclusao = 2
  AND fr.valor > 0
--  AND imo.imov_id = 78

ORDER BY imo.imov_id;
