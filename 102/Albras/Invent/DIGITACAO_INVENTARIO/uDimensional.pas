unit uDimensional;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, cxStyles, cxGraphics, cxEdit, cxVGrid,
  cxControls, cxInplaceContainer, cxLookAndFeelPainters, cxButtons,
  cxCalendar;

type
  TfrmDimensional = class(TForm)
    Panel1: TPanel;
    cxVerticalGrid1: TcxVerticalGrid;
    cxVerticalGrid1Endereco: TcxEditorRow;
    cxVerticalGrid1Volume: TcxEditorRow;
    cxVerticalGrid1DataProducao: TcxEditorRow;
    cxVerticalGrid1DataValidade: TcxEditorRow;
    cxVerticalGrid1Comprimento: TcxEditorRow;
    cxVerticalGrid1Largura: TcxEditorRow;
    cxVerticalGrid1Altura: TcxEditorRow;
    cxVerticalGrid1Diametro: TcxEditorRow;
    cxVerticalGrid1Peca: TcxEditorRow;
    cxVerticalGrid1Serie: TcxEditorRow;
    btnOk: TcxButton;
    btnCancel: TcxButton;
    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmDimensional: TfrmDimensional;

implementation

{$R *.dfm}

procedure TfrmDimensional.btnOkClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TfrmDimensional.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmDimensional.FormShow(Sender: TObject);
begin
  cxVerticalGrid1DataProducao.Properties.Value := null;
  cxVerticalGrid1DataValidade.Properties.Value := null;
end;

end.
