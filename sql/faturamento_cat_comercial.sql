WITH contas_ativas AS (
    SELECT
        cnta.imov_id,
        cnta.cnta_id AS idconta,      
        cnta.cnta_amreferenciaconta AS referencia,
        cnta.cnta_dtvencimentoconta AS vencimento,
        cnta.cnta_nnconsumoagua AS cagua,
	cnta.cnta_nnconsumoesgoto AS cesg,         
	cnta.cnta_vlagua AS vl_agua,
	cnta.cnta_vlesgoto AS vl_esgoto,
	cnta.cnta_vldebitos AS vl_debitos,
	cnta.cnta_vlcreditos AS vl_creditos,
	cnta.cnta_vlimpostos AS vl_impostos,        
        (cnta.cnta_vlagua + cnta.cnta_vlesgoto + cnta.cnta_vldebitos
         - cnta.cnta_vlcreditos - cnta.cnta_vlimpostos) AS valor
    FROM faturamento.conta cnta
    WHERE cnta.cnta_amreferenciaconta = '${VAR_REFERENCIA}'
      AND cnta.dcst_idatual IN (0,1,2)
),

contas_historicas AS (
    SELECT
        cnhi.imov_id,
        cnhi.cnta_id AS idconta,
        cnhi.cnhi_amreferenciaconta AS referencia,
        cnhi.cnhi_dtvencimentoconta AS vencimento,
	cnhi.cnhi_nnconsumoagua AS cagua,
	cnhi.cnhi_nnconsumoesgoto AS cesg,	
	cnhi.cnhi_vlagua AS vl_agua,
	cnhi.cnhi_vlesgoto AS vl_esgoto,
	cnhi.cnhi_vldebitos AS vl_debitos,
	cnhi.cnhi_vlcreditos AS vl_creditos,
	cnhi.cnhi_vlimpostos AS vl_impostos,                
        (cnhi.cnhi_vlagua + cnhi.cnhi_vlesgoto + cnhi.cnhi_vldebitos
         - cnhi.cnhi_vlcreditos - cnhi.cnhi_vlimpostos) AS valor
    FROM faturamento.conta_historico cnhi
    WHERE cnhi.cnhi_amreferenciaconta = '${VAR_REFERENCIA}'
      AND cnhi.dcst_idatual IN (0,1,2)
),

contas_consolidadas AS (
    SELECT * FROM contas_ativas
    UNION ALL
    SELECT * FROM contas_historicas
)

SELECT 
    imo.imov_id AS "MATRICULA",
    TO_CHAR(imo.imov_nncoordenadax,'990D999999999999999') AS "LATITUDE",
    TO_CHAR(imo.imov_nncoordenaday,'990D999999999999999') AS "LONGITUDE",
    cli.clie_nmcliente AS "NOME CLIENTE",
    cli.clie_nncpf AS "CPF",
    cli.clie_nncnpj AS "CNPJ",
    cli2.clie_id AS "COD RESP",
    cli2.clie_nmcliente AS "NOME RESP",
    cli2.clie_nncpf AS "CPF RESP",
    cli2.clie_nncnpj AS "CNPJ RESP",    
    cli3.clie_id AS "COD PAI",
    cli3.clie_nmcliente AS "NOME PAI",
    cli.clie_nncpf AS "CPF PAI",
    cli.clie_nncnpj AS "CNPJ PAI",
    CASE imo.imov_idcategoriaprincipal 
        WHEN 1 THEN 'RESIDENCIAL'
        WHEN 2 THEN 'COMERCIAL'
        WHEN 3 THEN 'INDUSTRIAL'
        WHEN 4 THEN 'PUBLICO'
        ELSE 'NAO DEFINIDO'
    END AS "CATEGORIA PRINCIPAL",
    (CASE imo.imov_idsubcategoriaprincipal 
	WHEN 1 THEN 'RESIDENCIAL'
	WHEN 2 THEN 'COMERCIAL'
	WHEN 3 THEN 'INDUSTRIAL'
	WHEN 4 THEN 'MUNICIPAL'
	WHEN 5 THEN 'ESTADUAL'
	WHEN 6 THEN 'FEDERAL'
	WHEN 7 THEN 'RES. POPULAR'
	WHEN 8 THEN 'PEQ. NEGOCIOS'
	WHEN 9 THEN 'ENT. FILANTROPICAS'
	WHEN 10 THEN 'SIST. OPERADO POR PREFEITURA'
	ELSE 'NAO DEFINIDO'
    END) AS "SUBCATEGORIA PRINCIPAL",
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
    une.uneg_nmunidadenegocio AS "NOME UNIDADE",
    loc.loca_id AS "CODIGO LOCALIDADE",    
    logr.logr_nmlogradouro AS "NOME LOGRADOURO",
    cep.cep_cdcep AS "CEP",
    imo.imov_dscomplementoendereco AS "COMPLEMENTO",
    bai.bair_nmbairro AS "BAIRRO",
    imo.imov_nnimovel AS "NR",
    mun.muni_nmmunicipio AS "MUNICIPIO",
    imo.imov_qteconomia AS "ECONOMIAS",
    hid.hidr_nnhidrometro AS "NR HID.",
    CAST(fat.ftst_id  AS TEXT) || ' - ' || fat.ftst_dsfaturamentosituacaotipo AS "SIT. FATURAMENTO",
    fsh.ftsh_amfatmtsitinicio AS "INICIO",
    fsh.ftsh_amfaturamentosituacaofim AS "FIM",
    ftm.ftsm_dsfatsitmotivo AS "MOTIVO",
    fsh.ftsh_dsobservacaoinforma AS "OBS FATURAMENTO",	    
    las.last_dsligacaoaguasituacao AS "SITUACAO AGUA", 
    les.lest_dsligacaoesgotosituacao AS "SITUACAO ESGOTO",
    subq.referencia AS "REFERENCIA FATURAMENTO",
    subq.vencimento AS "DATA VENCIMENTO",
    subq.cagua AS "VOLUME AGUA",
    TO_CHAR(subq.vl_agua, '999G999G990D00') AS "VALOR AGUA",
    subq.cesg AS "VOLUME ESGOTO",
    TO_CHAR(subq.vl_esgoto, '999G999G990D00') AS "VALOR ESGOTO",
    TO_CHAR(subq.vl_debitos, '999G999G990D00') AS "OUTROS SERVICOS",
    TO_CHAR(subq.vl_creditos, '999G999G990D00') AS "CREDITOS",
    TO_CHAR(subq.vl_impostos, '999G999G990D00') AS "IMPOSTOS",    
    TO_CHAR(subq.valor, '999G999G990D00') AS "VALOR FATURADO"

