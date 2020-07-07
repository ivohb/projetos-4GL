<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manutenção:    
 //Data manutenção:14/07/2005
 //Módulo:         FAM
 //Processo:       MANUTENÇÃO DE INFORMAÇOES COMPLEMENTARES
 //Versão:         1.0
 $prog="fame/fam0002";
 $versao='1.0';
 //-----------------------------------------------------------------------------

 include("../../bibliotecas/inicio.inc");
 include("../../bibliotecas/usuario.inc");
 if($nome_<>"")
 {
  include("../../bibliotecas/style.inc");
  include("../../bibliotecas/autentica.inc");
  $nom_=strtoupper($nom_);
  $nom_=chop($nom_);
  if($nom_<>"")
  {
   $cforn="select a.cod_fornecedor,a.raz_social
             from fornecedor a
             where raz_social like '%".$nom_."%'
             order by a.raz_social";
   $res = $cconnect("logix",$ifx_user,$ifx_senha);
   $result = $cquery($cforn,$res);
   $mat=$cfetch_row($result);
  }else{
   $cforn="select a.cod_fornecedor,a.raz_social
             from fornecedor a
             where a.cod_fornecedor='".$cgc_."'
             order by a.raz_social            ";
   $res = $cconnect("logix",$ifx_user,$ifx_senha);
   $result = $cquery($cforn,$res);
   $mat=$cfetch_row($result);
  }
  printf("</tr><tr><td width='40'  style=$n_style colspan='4'     align='right'>
          <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
          CODIGO</font></i>
          </td>
          <td width='150'  style=$n_style colspan='15'     align='right'>
          <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
          Razao Social/Nome FORNECEDOR</font></i>
          </td>
          <td width='30'  style=$n_style colspan='3'     align='right'>
          <i><font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
          CODIGO ITEM</font></i>
          </td></tr>");


  while (is_array($mat))
  {
   $cod_fornecedor=$mat["cod_fornecedor"];
   $raz_social=$mat["raz_social"];
   printf("<tr> <FORM METHOD='POST' ACTION='fam0002_b.php' target=_blank ></tr>");
   printf("<tr>
      <td width='40'  style=$n_style colspan='4'     align='left'>
       <input type='text' name='cod_fornecedor' size='15' maxlenght='15'
       value='".$cod_fornecedor."' readonly> 
      </td>
      <td width='150'  style=$n_style colspan='15'      align='right'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='raz_social' value='".$raz_social."' 
       readonly size='50' maxlenght='50'
       >  
      <td width='30'  style=$n_style colspan='3'      align='right'>
       <font face='Arial, Helvetica, sans-serif' size='3' color=$c_color>
       <input type='text' name='cod_item'  size='20' maxlenght='20'   >  
      </td>
      <td width='0'  style=$n_style colspan='1'     align='left'>
       <input type='hidden' value='N' name='prog_c' size='1' maxlenght='1' readonly> 
      </td>
      <td width='80'  style=$n_style colspan='8'      align='center'>
       <input type='submit' name='Confirmar' value='Avança'> </td>
     </tr> 
     </FORM>");
   printf("</form>");
   $mat=$cfetch_row($result);
  }
 }else{
  fechar();
  include("../../bibliotecas/negado.inc");
 }
 printf("</html>");
?>
