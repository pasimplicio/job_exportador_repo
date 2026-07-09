	SELECT
		imo.imov_id AS "MATRICULA",
		imo.imov_nncoordenadax AS "LATITUDE",
		imo.imov_nncoordenaday AS "LONGITUDE",
		cli.clie_nmcliente AS "NOME",
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
		ipe.iper_dsimovelperfil AS "PERFIL",
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
		dis.diop_dsdistritooperacional AS "DISTR OPERACIONAL",
		pag.pghi_dtpagamento - con.cnhi_dtvencimentoconta AS "ATRASO",
		con.cnhi_amreferenciaconta AS "REFERENCIA",
		pag.pghi_dtpagamento AS "DATA PAGAMENTO",
		con.cnhi_dtvencimentoconta AS "VENCIMENTO",
		con.cnhi_dtvencimentooriginal AS "VENCIMENTO ORIGINAL",
		pag.pghi_dtpagamento - con.cnhi_dtvencimentooriginal AS "ATRASO VENCIMENTO ORIGINAL",
		(CASE 
		WHEN pag.pghi_dtpagamento - con.cnhi_dtvencimentoconta <= 0 THEN '01 - EM DIA'
		WHEN pag.pghi_dtpagamento - con.cnhi_dtvencimentoconta <= 5  THEN '02 - ATE 5 DIAS DE ATRASO'
		WHEN pag.pghi_dtpagamento - con.cnhi_dtvencimentoconta <= 15  THEN '03 - ATE 15 DIAS DE ATRASO'
		WHEN pag.pghi_dtpagamento - con.cnhi_dtvencimentoconta <= 30  THEN '04 - ATE 30 DIAS DE ATRASO'
		WHEN pag.pghi_dtpagamento - con.cnhi_dtvencimentoconta <= 60  THEN '05 - ATE 60 DIAS DE ATRASO'
		WHEN pag.pghi_dtpagamento - con.cnhi_dtvencimentoconta <= 90  THEN '06 - ATE 90 DIAS DE ATRASO'
		WHEN pag.pghi_dtpagamento - con.cnhi_dtvencimentoconta <= 180  THEN '07 - ATE 180 DIAS DE ATRASO'
		WHEN pag.pghi_dtpagamento - con.cnhi_dtvencimentoconta <= 365  THEN '08 - ATE 365 DIAS DE ATRASO'
		WHEN pag.pghi_dtpagamento - con.cnhi_dtvencimentoconta <= 1825  THEN '09 - ATE 5 ANOS DE ATRASO'
		WHEN pag.pghi_dtpagamento - con.cnhi_dtvencimentoconta <= 3650  THEN '10 - ATE 10 ANOS DE ATRASO'
		WHEN pag.pghi_dtpagamento - con.cnhi_dtvencimentoconta > 3650  THEN '11 - ACIMA DE 10 ANOS DE ATRASO'
		END) AS "FAIXA ATRASO",
		con.cnhi_nnconsumoagua AS "VOL AGUA",
		con.cnhi_nnconsumoesgoto AS "VOL ESGOTO",
		con.cnhi_vlagua AS "VL AGUA",
		con.cnhi_vlesgoto AS "VL ESGOTO",
		con.cnhi_vldebitos AS "VL DEBITOS",
		con.cnhi_vlcreditos AS "VL CREDITOS",
		con.cnhi_vlimpostos AS "VL IMPOSTOS",
		pag.pghi_vlpagamento AS "VALOR",
		'PAGO' AS "STATUS",
		pag.pghi_amreferenciaarrecadacao AS "REFERENCIA ARR",
		pag.pghi_vlpagamento AS "VALOR PAGO"
	FROM
		arrecadacao.pagamento_historico pag
		INNER JOIN faturamento.conta_historico con ON con.cnta_id = pag.cnta_id
		INNER JOIN cadastro.imovel imo ON pag.imov_id = imo.imov_id
		INNER JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
		INNER JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
		INNER JOIN cadastro.imovel_perfil ipe ON ipe.iper_id = imo.iper_id
		INNER JOIN cadastro.quadra qdr ON qdr.qdra_id = imo.qdra_id
		LEFT JOIN operacional.distrito_operacional dis ON dis.diop_id = qdr.diop_id
		LEFT JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
		LEFT JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
		LEFT JOIN cadastro.setor_comercial sec ON imo.stcm_id = sec.stcm_id
		LEFT JOIN micromedicao.rota rot ON rot.rota_id = qdr.rota_id
		LEFT JOIN faturamento.faturamento_grupo ftg ON rot.ftgr_id = ftg.ftgr_id
	WHERE
		--pag.pghi_dtpagamento >= '2023-03-01' AND pag.pghi_dtpagamento <= '2023-03-31'
		pag.pghi_amreferenciaarrecadacao = VAR_REFERENCIA
