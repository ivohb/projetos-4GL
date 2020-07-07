unit uFuncoes;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, ComCtrls, DB, ADODB,
  Forms, Dialogs, Variants, Registry, QuickRpt, IdMessage, IdSMTP,
  IdComponent, IdTCPConnection, IdTCPClient, IdMessageClient,
  IdBaseComponent, IdAntiFreezeBase, IdAntiFreeze, ShellApi, StrUtils,ComObj,FileCtrl,cxGridDBTableView;

  function  complString(str:string;x:char;len:integer):string;
  function  complString2(str:string;x:char;len:integer):string;
  function  limpaString(str:string;x:char): string;
  function  leftAte(texto:string;x:char):string;
  function  empty(texto:string): boolean;
  function  testaCnpj(xCNPJ: String):Boolean;
  function  mes(i : integer) : string;
  function  ehInteiro( str: string) : boolean;
  function  CodString(cbo: TStrings; str: boolean; ch : char = '-'): string;
  function  RightDe(texto:string;caracter:string):string;
  function  DataExtenso(Data:TDateTime;Dia:Boolean = False): String;
  function  TabelaExiste(tabela:string; con:Boolean): Boolean;
  procedure Execute(comando:WideString);
  function  posVetor(var vetor : array of String; str : String) : integer;
  function  connInformixA( conectar : boolean ) : boolean;
  procedure InsereVetor(var v : array of String; str : string);
  function  nvl(x1, x2: Real) : Real;
  procedure MsgAguarde(mostra:boolean);
  function  LTrimChar(str : string; chr : char ) : string;
  function  GetBuildInfo: string;
  function  replace_string(tx, txOld, txNew : string) : string;
  procedure replaceTString(var str : TStrings; txOld, txNew : string);
  function  DescrCodLogix(tabela:string;cod:string;msg:boolean = False; cod_emp: string = ''):string;
  procedure setCodUsuario(str : string);
  function  CriptString(tipo:integer;texto:string):string;
  function  LetraNum(letra:string):string;
  function  NumLetra(Num:string):string;
  function  sequencia(campo,tabela: string; cond: string = '';informix : boolean = False ):integer ;
  function  parametro(par:string):string;
  function  VP(valor:string):string;
  function  Executa_Aguarda(const FileName, Params: string; const WindowState: Word): boolean;
  procedure FinalizaPlugin;
  procedure DEBUG_DISPLAY(TABLE, ERROR: String; X_ERR: Exception );
  procedure QReport_ImpPadrao(var quick: TQuickRep; nome_impressora: string);
  procedure SET_ISOLATION(var qry :TADOQuery);
  function  ColunaExiste(tabela,coluna :string): Boolean;
  procedure Excel(mescla1,mescla2, negrito, alinha, texto: string; size,cor,Borda: integer;var planilha:variant);
  function  FormataData(auxData : TDateTime; sFormato, nFormato: Variant) : String;
  Function  Convert_num_letra(Serial:String) : String;
  procedure CSQL(var oQry:TADOQuery;cSql:String);
  function  aspas(cValor:String):String;
	function  fData (vData : String) : String;
  function  fFloat(valor : String) : String;
  function  fReal (valor : String ; casas : integer) : String;
  procedure GeraExecel(qry: TADOQuery;grid:TcxGridDBTableView; Titulo: String; CorTitulo : Tcolor; LinhaInicial, ColunaInicial,TamanhoPadraoCelulas:Integer; SomenteGrid:Boolean);
  function  ValidaGrid(campo_query : String;var titulo_coluna:string;grid : TcxGridDBTableView):Boolean;
  function  iif(Valor: Boolean; Verdadeiro,  Falso: Variant): Variant;
  
implementation

uses uConexao, DateUtils, Printers;     

var
    cod_usuario,cod_empresa,den_reduz : string;   // den_reduz é a descrição reduzida

function iif(Valor: Boolean; Verdadeiro,
  Falso: Variant): Variant;
begin
//Se "Valor" Verdadeiro então Retorna "Verdadeiro" senão Retorna "Falso"
  if Valor then
    Result := Verdadeiro
  else
    Result := Falso;
end;    

//FUNÇÃO QUE ARREDONDA VALORES E 
function fReal (valor : string ; casas : integer) : string;

function Arredondar(x: Extended; d: Integer): Double;
const
  t: array [0..12] of int64 = (1, 10, 100, 1000, 10000, 100000,
    1000000, 10000000, 100000000, 1000000000, 10000000000,
    100000000000, 1000000000000);
begin

  if Abs(d) > 12 then
    raise ERangeError.Create('RoundN: Value must be in -12..12');
  if d = 0 then
    Result := Int(x) + Int(Frac(x) * 2)
  else if d > 0 then
    begin
      x := x * t[d];
      Result := (Int(x) + Int(Frac(x) * 2)) / t[d];
    end
  else
    begin  // d < 0
      x := x / t[-d];
      Result := (Int(x) + Int(Frac(x) * 2)) * t[-d];
    end;
end;

function busca_casas(casa:integer):string;
var i : integer;
    c : string ;
    z : string ;
