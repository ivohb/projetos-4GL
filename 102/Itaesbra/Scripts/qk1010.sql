






{ TABLE "informix".qk1010 row size = 1081 number of columns = 54 index size = 463 
              }
create table "informix".qk1010 
  (
    qk1_filial varchar(2) 
        default '  ' not null ,
    qk1_peca varchar(40) 
        default '                                        ' not null ,
    qk1_rev varchar(2) 
        default '  ' not null ,
    qk1_revinv varchar(2) 
        default '  ' not null ,
    qk1_dtrevi varchar(8) 
        default '        ' not null ,
    qk1_pccli varchar(40) 
        default '                                        ' not null ,
    qk1_descli varchar(30) 
        default '                              ' not null ,
    qk1_ppap varchar(40) 
        default '                                        ' not null ,
    qk1_desc varchar(150) 
        default '                                                                                                                                                      ' 
              not null ,
    qk1_codcli varchar(6) 
        default '      ' not null ,
    qk1_lojcli varchar(2) 
        default '  ' not null ,
    qk1_nomcli varchar(40) 
        default '                                        ' not null ,
    qk1_ndes varchar(30) 
        default '                              ' not null ,
    qk1_revdes varchar(15) 
        default '               ' not null ,
    qk1_dtrdes varchar(8) 
        default '        ' not null ,
    qk1_projet varchar(40) 
        default '                                        ' not null ,
    qk1_motivo varchar(50) 
        default '                                                  ' not null ,
    qk1_alteng varchar(100) 
        default '                                                                                                    ' 
              not null ,
    qk1_dteng varchar(8) 
        default '        ' not null ,
    qk1_doc varchar(30) 
        default '                              ' not null ,
    qk1_tplogo varchar(1) 
        default ' ' not null ,
    qk1_codequ varchar(5) 
        default '     ' not null ,
    qk1_produt varchar(15) 
        default '               ' not null ,
    qk1_revi varchar(2) 
        default '  ' not null ,
    qk1_just varchar(50) 
        default '                                                  ' not null ,
    qk1_status varchar(1) 
        default ' ' not null ,
    qk1_dtence varchar(8) 
        default '        ' not null ,
    qk1_dtreab varchar(8) 
        default '        ' not null ,
    qk1_licpk float 
        default 0.0000000000000000 not null ,
    qk1_lscpk float 
        default 0.0000000000000000 not null ,
    qk1_altdoc varchar(20) 
        default '                    ' not null ,
    qk1_nalprj varchar(1) 
        default ' ' not null ,
    qk1_codvcl varchar(20) 
        default '                    ' not null ,
    qk1_revcli varchar(2) 
        default '  ' not null ,
    qk1_dtrevc varchar(8) 
        default '        ' not null ,
    qk1_cjtdes varchar(30) 
        default '                              ' not null ,
    qk1_cjtrev varchar(2) 
        default '  ' not null ,
    qk1_cjrevd varchar(8) 
        default '        ' not null ,
    qk1_pesoli float 
        default 0.0000000000000000 not null ,
    qk1_cjpeso float 
        default 0.0000000000000000 not null ,
    qk1_qtdecj float 
        default 0.0000000000000000 not null ,
    qk1_codigo varchar(40) 
        default '                                        ' not null ,
    qk1_usuari varchar(50) 
        default '                                                  ' not null ,
    qk1_visto varchar(50) 
        default '                                                  ' not null ,
    qk1_tipo varchar(1) 
        default ' ' not null ,
    qk1_pecseg varchar(1) 
        default ' ' not null ,
    qk1_fluxo varchar(1) 
        default ' ' not null ,
    qk1_msblql varchar(1) 
        default ' ' not null ,
    qk1_dtelab varchar(8) 
        default '        ' not null ,
    qk1_okapro varchar(1) 
        default ' ' not null ,
    qk1_dtvist varchar(8) 
        default '        ' not null ,
    d_e_l_e_t_ varchar(1) 
        default ' ' not null ,
    r_e_c_n_o_ integer 
        default 0 not null ,
    r_e_c_d_e_l_ integer 
        default 0 not null ,
    primary key (r_e_c_n_o_)  constraint "informix".qk1010_pk
  ) extent size 16 next size 16 lock mode row;

revoke all on "informix".qk1010 from "public" as "informix";


create index "informix".qk10101 on "informix".qk1010 (qk1_filial,
    qk1_peca,qk1_rev,r_e_c_n_o_,d_e_l_e_t_) using btree  in prd;
    
create index "informix".qk10102 on "informix".qk1010 (qk1_filial,
    qk1_peca,qk1_revinv,r_e_c_n_o_,d_e_l_e_t_) using btree  in 
    prd;
create index "informix".qk10103 on "informix".qk1010 (qk1_filial,
    qk1_codcli,qk1_lojcli,qk1_peca,qk1_rev,r_e_c_n_o_,d_e_l_e_t_) 
    using btree  in prd;
create index "informix".qk10104 on "informix".qk1010 (qk1_filial,
    qk1_ppap,qk1_peca,qk1_rev,r_e_c_n_o_,d_e_l_e_t_) using btree 
     in prd;
create index "informix".qk10105 on "informix".qk1010 (qk1_filial,
    qk1_fluxo,qk1_ppap,r_e_c_n_o_,d_e_l_e_t_) using btree  in 
    prd;
create index "informix".qk10106 on "informix".qk1010 (qk1_filial,
    qk1_ppap,qk1_rev,r_e_c_n_o_,d_e_l_e_t_) using btree  in prd;
    
create unique index "informix".qk1010_unq on "informix".qk1010 
    (qk1_filial,qk1_peca,qk1_rev,r_e_c_d_e_l_) using btree  in 
    prd;


