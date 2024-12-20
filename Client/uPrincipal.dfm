object frmPrincipal: TfrmPrincipal
  Left = 0
  Top = 0
  Caption = 'Cadastro de Pessoas'
  ClientHeight = 475
  ClientWidth = 942
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnShow = FormShow
  TextHeight = 13
  object pnlCampos: TPanel
    Left = 0
    Top = 0
    Width = 942
    Height = 113
    Align = alTop
    TabOrder = 0
    object btnGravar: TButton
      Left = 794
      Top = 67
      Width = 120
      Height = 31
      Caption = '&Gravar'
      TabOrder = 7
      OnClick = btnGravarClick
    end
    object edtCep: TLabeledEdit
      Left = 632
      Top = 72
      Width = 105
      Height = 21
      EditLabel.Width = 19
      EditLabel.Height = 13
      EditLabel.Caption = 'Cep'
      EditMask = '00000\-999;0;_'
      MaxLength = 9
      TabOrder = 6
      Text = ''
    end
    object edtDataRegistro: TLabeledEdit
      Left = 171
      Top = 24
      Width = 120
      Height = 21
      EditLabel.Width = 66
      EditLabel.Height = 13
      EditLabel.Caption = 'Data Registro'
      Enabled = False
      ReadOnly = True
      TabOrder = 1
      Text = ''
    end
    object edtDocumento: TLabeledEdit
      Left = 171
      Top = 72
      Width = 120
      Height = 21
      EditLabel.Width = 54
      EditLabel.Height = 13
      EditLabel.Caption = 'Documento'
      NumbersOnly = True
      TabOrder = 3
      Text = ''
    end
    object edtId: TLabeledEdit
      Left = 19
      Top = 24
      Width = 137
      Height = 21
      EditLabel.Width = 47
      EditLabel.Height = 13
      EditLabel.Caption = 'Id Pessoa'
      Enabled = False
      ReadOnly = True
      TabOrder = 0
      Text = ''
    end
    object edtNatureza: TLabeledEdit
      Left = 19
      Top = 72
      Width = 137
      Height = 21
      EditLabel.Width = 44
      EditLabel.Height = 13
      EditLabel.Caption = 'Natureza'
      NumbersOnly = True
      TabOrder = 2
      Text = ''
    end
    object edtPrimeiroNome: TLabeledEdit
      Left = 311
      Top = 72
      Width = 137
      Height = 21
      EditLabel.Width = 68
      EditLabel.Height = 13
      EditLabel.Caption = 'Primeiro Nome'
      TabOrder = 4
      Text = ''
    end
    object edtSegundoNome: TLabeledEdit
      Left = 466
      Top = 72
      Width = 145
      Height = 21
      EditLabel.Width = 72
      EditLabel.Height = 13
      EditLabel.Caption = 'Segundo Nome'
      TabOrder = 5
      Text = ''
    end
  end
  object pnlGrid: TPanel
    Left = 0
    Top = 113
    Width = 942
    Height = 362
    Align = alClient
    TabOrder = 1
    object gridPessoas: TDBGrid
      Left = 1
      Top = 1
      Width = 940
      Height = 335
      Align = alClient
      DataSource = dtsPessoa
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
      OnCellClick = gridPessoasCellClick
    end
    object navPessoa: TDBNavigator
      Left = 1
      Top = 336
      Width = 940
      Height = 25
      DataSource = dtsPessoa
      VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast, nbInsert, nbDelete, nbPost, nbCancel, nbRefresh]
      Align = alBottom
      ConfirmDelete = False
      TabOrder = 1
      OnClick = navPessoaClick
    end
  end
  object memPessoa: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvPersistent, rvSilentMode]
    ResourceOptions.Persistent = True
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 336
    Top = 184
  end
  object dtsPessoa: TDataSource
    DataSet = memPessoa
    Left = 416
    Top = 184
  end
end
