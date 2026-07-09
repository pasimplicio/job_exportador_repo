--VAR_REFERENCIA

SELECT
		imo.imov_id AS "MATRICULA",
		imo.imov_nncoordenadax AS "LATITUDE",
		imo.imov_nncoordenaday AS "LONGITUDE",
		cli.clie_id AS "CLIENTE",
		imo.loca_id AS "LOCALIDADE",
		con.cnhi_amreferenciaconta AS "REFERENCIA",
		pag.pghi_dtpagamento AS "DATA PAGAMENTO",
		con.cnhi_dtvencimentooriginal AS "VENCIMENTO ORIGINAL",
		TO_CHAR(pag.pghi_vlpagamento, '999G999G990D00') AS "VALOR",
		'PAGO' AS "STATUS",
		pag.pghi_amreferenciaarrecadacao AS "REFERENCIA ARR",
		TO_CHAR(pag.pghi_vlpagamento, '999G999G990D00') AS "VALOR PAGO"
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
		cli.clie_id AS "CLIENTE",
		imo.loca_id AS "LOCALIDADE",
		con.cnhi_amreferenciaconta AS "REFERENCIA",
		pag.pgmt_dtpagamento AS "DATA PAGAMENTO",
		con.cnhi_dtvencimentooriginal AS "VENCIMENTO ORIGINAL",
		TO_CHAR(pag.pgmt_vlpagamento, '999G999G990D00') AS "VALOR",
		'PAGO' AS "STATUS",
		pag.pgmt_amreferenciaarrecadacao AS "REFERENCIA ARR",
		TO_CHAR(pag.pgmt_vlpagamento, '999G999G990D00') AS "VALOR PAGO"
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
		cli.clie_id AS "CLIENTE",
		imo.loca_id AS "LOCALIDADE",
		con.cnta_amreferenciaconta AS "REFERENCIA",
		pag.pgmt_dtpagamento AS "DATA PAGAMENTO",
		con.cnta_dtvencimentooriginal AS "VENCIMENTO ORIGINAL",
		TO_CHAR(pag.pgmt_vlpagamento, '999G999G990D00') AS "VALOR",
		'PAGO' AS "STATUS",
		pag.pgmt_amreferenciaarrecadacao AS "REFERENCIA ARR",
		TO_CHAR(pag.pgmt_vlpagamento, '999G999G990D00') AS "VALOR PAGO"
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
		cli.clie_id AS "CLIENTE",
		imo.loca_id AS "LOCALIDADE",
		con.cnta_amreferenciaconta AS "REFERENCIA",
		pag.pghi_dtpagamento AS "DATA PAGAMENTO",
		con.cnta_dtvencimentooriginal AS "VENCIMENTO ORIGINAL",
		TO_CHAR(pag.pghi_vlpagamento, '999G999G990D00') AS "VALOR",
		'PAGO' AS "STATUS",
		pag.pghi_amreferenciaarrecadacao AS "REFERENCIA ARR",
		TO_CHAR(pag.pghi_vlpagamento, '999G999G990D00') AS "VALOR PAGO"
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
		cli.clie_id AS "CLIENTE",
		imo.loca_id AS "LOCALIDADE",
		NULL AS "REFERENCIA",
		pag.pghi_dtpagamento AS "DATA PAGAMENTO",
		NULL AS "VENCIMENTO ORIGINAL",
		NULL AS "VALOR",
		'OUTROS VALORES PAGOS' AS "STATUS",
		pag.pghi_amreferenciaarrecadacao AS "REFERENCIA ARR",
		TO_CHAR(pag.pghi_vlpagamento, '999G999G990D00') AS "VALOR PAGO"
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
		cli.clie_id AS "CLIENTE",
		imo.loca_id AS "LOCALIDADE",
		NULL AS "REFERENCIA",
		pag.pgmt_dtpagamento AS "DATA PAGAMENTO",
		NULL AS "VENCIMENTO ORIGINAL",
		NULL AS "VALOR",
		'OUTROS VALORES PAGOS' AS "STATUS",
		pag.pgmt_amreferenciaarrecadacao AS "REFERENCIA ARR",
		TO_CHAR(pag.pgmt_vlpagamento, '999G999G990D00') AS "VALOR PAGO"
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
		cli.clie_id AS "CLIENTE",
		imo.loca_id AS "LOCALIDADE",
		NULL AS "REFERENCIA",
		dev.devl_dtdevolucao AS "DATA PAGAMENTO",
		NULL AS "VENCIMENTO ORIGINAL",
		NULL AS "VALOR",
		'OUTROS VALORES DEVOLVIDOS' AS "STATUS",
		dev.devl_amreferenciaarrecadacao AS "REFERENCIA ARR",
		TO_CHAR(-1*dev.devl_vldevolucao, '999G999G990D00') AS "VALOR PAGO"
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
		cli.clie_id AS "CLIENTE",
		imo.loca_id AS "LOCALIDADE",
		NULL AS "REFERENCIA",
		dev.dehi_dtdevolucao AS "DATA PAGAMENTO",
		NULL AS "VENCIMENTO ORIGINAL",
		NULL AS "VALOR",
		'OUTROS VALORES DEVOLVIDOS' AS "STATUS",
		dev.dehi_amreferenciaarrecadacao AS "REFERENCIA ARR",
		TO_CHAR(-1*dev.dehi_vldevolucao, '999G999G990D00') AS "VALOR PAGO"
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