
		CREATE TABLE clientes_codesp(
				cod_cliente			CHAR(15),
				tipo_cliente		CHAR(01),
				nom_cliente			CHAR(60),
				nom_reduzido		CHAR(15),
				end_cliente			CHAR(36),
				den_bairro			CHAR(19),
				cidade				CHAR(50),
				cod_cidade			CHAR(07),
				cod_cep				CHAR(09),
				estado				CHAR(02),
				telefone			CHAR(15),
				num_fax				CHAR(15),
				ins_estadual		CHAR(15),
				end_cod				CHAR(36),
				den_bairro_cob		CHAR(19),
				cidade_cob			CHAR(50),
				cod_cidade_cob		CHAR(07),
				estado_cob			CHAR(02),
				cod_cep_cob			CHAR(09),
				contato				CHAR(15),
				Emal1				CHAR(50),
				Emal2				CHAR(50),
				Emal3				CHAR(50),
		    id_registro     INTEGER,
		    cod_status  CHAR(01)
		 )

   create table rejeicao_cli_codesp (
      id_cliente      integer,
      motivo          char(70)
   );

		CREATE   TABLE nfs_codesp(
			cod_empresa				CHAR(02),
			num_nf  				DECIMAL(6,0),
			serie 					CHAR(02),
			cod_cliente 			CHAR(15),
			data_emissao			DATE,
			data_vencto				DATE,
			val_tot_nff				DECIMAL(17),
			val_duplicata			DECIMAL(17),
			num_boleto				CHAR(15),
			ies_situacao			CHAR(1),
			data_cancel     		CHAR(15),
			texto_fatura		 	CHAR(300),
			viagem	  				CHAR(6),
			navio	  				CHAR(20),	
			atracacao  				CHAR(7),	
			data_atracacao			CHAR(10),	
			data_desatracacao		CHAR(10),
			contrato				CHAR(10),	
			local					CHAR(50),	
			documento				CHAR(18),
			tip_carteira			CHAR(02),
			id_registro   INTEGER,
			cod_status    CHAR(01)
		)

   create table rejeicao_nfs_codesp (
      id_nf_mestre    integer,
      num_seq         integer,
      motivo          char(70)
   );


		CREATE  TABLE itens_nfs_codesp(
			cod_empresa					CHAR(02),
			num_nf  					DECIMAL(6,0),
			serie 						CHAR(02),
			cod_cliente 				CHAR(15),
			sequencia					DECIMAL(5,0),
			cod_item 					CHAR(15) ,
			den_item					CHAR(76),
			qtd_item					DECIMAL(17),
			unidade_medida				CHAR(03),
			pre_unit					DECIMAL(17),
			val_liq_item				DECIMAL(17),
			pct_iss	  					DECIMAL(5),
			val_tot_base_iss			DECIMAL(17),
			val_iss			      		DECIMAL(17),
			pct_icms					DECIMAL(5),
			val_tot_base_icms			DECIMAL(17),
			val_tot_icms				DECIMAL(17),
			pct_irpj					DECIMAL(5),
			val_base_irpj				DECIMAL(17),
			val_irpj					DECIMAL(17),			
			pct_csll					DECIMAL(5),
			val_base_csll				DECIMAL(17),
			val_csll					DECIMAL(17),			
			pct_cofins					DECIMAL(5),
			val_base_cofins				DECIMAL(17),
			val_cofins					DECIMAL(17),
			pct_pis						DECIMAL(5),	
			val_base_pis				DECIMAL(17),
			val_pis						DECIMAL(17),
			ies_trib_pis_cofins			CHAR(01)
		)

		CREATE   TABLE nfs_texto_codesp(
			cod_empresa				CHAR(02),
			num_nf  				DECIMAL(6,0),
			serie 					CHAR(02),
			cod_cliente 			CHAR(15),
			sequencia_texto			DECIMAL(05),
			des_texto   			CHAR(300),		
			id_registro     INTEGER,
			cod_status      CHAR(01)
		);
		
