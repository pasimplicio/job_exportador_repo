SELECT 
  ra.rgat_id AS "NR R.A.",
  sot.sotp_dssolicitacaotipo AS "TIPO SOLICITACAO",
  ste.step_dssolcttipoespec AS "TIPO ESPECIFICACAO",
  (CASE ra.rgat_cdsituacao
	WHEN 1 THEN 'PENDENTE'
	WHEN 2 THEN 'ENCERRADA'
	ELSE 'INDETERMINADO'
  END) AS "SITUACAO R.A.", 
  ra.rgat_dsobservacao AS "OBS", 
  ra.rgat_dsparecerencerramento AS "PARECER", 
  ra.imov_id AS "MATRICULA",
  cli.clie_id AS "CODIGO CLIENTE",
  cli.clie_nmcliente AS "NOME",
  cli.clie_nncpf AS "CPF",
  cli.clie_nncnpj AS "CNPJ",
	(
		SELECT
			STRING_AGG('('||cfn.cfon_cdddd||')'||cfn.cfon_nnfone,' | ')
		FROM
			cadastro.cliente_fone cfn
			INNER JOIN cadastro.cliente cli2 ON cli2.clie_id = cfn.clie_id
			INNER JOIN cadastro.cliente_imovel cim2 ON cim2.clie_id = cli2.clie_id AND cim2.clim_dtrelacaofim IS NULL AND cim2.imov_id = imo.imov_id
	) AS "TELEFONES",
  cli.clie_dsemail AS "EMAIL",	     
  TO_CHAR(ra.rgat_tmregistroatendimento, 'dd/MM/yyyy') AS "DATA ATENDIMENTO",
  TO_CHAR(ra.rgat_tmregistroatendimento, 'hh24:mm') AS "HORARIO ATENDIMENTO",
  mes.meso_dsmeiosolicitacao AS "MEIO DE SOLICITACAO",
  TO_CHAR(ra.rgat_tmencerramento, 'dd/MM/yyyy') AS "DATA ENCERRAMENTO",
  TO_CHAR(ra.rgat_tmencerramento, 'hh24:mm') AS "HORARIO ENCERRAMENTO",
  ame.amen_dsmotivoencerramento AS "MOTIVO ENCERRAMENTO",
  une.uneg_nmunidadenegocio AS "UNID NEGOCIO",
  loc.loca_id AS "LOCALIDADE", 
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
  LEFT JOIN cadastro.imovel imo ON imo.imov_id = ra.imov_id
  LEFT JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
  LEFT JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id 
  LEFT JOIN atendimentopublico.solicitacao_tipo_espec ste ON ste.step_id = ra.step_id
  LEFT JOIN atendimentopublico.solicitacao_tipo sot ON sot.sotp_id = ste.sotp_id  
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
  ra.rgat_tmregistroatendimento >= '2026-01-01'
ORDER BY 7,8