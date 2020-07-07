<?php
  $transac=" set isolation to dirty read";
  $res_trans = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_trans = $cquery($transac,$res_trans);
  $transac=" set isolation to dirty read";
  $res_trans = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result_trans = $cquery($transac,$res_trans);

  $del_atu="delete from lt1200_dat_pedido
            where cod_usuario='".$ifx_user."' ";
  $res_del = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result_del = $cquery($del_atu,$res_del);


  $atu_pedido="insert into lt1200_dat_pedido
            select '".$ifx_user."',b.cdped,a.cod_palm,a.dt_import
                from logix:vnimpped a,logix:vnxeorca b,logix:pedidos c
                    where a.cod_item='000'
                      and b.cod=a.cod_crm
                      and c.num_pedido=b.cdped
                      and c.dat_pedido<>a.dt_import
                       ";

  $res_atu = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result_trans = $cquery($atu_pedido,$res_atu);

  $atu_sel="select num_pedido_logix,num_pedido_palm,dt_import
                from lt1200_dat_pedido
                where cod_usuario='".$ifx_user."' ";
  $res_sel = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result_sel = $cquery($atu_sel,$res_sel);

  $mat_sel=$cfetch_row($result_sel);
  while (is_array($mat_sel))
  {
   $num_pedido=$mat_sel["num_pedido_logix"];
   $num_pedido_repres=round($mat_sel["num_pedido_palm"]);
   $dat_pedido=$mat_sel["dt_import"];
   $atu_data="update pedidos set
          dat_pedido='".$dat_pedido."',
          num_pedido_repres='".$num_pedido_repres."'
        where cod_empresa='01'
          and num_pedido='".$num_pedido."' ";
   $res_data = $cconnect("logix",$ifx_user,$ifx_senha);
   $result_data = $cquery($atu_data,$res_data);
   $mat_sel=$cfetch_row($result_sel);
  }

  $del_atu="delete from lt1200_dat_pedido
            where cod_usuario='".$ifx_user."' ";
  $res_del = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result_del = $cquery($del_atu,$res_del);


  $atu_pedido="insert into lt1200_dat_pedido
            select '".$ifx_user."',b.cdped,a.cod_palm,a.dt_import
                from logix:vnimpped a,logix:vnxeorca b,logix:pedido_dig_mest c
                    where a.cod_item='000'
                      and b.cod=a.cod_crm
                      and c.num_pedido=b.cdped
                      and c.dat_digitacao<>a.dt_import

                       ";

  $res_atu = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result_trans = $cquery($atu_pedido,$res_atu);

  $atu_sel="select num_pedido_logix,num_pedido_palm,dt_import
                from lt1200_dat_pedido
                where cod_usuario='".$ifx_user."' ";
  $res_sel = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result_sel = $cquery($atu_sel,$res_sel);

  $mat_sel=$cfetch_row($result_sel);
  while (is_array($mat_sel))
  {
   $num_pedido=$mat_sel["num_pedido_logix"];
   $num_pedido_repres=round($mat_sel["num_pedido_palm"]);
   $dat_pedido=$mat_sel["dt_import"];
   $atu_data="update pedido_dig_mest set
          dat_digitacao='".$dat_pedido."',
          num_pedido_repres='".$num_pedido_repres."'
        where cod_empresa='01'
          and num_pedido='".$num_pedido."' ";
   $res_data = $cconnect("logix",$ifx_user,$ifx_senha);
   $result_data = $cquery($atu_data,$res_data);
   $mat_sel=$cfetch_row($result_sel);
  }

?>
