SELECT 
    loca.loca_id AS "LOCALIDADE",
    rfat.rfat_amreferencia AS "REFERENCIA",      
    rfat.rfat_dtcontabil AS "DATA FATURAMENTO", 
    TO_CHAR(SUM(rfat.rfat_vlitemfaturamento), '999G999G990D00') AS "VALOR FATURADO"  
FROM financeiro.resumo_faturamento rfat
    INNER JOIN financeiro.lancamento_tipo lctp ON rfat.lctp_id = lctp.lctp_id AND lctp.lctp_id = 25
    INNER JOIN financeiro.lancamento_item lcit ON rfat.lcit_id = lcit.lcit_id AND lcit.lcit_id = 18
    INNER JOIN cadastro.unidade_negocio uneg ON rfat.uneg_id = uneg.uneg_id
    INNER JOIN cadastro.gerencia_regional greg ON rfat.greg_id = greg.greg_id
    INNER JOIN cadastro.localidade loca ON rfat.loca_id = loca.loca_id
    INNER JOIN cadastro.categoria catg ON rfat.catg_id = catg.catg_id
    INNER JOIN cadastro.imovel_perfil iper ON rfat.iper_id = iper.iper_id
    INNER JOIN cadastro.municipio muni ON loca.muni_idprincipal = muni.muni_id
WHERE 
    rfat.rfat_dtcontabil >= '2025-01-01'
    AND rfat.rfat_dtcontabil < CURRENT_DATE
GROUP BY
    uneg.uneg_nmunidadenegocio,
    greg.greg_nmregional,
    loca.loca_id,
    muni.muni_nmmunicipio,
    catg.catg_dscategoria,
    iper.iper_dsimovelperfil,
    rfat.rfat_amreferencia,
    rfat.rfat_dtcontabil
 ORDER BY rfat.rfat_dtcontabil