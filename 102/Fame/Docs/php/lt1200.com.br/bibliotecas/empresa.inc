<?php
   $sel_empresa="select * from empresa 
                         where cod_empresa='".$emp_padrao."'";
   $link=$cconnect("logix",$ifx_user,$ifx_senha);
   $res_empresa=$cquery($sel_empresa,$link);
   $mat_empresa=$cfetch_row($res_empresa);
   $cod_emp=trim($mat_empresa["cod_empresa"]);
   $nom_emp=trim($mat_empresa["cod_empresa"]).'-'.trim($mat_empresa["den_empresa"]);
   printf("<tr>
            <td width='100'  style=$n_style colspan='10'     align='center'>
             <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
             Empresa:</font></i>
            </td>
         <td width='200'  style=$n_style colspan='20'  >  
          <select name='empresa'>");
  printf("<option value='$cod_emp'  selected>$nom_emp</option>");

  $sel_empresa="select * from empresa 
                         where cod_empresa<>'".$emp_padrao."'
                          order by cod_empresa";
  $link=$cconnect("logix",$ifx_user,$ifx_senha);
  $res_empresa=$cquery($sel_empresa,$link);
  $mat_empresa=$cfetch_row($res_empresa);
  while(is_array($mat_empresa))
  {
   $cod_emp=trim($mat_empresa["cod_empresa"]);
   $nom_emp=trim($mat_empresa["cod_empresa"]).'-'.trim($mat_empresa["den_empresa"]);
   printf("<option value='$cod_emp' >$nom_emp</option>");
   $mat_empresa=$cfetch_row($res_empresa);
  }
  printf("</select>
         </td> ");
?>