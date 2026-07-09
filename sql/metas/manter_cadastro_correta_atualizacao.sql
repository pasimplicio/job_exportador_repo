WITH contas_ativas AS (
    SELECT
        cnta.imov_id,
        cnta.cnta_id AS idconta,
        cnta.cnta_amreferenciaconta AS referencia,
        cnta.cnta_dtvencimentoconta AS vencimento,
        (cnta.cnta_vlagua + cnta.cnta_vlesgoto + cnta.cnta_vldebitos
         - cnta.cnta_vlcreditos - cnta.cnta_vlimpostos) AS valor
    FROM faturamento.conta cnta
    WHERE cnta.cnta_amreferenciaconta BETWEEN 202601 AND 202612
      AND cnta.dcst_idatual IN (0,1,2)
),

contas_historicas AS (
    SELECT
        cnhi.imov_id,
        cnhi.cnta_id AS idconta,
        cnhi.cnhi_amreferenciaconta AS referencia,
        cnhi.cnhi_dtvencimentoconta AS vencimento,        
        (cnhi.cnhi_vlagua + cnhi.cnhi_vlesgoto + cnhi.cnhi_vldebitos
         - cnhi.cnhi_vlcreditos - cnhi.cnhi_vlimpostos) AS valor
    FROM faturamento.conta_historico cnhi
    WHERE cnhi.cnhi_amreferenciaconta BETWEEN 202601 AND 202612
      AND cnhi.dcst_idatual IN (0,1,2)
),

contas_consolidadas AS (
    SELECT * FROM contas_ativas
    UNION ALL
    SELECT * FROM contas_historicas
)


SELECT 
  imo.imov_id AS "MATRICULA",
  CASE
    WHEN cli.clie_nncpf IS NULL
     AND cli.clie_nncnpj IS NULL
     AND cli2.clie_nncpf IS NULL
     AND cli2.clie_nncnpj IS NULL
     AND cli3.clie_nncpf IS NULL
     AND cli3.clie_nncnpj IS NULL
    THEN 'NAO' ELSE 'SIM'
  END AS "IDENTIFICADA",
 	(CASE imo.imov_idcategoriaprincipal 
	WHEN 1 THEN '1 - RESIDENCIAL'
	WHEN 2 THEN '2 - COMERCIAL'
	WHEN 3 THEN '3 - INDUSTRIAL'
	WHEN 4 THEN '4 - PUBLICO'
	ELSE 'NAO DEFINIDO'
	END) AS "CATEGORIA PRINCIPAL",
	imo.iper_id AS "PERFIL",
  	une.uneg_nmunidadenegocio AS "GERENCIA",
  now() AS "EXTRACAO"
FROM cadastro.imovel imo
	INNER JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
	INNER JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
	INNER JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
	INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
	LEFT JOIN cadastro.cliente_imovel cim2 ON cim2.imov_id = imo.imov_id AND cim2.clim_dtrelacaofim IS NULL AND cim2.crtp_id  = 3
	LEFT JOIN cadastro.cliente cli2 ON cli2.clie_id = cim2.clie_id
	LEFT JOIN cadastro.cliente cli3 ON cli3.clie_id = cli2.clie_cdclienteresponsavel
        LEFT JOIN contas_consolidadas cc ON cc.imov_id = imo.imov_id	
WHERE imo.imov_idcategoriaprincipal <> 4
  AND imo.iper_id <> '6'
  AND cc.valor > 0
  AND cli3.clie_id IS NULL
