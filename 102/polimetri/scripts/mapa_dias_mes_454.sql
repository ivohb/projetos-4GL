CREATE TABLE mapa_dias_mes_454
	(
	cod_empresa CHAR (2),
	data_processamento DATETIME YEAR TO SECOND,
	qtd_dias_mes DECIMAL (4, 2),
	qtd_saldo_dias_mes DECIMAL (4, 2),
	qtd_dias_mes_1 DECIMAL (4, 2),
	qtd_dias_mes_2 DECIMAL (4, 2),
	qtd_dias_mes_3 DECIMAL (4, 2),
	qtd_dias_mes_4 DECIMAL (4, 2),
	PRIMARY KEY (cod_empresa,data_processamento)
	);

