CREATE TABLE erro_critico_405 (
    cod_empresa  CHAR(02),
    nom_usuario  CHAR(08),
    num_programa CHAR(50),
    dat_process  DATETIME YEAR TO SECOND,
    cod_erro     CHAR(07),
    den_critica  CHAR(80)
);

CREATE INDEX erro_critico_405 ON
 erro_critico_405(cod_empresa,cod_erro);
