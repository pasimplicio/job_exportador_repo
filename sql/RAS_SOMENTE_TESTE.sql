SELECT 
  ra.rgat_id AS "NR R.A.",
  CASE
	WHEN COALESCE(ra.rgat_nncoordenadanorte,0) <> 0
	THEN TO_CHAR(ra.rgat_nncoordenadanorte, '999G999G990D000000000000')
	ELSE TO_CHAR(imo.imov_nncoordenaday, '999G999G990D000000000000')
  END AS "LONGITUDE",
  CASE
	WHEN COALESCE(ra.rgat_nncoordenadaleste,0) <> 0
	THEN TO_CHAR(ra.rgat_nncoordenadaleste, '999G999G990D000000000000')
	ELSE TO_CHAR(imo.imov_nncoordenadax, '999G999G990D000000000000')
  END AS "LATITUDE",
  sot.sotp_dssolicitacaotipo AS "SOLICITACAO TIPO",
  ste.step_dssolcttipoespec AS "TIPO ESPECIFICACAO",
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
  imo.iper_id AS "PERFIL IMOVEL",
cli.clie_nmcliente AS "NOME",
cli.clie_nncpf AS "CPF",
cli.clie_nncnpj AS "CNPJ",
(CASE cli.clie_iccpfcnpjvalidado
WHEN 0 THEN 'NAO'
WHEN 1 THEN 'SIM'
ELSE 'NAO'
END) AS "DOC VALIDADO",
(
	SELECT
		STRING_AGG('('||cfn.cfon_cdddd||')'||cfn.cfon_nnfone,' | ')
	FROM
		cadastro.cliente_fone cfn
		INNER JOIN cadastro.cliente cli2 ON cli2.clie_id = cfn.clie_id
		INNER JOIN cadastro.cliente_imovel cim2 ON cim2.clie_id = cli2.clie_id AND cim2.clim_dtrelacaofim IS NULL AND cim2.imov_id = imo.imov_id
) AS "TELEFONES",
cli.clie_dsemail AS "EMAIL",
  mes.meso_dsmeiosolicitacao AS "MEIO DE SOLICITACAO",
  TO_CHAR(ra.rgat_tmregistroatendimento, 'dd/MM/yyyy') AS "DATA ATENDIMENTO R.A.",
  TO_CHAR(ra.rgat_tmregistroatendimento, 'hh24:mi') AS "HORARIO ATENDIMENTO R.A.",
  (CASE 
	WHEN (ra.rgat_dtprevistaatual < CURRENT_DATE AND ra.rgat_cdsituacao = 1) THEN 'ATRASADO'
	WHEN (ra.rgat_dtprevistaatual >= CURRENT_DATE AND ra.rgat_cdsituacao = 1) THEN 'NO PRAZO'
	WHEN (ra.rgat_dtprevistaatual < ra.rgat_tmencerramento AND ra.rgat_cdsituacao = 2) THEN 'ENCERRADO ATRASADO'
	WHEN (ra.rgat_dtprevistaatual >= ra.rgat_tmencerramento AND ra.rgat_cdsituacao = 2) THEN 'ENCERRADO NO PRAZO'	
	ELSE 'INDETERMINADO'
  END) AS "ATRASO R.A.",
  TO_CHAR(ra.rgat_dtprevistaatual,'dd/MM/yyyy') AS "DATA PREVISTA R.A.",
  TO_CHAR(ra.rgat_tmencerramento, 'dd/MM/yyyy') AS "DATA ENCERRAMENTO R.A.",
  TO_CHAR(ra.rgat_tmencerramento, 'hh24:mi') AS "HORARIO ENCERRAMENTO R.A.",
  TO_CHAR(EXTRACT( epoch FROM(ra.rgat_tmencerramento - ra.rgat_tmregistroatendimento))/3600, '999G999G990D00') AS "DURACAO R.A.",
  ame.amen_dsmotivoencerramento AS "MOTIVO ENCERRAMENTO R.A.",
  TO_CHAR(ors.orse_tmgeracao, 'dd/MM/yyyy') AS "DATA GERACAO O.S.",
  TO_CHAR(ors.orse_tmgeracao, 'hh24:mi') AS "HORARIO GERACAO O.S.",
  (CASE 
	WHEN (ors.orse_dtvalidade < CURRENT_DATE AND ors.orse_cdsituacao = 1) THEN 'ATRASADO'
	WHEN (ors.orse_dtvalidade >= CURRENT_DATE AND ors.orse_cdsituacao = 1) THEN 'NO PRAZO'
	WHEN (ors.orse_dtvalidade < ors.orse_tmencerramento AND ors.orse_cdsituacao = 2) THEN 'ENCERRADO ATRASADO'
	WHEN (ors.orse_dtvalidade >= ors.orse_tmencerramento AND ors.orse_cdsituacao = 2) THEN 'ENCERRADO NO PRAZO'	
	ELSE 'INDETERMINADO'
  END) AS "ATRASO O.S.",
  TO_CHAR(ors.orse_dtvalidade,'dd/MM/yyyy') AS "DATA PREVISTA O.S.",
  TO_CHAR(ors.orse_tmencerramento, 'dd/MM/yyyy') AS "DATA ENCERRAMENTO O.S.",
  TO_CHAR(ors.orse_tmencerramento, 'hh24:mi') AS "HORARIO ENCERRAMENTO O.S.",
  mos.amen_dsmotivoencerramento AS "MOTIVO ENCERRAMENTO O.S.",
  TO_CHAR(ors.orse_tmexecucao , 'dd/MM/yyyy') AS "DATA EXECUCAO O.S.",
  TO_CHAR(ors.orse_tmexecucao , 'hh24:mi') AS "HORA EXECUCAO O.S.",
  TO_CHAR(ors.orse_tmultimaalteracao, 'dd/MM/yyyy') AS "DATA ULTIMA ALTERACAO O.S.",
  TO_CHAR(ors.orse_tmultimaalteracao, 'hh24:mi') AS "HORA ULTIMA ALTERACAO O.S.",
  TO_CHAR(EXTRACT( epoch FROM(ors.orse_tmultimaalteracao - ors.orse_tmgeracao))/3600, '999G999G990D00') AS "DURACAO O.S.",
 (CASE imo.imov_idcategoriaprincipal 
	WHEN 1 THEN '1 - RESIDENCIAL'
	WHEN 2 THEN '2 - COMERCIAL'
	WHEN 3 THEN '3 - INDUSTRIAL'
	WHEN 4 THEN '4 - PUBLICO'
	ELSE 'NAO DEFINIDO'
	END) AS "CATEGORIA PRINCIPAL",
	(CASE imo.imov_idsubcategoriaprincipal 
	WHEN 1 THEN '1 - RESIDENCIAL'
	WHEN 2 THEN '2 - COMERCIAL'
	WHEN 3 THEN '3 - INDUSTRIAL'
	WHEN 4 THEN '4 - MUNICIPAL'
	WHEN 5 THEN '5 - ESTADUAL'
	WHEN 6 THEN '6 - FEDERAL'
	WHEN 7 THEN '7 - RES. POPULAR'
	WHEN 8 THEN '8 - PEQ. NEGOCIOS'
	WHEN 9 THEN '9 - ENT. FILANTROPICAS'
	WHEN 10 THEN '10 - SIST. OPERADO POR PREFEITURA'
	ELSE 'NAO DEFINIDO'
  END) AS "SUBCATEGORIA PRINCIPAL",
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
  os_unid_encerramento.unid_dsunidade AS "SETOR DE ENCERRAMENTO O.S.",
  os_usu_encerramento.usur_nmlogin || ' - ' || os_usu_encerramento.usur_nmusuario AS "USUARIO ENCERRAMENTO O.S.",
  las.last_dsligacaoaguasituacao AS "SITUACAO AGUA",
  les.lest_dsligacaoesgotosituacao AS "SITUACAO ESGOTO",
  hid.hidr_nnhidrometro AS "NR HID.",
  hid.hidr_nnanofabricacao AS "ANO HD",
  his.hidi_dtinstalacaohidrometro AS "DATA DE INSTALACAO HD.",
  COALESCE((
	SELECT
		SUM(pags.qtd) AS qtd
	FROM		
		(SELECT 
				COUNT(pag.pgmt_id) AS qtd
			FROM
				arrecadacao.pagamento pag
			WHERE
				pag.pgst_idatual IN (0,1)
				AND pag.imov_id = ra.imov_id
				AND pag.pgmt_dtpagamento BETWEEN ra.rgat_tmencerramento AND (ra.rgat_tmencerramento+INTERVAL '7d')
		UNION
			SELECT 
				COUNT(pag.pghi_id) AS qtd
			FROM
				arrecadacao.pagamento_historico pag
			WHERE
				pag.pgst_idatual IN (0,1)
				AND pag.imov_id = ra.imov_id
				AND pag.pghi_dtpagamento BETWEEN ra.rgat_tmencerramento AND (ra.rgat_tmencerramento+INTERVAL '7d')) pags),0) AS "QTD DOCS PAGOS ATE 1 SEMANA APOS ENCERRAMENTO DO R.A.",
  TO_CHAR(COALESCE((
	SELECT
		SUM(pags.valor) AS valor
	FROM		
		(SELECT 
				SUM(pag.pgmt_vlpagamento) AS valor
			FROM
				arrecadacao.pagamento pag
			WHERE
				pag.pgst_idatual IN (0,1)
				AND pag.imov_id = ra.imov_id
				AND pag.pgmt_dtpagamento BETWEEN ra.rgat_tmencerramento AND (ra.rgat_tmencerramento+INTERVAL '7d')
		UNION
			SELECT 
				SUM(pag.pghi_vlpagamento) AS valor
			FROM
				arrecadacao.pagamento_historico pag
			WHERE
				pag.pgst_idatual IN (0,1)
				AND pag.imov_id = ra.imov_id
				AND pag.pghi_dtpagamento BETWEEN ra.rgat_tmencerramento AND (ra.rgat_tmencerramento+INTERVAL '7d')) pags),0),'9G999G999G990D00') AS "VALOR TOTAL PAGO ATE 1 SEMANA APOS ENCERRAMENTO DO R.A."
  --TO_CHAR(SUM(COALESCE(pags_1_semana.valor,0)), '9G999G999G990D00') AS "VALOR TOTAL PAGO ATE 1 SEMANA APOS ENCERRAMENTO DO R.A."
FROM 
  atendimentopublico.registro_atendimento ra
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
  LEFT JOIN cadastro.imovel imo ON imo.imov_id = ra.imov_id
  LEFT JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
  LEFT JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
  LEFT JOIN atendimentopublico.ligacao_agua_situacao las ON las.last_id = imo.last_id
  LEFT JOIN atendimentopublico.ligacao_esgoto_situacao les ON les.lest_id = imo.lest_id
  LEFT JOIN atendimentopublico.ligacao_agua lagu ON lagu.lagu_id = imo.imov_id
  LEFT JOIN micromedicao.hidrometro_inst_hist his ON lagu.hidi_id = his.hidi_id AND his.hidi_dtretiradahidrometro IS NULL
  LEFT JOIN micromedicao.hidrometro hid ON his.hidr_id = hid.hidr_id
WHERE 
  ra.rgat_tmregistroatendimento >= '2021-06-01' AND
  ra.rgat_cdsituacao = 2 
  AND ste.step_dssolcttipoespec = 'REGISTRO MOVIMENTACAO JUDICIAL'
  AND ra.imov_id = 682152
  
ORDER BY 7,8