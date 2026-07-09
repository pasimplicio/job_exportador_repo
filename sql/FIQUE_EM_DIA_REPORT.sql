	SELECT
		'PARCELAMENTO' AS "MODALIDADE",
		COALESCE((
			SELECT
				mes.meso_dsmeiosolicitacao
			FROM
				atendimentopublico.meio_solicitacao mes
				INNER JOIN atendimentopublico.registro_atendimento ra ON ra.meso_id = mes.meso_id
				INNER JOIN atendimentopublico.atend_motivo_encmt ate ON ate.amen_id = ra.amen_id
			WHERE
				ra.imov_id = imo.imov_id
				AND ra.step_id = 1062
				AND ra.rgat_tmregistroatendimento >= CURRENT_DATE - INTERVAL '7days'
				AND ate.amen_icexecucao = 1
			ORDER BY ra.rgat_tmregistroatendimento DESC
			LIMIT 1
		),
		(
			SELECT
				mes.meso_dsmeiosolicitacao
			FROM
				atendimentopublico.meio_solicitacao mes
				INNER JOIN atendimentopublico.registro_atendimento ra ON ra.meso_id = mes.meso_id
				INNER JOIN atendimentopublico.atend_motivo_encmt ate ON ate.amen_id = ra.amen_id
			WHERE
				ra.imov_id = imo.imov_id
				AND ra.step_id = 977
				AND ra.rgat_tmregistroatendimento >= CURRENT_DATE - INTERVAL '7days'
				AND ate.amen_icexecucao = 1
			ORDER BY ra.rgat_tmregistroatendimento DESC
			LIMIT 1
		),'BALCAO') AS "MEIO SOLICITACAO",
		par.imov_id AS "MATRICULA",
		TO_CHAR(imo.imov_nncoordenadax,'990D999999999999999') AS "LATITUDE",
		TO_CHAR(imo.imov_nncoordenaday,'990D999999999999999') AS "LONGITUDE",
