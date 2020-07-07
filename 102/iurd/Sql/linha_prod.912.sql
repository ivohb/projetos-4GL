CREATE TABLE linha_prod_sgiurd_912
	(
	id_registro        integer,
	cod_lin_prod       DECIMAL(2,0),
	cod_lin_recei      DECIMAL(2,0),
	cod_seg_merc       DECIMAL(2,0),
	cod_cla_uso        DECIMAL(2,0),
	cod_igreja         CHAR (12),
	primary key(id_registro)
);

CREATE INDEX linha_prod_sgiurd_912
	ON linha_prod_sgiurd_912 
(cod_lin_prod, cod_lin_recei, cod_seg_merc, cod_cla_uso );

