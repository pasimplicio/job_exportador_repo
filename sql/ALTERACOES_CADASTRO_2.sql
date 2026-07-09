SELECT
	usu.usur_nmlogin || ' - ' || uni.unid_dssiglaunidade AS "USUARIO",
	usu.usur_nmusuario AS "NOME USUARIO",
	emp.empr_nmempresa AS "EMPRESA",
	opf.opef_cnargumento AS "ID",
	imo.imov_id AS "MATRICULA ASSOCIADA",
	imo.iper_id AS "PERFIL DO IMOVEL",
	tbc.tbca_tmultimaalteracao::DATE AS "QUANDO",
	TO_TIMESTAMP(TO_CHAR(tbc.tbca_tmultimaalteracao,'DDMMYYYY HH24MIss'),'DDMMYYYY HH24MIss') AS "HORARIO",
	tco.tbco_dscoluna AS "DADO ALTERADO",
	tbc.tbca_cncolunaanterior AS "DADO ANTERIOR",
	tbc.tbca_cncolunaatual AS "DADO ATUAL"
	FROM
	seguranca.tabela_linha_alteracao tbl
	INNER JOIN seguranca.operacao_efetuada opf ON opf.opef_id = tbl.tref_id
	INNER JOIN seguranca.usuario_alteracao ual ON ual.tref_id = opf.opef_id
	INNER JOIN seguranca.usuario usu ON usu.usur_id = ual.usis_id
	INNER JOIN cadastro.unidade_organizacional uni ON uni.unid_id = usu.unid_id
	INNER JOIN seguranca.tab_linha_col_alteracao tbc ON tbl.tbla_id = tbc.tbla_id
	INNER JOIN seguranca.tabela_coluna tco ON tco.tbco_id = tbc.tbco_id
	LEFT JOIN cadastro.empresa emp ON emp.empr_id = usu.empr_id
	LEFT JOIN cadastro.cliente cli ON cli.clie_id = opf.opef_cnargumento
	LEFT JOIN cadastro.cliente_imovel cim ON cim.clie_id = cli.clie_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
	LEFT JOIN cadastro.imovel imo ON imo.imov_id = cim.imov_id
WHERE
	tbc.tbca_cncolunaanterior <> tbc.tbca_cncolunaatual
	AND tbc.tbco_id IN (
271, 275, 276, 1527, 4796
)
	AND tbc.tbca_tmultimaalteracao >= '2021-10-01'
	ORDER BY "HORARIO" DESC