/*		CASE 
		    WHEN anx.raan_imdocumento IS NOT NULL THEN
		    'COM ANEXO'
		 ELSE
		    'SEM ANEXO' 
		 END AS "ANEXO",*/
		cat.catg_dscategoria AS "CATEGORIA",
		loc.uneg_id AS "GERENCIA",
		une.uneg_nmunidadenegocio AS "NOME UNIDADE",
		imo.loca_id AS "LOCALIDADE",
		loc.loca_nmlocalidade AS "NOME LOCALIDADE",
		usu.usur_nmlogin AS "LOGIN",
		usu.usur_nmusuario AS "NOME USUARIO",
		uno.unid_dsunidade AS "UNIDADE ORG",
		TO_CHAR(par.parc_tmparcelamento,'dd/MM/YYYY') AS "DATA OPCAO",
		TO_CHAR(par.parc_tmparcelamento,'hh24:mi') AS "HORA OPCAO",
		TO_CHAR(par.parc_tmparcelamento,'hh24') AS "HORA DO DIA OPCAO",
		TO_CHAR(par.parc_vldebitoatualizado,'999999999999990D00') AS "VALOR DEBITO",
		TO_CHAR(par.parc_vlentrada,'999999999999990D00') AS "VALOR ENTRADA",
		TO_CHAR(COALESCE(gpg_entrada.gpag_dtvencimento,gph_entrada_historico.gphi_dtvencimento),'dd/MM/YYYY') AS "VENCIMENTO ENTRADA",
		TO_CHAR(COALESCE(pag_entrada.pgmt_dtpagamento,pag_entrada_historico.pghi_dtpagamento),'dd/MM/YYYY') AS "DATA PAGAMENTO ENTRADA",
		TO_CHAR(COALESCE(pag_entrada.pgmt_vlpagamento,pag_entrada_historico.pghi_vlpagamento,0),'999999999999990D00') AS "VALOR PAGO ENTRADA",
		par.parc_nnprestacoes AS "PARCELAS",
		TO_CHAR(par.parc_vlprestacao,'999999999999990D00') AS "VALOR PARCELA",
		TO_CHAR(par.parc_vlprestacao*par.parc_nnprestacoes,'999999999999990D00') AS "VL FINANCIADO TOTAL",
		TO_CHAR((par.parc_vldebitoatualizado - ((par.parc_vlprestacao*par.parc_nnprestacoes)+par.parc_vlentrada)),'999999999999990D00') AS "DESCONTO CONCEDIDO TOTAL",
		TO_CHAR(par.parc_vlentrada+(par.parc_vlprestacao*par.parc_nnprestacoes),'999999999999990D00') AS "VALOR FINAL",
		'' AS "VENCIMENTO A VISTA",
		'' AS "DATA PAGAMENTO A VISTA",
		TO_CHAR(0,'999999999999990D00') AS "VALOR PAGO A VISTA",
		COALESCE((SELECT
			STRING_AGG(cbs.cbst_dscobrancasituacao || '- ' ||TO_CHAR(ics.iscb_dtimplantacaocobranca,'dd/MM/YYYY'),';')
		FROM
			cadastro.imovel_cobranca_situacao ics
			INNER JOIN cobranca.cobranca_situacao cbs ON cbs.cbst_id = ics.cbst_id
		WHERE
			ics.iscb_dtretiradacobranca IS NULL
			AND cbs.cbst_id IN (12,14,17,24,25,26)
			AND ics.imov_id = imo.imov_id),'') AS "SIT COBRANCA",
		TO_CHAR(COALESCE((par.parc_vljurosmora + par.parc_vlmulta),0),'999999999999990D00') AS "VALOR JUROS E MULTAS",
		cli.clie_id AS "ID CLIENTE TITULAR DO IMOVEL",
		cli.clie_nmcliente AS "NOME DO CLIENTE TITULAR",
		CASE
		    WHEN cli.clie_nncpf IS NOT NULL THEN
			CONCAT(SUBSTRING(cli.clie_nncpf,1,3),'.',SUBSTRING(cli.clie_nncpf,4,3),'.',SUBSTRING(cli.clie_nncpf,7,3),'-',SUBSTRING(cli.clie_nncpf,10,2))
		    WHEN cli.clie_nncnpj IS NOT NULL THEN
			CONCAT(SUBSTRING(cli.clie_nncnpj, 1, 2),'.',SUBSTRING(cli.clie_nncnpj,3,3),'.',SUBSTRING(cli.clie_nncnpj,6,3),'/',SUBSTRING(cli.clie_nncnpj,9,4),'-',SUBSTRING(cli.clie_nncnpj, 13, 2))
		ELSE
			''
		END AS "DOCUMENTO CLIENTE TITULAR",
		cli_par.clie_id AS "ID CLIENTE RESPONSAVEL DO PARCELAMENTO",
		cli_par.clie_nmcliente AS "NOME DO CLIENTE RESPOSÁVEL",
		TO_CHAR(COALESCE(par.parc_vlprestacao*valor_pago_parcelas.qtd,0),'999G999G990D00') AS "VALOR PAGO PARCELAS",
		valor_pago_parcelas.qtd AS "QTD PARCELAS PAGAS",
		TO_CHAR(con_atraso.valor,'999999999999990D00') AS "VALOR ATRASO",
		con_atraso.qtd AS "QTD CONTAS ATRASO",
		con_atraso.min AS "MENOR REF ATRASO",
		con_atraso.max AS "MAIOR REF ATRASO"
		
	FROM
		cobranca.parcelamento par
		INNER JOIN cadastro.imovel imo ON imo.imov_id = par.imov_id 
		INNER JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
		INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
		LEFT JOIN cadastro.categoria cat ON cat.catg_id = imo.imov_idcategoriaprincipal
		LEFT JOIN seguranca.usuario usu ON usu.usur_id = par.usur_id
		LEFT JOIN cadastro.unidade_organizacional uno ON uno.unid_id = usu.unid_id
		LEFT JOIN faturamento.guia_pagamento gpg_entrada ON gpg_entrada.parc_id = par.parc_id AND gpg_entrada.dbtp_id = 33 AND gpg_entrada.dcst_idatual IN (0,1,2)
		LEFT JOIN arrecadacao.pagamento pag_entrada ON pag_entrada.gpag_id = gpg_entrada.gpag_id
		LEFT JOIN faturamento.guia_pagamento_historico gph_entrada_historico ON gph_entrada_historico.parc_id = par.parc_id AND gph_entrada_historico.dbtp_id = 33 AND gph_entrada_historico.dcst_idatual IN (0,1,2)
		LEFT JOIN arrecadacao.pagamento_historico pag_entrada_historico ON pag_entrada_historico.gpag_id = gph_entrada_historico.gpag_id
		LEFT JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
		LEFT JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
		LEFT JOIN cadastro.cliente cli_par ON par.clie_id = cli_par.clie_id
		LEFT JOIN atendimentopublico.registro_atendimento rat ON rat.imov_id = par.imov_id
		LEFT JOIN atendimentopublico.ra_anexo anx ON anx.rgat_id = rat.rgat_id		
		LEFT JOIN
			(SELECT
				con4.imov_id AS mat1,
				MIN(con4.cnta_amreferenciaconta) AS min,
				MAX(con4.cnta_amreferenciaconta) AS max,
				COUNT(con4.cnta_id) AS qtd,
				SUM(con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos) AS valor
			FROM
				faturamento.conta con4
				WHERE
					con4.dcst_idatual IN (0,1,2,5) AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con4.cnta_id) AND con4.cnta_dtvencimentoconta > '2023-01-01' AND con4.cnta_dtvencimentoconta < CURRENT_DATE AND con4.cnta_dtrevisao IS NULL AND con4.iper_id <> 6
				GROUP BY 1) AS con_atraso ON con_atraso.mat1 = imo.imov_id	
		LEFT JOIN (
		SELECT
				parc_id,
				qtd,
				SUM(valor_pago) AS valor_pago
		FROM
				(SELECT
					dch.parc_id AS parc_id,
					COUNT(distinct dco.cnta_id) AS qtd,
					SUM(dco.dbcb_vlprestacao) AS valor_pago
				FROM
					faturamento.conta con
					INNER JOIN faturamento.debito_cobrado dco ON dco.cnta_id = con.cnta_id
					INNER JOIN faturamento.debito_a_cobrar_geral dcg ON dcg.dbac_id = dco.dbac_id
					INNER JOIN faturamento.debito_a_cobrar dch ON dch.dbac_id = dcg.dbac_id
					INNER JOIN arrecadacao.pagamento pgh ON pgh.cnta_id = con.cnta_id AND pgh.pgst_idatual IN (0,1,2,5)
					INNER JOIN cobranca.parcelamento par ON par.parc_id = dch.parc_id
					
				WHERE
					par.parc_tmparcelamento >= '2023-01-18'
				GROUP BY 1) AS TMP
				GROUP BY 1,2 ) AS valor_pago_parcelas ON valor_pago_parcelas.parc_id = par.parc_id
		WHERE
			par.parc_tmparcelamento >= '2023-01-18' /*AND imo.imov_id IN(915297,2080605)*/ AND par.rdir_id = 48 AND par.pcst_id = 1
