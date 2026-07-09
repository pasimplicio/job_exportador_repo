select distinct
    imov.imov_id as "matricula",
    date(opef.opef_tmultimaalteracao) as "data operacao",
    oper.oper_dsoperacao as "nome operacao",
    count(pghi.pghi_id) as "qtde conta paga apos operacao",
    to_char(sum(pghi.pghi_vlpagamento),'999G999G990D00') as "valor pago apos operacao"
from
    cadastro.imovel imov
    inner join seguranca.operacao_efetuada opef on opef.opef_cnargumento = imov.imov_id
    inner join seguranca.operacao oper on oper.oper_id = opef.oper_id
    --inner join seguranca.tabela_linha_alteracao tbla on tbla.tref_id = opef.opef_id
   -- inner join seguranca.tab_linha_col_alteracao tbca on tbca.tbla_id = tbla.tbla_id
    --inner join seguranca.tabela_coluna tbco on tbco.tbco_id = tbca.tbco_id
    left join arrecadacao.pagamento_historico pghi on pghi.imov_id = opef.opef_cnargumento and pghi.pghi_dtpagamento >= date(opef.opef_tmultimaalteracao) and pghi.pgst_idatual in (0, 1) and pghi.dotp_id = 1
     --inner join faturamento.conta cnta on cnta.imov_id = imov.imov_id     
where
    oper.oper_id in (9)
    --and imov.imov_id in (30333, 15055981, 5568, 15059, 20770)
    and date(opef.opef_tmultimaalteracao) >= '2024-08-01'
    
   -- and tbco.tbco_id = 1776
   /* and tbco.tbco_id in (
        287, --imov_nnareaconstruida
        294, --lgbr_id
        295, --imov_qteconomia
        398, --last_id
        399, --lest_id
        1776 --imov_id(categoria)
     )*/
group by 1, 2, 3
order by imov.imov_id