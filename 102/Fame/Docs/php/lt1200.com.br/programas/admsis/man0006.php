<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manutenção:    
 //Data manutenção:21/06/2005
 //Módulo:         ADMSIS
 //Processo:       Manutenção de Paramentros de Clientes
 //Versão:         1.0
 $prog="admsis/man0006";
 //-----------------------------------------------------------------------------

 include("../../bibliotecas/inicio.inc");
 include("../../bibliotecas/usuario.inc");
 if($nome_<>"")
 {
  include("../../bibliotecas/style.inc");
  printf("<tr> <FORM METHOD='POST' ACTION='man0006.php'></tr>");
  include("../../bibliotecas/autentica.inc");
  $selec_tables="select *
           from lt1200_par_cliente
	where	programa='".$programa."'
        order by base,tabela
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
   $cons_faz="delete from  lt1200_par_cliente 
	    where cod_cliente='".$cod_cliente_c."'
              ";

   $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_faz = $cquery($cons_faz,$res_faz);
   $prog_c="N";
  }
  if($fazer=='I')
  {
   $cons_faz="insert into  lt1200_par_cliente (
 	  cod_cliente,nom_cliente,tipo_sgdb)
        values ('".$cod_cliente ."','".$nom_cliente."','".$tipo_sgdb."')";
   $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_faz = $cquery($cons_faz,$res_faz);
   $prog_c="N";
  }
  if($fazer=='A')
  {
   $cons_faz="update  lt1200_par_cliente set
                         cod_cliente='".$cod_cliente."',
                         nom_cliente='".$nom_cliente."'
                         tipo_sgdb='".$tipo_sgdb."'
                     where cod_cliente='".$cod_cliente_c."' ";
   $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_faz = $cquery($cons_faz,$res_faz);
   $prog_c="N";
  }
  $selec_tables="select  * 
        from lt1200_par_cliente a
        order by nom_cliente
 	";
  $res_tables = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result_tables = $cquery($selec_tables,$res_tables);
  $mat_tables=$cfetch_row($result_tables);
  printf("<tr>     
      <td width='750'  style=$n_style colspan='75'     align='center'>
       <b><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       CLIENTES LOGOCENTER</font></b>
      </td>
     </tr>
     <tr>     
      <td width='50'  style=$n_style colspan='5'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Código</font></b>
      </td>
      <td width='250'  style=$n_style colspan='25'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Nome</font></b>
      </td>
      <td width='250'  style=$n_style colspan=25      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Banco(IFX,ORA,SQL,DB2)</font></b>
      </td>
     </tr>
     ");
  printf("<FORM METHOD='POST' ACTION='man0006.php'>");
  printf("</tr>
      <tr>
      <td width='10'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='I' name='prog_c' size='1' maxlenght='1' readonly> 
      </td>
     </tr> 
     <tr>     
      <td width='50'  style=$n_style colspan='5'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='cod_cliente'  size='10' maxlenght='10'
       >  
      <td width='250'  style=$n_style colspan='25'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='nom_cliente'  size='40' maxlenght='40'
       >  
      <td width='10'  style=$n_style colspan='1'      align='right'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='tipo_sgdb'  size='3' maxlenght='3'
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
   $nom_cliente=$mat_tables["nom_cliente"];
   $tipo_sgdb=$mat_tables["tipo_sgdb"];
   printf("<FORM METHOD='POST' ACTION='man0006.php'>");
   printf("<tr>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' name='cod_cliente_c' size='10' maxlenght='10'
       value='".$cod_cliente."' readonly> 
      </td>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' name='nom_cliente_c' size='40' maxlenght='40'
       value='".$cod_cliente."' readonly> 
      </td>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' name='tipo_sgdb_c' size='3' maxlenght='3'
       value='".$tipo_sgdb."' readonly> 
      </td>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='A' name='prog_c' size='1' maxlenght='1' readonly> 
      </td>
     </tr> 
     <tr>     
      <td width='50'  style=$n_style colspan='5'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='cod_cliente'  value='".$cod_cliente."' size='10' maxlenght='10'
       >  
      <td width='250'  style=$n_style colspan='25'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='nom_cliente' value='".$nom_cliente."' size='40' maxlenght='40'
       >  
      <td width='10'  style=$n_style   align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='tipo_sgdb' value='".$tipo_sgdb."' size='3' maxlenght='3'
       >  
      </td>
      <td width='10'  style=$n_style colspan='1'      align='center'>
       <input type='submit' name='Confirmar' value='Alterar '>
      </td>
     </FORM>");
   printf("<FORM METHOD='POST' ACTION='man0006.php'>");
   printf("
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' name='cod_cliente_c' size='10' maxlenght='10'
       value='".$cod_cliente."' readonly> 
      </td>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' name='nom_cliente_c' size='40' maxlenght='40'
       value='".$cod_cliente."' readonly> 
      </td>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' name='tipo_sgdb_c' size='3' maxlenght='3'
       value='".$tipo_sgdb."' readonly> 
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
 }else{
  fechar();
  include("../../bibliotecas/negado.inc");
 }
 printf("</html>");
?>