UNION
	SELECT
		'A VISTA' AS "MODALIDADE",
		COALESCE((
			SELECT
				mes.meso_dsmeiosolicitacao
			FROM
				atendimentopublico.meio_solicitacao mes
				INNER JOIN atendimentopublico.registro_atendimento ra ON ra.meso_id = mes.meso_id
				INNER JOIN atendimentopublico.atend_motivo_encmt ate ON ate.amen_id = ra.amen_id
			WHERE
				ra.imov_id = imo.imov_id
				AND ra.step_id = 1062
				AND ra.rgat_tmregistroatendimento >= CURRENT_DATE - INTERVAL '7days'
				AND ate.amen_icexecucao = 1
			ORDER BY ra.rgat_tmregistroatendimento DESC
			LIMIT 1
		),
		(
			SELECT
				mes.meso_dsmeiosolicitacao
			FROM
				atendimentopublico.meio_solicitacao mes
				INNER JOIN atendimentopublico.registro_atendimento ra ON ra.meso_id = mes.meso_id
				INNER JOIN atendimentopublico.atend_motivo_encmt ate ON ate.amen_id = ra.amen_id
			WHERE
				ra.imov_id = imo.imov_id
				AND ra.step_id = 977
				AND ra.rgat_tmregistroatendimento >= CURRENT_DATE - INTERVAL '7days'
				AND ate.amen_icexecucao = 1
			ORDER BY ra.rgat_tmregistroatendimento DESC
			LIMIT 1
		),'BALCAO') AS "MEIO SOLICITACAO",
		cdb.imov_id AS "MATRICULA",
		TO_CHAR(imo.imov_nncoordenadax,'990D999999999999999') AS "LATITUDE",
		TO_CHAR(imo.imov_nncoordenaday,'990D999999999999999') AS "LONGITUDE",
		cat.catg_dscategoria AS "CATEGORIA",
		loc.uneg_id AS "GERENCIA",
		une.uneg_nmunidadenegocio AS "NOME UNIDADE",
		imo.loca_id AS "LOCALIDADE",
		loc.loca_nmlocalidade AS "NOME LOCALIDADE",
		usu.usur_nmlogin AS "LOGIN",
		usu.usur_nmusuario AS "NOME USUARIO",
		uno.unid_dsunidade AS "UNIDADE ORG",
		TO_CHAR(cdb.cbdo_tmemissao,'dd/MM/YYYY') AS "DATA OPCAO",
		TO_CHAR(cdb.cbdo_tmemissao,'hh24:mi') AS "HORARIO OPCAO",
		TO_CHAR(cdb.cbdo_tmemissao,'hh24') AS "HORA DO DIA OPCAO",
		TO_CHAR((cdb.cbdo_vldocumento+cdb.cbdo_vldesconto),'999999999999990D00') AS "VALOR DEBITO",
		TO_CHAR(0,'999999999999990D00') AS "VALOR ENTRADA",
		'' AS "VENCIMENTO ENTRADA",
		'' AS "DATA PAGAMENTO ENTRADA",
		TO_CHAR(0,'999999999999990D00') AS "VALOR PAGO ENTRADA",
		0 AS "PARCELAS",
		TO_CHAR(0,'999999999999990D00') AS "VALOR PARCELA",
		TO_CHAR(0,'999999999999990D00') AS "VL FINANCIADO TOTAL",
		TO_CHAR(cdb.cbdo_vldesconto,'999999999999990D00') AS "DESCONTO CONCEDIDO TOTAL",
		TO_CHAR(cdb.cbdo_vldocumento,'999999999999990D00') AS "VALOR FINAL",
		TO_CHAR(cdb.cbdo_dtvalidade,'dd/MM/YYYY') AS "VENCIMENTO A VISTA",
		TO_CHAR(COALESCE(pag.pgmt_dtpagamento,pgh.pghi_dtpagamento),'dd/MM/YYYY') AS "DATA PAGAMENTO A VISTA",
		TO_CHAR(cdb.cbdo_vldocumento,'999999999999990D00') AS "VALOR PAGO A VISTA",
		COALESCE((SELECT
			STRING_AGG(cbs.cbst_dscobrancasituacao || '- ' ||TO_CHAR(ics.iscb_dtimplantacaocobranca,'dd/MM/YYYY'),';')
		FROM
			cadastro.imovel_cobranca_situacao ics
			INNER JOIN cobranca.cobranca_situacao cbs ON cbs.cbst_id = ics.cbst_id
		WHERE
			ics.iscb_dtretiradacobranca IS NULL
			AND cbs.cbst_id IN (12,14,17,24,25,26)
			AND ics.imov_id = imo.imov_id),'') AS "SIT COBRANCA",
		TO_CHAR(COALESCE(cdb.cbdo_vlacrescimos,0),'999999999999990D00') AS "VALOR JUROS E MULTAS",
		cli.clie_id AS "ID CLIENTE TITULAR DO IMOVEL",
		cli.clie_nmcliente AS "NOME DO CLIENTE RESPOSÁVEL",
		CASE
		    WHEN cli.clie_nncpf IS NOT NULL THEN
			CONCAT(SUBSTRING(cli.clie_nncpf,1,3),'.',SUBSTRING(cli.clie_nncpf,4,3),'.',SUBSTRING(cli.clie_nncpf,7,3),'-',SUBSTRING(cli.clie_nncpf,10,2))
		    WHEN cli.clie_nncnpj IS NOT NULL THEN
			CONCAT(SUBSTRING(cli.clie_nncnpj, 1, 2),'.',SUBSTRING(cli.clie_nncnpj,3,3),'.',SUBSTRING(cli.clie_nncnpj,6,3),'/',SUBSTRING(cli.clie_nncnpj,9,4),'-',SUBSTRING(cli.clie_nncnpj, 13, 2))
		ELSE
			''
		END AS "DOCUMENTO CLIENTE TITULAR",
		cli.clie_id AS "ID CLIENTE RESPONSAVEL DO PARCELAMENTO",
		cli.clie_nmcliente AS "NOME DO CLIENTE RESPOSÁVEL",
		TO_CHAR(0,'999G999G990D00') AS "VALOR PAGO PARCELAS",
		0 AS "QTD PARCELAS PAGAS",
		TO_CHAR(con_atraso.valor,'999999999999990D00') AS "VALOR ATRASO",
		con_atraso.qtd AS "QTD CONTAS ATRASO",
		con_atraso.min AS "MENOR REF ATRASO",
		con_atraso.max AS "MAIOR REF ATRASO"
	FROM
		cobranca.cobranca_documento cdb
		INNER JOIN cadastro.imovel imo ON cdb.imov_id = imo.imov_id
		INNER JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
		INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
		LEFT JOIN cadastro.categoria cat ON cat.catg_id = imo.imov_idcategoriaprincipal
		LEFT JOIN seguranca.usuario usu ON usu.usur_id = cdb.usur_id
		LEFT JOIN cadastro.unidade_organizacional uno ON uno.unid_id = usu.unid_id
		LEFT JOIN arrecadacao.pagamento pag ON pag.cbdo_id = cdb.cbdo_id
		LEFT JOIN arrecadacao.pagamento_historico pgh ON pgh.cbdo_id = cdb.cbdo_id
		LEFT JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
		LEFT JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
		LEFT JOIN atendimentopublico.registro_atendimento rat ON rat.imov_id = cdb.imov_id
		LEFT JOIN atendimentopublico.ra_anexo anx ON anx.rgat_id = rat.rgat_id
		LEFT JOIN
			(SELECT
				con4.imov_id AS mat1,
				MIN(con4.cnta_amreferenciaconta) AS min,
				MAX(con4.cnta_amreferenciaconta) AS max,
				COUNT(con4.cnta_id) AS qtd,
				SUM(con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos) AS valor
			FROM
				faturamento.conta con4
				WHERE
					con4.dcst_idatual IN (0,1,2,5) AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con4.cnta_id) AND con4.cnta_dtvencimentoconta > '2023-01-01' AND con4.cnta_dtvencimentoconta < CURRENT_DATE AND con4.cnta_dtrevisao IS NULL AND con4.iper_id <> 6
				GROUP BY 1) AS con_atraso ON con_atraso.mat1 = imo.imov_id
	WHERE
		cdb.rdir_id = 48 AND
		COALESCE(pag.pgmt_vlpagamento,pgh.pghi_vlpagamento)>0 
	GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,imo.imov_id,cdb.cbdo_vlacrescimos,cli.clie_id,con_atraso.valor,con_atraso.qtd,con_atraso.min,con_atraso.max
