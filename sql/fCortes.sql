select
    imov.imov_id as "matricula",
    CASE imov.imov_idcategoriaprincipal 
        WHEN 1 THEN 'RESIDENCIAL'
        WHEN 2 THEN 'COMERCIAL'
        WHEN 3 THEN 'INDUSTRIAL'
        WHEN 4 THEN 'PUBLICO'
        ELSE 'NAO DEFINIDO'
    END AS "Categoria Principal",        
    loc.loca_id AS "Localidade",  
    las.last_dsligacaoaguasituacao AS "Situacao da agua",
    date(cbdo.cbdo_tmemissao) as "data emissao",
    dotp.dotp_dsdocumentotipo as "tipo documento",
    demf.demf_dsdocumentoemissaoforma as "forma emissao",
    cbac.cbac_dscobrancaacao as "acao cobranca",
    to_char(cbdo.cbdo_vldocumento, '999G999G990D00') as "valor documento",
    cas.cast_dssituacaoacao as "situacao acao",
    cbdo.cbdo_dtsituacaoacao as "data acao",
    cdst.cdst_dssituacaodebito as "situacao debito",
    amen.amen_dsmotivoencerramento as "motivo encerramento"
    
from 
    cadastro.imovel imov
    inner join cadastro.localidade loc ON imov.loca_id = loc.loca_id
    inner join cobranca.cobranca_documento cbdo on cbdo.imov_id = imov.imov_id and cbdo.cbdo_tmemissao >= '2025-01-01'
    inner join cobranca.documento_tipo dotp on dotp.dotp_id = cbdo.dotp_id
    inner join cobranca.documento_emissao_forma demf on demf.demf_id = cbdo.demf_id
    inner join cobranca.cobranca_acao cbac on cbac.cbac_id = cbdo.cbac_id
    inner join cobranca.cobranca_acao_situacao cas on cas.cast_id = cbdo.cast_id
    inner join cobranca.cobranca_debito_situacao cdst on cdst.cdst_id = cbdo.cdst_id
    left join atendimentopublico.atend_motivo_encmt amen on amen.amen_id = cbdo.amen_id
    LEFT JOIN atendimentopublico.ligacao_agua_situacao las ON las.last_id = imov.last_id    
    

where
    dotp.dotp_id = 13
    --and imov.imov_id in (189111, 74667, 88072, 187283)
order by
    imov.imov_id
    




/*
Foreign Key	cobranca.cobranca_documento.fk1_cobranca_documento	normal	


Foreign Key	cobranca.cobranca_sit_comando.fk1_cobranca_situacao_comando	normal	

Foreign Key	cobranca.cobranca_situacao_hist.fk1_cobranca_situacao_historico	normal	

Foreign Key	cobranca.comando_ativ_imoveis.fk2_comando_ativ_imoveis	normal

*/