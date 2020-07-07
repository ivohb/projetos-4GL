create table man_apont_912 (
cod_empresa           char(02),
id_registro           integer,
num_ordem             integer,
num_pedido            integer,
num_seq_pedido        integer,
cod_item             char(15),
cod_roteiro          char(15),
num_rot_alt          decimal(3,0),
num_lote             char(15),
dat_inicial          datetime,
dat_final            datetime,
cod_recur            char(05),
cod_operac           char(05),
num_seq_operac       decimal(3,0),
oper_final           char(01),
cod_cent_trab        char(05),
cod_cent_cust        decimal(4,0),
cod_unid_prod        char(05),
cod_arranjo          char(05),
qtd_refugo           decimal(10,3),
qtd_sucata           decimal(10,3),
qtd_boas             decimal(10,3),
comprimento          integer,
largura              integer,
altura               integer,
diametro             integer,
tip_apon             char(01),
tip_operacao         char(01),
cod_local_prod       char(10),
cod_local_est        char(10),
qtd_hor              decimal(11,7),
matricula            char(08),
cod_turno            char(01),
hor_inicial          char(05),
hor_final            char(05),
unid_funcional       char(10),
dat_atualiz          datetime,
ies_terminado        char(01),
cod_eqpto            char(15),
cod_ferramenta       char(15),
integr_min           char(01),
nom_prog             char(08),
nom_usuario          char(08),
cod_status           char(01),
num_processo         integer,
num_proc_ant         integer,
num_proc_dep         integer,
num_transac          integer,
mensagem             char(210),
dat_process          datetime,
id_apont             integer,
id_tempo             integer,
integrado            integer,
den_erro             char(500),
dat_integra          char(20),
usuario              char(08),
tip_integra          char(01),
concluido            char(01),
num_docum            char(15),
qtd_movto            decimal(10,3),
tip_movto            char(01),
qtd_tempo            integer,
dat_criacao          datetime,
qtd_retrab           decimal(10,3),
seq_reg_mestre       integer,
qtd_estornada        decimal(10,3),
primary key(id_registro)
)