UNION
	SELECT
		'A VISTA' AS "MODALIDADE",
		COALESCE((
			SELECT
				mes.meso_dsmeiosolicitacao
			FROM
				atendimentopublico.meio_solicitacao mes
				INNER JOIN atendimentopublico.registro_atendimento ra ON ra.meso_id = mes.meso_id
				INNER JOIN atendimentopublico.atend_motivo_encmt ate ON ate.amen_id = ra.amen_id
			WHERE
				ra.imov_id = imo.imov_id
				AND ra.step_id = 1062
				AND ra.rgat_tmregistroatendimento >= CURRENT_DATE - INTERVAL '7days'
				AND ate.amen_icexecucao = 1
			ORDER BY ra.rgat_tmregistroatendimento DESC
			LIMIT 1
		),
		(
			SELECT
				mes.meso_dsmeiosolicitacao
			FROM
				atendimentopublico.meio_solicitacao mes
				INNER JOIN atendimentopublico.registro_atendimento ra ON ra.meso_id = mes.meso_id
				INNER JOIN atendimentopublico.atend_motivo_encmt ate ON ate.amen_id = ra.amen_id
			WHERE
				ra.imov_id = imo.imov_id
				AND ra.step_id = 977
				AND ra.rgat_tmregistroatendimento >= CURRENT_DATE - INTERVAL '7days'
				AND ate.amen_icexecucao = 1
			ORDER BY ra.rgat_tmregistroatendimento DESC
			LIMIT 1
		),'BALCAO') AS "MEIO SOLICITACAO",
		cdb.imov_id AS "MATRICULA",
		TO_CHAR(imo.imov_nncoordenadax,'990D999999999999999') AS "LATITUDE",
		TO_CHAR(imo.imov_nncoordenaday,'990D999999999999999') AS "LONGITUDE",
