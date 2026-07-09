--201910: Deve ser substituida pela referencia do faturamento que se deseja obter os dados
--VAR_UNIDADE: Deve ser substituida pelo id da unidade de onde se quer obter os dados

SELECT 
	imo.imov_id AS "MATRICULA",
	cli.clie_nmcliente AS "NOME",
	cli.clie_nncpf AS "CPF",
	cli.clie_nncnpj AS "CNPJ",
	(CASE cli.clie_iccpfcnpjvalidado
	WHEN 0 THEN 'NAO'
	WHEN 1 THEN 'SIM'
	ELSE 'NAO'
	END) AS "DOC VALIDADO",
	cli.clie_dsemail AS "EMAIL",
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
	hid.hidr_nnhidrometro AS "NR HID.",
	hid.hidr_nnanofabricacao AS "ANO HD",
	his.hidi_dtinstalacaohidrometro AS "DATA DE INSTALACAO HD.",
	hic.hicp_dshidrometrocapacidade AS "CAPACIDADE HD",
	hdi.hidm_dshidrometrodiametro AS "DIAMETRO HD",
	cob.cbst_dscobrancasituacao AS "SIT. COBRANCA",
	ics.iscb_dtimplantacaocobranca AS "DATA DE ENTRADA COBRANCA",
	cob_exi.cbst_dscobrancasituacao AS "SIT. COBRANCA",
	ics_exi.iscb_dtimplantacaocobranca AS "DATA DE ENTRADA COBRANCA",
	pags0.doctp AS "TIPO DOCUMENTO 201911",
	pags0.datapg AS "DATA PAGAMENTO 201911",
	pags0.qtd AS "QTD PAGAMENTOS 201911",
	pags0.valor AS "VALOR PAGAMENTO 201911",
	pags1.doctp AS "TIPO DOCUMENTO 201911 - 1",
	pags1.datapg AS "DATA PAGAMENTO 201911 - 1",
	pags1.qtd AS "QTD PAGAMENTOS 201911 - 1",
	pags1.valor AS "VALOR PAGAMENTO 201911 - 1",
	pags2.doctp AS "TIPO DOCUMENTO 201911 - 2",
	pags2.datapg AS "DATA PAGAMENTO 201911 - 2",
	pags2.qtd AS "QTD PAGAMENTOS 201911 - 2",
	pags2.valor AS "VALOR PAGAMENTO 201911 - 2",
	pags3.doctp AS "TIPO DOCUMENTO 201911 - 3",
	pags3.datapg AS "DATA PAGAMENTO 201911 - 3",
	pags3.qtd AS "QTD PAGAMENTOS 201911 - 3",
	pags3.valor AS "VALOR PAGAMENTO 201911 - 3"
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
	LEFT JOIN operacional.distrito_operacional dis ON dis.diop_id = qdr.diop_id
	LEFT JOIN cadastro.cliente_imovel cim2 ON cim2.imov_id = imo.imov_id AND cim2.clim_dtrelacaofim IS NULL AND cim2.crtp_id  = 3
	LEFT JOIN cadastro.cliente cli2 ON cli2.clie_id = cim2.clie_id
	LEFT JOIN cadastro.cliente cli3 ON cli3.clie_id = cli2.clie_cdclienteresponsavel
	LEFT JOIN cadastro.logradouro_cep lgc ON lgc.lgcp_id = imo.lgcp_id
	LEFT JOIN cadastro.cep cep ON cep.cep_id = lgc.cep_id
	LEFT JOIN cadastro.logradouro_tipo lgt ON lgt.lgtp_id = logr.lgtp_id
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
	LEFT JOIN (	SELECT
				pags.mat1 AS mat1,
				pags.doctp AS doctp,
				pags.datapg AS datapg,
				SUM(pags.qtd) AS qtd,
				SUM(pags.valor) AS valor
			FROM
				(SELECT 
						pag.imov_id AS mat1,
						dot.dotp_dsdocumentotipo AS doctp,
						pag.pgmt_dtpagamento AS datapg,
						COUNT(pag.pgmt_id) AS qtd,
						SUM(pag.pgmt_vlpagamento) AS valor
					FROM 
						arrecadacao.pagamento pag
						INNER JOIN cobranca.documento_tipo dot ON dot.dotp_id = pag.dotp_id
					WHERE
						pag.pgmt_amreferenciaarrecadacao = TO_CHAR(TO_DATE(201911,'yyyyMM') - INTERVAL '0MONTH','yyyyMM')::INT
						--AND pag.imov_id = 1414
					GROUP BY 1,2,3
				UNION
					SELECT 
						pag.imov_id AS mat1,
						dot.dotp_dsdocumentotipo AS doctp,
						pag.pghi_dtpagamento AS datapg,
						COUNT(pag.pghi_id) AS qtd,
						SUM(pag.pghi_vlpagamento) AS valor
					FROM 
						arrecadacao.pagamento_historico pag
						INNER JOIN cobranca.documento_tipo dot ON dot.dotp_id = pag.dotp_id
					WHERE
						pag.pghi_amreferenciaarrecadacao = TO_CHAR(TO_DATE(201911,'yyyyMM') - INTERVAL '0MONTH','yyyyMM')::INT
						--AND pag.imov_id = 1414
					GROUP BY 1,2,3) AS pags
			GROUP BY 1,2,3) AS pags0 ON pags0.mat1 = imo.imov_id
	LEFT JOIN (	SELECT
				pags.mat1 AS mat1,
				pags.doctp AS doctp,
				pags.datapg AS datapg,
				SUM(pags.qtd) AS qtd,
				SUM(pags.valor) AS valor
			FROM
				(SELECT 
						pag.imov_id AS mat1,
						dot.dotp_dsdocumentotipo AS doctp,
						pag.pgmt_dtpagamento AS datapg,
						COUNT(pag.pgmt_id) AS qtd,
						SUM(pag.pgmt_vlpagamento) AS valor
					FROM 
						arrecadacao.pagamento pag
						INNER JOIN cobranca.documento_tipo dot ON dot.dotp_id = pag.dotp_id
					WHERE
						pag.pgmt_amreferenciaarrecadacao = TO_CHAR(TO_DATE(201911,'yyyyMM') - INTERVAL '1MONTH','yyyyMM')::INT
						--AND pag.imov_id = 1414
					GROUP BY 1,2,3
				UNION
					SELECT 
						pag.imov_id AS mat1,
						dot.dotp_dsdocumentotipo AS doctp,
						pag.pghi_dtpagamento AS datapg,
						COUNT(pag.pghi_id) AS qtd,
						SUM(pag.pghi_vlpagamento) AS valor
					FROM 
						arrecadacao.pagamento_historico pag
						INNER JOIN cobranca.documento_tipo dot ON dot.dotp_id = pag.dotp_id
					WHERE
						pag.pghi_amreferenciaarrecadacao = TO_CHAR(TO_DATE(201911,'yyyyMM') - INTERVAL '1MONTH','yyyyMM')::INT
						--AND pag.imov_id = 1414
					GROUP BY 1,2,3) AS pags
			GROUP BY 1,2,3) AS pags1 ON pags1.mat1 = imo.imov_id
	LEFT JOIN (	SELECT
				pags.mat1 AS mat1,
				pags.doctp AS doctp,
				pags.datapg AS datapg,
				SUM(pags.qtd) AS qtd,
				SUM(pags.valor) AS valor
			FROM
				(SELECT 
						pag.imov_id AS mat1,
						dot.dotp_dsdocumentotipo AS doctp,
						pag.pgmt_dtpagamento AS datapg,
						COUNT(pag.pgmt_id) AS qtd,
						SUM(pag.pgmt_vlpagamento) AS valor
					FROM 
						arrecadacao.pagamento pag
						INNER JOIN cobranca.documento_tipo dot ON dot.dotp_id = pag.dotp_id
					WHERE
						pag.pgmt_amreferenciaarrecadacao = TO_CHAR(TO_DATE(201911,'yyyyMM') - INTERVAL '2MONTH','yyyyMM')::INT
						--AND pag.imov_id = 1414
					GROUP BY 1,2,3
				UNION
					SELECT 
						pag.imov_id AS mat1,
						dot.dotp_dsdocumentotipo AS doctp,
						pag.pghi_dtpagamento AS datapg,
						COUNT(pag.pghi_id) AS qtd,
						SUM(pag.pghi_vlpagamento) AS valor
					FROM 
						arrecadacao.pagamento_historico pag
						INNER JOIN cobranca.documento_tipo dot ON dot.dotp_id = pag.dotp_id
					WHERE
						pag.pghi_amreferenciaarrecadacao = TO_CHAR(TO_DATE(201911,'yyyyMM') - INTERVAL '2MONTH','yyyyMM')::INT
						--AND pag.imov_id = 1414
					GROUP BY 1,2,3) AS pags
			GROUP BY 1,2,3) AS pags2 ON pags2.mat1 = imo.imov_id
	LEFT JOIN (	SELECT
				pags.mat1 AS mat1,
				pags.doctp AS doctp,
				pags.datapg AS datapg,
				SUM(pags.qtd) AS qtd,
				SUM(pags.valor) AS valor
			FROM
				(SELECT 
						pag.imov_id AS mat1,
						dot.dotp_dsdocumentotipo AS doctp,
						pag.pgmt_dtpagamento AS datapg,
						COUNT(pag.pgmt_id) AS qtd,
						SUM(pag.pgmt_vlpagamento) AS valor
					FROM 
						arrecadacao.pagamento pag
						INNER JOIN cobranca.documento_tipo dot ON dot.dotp_id = pag.dotp_id
					WHERE
						pag.pgmt_amreferenciaarrecadacao = TO_CHAR(TO_DATE(201911,'yyyyMM') - INTERVAL '3MONTH','yyyyMM')::INT
						--AND pag.imov_id = 1414
					GROUP BY 1,2,3
				UNION
					SELECT 
						pag.imov_id AS mat1,
						dot.dotp_dsdocumentotipo AS doctp,
						pag.pghi_dtpagamento AS datapg,
						COUNT(pag.pghi_id) AS qtd,
						SUM(pag.pghi_vlpagamento) AS valor
					FROM 
						arrecadacao.pagamento_historico pag
						INNER JOIN cobranca.documento_tipo dot ON dot.dotp_id = pag.dotp_id
					WHERE
						pag.pghi_amreferenciaarrecadacao = TO_CHAR(TO_DATE(201911,'yyyyMM') - INTERVAL '3MONTH','yyyyMM')::INT
						--AND pag.imov_id = 1414
					GROUP BY 1,2,3) AS pags
			GROUP BY 1,2,3) AS pags3 ON pags3.mat1 = imo.imov_id
WHERE
	imo.imov_icexclusao = 2 AND
	(pags0.valor>0
	 OR pags1.valor>0
	 OR pags2.valor>0
	 OR pags3.valor>0)
ORDER BY "LOCALIDADE","SETOR COMERCIAL","ROTA","QUADRA","SEQUENCIA","SUB LOTE"