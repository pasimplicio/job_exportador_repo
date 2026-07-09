SELECT 
	con.mcpf_ammovimento AS "REFERENCIA",
	ltr.nome_leiturista_caema AS "LEITURISTA",
	--(TRIM(TO_CHAR(imo.loca_id,'000')) || '-' || TRIM(TO_CHAR(sec.stcm_cdsetorcomercial,'000')) || '-' || TRIM(TO_CHAR(qdr.qdra_nnquadra,'000'))|| '-' || TRIM(TO_CHAR(imo.imov_nnlote,'0000'))|| '-' || TRIM(TO_CHAR(imo.imov_nnsublote,'000'))) AS "INSCRICAO",
	con.imov_id AS "MATRICULA",
	une.uneg_nmunidadenegocio AS "UNIDADE",
	loc.loca_nmlocalidade AS "LOCALIDADE",
	ftg.ftgr_dsfaturamentogrupo AS "GRUPO FATURAMENTO",
	TRIM(TO_CHAR(sec.stcm_cdsetorcomercial,'000')) AS "SETOR COMERCIAL",
	rot.rota_cdrota AS "ROTA",
	TRIM(TO_CHAR(qdr.qdra_nnquadra,'000')) AS "QUADRA",
	imo.imov_nnsequencialrota AS "SEQ. ROTA",
	TRIM(TO_CHAR(imo.imov_nnlote,'0000')) AS "LOTE",
	TRIM(TO_CHAR(imo.imov_nnsublote,'000')) AS "SUB LOTE",
	con.mcpf_nnleituraanterior AS "LEITURA ANTERIOR",
	CASE
		WHEN lta.ltan_id IS NULL THEN COALESCE(con.mcpf_nnleiturahidrometro::TEXT, 'NAO MEDIDO') 
		ELSE con.mcpf_nnleiturahidrometro::TEXT
	END AS "LEITURA ATUAL",
	TRIM(TO_CHAR(lta.ltan_id,'000')) || ' - ' || lta.ltan_dsleituraanormalidade AS "ANORM LEITURA",
	csa.csan_dsabrvconsanormalidade AS "ANORM CONSUMO",
	con.mcpf_nnconsumocobrado AS "CONSUMO",
	TO_CHAR(con.mcpf_tmleitura, 'DD/MM/YYYY HH24:MI:SS') AS "DATA E HORA LEITURA",
	TO_CHAR(mre.mrem_tmprocessamento, 'DD/MM/YYYY HH24:MI:SS') AS "DATA E HORA RECEBIMENTO",
	CASE con.mcpf_icemissaoconta 
		WHEN 1 THEN 'SIM'
		WHEN 2 THEN 'NAO'
		ELSE 'OUTRO'
	END AS "IMPRESSAO",
	(CASE imo.icte_id
	WHEN '1' THEN 'ENVIAR PARA O CLIENTE RESPONSAVEL-EMITE CONTA' 
	WHEN '2' THEN 'ENVIAR PARA O IMOVEL'
	WHEN '3' THEN 'NAO PAGÁVEL P/ O IMÓVEL E PAGAVEL P/ O RESPONSAVEL'
	WHEN '4' THEN 'ENVIAR PARA EMAIL'
	WHEN '5' THEN 'ENVIAR PARA IMOVEL E PARA EMAIL'
	WHEN '9' THEN 'ENVIAR PARA O CLIENTE RESPONSAVEL-EMITE CONTA'
       END) 
       AS "OPCAO ENVIO CONTA"
	
FROM 
	faturamento.mov_conta_prefaturada con
	INNER JOIN cadastro.imovel imo ON imo.imov_id = con.imov_id
	INNER JOIN cadastro.localidade loc ON imo.loca_id = loc.loca_id
	INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
	INNER JOIN cadastro.setor_comercial sec ON imo.stcm_id = sec.stcm_id
	INNER JOIN cadastro.quadra qdr ON qdr.qdra_id = imo.qdra_id
	INNER JOIN micromedicao.rota rot ON rot.rota_id = qdr.rota_id
	INNER JOIN micromedicao.leiturista ltr ON ltr.leit_id = rot.leit_id
	INNER JOIN faturamento.faturamento_grupo ftg ON rot.ftgr_id = ftg.ftgr_id
	LEFT JOIN micromedicao.leitura_anormalidade lta ON lta.ltan_id = con.ltan_id
	LEFT JOIN micromedicao.consumo_anormalidade csa ON csa.csan_id = con.csan_id
	LEFT JOIN micromedicao.movimento_roteiro_empr mre ON mre.imov_id = con.imov_id AND mre.mrem_ammovimento = con.mcpf_ammovimento
WHERE 
	con.mcpf_ammovimento = VAR_REFERENCIA
	
ORDER BY "REFERENCIA","LOCALIDADE","SETOR COMERCIAL","ROTA","QUADRA","SEQ. ROTA","SUB LOTE";
	