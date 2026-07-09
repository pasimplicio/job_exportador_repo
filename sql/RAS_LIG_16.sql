SELECT 
  ra.rgat_id AS "NR R.A.",
  ste.step_dssolcttipoespec AS "TIPO SOLICITACAO",
  (CASE ra.rgat_cdsituacao
	WHEN 1 THEN 'PENDENTE'
	WHEN 2 THEN 'ENCERRADA'
	ELSE 'INDETERMINADO'
  END) AS "SITUACAO R.A.",
  ra.rgat_dsobservacao AS "OBS R.A.",
  ra.rgat_dsparecerencerramento AS "PARECER R.A.",
  ors.orse_id AS "NR O.S.",
  svt.svtp_dsservicotipo AS "TIPO DE SERVICO",
  svt.svtp_cdservicotipo AS "COD SERVICO",
  (CASE ors.orse_cdsituacao
	WHEN 1 THEN 'PENDENTE'
	WHEN 2 THEN 'ENCERRADA'
	ELSE 'INDETERMINADO'
  END) AS "SITUACAO O.S.",
  ors.orse_dsobservacao AS "OBS O.S.",
  ors.orse_dsparecerencerramento AS "PARECER O.S.",
  ra.imov_id AS "MATRICULA", 
  mes.meso_dsmeiosolicitacao AS "MEIO DE SOLICITACAO",
  TO_CHAR(ra.rgat_tmregistroatendimento, 'dd/MM/yyyy') AS "DATA ATENDIMENTO R.A.",
  TO_CHAR(ra.rgat_tmregistroatendimento, 'hh24:mi') AS "HORARIO ATENDIMENTO R.A.",
  TO_CHAR(ra.rgat_tmencerramento, 'dd/MM/yyyy') AS "DATA ENCERRAMENTO R.A.",
  TO_CHAR(ra.rgat_tmencerramento, 'hh24:mi') AS "HORARIO ENCERRAMENTO R.A.",
  ame.amen_dsmotivoencerramento AS "MOTIVO ENCERRAMENTO R.A.",
  TO_CHAR(ors.orse_tmgeracao, 'dd/MM/yyyy') AS "DATA GERACAO O.S.",
  TO_CHAR(ors.orse_tmgeracao, 'hh24:mi') AS "HORARIO GERACAO O.S.",
  TO_CHAR(orse_dtvalidade, 'dd/MM/yyyy') AS "DATA DE VALIDADE O.S.",
  (CASE 
	WHEN (ors.orse_dtvalidade < CURRENT_DATE AND ors.orse_cdsituacao = 1) THEN 'ATRASADO'
	WHEN (ors.orse_dtvalidade >= CURRENT_DATE AND ors.orse_cdsituacao = 1) THEN 'NO PRAZO'
	WHEN (ors.orse_dtvalidade < ors.orse_tmencerramento AND ors.orse_cdsituacao = 2) THEN 'ENCERRADO ATRASADO'
	WHEN (ors.orse_dtvalidade >= ors.orse_tmencerramento AND ors.orse_cdsituacao = 2) THEN 'ENCERRADO NO PRAZO'	
	ELSE 'INDETERMINADO'
  END) AS "SITUACAO R.A.",
  TO_CHAR(ors.orse_tmencerramento, 'dd/MM/yyyy') AS "DATA ENCERRAMENTO O.S.",
  TO_CHAR(ors.orse_tmencerramento, 'hh24:mi') AS "HORARIO ENCERRAMENTO O.S.",
  mos.amen_dsmotivoencerramento AS "MOTIVO ENCERRAMENTO O.S.",
  TO_CHAR(ors.orse_tmexecucao , 'dd/MM/yyyy') AS "DATA EXECUÇÃO O.S.",
  TO_CHAR(ors.orse_tmexecucao , 'hh24:mi') AS "HORA EXECUÇÃO O.S.",
  TO_CHAR(ors.orse_tmultimaalteracao, 'dd/MM/yyyy') AS "DATA ULTIMA ALTERACAO O.S.",
  TO_CHAR(ors.orse_tmultimaalteracao, 'hh24:mi') AS "HORA ULTIMA ALTERACAO O.S.",
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
  uno_atual.unid_dsunidade AS "SETOR ATUAL R.A.",
  uno_geracao.unid_dsunidade AS "SETOR DE GERACAO R.A.",
  usu_geracao.usur_nmlogin || ' - ' || usu_geracao.usur_nmusuario AS "USUARIO GERACAO R.A.",
  uno_encerramento.unid_dsunidade AS "SETOR DE ENCERRAMENTO R.A.",
  usu_encerramento.usur_nmlogin || ' - ' || usu_encerramento.usur_nmusuario AS "USUARIO ENCERRAMENTO R.A.",
  uno_atual_os.unid_dsunidade AS "SETOR ATUAL O.S.",
  os_unid_geracao.unid_dsunidade AS "SETOR DE GERACAO O.S.",
  os_usu_geracao.usur_nmlogin || ' - ' || os_usu_geracao.usur_nmusuario AS "USUARIO GERACAO O.S.",
  os_unid_execucao.unid_dsunidade AS "SETOR DE EXECUCAO O.S.",
  os_usu_execucao.usur_nmlogin || ' - ' || os_usu_execucao.usur_nmusuario AS "USUARIO EXECUCAO O.S.",
  eqp.eqpe_nmequipe AS "EQUIPE EXECUCAO",
  os_unid_encerramento.unid_dsunidade AS "SETOR DE ENCERRAMENTO O.S.",
  os_usu_encerramento.usur_nmlogin || ' - ' || os_usu_encerramento.usur_nmusuario AS "USUARIO ENCERRAMENTO O.S.",
