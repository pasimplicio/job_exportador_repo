--ref 202408

select
	imov.imov_id as "matricula",
	--ftgr.ftgr_id as "grupo faturamento",
	hidi.hidi_dtinstalacaohidrometro as "data instalacao",
	--mcpf.mcpf_ammovimento as "referencia",
	--date(mcpf.mcpf_tmleitura) as "dt leitura",
	--mcpf.mcpf_nnleiturahidrometro as "leitura hidrometro",
	--ltan.ltan_dsleituraanormalidade as "anormalidade leitura",
	sum(case mcpf.mcpf_ammovimento when 202408 then mcpf.mcpf_nnconsumomedido end) as "consumo medido 08/24",
	sum(case mcpf.mcpf_ammovimento when 202409 then mcpf.mcpf_nnconsumomedido end) as "consumo medido 09/24",
	sum(case mcpf.mcpf_ammovimento when 202410 then mcpf.mcpf_nnconsumomedido end) as "consumo medido 10/24",
	sum(case mcpf.mcpf_ammovimento when 202411 then mcpf.mcpf_nnconsumomedido end) as "consumo medido 11/24",
	sum(case mcpf.mcpf_ammovimento when 202412 then mcpf.mcpf_nnconsumomedido end) as "consumo medido 12/24",
	sum(case mcpf.mcpf_ammovimento when 202501 then mcpf.mcpf_nnconsumomedido end) as "consumo medido 01/25",
	sum(case mcpf.mcpf_ammovimento when 202502 then mcpf.mcpf_nnconsumomedido end) as "consumo medido 02/25",
	sum(case mcpf.mcpf_ammovimento when 202503 then mcpf.mcpf_nnconsumomedido end) as "consumo medido 03/25",
	sum(case mcpf.mcpf_ammovimento when 202504 then mcpf.mcpf_nnconsumomedido end) as "consumo medido 04/25",
	sum(case mcpf.mcpf_ammovimento when 202505 then mcpf.mcpf_nnconsumomedido end) as "consumo medido 05/25",
	sum(case mcpf.mcpf_ammovimento when 202506 then mcpf.mcpf_nnconsumomedido end) as "consumo medido 06/25",
	sum(case mcpf.mcpf_ammovimento when 202507 then mcpf.mcpf_nnconsumomedido end) as "consumo medido 07/25",
	sum(case mcpf.mcpf_ammovimento when 202508 then mcpf.mcpf_nnconsumomedido end) as "consumo medido 08/25",	
	sum(case mcpf.mcpf_ammovimento when 202509 then mcpf.mcpf_nnconsumomedido end) as "consumo medido 09/25",
	sum(case mcpf.mcpf_ammovimento when 202510 then mcpf.mcpf_nnconsumomedido end) as "consumo medido 10/25",	
	--cstp.cstp_dsconsumotipo as "tipo consumo",
	--mcpf.mcpf_nnconsumocobrado as "consumo cobrado",
	--csan.csan_dsconsumoanormalidade as "anormalidade consumo",
	to_char(sum(case conta.referencia when 202408 then conta.valor end), '999G999G990D00') as "valor conta 08/24",
	to_char(sum(case conta.referencia when 202409 then conta.valor end), '999G999G990D00') as "valor conta 09/24",
	to_char(sum(case conta.referencia when 202410 then conta.valor end), '999G999G990D00') as "valor conta 10/24",
	to_char(sum(case conta.referencia when 202411 then conta.valor end), '999G999G990D00') as "valor conta 11/24",
	to_char(sum(case conta.referencia when 202412 then conta.valor end), '999G999G990D00') as "valor conta 12/24",
	to_char(sum(case conta.referencia when 202501 then conta.valor end), '999G999G990D00') as "valor conta 01/25",
	to_char(sum(case conta.referencia when 202502 then conta.valor end), '999G999G990D00') as "valor conta 02/25",
	to_char(sum(case conta.referencia when 202503 then conta.valor end), '999G999G990D00') as "valor conta 03/25",
	to_char(sum(case conta.referencia when 202504 then conta.valor end), '999G999G990D00') as "valor conta 04/25",
	to_char(sum(case conta.referencia when 202505 then conta.valor end), '999G999G990D00') as "valor conta 05/25",
	to_char(sum(case conta.referencia when 202506 then conta.valor end), '999G999G990D00') as "valor conta 06/25",
	to_char(sum(case conta.referencia when 202507 then conta.valor end), '999G999G990D00') as "valor conta 07/25",
	to_char(sum(case conta.referencia when 202508 then conta.valor end), '999G999G990D00') as "valor conta 08/25",
	to_char(sum(case conta.referencia when 202509 then conta.valor end), '999G999G990D00') as "valor conta 09/25",
	to_char(sum(case conta.referencia when 202510 then conta.valor end), '999G999G990D00') as "valor conta 10/25",			
	--conta.vencimento as "vencimento conta",
	--conta.tipoCOnta as "tipo conta",
	to_char(sum(case pagto.referencia when 202408 then pagto.valor end), '999G999G990D00') as "valor pago 08/24",
	to_char(sum(case pagto.referencia when 202409 then pagto.valor end), '999G999G990D00') as "valor pago 09/24",
	to_char(sum(case pagto.referencia when 202410 then pagto.valor end), '999G999G990D00') as "valor pago 10/24",
	to_char(sum(case pagto.referencia when 202411 then pagto.valor end), '999G999G990D00') as "valor pago 11/24",
	to_char(sum(case pagto.referencia when 202412 then pagto.valor end), '999G999G990D00') as "valor pago 12/24",
	to_char(sum(case pagto.referencia when 202501 then pagto.valor end), '999G999G990D00') as "valor pago 01/25",
	to_char(sum(case pagto.referencia when 202502 then pagto.valor end), '999G999G990D00') as "valor pago 02/25",
	to_char(sum(case pagto.referencia when 202503 then pagto.valor end), '999G999G990D00') as "valor pago 03/25",
	to_char(sum(case pagto.referencia when 202504 then pagto.valor end), '999G999G990D00') as "valor pago 04/25",
	to_char(sum(case pagto.referencia when 202505 then pagto.valor end), '999G999G990D00') as "valor pago 05/25",
	to_char(sum(case pagto.referencia when 202506 then pagto.valor end), '999G999G990D00') as "valor pago 06/25",
	to_char(sum(case pagto.referencia when 202507 then pagto.valor end), '999G999G990D00') as "valor pago 07/25",
	to_char(sum(case pagto.referencia when 202508 then pagto.valor end), '999G999G990D00') as "valor pago 08/25",
	to_char(sum(case pagto.referencia when 202509 then pagto.valor end), '999G999G990D00') as "valor pago 09/25",	
	to_char(sum(case pagto.referencia when 202510 then pagto.valor end), '999G999G990D00') as "valor pago 10/25"
	--pagto.dtPag as "data pagamento"
