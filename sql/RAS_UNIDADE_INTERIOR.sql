SELECT 
  ra.rgat_id AS "NR R.A.",
  ors.orse_id AS "NR O.S",
  ste.step_dssolcttipoespec AS "TIPO SOLICITACAO", 
  (CASE ra.rgat_cdsituacao
	WHEN 1 THEN 'PENDENTE'
	WHEN 2 THEN 'ENCERRADA'
	ELSE 'INDETERMINADO'
  END) AS "SITUACAO R.A.", 
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
  ra.rgat_tmregistroatendimento >= '2026-01-01' AND une.uneg_id IN (2,3,4,5,6,7,8,9,10,20,21)
ORDER BY 7,8