UNION
	SELECT
		imo.imov_id AS "MATRICULA",
		imo.imov_nncoordenadax AS "LATITUDE",
		imo.imov_nncoordenaday AS "LONGITUDE",
		cli.clie_nmcliente AS "NOME",
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
		ipe.iper_dsimovelperfil AS "PERFIL",
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
		dis.diop_dsdistritooperacional AS "DISTR OPERACIONAL",
		pag.pgmt_dtpagamento - con.cnhi_dtvencimentoconta AS "ATRASO",
		con.cnhi_amreferenciaconta AS "REFERENCIA",
		pag.pgmt_dtpagamento AS "DATA PAGAMENTO",
		con.cnhi_dtvencimentoconta AS "VENCIMENTO",
		con.cnhi_dtvencimentooriginal AS "VENCIMENTO ORIGINAL",
		pag.pgmt_dtpagamento - con.cnhi_dtvencimentooriginal AS "ATRASO VENCIMENTO ORIGINAL",
		(CASE 
		WHEN pag.pgmt_dtpagamento - con.cnhi_dtvencimentoconta <= 0 THEN '01 - EM DIA'
		WHEN pag.pgmt_dtpagamento - con.cnhi_dtvencimentoconta <= 5  THEN '02 - ATE 5 DIAS DE ATRASO'
		WHEN pag.pgmt_dtpagamento - con.cnhi_dtvencimentoconta <= 15  THEN '03 - ATE 15 DIAS DE ATRASO'
		WHEN pag.pgmt_dtpagamento - con.cnhi_dtvencimentoconta <= 30  THEN '04 - ATE 30 DIAS DE ATRASO'
		WHEN pag.pgmt_dtpagamento - con.cnhi_dtvencimentoconta <= 60  THEN '05 - ATE 60 DIAS DE ATRASO'
		WHEN pag.pgmt_dtpagamento - con.cnhi_dtvencimentoconta <= 90  THEN '06 - ATE 90 DIAS DE ATRASO'
		WHEN pag.pgmt_dtpagamento - con.cnhi_dtvencimentoconta <= 180  THEN '07 - ATE 180 DIAS DE ATRASO'
		WHEN pag.pgmt_dtpagamento - con.cnhi_dtvencimentoconta <= 365  THEN '08 - ATE 365 DIAS DE ATRASO'
		WHEN pag.pgmt_dtpagamento - con.cnhi_dtvencimentoconta <= 1825  THEN '09 - ATE 5 ANOS DE ATRASO'
		WHEN pag.pgmt_dtpagamento - con.cnhi_dtvencimentoconta <= 3650  THEN '10 - ATE 10 ANOS DE ATRASO'
		WHEN pag.pgmt_dtpagamento - con.cnhi_dtvencimentoconta > 3650  THEN '11 - ACIMA DE 10 ANOS DE ATRASO'
		END) AS "FAIXA ATRASO",
		con.cnhi_nnconsumoagua AS "VOL AGUA",
		con.cnhi_nnconsumoesgoto AS "VOL ESGOTO",
		con.cnhi_vlagua AS "VL AGUA",
		con.cnhi_vlesgoto AS "VL ESGOTO",
		con.cnhi_vldebitos AS "VL DEBITOS",
		con.cnhi_vlcreditos AS "VL CREDITOS",
		con.cnhi_vlimpostos AS "VL IMPOSTOS",
		pag.pgmt_vlpagamento AS "VALOR",
		'PAGO' AS "STATUS",
		pag.pgmt_amreferenciaarrecadacao AS "REFERENCIA ARR",
		pag.pgmt_vlpagamento AS "VALOR PAGO"
	FROM
		arrecadacao.pagamento pag
		INNER JOIN faturamento.conta_historico con ON con.cnta_id = pag.cnta_id
		INNER JOIN cadastro.imovel imo ON pag.imov_id = imo.imov_id
		INNER JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
		INNER JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
		INNER JOIN cadastro.imovel_perfil ipe ON ipe.iper_id = imo.iper_id
		INNER JOIN cadastro.quadra qdr ON qdr.qdra_id = imo.qdra_id
		LEFT JOIN operacional.distrito_operacional dis ON dis.diop_id = qdr.diop_id
		LEFT JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
		LEFT JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
		LEFT JOIN cadastro.setor_comercial sec ON imo.stcm_id = sec.stcm_id
		LEFT JOIN micromedicao.rota rot ON rot.rota_id = qdr.rota_id
		LEFT JOIN faturamento.faturamento_grupo ftg ON rot.ftgr_id = ftg.ftgr_id
	WHERE
		--pag.pgmt_dtpagamento >= '2023-03-01' AND pag.pgmt_dtpagamento <= '2023-03-31'
		pag.pgmt_amreferenciaarrecadacao = VAR_REFERENCIA
