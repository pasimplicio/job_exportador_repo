--VAR_ARRECADACAO: Deve ser substituida pela referencia do faturamento que se deseja obter os dados
--11,12,13,14,15: Deve ser substituida pelo id da unidade de onde se quer obter os dados

SELECT 
	(imo.loca_id::TEXT || '-' || sec.stcm_cdsetorcomercial::TEXT || '-' || rot.rota_cdrota::TEXT) AS "LOCALIZACAO",
	imo.imov_id AS "MATRICULA",
	imo.imov_nncoordenadax AS "LATITUDE",
	imo.imov_nncoordenaday AS "LONGITUDE",
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
	sex.psex_dspessoasexo AS "SEXO",
	cim.clim_dtrelacaoinicio AS "INICIO DA RELACAO",
	cli2.clie_id AS "COD RESP",
	cli2.clie_nmcliente AS "NOME RESP",
	cli2.clie_nncpf AS "CPF RESP",
	cli2.clie_nncnpj AS "CNPJ RESP",
	cli3.clie_id AS "COD PAI",
	cli3.clie_nmcliente AS "NOME PAI",
	cli3.clie_nncpf AS "CPF PAI",
	cli3.clie_nncnpj AS "CNPJ PAI",
	imo.iper_id AS "PERFIL",
	(CASE imo.imov_idcategoriaprincipal 
	WHEN 1 THEN '1 - RESIDENCIAL'
	WHEN 2 THEN '2 - COMERCIAL'
	WHEN 3 THEN '3 - INDUSTRIAL'
	WHEN 4 THEN '4 - PUBLICO'
	ELSE 'NAO DEFINIDO'
	END) AS "CATEGORIA PRINCIPAL",
	(CASE imo.imov_idsubcategoriaprincipal 
	WHEN 1 THEN '1 - RESIDENCIAL'
	WHEN 2 THEN '2 - COMERCIAL'
	WHEN 3 THEN '3 - INDUSTRIAL'
	WHEN 4 THEN '4 - MUNICIPAL'
	WHEN 5 THEN '5 - ESTADUAL'
	WHEN 6 THEN '6 - FEDERAL'
	WHEN 7 THEN '7 - RES. POPULAR'
	WHEN 8 THEN '8 - PEQ. NEGOCIOS'
	WHEN 9 THEN '9 - ENT. FILANTROPICAS'
	WHEN 10 THEN '10 - SIST. OPERADO POR PREFEITURA'
	ELSE 'NAO DEFINIDO'
	END) AS "SUBCATEGORIA PRINCIPAL",
	imo.imov_qteconomia AS "ECONOMIAS",
	ftb.ftab_dsfonteabastecimento AS "ABASTECIMENTO",
	dis.diop_dsdistritooperacional AS "DISTR OPERACIONAL",
	loc.uneg_id AS "GERENCIA",
	une.uneg_nmunidadenegocio AS "NOME UNIDADE",
	imo.loca_id AS "LOCALIDADE",
	loc.loca_nmlocalidade AS "NOME LOCALIDADE",
	sec.stcm_cdsetorcomercial AS "SETOR COMERCIAL",
	qdr.qdra_nnquadra AS "QUADRA",
	imo.imov_nnsequencialrota AS "SEQUENCIA",
	imo.imov_nnsublote AS "SUB LOTE",
	rot.rota_cdrota AS "ROTA",
	ftg.ftgr_dsfaturamentogrupo AS "GRUPO FATURAMENTO",
	lgt.lgtp_dslogradourotipo AS "TIPO LOGRADOURO",
	logr.logr_nmlogradouro AS "NOME LOGRADOURO",
	cep.cep_cdcep AS "CEP",
	imo.imov_dscomplementoendereco AS "COMPLEMENTO",
	bai.bair_nmbairro AS "BAIRRO",
	imo.imov_nnimovel AS "NR",
	mun.muni_nmmunicipio AS "MUNICIPIO",
	imo.last_id AS "ID SIT. AGUA",
	las.last_dsligacaoaguasituacao AS "SITUACAO AGUA",
	lgd.lagd_dsligacaoaguadiametro AS "DIAMETRO LIG AGUA",
	lagu.lagu_dtimplantacao AS "DT. IMPLANTACAO",
	lagu.lagu_dtligacaoagua AS "DT. LIGACAO",
	lagu.lagu_dtcorte AS "DT. CORTE",
	lagu.lagu_dtreligacaoagua AS "DT. RELIGACAO",
	lagu.lagu_dtsupressaoagua AS "DT. SUPRESSAO",
	imo.lest_id AS "ID SIT. ESG",
	les.lest_dsligacaoesgotosituacao AS "SITUACAO ESGOTO",
	imo.imov_nnareaconstruida AS "AREA",
	CAST(fat.ftst_id  AS TEXT) || ' - ' || fat.ftst_dsfaturamentosituacaotipo AS "SIT. FATURAMENTO",
	fsh.ftsh_amfatmtsitinicio AS "INICIO",
	fsh.ftsh_amfaturamentosituacaofim AS "FIM",
	ftm.ftsm_dsfatsitmotivo AS "MOTIVO",
	cst.cbsp_id AS "COD SIT.",
	CAST(cst.cbsp_id AS TEXT) || ' - ' || cst.cbsp_dscobrancasituacaotipo AS "SIT. ESPECIAL DE COBRANCA",
	csh.cbsh_amcobrancasituacaoinicio AS "INICIO",
	csh.cbsh_amcobrancasituacaofim AS "FIM",
	csm.cbsm_dscobrancasituacaomotivo AS "MOTIVO",
	csh.cbsh_dsobservacaoinforma AS "OBS",
	hid.hidr_nnhidrometro AS "NR HID.",
	hid.hidr_nnanofabricacao AS "ANO HD",
	his.hidi_dtinstalacaohidrometro AS "DATA DE INSTALACAO HD.",
	hic.hicp_dshidrometrocapacidade AS "CAPACIDADE HD",
	hdi.hidm_dshidrometrodiametro AS "DIAMETRO HD",
	cob.cbst_dscobrancasituacao AS "SIT. COBRANCA",
	ics.iscb_dtimplantacaocobranca AS "DATA DE ENTRADA COBRANCA",
	cob_exi.cbst_dscobrancasituacao AS "SIT. COBRANCA",
	ics_exi.iscb_dtimplantacaocobranca AS "DATA DE ENTRADA COBRANCA",
	--TO_CHAR(ult_alt_cli.ult_alt, 'DD/MM/YYYY')
	TO_CHAR((
			SELECT
				MIN(opf.opef_tmultimaalteracao) AS ult_alt
			FROM
				seguranca.tabela_linha_alteracao tbl
				INNER JOIN seguranca.operacao_efetuada opf ON opf.opef_id = tbl.tref_id
				INNER JOIN seguranca.tab_linha_col_alteracao tbc ON tbl.tbla_id = tbc.tbla_id
			WHERE
				--tbl.tabe_id = 60
				--tbc.tbca_cncolunaanterior <> tbc.tbca_cncolunaatual
				--AND 
				tbc.tbco_id IN (271, 272, 275, 276, 701, 60, 4796, 23848, 23850, 1527, 1529, 1531, 1539, 2524, 2525, 2526, 2527, 2529)
				--AND tbc.tbca_tmultimaalteracao >= (CURRENT_DATE::TIMESTAMP)
				--AND usu.usur_nmlogin = 'YGOR'
				AND opf.opef_cnargumento = cli.clie_id
	),'DD/MM/YYYY') AS "ULTIMA ALTERACAO CADASTRO",
	TO_CHAR(COALESCE(pags_ano_passado.valor,0), '999G999G990D00') AS "VALOR PAGO 202001",
	COALESCE(pags_ano_passado.qtd,0) AS "QTD DOC PAGOS 202001",
	TO_CHAR(COALESCE(pags_ult.valor,0), '999G999G990D00') AS "VALOR PAGO VAR_ARRECADACAO",
	COALESCE(pags_ult.qtd, 0) AS "QTD DOC PAGOS VAR_ARRECADACAO",
	TO_CHAR(COALESCE(pags_pen.valor,0), '999G999G990D00') AS "VALOR PAGO VAR_ARRECADACAO - 1",
	COALESCE(pags_pen.qtd,0) AS "QTD DOC PAGOS VAR_ARRECADACAO - 1",
	TO_CHAR(COALESCE(pags_ant.valor,0), '999G999G990D00') AS "VALOR PAGO VAR_ARRECADACAO - 2",
	COALESCE(pags_ant.qtd,0) AS "QTD DOC PAGOS VAR_ARRECADACAO - 2"
