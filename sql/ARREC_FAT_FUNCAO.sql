SELECT 
	res.ardd_amreferenciaarrecadacao AS "REFERENCIA",
	res.ardd_dtpagamento AS "DATA PAGAMENTO",
	CASE 
	WHEN EXTRACT(YEAR FROM res.ardd_dtpagamento) * 100 + EXTRACT(MONTH FROM res.ardd_dtpagamento) = res.ardd_amreferenciaarrecadacao THEN res.ardd_dtpagamento
	ELSE TO_DATE(CAST(res.ardd_amreferenciaarrecadacao AS VARCHAR) || '01', 'YYYYMMDD')
	END AS "RESULTADO",
	TO_CHAR(SUM(res.ardd_vlpagamentos), 'L999G999G990D00') AS  "VALOR PAGAMENTO"
FROM arrecadacao.arrec_dados_diarios res
WHERE 
	res.ardd_amreferenciaarrecadacao = 202309
GROUP BY 1,2,3
	