UNION
	SELECT
		imo.imov_id AS "MATRICULA",
		imo.imov_nncoordenadax AS "LATITUDE",
		imo.imov_nncoordenaday AS "LONGITUDE",
		cli.clie_nmcliente AS "NOME",
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
		ipe.iper_dsimovelperfil AS "PERFIL",
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
		dis.diop_dsdistritooperacional AS "DISTR OPERACIONAL",
		pag.pgmt_dtpagamento - con.cnta_dtvencimentoconta AS "ATRASO",
		con.cnta_amreferenciaconta AS "REFERENCIA",
		pag.pgmt_dtpagamento AS "DATA PAGAMENTO",
		con.cnta_dtvencimentoconta AS "VENCIMENTO",
		con.cnta_dtvencimentooriginal AS "VENCIMENTO ORIGINAL",
		pag.pgmt_dtpagamento - con.cnta_dtvencimentooriginal AS "ATRASO VENCIMENTO ORIGINAL",
		(CASE 
		WHEN pag.pgmt_dtpagamento - con.cnta_dtvencimentoconta <= 0 THEN '01 - EM DIA'
		WHEN pag.pgmt_dtpagamento - con.cnta_dtvencimentoconta <= 5  THEN '02 - ATE 5 DIAS DE ATRASO'
		WHEN pag.pgmt_dtpagamento - con.cnta_dtvencimentoconta <= 15  THEN '03 - ATE 15 DIAS DE ATRASO'
		WHEN pag.pgmt_dtpagamento - con.cnta_dtvencimentoconta <= 30  THEN '04 - ATE 30 DIAS DE ATRASO'
		WHEN pag.pgmt_dtpagamento - con.cnta_dtvencimentoconta <= 60  THEN '05 - ATE 60 DIAS DE ATRASO'
		WHEN pag.pgmt_dtpagamento - con.cnta_dtvencimentoconta <= 90  THEN '06 - ATE 90 DIAS DE ATRASO'
		WHEN pag.pgmt_dtpagamento - con.cnta_dtvencimentoconta <= 180  THEN '07 - ATE 180 DIAS DE ATRASO'
		WHEN pag.pgmt_dtpagamento - con.cnta_dtvencimentoconta <= 365  THEN '08 - ATE 365 DIAS DE ATRASO'
		WHEN pag.pgmt_dtpagamento - con.cnta_dtvencimentoconta <= 1825  THEN '09 - ATE 5 ANOS DE ATRASO'
		WHEN pag.pgmt_dtpagamento - con.cnta_dtvencimentoconta <= 3650  THEN '10 - ATE 10 ANOS DE ATRASO'
		WHEN pag.pgmt_dtpagamento - con.cnta_dtvencimentoconta > 3650  THEN '11 - ACIMA DE 10 ANOS DE ATRASO'
		END) AS "FAIXA ATRASO",
		con.cnta_nnconsumoagua AS "VOL AGUA",
		con.cnta_nnconsumoesgoto AS "VOL ESGOTO",
		con.cnta_vlagua AS "VL AGUA",
		con.cnta_vlesgoto AS "VL ESGOTO",
		con.cnta_vldebitos AS "VL DEBITOS",
		con.cnta_vlcreditos AS "VL CREDITOS",
		con.cnta_vlimpostos AS "VL IMPOSTOS",
		pag.pgmt_vlpagamento AS "VALOR",
		'PAGO' AS "STATUS",
		pag.pgmt_amreferenciaarrecadacao AS "REFERENCIA ARR",
		pag.pgmt_vlpagamento AS "VALOR PAGO"
	FROM
		arrecadacao.pagamento pag
		INNER JOIN faturamento.conta con ON con.cnta_id = pag.cnta_id
		INNER JOIN cadastro.imovel imo ON pag.imov_id = imo.imov_id
		INNER JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
		INNER JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
		INNER JOIN cadastro.imovel_perfil ipe ON ipe.iper_id = imo.iper_id
		INNER JOIN cadastro.quadra qdr ON qdr.qdra_id = imo.qdra_id
		LEFT JOIN operacional.distrito_operacional dis ON dis.diop_id = qdr.diop_id
		LEFT JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
		LEFT JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
		LEFT JOIN cadastro.setor_comercial sec ON imo.stcm_id = sec.stcm_id
		LEFT JOIN micromedicao.rota rot ON rot.rota_id = qdr.rota_id
		LEFT JOIN faturamento.faturamento_grupo ftg ON rot.ftgr_id = ftg.ftgr_id
	WHERE
		--pag.pgmt_dtpagamento >= '2023-03-01' AND pag.pgmt_dtpagamento <= '2023-03-31'
		pag.pgmt_amreferenciaarrecadacao = VAR_REFERENCIA