FROM 
	cadastro.imovel imo
	INNER JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
	INNER JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
	INNER JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
	INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
	INNER JOIN cadastro.setor_comercial sec ON imo.stcm_id = sec.stcm_id
	INNER JOIN cadastro.quadra qdr ON qdr.qdra_id = imo.qdra_id
	INNER JOIN micromedicao.rota rot ON rot.rota_id = qdr.rota_id
	INNER JOIN faturamento.faturamento_grupo ftg ON rot.ftgr_id = ftg.ftgr_id
	INNER JOIN cadastro.logradouro_bairro lgb ON lgb.lgbr_id = imo.lgbr_id
	INNER JOIN cadastro.logradouro logr ON lgb.logr_id = logr.logr_id
	INNER JOIN cadastro.bairro bai ON bai.bair_id = lgb.bair_id
	INNER JOIN cadastro.municipio mun ON mun.muni_id = bai.muni_id
	INNER JOIN cadastro.fonte_abastecimento ftb ON ftb.ftab_id = imo.ftab_id
	INNER JOIN atendimentopublico.ligacao_agua_situacao las ON las.last_id = imo.last_id
	INNER JOIN atendimentopublico.ligacao_esgoto_situacao les ON les.lest_id = imo.lest_id
	LEFT JOIN cadastro.pessoa_sexo sex ON sex.psex_id = cli.psex_id
	LEFT JOIN operacional.distrito_operacional dis ON dis.diop_id = qdr.diop_id
	LEFT JOIN cadastro.cliente_imovel cim2 ON cim2.imov_id = imo.imov_id AND cim2.clim_dtrelacaofim IS NULL AND cim2.crtp_id  = 3
	LEFT JOIN cadastro.cliente cli2 ON cli2.clie_id = cim2.clie_id
	LEFT JOIN cadastro.cliente cli3 ON cli3.clie_id = cli2.clie_cdclienteresponsavel
	LEFT JOIN cadastro.logradouro_cep lgc ON lgc.lgcp_id = imo.lgcp_id
	LEFT JOIN cadastro.cep cep ON cep.cep_id = lgc.cep_id
	LEFT JOIN cadastro.logradouro_tipo lgt ON lgt.lgtp_id = logr.lgtp_id
	LEFT JOIN faturamento.fatur_situacao_hist fsh ON fsh.imov_id = imo.imov_id AND fsh.ftsh_amfaturamentoretirada IS NULL
	LEFT JOIN faturamento.fatur_situacao_tipo fat ON fat.ftst_id = fsh.ftst_id
	LEFT JOIN faturamento.fatur_situacao_motivo ftm ON fsh.ftsm_id = ftm.ftsm_id
	LEFT JOIN atendimentopublico.ligacao_agua lagu ON lagu.lagu_id = imo.imov_id
	LEFT JOIN atendimentopublico.ligacao_agua_diametro lgd ON lgd.lagd_id = lagu.lagd_id
	LEFT JOIN micromedicao.hidrometro_inst_hist his ON lagu.hidi_id = his.hidi_id AND his.hidi_dtretiradahidrometro IS NULL
	LEFT JOIN micromedicao.hidrometro hid ON his.hidr_id = hid.hidr_id
	LEFT JOIN micromedicao.hidrometro_capacidade hic ON hic.hicp_id = hid.hicp_id
	LEFT JOIN micromedicao.hidrometro_diametro hdi ON hdi.hidm_id = hid.hidm_id
	LEFT JOIN micromedicao.hidrometro_marca hma ON hma.himc_id = hid.himc_id
	LEFT JOIN cadastro.imovel_cobranca_situacao ics ON ics.imov_id = imo.imov_id AND ics.iscb_dtretiradacobranca IS NULL AND ics.cbst_id IN (12,14,17)
	LEFT JOIN cadastro.imovel_cobranca_situacao ics_exi ON ics_exi.imov_id = imo.imov_id AND ics_exi.iscb_dtretiradacobranca IS NULL AND ics_exi.cbst_id = 23
	LEFT JOIN cobranca.cobranca_situacao cob ON cob.cbst_id = ics.cbst_id 
	LEFT JOIN cobranca.cobranca_situacao cob_exi ON cob_exi.cbst_id = ics_exi.cbst_id 
	LEFT JOIN cobranca.cobranca_situacao_hist csh ON csh.imov_id = imo.imov_id AND csh.cbsh_amcobrancaretirada IS NULL
	LEFT JOIN cobranca.cobranca_situacao_tipo cst ON csh.cbsp_id = cst.cbsp_id
	LEFT JOIN cobranca.cobranca_situacao_motivo csm ON csm.cbsm_id = csh.cbsm_id
	LEFT JOIN(
			SELECT
				pags.imov_id AS imov_id,
				SUM(pags.qtd) AS qtd,
				SUM(pags.valor) AS valor
			FROM		
				(SELECT 
						pag.imov_id AS imov_id,
						COUNT(pag.pgmt_id) AS qtd,
						SUM(pag.pgmt_vlpagamento) AS valor
					FROM
						arrecadacao.pagamento pag
						INNER JOIN cadastro.localidade loc ON loc.loca_id = pag.loca_id AND loc.uneg_id IN (11,12,13,14,15)
					WHERE
						pag.pgst_idatual IN (0,1)
						AND pag.pgmt_amreferenciaarrecadacao = VAR_ARRECADACAO - 100
					GROUP BY 1
				UNION
					SELECT 
						pag.imov_id AS imov_id,
						COUNT(pag.pghi_id) AS qtd,
						SUM(pag.pghi_vlpagamento) AS valor
					FROM
						arrecadacao.pagamento_historico pag
						INNER JOIN cadastro.localidade loc ON loc.loca_id = pag.loca_id AND loc.uneg_id IN (11,12,13,14,15)
					WHERE
						pag.pgst_idatual IN (0,1)
						AND pag.pghi_amreferenciaarrecadacao = VAR_ARRECADACAO - 100
					GROUP BY 1) pags
			GROUP BY 1
		) AS pags_ano_passado ON pags_ano_passado.imov_id = imo.imov_id
	LEFT JOIN(
			SELECT
				pags.imov_id AS imov_id,
				SUM(pags.qtd) AS qtd,
				SUM(pags.valor) AS valor
			FROM		
				(SELECT 
						pag.imov_id AS imov_id,
						COUNT(pag.pgmt_id) AS qtd,
						SUM(pag.pgmt_vlpagamento) AS valor
					FROM
						arrecadacao.pagamento pag
						INNER JOIN cadastro.localidade loc ON loc.loca_id = pag.loca_id AND loc.uneg_id IN (11,12,13,14,15)
					WHERE
						pag.pgst_idatual IN (0,1)
						AND pag.pgmt_amreferenciaarrecadacao = VAR_ARRECADACAO
					GROUP BY 1
				UNION
					SELECT 
						pag.imov_id AS imov_id,
						COUNT(pag.pghi_id) AS qtd,
						SUM(pag.pghi_vlpagamento) AS valor
					FROM
						arrecadacao.pagamento_historico pag
						INNER JOIN cadastro.localidade loc ON loc.loca_id = pag.loca_id AND loc.uneg_id IN (11,12,13,14,15)
					WHERE
						pag.pgst_idatual IN (0,1)
						AND pag.pghi_amreferenciaarrecadacao = VAR_ARRECADACAO
					GROUP BY 1) pags
			GROUP BY 1
		) AS pags_ult ON pags_ult.imov_id = imo.imov_id
	LEFT JOIN (
			SELECT
				pags.imov_id AS imov_id,
				SUM(pags.qtd) AS qtd,
				SUM(pags.valor) AS valor
			FROM		
				(SELECT 
						pag.imov_id AS imov_id,
						COUNT(pag.pgmt_id) AS qtd,
						SUM(pag.pgmt_vlpagamento) AS valor
					FROM
						arrecadacao.pagamento pag
						INNER JOIN cadastro.localidade loc ON loc.loca_id = pag.loca_id AND loc.uneg_id IN (11,12,13,14,15)
					WHERE
						pag.pgst_idatual IN (0,1)
						AND pag.pgmt_amreferenciaarrecadacao = (
								SELECT 
									CASE (CAST(SUBSTRING(CAST(VAR_ARRECADACAO AS TEXT) FROM 5 FOR 6) AS INT))
										WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(VAR_ARRECADACAO AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
										ELSE CAST(VAR_ARRECADACAO-1 AS TEXT)
									END
							)
					GROUP BY 1
				UNION
					SELECT 
						pag.imov_id AS imov_id,
						COUNT(pag.pghi_id) AS qtd,
						SUM(pag.pghi_vlpagamento) AS valor
					FROM
						arrecadacao.pagamento_historico pag
						INNER JOIN cadastro.localidade loc ON loc.loca_id = pag.loca_id AND loc.uneg_id IN (11,12,13,14,15)
					WHERE
						pag.pgst_idatual IN (0,1)
						AND pag.pghi_amreferenciaarrecadacao = (
								SELECT 
									CASE (CAST(SUBSTRING(CAST(VAR_ARRECADACAO AS TEXT) FROM 5 FOR 6) AS INT))
										WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(VAR_ARRECADACAO AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
										ELSE CAST(VAR_ARRECADACAO-1 AS TEXT)
									END
							)
					GROUP BY 1) pags
			GROUP BY 1
		) AS pags_pen ON pags_pen.imov_id = imo.imov_id
	LEFT JOIN (
			SELECT
				pags.imov_id AS imov_id,
				SUM(pags.qtd) AS qtd,
				SUM(pags.valor) AS valor
			FROM		
				(SELECT 
						pag.imov_id AS imov_id,
						COUNT(pag.pgmt_id) AS qtd,
						SUM(pag.pgmt_vlpagamento) AS valor
					FROM
						arrecadacao.pagamento pag
						INNER JOIN cadastro.localidade loc ON loc.loca_id = pag.loca_id AND loc.uneg_id IN (11,12,13,14,15)
					WHERE
						pag.pgst_idatual IN (0,1)
						AND pag.pgmt_amreferenciaarrecadacao = (
								SELECT 
									CASE (CAST(SUBSTRING(CAST(VAR_ARRECADACAO AS TEXT) FROM 5 FOR 6) AS INT))
										WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(VAR_ARRECADACAO AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'11'
										WHEN 2 THEN CAST((CAST(SUBSTRING(CAST(VAR_ARRECADACAO AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
										ELSE CAST(VAR_ARRECADACAO-2 AS TEXT)
									END
							)
					GROUP BY 1
				UNION
					SELECT 
						pag.imov_id AS imov_id,
						COUNT(pag.pghi_id) AS qtd,
						SUM(pag.pghi_vlpagamento) AS valor
					FROM
						arrecadacao.pagamento_historico pag
						INNER JOIN cadastro.localidade loc ON loc.loca_id = pag.loca_id AND loc.uneg_id IN (11,12,13,14,15)
					WHERE
						pag.pgst_idatual IN (0,1)
						AND pag.pghi_amreferenciaarrecadacao = (
								SELECT 
									CASE (CAST(SUBSTRING(CAST(VAR_ARRECADACAO AS TEXT) FROM 5 FOR 6) AS INT))
										WHEN 1 THEN CAST((CAST(SUBSTRING(CAST(VAR_ARRECADACAO AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'11'
										WHEN 2 THEN CAST((CAST(SUBSTRING(CAST(VAR_ARRECADACAO AS TEXT) FROM 0 FOR 5) AS INT))-1 AS TEXT)||'12'
										ELSE CAST(VAR_ARRECADACAO-2 AS TEXT)
									END
							)
					GROUP BY 1) pags
			GROUP BY 1
		) AS pags_ant ON pags_ant.imov_id = imo.imov_id
WHERE
	imo.imov_icexclusao = 2
	--loc.uneg_id >= 11 AND loc.uneg_id <= 15
	 AND une.uneg_id IN (11,12,13,14,15)
	AND (pags_ano_passado.qtd > 0 OR pags_ult.qtd > 0)
	--AND imo.imov_id = 8843279
ORDER BY "LOCALIDADE","SETOR COMERCIAL","ROTA","QUADRA","SEQUENCIA","SUB LOTE"