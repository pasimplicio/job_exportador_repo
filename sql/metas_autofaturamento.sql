WITH ultimo_pagamento AS (
    SELECT DISTINCT ON (pag.imov_id)
        pag.imov_id,
        pag.pgmt_amreferenciapagamento AS referencia,
        pag.pgmt_vlpagamento          AS valor
    FROM (
        SELECT
            p.imov_id,
            p.loca_id,
            p.pgmt_amreferenciapagamento,
            p.pgmt_vlpagamento,
            p.pgmt_dtpagamento
        FROM arrecadacao.pagamento p
        UNION ALL
        SELECT
            ph.imov_id,
            ph.loca_id,
            ph.pghi_amreferenciapagamento AS pgmt_amreferenciapagamento,
            ph.pghi_vlpagamento           AS pgmt_vlpagamento,
            ph.pghi_dtpagamento           AS pgmt_dtpagamento
        FROM arrecadacao.pagamento_historico ph
    ) pag
    INNER JOIN cadastro.localidade loc
        ON loc.loca_id = pag.loca_id
    ORDER BY
        pag.imov_id,
        pag.pgmt_amreferenciapagamento DESC,
        pag.pgmt_dtpagamento DESC NULLS LAST
),

ops AS (
    SELECT
        CAST(oe.opef_cnargumento AS BIGINT)      AS imov_id,
        op.oper_dsoperacao                      AS descricao_operacao,
        MAX(oe.opef_tmultimaalteracao)          AS ts_operacao
    FROM seguranca.operacao_efetuada oe
    JOIN seguranca.operacao op ON op.oper_id = oe.oper_id
    WHERE oe.oper_id = 17
      --AND oe.opef_tmultimaalteracao BETWEEN DATE '2025-01-01' AND CURRENT_DATE
      AND oe.opef_cnargumento IS NOT NULL
    GROUP BY CAST(oe.opef_cnargumento AS BIGINT), op.oper_dsoperacao
    ORDER BY imov_id, ts_operacao
),


contas_validas AS (
  SELECT 
    con.imov_id as imov_id,
    count(con.cnta_id)as qtd,
    sum(con.cnta_vlagua + con.cnta_vlesgoto + con.cnta_vldebitos - con.cnta_vlcreditos - con.cnta_vlimpostos) AS valor
  FROM faturamento.conta con
  JOIN faturamento.conta_categoria catg ON catg.cnta_id = con.cnta_id
  JOIN cadastro.imovel imo ON imo.imov_id = con.imov_id
  WHERE con.dcst_idatual IN (0,1,2)
    AND con.cnta_dtrevisao IS NULL
    AND con.cnta_dtvencimentoconta < CURRENT_DATE
    AND con.iper_id <> 6
    AND NOT EXISTS (
      SELECT 1 
      FROM arrecadacao.pagamento pag 
      WHERE pag.cnta_id = con.cnta_id
    )
  group by 1
)


SELECT
    imo.imov_id AS "Imovel",
    TO_CHAR(imo.imov_nncoordenaday,'990D999999999999999') AS "LATITUDE",
    TO_CHAR(imo.imov_nncoordenadax,'990D999999999999999') AS "LONGITUDE",    
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
    les.lest_dsligacaoesgotosituacao AS "Situacao de esgoto",
    lagu.lagu_dtligacaoagua AS "Data ligacao",
    CAST(oper.ts_operacao AS DATE) AS "Data ultima alteracao",
    TO_CHAR(fat.valor, '999G999G990D00') AS "Valor Faturado",
    up.referencia AS "Ultima ref paga",
    TO_CHAR(up.valor, '999G999G990D00') AS "Ultimo valor pago",
    cv.qtd AS "Qtde Contas em atraso",
    TO_CHAR(cv.valor, '999G999G990D00') AS "Débito total"
/*    CASE 
	WHEN fat.valor > 0 THEN 'FATURANDO'
		ELSE 'NAO FATURANDO'
    END AS "Status Faturamento"*/
FROM
	cadastro.imovel imo
	LEFT JOIN ultimo_pagamento up ON up.imov_id = imo.imov_id
	LEFT JOIN contas_validas cv ON cv.imov_id = imo.imov_id
	LEFT JOIN ops oper ON oper.imov_id = imo.imov_id			
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
			AND con.cnta_amreferenciaconta = 202512
			UNION ALL  
			SELECT 
				con.imov_id,
				con.cnhi_vlagua + con.cnhi_vlesgoto + con.cnhi_vldebitos - con.cnhi_vlcreditos - con.cnhi_vlimpostos AS valor
			FROM faturamento.conta_historico con
			WHERE con.dcst_idatual IN (0,1,2,5)
			AND con.cnhi_amreferenciaconta = 202512
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
