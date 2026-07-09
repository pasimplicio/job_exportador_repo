SELECT 
  ra.rgat_id AS "NR RA",
  ra.rgat_nncoordenadanorte AS "LONGITUDE",
  ra.rgat_nncoordenadaleste AS "LATITUDE",
  ors.orse_id AS "NR OS",
  stg.sotg_id AS "ID GRUPO DE SOLICITACAO",
  stg.sotg_dssolicitacaotipogrupo AS "GRUPO DE SOLICITACAO",
  stp.sotp_id AS "ID TIPO SOLICIATACAO",
  stp.sotp_dssolicitacaotipo AS "TIPO SOLICITACAO",
  ste.step_id AS "ID ESPECIFICACAO SOLICITACAO",
  ste.step_dssolcttipoespec AS "ESPECIFICACAO SOLICITACAO", 
  (CASE ra.rgat_cdsituacao
	WHEN 1 THEN 'PENDENTE'
	WHEN 2 THEN 'ENCERRADA'
	ELSE 'INDETERMINADO'
  END) AS "SITUACAO RA",
  (CASE	ra.rgat_cdsituacao
	WHEN 1 THEN CURRENT_DATE - ra.rgat_tmregistroatendimento::DATE
	WHEN 2 THEN ra.rgat_tmencerramento::DATE - ra.rgat_tmregistroatendimento::DATE
   END) AS "TEMPO PARA EXECUCAO",
  ra.rgat_dsobservacao AS "OBS", 
  ra.rgat_dsparecerencerramento AS "PARECER", 
  ra.imov_id AS "MATRICULA", 
  TO_CHAR(ra.rgat_tmregistroatendimento, 'dd/MM/yyyy') AS "DATA ATENDIMENTO",
  TO_CHAR(ra.rgat_tmregistroatendimento, 'hh24:mm') AS "HORARIO ATENDIMENTO",
  mes.meso_dsmeiosolicitacao AS "MEIO DE SOLICITACAO",
  TO_CHAR(ra.rgat_tmencerramento, 'dd/MM/yyyy') AS "DATA ENCERRAMENTO",
  TO_CHAR(ra.rgat_tmencerramento, 'hh24:mm') AS "HORARIO ENCERRAMENTO",
  ame.amen_dsmotivoencerramento AS "MOTIVO ENCERRAMENTO",
  une.uneg_nmunidadenegocio AS "UNID NEGOCIO",
  loc.loca_id AS "LOCALIDADE", 
  loc.loca_nmlocalidade AS "NOME LOCALIDADE",
  sec.stcm_cdsetorcomercial AS "SETOR COMERCIAL",
  qdr.qdra_nnquadra AS "QUADRA",
  rot.rota_cdrota AS "ROTA",
  lgt.lgtp_dslogradourotipo AS "TIPO LOGRADOURO",
  logr.logr_nmlogradouro AS "NOME LOGRADOURO",
  ra.rgat_dscomplementondereco AS "COMPLEMENTO",
  bai.bair_nmbairro AS "BAIRRO",
  ra.rgat_nnimovel AS "NUM IMOVEL",
  mun.muni_nmmunicipio AS "MUNICIPIO",
  uno_atual.unid_dsunidade AS "SETOR ATUAL",
  uno_geracao.unid_dsunidade AS "SETOR DE GERACAO",
  usu_geracao.usur_nmlogin || ' - ' || usu_geracao.usur_nmusuario AS "USUARIO GERACAO",
  uno_encerramento.unid_dsunidade AS "SETOR DE ENCERRAMENTO",
  usu_encerramento.usur_nmlogin || ' - ' || usu_encerramento.usur_nmusuario AS "USUARIO ENCERRAMENTO"
FROM 
  atendimentopublico.registro_atendimento ra
  LEFT JOIN atendimentopublico.solicitacao_tipo_espec ste ON ste.step_id = ra.step_id
  LEFT JOIN atendimentopublico.solicitacao_tipo stp ON stp.sotp_id = ste.sotp_id
  LEFT JOIN atendimentopublico.solicitacao_tipo_grupo stg ON stg.sotg_id = stp.sotg_id
  LEFT JOIN atendimentopublico.meio_solicitacao mes ON mes.meso_id = ra.meso_id
  LEFT JOIN atendimentopublico.ra_unidade rau ON rau.rgat_id = ra.rgat_id AND rau.attp_id = 1
  LEFT JOIN cadastro.unidade_organizacional uno_geracao ON uno_geracao.unid_id = rau.unid_id
  LEFT JOIN seguranca.usuario usu_geracao ON usu_geracao.usur_id = rau.usur_id
  LEFT JOIN atendimentopublico.ra_unidade rau_encerramento ON rau_encerramento.rgat_id = ra.rgat_id AND rau_encerramento.attp_id = 3
  LEFT JOIN cadastro.unidade_organizacional uno_encerramento ON uno_encerramento.unid_id = rau_encerramento.unid_id
  LEFT JOIN seguranca.usuario usu_encerramento ON usu_encerramento.usur_id = rau_encerramento.usur_id
  LEFT JOIN cadastro.localidade loc ON loc.loca_id = ra.loca_id
  LEFT JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
  LEFT JOIN cadastro.setor_comercial sec ON ra.stcm_id = sec.stcm_id
  LEFT JOIN cadastro.quadra qdr ON qdr.qdra_id = ra.qdra_id
  LEFT JOIN micromedicao.rota rot ON rot.rota_id = qdr.rota_id
  LEFT JOIN cadastro.logradouro_bairro lgb ON lgb.lgbr_id = ra.lgbr_id
  LEFT JOIN cadastro.logradouro logr ON lgb.logr_id = logr.logr_id
  LEFT JOIN cadastro.logradouro_tipo lgt ON lgt.lgtp_id = logr.lgtp_id
  LEFT JOIN cadastro.bairro bai ON bai.bair_id = lgb.bair_id
  LEFT JOIN cadastro.municipio mun ON mun.muni_id = bai.muni_id
  LEFT JOIN cadastro.unidade_organizacional uno_atual ON uno_atual.unid_id = ra.unid_idatual
  LEFT JOIN atendimentopublico.atend_motivo_encmt ame ON ame.amen_id = ra.amen_id
  LEFT JOIN atendimentopublico.ordem_servico ors ON ors.rgat_id = ra.rgat_id
WHERE 
  (NOT ra.rgat_nncoordenadanorte IS NULL AND NOT ra.rgat_nncoordenadaleste IS NULL) AND
  ra.rgat_tmregistroatendimento >= '2019-01-01'
ORDER BY 7,8