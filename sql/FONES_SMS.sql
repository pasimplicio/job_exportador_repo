SELECT 
	con.imov_id AS "MATRICULA",
	cli.clie_nmcliente AS "CLIENTE",
	cli.clie_dsemail AS "EMAIL",
	con.cnta_dtvencimentoconta AS "VENCIMENTO",
	con.cnta_vlagua+con.cnta_vlesgoto+con.cnta_vldebitos-con.cnta_vlcreditos-con.cnta_vlimpostos AS "VALOR",
	(REPLACE('826X' || 
	TRIM(TO_CHAR(con.cnta_vlagua+con.cnta_vlesgoto+con.cnta_vldebitos-con.cnta_vlcreditos-con.cnta_vlimpostos,'0000000-H 00.00')) ||
	REPLACE(TO_CHAR((select PARM_CDEMPRESAFEBRABAN from cadastro.sistema_parametros),'0000'),' ','') ||
	REPLACE(TO_CHAR(con.loca_id,'000'),' ','') ||'-H' ||
	TO_CHAR(con.imov_id,'000000000') ||
	'01' || '-H ' ||
	REPLACE(RIGHT(TO_CHAR(con.cnta_amreferenciaconta,'000000'),2) || LEFT(TO_CHAR(con.cnta_amreferenciaconta,'000000'),5),' ','') ||
	'D'||
	'000' ||
	'3-H','.','')) AS "COD BARRAS",
	con.cnta_amreferenciaconta AS "REFERENCIA",
	'('||cfn.cfon_cdddd||') '||cfn.cfon_nnfone AS "TELEFONE",
	loc.loca_nmlocalidade AS "LOCALIDADE",
	une.uneg_nmunidadenegocio AS "UNIDADE"
FROM
	faturamento.conta con
	INNER JOIN cadastro.cliente_imovel cim ON con.imov_id = cim.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
	INNER JOIN cadastro.imovel imo ON imo.imov_id = con.imov_id
	INNER JOIN cadastro.localidade loc ON loc.loca_id = imo.loca_id
	INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
	INNER JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
	INNER JOIN cadastro.cliente_fone cfn ON cfn.clie_id = cli.clie_id AND LEFT(cfn.cfon_nnfone,1)='9' AND LENGTH(cfn.cfon_nnfone)=9
WHERE
	une.uneg_id IN (${VAR_UNIDADES}) AND
	cfn.cfon_id = (
			SELECT 
				MAX(cfn2.cfon_id) 
			FROM 
				cadastro.cliente_fone cfn2 
			WHERE 
				cfn2.clie_id = cli.clie_id AND 
				LEFT(cfn2.cfon_nnfone,1)='9' AND 
				LENGTH(cfn2.cfon_nnfone)=9) 
	AND
	con.cnta_id = (
			SELECT 
				MAX(con4.cnta_id) 
			FROM 
				faturamento.conta con4 
			WHERE 
				con4.imov_id = con.imov_id
				AND con4.dcst_idatual IN (0,1,2)
				AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con4.cnta_id) 
				--AND (con.cnta_dtvencimentoconta = CURRENT_DATE + INTERVAL '5d' OR con.cnta_dtvencimentoconta = CURRENT_DATE + INTERVAL '2d' OR con.cnta_dtvencimentoconta = CURRENT_DATE)
				AND (con4.cnta_dtvencimentoconta = CURRENT_DATE OR con4.cnta_dtvencimentoconta = CURRENT_DATE - INTERVAL '30d')
				--AND con.cnta_dtvencimentoconta = CURRENT_DATE
				AND con4.cnta_dtrevisao IS NULL 
				AND con4.iper_id <> 6
				AND (con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos)>0
			)
	--AND NOT con.cnta_amreferenciaconta IN (202004,202005)