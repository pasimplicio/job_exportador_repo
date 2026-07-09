SELECT distinct
	cli.clie_id AS "CODIGO CLIENTE",
	cli.clie_nmcliente AS "NOME",
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
			INNER JOIN cadastro.cliente_imovel cim2 ON cim2.clie_id = cli2.clie_id AND cim2.clim_dtrelacaofim IS NULL AND cim2.imov_id = imo.imov_id
	) AS "TELEFONES",
	(
		SELECT
			'('||cfn.cfon_cdddd||')'||cfn.cfon_nnfone
		FROM
			cadastro.cliente_fone cfn
		WHERE 
			cfn.cfon_icfonepadrao = 1 AND cfn.clie_id = cli.clie_id
		LIMIT 1
	) AS "TELEFONE PADRAO TITULAR",
	(
		SELECT
			'('||cfn.cfon_cdddd||')'||cfn.cfon_nnfone
		FROM
			cadastro.cliente_fone cfn
		WHERE 
			cfn.clie_id = cli.clie_id AND cfn.cfon_id = (SELECT MAX(cfn2.cfon_id) FROM cadastro.cliente_fone cfn2 WHERE cfn2.clie_id = cli.clie_id)
		LIMIT 1
	) AS "TELEFONE MAIS RECENTE TITULAR",
	(
		SELECT
			'('||cfn.cfon_cdddd||')'||cfn.cfon_nnfone
		FROM
			cadastro.cliente_fone cfn
		WHERE 
			cfn.clie_id = cli.clie_id 
			AND LEFT(cfn.cfon_nnfone,1) = '9'
			AND cfn.cfon_id = (SELECT MAX(cfn2.cfon_id) FROM cadastro.cliente_fone cfn2 WHERE cfn2.clie_id = cli.clie_id AND LEFT(cfn2.cfon_nnfone,1) = '9')
		LIMIT 1
	) AS "CELULAR MAIS RECENTE TITULAR",
	(
		SELECT
			'('||cfn.cfon_cdddd||')'||cfn.cfon_nnfone
		FROM
			cadastro.cliente_fone cfn
		WHERE 
			cfn.clie_id = cli.clie_id 
			AND LEFT(cfn.cfon_nnfone,1) = '9'
			AND cfn.cfon_cdddd IN ('98','99')
			AND cfn.cfon_id = (SELECT MAX(cfn2.cfon_id) FROM cadastro.cliente_fone cfn2 WHERE cfn2.clie_id = cli.clie_id AND LEFT(cfn2.cfon_nnfone,1) = '9' AND cfn2.cfon_cdddd IN ('98','99'))
		LIMIT 1
	) AS "CELULAR MAIS RECENTE DDD MA",
	cli.clie_dsemail AS "EMAIL",
	TO_CHAR(cli.clie_dtnascimento,'DD/MM/YYYY') AS "DT NASCIMENTO",
	cli.clie_nnmae AS "NOME DA MAE",
	sex.psex_dspessoasexo AS "SEXO"

FROM
	cadastro.cliente cli
	INNER JOIN cadastro.cliente_imovel cim ON cli.clie_id = cim.clie_id
	INNER JOIN cadastro.imovel imo ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
	LEFT JOIN cadastro.pessoa_sexo sex ON sex.psex_id = cli.psex_id

WHERE
	--cli.clie_id in (2609770, 7344945, 4499468) AND
	imo.imov_icexclusao = 2