select
	imov.imov_id as matricula,
	count(cnta.cnta_id) as "qtde atraso",
	to_char(sum(cnta.cnta_vlagua + cnta.cnta_vlesgoto + cnta.cnta_vldebitos - cnta.cnta_vlcreditos - cnta.cnta_vlimpostos), '999G999G990D00') as "valor atraso"
from
	cadastro.imovel imov
	inner join cadastro.quadra qdra on qdra.qdra_id = imov.qdra_id
	inner join micromedicao.rota rota on rota.rota_id = qdra.rota_id
	inner join faturamento.faturamento_grupo ftgr on ftgr.ftgr_id = rota.ftgr_id
	inner join faturamento.conta cnta on cnta.imov_id = imov.imov_id and cnta.cnta_dtvencimentoconta < current_date
where
	imov.imov_icexclusao = 2
	--and ftgr.ftgr_id = 898
	and cnta.dcst_idatual in (0,1,2) -- Debito_credito_situacao (normal / retificada / incluida)
	and not exists (select pgmt.cnta_id from arrecadacao.pagamento pgmt where pgmt.cnta_id = cnta.cnta_id)
	and cnta.cnta_dtrevisao is null 
group by 1