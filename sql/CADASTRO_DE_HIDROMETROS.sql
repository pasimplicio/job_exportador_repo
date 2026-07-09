SELECT
	hid.hidr_nnhidrometro AS "NR HID.",
	htp.hitp_dshidrometrotipo AS "TIPO",
	hrl.hire_dsrelojoaria AS "RELOJOARIA",
	hic.hicp_dshidrometrocapacidade AS "CAPACIDADE HD",
	hdi.hidm_dshidrometrodiametro AS "DIAMETRO HD",
	hma.himc_dshidrometromarca AS "FABRICANTE",
	hcm.hicm_dshidrclassemetrologica AS "CLASSE METROLOGICA",
	hla.hila_dshidrlocalarmazenagem AS "LOCAL ARMAZENAMENTO",
	hist_mov.hist AS "HISTORICO DE MOVIMENTACAO",
	hist_inst.hist AS "HISTORICO DE INSTALACAO",
	hst.hist_dshidrometrosituacao AS "SIT HIDROMETRO",
	his.hidi_dtinstalacaohidrometro AS "DATA DE INSTALACAO HD.",
	mdt.medt_dsmedicaotipo AS "LOCAL INSTALACAO",
	hli.hili_dshidmtlocalinstalacao AS "POSICAO INSTALACAO",
	imo.imov_id AS "MATRICULA IMOVEL",
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
	mun.muni_nmmunicipio AS "MUNICIPIO"
FROM
	micromedicao.hidrometro hid
	LEFT JOIN micromedicao.hidrometro_tipo htp ON htp.hitp_id = hid.hitp_id
	LEFT JOIN micromedicao.hidrometro_relojoaria hrl ON hrl.hire_id = hid.hire_id
	LEFT JOIN micromedicao.hidrometro_capacidade hic ON hic.hicp_id = hid.hicp_id
	LEFT JOIN micromedicao.hidrometro_diametro hdi ON hdi.hidm_id = hid.hidm_id
	LEFT JOIN micromedicao.hidrometro_marca hma ON hma.himc_id = hid.himc_id
	LEFT JOIN micromedicao.hidrometro_classe_metrlg hcm ON hcm.hicm_id = hid.hicm_id
	LEFT JOIN micromedicao.hidrometro_local_armaz hla ON hla.hila_id = hid.hila_id
	LEFT JOIN micromedicao.hidrometro_situacao hst ON hst.hist_id = hid.hist_id
	LEFT JOIN micromedicao.hidrometro_inst_hist his ON his.hidr_id = hid.hidr_id AND his.hidi_dtretiradahidrometro IS NULL
	LEFT JOIN micromedicao.medicao_tipo mdt ON mdt.medt_id = his.medt_id
	LEFT JOIN micromedicao.hidrometro_local_inst hli ON hli.hili_id = his.hili_id
	LEFT JOIN cadastro.imovel imo ON imo.imov_id = his.lagu_id
	LEFT JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id AND loc.greg_id IN (1,2)
	LEFT JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
	LEFT JOIN cadastro.setor_comercial sec ON imo.stcm_id = sec.stcm_id
	LEFT JOIN cadastro.quadra qdr ON qdr.qdra_id = imo.qdra_id
	LEFT JOIN micromedicao.rota rot ON rot.rota_id = qdr.rota_id
	LEFT JOIN faturamento.faturamento_grupo ftg ON rot.ftgr_id = ftg.ftgr_id
	LEFT JOIN cadastro.logradouro_bairro lgb ON lgb.lgbr_id = imo.lgbr_id
	LEFT JOIN cadastro.logradouro logr ON lgb.logr_id = logr.logr_id
	LEFT JOIN cadastro.bairro bai ON bai.bair_id = lgb.bair_id
	LEFT JOIN cadastro.municipio mun ON mun.muni_id = bai.muni_id
	LEFT JOIN cadastro.logradouro_cep lgc ON lgc.lgcp_id = imo.lgcp_id
	LEFT JOIN cadastro.cep cep ON cep.cep_id = lgc.cep_id
	LEFT JOIN cadastro.logradouro_tipo lgt ON lgt.lgtp_id = logr.lgtp_id
	LEFT JOIN (
		SELECT
			hid.hidr_id AS hidr_id,
			STRING_AGG(COALESCE(TO_CHAR(hmv.himv_dtmovimentacao,'dd/MM/yyyy'),'') || ' : ' || COALESCE(hla_origem.hila_dshidrlocalarmazenagem,'') || ' -> ' || COALESCE(hla_destino.hila_dshidrlocalarmazenagem,''), ' | ') AS hist
		FROM
			micromedicao.hidrometro hid
			LEFT JOIN micromedicao.hidrometro_movimentado hmo ON hmo.hidr_id = hid.hidr_id
			LEFT JOIN micromedicao.hidrometro_movimentacao hmv ON hmv.himv_id = hmo.himv_id
			LEFT JOIN micromedicao.hidrometro_local_armaz hla_origem ON hla_origem.hila_id = hmv.hila_idhidmtlocalarmzorigem
			LEFT JOIN micromedicao.hidrometro_local_armaz hla_destino ON hla_destino.hila_id = hmv.hila_idhidmtlocalarmzdest
		GROUP BY 1
	) AS hist_mov ON hist_mov.hidr_id = hid.hidr_id
	LEFT JOIN (
		SELECT
			hid.hidr_id AS hidr_id,
			STRING_AGG('MAT.: ' || COALESCE(his.lagu_id, his.imov_id)::TEXT || ' INST.: ' || COALESCE(TO_CHAR(his.hidi_dtinstalacaohidrometro,'dd/MM/yyyy'),'') || ', RET.: ' || COALESCE(TO_CHAR(his.hidi_dtretiradahidrometro,'dd/MM/yyyy'), ''), ' | ') AS hist
		FROM
			micromedicao.hidrometro hid
			LEFT JOIN micromedicao.hidrometro_inst_hist his ON his.hidr_id = hid.hidr_id
		GROUP BY 1
	) AS hist_inst ON hist_inst.hidr_id = hid.hidr_id
--WHERE
	--LEFT(hid.hidr_nnhidrometro, 4) IN ('Y13B','Y14B','A13B','A14B') AND
	--hid.hidr_dtaquisicao >= '2013-01-01' AND hid.hidr_dtaquisicao < '2015-01-01'