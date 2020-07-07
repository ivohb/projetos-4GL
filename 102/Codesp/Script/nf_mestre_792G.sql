CREATE TABLE nf_mestre_792G (
			cod_empresa				CHAR(02),
			num_docum					DECIMAL(6,0),
			especie						CHAR(03),
			cod_cliente 			CHAR(14),
			data_emissao			DATE,
			data_vencto				DATE,
			val_tot_nff				DECIMAL(17,2),
			val_duplicata			DECIMAL(17,2),
			num_boleto				CHAR(15),
			ies_situacao			CHAR(1),
			texto_fatura		  CHAR(300),
			status_registro   CHAR(01)
);