UNION
	SELECT
		imo.imov_id AS "MATRICULA",
		imo.imov_nncoordenadax AS "LATITUDE",
		imo.imov_nncoordenaday AS "LONGITUDE",
		cli.clie_nmcliente AS "NOME",
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
		ipe.iper_dsimovelperfil AS "PERFIL",
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
		dis.diop_dsdistritooperacional AS "DISTR OPERACIONAL",
		pag.pghi_dtpagamento - con.cnta_dtvencimentoconta AS "ATRASO",
		con.cnta_amreferenciaconta AS "REFERENCIA",
		pag.pghi_dtpagamento AS "DATA PAGAMENTO",
		con.cnta_dtvencimentoconta AS "VENCIMENTO",
		con.cnta_dtvencimentooriginal AS "VENCIMENTO ORIGINAL",
		pag.pghi_dtpagamento - con.cnta_dtvencimentooriginal AS "ATRASO VENCIMENTO ORIGINAL",
		(CASE 
		WHEN pag.pghi_dtpagamento - con.cnta_dtvencimentoconta <= 0 THEN '01 - EM DIA'
		WHEN pag.pghi_dtpagamento - con.cnta_dtvencimentoconta <= 5  THEN '02 - ATE 5 DIAS DE ATRASO'
		WHEN pag.pghi_dtpagamento - con.cnta_dtvencimentoconta <= 15  THEN '03 - ATE 15 DIAS DE ATRASO'
		WHEN pag.pghi_dtpagamento - con.cnta_dtvencimentoconta <= 30  THEN '04 - ATE 30 DIAS DE ATRASO'
		WHEN pag.pghi_dtpagamento - con.cnta_dtvencimentoconta <= 60  THEN '05 - ATE 60 DIAS DE ATRASO'
		WHEN pag.pghi_dtpagamento - con.cnta_dtvencimentoconta <= 90  THEN '06 - ATE 90 DIAS DE ATRASO'
		WHEN pag.pghi_dtpagamento - con.cnta_dtvencimentoconta <= 180  THEN '07 - ATE 180 DIAS DE ATRASO'
		WHEN pag.pghi_dtpagamento - con.cnta_dtvencimentoconta <= 365  THEN '08 - ATE 365 DIAS DE ATRASO'
		WHEN pag.pghi_dtpagamento - con.cnta_dtvencimentoconta <= 1825  THEN '09 - ATE 5 ANOS DE ATRASO'
		WHEN pag.pghi_dtpagamento - con.cnta_dtvencimentoconta <= 3650  THEN '10 - ATE 10 ANOS DE ATRASO'
		WHEN pag.pghi_dtpagamento - con.cnta_dtvencimentoconta > 3650  THEN '11 - ACIMA DE 10 ANOS DE ATRASO'
		END) AS "FAIXA ATRASO",
		con.cnta_nnconsumoagua AS "VOL AGUA",
		con.cnta_nnconsumoesgoto AS "VOL ESGOTO",
		con.cnta_vlagua AS "VL AGUA",
		con.cnta_vlesgoto AS "VL ESGOTO",
		con.cnta_vldebitos AS "VL DEBITOS",
		con.cnta_vlcreditos AS "VL CREDITOS",
		con.cnta_vlimpostos AS "VL IMPOSTOS",
		pag.pghi_vlpagamento AS "VALOR",
		'PAGO' AS "STATUS",
		pag.pghi_amreferenciaarrecadacao AS "REFERENCIA ARR",
		pag.pghi_vlpagamento AS "VALOR PAGO"
	FROM
		arrecadacao.pagamento_historico pag
		INNER JOIN faturamento.conta con ON con.cnta_id = pag.cnta_id
		INNER JOIN cadastro.imovel imo ON pag.imov_id = imo.imov_id
		INNER JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
		INNER JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
		INNER JOIN cadastro.imovel_perfil ipe ON ipe.iper_id = imo.iper_id
		INNER JOIN cadastro.quadra qdr ON qdr.qdra_id = imo.qdra_id
		LEFT JOIN operacional.distrito_operacional dis ON dis.diop_id = qdr.diop_id
		LEFT JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
		LEFT JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
		LEFT JOIN cadastro.setor_comercial sec ON imo.stcm_id = sec.stcm_id
		LEFT JOIN micromedicao.rota rot ON rot.rota_id = qdr.rota_id
		LEFT JOIN faturamento.faturamento_grupo ftg ON rot.ftgr_id = ftg.ftgr_id
	WHERE
		--pag.pghi_dtpagamento >= '2023-03-01' AND pag.pghi_dtpagamento <= '2023-03-31'
		pag.pghi_amreferenciaarrecadacao = VAR_REFERENCIA
