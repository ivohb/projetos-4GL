nivel_autorid_265^cod_empresa^256^2^1^
nivel_autorid_265^cod_nivel_autorid^256^2^2^
nivel_autorid_265^den_nivel_autorid^256^30^3^
nivel_autorid_265^cod_nivel_subst^0^2^4^


nivel_hierarq_265^empresa^256^2^1^
nivel_hierarq_265^nivel_autoridade^256^2^2^
nivel_hierarq_265^hierarquia^261^512^3^

create table nivel_hierarq_265 (
  empresa               char(02),
  nivel_autoridade      char(02),
  hierarquia            decimal(3,0)
):

create table nivel_autorid_265 (
   cod_empresa         char(02),
   cod_nivel_autorid   char(02),
   den_nivel_autorid   char(30),
   cod_nivel_subst     char(02)
);
