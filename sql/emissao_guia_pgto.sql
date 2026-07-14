select
	gpg.imov_id as "matricula",
	uni.unid_dsunidade as "setor emissao",
	gpg.gpag_dtemissao as "data emissao"
	
from
	faturamento.guia_pagamento gpg
	inner join seguranca.usuario usu ON usu.usur_id = gpg.usur_id
	inner join cadastro.unidade_organizacional uni ON uni.unid_id = usu.unid_id
where
	gpg.gpag_dtemissao > '2024-02-01'
	
