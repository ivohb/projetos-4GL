<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manutenção:    Henrique
 //Data manutenção:22/06/2005
 //Módulo:        ADMSIS
 //Processo:      Cadastro de Clientes que utilizam est programa
 //-----------------------------------------------------------------------------
 $dia=date("d");
 $mes=date("m");
 $ano=date("Y");
 $hora=date("h");
 $min=date("i");
 $data=sprintf("%02d/%02d/%04d-%02d:%02d",$dia,$mes,$ano,$hora,$min);
 $ip=$HTTP_X_FORWARDED_FOR;
 $ip_ext=$REMOTE_ADDR;
 $teste=session_register("id");
 session_register("ifx_user");
 session_register("ifx_senha");
 if(!$teste)
 {
  $msg = "Não foi possível registrar essa sessão. <br>Favor habilite o recebimento de cookies no seu browser.";
  break;
 }
 function fechar()
 {
  echo "<script language=\"javascript\">";
  echo "window.close()";
  echo "</script>";
 }                                
 $prog="admsis/man0003";
 include("../../bibliotecas/usuario.inc");
 printf("<html>");
 printf("<head>");
 printf("<meta http-equiv='Content-Type' content='text/html;charset=iso-8859-1'>");
 $nome_="Tabelas por Programa";
 printf("<title>$nome_</title>");
 printf("</head>");
 printf("<basefont face='Arial, Helvetica, sans-serif' size='1' color=$c_color>");
 include("../../bibliotecas/style.inc");
 $selec_tables="select *
           from lt1200_cli_prog
	where	programa='".$programa."'
        order by cod_cliente
	";
 $res_tables = $cconnect("lt1200",$ifx_user,$ifx_senha);
 $result_tables = $cquery($selec_tables,$res_tables);
 $mat_tables=$cfetch_row($result_tables);
 if($prog_c=="I")
 {
  $fazer="I";
 }elseif($prog_c=="A")
 {
  $fazer="A";
 }elseif($prog_c=="E")
 {
  $fazer="E";
 }else{
  $fazer="N";
 }

 if($fazer=='E')
 {
  $cons_faz="delete from  lt1200_cli_prog 
	    where programa='".$programa."'
		  and cod_cliente='".$cod_cliente_c."'
              ";

  $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result_faz = $cquery($cons_faz,$res_faz);
  $prog_c="N";
 }
 if($fazer=='I')
 {
  $cons_faz="insert into  lt1200_cli_prog (
	  cod_cliente,programa)
        values ('".$cod_cliente."','".$programa ."')";
  $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result_faz = $cquery($cons_faz,$res_faz);
  $prog_c="N";
 }
 if($fazer=='A')
 {
  $cons_faz="update  lt1200_cli_prog set
                         cod_cliente='".$cod_cliente."'
                     where programa='".$programa."'
                       and cod_cliente='".$cod_cliente_c."'";
  $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result_faz = $cquery($cons_faz,$res_faz);
  $prog_c="N";
 }
 $selec_tables="select  * 
       from lt1200_cli_prog a
	where	a.programa='".$programa."'
        order by cod_cliente
 	";
 $res_tables = $cconnect("lt1200",$ifx_user,$ifx_senha);
 $result_tables =$cquery($selec_tables,$res_tables);
 $mat_tables=$cfetch_row($result_tables);
 printf("<tr>     
      <td width='750'  style=$n_style colspan='75'     align='center'>
       <b><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       CLIENTES QUE UTILIZAM ESTE  PROGRAMA  $programa</font></b>
      </td>
     </tr>
     <tr>     
      <td width='150'  style=$n_style colspan=15      align='center'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       cliente</font></b>
      </td>
      <td width='450'  style=$n_style colspan=45      align='center'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       NOME DO CLIENTE</font></b>
      </td>
     </tr>
     ");
  printf("<FORM METHOD='POST' ACTION='man0003_c.php'>");
  printf("</tr>
      <tr>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' name='programa' size='10' maxlenght='10'
       value='".$programa."' readonly> 
      </td>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='I' name='prog_c' size='1' maxlenght='1' readonly> 
      </td>
     </tr> 
     <tr>     
      <td width='150'  style=$n_style colspan='15'      align='right'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='cod_cliente'  size='20' maxlenght='20'
       >  
      </td>
      <td width='80'  style=$n_style colspan='8'      align='center'>
       <input type='submit' name='Confirmar' value='Incluir '>
      </td>
     </tr> 
     </FORM>");

 while (is_array($mat_tables))
 {
  $cod_cliente=$mat_tables["cod_cliente"];
  printf("<FORM METHOD='POST' ACTION='man0003_c.php'>");
  printf("<tr>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' name='programa' size='10' maxlenght='10'
       value='".$programa."' readonly> 
      </td>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' name='cod_cliente_c' size='10' maxlenght='10'
       value='".$cod_cliente."' readonly> 
      </td>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='A' name='prog_c' size='1' maxlenght='1' readonly> 
      </td>
     </tr> 
     <tr>     
      <td width='150'  style=$n_style colspan='15'      align='right'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='cod_cliente'  value='".$cod_cliente."' size='20' maxlenght='20'
       >  
      </td>
      <td width='80'  style=$n_style colspan='8'      align='center'>
       <input type='submit' name='Confirmar' value='Alterar '>
      </td>
     </FORM>");
  printf("<FORM METHOD='POST' ACTION='man0003_c.php'>");
  printf("
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' name='programa' size='10' maxlenght='10'
       value='".$programa."' readonly> 
      </td>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' name='cod_cliente_c' size='10' maxlenght='10'
       value='".$cod_cliente."' readonly> 
      </td>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='E' name='prog_c' size='1' maxlenght='1' readonly> 
      </td>
      <td width='80'  style=$n_style colspan='8'      align='center'>
       <input type='submit' name='Confirmar' value='Excluir '>
      </td>
     </tr> 
     </FORM>");

  $mat_tables=$cfetch_row($result_tables);
 }
 printf("</html>");
?>






