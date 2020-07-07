drop  table man_apont_912;
create table man_apont_912 
  (
    cod_empresa char(2),
    id_registro integer,
    num_ordem integer,
    num_pedido integer,
    num_seq_pedido integer,
    cod_item char(15),
    cod_roteiro char(15),
    num_rot_alt decimal(2,0),
    num_lote char(15),
    dat_inicial datetime,
    dat_final datetime,
    cod_recur char(5),
    cod_operac char(5),
    num_seq_operac decimal(3,0),
    oper_final char(1),
    cod_cent_trab char(5),
    cod_cent_cust decimal(4,0),
    cod_unid_prod char(5),
    cod_arranjo char(5),
    qtd_refugo decimal(10,3),
    qtd_sucata decimal(10,3),
    qtd_boas decimal(10,3),
    comprimento integer,
    largura integer,
    altura integer,
    diametro integer,
    tip_apon char(1),
    tip_operacao char(1),
    cod_local_prod char(10),
    cod_local_est char(10),
    qtd_hor decimal(11,7),
    matricula char(8),
    cod_turno char(1),
    hor_inicial char(5),
    hor_final char(5),
    unid_funcional char(10),
    dat_atualiz datetime,
    ies_terminado char(1),
    cod_eqpto char(15),
    cod_ferramenta char(15),
    integr_min char(1),
    nom_prog char(8),
    nom_usuario char(8),
    cod_status char(1),
    num_processo integer,
    num_proc_ant integer,
    num_proc_dep integer,
    num_transac integer,
    mensagem char(210),
    dat_process datetime,
    id_apont integer,
    id_tempo integer,
    integrado integer,
    den_erro char(500),
    dat_integra char(20),
    usuario char(8),
    tip_integra char(1),
    concluido char(1),
    num_docum char(15),
    qtd_movto decimal(10,3),
    tip_movto char(1),
    qtd_tempo integer,
    dat_criacao datetime,
    qtd_retrab decimal(10,3),
    seq_reg_mestre  integer,
    qtd_estornada decimal(10,3)
  );

create unique index ix_man_apont_912 
  on man_apont_912(cod_empresa, id_registro);
  
create table apont_erro_912 (
  cod_empresa       char(02),
  seq_reg_mestre    integer,
  erro              char(100),
  num_ordem         integer
);

create index ix_apont_erro_912 
  on apont_erro_912(cod_empresa, seq_reg_mestre);


create table trans_relac_885 (
 cod_empresa      char(02),
 seq_reg_mestre   integer,
 num_transac_orig integer,
 num_transac_dest integer 
);

create unique index ix_trans_relac_885 
  on trans_relac_885(cod_empresa, seq_reg_mestre);


         create table trans_relac_om_885 (
            cod_empresa      char(02),
            num_om           integer,
            num_pedido       integer,
            num_sequencia    integer,
            num_transac_orig integer,
            num_transac_dest integer
           );


           create index ix_trans_relac_om_885 on
            trans_relac_om_885(cod_empresa, num_om)
            
            
create table boletim_ond_885 (
 chav_acesso      decimal(14,0),  -- yyyymmddhhmmss
 num_boletim      int,
 num_versao       int,      -- enviar sempre 0 (se a Aline alterar o consumo, eu crio a vers�o 1)
 dat_producao     datetime, -- yyyy-mm-dd
 cod_composicao   char(15), -- KKB345, por exemplo
 num_of           int,  -- n�mero da ordem de fabrica��o
 cod_material     char(15), -- c�digo do papel no logix (MI100, por ex.)
 qtd_consumo      decimal(10,3), -- quantidade consumida pela OF
 cod_operacao     char(01), -- A=Apontar baixa E=Estronar baixa
 status_registro  char(01), -- 0=Enviado pelo Trim 1=Aceito pelo Logix 2=Criticado pelo Logix
 num_sequencia    int identity(1,1),
 cod_baixar       char(15), -- c�digo a baixar informado pelo usu�rio(uso s� do logix)
 qtd_baixar       decimal(10,3), -- quantidade a baixar informada pelo usu�rio(uso s� do logix)
 num_of_chapa     int, -- n�mero da OF da chapa do item do pedido (uso s� do logix)
 num_transac      int, -- n�mero do movimento de estoque (uso s� do logix)
 primary key(num_sequencia)
);



DROP TABLE nao_agrupar_885
CREATE TABLE nao_agrupar_885 (
 cod_empresa      char(02) not null,
 cod_cliente      char(15) not null,
 primary key(cod_empresa, cod_cliente)
)
