SELECT
	usu.usur_nmlogin AS "LOGIN",
	usu.usur_nmusuario AS "NOME USUARIO",
	uni.unid_dsunidade AS "UNIDADE ORGANIZACIONAL",
	ust.usst_dsusuariosituacao AS "USUARIO SITUACAO",
	STRING_AGG(grp.grup_dsgrupo, ' / ') AS "GRUPO"
FROM
	seguranca.usuario usu
	INNER JOIN cadastro.unidade_organizacional uni ON uni.unid_id = usu.unid_id
	INNER JOIN seguranca.usuario_grupo usg ON usg.usur_id = usu.usur_id
	INNER JOIN seguranca.grupo grp ON usg.grup_id = grp.grup_id
	INNER JOIN seguranca.usuario_situacao ust ON ust.usst_id = usu.usst_id
GROUP BY 1,2,3,4