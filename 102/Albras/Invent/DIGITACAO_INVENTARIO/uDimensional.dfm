object frmDimensional: TfrmDimensional
  Left = 707
  Top = 232
  BorderStyle = bsSingle
  Caption = 'Controles do Item'
  ClientHeight = 235
  ClientWidth = 310
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 194
    Width = 310
    Height = 41
    Align = alBottom
    TabOrder = 1
    object btnOk: TcxButton
      Left = 224
      Top = 8
      Width = 75
      Height = 25
      Caption = '&Ok'
      TabOrder = 0
      OnClick = btnOkClick
    end
    object btnCancel: TcxButton
      Left = 136
      Top = 8
      Width = 75
      Height = 25
      Caption = '&Cancelar'
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
  object cxVerticalGrid1: TcxVerticalGrid
    Left = 0
    Top = 0
    Width = 310
    Height = 194
    Align = alClient
    TabOrder = 0
    object cxVerticalGrid1Endereco: TcxEditorRow
      Properties.Caption = 'Endereco'
      Properties.DataBinding.ValueType = 'String'
      Properties.Value = ''
    end
    object cxVerticalGrid1Volume: TcxEditorRow
      Properties.Caption = 'Volume'
      Properties.DataBinding.ValueType = 'Integer'
      Properties.Value = 0
    end
    object cxVerticalGrid1DataProducao: TcxEditorRow
      Properties.Caption = 'Data Produ'#231#227'o'
      Properties.EditPropertiesClassName = 'TcxDateEditProperties'
      Properties.DataBinding.ValueType = 'DateTime'
      Properties.Value = 0d
    end
    object cxVerticalGrid1DataValidade: TcxEditorRow
      Properties.Caption = 'Data Validade'
      Properties.EditPropertiesClassName = 'TcxDateEditProperties'
      Properties.DataBinding.ValueType = 'DateTime'
      Properties.Value = 0d
    end
    object cxVerticalGrid1Comprimento: TcxEditorRow
      Properties.Caption = 'Comprimento'
      Properties.DataBinding.ValueType = 'Float'
      Properties.Value = 0.000000000000000000
    end
    object cxVerticalGrid1Largura: TcxEditorRow
      Properties.Caption = 'Largura'
      Properties.DataBinding.ValueType = 'Float'
      Properties.Value = 0.000000000000000000
    end
    object cxVerticalGrid1Altura: TcxEditorRow
      Properties.Caption = 'Altura'
      Properties.DataBinding.ValueType = 'Float'
      Properties.Value = 0.000000000000000000
    end
    object cxVerticalGrid1Diametro: TcxEditorRow
      Properties.Caption = 'Di'#226'metro'
      Properties.DataBinding.ValueType = 'Float'
      Properties.Value = 0.000000000000000000
    end
    object cxVerticalGrid1Peca: TcxEditorRow
      Properties.Caption = 'Num. Pe'#231'a'
      Properties.DataBinding.ValueType = 'String'
      Properties.Value = ''
    end
    object cxVerticalGrid1Serie: TcxEditorRow
      Properties.Caption = 'Num. S'#233'rie'
      Properties.DataBinding.ValueType = 'String'
      Properties.Value = ''
    end
  end
end