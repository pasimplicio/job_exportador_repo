SELECT 
	con.imov_id AS "MATRICULA",
	cli.clie_nmcliente AS "CLIENTE",
	cli.clie_nncpf AS "CPF",
	cli.clie_nncnpj AS "CNPJ",
	(CASE cli.clie_iccpfcnpjvalidado
	WHEN 0 THEN 'NAO'
	WHEN 1 THEN 'SIM'
	ELSE 'NAO'
	END) AS "DOC VALIDADO",
	(
		SELECT
			STRING_AGG('('||cfn.cfon_cdddd||')'||cfn.cfon_nnfone,' | ')
		FROM
			cadastro.cliente_fone cfn
			INNER JOIN cadastro.cliente cli2 ON cli2.clie_id = cfn.clie_id
			INNER JOIN cadastro.cliente_imovel cim2 ON cim2.clie_id = cli2.clie_id AND cim2.clim_dtrelacaofim IS NULL AND cim2.imov_id = con.imov_id
	) AS "TELEFONES",
	cli.clie_dsemail AS "EMAIL",
	con.cnta_dtvencimentoconta AS "VENCIMENTO",
	con.cnta_vlagua+con.cnta_vlesgoto+con.cnta_vldebitos-con.cnta_vlcreditos-con.cnta_vlimpostos AS "VALOR",
	con.cnta_amreferenciaconta AS "REFERENCIA"
FROM
	faturamento.conta con
	INNER JOIN cadastro.cliente_imovel cim ON con.imov_id = cim.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
	INNER JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
	INNER JOIN cadastro.localidade loc ON loc.loca_id = con.loca_id
WHERE
	con.cnta_id = (
			SELECT 
				MAX(con4.cnta_id) 
			FROM 
				faturamento.conta con4 
				INNER JOIN faturamento.debito_cobrado deb ON deb.cnta_id = con4.cnta_id
				INNER JOIN faturamento.debito_a_cobrar dco ON dco.dbac_id = deb.dbac_id
				INNER JOIN cobranca.parcelamento par ON par.parc_id = dco.parc_id
			WHERE 
				con4.imov_id = con.imov_id
				AND con.dcst_idatual IN (0,1,2)
				AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con4.cnta_id) 
				AND con.cnta_dtvencimentoconta = CURRENT_DATE + INTERVAL '3d'
				AND con4.cnta_dtrevisao IS NULL 
				AND con4.iper_id <> 6
				AND (con.cnta_vlagua+con.cnta_vlesgoto+con.cnta_vldebitos-con.cnta_vlcreditos-con.cnta_vlimpostos)>0
				AND con.cnta_vldebitos > 0
				AND EXISTS (
						SELECT 
							ecc.cnta_id
						FROM 
							cobranca.parcelamento_item pit
							INNER JOIN cobranca.empresa_cobranca_conta ecc ON ecc.cnta_id = pit.cnta_id
						WHERE
							pit.parc_id = par.parc_id AND ecc.empr_id = VAR_EMPRESA
						LIMIT 1
							)
			)