TO_CHAR((
		SELECT
			MIN(opf.opef_tmultimaalteracao) AS ult_alt
		FROM
			seguranca.tabela_linha_alteracao tbl
			INNER JOIN seguranca.operacao_efetuada opf ON opf.opef_id = tbl.tref_id
			INNER JOIN seguranca.tab_linha_col_alteracao tbc ON tbl.tbla_id = tbc.tbla_id
		WHERE
			--tbl.tabe_id = 60
			--tbc.tbca_cncolunaanterior <> tbc.tbca_cncolunaatual
			--AND 
			tbc.tbco_id IN (271, 272, 275, 276, 701, 60, 4796, 23848, 23850, 1527, 1529, 1531, 1539, 2524, 2525, 2526, 2527, 2529)
			--AND tbc.tbca_tmultimaalteracao >= (CURRENT_DATE::TIMESTAMP)
			--AND usu.usur_nmlogin = 'YGOR'
			AND opf.opef_cnargumento = cli.clie_id
	),'dd/MM/yyyy') AS "ULTIMA ALTERACAO CADASTRO",
	(
		SELECT
			TO_CHAR(MAX(cfon_tmultimaalteracao), 'dd/MM/yyyy')
		FROM
			cadastro.cliente_fone cfn
		WHERE 
			cfn.clie_id = cli.clie_id
	) AS "UTIMA ATUALIZACAO TELEFONE"
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
  LEFT JOIN atendimentopublico.servico_tipo svt ON svt.svtp_id = ors.svtp_id
  LEFT JOIN atendimentopublico.atend_motivo_encmt mos ON mos.amen_id = ors.amen_id
  LEFT JOIN cadastro.unidade_organizacional uno_atual_os ON uno_atual_os.unid_id = ors.unid_idatual
  LEFT JOIN atendimentopublico.ordem_servico_unidade os_geracao ON os_geracao.orse_id = ors.orse_id AND os_geracao.attp_id = 1
  LEFT JOIN cadastro.unidade_organizacional os_unid_geracao ON os_unid_geracao.unid_id = os_geracao.unid_id
  LEFT JOIN seguranca.usuario os_usu_geracao ON os_usu_geracao.usur_id = os_geracao.usur_id
  LEFT JOIN atendimentopublico.ordem_servico_unidade os_execucao ON os_execucao.orse_id = ors.orse_id AND os_execucao.attp_id = 2
  LEFT JOIN cadastro.unidade_organizacional os_unid_execucao ON os_unid_execucao.unid_id = os_execucao.unid_id
  LEFT JOIN seguranca.usuario os_usu_execucao ON os_usu_execucao.usur_id = os_execucao.usur_id
  LEFT JOIN atendimentopublico.ordem_servico_unidade os_encerramento ON os_encerramento.orse_id = ors.orse_id AND os_encerramento.attp_id = 3
  LEFT JOIN cadastro.unidade_organizacional os_unid_encerramento ON os_unid_encerramento.unid_id = os_encerramento.unid_id
  LEFT JOIN seguranca.usuario os_usu_encerramento ON os_usu_encerramento.usur_id = os_encerramento.usur_id
  LEFT JOIN atendimentopublico.ordem_servico_atividade osa ON osa.orse_id = ors.orse_id
  LEFT JOIN atendimentopublico.os_ativ_periodo_execucao oae ON oae.osat_id = osa.osat_id
  LEFT JOIN atendimentopublico.os_execucao_equipe ose ON oae.oape_id = ose.oape_id
  LEFT JOIN atendimentopublico.equipe eqp ON eqp.eqpe_id = ose.eqpe_id
  LEFT JOIN atendimentopublico.ra_solicitante rasol ON rasol.rgat_id = ra.rgat_id
  LEFT JOIN cadastro.cliente cli ON rasol.clie_id = cli.clie_id
WHERE 
  ra.rgat_tmregistroatendimento >= '2021-01-01' AND
  uno_geracao.unid_id = 551
ORDER BY 7,8