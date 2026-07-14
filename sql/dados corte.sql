SELECT
lagu.lagu_id AS "Matricula",
lagu.lagu_dtcorte AS "Data do Corte",
lagu.lagu_nncorte AS "Numero de Cortes",
cotp.cotp_dscortetipo AS "Local Corte",
mtco.mtco_dsmotivo AS "Tipo de Corte",
lagu.lagu_dtreligacaoagua AS "Data da Religação",
loca.loca_nmlocalidade AS "Localidade"


FROM
atendimentopublico.ligacao_agua lagu
INNER JOIN atendimentopublico.corte_tipo cotp ON cotp.cotp_id = lagu.cotp_id
INNER JOIN atendimentopublico.motivo_corte mtco ON mtco.mtco_id = lagu.mtco_id
INNER JOIN cadastro.imovel imo ON imo.imov_id = lagu.lagu_id
INNER JOIN cadastro.localidade loca ON loca.loca_id = imo.loca_id AND loca.loca_id IN (111, 122, 133, 145, 151, 201, 363, 701)

WHERE
lagu.lagu_dtcorte > '2022-01-01'

ORDER BY
"Data do Corte"

--LEFT JOIN atendimentopublico.ligacao_agua lagu ON lagu.lagu_id = imo.imov_id