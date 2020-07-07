CREATE TABLE  ficha_cacamba_970
    (
    id_registro       SERIAL,
    cod_empresa      	CHAR (2),
    cod_item         	CHAR (15),
    cod_item_cliente  CHAR(30),
    rua   			      CHAR(3),
    vao 			        CHAR(6),
    data              DATE,
    rastro            char(15),   
    observacao    	  CHAR(34),
    num_seq          	DECIMAL(3,0),
    num_sub_seq      	DECIMAL(3,0),
    opprox           	CHAR (10),
    setatual         	CHAR (10),
    setprox         	 CHAR (10),
    ies_impresso      CHAR (1),
    numero_copias  	  DECIMAL(3,0),
    quantidade        DECIMAL(10,3),
    primary key(id_registro)

); 

CREATE unique INDEX ix_ficha_cacamba_970
    ON ficha_cacamba_970 (cod_empresa, cod_item, rastro);
