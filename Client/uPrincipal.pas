unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls, System.Net.HttpClient,
  System.JSON, DataSet.Serialize, FireDAC.Stan.StorageBin, FireDAC.Phys.Intf, FireDAC.DApt.Intf, Vcl.DBCtrls,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.Buttons, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, Data.DB,
  FireDAC.Stan.Intf, Vcl.Grids, Vcl.DBGrids;

type
  TfrmPrincipal = class(TForm)
    edtId: TLabeledEdit;
    edtNatureza: TLabeledEdit;
    edtDocumento: TLabeledEdit;
    edtSegundoNome: TLabeledEdit;
    edtPrimeiroNome: TLabeledEdit;
    edtDataRegistro: TLabeledEdit;
    gridPessoas: TDBGrid;
    memPessoa: TFDMemTable;
    dtsPessoa: TDataSource;
    navPessoa: TDBNavigator;
    btnGravar: TButton;
    edtCep: TLabeledEdit;
    pnlCampos: TPanel;
    pnlGrid: TPanel;
    procedure btnGravarClick(Sender: TObject);
    procedure navPessoaClick(Sender: TObject; Button: TNavigateBtn);
    procedure gridPessoasCellClick(Column: TColumn);
    procedure FormShow(Sender: TObject);
  private
    procedure FitColumns;
    procedure GetAll;
    procedure GetPessoa(const Id: Integer);
    procedure DeletePessoa(const Id: Integer);
    procedure AtualizarPessoa(const JsonPessoa: TJSONObject; const Id: Integer);
    procedure InserirPessoa(const JsonPessoa: TJSONObject);
    procedure ClearForm;
    procedure PreencherCampos;

    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;
  IdSelecionado: Integer;
const
  Server_URL: string = 'http://localhost:8080';
  Metodo: string = '/pessoas';

implementation

{$R *.dfm}


procedure TfrmPrincipal.GetPessoa(const Id: Integer);
var
  httpClient: THTTPClient;
  response: IHTTPResponse;
  jsonResponse: TJSONObject;
begin
  httpClient := THTTPClient.Create;
  httpClient.ConnectionTimeout := Integer.MaxValue;
  httpClient.SendTimeout := Integer.MaxValue;
  httpClient.ResponseTimeout := Integer.MaxValue;
  try
    response := httpClient.Get(Server_URL + Metodo + '/' + Id.ToString);

    if response.StatusCode = 200 then
    begin
      jsonResponse := TJSONObject.ParseJSONValue(response.ContentAsString) as TJSONObject;
      memPessoa.Close;
      memPessoa.LoadFromJSON(jsonResponse);
    end
    else
      raise Exception.Create('Erro ao buscar dados da API: ' + response.StatusText);
  finally
    httpClient.Free;
  end;
end;

procedure TfrmPrincipal.InserirPessoa(const JsonPessoa: TJSONObject);
var
  httpClient: THTTPClient;
  response: IHTTPResponse;
  stringStream: TStringStream;
begin
  httpClient := THTTPClient.Create;
  httpClient.ConnectionTimeout := Integer.MaxValue;
  httpClient.SendTimeout := Integer.MaxValue;
  httpClient.ResponseTimeout := Integer.MaxValue;

  stringStream := TStringStream.Create(JsonPessoa.ToString, TEncoding.UTF8);
  try
    response := httpClient.Post(Server_URL + Metodo, stringStream);

    if response.StatusCode <> 200 then
      raise Exception.Create('Erro ao buscar dados da API: ' + response.StatusText);
  finally
    httpClient.Free;
    stringStream.Free;
  end;
end;

procedure TfrmPrincipal.gridPessoasCellClick(Column: TColumn);
begin
  PreencherCampos();
end;

procedure TfrmPrincipal.AtualizarPessoa(const JsonPessoa: TJSONObject; const Id: Integer);
var
  httpClient: THTTPClient;
  response: IHTTPResponse;
  stringStream: TStringStream;
begin
  httpClient := THTTPClient.Create;
  httpClient.ConnectionTimeout := Integer.MaxValue;
  httpClient.SendTimeout := Integer.MaxValue;
  httpClient.ResponseTimeout := Integer.MaxValue;
  stringStream := TStringStream.Create(JsonPessoa.ToString, TEncoding.UTF8);
  try
    response := httpClient.Put(Server_URL + Metodo + '/' + Id.ToString, stringStream);

    if response.StatusCode <> 200 then
      raise Exception.Create('Erro ao buscar dados da API: ' + response.StatusText);
  finally
    httpClient.Free;
    stringStream.Free;
  end;
end;

procedure TfrmPrincipal.FitColumns;
begin
  gridPessoas.Columns[0].Width := 70;
  gridPessoas.Columns[0].Title.Caption := 'Id';

  gridPessoas.Columns[1].Width := 80;
  gridPessoas.Columns[1].Title.Caption := 'Natureza';

  gridPessoas.Columns[2].Width := 90;
  gridPessoas.Columns[2].Title.Caption := 'Documento';

  gridPessoas.Columns[3].Width := 100;
  gridPessoas.Columns[3].Title.Caption := 'Nome';

  gridPessoas.Columns[4].Width := 100;
  gridPessoas.Columns[4].Title.Caption := 'Sobrenome';

  gridPessoas.Columns[5].Width := 100;
  gridPessoas.Columns[5].Title.Caption := 'Data Cadastro';

  gridPessoas.Columns[6].Width := 70;
  gridPessoas.Columns[6].Title.Caption := 'Cep';
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
  GetAll();
