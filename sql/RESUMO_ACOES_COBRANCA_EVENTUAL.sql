SELECT
	une.uneg_nmunidadenegocio AS "UNIDADE",
	loc.loca_nmlocalidade AS "LOCALIDADE",
	sec.stcm_cdsetorcomercial AS "SETOR COMERCIAL",
	rot.rota_cdrota AS "ROTA",
	rse.rcbe_nnquadra AS "QUADRA",
	cat.catg_dscategoria AS "CATEGORIA",
	ipe.iper_dsimovelperfil AS "PERFIL",
	TO_CHAR(rse.rcbe_tmrealizacaoemitir, 'dd/MM/yyyy') AS "DATA EMISSAO",
	TO_CHAR(rse.rcbe_tmrealizacaoencerrar, 'dd/MM/yyyy') AS "DATA ENCERRAMENTO",
	cba.cbac_dscobrancaacao AS "TIPO DA ACAO",
	cbs.cast_dssituacaoacao AS "SITUACAO DA ACAO",
	cds.cdst_dssituacaodebito AS "SITUACAO DO DEBITO",
	rse.rcbe_qtdocumentos AS "QTD DOCUMENTOS",
	TO_CHAR(rse.rcbe_vldocumentos, 'L999G999G990D00') AS "VALOR",
	rse.rcbe_icdefinitivo AS "SIT DEFINITIVA",
	emp.empr_nmempresa AS "EMPRESA",
	rse.cbct_id AS "CRITERIO COBRANCA"
	
FROM 	
	cobranca.resumo_cobr_acao_event rse
	INNER JOIN cobranca.cobranca_acao cba ON cba.cbac_id = rse.cbac_id
	INNER JOIN cobranca.cobranca_acao_situacao cbs ON cbs.cast_id = rse.cast_id
	INNER JOIN cobranca.cobranca_debito_situacao cds ON cds.cdst_id = rse.cdst_id
	INNER JOIN cadastro.localidade loc ON loc.loca_id = rse.loca_id
	INNER JOIN cadastro.imovel_perfil ipe ON ipe.iper_id = rse.iper_id
	INNER JOIN cadastro.categoria cat ON cat.catg_id = rse.catg_id
	INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = rse.uneg_id
	INNER JOIN cadastro.setor_comercial sec ON sec.stcm_id = rse.stcm_id
	INNER JOIN micromedicao.rota rot ON rot.rota_id = rse.rota_id
	INNER JOIN cadastro.empresa emp ON emp.empr_id = rse.empr_id
WHERE
	rse.rcbe_tmrealizacaoemitir>=TO_CHAR((CURRENT_DATE - INTERVAL '1y'),'yyyyMM')::INTEGER