SELECT 
  ra.rgat_id AS "NR R.A.", 
  cli.clie_id AS "ID CLIENTE",
  cli.clie_nmcliente AS "NOME ATUAL",
  (CASE
		WHEN cli.clie_nncpf IS NULL THEN cli.clie_nncnpj
		WHEN cli.clie_nncnpj IS NULL THEN cli.clie_nncpf
		ELSE ''
   END) AS "CPF ATUAL",
  cli.clie_nncnpj AS "CNPJ ATUAL",
  replace(UPPER(TRIM(split_part(split_part(ra.rgat_dsobservacao, E'\n', 1),'- Nome: ',2))),'  ', ' ') AS "NOME",
  split_part(split_part(ra.rgat_dsobservacao, E'\n', 2),'- Cpf/Cnpj: ',2) AS "CPF/CNPJ",
  LOWER(TRIM(split_part(split_part(ra.rgat_dsobservacao, E'\n', 3),'- Email: ',2))) AS "EMAIL",
  replace(replace(split_part(split_part(split_part(ra.rgat_dsobservacao, E'\n', 4),'- Telefone para Contato: ',2), ' ',1), ')', ''), '(', '') AS "DDD",
  replace(split_part(split_part(split_part(ra.rgat_dsobservacao, E'\n', 4),'- Telefone para Contato: ',2), ' ',2), '-', '') AS "TELEFONE",


  (CASE
	WHEN cli.clie_nncnpj IS NULL
	THEN split_part(split_part(ra.rgat_dsobservacao, E'\n', 5),'Data de Nascimento: ',2) 
	ELSE ''

  END) AS "NASC",


  TO_CHAR(ra.rgat_tmregistroatendimento, 'dd/MM/yyyy') AS "DATA ATENDIMENTO",
  (CASE
		WHEN cli.clie_nmcliente = REPLACE(UPPER(TRIM(split_part(split_part(ra.rgat_dsobservacao, E'\n', 1),'- Nome: ',2))),'  ', ' ') 
		THEN 'VERDADEIRO'
		ELSE 'FALSO'
   END) AS "TESTE NOME",

  (CASE
	WHEN (CASE
			WHEN cli.clie_nncpf IS NULL THEN cli.clie_nncnpj
			WHEN cli.clie_nncnpj IS NULL THEN cli.clie_nncpf
			ELSE ''
	      END) = split_part(split_part(ra.rgat_dsobservacao, E'\n', 2),'- Cpf/Cnpj: ',2) 
	THEN 'VERDADEIRO'
	ELSE 'FALSO'
   END) AS "TESTE CPF",
  (CASE
  WHEN (cli.clie_nncpf IS NULL AND cli.clie_nncnpj IS NULL) AND (cli.clie_nmcliente = REPLACE(UPPER(TRIM(split_part(split_part(ra.rgat_dsobservacao, E'\n', 1),'- Nome: ',2))),'  ', ' ') )THEN 'ATUALIZADO EMAIL, DATA DE NASCIMENTO, TELEFONE E CPF.'
  WHEN (cli.clie_nncpf IS NULL AND cli.clie_nncnpj IS NULL) AND NOT (cli.clie_nmcliente = REPLACE(UPPER(TRIM(split_part(split_part(ra.rgat_dsobservacao, E'\n', 1),'- Nome: ',2))),'  ', ' ') )THEN 'ANALISE THIAGO'


  WHEN ((cli.clie_nmcliente = REPLACE(UPPER(TRIM(split_part(split_part(ra.rgat_dsobservacao, E'\n', 1),'- Nome: ',2))),'  ', ' ') ) AND ((CASE
			WHEN cli.clie_nncpf IS NULL THEN cli.clie_nncnpj
			WHEN cli.clie_nncnpj IS NULL THEN cli.clie_nncpf
			ELSE ''
	      END) = split_part(split_part(ra.rgat_dsobservacao, E'\n', 2),'- Cpf/Cnpj: ',2))) THEN 'ATUALIZADO EMAIL, DATA DE NASCIMENTO E TELEFONE.'
    WHEN ((cli.clie_nmcliente = REPLACE(UPPER(TRIM(split_part(split_part(ra.rgat_dsobservacao, E'\n', 1),'- Nome: ',2))),'  ', ' ') ) AND NOT ((CASE
			WHEN cli.clie_nncpf IS NULL THEN cli.clie_nncnpj
			WHEN cli.clie_nncnpj IS NULL THEN cli.clie_nncpf
			ELSE ''
	      END) = split_part(split_part(ra.rgat_dsobservacao, E'\n', 2),'- Cpf/Cnpj: ',2))) THEN 'ATUALIZADO EMAIL E TELEFONE. CPF DIVERGENTE.'
  WHEN ( NOT (cli.clie_nmcliente = REPLACE(UPPER(TRIM(split_part(split_part(ra.rgat_dsobservacao, E'\n', 1),'- Nome: ',2))),'  ', ' ') ) AND ((CASE
			WHEN cli.clie_nncpf IS NULL THEN cli.clie_nncnpj
			WHEN cli.clie_nncnpj IS NULL THEN cli.clie_nncpf
			ELSE ''
	      END) = split_part(split_part(ra.rgat_dsobservacao, E'\n', 2),'- Cpf/Cnpj: ',2))) THEN 'ANALISE JOSIEL'
  WHEN (NOT (cli.clie_nmcliente = REPLACE(UPPER(TRIM(split_part(split_part(ra.rgat_dsobservacao, E'\n', 1),'- Nome: ',2))),'  ', ' ') ) AND NOT ((CASE
			WHEN cli.clie_nncpf IS NULL THEN cli.clie_nncnpj
			WHEN cli.clie_nncnpj IS NULL THEN cli.clie_nncpf
			ELSE ''
	      END) = split_part(split_part(ra.rgat_dsobservacao, E'\n', 2),'- Cpf/Cnpj: ',2))) THEN 'ATUALIZADO EMAIL E TELEFONE. NOME E CPF DIVERGENTES.'
  END) AS "PARECER",
  '' AS "SITUACAO"
