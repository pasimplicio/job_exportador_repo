


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
		'PAGO' AS "STATUS"
	FROM
		arrecadacao.pagamento_historico pag
		INNER JOIN faturamento.conta_historico con ON con.cnta_id = pag.cnta_id
		INNER JOIN cadastro.imovel imo ON pag.imov_id = imo.imov_id
		INNER JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
		INNER JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
		INNER JOIN cadastro.imovel_perfil ipe ON ipe.iper_id = imo.iper_id
		INNER JOIN cadastro.quadra qdr ON qdr.qdra_id = imo.qdra_id
		LEFT JOIN operacional.distrito_operacional dis ON dis.diop_id = qdr.diop_id
		LEFT JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id AND loc.greg_id IN (1,2)
		LEFT JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
		LEFT JOIN cadastro.setor_comercial sec ON imo.stcm_id = sec.stcm_id
		LEFT JOIN micromedicao.rota rot ON rot.rota_id = qdr.rota_id
		LEFT JOIN faturamento.faturamento_grupo ftg ON rot.ftgr_id = ftg.ftgr_id
	WHERE
		con.cnhi_dtvencimentoconta >= 'VAR_VENCIMENTO_BEGIN' AND con.cnhi_dtvencimentoconta <= 'VAR_VENCIMENTO_END'
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
		'PAGO' AS "STATUS"
	FROM
		arrecadacao.pagamento pag
		INNER JOIN faturamento.conta_historico con ON con.cnta_id = pag.cnta_id
		INNER JOIN cadastro.imovel imo ON pag.imov_id = imo.imov_id
		INNER JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
		INNER JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
		INNER JOIN cadastro.imovel_perfil ipe ON ipe.iper_id = imo.iper_id
		INNER JOIN cadastro.quadra qdr ON qdr.qdra_id = imo.qdra_id
		LEFT JOIN operacional.distrito_operacional dis ON dis.diop_id = qdr.diop_id
		LEFT JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id AND loc.greg_id IN (1,2)
		LEFT JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
		LEFT JOIN cadastro.setor_comercial sec ON imo.stcm_id = sec.stcm_id
		LEFT JOIN micromedicao.rota rot ON rot.rota_id = qdr.rota_id
		LEFT JOIN faturamento.faturamento_grupo ftg ON rot.ftgr_id = ftg.ftgr_id
	WHERE
		con.cnhi_dtvencimentoconta >= 'VAR_VENCIMENTO_BEGIN' AND con.cnhi_dtvencimentoconta <= 'VAR_VENCIMENTO_END'
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
		'PAGO' AS "STATUS"
	FROM
		arrecadacao.pagamento_historico pag
		INNER JOIN faturamento.conta con ON con.cnta_id = pag.cnta_id
		INNER JOIN cadastro.imovel imo ON pag.imov_id = imo.imov_id
		INNER JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
		INNER JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
		INNER JOIN cadastro.imovel_perfil ipe ON ipe.iper_id = imo.iper_id
		INNER JOIN cadastro.quadra qdr ON qdr.qdra_id = imo.qdra_id
		LEFT JOIN operacional.distrito_operacional dis ON dis.diop_id = qdr.diop_id
		LEFT JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id AND loc.greg_id IN (1,2)
		LEFT JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
		LEFT JOIN cadastro.setor_comercial sec ON imo.stcm_id = sec.stcm_id
		LEFT JOIN micromedicao.rota rot ON rot.rota_id = qdr.rota_id
		LEFT JOIN faturamento.faturamento_grupo ftg ON rot.ftgr_id = ftg.ftgr_id
	WHERE
		con.cnta_dtvencimentoconta >= 'VAR_VENCIMENTO_BEGIN' AND con.cnta_dtvencimentoconta <= 'VAR_VENCIMENTO_END'
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
		'PAGO' AS "STATUS"
		
	FROM
		arrecadacao.pagamento pag
		INNER JOIN faturamento.conta con ON con.cnta_id = pag.cnta_id
		INNER JOIN cadastro.imovel imo ON pag.imov_id = imo.imov_id
		INNER JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
		INNER JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
		INNER JOIN cadastro.imovel_perfil ipe ON ipe.iper_id = imo.iper_id
		INNER JOIN cadastro.quadra qdr ON qdr.qdra_id = imo.qdra_id
		LEFT JOIN operacional.distrito_operacional dis ON dis.diop_id = qdr.diop_id
		LEFT JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id AND loc.greg_id IN (1,2)
		LEFT JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
		LEFT JOIN cadastro.setor_comercial sec ON imo.stcm_id = sec.stcm_id
		LEFT JOIN micromedicao.rota rot ON rot.rota_id = qdr.rota_id
		LEFT JOIN faturamento.faturamento_grupo ftg ON rot.ftgr_id = ftg.ftgr_id
	WHERE
		con.cnta_dtvencimentoconta >= 'VAR_VENCIMENTO_BEGIN' AND con.cnta_dtvencimentoconta <= 'VAR_VENCIMENTO_END'
