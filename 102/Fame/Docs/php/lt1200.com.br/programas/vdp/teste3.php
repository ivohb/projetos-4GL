<?
   $ajusta_zona="select * from vnpfisic";
   $res_ajusta = $cconnect("logix",$ifx_user,$ifx_senha);
   $result_ajusta = $cquery($ajusta_zona,$res_ajusta);
   $mat_ajusta=$cfetch_row($result_ajusta);
   while (is_array($mat_ajusta))
   {
    $cdfilial=chop($mat_ajusta["cdfilial"]);
    $cod=round($mat_ajusta["cod"]);
    $aju_ajusta="update lt1200_hist_comis set zona='".$cdfilial."'
                 where cod_repres='".$cod."' 
                  and mes_ref='07'
                  and ano_ref='2006'  ";
    $res_aju = $cconnect("lt1200",$ifx_user,$ifx_senha);
    $result_aju = $cquery($aju_ajusta,$res_aju);
    printf($aju_ajusta);
    $mat_ajusta=$cfetch_row($result_ajusta);
   }
?>