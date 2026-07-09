select
	ces.imov_id as "matricula",
	uni.unid_dsunidade as "setor emissao",
	ces.ctem_tmemissao as "data emissao"
	
from
	faturamento.conta_emissao_segundavia ces
	inner join seguranca.usuario usu ON usu.usur_id = ces.usur_id
	inner join cadastro.unidade_organizacional uni ON uni.unid_id = usu.unid_id
where
	ces.ctem_tmemissao > '2024-02-01' and
	ces.ctem_icemissaopresencial = 1
