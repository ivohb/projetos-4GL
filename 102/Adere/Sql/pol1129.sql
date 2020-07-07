-- delete from conjuga_ops_912
select * from conjuga_ops_912
select * from ord_oper where num_ordem in (1184485, 1174209, 1200059, 1198915, 1205163)
select * from recurso order by cod_empresa, cod_recur

1184485 = 1198915 operac
1200059 = 1205163 operac

      DECLARE cq_operacoes CURSOR FOR
       SELECT
              cod_arranjo
         FROM ord_oper
        WHERE cod_empresa      = p_cod_empresa
          AND num_ordem        = lr_dados_ordem.num_ordem
          AND num_seq_operac ordem        = lr_dados_ordem.num_seq_operac

      FOREACH cq_operacoes INTO
              l_cod_arranjo


                    DECLARE cq_recurso CURSOR FOR
         SELECT a.cod_recur
           FROM rec_arranjo a
          WHERE a.cod_empresa = p_cod_empresa
            AND a.cod_arranjo = l_cod_arranjo
            AND a.cod_recur IN
                 (SELECT b.cod_recur FROM recurso b
                   WHERE b.cod_empresa   = a.cod_empresa
                     AND b.cod_recur     = a.cod_recur
                     AND b.ies_tip_recur = '2')


    FOREACH cq_recurso     INTO lr_dados_ordem.cod_recur
                            EXIT FOREACH
                END FOREACH
