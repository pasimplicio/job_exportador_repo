SELECT 
	((2*6378.137*asin(sqrt(pow(sin((radians(-2.502988)-radians(imov_nncoordenadax))/2),2)+cos(radians(-2.502988))*cos(radians(imov_nncoordenadax))*pow(sin((radians(-44.269712)-radians(imov_nncoordenaday))/2),2))))*1000) AS "DISTANCIA",
	* 
FROM 
	cadastro.imovel
WHERE 
	NOT imov_nncoordenadax IS NULL
	AND NOT imov_nncoordenaday IS NULL
	AND ((2*6378.137*asin(sqrt(pow(sin((radians(-2.502988)-radians(imov_nncoordenadax))/2),2)+cos(radians(-2.502988))*cos(radians(imov_nncoordenadax))*pow(sin((radians(-44.269712)-radians(imov_nncoordenaday))/2),2))))*1000) <= 5000
ORDER BY 1 ASC
--LIMIT 100