SELECT 
	  os.orse_id AS "NR OS", 
	  svt.svtp_dsservicotipo AS "TIPO SERVICO", 
	  (CASE os.orse_cdsituacao
		WHEN 1 THEN 'PENDENTE'
		WHEN 2 THEN 'ENCERRADA'
		ELSE 'INDETERMINADO'
	  END) AS "SITUACAO OS", 
	  atm.amen_dsmotivoencerramento AS "TIPO DE ENCERRAMENTO",
	  os.orse_dsobservacao AS "OBSERVACAO", 
	  os.orse_dsparecerencerramento AS "PARECER", 
	  os.imov_id AS "MATRICULA", 
	  TO_CHAR(os.orse_tmgeracao, 'dd/MM/yyyy') AS "DATA GERACAO",
	  TO_CHAR(os.orse_tmencerramento, 'dd/MM/yyyy') AS "DATA ENCERRAMENTO",
	  une.uneg_nmunidadenegocio AS "UNID NEGOCIO",
	  loc.loca_nmlocalidade AS "LOCALIDADE", 
	  uno_geracao.unid_dsunidade AS "SETOR DE GERACAO",
	  usu_abrir.usur_nmlogin || ' - ' || usu_abrir.usur_nmusuario AS "USUARIO GERACAO",
	  uno_encerramento.unid_dsunidade AS "SETOR DE ENCERRAMENTO",
	  usu_ence.usur_nmlogin || ' - ' || usu_ence.usur_nmusuario AS "USUARIO ENCERRAMENTO",
	  eqp.eqpe_nmequipe AS "EQUIPE ENCERRAMENTO",
	  TO_CHAR(cdo.cbdo_vldocumento, 'L999G999G990D00') AS "VALOR COBRANCA",
	  emp.empr_nmempresa AS "NOME EMPRESA",
	  cds.cdst_dssituacaodebito AS "SIT DEBITO",
	  cas.cast_dssituacaoacao AS "SIT ACAO COBRANCA"
FROM 
	atendimentopublico.ordem_servico os
	INNER JOIN atendimentopublico.servico_tipo svt ON svt.svtp_id = os.svtp_id
	INNER JOIN cadastro.imovel imo ON imo.imov_id = os.imov_id
	INNER JOIN cadastro.localidade loc ON loc.loca_id = imo.loca_id
	INNER JOIN cadastro.unidade_negocio une ON une.uneg_id = loc.uneg_id
	LEFT JOIN atendimentopublico.ordem_servico_atividade osa ON osa.orse_id = os.orse_id
	LEFT JOIN atendimentopublico.os_ativ_periodo_execucao oae ON oae.osat_id = osa.osat_id
	LEFT JOIN atendimentopublico.os_execucao_equipe ose ON oae.oape_id = ose.oape_id
	LEFT JOIN atendimentopublico.ordem_servico_unidade osu_abrir ON osu_abrir.orse_id = os.orse_id AND osu_abrir.attp_id = 1
	LEFT JOIN cadastro.unidade_organizacional uno_geracao ON uno_geracao.unid_id = osu_abrir.unid_id
	LEFT JOIN atendimentopublico.ordem_servico_unidade osu_ence ON osu_ence.orse_id = os.orse_id AND osu_ence.attp_id = 3
	LEFT JOIN cadastro.unidade_organizacional uno_encerramento ON uno_encerramento.unid_id = osu_ence.unid_id
	LEFT JOIN seguranca.usuario usu_abrir ON usu_abrir.usur_id = osu_abrir.usur_id
	LEFT JOIN seguranca.usuario usu_ence ON usu_ence.usur_id = osu_ence.usur_id
	LEFT JOIN atendimentopublico.equipe eqp ON eqp.eqpe_id = ose.eqpe_id
	LEFT JOIN cobranca.cobranca_documento cdo ON cdo.cbdo_id = os.cbdo_id
	LEFT JOIN cadastro.empresa emp ON emp.empr_id = cdo.empr_id
	LEFT JOIN cobranca.cobranca_debito_situacao cds ON cds.cdst_id = cdo.cdst_id
	LEFT JOIN cobranca.cobranca_acao_situacao cas ON cas.cast_id = cdo.cast_id
	LEFT JOIN atendimentopublico.atend_motivo_encmt atm ON atm.amen_id = os.amen_id
WHERE 
	os.orse_tmgeracao > '2022-01-01' AND
	svt.svtp_id IN (713,714,720,9162,351,56,59,7165) AND
	une.uneg_id IN (2,3,4,5,6,7,8,9,10,11,12,13,14,15)