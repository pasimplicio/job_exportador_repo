SELECT 
	mod.modu_dsmodulo AS "MODULO",
	grp.grup_dsgrupo AS "GRUPO CHAVE",
	grp.grup_icuso AS "ATIVO?",
	ope.oper_dsoperacao AS "OPERACAO",
	fun.fncd_dsfuncionalidade AS "FUNCIONALIDADE",
	fun.fncd_icpontoentrada AS "PONTO DE ENTRADA",
	fun.fncd_dscaminhomenu AS "CAMINHO MENU",
	fun.fncd_dscaminhourl AS "URL",
	funpai.fncd_dsfuncionalidade AS "FUNCIONALIDADE PAI",
	funpai.fncd_icpontoentrada AS "PONTO DE ENTRADA PAI",
	funpai.fncd_dscaminhomenu AS "CAMINHO MENU PAI",
	funpai.fncd_dscaminhourl AS "URL PAI"
FROM
	seguranca.grupo_func_operacao gfo
	INNER JOIN seguranca.operacao ope ON gfo.oper_id = ope.oper_id
	INNER JOIN seguranca.funcionalidade fun ON fun.fncd_id = gfo.fncd_id
	INNER JOIN seguranca.modulo mod ON mod.modu_id = fun.modu_id
	INNER JOIN seguranca.grupo grp ON grp.grup_id = gfo.grup_id
	LEFT JOIN seguranca.funcionalidade_depend fdp ON fdp.fncd_iddependencia = fun.fncd_id
	LEFT JOIN seguranca.funcionalidade funpai ON funpai.fncd_id = fdp.fncd_id