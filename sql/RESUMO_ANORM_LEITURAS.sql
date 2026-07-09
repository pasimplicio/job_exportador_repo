SELECT
	mdh.mdhi_amleitura AS "REFERENCIA",
	loc.uneg_id AS "GERENCIA",
	une.uneg_nmunidadenegocio AS "NOME UNIDADE",
	imo.loca_id AS "LOCALIDADE",
	loc.loca_nmlocalidade AS "NOME LOCALIDADE",
	sec.stcm_cdsetorcomercial AS "SETOR COMERCIAL",
	lts.ltst_dsleiturasituacao AS "SITUACAO LEITURA",
	lai.ltan_dsleituraanormalidade AS "ANORM LEIT INF",
	laf.ltan_dsleituraanormalidade AS "ANORM LEIT FAT",
	COUNT(DISTINCT mdh.mdhi_id) AS "QTD"
FROM
	micromedicao.medicao_historico mdh
	INNER JOIN cadastro.imovel imo ON mdh.lagu_id = imo.imov_id
	INNER JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
	INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
	INNER JOIN cadastro.setor_comercial sec ON imo.stcm_id = sec.stcm_id
	LEFT JOIN micromedicao.leitura_situacao lts ON lts.ltst_id = mdh.ltst_idleiturasituacaoatual
	LEFT JOIN micromedicao.leitura_anormalidade lai ON lai.ltan_id = mdh.ltan_idleitanorminformada
	LEFT JOIN micromedicao.leitura_anormalidade laf ON laf.ltan_id = mdh.ltan_idleitanormfatmt
WHERE
	mdh.mdhi_amleitura >= 201801
GROUP BY 1,2,3,4,5,6,7,8,9