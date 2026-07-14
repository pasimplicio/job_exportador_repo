select distinct 
        mre.mrem_ammovimento as "REFERENCIA",
        clie.clie_nmcliente as "LEITURISTA",
	mre.imov_id as "MATRICULA",
	mcpf.mcpf_nncoordenadax as "LAT IMPRESSAO",
	mcpf.mcpf_nncoordenaday as "LON IMPRESSAO",
	uneg.uneg_nmunidadenegocio as "UNIDADE",
	loca.loca_nmlocalidade as "LOCALIDADE",
	mre.ftgr_id as "GRP FATURAMENTO",
	trim(to_char(mre.mrem_cdsetorcomercial,'000')) as "SETOR",
	mre.mrem_cdrota as "ROTA",
	trim( to_char( mre.mrem_nnquadra, '000' )) as "QUADRA",
	mre.mrem_nnsequencialrota as "SEQUENCIA",
	trim(to_char(imo.imov_nnlote,'0000')) as "LOTE",
	trim(to_char(imo.imov_nnsublote,'000')) as "SUBLOTE",
	mcpf.mcpf_icsituacaoleitura as "IC SIT LEITURA",
	mre.mrem_nnleituraanterior as "LEITURA ANTERIOR",
	(case
		when la.ltan_id is null then coalesce(mre.mrem_nnleiturahidrometro::text, 'NAO MEDIDO') 
		else mre.mrem_nnleiturahidrometro::text
	end) as "LEITURA ATUAL", 
	trim(to_char(la.ltan_id,'000')) || ' - ' || la.ltan_dsleituraanormalidade as "ANORM LEITURA",
	ca.csan_dsabrvconsanormalidade as "ANORM CONSUMO",
	ch.cshi_nnconsumofaturadomes as "CONSUMO",
	to_char(mre.mrem_tmleitura, 'DD/MM/YYYY HH24:MI:SS') as "DATA HORA LEITURA",
	to_char(mre.mrem_tmprocessamento, 'DD/MM/YYYY HH24:MI:SS') as "DATA HORA RECEBIMENTO",
	(case mcpf.mcpf_icemissaoconta 
		when 1 then 'SIM'
		when 2 then 'NAO'
		else 'OUTRO'
	end) as "IMPRESSAO",
	(case imo.icte_id
	when '1' then 'ENVIAR PARA O CLIENTE RESPONSAVEL-EMITE CONTA' 
	when '2' then 'ENVIAR PARA O IMOVEL'
	when '3' then 'NAO PAGÁVEL P/ O IMÓVEL E PAGAVEL P/ O RESPONSAVEL'
	when '4' then 'ENVIAR PARA EMAIL'
	when '5' then 'ENVIAR PARA IMOVEL E PARA EMAIL'
        when '9' then 'ENVIAR PARA O CLIENTE RESPONSAVEL-EMITE CONTA'
        end) as "OPCAO ENVIO CONTA"
from   
        micromedicao.movimento_roteiro_empr mre   
        left join micromedicao.consumo_historico ch on (ch.imov_id = mre.imov_id and mre.mrem_ammovimento = ch.cshi_amfaturamento and ch.lgti_id = 1)  
        left join micromedicao.consumo_anormalidade ca on ca.csan_id = ch.csan_id    
        inner join faturamento.mov_conta_prefaturada mcpf on ( mre.imov_id = mcpf.imov_id and mre.mrem_ammovimento = mcpf.mcpf_ammovimento and ( mre.medt_id = mcpf.medt_id or mre.medt_id is null  ) )   
        left join faturamento.conta cnta on ( cnta.cnta_id = mcpf.cnta_id )   
        left join faturamento.conta_historico cnta_histo on ( cnta_histo.cnta_id = mcpf.cnta_id )   
        inner join cadastro.imovel imo on ( imo.imov_id = mcpf.imov_id )   
        left join atendimentopublico.ligacao_agua lagu on ( lagu.lagu_id = imo.imov_id )   
        left join micromedicao.leitura_anormalidade la on la.ltan_id = mre.ltan_id
        inner join micromedicao.leiturista leit on leit.leit_id = mre.leit_id
        inner join cadastro.cliente clie on clie.clie_id = leit.clie_id
        inner join cadastro.localidade loca on loca.loca_id = mre.loca_id
        inner join cadastro.unidade_negocio uneg on uneg.uneg_id = loca.uneg_id
        --inner join cadastro.quadra qdra on qdra.qdra_id = imo.qdra_id
where   
        mre.mrem_ammovimento = ${VAR_REFERENCIA} 
        --and mre.rota_id = 320 
order by   
      "REFERENCIA","LOCALIDADE","SETOR","ROTA","SEQUENCIA","SUBLOTE";