SELECT 
  imov.imov_id AS "MATRICULA",
  clie.clie_id AS "CODIGO CLIENTE",
  clie.clie_nmcliente AS "NOME",
  COALESCE(clie.clie_nncpf, clie.clie_nncnpj)  AS "CPF / CNPJ",
  clie2.clie_id AS "COD RESP",
  clie2.clie_nmcliente AS "NOME RESP",
  COALESCE(clie2.clie_nncpf, clie2.clie_nncnpj)  AS "CPF / CNPJ - RESP",
  clie3.clie_id AS "COD PAI",
  clie3.clie_nmcliente AS "NOME PAI",
  COALESCE(clie3.clie_nncpf, clie3.clie_nncnpj)  AS "CPF / CNPJ - PAI",
  imov.loca_id AS "LOCALIDADE",
  conta.valor AS "VALOR"
FROM 
  cadastro.imovel imov
  INNER JOIN cadastro.cliente_imovel clim ON clim.imov_id = imov.imov_id AND clim.clim_dtrelacaofim IS NULL AND clim.clim_icnomeconta = 1
  INNER JOIN cadastro.cliente clie ON clie.clie_id = clim.clie_id
  LEFT JOIN cadastro.cliente_imovel clim2 ON clim2.imov_id = imov.imov_id AND clim2.clim_dtrelacaofim IS NULL AND clim2.crtp_id  = 3
  LEFT JOIN cadastro.cliente clie2 ON clie2.clie_id = clim2.clie_id
  LEFT JOIN cadastro.cliente clie3 ON clie3.clie_id = clie2.clie_cdclienteresponsavel
  INNER JOIN cadastro.localidade loca ON imov.loca_id = loca.loca_id
  INNER JOIN cadastro.unidade_negocio uneg ON uneg.uneg_id = loca.uneg_id
  LEFT JOIN (
    SELECT
      imov_id,
      cnta.cnta_amreferenciaconta AS referencia,
      sum(cnta.cnta_vlagua + cnta.cnta_vlesgoto + cnta.cnta_vldebitos - cnta.cnta_vlcreditos - cnta.cnta_vlimpostos) AS valor
    FROM
      faturamento.conta cnta
    WHERE
      cnta.dcst_idatual IN (0, 1, 2)
      AND cnta.cnta_amreferenciaconta = 202504
    GROUP BY 1,2
    UNION
    SELECT
      imov_id,
      cnhi.cnhi_amreferenciaconta AS referencia,
      sum(cnhi.cnhi_vlagua + cnhi.cnhi_vlesgoto + cnhi.cnhi_vldebitos - cnhi.cnhi_vlcreditos - cnhi.cnhi_vlimpostos) AS valor
    FROM
      faturamento.conta_historico cnhi
    WHERE
      cnhi.dcst_idatual IN (0, 1, 2)
      AND cnhi.cnhi_amreferenciaconta = 202504
      GROUP BY 1,2
  ) AS conta ON conta.imov_id = imov.imov_id
WHERE
  imov.imov_icexclusao = 2  
  AND uneg.uneg_id IN (2,3,4,5,6,7,8,9,10,20,21)
  /*AND COALESCE(clie.clie_nncpf, clie.clie_nncnpj) IS NULL  
  AND COALESCE(clie2.clie_nncpf, clie2.clie_nncnpj) IS NULL  
  AND COALESCE(clie3.clie_nncpf, clie3.clie_nncnpj) IS NULL
  AND conta.valor IS NOT NULL*/