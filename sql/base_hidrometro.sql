-- VAR_REFERENCIA
select
	imov.imov_id as "matricula",
	catg.catg_dscategoria as "categoria",
	imov.imov_qteconomia as "numero_economias",
	imov.loca_id as "cod_localidade",
	bair.bair_nmbairro as "bairro",
	diop.diop_dsdistritooperacional as "zona_abastecimento",
	to_char(mcpf.mcpf_nncoordenadax,'990D999999999999999') as "latitude",
	to_char(mcpf.mcpf_nncoordenaday,'990D999999999999999') as "longitude",
	hidr.hidr_nnhidrometro as "numero_hd",
	hidr.hidr_nnanofabricacao as "ano_fabricacao",
	hicm.hicm_dshidrclassemetrologica as "classe_metrologica",
	hidm.hidm_dshidrometrodiametro as "diametro_hd",
	hidi.hidi_dtinstalacaohidrometro as "data_instalacao_hd",
	fatur.referencia as "referencia",
	fatur.consAgua as "consumo_agua",
	fatur.consEsgoto as "consumo_esgoto",
	csan.csan_dsconsumoanormalidade as "anormalidade_consumo",
	ltan.ltan_dsleituraanormalidade AS "anormalidade_leitura"
	
from
	cadastro.imovel imov
	left join cadastro.quadra qdra on qdra.qdra_id = imov.qdra_id
	left join cadastro.logradouro_bairro lgbr on lgbr.lgbr_id = imov.lgbr_id
	left join cadastro.bairro bair on bair.bair_id = lgbr.bair_id
	left join operacional.distrito_operacional diop on diop.diop_id = qdra.diop_id
	inner join micromedicao.hidrometro_inst_hist hidi on hidi.lagu_id = imov.imov_id
	left join faturamento.mov_conta_prefaturada mcpf on mcpf.imov_id = imov.imov_id and mcpf.mcpf_ammovimento = VAR_REFERENCIA and mcpf.medt_id = 1
	left join micromedicao.consumo_historico mich on mich.imov_id = imov.imov_id and mich.cshi_amfaturamento = VAR_REFERENCIA and mich.lgti_id = 1
	left join micromedicao.consumo_anormalidade csan on csan.csan_id = mich.csan_id 
	left join micromedicao.medicao_historico mdhi on mdhi.hidi_id = hidi.hidi_id and mdhi.mdhi_amleitura = VAR_REFERENCIA
	left join micromedicao.leitura_anormalidade ltan on ltan.ltan_id = mdhi.ltan_idleitanorminformada
	inner join micromedicao.hidrometro hidr on hidr.hidr_id = hidi.hidr_id
	inner join micromedicao.hidrometro_classe_metrlg hicm on hicm.hicm_id = hidr.hicm_id
	inner join micromedicao.hidrometro_diametro hidm on hidm.hidm_id = hidr.hidm_id
	inner join cadastro.categoria catg on catg.catg_id = imov.imov_idcategoriaprincipal
	inner join (
			select
				imov_id,
				cnta.cnta_nnconsumoagua as consAgua,
				cnta.cnta_nnconsumoesgoto as consEsgoto,
				cnta.cnta_amreferenciaconta as referencia
			from
				faturamento.conta cnta
			where
				cnta.cnta_amreferenciaconta = VAR_REFERENCIA
				and cnta.dcst_idatual <> 4
			union all
			select
				imov_id,
				cnhi.cnhi_nnconsumoagua as consAgua,
				cnhi.cnhi_nnconsumoesgoto as consEsgoto,
				cnhi.cnhi_amreferenciaconta as referencia
			from
				faturamento.conta_historico cnhi
			where
				cnhi.cnhi_amreferenciaconta = VAR_REFERENCIA
				and cnhi.dcst_idatual <> 4
	)as fatur on fatur.imov_id = imov.imov_id
where
	hidi.hidi_dtretiradahidrometro is null
	and hidi.medt_id = 1
	--and hidi.lagu_id = 116

order by 1


/*

operacional.distrito_operacional diop.diop_dsdistritooperacional diop.diop_id


select
	*
from
	micromedicao.hidrometro
where
	hidr_id = 438666

select
	*
from
	micromedicao.hidrometro_inst_hist hidi
where
	hidi.hidi_dtretiradahidrometro is null
	and hidi.medt_id = 1
	and hidi.lagu_id = 5340438
*/