begin
  c := '#,';
  z := '0.';

  for i := 1 to casa do
    begin
      c := c + '#'; 
      z := z + '0';
    end;
  result := c + z;
end;

begin
  Result := formatFloat(busca_casas(casas),Arredondar(
                                      strtofloat(
                                                 IfThen(valor <> '',StringReplace(valor,'.',',',[rfReplaceAll]),'0')
                                                )
                                      ,CASAS)  
                       );
end;

function fFloat(valor : string) : String;
begin
  Result := IfThen(valor <> '',StringReplace(valor,'.','',[rfReplaceAll]),'null');
  Result := IfThen(valor <> '',StringReplace(valor,',','.',[rfReplaceAll]),'null');
end;

function  aspas(cValor:String):String;
begin
  Result := QuotedStr(Trim(cValor));
end;

function ColunaExiste(tabela,coluna :string): Boolean;
begin
  if Base_Dados = 1 then
    begin
      dmConexao.qryGenInformix.Close;
      dmConexao.qryGenInformix.sql.text := 'select count(tabname) from systables tab  '+
                                           'inner join syscolumns col '                +
                                           '  on tab.tabid = col.tabid '               +
                                           'where tab.tabname = '+QuotedStr(Trim(LowerCase(tabela)))+
                                           '  and col.colname = '+QuotedStr(Trim(LowerCase(coluna)));
      dmConexao.qryGenInformix.Open;
      result := (dmConexao.qryGenInformix.Fields[0].AsInteger >= 1);
      dmConexao.qryGenInformix.Close;
    end;
end;

procedure SET_ISOLATION(var qry :TADOQuery);
var Sql : string;
begin
  Sql := qry.SQL.text;
 // qry.SQL.text := ' SET ISOLATION TO DIRTY READ ';
 // qry.ExecSQL;
  qry.SQL.text := Sql;
end;

procedure QReport_ImpPadrao(var quick: TQuickRep; nome_impressora: string);
var j: integer;
begin
  for j := 0 to Printer.Printers.Count - 1 do
    if Printer.Printers.Strings[j] = nome_impressora then
      Break;

  if j <> Printer.Printers.Count then
    quick.PrinterSettings.PrinterIndex := j;
end;

procedure FinalizaPlugin;
begin
  dmConexao.qryGenInformix.Close;
  dmConexao.qryGenInformix.SQL.Text := ' UPDATE pg_usuario SET ies_logado = ''N'' ' +
                                       ' WHERE cod_usuario = ' + QuotedStr(cod_usuario);
  dmConexao.qryGenInformix.ExecSQL;
  Application.Terminate;
end;


function VP(valor:string):string;
begin
  Result := StringReplace(valor,',','.',[rfReplaceAll]);

  if (Result = Null) or (Result = '') or (Length(TRIM(Result)) = 0) then
    Result := '0';
end;