UNION
	SELECT
		imo.imov_id AS "MATRICULA",
		imo.imov_nncoordenadax AS "LATITUDE",
		imo.imov_nncoordenaday AS "LONGITUDE",
		cli.clie_nmcliente AS "NOME",
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
		ipe.iper_dsimovelperfil AS "PERFIL",
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
		dis.diop_dsdistritooperacional AS "DISTR OPERACIONAL",
		NULL AS "ATRASO",
		NULL AS "REFERENCIA",
		pag.pghi_dtpagamento AS "DATA PAGAMENTO",
		NULL AS "VENCIMENTO",
		NULL AS "VENCIMENTO ORIGINAL",
		NULL AS "ATRASO VENCIMENTO ORIGINAL",
		NULL AS "FAIXA ATRASO",
		NULL AS "VOL AGUA",
		NULL AS "VOL ESGOTO",
		NULL AS "VL AGUA",
		NULL AS "VL ESGOTO",
		NULL AS "VL DEBITOS",
		NULL AS "VL CREDITOS",
		NULL AS "VL IMPOSTOS",
		NULL AS "VALOR",
		'OUTROS VALORES PAGOS' AS "STATUS",
		pag.pghi_amreferenciaarrecadacao AS "REFERENCIA ARR",
		pag.pghi_vlpagamento AS "VALOR PAGO"
	FROM
		arrecadacao.pagamento_historico pag
		LEFT JOIN cadastro.imovel imo ON pag.imov_id = imo.imov_id
		LEFT JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
		LEFT JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
		LEFT JOIN cadastro.imovel_perfil ipe ON ipe.iper_id = imo.iper_id
		LEFT JOIN cadastro.quadra qdr ON qdr.qdra_id = imo.qdra_id
		LEFT JOIN operacional.distrito_operacional dis ON dis.diop_id = qdr.diop_id
		LEFT JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
		LEFT JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
		LEFT JOIN cadastro.setor_comercial sec ON imo.stcm_id = sec.stcm_id
		LEFT JOIN micromedicao.rota rot ON rot.rota_id = qdr.rota_id
		LEFT JOIN faturamento.faturamento_grupo ftg ON rot.ftgr_id = ftg.ftgr_id
	WHERE
		--pag.pghi_dtpagamento >= '2023-03-01' AND pag.pghi_dtpagamento <= '2023-03-31'
		pag.pghi_amreferenciaarrecadacao = VAR_REFERENCIA AND pag.cnta_id IS NULL