FROM contas_consolidadas subq
        LEFT JOIN cadastro.imovel imo ON imo.imov_id = subq.imov_id
 	INNER JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
	INNER JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
	INNER JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id AND loc.greg_id IN (1, 2)
	INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
	INNER JOIN cadastro.logradouro_bairro lgb ON lgb.lgbr_id = imo.lgbr_id
	INNER JOIN cadastro.logradouro logr ON lgb.logr_id = logr.logr_id	
	INNER JOIN cadastro.bairro bai ON bai.bair_id = lgb.bair_id
	INNER JOIN cadastro.municipio mun ON mun.muni_id = bai.muni_id
        INNER JOIN atendimentopublico.ligacao_agua_situacao las ON las.last_id = imo.last_id
        INNER JOIN atendimentopublico.ligacao_esgoto_situacao les ON les.lest_id = imo.lest_id
	LEFT JOIN cadastro.logradouro_cep lgc ON lgc.lgcp_id = imo.lgcp_id
	LEFT JOIN cadastro.cep cep ON cep.cep_id = lgc.cep_id
	LEFT JOIN atendimentopublico.ligacao_agua lagu ON lagu.lagu_id = imo.imov_id
	LEFT JOIN atendimentopublico.ligacao_esgoto lesg ON lesg.lesg_id = imo.imov_id	
	LEFT JOIN micromedicao.hidrometro_inst_hist his ON lagu.hidi_id = his.hidi_id AND his.hidi_dtretiradahidrometro IS NULL	   	
	LEFT JOIN micromedicao.hidrometro hid ON his.hidr_id = hid.hidr_id
	LEFT JOIN cadastro.cliente_imovel cim2 ON cim2.imov_id = imo.imov_id AND cim2.clim_dtrelacaofim IS NULL AND cim2.crtp_id  = 3
	LEFT JOIN cadastro.cliente cli2 ON cli2.clie_id = cim2.clie_id
	LEFT JOIN cadastro.cliente cli3 ON cli3.clie_id = cli2.clie_cdclienteresponsavel
	LEFT JOIN faturamento.fatur_situacao_hist fsh ON fsh.imov_id = imo.imov_id AND fsh.ftsh_amfaturamentoretirada IS NULL
	LEFT JOIN faturamento.fatur_situacao_tipo fat ON fat.ftst_id = fsh.ftst_id
	LEFT JOIN faturamento.fatur_situacao_motivo ftm ON fsh.ftsm_id = ftm.ftsm_id			
WHERE imo.imov_icexclusao = 2
  AND subq.valor > 0
  AND imo.imov_idcategoriaprincipal  = 2
  --AND mun.muni_nmmunicipio = 'SAO LUIS'

ORDER BY loc.loca_id, imo.imov_id;