end;

procedure TfrmPrincipal.GetAll;
var
  httpClient: THTTPClient;
  response: IHTTPResponse;
  jsonResponse: TJSONArray;
begin
  httpClient := THTTPClient.Create;
  httpClient.ConnectionTimeout := Integer.MaxValue;
  httpClient.SendTimeout := Integer.MaxValue;
  httpClient.ResponseTimeout := Integer.MaxValue;
  try
    response := httpClient.Get(Server_URL + Metodo);

    if response.StatusCode = 200 then
    begin
      jsonResponse := TJSONArray.ParseJSONValue(response.ContentAsString) as TJSONArray;
      memPessoa.Close;
      memPessoa.LoadFromJSON(jsonResponse);
      FitColumns();
    end
    else
      raise Exception.Create('Erro ao buscar dados da API: ' + response.StatusText);
  finally
    httpClient.Free;
  end;
end;

procedure TfrmPrincipal.btnGravarClick(Sender: TObject);
var
  json: TJSONObject;
begin
  json := TJSONObject.Create;
  try
    json.AddPair('flnatureza', edtNatureza.Text);
    json.AddPair('dsdocumento', edtDocumento.Text);
    json.AddPair('nmprimeiro', edtPrimeiroNome.Text);
    json.AddPair('nmsegundo', edtSegundoNome.Text);
    json.AddPair('dscep', edtCep.Text);
    json.AddPair('dtregistro', FormatDateTime('YYYY-MM-DD', Now));

    if edtId.Text = '' then
      InserirPessoa(json)
    else
      AtualizarPessoa(json, memPessoa.FieldByName('idpessoa').AsLargeInt);
  finally
    json.Free;
    ClearForm();
    GetAll;
  end;
end;

procedure TfrmPrincipal.DeletePessoa(const Id: Integer);
var
  httpClient: THTTPClient;
  response: IHTTPResponse;
begin
  httpClient := THTTPClient.Create;
  httpClient.ConnectionTimeout := Integer.MaxValue;
  httpClient.SendTimeout := Integer.MaxValue;
  httpClient.ResponseTimeout := Integer.MaxValue;
  try
    response := httpClient.Delete(Server_URL + Metodo + '/' + Id.ToString);

    if response.StatusCode <> 200 then
      raise Exception.Create('Erro ao buscar dados da API: ' + response.StatusText);
  finally
    httpClient.Free;
  end;
end;

procedure TfrmPrincipal.navPessoaClick(Sender: TObject; Button: TNavigateBtn);
begin
  if Button in [nbFirst, nbPrior , nbNext, nbLast] then
    PreencherCampos()
  else if Button = nbInsert then
  begin
    edtNatureza.SetFocus;
    (Sender as TDBNavigator).DataSource.DataSet.Append;
    ClearForm();
  end
  else if Button = nbDelete then
  begin
    If MessageDlg('Confirma a exclusão do registro?', mtWarning, [mbYes, mbNo], 0) = mrYes then
      DeletePessoa(IdSelecionado);

    GetAll();
  end
  else if Button = nbPost then
  begin
    var json: TJSONObject;
    json.AddPair('flnatureza', edtNatureza.Text);
    json.AddPair('dsdocumento', edtDocumento.Text);
    json.AddPair('nmprimeiro', edtPrimeiroNome.Text);
    json.AddPair('nmsegundo', edtSegundoNome.Text);
    json.AddPair('dscep', edtCep.Text);
    json := TJSONObject.Create;
    AtualizarPessoa(json, IdSelecionado);
    json.Free;
  end
  else if Button = nbCancel then
    ClearForm()
  else if Button = nbRefresh then
    GetAll()
end;

procedure TfrmPrincipal.PreencherCampos;
begin
  edtId.Text           := memPessoa.FieldByName('idpessoa').AsLargeInt.ToString;
  edtNatureza.Text     := memPessoa.FieldByName('flnatureza').AsString;
  edtDocumento.Text    := memPessoa.FieldByName('dsdocumento').AsString;
  edtPrimeiroNome.Text := memPessoa.FieldByName('nmprimeiro').AsString;
  edtSegundoNome.Text  := memPessoa.FieldByName('nmsegundo').AsString;
  edtDataRegistro.Text := memPessoa.FieldByName('dtregistro').AsString;
  edtCep.Text          := memPessoa.FieldByName('dscep').AsString;

  if memPessoa.FieldByName('idpessoa').AsLargeInt > 0 then
  begin
    IdSelecionado := memPessoa.FieldByName('idpessoa').Value;
    btnGravar.Caption := 'Atualizar';
  end;
end;

procedure TfrmPrincipal.ClearForm;
begin
  btnGravar.Caption := 'Gravar';
  IdSelecionado := 0;

  edtId.Clear();
  edtNatureza.Clear();
  edtDocumento.Clear();
  edtPrimeiroNome.Clear();
  edtSegundoNome.Clear();
  edtDataRegistro.Clear();
  edtCep.Clear();
end;

end.
