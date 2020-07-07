<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manutenção:    
 //Data manutenção:04/10/2005
 //Módulo:         SUP
 //Processo:       Notas Fiscais de Entrada
 //Versão:         1.0
 $prog="sup/sup0003";
 $versao=1;
 //-----------------------------------------------------------------------------

 include("../../bibliotecas/inicio.inc");
 include("../../bibliotecas/usuario.inc");
 if($nome_<>"")
 {
  include("../../bibliotecas/style.inc");
  printf("<tr> <FORM METHOD='POST' ACTION='sup0003_a.php'></tr>");
  include("../../bibliotecas/empresa.inc");
  include("../../bibliotecas/autentica.inc");
  printf("</tr> 
      </tr>");
  include("../../bibliotecas/data_ini.inc");
  include("../../bibliotecas/data_fin.inc");

     printf("<tr>
        <td width='750' colspan='75' style=$n_style      align='left'>
         <input type='checkbox' name='comp' value='S' >
         Inclui Notas de Compras
        </td></tr><tr>
        <td width='750' colspan='75' style=$n_style      align='left'>
         <input type='checkbox' name='frete' value='S' >
         Inclui Fretes
        </td></tr><tr>
        <td width='750' colspan='75' style=$n_style      align='left'>
         <input type='checkbox' name='cons' value='S' >
         Inclui Notas de Consertos
        </td></tr><tr>
        <td width='750' colspan='75' style=$n_style      align='left'>
         <input type='checkbox' name='dev' value='S' >
         Inclui Notas de Devoluções
        </td>");

  printf("</tr> 
      </tr>
       <tr>
        <td width='50'  colspan='5' style=$n_style      align='center'>
         <input type='submit' name='Confirmar' value='Emitir Relatório'>
        </td>
        <td width='50'  colspan='5' style=$n_style     align='center'>
         <input type='reset' name='Cancelar' value='Limpar Campos'>
        </td>
       </tr>
       <tr>
        <td width='0'  style=$n_style colspan='1'     align='left'>
         <input type='hidden' value='C' name='prog_c' size='1' maxlenght='1' readonly> 
        </td>
      </tr>
      </FORM>");
 }else{
  fechar();
  include("../../bibliotecas/negado.inc");
 }
 printf("</html>");
?>

 