UNION
	SELECT
		imo.imov_id AS "MATRICULA",
		imo.imov_nncoordenadax AS "LATITUDE",
		imo.imov_nncoordenaday AS "LONGITUDE",
		cli.clie_nmcliente AS "NOME",
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
		ipe.iper_dsimovelperfil AS "PERFIL",
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
		dis.diop_dsdistritooperacional AS "DISTR OPERACIONAL",
		NULL AS "ATRASO",
		NULL AS "REFERENCIA",
		pag.pgmt_dtpagamento AS "DATA PAGAMENTO",
		NULL AS "VENCIMENTO",
		NULL AS "VENCIMENTO ORIGINAL",
		NULL AS "ATRASO VENCIMENTO ORIGINAL",
		NULL AS "FAIXA ATRASO",
		NULL AS "VOL AGUA",
		NULL AS "VOL ESGOTO",
		NULL AS "VL AGUA",
		NULL AS "VL ESGOTO",
		NULL AS "VL DEBITOS",
		NULL AS "VL CREDITOS",
		NULL AS "VL IMPOSTOS",
		NULL AS "VALOR",
		'OUTROS VALORES PAGOS' AS "STATUS",
		pag.pgmt_amreferenciaarrecadacao AS "REFERENCIA ARR",
		pag.pgmt_vlpagamento AS "VALOR PAGO"
	FROM
		arrecadacao.pagamento pag
		LEFT JOIN cadastro.imovel imo ON pag.imov_id = imo.imov_id
		LEFT JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
		LEFT JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
		LEFT JOIN cadastro.imovel_perfil ipe ON ipe.iper_id = imo.iper_id
		LEFT JOIN cadastro.quadra qdr ON qdr.qdra_id = imo.qdra_id
		LEFT JOIN operacional.distrito_operacional dis ON dis.diop_id = qdr.diop_id
		LEFT JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
		LEFT JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
		LEFT JOIN cadastro.setor_comercial sec ON imo.stcm_id = sec.stcm_id
		LEFT JOIN micromedicao.rota rot ON rot.rota_id = qdr.rota_id
		LEFT JOIN faturamento.faturamento_grupo ftg ON rot.ftgr_id = ftg.ftgr_id
	WHERE
		--pag.pghi_dtpagamento >= '2023-03-01' AND pag.pghi_dtpagamento <= '2023-03-31'
		pag.pgmt_amreferenciaarrecadacao = VAR_REFERENCIA AND pag.cnta_id IS NULL
