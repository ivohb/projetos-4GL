<?PHP
 //-----------------------------------------------------------------------------
 //Desenvolvedor: Henrique Antonio Conte
 //Manutenção:    
 //Data manutenção:04/10/2005
 //Módulo:         FAME
 //Processo:       ARQUIVO PARA SEGURO DE CARGAS
 //Versão:         1.0
 $prog="fame/fam0011";
 $versao=1;
 //-----------------------------------------------------------------------------

 include("../../bibliotecas/inicio.inc");
 include("../../bibliotecas/usuario.inc");
 if($nome_<>"")
 {
  include("../../bibliotecas/style.inc");
  printf("<tr> <FORM METHOD='POST' ACTION='fam0011_a.php'></tr>");
  include("../../bibliotecas/empresa.inc");
  include("../../bibliotecas/autentica.inc");
  printf("</tr> 
      </tr>");
  include("../../bibliotecas/data_ini.inc");
  include("../../bibliotecas/data_fin.inc");

  printf("</tr> 
      </tr>
       <tr>
        <td width='50'  colspan='5' style=$n_style      align='center'>
         <input type='submit' name='Confirmar' value='Gerar Arquivo'>
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
