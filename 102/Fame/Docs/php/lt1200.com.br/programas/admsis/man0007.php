<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manutenção:    
 //Data manutenção:21/06/2005
 //Módulo:         ADMSIS
 //Processo:       Manutenção de Cadastro de Tabelas do Sistema LT1200
 //Versão:         1.0
 $prog="admsis/man0007";
 //-----------------------------------------------------------------------------

 include("../../bibliotecas/inicio.inc");
 include("../../bibliotecas/usuario.inc");
 if($nome_<>"")
 {
  include("../../bibliotecas/style.inc");
  printf("<tr> <FORM METHOD='POST' ACTION='man0007.php'></tr>");
  include("../../bibliotecas/autentica.inc");
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
   $cons_faz="delete from  lt1200_tabelas 
	    where tabela='".$tabela_c."'
              ";

   $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_faz = $cquery($cons_faz,$res_faz);
   $prog_c="N";
  }
  if($fazer=='I')
  {
   $cons_faz="insert into  lt1200_tabelas (
 	  tabela,utilizacao)
        values ('".$tabela ."','".$utilizacao."')";
   $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_faz = $cquery($cons_faz,$res_faz);
   $prog_c="N";
  }
  if($fazer=='A')
  {
   $cons_faz="update  lt1200_tabelas set
                         tabela='".$tabela."',
                         utilizacao='".$utilizacao."'
                     where tabela='".$tabela_c."' ";
   $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_faz = $cquery($cons_faz,$res_faz);
   $prog_c="N";
  }
  $selec_tables="select  * 
        from lt1200_tabelas 
        order by tabela
 	";
  $res_tables = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result_tables = $cquery($selec_tables,$res_tables);
  $mat_tables=$cfetch_row($result_tables);
  printf("<tr>     
      <td width='750'  style=$n_style colspan='75'     align='center'>
       <b><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       Tabelas LT1200</font></b>
      </td>
     </tr>
     <tr>     
      <td width='50'  style=$n_style colspan='5'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Tabela</font></b>
      </td>
      <td width='250'  style=$n_style colspan='25'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Utilizaçao</font></b>
      </td>
     </tr>
     ");
  printf("<FORM METHOD='POST' ACTION='man0007.php'>");
  printf("</tr>
      <tr>
      <td width='10'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='I' name='prog_c' size='1' maxlenght='1' readonly> 
      </td>
     </tr> 
     <tr>     
      <td width='50'  style=$n_style colspan='5'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='tabela'  size='20' maxlenght='40'
       >  
      <td width='250'  style=$n_style colspan='25'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='utilizacao'  size='60' maxlenght='200'
       >  
      </td>
      <td width='80'  style=$n_style colspan='8'      align='center'>
       <input type='submit' name='Confirmar' value='Incluir '>
      </td>
     </tr> 
     </FORM>");

  while (is_array($mat_tables))
  {
   $tabela=$mat_tables["tabela"];
   $utilizacao=$mat_tables["utilizacao"];
   printf("<FORM METHOD='POST' ACTION='man0007.php'>");
   printf("<tr>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' name='tabela_c' size='40' maxlenght='40'
       value='".$tabela."' readonly> 
      </td>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' name='utilizacao_c' size='60' maxlenght='200'
       value='".$utilizacao."' readonly> 
      </td>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='A' name='prog_c' size='1' maxlenght='1' readonly> 
      </td>
     </tr> 
     <tr>     
      <td width='50'  style=$n_style colspan='5'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='tabela'  value='".$tabela."' size='20' maxlenght='40'
       >  
      <td width='250'  style=$n_style colspan='25'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='utilizacao' value='".$utilizacao."' size='60' maxlenght='200'
       >  
      </td>
      <td width='10'  style=$n_style colspan='1'      align='center'>
       <input type='submit' name='Confirmar' value='Alterar '>
      </td>
     </FORM>");
   printf("<FORM METHOD='POST' ACTION='man0007.php'>");
   printf("
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' name='tabela_c' size='10' maxlenght='40'
       value='".$tabela."' readonly> 
      </td>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' name='utilizacao_c' size='40' maxlenght='200'
       value='".$utilizacao."' readonly> 
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






