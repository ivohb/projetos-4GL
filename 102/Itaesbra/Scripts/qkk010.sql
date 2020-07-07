






{ TABLE "informix".qkk010 row size = 448 number of columns = 38 index size = 344 
              }
create table "informix".qkk010 
  (
    qkk_filial varchar(2) 
        default '  ' not null ,
    qkk_peca varchar(40) 
        default '                                        ' not null ,
    qkk_rev varchar(2) 
        default '  ' not null ,
    qkk_proces varchar(4) 
        default '    ' not null ,
    qkk_revinv varchar(2) 
        default '  ' not null ,
    qkk_nope varchar(7) 
        default '       ' not null ,
    qkk_desc varchar(80) 
        default '                                                                                ' 
              not null ,
    qkk_pecalo varchar(20) 
        default '                    ' not null ,
    qkk_maq varchar(10) 
        default '          ' not null ,
    qkk_nommaq varchar(50) 
        default '                                                  ' not null ,
    qkk_setor varchar(15) 
        default '               ' not null ,
    qkk_seqant varchar(7) 
        default '       ' not null ,
    qkk_chave varchar(8) 
        default '        ' not null ,
    qkk_seqpos varchar(7) 
        default '       ' not null ,
    qkk_planta varchar(3) 
        default '   ' not null ,
    qkk_pccicl float 
        default 0.0000000000000000 not null ,
    qkk_qtdh float 
        default 0.0000000000000000 not null ,
    qkk_pchora float 
        default 0.0000000000000000 not null ,
    qkk_pcseg float 
        default 0.0000000000000000 not null ,
    qkk_tpope varchar(1) 
        default ' ' not null ,
    qkk_sbope varchar(2) 
        default '  ' not null ,
    qkk_area varchar(30) 
        default '                              ' not null ,
    qkk_func varchar(50) 
        default '                                                  ' not null ,
    qkk_simita varchar(2) 
        default '  ' not null ,
    qkk_simb2 varchar(2) 
        default '  ' not null ,
    qkk_simb3 varchar(2) 
        default '  ' not null ,
    qkk_luva varchar(1) 
        default ' ' not null ,
    qkk_bota varchar(1) 
        default ' ' not null ,
    qkk_abafad varchar(1) 
        default ' ' not null ,
    qkk_oculos varchar(1) 
        default ' ' not null ,
    qkk_aventa varchar(1) 
        default ' ' not null ,
    qkk_mangot varchar(1) 
        default ' ' not null ,
    qkk_mascar varchar(1) 
        default ' ' not null ,
    qkk_bitmap varchar(20) 
        default '                    ' not null ,
    qkk_msblql varchar(1) 
        default ' ' not null ,
    qkk_item varchar(4) 
        default '    ' not null ,
    d_e_l_e_t_ varchar(1) 
        default ' ' not null ,
    r_e_c_n_o_ integer 
        default 0 not null ,
    primary key (r_e_c_n_o_)  constraint "informix".qkk010_pk
  );

revoke all on "informix".qkk010 from "public" as "informix";


create index "informix".qkk0101 on "informix".qkk010 (qkk_filial,
    qkk_peca,qkk_rev,qkk_item,r_e_c_n_o_,d_e_l_e_t_) using btree 
    ;
create index "informix".qkk0102 on "informix".qkk010 (qkk_filial,
    qkk_peca,qkk_rev,qkk_nope,r_e_c_n_o_,d_e_l_e_t_) using btree 
    ;
create index "informix".qkk0103 on "informix".qkk010 (qkk_filial,
    qkk_peca,qkk_revinv,qkk_item,r_e_c_n_o_,d_e_l_e_t_) using 
    btree ;
create index "informix".qkk0104 on "informix".qkk010 (qkk_filial,
    qkk_chave,r_e_c_n_o_,d_e_l_e_t_) using btree ;
create index "informix".qkk0105 on "informix".qkk010 (qkk_filial,
    qkk_proces,qkk_peca,qkk_rev,qkk_nope,r_e_c_n_o_,d_e_l_e_t_) 
    using btree ;
create index "informix".qkk0106 on "informix".qkk010 (qkk_filial,
    qkk_proces,qkk_nope,r_e_c_n_o_,d_e_l_e_t_) using btree ;
create index "informix".qkk0107 on "informix".qkk010 (qkk_filial,
    qkk_proces,qkk_rev,r_e_c_n_o_,d_e_l_e_t_) using btree ;


