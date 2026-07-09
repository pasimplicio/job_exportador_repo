SELECT 
	* 
FROM
	seguranca.usuario 
	INNER JOIN (SELECT usur_nmsenha AS senha, COUNT(usur_nmlogin) AS rept FROM seguranca.usuario GROUP BY 1 ORDER BY 2 DESC) AS grup_senha ON grup_senha.senha = usur_nmsenha
WHERE
	grup_senha.rept>1