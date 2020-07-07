object frmDuplicidade: TfrmDuplicidade
  Left = 470
  Top = 214
  BorderStyle = bsDialog
  Caption = 'Contagem j'#225' digitada'
  ClientHeight = 255
  ClientWidth = 342
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
    Top = 0
    Width = 342
    Height = 255
    Align = alClient
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 0
    object Label1: TLabel
      Left = 32
      Top = 16
      Width = 287
      Height = 33
      AutoSize = False
      Caption = 
        'A contagem que voc'#234' est'#225' tentando inserir j'#225' foi cadastrada ante' +
        'riormente:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      WordWrap = True
    end
    object Label2: TLabel
      Left = 15
      Top = 88
      Width = 44
      Height = 13
      Caption = 'C'#243'digo:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label3: TLabel
      Left = 15
      Top = 108
      Width = 83
      Height = 13
      Caption = 'N'#186'. Contagem:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label4: TLabel
      Left = 15
      Top = 128
      Width = 82
      Height = 13
      Caption = 'Local F'#225'brica:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label5: TLabel
      Left = 15
      Top = 165
      Width = 58
      Height = 13
      Caption = 'N'#186'. Folha:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label6: TLabel
      Left = 15
      Top = 185
      Width = 48
      Height = 13
      Caption = 'Usu'#225'rio:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label7: TLabel
      Left = 15
      Top = 146
      Width = 59
      Height = 13
      Caption = 'Situa'#231#227'o :'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object cxButton1: TcxButton
      Left = 136
      Top = 208
      Width = 75
      Height = 25
      Caption = '&Ok'
      TabOrder = 0
      OnClick = cxButton1Click
    end
    object lblCodIitem: TcxLabel
      Left = 115
      Top = 88
      Width = 55
      Height = 17
      Caption = 'lblCodIitem'
      TabOrder = 1
    end
    object lblNumContagem: TcxLabel
      Left = 115
      Top = 108
      Width = 84
      Height = 17
      Caption = 'lblNumContagem'
      TabOrder = 2
    end
    object lblLocalFab: TcxLabel
      Left = 115
      Top = 128
      Width = 58
      Height = 17
      Caption = 'lblLocalFab'
      TabOrder = 3
    end
    object lblNumFolha: TcxLabel
      Left = 115
      Top = 165
      Width = 62
      Height = 17
      Caption = 'lblNumFolha'
      TabOrder = 4
    end
    object lblCodUsuario: TcxLabel
      Left = 115
      Top = 185
      Width = 69
      Height = 17
      Caption = 'lblCodUsuario'
      TabOrder = 5
    end
    object lblSit: TcxLabel
      Left = 115
      Top = 146
      Width = 26
      Height = 17
      Caption = 'lblSit'
      TabOrder = 6
    end
  end
end
