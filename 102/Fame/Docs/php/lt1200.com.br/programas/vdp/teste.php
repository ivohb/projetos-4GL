<?

  $ajusta_zona="select cod as cod_repres,cdfilial
                  from vnpfisic" ;
  $res_zona = $cconnect("logix",$ifx_user,$ifx_senha);
  $result_zona = $cquery($ajusta_zona,$res_zona);     
   $mat_zona=$cfetch_row($result_zona);
   while (is_array($mat_zona))
   {
    $cod_aju=round($mat_zona["cod_repres"]);
    $zona_aju=chop($mat_zona["cdfilial"]);
    $ajuste="update lt1200_hist_comis set zona='".$zona_aju."'
               where cod_repres='".$cod_aju."' 
                     and ano_ref='2006'
                     and mes_ref < 6
                      " ;
    $res_ajuste = $cconnect("lt1200",$ifx_user,$ifx_senha);
    $cquery($ajuste,$res_ajuste);     
    $mat_zona=$cfetch_row($result_zona);
   }

?>