/*		CASE 
		    WHEN anx.raan_imdocumento IS NOT NULL THEN
		    'COM ANEXO'
		 ELSE
		    'SEM ANEXO' 
		 END AS "ANEXO",*/
		cat.catg_dscategoria AS "CATEGORIA",
		loc.uneg_id AS "GERENCIA",
		une.uneg_nmunidadenegocio AS "NOME UNIDADE",
		imo.loca_id AS "LOCALIDADE",
		loc.loca_nmlocalidade AS "NOME LOCALIDADE",
		usu.usur_nmlogin AS "LOGIN",
		usu.usur_nmusuario AS "NOME USUARIO",
		uno.unid_dsunidade AS "UNIDADE ORG",
		TO_CHAR(cdb.cbdo_tmemissao,'dd/MM/YYYY') AS "DATA OPCAO",
		TO_CHAR(cdb.cbdo_tmemissao,'hh24:mi') AS "HORARIO OPCAO",
		TO_CHAR(cdb.cbdo_tmemissao,'hh24') AS "HORA DO DIA OPCAO",
		TO_CHAR((cdb.cbdo_vldocumento+cdb.cbdo_vldesconto),'999999999999990D00') AS "VALOR DEBITO",
		TO_CHAR(0,'999999999999990D00') AS "VALOR ENTRADA",
		'' AS "VENCIMENTO ENTRADA",
		'' AS "DATA PAGAMENTO ENTRADA",
		TO_CHAR(0,'999999999999990D00') AS "VALOR PAGO ENTRADA",
		0 AS "PARCELAS",
		TO_CHAR(0,'999999999999990D00') AS "VALOR PARCELA",
		TO_CHAR(0,'999999999999990D00') AS "VL FINANCIADO TOTAL",
		TO_CHAR(cdb.cbdo_vldesconto,'999999999999990D00') AS "DESCONTO CONCEDIDO TOTAL",
		TO_CHAR(cdb.cbdo_vldocumento,'999999999999990D00') AS "VALOR FINAL",
		TO_CHAR(cdb.cbdo_dtvalidade,'dd/MM/YYYY') AS "VENCIMENTO A VISTA",
		'' AS "DATA PAGAMENTO A VISTA",
		TO_CHAR(0,'999999999999990D00') AS "VALOR PAGO A VISTA",
		COALESCE((SELECT
			STRING_AGG(cbs.cbst_dscobrancasituacao || '- ' ||TO_CHAR(ics.iscb_dtimplantacaocobranca,'dd/MM/YYYY'),';')
		FROM
			cadastro.imovel_cobranca_situacao ics
			INNER JOIN cobranca.cobranca_situacao cbs ON cbs.cbst_id = ics.cbst_id
		WHERE
			ics.iscb_dtretiradacobranca IS NULL
			AND cbs.cbst_id IN (12,14,17,24,25,26)
			AND ics.imov_id = imo.imov_id),'') AS "SIT COBRANCA",
		TO_CHAR(COALESCE(cdb.cbdo_vlacrescimos,0),'999999999999990D00') AS "VALOR JUROS E MULTAS",
		cli.clie_id AS "ID CLIENTE TITULAR DO IMOVEL",
		cli.clie_nmcliente AS "NOME DO CLIENTE RESPOSÁVEL",
		CASE
		    WHEN cli.clie_nncpf IS NOT NULL THEN
			CONCAT(SUBSTRING(cli.clie_nncpf,1,3),'.',SUBSTRING(cli.clie_nncpf,4,3),'.',SUBSTRING(cli.clie_nncpf,7,3),'-',SUBSTRING(cli.clie_nncpf,10,2))
		    WHEN cli.clie_nncnpj IS NOT NULL THEN
			CONCAT(SUBSTRING(cli.clie_nncnpj, 1, 2),'.',SUBSTRING(cli.clie_nncnpj,3,3),'.',SUBSTRING(cli.clie_nncnpj,6,3),'/',SUBSTRING(cli.clie_nncnpj,9,4),'-',SUBSTRING(cli.clie_nncnpj, 13, 2))
		ELSE
			''
		END AS "DOCUMENTO CLIENTE TITULAR",
		cli.clie_id AS "ID CLIENTE RESPONSAVEL DO PARCELAMENTO",
		cli.clie_nmcliente AS "NOME DO CLIENTE RESPOSÁVEL",
		TO_CHAR(0,'999G999G990D00') AS "VALOR PAGO PARCELAS",
		0 AS "QTD PARCELAS PAGAS",
		TO_CHAR(0,'999999999999990D00') AS "VALOR ATRASO",
		0 AS "QTD CONTAS ATRASO",
		0 AS "MENOR REF ATRASO",
		0 AS "MAIOR REF ATRASO"
	FROM
		cobranca.cobranca_documento cdb
		INNER JOIN cadastro.imovel imo ON cdb.imov_id = imo.imov_id
		INNER JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
		INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
		LEFT JOIN cadastro.categoria cat ON cat.catg_id = imo.imov_idcategoriaprincipal
		LEFT JOIN seguranca.usuario usu ON usu.usur_id = cdb.usur_id
		LEFT JOIN cadastro.unidade_organizacional uno ON uno.unid_id = usu.unid_id
		LEFT JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
		LEFT JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
		LEFT JOIN atendimentopublico.registro_atendimento rat ON rat.imov_id = cdb.imov_id
		LEFT JOIN atendimentopublico.ra_anexo anx ON anx.rgat_id = rat.rgat_id	
	WHERE
		cdb.rdir_id = 48
		AND NOT EXISTS (
			SELECT 
				cdb_pago.cbdo_id
			FROM
				cobranca.cobranca_documento cdb_pago
				LEFT JOIN arrecadacao.pagamento pag ON pag.cbdo_id = cdb_pago.cbdo_id
				LEFT JOIN arrecadacao.pagamento_historico pgh ON pgh.cbdo_id = cdb_pago.cbdo_id
			
			WHERE
				COALESCE(pag.pgmt_vlpagamento,pgh.pghi_vlpagamento,0)>0
				AND cdb_pago.imov_id = cdb.imov_id
				AND cdb_pago.rdir_id = cdb.rdir_id 
				AND TO_CHAR(cdb_pago.cbdo_tmemissao,'dd/MM/YYYY') = TO_CHAR(cdb.cbdo_tmemissao,'dd/MM/YYYY')
		)
		AND cdb.cbdo_id = (
			SELECT 
				MAX(cdb2.cbdo_id) 
			FROM 
				cobranca.cobranca_documento cdb2
				LEFT JOIN arrecadacao.pagamento pag ON pag.cbdo_id = cdb2.cbdo_id
				LEFT JOIN arrecadacao.pagamento_historico pgh ON pgh.cbdo_id = cdb2.cbdo_id
			WHERE 
				cdb2.imov_id  = cdb.imov_id 
				AND COALESCE(pag.pgmt_vlpagamento,pgh.pghi_vlpagamento,0)=0
				AND cdb2.rdir_id = cdb.rdir_id 
				AND TO_CHAR(cdb2.cbdo_tmemissao,'dd/MM/YYYY') = TO_CHAR(cdb.cbdo_tmemissao,'dd/MM/YYYY')
		)
		AND NOT EXISTS (SELECT * FROM cobranca.parcelamento par WHERE par.imov_id = cdb.imov_id AND par.rdir_id = 48 AND par.pcst_id = 1)
	GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,imo.imov_id,cdb.cbdo_vlacrescimos,cli.clie_id
