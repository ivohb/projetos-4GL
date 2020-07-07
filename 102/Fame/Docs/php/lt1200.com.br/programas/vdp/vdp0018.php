<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manutenção:    
 //Data manutenção:26/03/2010
 //Módulo:         VDP
 //Processo:       Emissao Folha Pagamento Representante/Autônomo
 //Versão:         1.0
 $prog="vdp/vdp0018";
 $versao="1";
 //-----------------------------------------------------------------------------

 include("../../bibliotecas/inicio.inc");
 include("../../bibliotecas/usuario.inc");
 if($nome_<>"")
 {
  include("../../bibliotecas/style.inc");
  printf("<tr> <FORM METHOD='POST' ACTION='vdp0018_a.php'></tr>");
  include("../../bibliotecas/empresa.inc");
     printf("<td width='20'  style=$n_style colspan='2'      align='left'>
       <b><font face='Arial, Helvetica, sans-serif' size='2' color=$c_color>
       Tipo:</font></b>
     </td>
     <td width='50'  style=$n_style colspan='5'     align='left'>
      <select name='tipo'>");
      printf("<option value='R' selected>Representante</option>");
      printf("<option value='A'>Autonomo</option>");
      printf("</select>
     </td></tr><tr>" );

  include("../../bibliotecas/mes_ref.inc");
  include("../../bibliotecas/ano_ref.inc");
  include("../../bibliotecas/autentica.inc");
  include("../../bibliotecas/opentable.inc");
  printf("</tr> 
        </tr>
        <tr>
         <td width='50'  colspan='5' style=$n_style      align='center'>
         &nbsp;
        </td>
        <td width='50'  colspan='5' style=$n_style     align='center'>
         &nbsp;
        </td>
       </tr>
        <tr>
         <td width='50'  colspan='5' style=$n_style      align='center'>
         <input type='submit' name='Confirmar' value='Emitir Relatorio'>
        </td>
        <td width='50'  colspan='5' style=$n_style     align='center'>
         &nbsp;
        </td>
       </tr>
      </FORM>");
 }else{
  fechar();
  include("../../bibliotecas/negado.inc");
 }
 printf("</html>");
?>
