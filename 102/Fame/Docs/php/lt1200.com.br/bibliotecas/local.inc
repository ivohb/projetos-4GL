<?php
   $sel_local="select * from local 
                         where cod_empresa='".$empresa."'
                       order by cod_local";
   $link=$cconnect("logix",$ifx_user,$ifx_senha);
   $res_local=$cquery($sel_local,$link);
   $mat_local=$cfetch_row($res_local);
   $cod_local='TT';
   $nom_local='Todos';
   printf("<tr>
            <td width='50'  style=$n_style colspan='5'     align='center'>
             <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
             Local:</font></i>
            </td>
         <td width='100'  style=$n_style colspan='10'  >  
          <select name='local'>");
  printf("<option value='$cod_local' >$nom_local</option>");
  while(is_array($mat_local))
  {
   $cod_local=trim($mat_local["cod_local"]);
   $nom_local=trim($mat_local["cod_local"]).'-'.trim($mat_local["den_local"]);
   printf("<option value='$cod_local' >$nom_local</option>");
   $mat_local=$cfetch_row($res_local);
  }
  printf("</select>
         </td> ");
?>