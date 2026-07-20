WITH conta_sel AS (
	SELECT DISTINCT ON (con.imov_id)
		con.imov_id,
		con.cnta_id,
		con.loca_id,
		con.cnta_dtvencimentoconta,
		con.cnta_amreferenciaconta,
		con.cnta_vlagua+con.cnta_vlesgoto+con.cnta_vldebitos-con.cnta_vlcreditos-con.cnta_vlimpostos AS valor,
		cli.clie_id,
		cli.clie_nmcliente,
		cli.clie_dsemail,
		cfn.cfon_cdddd,
		cfn.cfon_nnfone,
		loc.loca_nmlocalidade,
		une.uneg_nmunidadenegocio
	FROM
		faturamento.conta con
		INNER JOIN cadastro.cliente_imovel cim ON con.imov_id = cim.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
		INNER JOIN cadastro.imovel imo ON imo.imov_id = con.imov_id
		INNER JOIN cadastro.localidade loc ON loc.loca_id = imo.loca_id
		INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
		INNER JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
		INNER JOIN cadastro.cliente_fone cfn ON cfn.clie_id = cli.clie_id AND LEFT(cfn.cfon_nnfone,1)='9' AND LENGTH(cfn.cfon_nnfone)=9
	WHERE
		cfn.cfon_id = (
				SELECT
					MAX(cfn2.cfon_id)
				FROM
					cadastro.cliente_fone cfn2
				WHERE
					cfn2.clie_id = cli.clie_id AND
					LEFT(cfn2.cfon_nnfone,1)='9' AND
					LENGTH(cfn2.cfon_nnfone)=9)
		AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con.cnta_id)
		AND con.dcst_idatual IN (0,1,2)
		AND (con.cnta_dtvencimentoconta < CURRENT_DATE)
		AND imo.imov_idcategoriaprincipal IN (1,2,3)
		AND con.cnta_dtrevisao IS NULL
		AND con.iper_id <> 6
		AND (con.cnta_vlagua+con.cnta_vlesgoto+con.cnta_vldebitos-con.cnta_vlcreditos-con.cnta_vlimpostos)>0
		AND con.cnta_dtvencimentoconta >= '2023-01-01' AND con.cnta_dtvencimentoconta < CURRENT_DATE
		AND imo.iper_id <> 6
		AND imo.imov_idcategoriaprincipal <> 4
		AND cfn.cfon_cdddd IN ('98','99')
		AND NOT EXISTS(
			SELECT
				*
			FROM
				cobranca.cobranca_situacao_hist csh
			WHERE
				csh.imov_id = imo.imov_id
				AND csh.cbsh_amcobrancaretirada IS NULL
			LIMIT 1
		)
		AND une.uneg_id IN (${VAR_UNIDADE})
	ORDER BY con.imov_id, con.cnta_dtvencimentoconta DESC, con.cnta_id DESC
),
deb_agg AS (
	SELECT
		con4.imov_id,
		COUNT(con4.cnta_id) AS qtd,
		SUM(con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos) AS valor
	FROM faturamento.conta con4
	WHERE
		con4.dcst_idatual IN (0,1,2)
		AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con4.cnta_id)
		AND con4.cnta_dtvencimentoconta < CURRENT_DATE
		AND con4.cnta_dtrevisao IS NULL
		AND con4.iper_id <> 6
		AND con4.imov_id IN (SELECT cs.imov_id FROM conta_sel cs)
	GROUP BY con4.imov_id
)
SELECT
	cs.imov_id AS "MATRICULA",
	cs.clie_nmcliente AS "CLIENTE",
	cs.clie_dsemail AS "EMAIL",
	cs.cnta_dtvencimentoconta AS "VENCIMENTO",
	cs.valor AS "VALOR",
	(REPLACE('826X' ||
	TRIM(TO_CHAR(cs.valor,'0000000-H 00.00')) ||
	REPLACE(TO_CHAR((select PARM_CDEMPRESAFEBRABAN from cadastro.sistema_parametros),'0000'),' ','') ||
	REPLACE(TO_CHAR(cs.loca_id,'000'),' ','') ||'-H' ||
	TO_CHAR(cs.imov_id,'000000000') ||
	'01' || '-H ' ||
	REPLACE(RIGHT(TO_CHAR(cs.cnta_amreferenciaconta,'000000'),2) || LEFT(TO_CHAR(cs.cnta_amreferenciaconta,'000000'),5),' ','') ||
	'D'||
	'000' ||
	'3-H','.','')) AS "COD BARRAS",
	cs.cnta_amreferenciaconta AS "REFERENCIA",
	'('||cs.cfon_cdddd||') '||cs.cfon_nnfone AS "TELEFONE",
	cs.loca_nmlocalidade AS "LOCALIDADE",
	cs.uneg_nmunidadenegocio AS "UNIDADE",
	da.qtd AS "QTD DEBITOS",
	da.valor AS "VALOR DEBITOS"
FROM
	conta_sel cs
	LEFT JOIN deb_agg da ON da.imov_id = cs.imov_id
ORDER BY "VALOR" DESC