UNION
	SELECT
		imo.imov_id AS "MATRICULA",
		imo.imov_nncoordenadax AS "LATITUDE",
		imo.imov_nncoordenaday AS "LONGITUDE",
		cli.clie_nmcliente AS "NOME",
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
		ipe.iper_dsimovelperfil AS "PERFIL",
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
		dis.diop_dsdistritooperacional AS "DISTR OPERACIONAL",
		NULL AS "ATRASO",
		NULL AS "REFERENCIA",
		dev.devl_dtdevolucao AS "DATA PAGAMENTO",
		NULL AS "VENCIMENTO",
		NULL AS "VENCIMENTO ORIGINAL",
		NULL AS "ATRASO VENCIMENTO ORIGINAL",
		NULL AS "FAIXA ATRASO",
		NULL AS "VOL AGUA",
		NULL AS "VOL ESGOTO",
		NULL AS "VL AGUA",
		NULL AS "VL ESGOTO",
		NULL AS "VL DEBITOS",
		NULL AS "VL CREDITOS",
		NULL AS "VL IMPOSTOS",
		NULL AS "VALOR",
		'OUTROS VALORES DEVOLVIDOS' AS "STATUS",
		dev.devl_amreferenciaarrecadacao AS "REFERENCIA ARR",
		-1*dev.devl_vldevolucao AS "VALOR PAGO"
	FROM
		arrecadacao.devolucao dev
		LEFT JOIN cadastro.imovel imo ON dev.imov_id = imo.imov_id
		LEFT JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
		LEFT JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
		LEFT JOIN cadastro.imovel_perfil ipe ON ipe.iper_id = imo.iper_id
		LEFT JOIN cadastro.quadra qdr ON qdr.qdra_id = imo.qdra_id
		LEFT JOIN operacional.distrito_operacional dis ON dis.diop_id = qdr.diop_id
		LEFT JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
		LEFT JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
		LEFT JOIN cadastro.setor_comercial sec ON imo.stcm_id = sec.stcm_id
		LEFT JOIN micromedicao.rota rot ON rot.rota_id = qdr.rota_id
		LEFT JOIN faturamento.faturamento_grupo ftg ON rot.ftgr_id = ftg.ftgr_id
	WHERE
		--pag.pghi_dtpagamento >= '2023-03-01' AND pag.pghi_dtpagamento <= '2023-03-31'
		dev.devl_amreferenciaarrecadacao = VAR_REFERENCIA
UNION
	SELECT
		imo.imov_id AS "MATRICULA",
		imo.imov_nncoordenadax AS "LATITUDE",
		imo.imov_nncoordenaday AS "LONGITUDE",
		cli.clie_nmcliente AS "NOME",
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
		ipe.iper_dsimovelperfil AS "PERFIL",
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
		dis.diop_dsdistritooperacional AS "DISTR OPERACIONAL",
		NULL AS "ATRASO",
		NULL AS "REFERENCIA",
		dev.dehi_dtdevolucao AS "DATA PAGAMENTO",
		NULL AS "VENCIMENTO",
		NULL AS "VENCIMENTO ORIGINAL",
		NULL AS "ATRASO VENCIMENTO ORIGINAL",
		NULL AS "FAIXA ATRASO",
		NULL AS "VOL AGUA",
		NULL AS "VOL ESGOTO",
		NULL AS "VL AGUA",
		NULL AS "VL ESGOTO",
		NULL AS "VL DEBITOS",
		NULL AS "VL CREDITOS",
		NULL AS "VL IMPOSTOS",
		NULL AS "VALOR",
		'OUTROS VALORES DEVOLVIDOS' AS "STATUS",
		dev.dehi_amreferenciaarrecadacao AS "REFERENCIA ARR",
		-1*dev.dehi_vldevolucao AS "VALOR PAGO"
	FROM
		arrecadacao.devolucao_historico dev
		LEFT JOIN cadastro.imovel imo ON dev.imov_id = imo.imov_id
		LEFT JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
		LEFT JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
		LEFT JOIN cadastro.imovel_perfil ipe ON ipe.iper_id = imo.iper_id
		LEFT JOIN cadastro.quadra qdr ON qdr.qdra_id = imo.qdra_id
		LEFT JOIN operacional.distrito_operacional dis ON dis.diop_id = qdr.diop_id
		LEFT JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
		LEFT JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
		LEFT JOIN cadastro.setor_comercial sec ON imo.stcm_id = sec.stcm_id
		LEFT JOIN micromedicao.rota rot ON rot.rota_id = qdr.rota_id
		LEFT JOIN faturamento.faturamento_grupo ftg ON rot.ftgr_id = ftg.ftgr_id
	WHERE
		--pag.pghi_dtpagamento >= '2023-03-01' AND pag.pghi_dtpagamento <= '2023-03-31'
		dev.dehi_amreferenciaarrecadacao = VAR_REFERENCIA