--  TO_CHAR(ra.rgat_tmregistroatendimento, 'hh24:mm') AS "HORARIO ATENDIMENTO",
--  mes.meso_dsmeiosolicitacao AS "MEIO DE SOLICITACAO",
--  TO_CHAR(ra.rgat_tmencerramento, 'dd/MM/yyyy') AS "DATA ENCERRAMENTO",
--  TO_CHAR(ra.rgat_tmencerramento, 'hh24:mm') AS "HORARIO ENCERRAMENTO",
--  une.uneg_nmunidadenegocio AS "UNID NEGOCIO",
--  loc.loca_id AS "LOCALIDADE", 
--  loc.loca_nmlocalidade AS "NOME LOCALIDADE",
--  sec.stcm_cdsetorcomercial AS "SETOR COMERCIAL",
--  qdr.qdra_nnquadra AS "QUADRA",
--  rot.rota_cdrota AS "ROTA",
--  lgt.lgtp_dslogradourotipo AS "TIPO LOGRADOURO",
--  logr.logr_nmlogradouro AS "NOME LOGRADOURO",
--  ra.rgat_dscomplementondereco AS "COMPLEMENTO",
--  bai.bair_nmbairro AS "BAIRRO",
--  ra.rgat_nnimovel AS "NUM IMOVEL",
--  mun.muni_nmmunicipio AS "MUNICIPIO",
--  uno_atual.unid_dsunidade AS "SETOR ATUAL",
--  uno_geracao.unid_dsunidade AS "SETOR DE GERACAO",
--  usu_geracao.usur_nmlogin || ' - ' || usu_geracao.usur_nmusuario AS "USUARIO GERACAO",
--  uno_encerramento.unid_dsunidade AS "SETOR DE ENCERRAMENTO",
--  usu_encerramento.usur_nmlogin || ' - ' || usu_encerramento.usur_nmusuario AS "USUARIO ENCERRAMENTO"
FROM 
  atendimentopublico.registro_atendimento ra
  LEFT JOIN cadastro.imovel imo ON imo.imov_id = ra.imov_id
  LEFT JOIN cadastro.cliente_imovel cim ON cim.imov_id = imo.imov_id AND cim.clim_dtrelacaofim IS NULL AND cim.clim_icnomeconta = 1
  LEFT JOIN cadastro.cliente cli ON cli.clie_id = cim.clie_id
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
WHERE 
  ste.step_id = 9176 AND ra.rgat_cdsituacao = 1
ORDER BY 1