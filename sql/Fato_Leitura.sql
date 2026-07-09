
-- trocar a referencia 202311

SELECT 
	imo.imov_id AS "MATRICULA",
	mdh.mdhi_amleitura AS "REFERENCIA",
	mdh.mdhi_dtleitantfatmt AS "DATA LEIT ANTERIOR FATURADA",
	mdh.mdhi_nnleitantfatmt AS "LEIT ANTERIOR FATURADA",
	mdh.mdhi_nnleitantinformada AS "LEIT ANTERIOR INFORMADA",
	mdh.mdhi_dtleituraatualinformada AS "DATA LEIT ATUAL INFORMADA",
	mdh.mdhi_nnleituraatualinformada AS "LEIT ATUAL INFORMADA",
	mdh.mdhi_dtleituraatualfaturamento AS "DATA LEIT ATUAL FATURADA",
	mdh.mdhi_nnleituraatualfaturamento AS "LEIT ATUAL FATURADA",
	mdh.mdhi_nnconsumomedidomes AS "CONSUMO MEDIDO",
	mdh.mdhi_nnconsumoinformado AS "CONSUMO INFORMADO",
	mdh.mdhi_nnconsumomediohidrometro AS "CONSUMO MEDIO HD",
	mdh.mdhi_dtleituracampo AS "DATA DA LEITURA CAMPO",
	mdh.mdhi_nnleituracampo AS "LEITURA DE CAMPO",
	lts.ltst_dsleiturasituacao AS "SITUACAO LEITURA",
	lai.ltan_dsleituraanormalidade AS "ANORM LEIT INF",
	laf.ltan_dsleituraanormalidade AS "ANORM LEIT FAT",
	cost_a1.cstp_dsconsumotipo AS "TIPO CONSUMO AGUA",
	cosa_a1.csan_dsconsumoanormalidade AS "ANORM CONS AGUA"
	
FROM 
	cadastro.imovel imo
	LEFT JOIN micromedicao.medicao_historico mdh ON mdh.lagu_id = imo.imov_id --AND mdh.mdhi_amleitura = VAR_REFERENCIA
	LEFT JOIN micromedicao.leitura_situacao lts ON lts.ltst_id = mdh.ltst_idleiturasituacaoatual
	LEFT JOIN micromedicao.leitura_anormalidade lai ON lai.ltan_id = mdh.ltan_idleitanorminformada
	LEFT JOIN micromedicao.leitura_anormalidade laf ON laf.ltan_id = mdh.ltan_idleitanormfatmt
	LEFT JOIN micromedicao.consumo_historico cosh_a1 ON cosh_a1.imov_id = imo.imov_id AND cosh_a1.cshi_amfaturamento = mdh.mdhi_amleitura AND cosh_a1.lgti_id = 1
	LEFT JOIN micromedicao.consumo_tipo cost_a1 ON cost_a1.cstp_id = cosh_a1.cstp_id
	LEFT JOIN micromedicao.consumo_anormalidade cosa_a1 ON cosa_a1.csan_id = cosh_a1.csan_id
WHERE
	imo.imov_icexclusao = 2 
	AND mdh.mdhi_amleitura >= 202311
	--AND  imo.imov_id = 82600

