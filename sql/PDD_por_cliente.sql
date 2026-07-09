select
 clie.clie_nmcliente as "Nome Cliente",
 clie.clie_id as "Id Cliente",
 clieR.clie_nmcliente as "Nome Responsavel",
 coalesce(
  regexp_replace(clie.clie_nncpf, '(\d{3})(\d{3})(\d{3})(\d{2})', '\1.\2.\3-\4'), 
  regexp_replace(clie.clie_nncnpj, '(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})', '\1.\2.\3/\4-\5')
 ) as "CPF / CNPJ",
 cnta.imov_id as "Matricula",
 cnta.loca_id as "Id Localidade",
 catg.catg_dscategoria as "Categoria",
 scat.scat_dssubcategoria as "Subcategoria",
 last.last_dsligacaoaguasituacao as "Agua",
 hidrA.hidr_nnhidrometro as "Hidrometro Agua",
 lest.lest_dsligacaoesgotosituacao as "Esgoto",
 hidrP.hidr_nnhidrometro as "Hidrometro Poco",
 count(cnta.cnta_id) as "Total Doc.",
 to_char(sum(cnta.cnta_vlagua + 
             cnta.cnta_vlesgoto +
             cnta.cnta_vldebitos -
             cnta.cnta_vlimpostos - 
             cnta.cnta_vlcreditos), '999G999G990D00') as "Valor Debito",
 (case
  when (current_date - cnta.cnta_dtvencimentoconta <= 730 and catg.catg_dscategoria <> 'PUBLICO') then '01 - DE 180 DIAS ATE 02 ANOS'
  when (current_date - cnta.cnta_dtvencimentoconta <= 1460 and catg.catg_dscategoria <> 'PUBLICO') then '02 - DE 02 ANOS ATE 04 ANOS'
  when (current_date - cnta.cnta_dtvencimentoconta <= 2190 and catg.catg_dscategoria <> 'PUBLICO') then '03 - DE 04 ANOS ATE 06 ANOS'
  when (current_date - cnta.cnta_dtvencimentoconta <= 2920 and catg.catg_dscategoria <> 'PUBLICO') then '04 - DE 06 ANOS ATE 08 ANOS'
  when (current_date - cnta.cnta_dtvencimentoconta <= 3650 and catg.catg_dscategoria <> 'PUBLICO') then '05 - DE 08 ANOS ATE 10 ANOS'
  when (current_date - cnta.cnta_dtvencimentoconta > 3650 and catg.catg_dscategoria <> 'PUBLICO') then '06 - PRESCRITO'
  when (current_date - cnta.cnta_dtvencimentoconta <= 1095 and catg.catg_dscategoria = 'PUBLICO') then '01 - DE 180 DIAS ATE 03 ANOS'
  when (current_date - cnta.cnta_dtvencimentoconta <= 1825 and catg.catg_dscategoria = 'PUBLICO') then '02 - DE 03 ANOS ATE 05 ANOS'
  when (current_date - cnta.cnta_dtvencimentoconta > 1825 and catg.catg_dscategoria = 'PUBLICO') then '03 - PRESCRITO'
  end) as "Nivel PDD", 
  to_char(iscb.iscb_dtimplantacaocobranca, 'DD/MM/YYYY') as "Data Negativacao"
                          
from
 cadastro.cliente clie
 inner join cadastro.cliente_conta clct on clct.clie_id = clie.clie_id and clct.crtp_id = 2
 inner join faturamento.conta cnta on cnta.cnta_id = clct.cnta_id 
 left join cadastro.cliente_conta clctR on clctR.cnta_id = cnta.cnta_id and clctR.crtp_id = 3 --(definir o cliente responsável através do cliente tipo 3)
 left join cadastro.cliente clieR on clieR.clie_id = clctR.clie_id
 inner join faturamento.conta_categoria ctcg on ctcg.cnta_id = cnta.cnta_id
 inner join cadastro.categoria catg on catg.catg_id = ctcg.catg_id
 inner join cadastro.subcategoria scat on scat.scat_id = ctcg.scat_id
 inner join atendimentopublico.ligacao_agua_situacao last on last.last_id = cnta.last_id
 inner join atendimentopublico.ligacao_esgoto_situacao lest on lest.lest_id = cnta.lest_id
 left join micromedicao.hidrometro_inst_hist hidiP on hidiP.imov_id = cnta.imov_id and hidiP.hidi_dtretiradahidrometro is null
 left join micromedicao.hidrometro hidrP on hidrP.hidr_id = hidiP.hidr_id
 left join micromedicao.hidrometro_inst_hist hidiA on hidiA.lagu_id = cnta.imov_id and hidiA.hidi_dtretiradahidrometro is null
 left join micromedicao.hidrometro hidrA on hidrA.hidr_id = hidiA.hidr_id
 left join cadastro.imovel_cobranca_situacao iscb on iscb.imov_id = cnta.imov_id and iscb.clie_id = clie.clie_id and iscb.cbst_id = 26 and iscb.iscb_dtretiradacobranca is null

where
 cnta.dcst_idatual in (0,1,2) -- Debito_credito_situacao (normal / retificada / incluida)
 --and clie.clie_id in (11876907, 11807895, 11754404, 11909087)
 --and clie.clie_id in(11754404, 11909087)
 and not exists (select pgmt.cnta_id from arrecadacao.pagamento pgmt where pgmt.cnta_id = cnta.cnta_id)
 and (cnta.cnta_dtrevisao is null or cnta.cmrv_id in (102,107)) -- Motivo_Revisao (antiguidade / transf titularidade)
 and current_date - cnta.cnta_dtvencimentoconta >= 180
 --and cnta.imov_id in (5888930, 42030)
group by 
 "Nome Cliente", "Id Cliente", "Nome Responsavel", "CPF / CNPJ", "Matricula", "Id Localidade", "Categoria", "Subcategoria", "Agua", "Hidrometro Agua", "Esgoto", "Hidrometro Poco", "Nivel PDD", "Data Negativacao"
order by
 "Nome Cliente", "Matricula", "Nivel PDD";