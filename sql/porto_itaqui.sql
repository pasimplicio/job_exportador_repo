--ref 202408

select
	imov.imov_id as "matricula",
	ftgr.ftgr_id as "grupo faturamento",
	hidi.hidi_dtinstalacaohidrometro as "data instalacao",
	mcpf.mcpf_ammovimento as "referencia",
	date(mcpf.mcpf_tmleitura) as "dt leitura",
	mcpf.mcpf_nnleiturahidrometro as "leitura hidrometro",
	ltan.ltan_dsleituraanormalidade as "anormalidade leitura",
	mcpf.mcpf_nnconsumomedido as "consumo medido",
	cstp.cstp_dsconsumotipo as "tipo consumo",
	mcpf.mcpf_nnconsumocobrado as "consumo cobrado",
	csan.csan_dsconsumoanormalidade as "anormalidade consumo",
	to_char(conta.valor, '999G999G990D00') as "valor conta",
	conta.vencimento as "vencimento conta",
	conta.tipoCOnta as "tipo conta",
	to_char(pagto.valorPag, '999G999G990D00') as "valor pago",
	pagto.dtPag as "data pagamento"
from
	cadastro.imovel imov
	inner join cadastro.quadra qdra on qdra.qdra_id = imov.qdra_id
	inner join micromedicao.rota rota on rota.rota_id = qdra.rota_id
	inner join faturamento.faturamento_grupo ftgr on ftgr.ftgr_id = rota.ftgr_id 
	left join micromedicao.hidrometro_inst_hist hidi on hidi.lagu_id = imov.imov_id and hidi.hidi_dtretiradahidrometro is null
	left join faturamento.mov_conta_prefaturada mcpf on mcpf.imov_id = imov.imov_id and mcpf.medt_id = 1 and mcpf.mcpf_ammovimento = ${VAR_REFERENCIA}
	left join micromedicao.leitura_anormalidade ltan on ltan.ltan_id = mcpf.ltan_id
	left join micromedicao.consumo_tipo cstp on cstp.cstp_id = mcpf.cstp_id
	left join micromedicao.consumo_anormalidade csan on csan.csan_id = mcpf.csan_id
	left join (
		select
			imov_id,
			cnta.cnta_amreferenciaconta as referencia,
			sum(cnta.cnta_vlagua + cnta.cnta_vlesgoto + cnta.cnta_vldebitos - cnta.cnta_vlcreditos - cnta.cnta_vlimpostos) as valor,
			cnta.cnta_dtvencimentoconta as vencimento,
			dcst.dcst_dsdebitocreditosituacao as tipoConta
		from
			faturamento.conta cnta
			inner join faturamento.debito_credito_situacao dcst on dcst.dcst_id = cnta.dcst_idatual
		where
			dcst.dcst_id in (0, 1, 2)
			and cnta.cnta_amreferenciaconta = ${VAR_REFERENCIA}
        group by imov_id, referencia, vencimento, tipoConta
		union
		select
			imov_id,
			cnhi.cnhi_amreferenciaconta as referencia,
			sum(cnhi.cnhi_vlagua + cnhi.cnhi_vlesgoto + cnhi.cnhi_vldebitos - cnhi.cnhi_vlcreditos - cnhi.cnhi_vlimpostos) as valor,
			cnhi.cnhi_dtvencimentoconta as vencimento,
			dcst.dcst_dsdebitocreditosituacao as tipoConta
		from
			faturamento.conta_historico cnhi
			inner join faturamento.debito_credito_situacao dcst on dcst.dcst_id = cnhi.dcst_idatual
		where
			dcst.dcst_id in (0, 1, 2)
			and cnhi.cnhi_amreferenciaconta = ${VAR_REFERENCIA}
        group by imov_id, referencia, vencimento, tipoConta
	) as conta on conta.imov_id = imov.imov_id
	left join (
		select
			imov_id,
			pgmt.pgmt_amreferenciapagamento as referenciaPag,
			pgmt.pgmt_vlpagamento as valorPag,
			pgmt.pgmt_dtpagamento as dtPag
  		from	
			arrecadacao.pagamento pgmt
		where
			pgmt.pgmt_amreferenciapagamento = ${VAR_REFERENCIA}
                        and pgmt.pgst_idatual <> 1
		union
		select
			imov_id,
			pghi.pghi_amreferenciapagamento as referenciaPag,
			pghi.pghi_vlpagamento as valorPag,
			pghi.pghi_dtpagamento as dtPag
  		from	
			arrecadacao.pagamento_historico pghi
		where
			pghi.pghi_amreferenciapagamento = ${VAR_REFERENCIA}
                        and pghi.pgst_idatual <> 1
	) as pagto on pagto.imov_id = imov.imov_id
where
	imov.imov_icexclusao = 2
	and ftgr.ftgr_id = 898
	--and imov.imov_id in (7010460, 1036912)
order by "matricula"

	
