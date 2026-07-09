SELECT
    imo.imov_id AS "Imovel",
    --TO_CHAR(imo.imov_nncoordenaday,'990D999999999999999') AS "LATITUDE",
    --TO_CHAR(imo.imov_nncoordenadax,'990D999999999999999') AS "LONGITUDE",    
    ipe.iper_dsimovelperfil AS "Perfil",
    cli.clie_id AS "CODIGO CLIENTE",
    cli.clie_nmcliente AS "NOME",
    cli.clie_nncpf AS "CPF",
    cli.clie_nncnpj AS "CNPJ",    
    cli.clie_cdclienteresponsavel AS "USUARIO CLIENTE SUPERIOR",
    cli2.clie_id AS "COD RESP",
    cli2.clie_nmcliente AS "NOME RESP",
    cli2.clie_cdclienteresponsavel AS "RESPONSAVEL CLIENTE SUPERIOR",
    cli2.clie_nncpf AS "CPF RESP",
    cli2.clie_nncnpj AS "CNPJ RESP",    
    cli3.clie_id AS "COD PAI",
    cli3.clie_nmcliente AS "NOME PAI",
    cli3.clie_cdclienteresponsavel AS "PAI CLIENTE SUPERIOR", 
    cli3.clie_nncpf AS "CPF PAI",
    cli3.clie_nncnpj AS "CNPJ PAI",
    CASE imo.imov_idcategoriaprincipal 
        WHEN 1 THEN 'RESIDENCIAL'
        WHEN 2 THEN 'COMERCIAL'
        WHEN 3 THEN 'INDUSTRIAL'
        WHEN 4 THEN 'PUBLICO'
        ELSE 'NAO DEFINIDO'
    END AS "Categoria Principal",        
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
    las.last_dsligacaoaguasituacao AS "Situacao da agua",
    lagu.lagu_dtligacaoagua AS "Data ligacao",
    TO_CHAR(fat.valor, '999G999G990D00') AS "Valor Faturado",
    CASE 
	WHEN fat.valor > 0 THEN 'FATURANDO'
		ELSE 'NAO FATURANDO'
    END AS "Status Faturamento"
    
FROM
	cadastro.imovel imo
	LEFT JOIN cadastro.cliente_imovel cim 
		ON cim.imov_id = imo.imov_id 
		AND cim.clim_dtrelacaofim IS NULL 
		AND cim.clim_icnomeconta = 1
	LEFT JOIN cadastro.cliente cli 
		ON cli.clie_id = cim.clie_id
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
	LEFT JOIN cadastro.logradouro_cep lgc ON lgc.lgcp_id = imo.lgcp_id
	LEFT JOIN cadastro.cep cep ON cep.cep_id = lgc.cep_id
	LEFT JOIN cadastro.logradouro_tipo lgt ON lgt.lgtp_id = logr.lgtp_id	
	LEFT JOIN atendimentopublico.ligacao_agua_situacao las 
		ON las.last_id = imo.last_id
	LEFT JOIN atendimentopublico.ligacao_esgoto_situacao les 
		ON les.lest_id = imo.lest_id
	LEFT JOIN atendimentopublico.ligacao_agua lagu 
		ON lagu.lagu_id = imo.imov_id
	LEFT JOIN cadastro.imovel_perfil ipe 
		ON imo.iper_id = ipe.iper_id
	LEFT JOIN cadastro.categoria cat 
		ON imo.imov_idcategoriaprincipal = cat.catg_id
	LEFT JOIN cadastro.subcategoria sca 
		ON imo.imov_idsubcategoriaprincipal = sca.scat_id
	LEFT JOIN cadastro.cliente_imovel cim2 
		ON cim2.imov_id = imo.imov_id 
		AND cim2.clim_dtrelacaofim IS NULL 
		AND cim2.crtp_id = 3
	LEFT JOIN cadastro.cliente cli2 
		ON cli2.clie_id = cim2.clie_id
	LEFT JOIN cadastro.cliente cli3 
		ON cli3.clie_id = cli2.clie_cdclienteresponsavel
	LEFT JOIN micromedicao.hidrometro_inst_hist his 
		ON lagu.hidi_id = his.hidi_id 
		AND his.hidi_dtretiradahidrometro IS NULL	
	LEFT JOIN micromedicao.hidrometro hid 
		ON his.hidr_id = hid.hidr_id
	-- JOIN COM A TABELA DE CONTAS (FATURAMENTO OU HISTÓRICO) QUE TÊM VALOR POSITIVO
	LEFT JOIN (
		SELECT
			uniao.imov_id,
			uniao.valor
		FROM
			(SELECT 
				con.imov_id,
				con.cnta_vlagua + con.cnta_vlesgoto + con.cnta_vldebitos - con.cnta_vlcreditos - con.cnta_vlimpostos AS valor
			FROM faturamento.conta con
			WHERE con.dcst_idatual IN (0,1,2,5)
			AND con.cnta_amreferenciaconta = 202508
			UNION ALL  
			SELECT 
				con.imov_id,
				con.cnhi_vlagua + con.cnhi_vlesgoto + con.cnhi_vldebitos - con.cnhi_vlcreditos - con.cnhi_vlimpostos AS valor
			FROM faturamento.conta_historico con
			WHERE con.dcst_idatual IN (0,1,2,5)
			AND con.cnhi_amreferenciaconta = 202508
		       ) AS uniao
		) fat ON fat.imov_id = imo.imov_id
WHERE
    imo.imov_icexclusao = 2
    AND (cli.clie_nncpf IS NULL OR TRIM(cli.clie_nncpf) = '')
    AND (cli.clie_nncnpj IS NULL OR TRIM(cli.clie_nncnpj) = '')
    AND (cli2.clie_nncpf IS NULL OR TRIM(cli2.clie_nncpf) = '')
    AND (cli2.clie_nncnpj IS NULL OR TRIM(cli2.clie_nncnpj) = '')
    AND (cli3.clie_nncpf IS NULL OR TRIM(cli3.clie_nncpf) = '')
    AND (cli3.clie_nncnpj IS NULL OR TRIM(cli3.clie_nncnpj) = '')
    AND fat.valor > 0
    AND imo.imov_idcategoriaprincipal <> 4
