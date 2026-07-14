SELECT
imov.imov_id AS "Matricula",
auif.auif_dtemissao AS "Data Notificação",
fzst.fzst_dsfiscalizacaosituacao AS "Tipo Irregularidade",
loca.loca_nmlocalidade AS "Localidade"


FROM
cadastro.imovel imov
INNER JOIN faturamento.autos_infracao auif ON auif.imov_id = imov.imov_id
INNER JOIN atendimentopublico.fiscalizacao_situacao fzst ON fzst.fzst_id = auif.fzst_id
INNER JOIN cadastro.localidade loca ON loca.loca_id = imov.loca_id AND loca.loca_id IN (111, 122, 133, 145, 151, 201, 363, 701)

WHERE
auif.auif_dtemissao > '2022-01-01'

ORDER BY
"Data Notificação"