UNION
	SELECT
		'ISENCAO' AS "MODALIDADE",
		COALESCE((
			SELECT
				mes.meso_dsmeiosolicitacao
			FROM
				atendimentopublico.meio_solicitacao mes
				INNER JOIN atendimentopublico.registro_atendimento ra ON ra.meso_id = mes.meso_id
				INNER JOIN atendimentopublico.atend_motivo_encmt ate ON ate.amen_id = ra.amen_id
			WHERE
				ra.imov_id = imo.imov_id
				AND ra.step_id = 1062
				AND ra.rgat_tmregistroatendimento >= CURRENT_DATE - INTERVAL '7days'
				AND ate.amen_icexecucao = 1
			ORDER BY ra.rgat_tmregistroatendimento DESC
			LIMIT 1
		),
(
			SELECT
				mes.meso_dsmeiosolicitacao
			FROM
				atendimentopublico.meio_solicitacao mes
				INNER JOIN atendimentopublico.registro_atendimento ra ON ra.meso_id = mes.meso_id
				INNER JOIN atendimentopublico.atend_motivo_encmt ate ON ate.amen_id = ra.amen_id
			WHERE
				ra.imov_id = imo.imov_id
				AND ra.step_id = 977
				AND ra.rgat_tmregistroatendimento >= CURRENT_DATE - INTERVAL '7days'
				AND ate.amen_icexecucao = 1
			ORDER BY ra.rgat_tmregistroatendimento DESC
			LIMIT 1
		),'BALCAO') AS "MEIO SOLICITACAO",
		con.imov_id AS "MATRICULA",
		TO_CHAR(imo.imov_nncoordenadax,'990D999999999999999') AS "LATITUDE",
		TO_CHAR(imo.imov_nncoordenaday,'990D999999999999999') AS "LONGITUDE",
		cat.catg_dscategoria AS "CATEGORIA",
		loc.uneg_id AS "GERENCIA",
		une.uneg_nmunidadenegocio AS "NOME UNIDADE",
		imo.loca_id AS "LOCALIDADE",
		loc.loca_nmlocalidade AS "NOME LOCALIDADE",
		usu.usur_nmlogin AS "LOGIN",
		usu.usur_nmusuario AS "NOME USUARIO",
		uno.unid_dsunidade AS "UNIDADE ORG",
		TO_CHAR(MAX(con.cnta_dtrevisao),'dd/MM/YYYY') AS "DATA OPCAO",
		TO_CHAR(MAX(con.cnta_tmultimaalteracao), 'hh24:mi') AS "HORARIO OPCAO",
		TO_CHAR(MAX(con.cnta_tmultimaalteracao), 'hh24') AS "HORA DO DIA OPCAO",
		TO_CHAR(SUM((con.cnta_vlagua+con.cnta_vlesgoto+con.cnta_vldebitos-con.cnta_vlcreditos-con.cnta_vlimpostos)),'999999999999990D00') AS "VALOR DEBITO",
		TO_CHAR(0,'999999999999990D00') AS "VALOR ENTRADA",
		'' AS "VENCIMENTO ENTRADA",
		'' AS "DATA PAGAMENTO ENTRADA",
		TO_CHAR(0,'999999999999990D00') AS "VALOR PAGO ENTRADA",
		0 AS "PARCELAS",
		TO_CHAR(0,'999999999999990D00') AS "VALOR PARCELA",
		TO_CHAR(0,'999999999999990D00') AS "VL FINANCIADO TOTAL",
		TO_CHAR(SUM((con.cnta_vlagua+con.cnta_vlesgoto+con.cnta_vldebitos-con.cnta_vlcreditos-con.cnta_vlimpostos)),'999999999999990D00') AS "DESCONTO CONCEDIDO TOTAL",
		TO_CHAR(0,'999999999999990D00') AS "VALOR FINAL",
		'' AS "VENCIMENTO A VISTA",
		'' AS "DATA PAGAMENTO A VISTA",
		TO_CHAR(0,'999999999999990D00') AS "VALOR PAGO A VISTA",
		COALESCE((SELECT
			STRING_AGG(cbs.cbst_dscobrancasituacao || '- ' ||TO_CHAR(ics.iscb_dtimplantacaocobranca,'dd/MM/YYYY'),';')
		FROM
			cadastro.imovel_cobranca_situacao ics
			INNER JOIN cobranca.cobranca_situacao cbs ON cbs.cbst_id = ics.cbst_id
		WHERE
			ics.iscb_dtretiradacobranca IS NULL
			AND cbs.cbst_id IN (12,14,17,24,25,26)
			AND ics.imov_id = imo.imov_id),'') AS "SIT COBRANCA",
		TO_CHAR(
			COALESCE((SELECT 
				SUM(TRUNC(((con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos)*0.02)::NUMERIC,2)) +
				SUM(TRUNC(((con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos)*0.005*(((EXTRACT(YEAR FROM con4.cnta_dtrevisao::DATE)-EXTRACT(YEAR FROM con4.cnta_dtvencimentoconta))*12)+(EXTRACT(MONTH FROM con4.cnta_dtrevisao::DATE)-EXTRACT(MONTH FROM con4.cnta_dtvencimentoconta))))::NUMERIC, 2))
			FROM
				faturamento.conta con4
			WHERE
				con4.imov_id = imo.imov_id
				AND con4.cmrv_id = 116
				AND con4.cnta_dtvencimentoconta < con4.cnta_dtrevisao
			),0),'999999999999990D00') AS "VALOR JUROS E MULTAS",
		cli.clie_id AS "ID CLIENTE TITULAR DO IMOVEL",
		cli.clie_nmcliente AS "NOME DO CLIENTE RESPOSÁVEL",
		CASE
		    WHEN cli.clie_nncpf IS NOT NULL THEN
			CONCAT(SUBSTRING(cli.clie_nncpf,1,3),'.',SUBSTRING(cli.clie_nncpf,4,3),'.',SUBSTRING(cli.clie_nncpf,7,3),'-',SUBSTRING(cli.clie_nncpf,10,2))
		    WHEN cli.clie_nncnpj IS NOT NULL THEN
			CONCAT(SUBSTRING(cli.clie_nncnpj, 1, 2),'.',SUBSTRING(cli.clie_nncnpj,3,3),'.',SUBSTRING(cli.clie_nncnpj,6,3),'/',SUBSTRING(cli.clie_nncnpj,9,4),'-',SUBSTRING(cli.clie_nncnpj, 13, 2))
		ELSE
			''
		END AS "DOCUMENTO CLIENTE TITULAR",
		cli.clie_id AS "ID CLIENTE RESPONSAVEL DO PARCELAMENTO",
		cli.clie_nmcliente AS "NOME DO CLIENTE RESPOSÁVEL",
		TO_CHAR(0,'999G999G990D00') AS "VALOR PAGO PARCELAS",
		0 AS "QTD PARCELAS PAGAS",
		TO_CHAR(con_atraso.valor,'999999999999990D00') AS "VALOR ATRASO",
		con_atraso.qtd AS "QTD CONTAS ATRASO",
		con_atraso.min AS "MENOR REF ATRASO",
		con_atraso.max AS "MAIOR REF ATRASO"
	FROM
		faturamento.conta con
		INNER JOIN cadastro.imovel imo ON imo.imov_id = con.imov_id
		INNER JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
		INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
		LEFT JOIN cadastro.categoria cat ON cat.catg_id = imo.imov_idcategoriaprincipal
		LEFT JOIN seguranca.usuario usu ON usu.usur_id = con.usur_id
		LEFT JOIN cadastro.unidade_organizacional uno ON uno.unid_id = usu.unid_id
		LEFT JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
		LEFT JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
		LEFT JOIN atendimentopublico.registro_atendimento rat ON rat.imov_id = con.imov_id
		LEFT JOIN atendimentopublico.ra_anexo anx ON anx.rgat_id = rat.rgat_id
		LEFT JOIN
			(SELECT
				con4.imov_id AS mat1,
				MIN(con4.cnta_amreferenciaconta) AS min,
				MAX(con4.cnta_amreferenciaconta) AS max,
				COUNT(con4.cnta_id) AS qtd,
				SUM(con4.cnta_vlagua+con4.cnta_vlesgoto+con4.cnta_vldebitos-con4.cnta_vlcreditos-con4.cnta_vlimpostos) AS valor
			FROM
				faturamento.conta con4
				WHERE
					con4.dcst_idatual IN (0,1,2,5) AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con4.cnta_id) AND con4.cnta_dtvencimentoconta > '2023-01-01' AND con4.cnta_dtvencimentoconta < CURRENT_DATE AND con4.cnta_dtrevisao IS NULL AND con4.iper_id <> 6
				GROUP BY 1) AS con_atraso ON con_atraso.mat1 = imo.imov_id
	WHERE
		con.cmrv_id = 116
	GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,imo.imov_id,cli.clie_id,con_atraso.valor,con_atraso.qtd,con_atraso.min,con_atraso.max