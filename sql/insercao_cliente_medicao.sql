select
    --imov.imov_id as matricula,
    clie.clie_id as cliente,
    to_char(operacao.ultAlt, 'DD/MM/YYYY') as "data operacao"
    --operacao.qtdePago as "qtde conta paga",
    --to_char(operacao.valorPago,'999G999G990D00') as "valor pago"
from
    cadastro.imovel imov
    inner join cadastro.cliente_imovel clim on clim.imov_id = imov.imov_id and clim.clim_dtrelacaofim is null and clim.clim_icnomeconta = 1
    inner join cadastro.cliente clie on clie.clie_id = clim.clie_id
    inner join (
        select
            opef.opef_cnargumento as clie,
            max(opef.opef_tmultimaalteracao) as ultAlt,
            pagHis.qtdePag + pagPgm.qtdePag as qtdePago,
            pagHis.valorPag + pagPgm.valorPag as valorPago
        from
            seguranca.operacao_efetuada opef
            inner join seguranca.operacao oper on oper.oper_id = opef.oper_id
            left join (
                select
                    pghi.imov_id as matPag,
                    coalesce(count(pghi.pghi_id),'0') as qtdePag,
                    coalesce(sum(pghi.pghi_vlpagamento),'0') as valorPag
                from
                    arrecadacao.pagamento_historico pghi
                where
                    pghi.pghi_dtpagamento >= '2024-08-01' and pghi.pgst_idatual in (0, 1) and pghi.dotp_id = 1
                group by matPag
            )as pagHis on pagHis.matPag = opef.opef_cnargumento
            left join (
                select
                    pgmt.imov_id as matPag,
                    coalesce(count(pgmt.pgmt_id), '0') as qtdePag,
                    coalesce(sum(pgmt.pgmt_vlpagamento), '0') as valorPag
                from
                    arrecadacao.pagamento pgmt
                where
                    pgmt.pgmt_dtpagamento >= '2024-08-01' and pgmt.pgst_idatual in (0, 1) and pgmt.dotp_id = 1
                group by matPag
            )as pagPgm on pagPgm.matPag = opef.opef_cnargumento
        where
            oper.oper_id in (28)
            and date(opef.opef_tmultimaalteracao) >= '2024-08-01'
        group by clie, qtdePago, valorPago
    )as operacao on operacao.clie = clie.clie_id
order by cliente, "data operacao"