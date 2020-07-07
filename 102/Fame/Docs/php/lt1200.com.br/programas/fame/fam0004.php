<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manutenção:    
 //Data manutenção:22/08/2005
 //Módulo:         Fame
 //Processo:       Cadastro de Motoristas
 //Versão:         1.0
 $versao=1;
 $prog="fame/fam0004";
 //-----------------------------------------------------------------------------

 include("../../bibliotecas/inicio.inc");
 include("../../bibliotecas/usuario.inc");
 if($nome_<>"")
 {
  include("../../bibliotecas/style.inc");
  printf("<tr> <FORM METHOD='POST' ACTION='fam0004.php'></tr>");
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
   $cons_faz="delete from  lt1200_motoristas 
            where cpf_moto='".$cpf_moto_c."'
              ";

   $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_faz = $cquery($cons_faz,$res_faz);
   $prog_c="N";
  }
  if($fazer=='I')
  {
   $cons_faz="insert into  lt1200_motoristas (
          cpf_moto,nome_moto,rg_moto,fone_moto)
        values ('".$cpf_moto."','".$nome_moto."','".$rg_moto."','".$fone_moto."')";
   $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_faz = $cquery($cons_faz,$res_faz);
   $prog_c="N";
  }
  if($fazer=='A')
  {
   $cons_faz="update  lt1200_motoristas set
                        nome_moto='".$nome_moto."',
                        rg_moto='".$rg_moto."',
                        fone_moto='".$fone_moto."'
                     where cpf_moto='".$cpf_moto_c."' ";
   $res_faz = $cconnect("lt1200",$ifx_user,$ifx_senha);
   $result_faz = $cquery($cons_faz,$res_faz);
   $prog_c="N";
  }


  $selec_caminhoes="select  *
                        from lt1200_motoristas a
                       order by nome_moto
                   ";
  $res_caminhoes = $cconnect("lt1200",$ifx_user,$ifx_senha);
  $result_caminhoes = $cquery($selec_caminhoes,$res_caminhoes);
  $mat_caminhoes=$cfetch_row($result_caminhoes);

  printf("<tr>
      <td width='750'  style=$n_style colspan='75'     align='center'>
       <b><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       Cadastro de Motoristas</font></b>
      </td>
     </tr>
     <tr>
      <td width='40'  style=$n_style colspan='4'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       CPF</font></b>
      </td>
      <td width='80'  style=$n_style colspan='8'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Nome</font></b>
      </td>
      <td width='40'  style=$n_style colspan='4'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       R.G.</font></b>
      </td>
      <td width='40'  style=$n_style colspan='4'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Fone</font></b>
      </td>
     </tr>
     ");

  printf("<FORM METHOD='POST' ACTION='fam0004.php'>");
  printf("</tr>
      <tr>
      <td width='10'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='I' name='prog_c' size='1' maxlenght='1' readonly> 
      </td>
     </tr> 
     <tr>     
      <td width='40'  style=$n_style colspan='4'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='cpf_moto'  size='15' maxlenght='15'>  
      </td>
      <td width='80'  style=$n_style colspan='8'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='nome_moto'  size='40' maxlenght='60'>  
      </td>
      <td width='40'  style=$n_style colspan='4'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='rg_moto'  size='15' maxlenght='15'>  
      </td>
      <td width='40'  style=$n_style colspan='4'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='fone_moto'  size='15' maxlenght='15'>  
      </td>
      <td width='80'  style=$n_style colspan='8'      align='center'>
       <input type='submit' name='Confirmar' value='Incluir '>
      </td>
     </tr> 
     </FORM>");

  while (is_array($mat_caminhoes))
  {
   printf("<FORM METHOD='POST' ACTION='fam0004.php'>");
   printf("<tr>

      <td width='40'  style=$n_style colspan='4'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='cpf_moto' value='".$mat_caminhoes["cpf_moto"]."'
        readonly size='15' maxlenght='15'>
      </td>
      <td width='80'  style=$n_style colspan='8'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='nome_moto' value='".$mat_caminhoes["nome_moto"]."'
       size='40' maxlenght='60'>
      </td>
      <td width='40'  style=$n_style colspan='4'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='rg_moto' value='".$mat_caminhoes["rg_moto"]."'
       size='15' maxlenght='15'>
      </td>
      <td width='40'  style=$n_style colspan='4'      align='left'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='fone_moto' value='".$mat_caminhoes["fone_moto"]."'
       size='15' maxlenght='15'>
      </td>

      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' name='cpf_moto_c' size='10' maxlenght='10'
       value='".$mat_caminhoes["cpf_moto"]."' readonly> 
      </td>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='A' name='prog_c' size='1' maxlenght='1' readonly> 
      </td>
     <td width='10'  style=$n_style colspan='1'      align='center'>
       <input type='submit' name='Confirmar' value='Alterar '>
      </td>
     </FORM>");

   printf("<FORM METHOD='POST' ACTION='fam0004.php'>");
   printf("
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' name='cpf_moto_c' size='10' maxlenght='10'
       value='".$mat_caminhoes["cpf_moto"]."' readonly> 
      </td>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='E' name='prog_c' size='1' maxlenght='1' readonly> 
      </td>
      <td width='80'  style=$n_style colspan='8'      align='center'>
       <input type='submit' name='Confirmar' value='Excluir '>
      </td>
     </tr> 
     </FORM>");
   $mat_caminhoes=$cfetch_row($result_caminhoes);
  }
 }else{
  fechar();
  include("../../bibliotecas/negado.inc");
 }
 printf("</html>");
?>






