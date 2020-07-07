<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manutenção:    
 //Data manutenção:21/06/2005
 //Módulo:         VDP
 //Processo:       Emissao Relatório RPR/RPA
 //Versão:         1.0
 $prog="vdp/vdp0016";
 $versao="1";
 //-----------------------------------------------------------------------------

 include("../../bibliotecas/inicio.inc");
 include("../../bibliotecas/usuario.inc");
 if($nome_<>"")
 {
  include("../../bibliotecas/style.inc");
  printf("<tr> <FORM METHOD='POST' ACTION='vdp0016_a.php'></tr>");
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
         <input type='submit' name='Confirmar' value='Emitir Relatorio'>
        </td>
        <td width='50'  colspan='5' style=$n_style     align='center'>
         <input type='reset' name='Cancelar' value='Limpar Campos'>
        </td>
       </tr>
      </FORM>");
 }else{
  fechar();
  include("../../bibliotecas/negado.inc");
 }
 printf("</html>");
?>