function parametro(par:string):string;
begin

  // retorna um parametro do sistema
  dmConexao.qryGenInformix.Close;
  dmConexao.qryGenInformix.SQL.Clear;
  dmConexao.qryGenInformix.SQL.Add('SELECT val_parametro FROM sistema_par WHERE  nom_parametro = '''+par+'''');
  dmConexao.qryGenInformix.Open;

  if (dmConexao.qryGenInformix.IsEmpty) OR (Length(TRIM(dmConexao.qryGenInformix.Fields[0].AsString)) = 0) then
    begin
      ShowMessage('VALOR NÃO ENCONTRADO PARA O PARÂMETRO DE SISTEMA: ' + par);
      FinalizaPlugin;
    end
  else
    begin
      result := TRIM(dmConexao.qryGenInformix.Fields[0].AsString);
      dmConexao.qryGenInformix.Close;
    end;
end;

Function Convert_num_letra(Serial:String) : String;
var
  Letras :string;
  I, Digito, Codigo : Integer;
begin
  Digito := 0;
  Letras := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  Result := ''; //Nessa variável vai o resultado da função
  for i := 1 to Length(serial) do
    begin
      {Val testa se é numérico ou não}
      Val(copy(serial,I,1),Digito,Codigo);
      if codigo = 0 then //valor é numerico
        Result := Result + copy(serial,I,1)
      else //não é numerico
        begin
          digito := pos(copy(serial,i,1),Letras);
          if trim(result) <> '' then
            Result := Result+'|'+IntToStr(digito)
          else
            Result := IntToStr(digito);
        end
    end;
end;

function sequencia(campo,tabela: string; cond: string = '';informix : boolean = False ):integer ;
var qry :TADOQuery;
begin
  // retorna a próxima sequencia de campo em Tabela
  if informix then
    qry := dmConexao.qryGenInformix
  else
    qry := dmConexao.qryGenInformix;

  qry.Close;
  qry.SQL.clear;
  qry.SQL.add('SELECT max('+campo+')+1 as COD_FOUND FROM '+tabela+'');
  if not empty(cond) then
    qry.SQL.add('WHERE '+cond+'');
  qry.Open;

  result := qry.Fields[0].asInteger;
  if (result = 0) or (qry.RecordCount = 0) then
    begin
      result := 1;
    end;

  qry.Close;
end;

function NumLetra(Num:string):string;
begin
  Num := UpperCase(Num);

  if Num = '45' then
    result := 'A'
  else if Num = '63' then
    result := 'B'
  else if Num = '33' then
    result := 'C'
  else if Num = '98' then
    result := 'D'
  else if Num = '89' then
    result := 'E'
  else if Num = '06' then
    result := 'F'
  else if Num = '29' then
    result := 'G'
  else if Num = '47' then
    result := 'H'
  else if Num = '56' then
    result := 'I'
  else if Num = '41' then
    result := 'J'
  else if Num = '92' then
    result := 'K'
  else if Num = '01' then
    result := 'L'
  else if Num = '34' then
    result := 'M'
  else if Num = '65' then
    result := 'N'
  else if Num = '76' then
    result := 'O'
  else if Num = '30' then
    result := 'P'
  else if Num = '82' then
    result := 'Q'
  else if Num = '10' then
    result := 'R'
  else if Num = '02' then
    result := 'S'
  else if Num = '23' then
    result := 'T'
  else if Num = '87' then
    result := 'U'
  else if Num = '81' then
    result := 'V'
  else if Num = '90' then
    result := 'X'
  else if Num = '08' then
    result := 'Z'
  else if Num = '99' then
    result := '0'
  else if Num = '88' then
    result := '1'
  else if Num = '77' then
    result := '2'
  else if Num = '66' then
    result := '3'
  else if Num = '55' then
    result := '4'
  else if Num = '44' then
    result := '5'
  else if Num = '33' then
    result := '6'
  else if Num = '22' then
    result := '7'
  else if Num = '11' then
    result := '8'
  else if Num = '00' then
    result := '9';
end;

function GetBuildInfo: string;
var
   VerInfoSize: DWORD;
   VerInfo: Pointer;
   VerValueSize: DWORD;
   VerValue: PVSFixedFileInfo;
   Dummy: DWORD;
   V1, V2, V3, V4: Word;
   Prog, X4 : string;
begin
   Prog := Application.Exename;
   VerInfoSize := GetFileVersionInfoSize(PChar(prog), Dummy);
   GetMem(VerInfo, VerInfoSize);
   GetFileVersionInfo(PChar(prog), 0, VerInfoSize, VerInfo);
   VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);

   with VerValue^ do
   begin

     V1 := dwFileVersionMS shr 16;
     V2 := dwFileVersionMS and $FFFF;
     V3 := dwFileVersionLS shr 16;
     V4 := dwFileVersionLS and $FFFF;
  end;
  FreeMem(VerInfo, VerInfoSize);

  x4 := Copy (IntToStr (100 + v4), 2, 2);

  if Length(x4) < 2 then
    x4 := '0' + x4;

  result := Copy (IntToStr (100 + v1), 3, 2) + '.' +
  x4;
end;

function LetraNum(letra:string):string;
begin
  letra := UpperCase(letra);
  
  if letra = 'A' then
    result := '45'
  else if letra = 'B' then
    result := '63'
  else if letra = 'C' then
    result := '33'
  else if letra = 'D' then
    result := '98'
  else if letra = 'E' then
    result := '89'
  else if letra = 'F' then
    result := '06'
  else if letra = 'G' then
    result := '29'
  else if letra = 'H' then
    result := '47'
  else if letra = 'I' then
    result := '56'
  else if letra = 'J' then
    result := '41'
  else if letra = 'K' then
    result := '92'
  else if letra = 'L' then
    result := '01'
  else if letra = 'M' then
    result := '34'
  else if letra = 'N' then
    result := '65'
  else if letra = 'O' then
    result := '76'
  else if letra = 'P' then
    result := '30'
  else if letra = 'Q' then
    result := '82'
  else if letra = 'R' then
    result := '10'
  else if letra = 'S' then
    result := '02'
  else if letra = 'T' then
    result := '23'
  else if letra = 'U' then
    result := '87'
  else if letra = 'V' then
    result := '81'
  else if letra = 'X' then
    result := '90'
  else if letra = 'Z' then
    result := '08'
  else if letra = '0' then
    result := '99'
  else if letra = '1' then
    result := '88'
  else if letra = '2' then
    result := '77'
  else if letra = '3' then
    result := '66'
  else if letra = '4' then
    result := '55'
  else if letra = '5' then
    result := '44'
  else if letra = '6' then
    result := '33'
  else if letra = '7' then
    result := '22'
  else if letra = '8' then
    result := '11'
  else if letra = '9' then
    result := '00';
end;


// tabela de usuarios do plucuim pgusuario
// criptografia

function CriptString(tipo:integer;texto:string):string;
var
  i:integer;
  tmp:string;
begin
  if tipo = 0 then
    begin
      for i:=1 to Length(TRIM(texto)) do
        tmp := tmp + LetraNum(copy(texto,i,1));
    end
  else
    begin
      i:=1;
      while i<= Length(TRIM(texto)) do
        begin
          tmp := tmp + NumLetra(copy(texto,i,2));
          inc(i,2);
        end;
    end;

  Result := tmp;

end;

procedure setCodUsuario(str : string);
begin
  cod_usuario := str;
end;


function DescrCodLogix(tabela:string;cod:string;msg:boolean = False; cod_emp: string = ''):string;
var stmt : string;
begin
  result := '';
  if empty(cod) then exit;
  if Empty(cod_emp) then cod_emp := cod_empresa;
  if tabela = 'empresa' then
    stmt := 'SELECT den_empresa FROM empresa WHERE cod_empresa = '+QuotedStr(cod)
  else if tabela = 'familia' then
    stmt := 'SELECT den_familia FROM familia WHERE cod_empresa = '+QuotedStr(cod_emp)+' AND cod_familia = '+QuotedStr(cod)
  else if tabela = 'gru_ctr_desp' then
    stmt := 'SELECT den_gru_ctr_desp FROM grupo_ctr_desp WHERE cod_empresa = '+QuotedStr(cod_emp)+' AND gru_ctr_desp = '+cod
  else if tabela = 'comprador' then
    stmt := 'SELECT nom_comprador FROM comprador WHERE cod_empresa = '+QuotedStr(cod_emp)+' AND cod_comprador = '+cod
  else if tabela = 'programador' then
    stmt := 'SELECT nom_progr FROM programador WHERE cod_empresa = '+QuotedStr(cod_emp)+' AND cod_progr = '+cod
  else if tabela = 'tipo_despesa' then
    stmt := 'SELECT nom_tip_despesa FROM tipo_despesa WHERE cod_empresa = '+QuotedStr(cod_emp)+' AND cod_tip_despesa = '+cod
  else if tabela = 'cod_fiscal_sup' then
    stmt := 'SELECT den_cod_fiscal FROM cod_fiscal_sup WHERE cod_fiscal = '+QuotedStr(cod)
  else if tabela = 'conta_contabil' then
    stmt := 'SELECT den_conta FROM plano_contas WHERE cod_empresa = '+QuotedStr(cod_emp)+' AND num_conta = '+QuotedStr(cod)
  else if msg then
    begin
      Application.MessageBox('Tipo de pesquisa inválido!',PChar(Application.Title), MB_ICONEXCLAMATION);
      Result := '';
      exit;
    end;

  dmConexao.qryGenInformix.Close;
  dmConexao.qryGenInformix.SQL.Clear;
  dmConexao.qryGenInformix.SQL.Add(stmt);
  try
    dmConexao.qryGenInformix.Open;

    if dmConexao.qryGenInformix.IsEmpty and msg then
      begin
        Application.MessageBox('Código Inválido!',PChar(Application.Title), MB_ICONEXCLAMATION);
        result := ''
      end
    else
      result := dmConexao.qryGenInformix.Fields[0].AsString;

  except
    if msg then
      Application.MessageBox('Tipo de pesquisa inválido!',PChar(Application.Title), MB_ICONEXCLAMATION);
    Result := '';
  end;
  dmConexao.qryGenInformix.Close;
end;


procedure replaceTString(var str : TStrings; txOld, txNew : string);
var i : integer;
begin
//
  for i := 0 to str.Count-1 do
    replace_string(str.Strings[i],txOld,txNew);

end;

function replace_string(tx, txOld, txNew : string): string;
begin
  while (AnsiPos(txOld,tx) > 0) do
    tx := StringReplace(tx,txOld,txNew,[rfReplaceAll]);
  result := tx;
end;


function LTrimChar(str : string; chr : char ) : string;
var i:integer;
begin
  i := 1;  
  while Copy(str,i,1) = chr do
    inc(i);

  result := Trim( Copy(str,i,Length(str)) );
end;

procedure MsgAguarde(mostra:boolean);
var
  frmMsg : TForm;
  i:integer;
begin
  { if mostra then
   begin
      frmMsg := TfrmAguarde.Create(Application);
      frmMsg.WindowState := wsNormal;
      frmMsg.Show;
      Application.ProcessMessages;
   end
   else
   begin

      if frmMsg.Active then
      begin
         frmMsg.Close;
         frmMsg.Free;
      end;

      for i := 0 To Application.MainForm.MDIChildCount-1 do
      begin
         if Application.MainForm.MDIChildren[i].ClassName = 'TfrmAguarde' then
         begin
            Application.MainForm.MDIChildren[i].Close;
            Application.MainForm.MDIChildren[i].Free;
            break;
         end;
      end;
   end; }
end;

function nvl(x1, x2: Real) : Real;
begin
  if VarIsNull(x1) then
    result := x2
  else
    result := x1;
end;

function connInformixA( conectar : boolean ) : boolean;
begin
  if conectar then
    begin
      // Conecto com o informix
      if not FileExists(ExtractFilePath(Application.ExeName)+'conexao.udl') then
        begin
          Application.MessageBox('Arquivo de configuração (''conexao.udl'') não encontrado!',
                                 PChar(Application.Title), MB_ICONINFORMATION);
          result := false;
        end
      else
        begin
          if qtd_conn = 0 then
            begin
              dmConexao.connInformix.Close;
              dmConexao.connInformix.ConnectionString := Format('File Name=%s',[ExtractFilePath(Application.ExeName)+'conexao.udl']);
              dmConexao.connInformix.Open;
              dmConexao.connInformix.Execute('SET ISOLATION TO DIRTY READ');
            end;

          inc(qtd_conn);
          result := True;
        end;
    end
  else
    begin
      if qtd_conn > 0 then
        dec(qtd_conn);

      if qtd_conn = 0 then
        dmConexao.connInformix.Close;

      result := True;
    end;
  //frm
end;

function posVetor(var vetor : array of String; str : String) : integer;
var i : integer;
begin
  result := -1;

  for i := 0 to Length(vetor)-1 do
    begin
      if Trim(vetor[i]) = Trim(str) then
        begin
          result := i;
          break;
        end;
    end;
end;

function complString(str:string;x:char;len:integer):string;
begin
  // Completa a string com x:char ate ter len tamanho
  while Length(str) < len do
    str := str + x;
  result := str;
end;

function limpaString(str:string;x:char): string;
var i:integer;
begin
  // retira sa string todos os x:char a esquerda
  i := 1;
  while Copy(str,i,1) = x do
    inc(i);
  result := Trim( Copy(str,i,Length(str)) );
end;

function empty(texto:string): boolean;
begin
  // Verifica se a string esta preenchida
  result :=  ( Length(Trim(texto)) = 0 );
end;

function leftAte(texto:string;x:char):string;
begin
  // retorna o string qté o primeiro x:xhar
  Result := Trim( copy(texto,1, Pos(x,texto)-1 ) );
end;


function TestaCnpj(xCNPJ: String):Boolean;
var
  d1,d4,xx,nCount,fator,resto,digito1,digito2 : Integer;
   Check : String;
begin
  // verifica se o CNPJ é Válido
  d1 := 0;
  d4 := 0;
  xx := 1;
  for nCount := 1 to Length( xCNPJ )-2 do
    begin
      if Pos( Copy( xCNPJ, nCount, 1 ), '/-.' ) = 0 then
        begin
          if xx < 5 then
            begin
              fator := 6 - xx;
            end
          else
            begin
              fator := 14 - xx;
            end;
          d1 := d1 + StrToInt( Copy( xCNPJ, nCount, 1 ) ) * fator;
          if xx < 6 then
            begin
              fator := 7 - xx;
            end
          else
            begin
              fator := 15 - xx;    end;
              d4 := d4 + StrToInt( Copy( xCNPJ, nCount, 1 ) ) * fator;
              xx := xx+1;
            end;
        end;
  resto := (d1 mod 11);
  if resto < 2 then
    begin
      digito1 := 0;
    end
  else
    begin
      digito1 := 11 - resto;
    end;

  d4 := d4 + 2 * digito1;
  resto := (d4 mod 11);

  if resto < 2 then
    begin
      digito2 := 0;
    end
  else
    begin
      digito2 := 11 - resto;
    end;

  Check := IntToStr(Digito1) + IntToStr(Digito2);

  if Check <> copy(xCNPJ,succ(length(xCNPJ)-2),2) then
    begin
      Result := False;
    end
  else
    begin
      Result := True;
    end;
end;

function mes(i : integer) : string;
begin
  case i of
    1 : Result := 'Janeiro';
    2 : Result := 'Fevereiro';
    3 : Result := 'Março';
    4 : Result := 'Abril';
    5 : Result := 'Maio';
    6 : Result := 'Junho';
    7 : Result := 'Julho';
    8 : Result := 'Agosto';
    9 : Result := 'Setembro';
    10 : Result := 'Outubro';
    11 : Result := 'Novembro';
    12 : Result := 'Dezembro';
  else
    Result := ''
  end;
end;

function ehInteiro( str: string) : boolean;
var val : integer;
begin
  result := TryStrToInt(str,val);
end;

function CodString(cbo: TStrings; str: boolean; ch : char = '-'): string;
var i : integer;
begin
  if cbo.Count > 0 then
    begin
      if str then
        result := QuotedStr( leftAte( cbo.Strings[0],ch))
      else
        result := leftAte( cbo.Strings[0],ch);

      for i := 1 to cbo.Count-1 do
        begin
          if str then
            result := result + ',' + QuotedStr( leftAte( cbo.Strings[i],ch))
          else
            result := result + ',' + leftAte( cbo.Strings[i],ch)
        end;
    end
  else
    result := '';
end;

function RightDe(texto:string;caracter:string):string;
var
  i   : Integer;
  tmp : String;
  ok  : Boolean;
begin
  if empty(texto) then
    Result := ''
  else
    begin
      tmp    := '';
      result := '';
      ok     := False;
      i      := Length(texto);

      while copy(texto,i,1) <> caracter do
        begin
          tmp := tmp + copy(texto,i,1);
          i   := i-1;
        end;

      for i:= length(tmp) downto 1 do
        result := result + copy(tmp,i,1);
    end;
end;

function DataExtenso(Data:TDateTime;Dia:Boolean = False): String;
var
  NoDia : Integer;
//  Now: TdateTime;
  DiaDaSemana : array [1..7] of String;
  NDia, NMes, Ano : Word;
begin
  DiaDasemana [1]:= 'Domingo';
  DiaDasemana [2]:= 'Segunda-feira';
  DiaDasemana [3]:= 'Terça-feira';
  DiaDasemana [4]:= 'Quarta-feira';
  DiaDasemana [5]:= 'Quinta-feira';
  DiaDasemana [6]:= 'Sexta-feira';
  DiaDasemana [7]:= 'Sábado';
  DecodeDate (Data, Ano, NMes, NDia);
  NoDia := DayOfWeek (Data);

  if Dia then
    Result := DiaDaSemana [NoDia] + ', ' + inttostr (NDia) + ' de ' + Mes( NMes) + ' de ' + inttostr (Ano)
  else
    Result := inttostr (NDia) + ' de ' + Mes(NMes)+ ' de ' + inttostr (Ano)
end;

function TabelaExiste(tabela:string; con:Boolean): Boolean;
begin
    if Base_Dados <> 3 then
      begin
        dmConexao.qryGenInformix.Close;
        dmConexao.qryGenInformix.sql.Clear;
        dmConexao.qryGenInformix.sql.Add('SELECT count(*) FROM systables ');
        dmConexao.qryGenInformix.sql.Add(' WHERE tabname = '+QuotedStr(Trim(LowerCase(tabela))));
        dmConexao.qryGenInformix.Open;
        result := (dmConexao.qryGenInformix.Fields[0].AsInteger >= 1);
      end
    else
      begin
        //try

          dmConexao.qryGenInformix.Close;
          dmConexao.qryGenInformix.sql.Clear;
          dmConexao.qryGenInformix.sql.Text := ' SELECT count(*) FROM DBA_TABLES '
                                            +  ' WHERE UPPER(TABLE_NAME) = ' + aspas(UpperCase(tabela));
          dmConexao.qryGenInformix.Open;
          result := (dmConexao.qryGenInformix.Fields[0].AsInteger >= 1);
        //  result := True;
        //except
        //  result := False;
        //end;
      end;

    dmConexao.qryGenInformix.Close;
end;

procedure Excel(mescla1,mescla2, negrito, alinha, texto: string; size,cor,Borda: integer;var planilha:variant);
const
  xlChart = -4109; xlWorksheet = -4167;                               // SheetType
  xlWBATWorksheet = -4167; xlWBATChart = -4109;                       // WBATemplate
  xlPortrait = 1; xlLandscape = 2; xlPaperA4 = 9;                     // Page Setup
  xlBottom = -4107; xlLeft = -4131; xlRight = -4152; xlTop = -4160;   // Format Cells
  xlHAlignCenter = -4108; xlVAlignCenter = -4108;                     // Text Alignment
  xlThick = 4; xlThin = 2;                                            // Cell Borders
  var cor1 : integer;
begin
  ////////////////////////////////////////////////////////////
  //  CRIA O EXCEL                                          //
  //  DECLARE A VARIAVEL planilha:Variant;                  //
  //  planilha := CreateoleObject('Excel.Application');     //
  //  planilha.WorkBooks.add(1);                            //
  //  planilha.visible := False/True;                       //
  ////////////////////////////////////////////////////////////

//Mescla as células
  planilha.Range[mescla1,mescla2].Mergecells := True;

//Negrito(S/N)
  if UpperCase(trim(negrito)) = 'S' then
    planilha.Range[mescla1,mescla2].Font.Bold := True;

//Tamanho
  planilha.Range[mescla1,mescla2].Font.Size := size;

//ALINHAMENTO
  if uppercase(trim(alinha)) = 'ESQUERDA' then
     planilha.Range[mescla1,mescla2].HorizontalAlignment := xlLeft
  else if uppercase(trim(alinha)) = 'CENTRO' then
     planilha.Range[mescla1,mescla2].HorizontalAlignment := xlHAlignCenter
  else if uppercase(trim(alinha)) = 'DIREITA' then
     planilha.Range[mescla1,mescla2].HorizontalAlignment := xlRight;

//MESCLA E ADD O TEXTO NA CÉLULA

  planilha.Range[mescla1,mescla2].Cells.Value2 := TRIM(TEXTO);

  planilha.range[mescla1,mescla2].select;
  planilha.Selection.Interior.ColorIndex := cor1;

//DEFINE O TAMANHO DA BORDA
  planilha.Range[mescla1,mescla2].Borders.Weight := Borda;
end;

procedure Execute(comando:WideString);
begin
//  connInformix(True);
  dmConexao.connInformix.Execute(comando);
//  connInformix(False);
end;

Function Autentica_Numero(Serial:String) : String;
var
  Letras1,letras2:string;
  I,posde,num1,num2 : Integer;
  const
  numero : array[0..26] of String = ('','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z');
begin
  num1 := 0;
  num2 := 0;
  Result := ''; //Nessa variável vai o resultado da função

  if pos('|',serial) = 0 then
    begin
      num2 := strtoint(serial);
       if num2 > 25 then
        begin
          num1 := 1;
          num2 := 1;
        end
      else
        num2 := num2+1;
    end
  else
    begin
      posde  := pos('|',serial);
      if posde = 0 then
        posde := length(serial);
      num1 := strtoint(copy(serial,1,posde-1));
      if Length(serial) > 1 then
        begin
          posde := pos('|',serial);
          num2 := strtoint(copy(serial,posde+1,length(serial)));
        end;
      if num2 > 25 then
        begin
          num2 := 1;
          num1 := num1+1;
        end
      else
        num2 := num2+1;
    end;
      letras1 := numero[num1];
      letras2 := numero[num2];
      result := letras1 + letras2;
end;

procedure InsereVetor(var v : array of String; str : string);
var i : integer;
begin
  i := 0;
  while i <= Length(v)-1  do
    begin
      if empty(v[i]) or (v[i] = str) then
        break
      else
        inc(i);
    end;

  if i <> Length(v) then
    if empty(v[i]) then
      v[i] := str;
end;

function Executa_Aguarda(const FileName, Params: string; const WindowState: Word): boolean;
var
  SUInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
  CmdLine: string;
begin
  { Coloca o nome do arquivo entre aspas. Isto é necessário devido aos espaços contidos em nomes longos }
  CmdLine := '"' + Filename + '"' + Params;
  FillChar(SUInfo, SizeOf(SUInfo), #0);

  with SUInfo do
    begin
      cb := SizeOf(SUInfo);
      dwFlags := STARTF_USESHOWWINDOW;
      wShowWindow := WindowState;
    end;

  Result := CreateProcess(nil, PChar(CmdLine), nil, nil, false,
  CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil,
  PChar(ExtractFilePath(Filename)), SUInfo, ProcInfo);

  { Aguarda até ser finalizado }
  if Result then
    begin
      WaitForSingleObject(ProcInfo.hProcess, INFINITE);
      { Libera os Handles }
      CloseHandle(ProcInfo.hProcess);
      CloseHandle(ProcInfo.hThread);
    end;
end;

function complString2(str:string;x:char;len:integer):string;
begin
  // Completa a string com x:char ate ter len tamanho pela esquerda
  str := trim(str);
  while Length(str) < len do
    str := x + str;
  result := str;
end;

procedure DEBUG_DISPLAY(TABLE, ERROR: String; X_ERR: Exception );
begin
  MESSAGEBOX(0,PCHAR('TABELA: ' + TABLE + #13 + 'ERRO: ' + ERROR + #13 + X_ERR.Message ) ,PCHAR(TABLE),MB_OK + MB_ICONERROR);
  ABORT;
end;

function FormataData(auxData: TDateTime; sFormato, nFormato: Variant): String;
//****** Retorna uma data em string formatada ******************************
// auxData - Data a ser formatada
// sFormato - formato desejado como String (ex. 'dd/mm/yyyy','yyyy-mm-dd')
// nFormato - formato desejado como numerico abaixo
// 1 - dd.mm.yyyy    2-yyyy-mm-dd     3 - dd/mm/yyyy     4 - ddmmyyyy
// 5- yyyymmdd       6-dd/mm/yy       7 - mm-dd-yyyy
//************************************************************************
var
  Dia,
  Mes,
  Ano : Word;
  navaData : String;
begin
  //  obtem o dia mes ano
  DecodeDate(auxData,Ano,Mes,Dia);

  if Length(sFormato) > 0 then
    nFormato:= AnsiIndexStr( VarToStr(sFormato), ['dd.mm.yyyy','yyyy-mm-dd','yyyy/mm/dd','dd/mm/yyyy','ddmmyyyy','yyyymmdd','dd/mm/yy','mm-dd-yyyy']);


  // formata de acordo com a opcao selecionada
  if Length(nFormato) > 0 then
     begin

        case nFormato of
           1: navaData := complString2(IntToStr(Dia), '0', 2)+'.'+complString2(IntToStr(Mes),'0',2)+'.'+complString2(IntToStr(Ano),'0',4); //dd.mm.yyyy
           2: navaData := complString2(IntToStr(Ano),'0',4)+'-'+complString2(IntToStr(Mes),'0',2)+'-'+complString2(IntToStr(Dia),'0',2);   //yyyy-mm-dd
           3: navaData := complString2(IntToStr(Dia),'0',2)+'/'+complString2(IntToStr(Mes),'0',2)+'/'+complString2(IntToStr(Ano),'0',4);   //dd/mm/yyyy
           4: navaData := complString2(IntToStr(Dia),'0',2)+complString2(IntToStr(Mes),'0',2)+complString2(IntToStr(Ano),'0',4);           //ddmmyyyy
           5: navaData := complString2(IntToStr(Ano),'0',4)+complString2(IntToStr(Mes),'0',2)+complString2(IntToStr(Dia),'0',2);           //yyyymmdd
           6: navaData := complString2(IntToStr(Dia),'0',2)+'/'+complString2(IntToStr(Mes),'0',2)+'/'+copy( IntToStr(Ano),3,2);  //dd/mm/yy
           7: navaData := complString2(IntToStr(Mes),'0',2)+'-'+complString2(IntToStr(Dia),'0',2)+'-'+copy( IntToStr(Ano),0,4);  //mm-dd-yyyy
           else
              navaData := DateToStr(auxData);
        end;
     end;

  // retorna a data formatada
  Result := navaData
end;


procedure CSQL(var oQry:TADOQuery;cSql:String);
begin
  oQry.Close;
  oQry.SQL.Text := dmConexao.ConverteSQL(cSql,Base_Dados);
  oQry.Open;
  oQry.First;
end;

function fData(vData : String) : String;
begin
  if Trim(vData) = aspas('') then
    vData := aspas('01/01/1900');

  case Base_Dados of
    1 :	Result := ' CAST(' + vData + ' AS DATE ) ';
    2 :	Result := ' CONVERT( DATETIME , ' + vData + ', 103) ';
    3 :	Result := ' TO_DATE (' + vData + ') ';
  end;
end;

procedure GeraExecel(qry: TADOQuery;grid:TcxGridDBTableView; Titulo: String; CorTitulo : Tcolor; LinhaInicial, ColunaInicial,TamanhoPadraoCelulas:Integer; SomenteGrid:Boolean);
Var
planilha,Excel : Variant;
Linha ,i ,coluna: integer;
titulo_coluna,cCaminho ,cTitulo:String;
listaTamanhos : Array of array of integer;
begin
  // Informa no uses do Form a unit ComObj
  try
    cTitulo := 'Planilha';
    Excel:= CreateoleObject('Excel.Application');
    Excel.WorkBooks.add(1);

    Excel.Workbooks[1].Sheets.Add;
    Excel.Workbooks[1].WorkSheets[1].Name := cTitulo;
    planilha :=  Excel.Workbooks[1].WorkSheets[cTitulo];

   // planilha.caption := Titulo;
    coluna:= ColunaInicial;
    linha := LinhaInicial;

    SetLength(listaTamanhos,qry.FieldCount,2);

    for  i:= 0 to qry.Fields.Count - 1 do
      begin
        if (ValidaGrid(qry.Fields.Fields[i].FieldName,titulo_coluna,grid)) or (SomenteGrid = false) then
          begin
            planilha.cells[linha,coluna] := titulo_coluna;
            listaTamanhos[i][1] := length(trim(titulo_coluna));
            planilha.cells[linha,coluna].interior.color := clwhite;
            planilha.cells[linha,coluna].Borders.Weight := 2;
            inc(coluna);
          end;
      end;

    qry.First;

    while not qry.eof do
      begin
        inc(linha);
        coluna := ColunaInicial;
        for i := 0 to qry.Fields.Count - 1 do
          begin
            if (ValidaGrid(qry.Fields.Fields[i].FieldName,titulo_coluna,grid)) or (SomenteGrid = false) then
              begin
                if (qry.Fields.Fields[i].DataType = ftInteger ) then
                  begin
                    planilha.cells[linha,coluna].numberformat := '0';
                    planilha.cells[linha,coluna] := qry.Fields.Fields[i].AsInteger;
                  end
                else if (qry.Fields.Fields[i].DataType = ftfloat) then
                  begin
                    planilha.cells[linha,coluna].numberformat := '0,00';
                    planilha.cells[linha,coluna] := qry.Fields.Fields[i].AsFloat
                  end
                else if (qry.Fields.Fields[i].DataType = ftString) then
                  planilha.cells[linha,coluna] := qry.Fields.Fields[i].AsString
                else
                  planilha.cells[linha,coluna] := qry.Fields.Fields[i].AsString;

                if TamanhoPadraoCelulas > 0 then
                  planilha.cells[linha,coluna].ColumnWidth := TamanhoPadraoCelulas;

               if listaTamanhos[i][1] < length(trim(qry.Fields.Fields[i].AsString))+6  then
                 begin
                   listaTamanhos[i][1] := length(trim(qry.Fields.Fields[i].AsString))+6;
                   planilha.cells[linha,coluna].ColumnWidth :=  listaTamanhos[i][1];
                 end;
                 
               planilha.cells[linha,coluna].interior.color :=  clWhite;

               planilha.cells[linha,coluna].Borders.Weight := 2;
               inc(coluna);

              end;
          end;

        qry.Next;
      end;

    SelectDirectory('Selecione o diretório:', '', cCaminho);
    planilha.SaveAs(cCaminho+'\Panilha.xls');


    if (Excel.Visible = False) and (not VarIsEmpty(Excel)) then
      begin
        Excel.DisplayAlerts := False;
        Excel.Quit;
        Excel    := Unassigned;
        planilha := Unassigned;
      end;

  except
    Application.MessageBox('Erro na geração do Excel!','Mensagem',0+MB_ICONINFORMATION);
  end;
end;

function ValidaGrid(campo_query : String; var titulo_coluna:string;grid : TcxGridDBTableView): Boolean;
var i : integer;
    bRetorno : Boolean;
begin
  bRetorno := false;
  for i:= 0 to grid.ColumnCount - 1 do
    begin
      if (grid.Columns[i].DataBinding.FieldName = campo_query) and (grid.Columns[i].Visible = true) then
        begin
          titulo_coluna := grid.Columns[i].Caption;
          bRetorno := true;
          Break;
        end;
    end;
  Result := bRetorno;
end;

end.