UNION
	SELECT
		imo.imov_id AS "MATRICULA",
		imo.imov_nncoordenadax AS "LATITUDE",
		imo.imov_nncoordenaday AS "LONGITUDE",
		cli.clie_id AS "CLIENTE",
		imo.loca_id AS "LOCALIDADE",
		con.cnta_amreferenciaconta AS "REFERENCIA",
		NULL AS "DATA PAGAMENTO",
		con.cnta_dtvencimentooriginal AS "VENCIMENTO ORIGINAL",
		TO_CHAR((con.cnta_vlagua+con.cnta_vlesgoto+con.cnta_vldebitos-con.cnta_vlcreditos-con.cnta_vlimpostos), '999G999G990D00') AS "VALOR",
		'EM ABERTO' AS "STATUS"
	FROM
		faturamento.conta con
		INNER JOIN cadastro.imovel imo ON con.imov_id = imo.imov_id
		INNER JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
		INNER JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
		INNER JOIN cadastro.imovel_perfil ipe ON ipe.iper_id = imo.iper_id
		INNER JOIN cadastro.quadra qdr ON qdr.qdra_id = imo.qdra_id
		LEFT JOIN operacional.distrito_operacional dis ON dis.diop_id = qdr.diop_id
		LEFT JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id AND loc.greg_id IN (1,2)
		LEFT JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
		LEFT JOIN cadastro.setor_comercial sec ON imo.stcm_id = sec.stcm_id
		LEFT JOIN micromedicao.rota rot ON rot.rota_id = qdr.rota_id
		LEFT JOIN faturamento.faturamento_grupo ftg ON rot.ftgr_id = ftg.ftgr_id
	WHERE
		con.cnta_dtvencimentoconta >= 'VAR_VENCIMENTO_BEGIN' AND con.cnta_dtvencimentoconta <= 'VAR_VENCIMENTO_END' AND 
		con.dcst_idatual IN (0,1,2) AND NOT EXISTS ( SELECT pag.cnta_id FROM arrecadacao.pagamento pag WHERE pag.cnta_id = con.cnta_id) AND con.cnta_dtrevisao IS NULL
UNION
	SELECT
		imo.imov_id AS "MATRICULA",
		imo.imov_nncoordenadax AS "LATITUDE",
		imo.imov_nncoordenaday AS "LONGITUDE",
		cli.clie_id AS "CLIENTE",
		imo.loca_id AS "LOCALIDADE",
		con.cnta_amreferenciaconta AS "REFERENCIA",
		NULL AS "DATA PAGAMENTO",
		con.cnta_dtvencimentooriginal AS "VENCIMENTO ORIGINAL",
		TO_CHAR((con.cnta_vlagua+con.cnta_vlesgoto+con.cnta_vldebitos-con.cnta_vlcreditos-con.cnta_vlimpostos), '999G999G990D00') AS "VALOR",
		'REVISAO' AS "STATUS"
	FROM
		faturamento.conta con
		INNER JOIN cadastro.imovel imo ON con.imov_id = imo.imov_id
		INNER JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
		INNER JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
		INNER JOIN cadastro.imovel_perfil ipe ON ipe.iper_id = imo.iper_id
		INNER JOIN cadastro.quadra qdr ON qdr.qdra_id = imo.qdra_id
		LEFT JOIN operacional.distrito_operacional dis ON dis.diop_id = qdr.diop_id
		LEFT JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id AND loc.greg_id IN (1,2)
		LEFT JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
		LEFT JOIN cadastro.setor_comercial sec ON imo.stcm_id = sec.stcm_id
		LEFT JOIN micromedicao.rota rot ON rot.rota_id = qdr.rota_id
		LEFT JOIN faturamento.faturamento_grupo ftg ON rot.ftgr_id = ftg.ftgr_id
	WHERE
		con.cnta_dtvencimentoconta >= 'VAR_VENCIMENTO_BEGIN' AND con.cnta_dtvencimentoconta <= 'VAR_VENCIMENTO_END' AND 
		NOT con.cnta_dtrevisao IS NULL
UNION
	SELECT
		imo.imov_id AS "MATRICULA",
		imo.imov_nncoordenadax AS "LATITUDE",
		imo.imov_nncoordenaday AS "LONGITUDE",
		cli.clie_id AS "CLIENTE",
		imo.loca_id AS "LOCALIDADE",
		con.cnhi_amreferenciaconta AS "REFERENCIA",
		COALESCE(par.parc_tmparcelamento::DATE, CURRENT_DATE) AS "DATA PAGAMENTO",
		con.cnhi_dtvencimentooriginal AS "VENCIMENTO ORIGINAL",
		TO_CHAR((con.cnhi_vlagua+con.cnhi_vlesgoto+con.cnhi_vldebitos-con.cnhi_vlcreditos-con.cnhi_vlimpostos), '999G999G990D00') AS "VALOR",
		'PARCELADO' AS "STATUS"
	FROM
		faturamento.conta_historico con
		INNER JOIN cadastro.imovel imo ON con.imov_id = imo.imov_id
		INNER JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
		INNER JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
		INNER JOIN cadastro.imovel_perfil ipe ON ipe.iper_id = imo.iper_id
		INNER JOIN cadastro.quadra qdr ON qdr.qdra_id = imo.qdra_id
		LEFT JOIN operacional.distrito_operacional dis ON dis.diop_id = qdr.diop_id
		LEFT JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id AND loc.greg_id IN (1,2)
		LEFT JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
		LEFT JOIN cadastro.setor_comercial sec ON imo.stcm_id = sec.stcm_id
		LEFT JOIN micromedicao.rota rot ON rot.rota_id = qdr.rota_id
		LEFT JOIN faturamento.faturamento_grupo ftg ON rot.ftgr_id = ftg.ftgr_id
		LEFT JOIN cobranca.parcelamento_item pci ON pci.cnta_id = con.cnta_id
		LEFT JOIN cobranca.parcelamento par ON par.parc_id = pci.parc_id
	WHERE
		con.cnhi_dtvencimentoconta >= 'VAR_VENCIMENTO_BEGIN' AND con.cnhi_dtvencimentoconta <= 'VAR_VENCIMENTO_END' AND 
		con.dcst_idatual = 5