from
	cadastro.imovel imov
	inner join cadastro.quadra qdra on qdra.qdra_id = imov.qdra_id
	inner join micromedicao.rota rota on rota.rota_id = qdra.rota_id
	inner join faturamento.faturamento_grupo ftgr on ftgr.ftgr_id = rota.ftgr_id 
	left join micromedicao.hidrometro_inst_hist hidi on hidi.lagu_id = imov.imov_id and hidi.hidi_dtretiradahidrometro is null
	
	left join (
		select
			imov_id,
			cnta.cnta_amreferenciaconta as referencia,
			sum(cnta.cnta_vlagua + cnta.cnta_vlesgoto + cnta.cnta_vldebitos - cnta.cnta_vlcreditos - cnta.cnta_vlimpostos) as valor,
			cnta.cnta_dtvencimentoconta as vencimento
			--dcst.dcst_dsdebitocreditosituacao as tipoConta
		from
			faturamento.conta cnta
		where
			cnta.dcst_idatual in (0, 1, 2)
			and cnta.cnta_amreferenciaconta >= 202408
		group by imov_id, referencia, vencimento
		union
		select
			imov_id,
			cnhi.cnhi_amreferenciaconta as referencia,
			sum(cnhi.cnhi_vlagua + cnhi.cnhi_vlesgoto + cnhi.cnhi_vldebitos - cnhi.cnhi_vlcreditos - cnhi.cnhi_vlimpostos) as valor,
			cnhi.cnhi_dtvencimentoconta as vencimento
			--dcst.dcst_dsdebitocreditosituacao as tipoConta
		from
			faturamento.conta_historico cnhi
		where
			cnhi.dcst_idatual in (0, 1, 2)
			and cnhi.cnhi_amreferenciaconta >= 202408
		group by imov_id, referencia, vencimento
	) as conta on conta.imov_id = imov.imov_id
	left join (
		select
			imov_id,
			pgmt.pgmt_amreferenciapagamento as referencia,
			pgmt.pgmt_vlpagamento as valor,
			pgmt.pgmt_dtpagamento as dtPag
  		from	
			arrecadacao.pagamento pgmt
		where
			pgmt.pgst_idatual <> 1
		union
		select
			imov_id,
			pghi.pghi_amreferenciapagamento as referencia,
			pghi.pghi_vlpagamento as valor,
			pghi.pghi_dtpagamento as dtPag
  		from	
			arrecadacao.pagamento_historico pghi
		where
			pghi.pgst_idatual <> 1
	) as pagto on pagto.imov_id = imov.imov_id and conta.referencia = pagto.referencia
	
	left join faturamento.mov_conta_prefaturada mcpf on mcpf.imov_id = imov.imov_id and mcpf.medt_id = 1 and mcpf.mcpf_ammovimento = conta.referencia
	--left join micromedicao.leitura_anormalidade ltan on ltan.ltan_id = mcpf.ltan_id
	--left join micromedicao.consumo_tipo cstp on cstp.cstp_id = mcpf.cstp_id
	--left join micromedicao.consumo_anormalidade csan on csan.csan_id = mcpf.csan_id
where
	imov.imov_icexclusao = 2
	and ftgr.ftgr_id = 898
	--and imov.imov_id in (7010460, 1036912)
group by 1,2
order by "matricula"

	
