-- REFERENCIA: 202408
-- Query destinada analise de medição da consistencia

select
    to_char(to_date(mdhi.mdhi_amleitura::text, 'YYYYMM'), 'MM/YYYY') as referencia,
    mdhi.lagu_id as matricula,
    mdhi.mdhi_nnconsumomediohidrometro as "consumo medio",
    mdhi.mdhi_nnconsumomedidomes as "consumo medido",
    mdhi.mdhi_nnconsumoinformado as "consumo informado",
    cshi.cshi_nnconsumofaturadomes as "consumo faturado",
    cstp.cstp_dsconsumotipo as "consumo tipo",
    (case mdhi.mdhi_icanalisado
        when 2 then 'NAO'
        else 'SIM'
        end) as analisado,
    ltst.ltst_dsleiturasituacao as "situacao leitura",
    ltan_f.ltan_dsleituraanormalidade as "anor leit faturamento",
    ltan_i.ltan_dsleituraanormalidade as "anor leit informada",
    csan.csan_dsconsumoanormalidade as "anor consumo"
from
    micromedicao.medicao_historico mdhi
    inner join micromedicao.leitura_situacao ltst on ltst.ltst_id = mdhi.ltst_idleiturasituacaoatual
    left join micromedicao.leitura_anormalidade ltan_f on ltan_f.ltan_id = mdhi.ltan_idleitanormfatmt
    left join micromedicao.leitura_anormalidade ltan_i on ltan_i.ltan_id = mdhi.ltan_idleitanorminformada
    inner join micromedicao.consumo_historico cshi on cshi.imov_id = mdhi.lagu_id and cshi.cshi_amfaturamento = mdhi.mdhi_amleitura and cshi.lgti_id = 1
    inner join micromedicao.consumo_tipo cstp on cstp.cstp_id = cshi.cstp_id
    left join micromedicao.consumo_anormalidade csan on csan.csan_id = cshi.csan_id
where
    mdhi.mdhi_amleitura >= 202408
    and medt_id = 1
--and mdhi.lagu_id = 51
order by matricula

