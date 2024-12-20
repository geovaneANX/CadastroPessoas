unit PessoaService;

interface

uses
  System.SysUtils, System.JSON, FireDAC.Comp.Client, FireDAC.Stan.Param,
  uPessoa, uEndereco, FireDAC.Stan.Async, System.StrUtils,
  System.Generics.Collections, System.Classes, FireDAC.Comp.Script,
  FireDAC.Comp.ScriptCommands, FireDAC.Stan.Util, DataSet.Serialize, Data.DB,
  uUtils, AtualizaEnderecoThread, uLotePessoa;

procedure InserirPessoa(const JsonPessoa: TJSONObject);
procedure InserirPessoaLote(const JsonListaPessoa: TJSONArray);

function ListarPessoas(const Id: Integer = 0): TJSONArray;
function DeletarPessoa(const Id: Integer): Boolean;
function AtualizarPessoa(const Id: Integer; const JsonObject: TJSONObject): TJSONArray;

implementation

function BuildSqlInsert(const Natureza, Documento, PrimeiroNome, SegundoNome, DtRegistro, Cep: string): string;
var
  query: string;
begin
  query := '''
    DO $$
      DECLARE novoid INTEGER;
      BEGIN
        INSERT INTO pessoa (flnatureza, dsdocumento, nmprimeiro, nmsegundo, dtregistro)
        VALUES (:natureza, :documento, :primeiro_nome, :segundo_nome, :dtregistro)

        RETURNING idpessoa INTO novoid;

        INSERT INTO endereco (idpessoa, dscep) VALUES (novoid, :cep);
      END
    $$;
  ''';

  query := query
    .Replace(':natureza', Natureza)
    .Replace(':documento', QuotedStr(Documento))
    .Replace(':primeiro_nome', QuotedStr(PrimeiroNome))
    .Replace(':segundo_nome', QuotedStr(SegundoNome))
    .Replace(':dtregistro', QuotedStr(DtRegistro))
    .Replace(':cep', QuotedStr(Cep));

  Result := query;
end;

function BuildSqlUpdate(Natureza, Documento, PrimeiroNome, SegundoNome, DtRegistro, Cep: string; const idPessoa: Integer): string;
var
  query: string;
begin
  query := '''
    DO $$
      BEGIN
        UPDATE pessoa SET flnatureza = :natureza, dsdocumento = :documento, nmprimeiro = :primeiro_nome, nmsegundo = :segundo_nome, dtregistro = :dtregistro
        WHERE idpessoa = :idpessoa;

        UPDATE endereco SET dscep = :cep WHERE idpessoa = :idpessoa;
      END
    $$;
  ''';

  if Natureza = '' then
    Natureza := '0';

  query := query
    .Replace(':idpessoa', idPessoa.ToString)
    .Replace(':natureza', Natureza)
    .Replace(':documento', QuotedStr(Documento))
    .Replace(':primeiro_nome', QuotedStr(PrimeiroNome))
    .Replace(':segundo_nome', QuotedStr(SegundoNome))
    .Replace(':dtregistro', QuotedStr(DtRegistro))
    .Replace(':cep', QuotedStr(Cep));

  Result := query;
end;

procedure SalvarLotePessoa(const LotePessoas: TLotePessoa);
var
  Pessoa: TPessoa;
  Endereco: TEndereco;
  scriptLote: TStrings;
  script: TFDScript;
begin
  Endereco := TEndereco.Create;
  Pessoa   := TPessoa.Create(Endereco);

  scriptLote := TStringList.Create;
  script     := TFDScript.Create(nil);

  try
    script.Connection := TUtils.GetConexao();

    try
      if not script.Connection.InTransaction then
        script.Connection.StartTransaction;

      for var index := 0 to LotePessoas.Count -1 do
      begin
        Pessoa := LotePessoas.Index(index);
        var sql := BuildSqlInsert(Pessoa.FlNatureza.ToString, Pessoa.DsDocumento, Pessoa.NmPrimeiro, Pessoa.NmSegundo, FormatDateTime('YYYY-MM-DD', Pessoa.DtRegistro), Pessoa.Endereco.DsCep);
        scriptLote.Add(sql);

        if scriptLote.Count = 500 then
        begin
          if scriptLote.Count > 0 then
            script.ExecuteScript(scriptLote);

          scriptLote.Clear();
          script.Connection.Commit;
        end;
      end;

      if scriptLote.Count > 0 then
      begin
        script.ExecuteScript(scriptLote);
      end;

      script.Connection.Commit;
      if LotePessoas.Count = 1 then
      begin
        for var index := 0 to LotePessoas.Count -1 do
        begin
          Pessoa := LotePessoas.Index(index);
          Pessoa.IdPessoa := TUtils.GetMaxId();
          // Via CEP Bloqueia IP após muitas requisições
          // TAtualizarEnderecoService.AtualizarEndereco(Pessoa.IdPessoa, Pessoa.Endereco.DsCep, nil);
        end;
      end;
    except
      on E: Exception do
      begin
        script.Connection.Rollback;
        raise Exception.Create('Erro ao cadastrar Pessoa! ' + sLineBreak + E.Message);
      end;
    end;
  finally
    Pessoa.Free;
    Endereco.Free;
    scriptLote.Free;
    script.Free;
  end;
end;

procedure SalvarPessoa(const Pessoa: TPessoa);
var
  FQuery: TFDQuery;
begin
  FQuery := TFDQuery.Create(nil);
  try
    try
      FQuery.Connection := TUtils.GetConexao();
      FQuery.SQL.Text   := BuildSqlInsert(Pessoa.FlNatureza.ToString, Pessoa.DsDocumento, Pessoa.NmPrimeiro, Pessoa.NmSegundo, FormatDateTime('YYYY-MM-DD', Pessoa.DtRegistro), Pessoa.Endereco.DsCep);
      FQuery.ExecSQL;

      TAtualizarEnderecoService.AtualizarEndereco(Pessoa.IdPessoa, Pessoa.Endereco.DsCep, nil);
    except
      on E: Exception do
      begin
        raise Exception.Create('Erro ao cadastrar Pessoa! ' + sLineBreak + E.Message);
      end;
    end;
  finally
    FQuery.Free;
  end;
end;

procedure InserirPessoaLote(const JsonListaPessoa: TJSONArray);
var
  Endereco: TEndereco;
  ListaPessoa: TLotePessoa;
  Pessoa: TPessoa;
begin
  ListaPessoa := TLotePessoa.Create();
  try
    for var index := 0 to JsonListaPessoa.Count -1 do
    begin
      var jsonPessoa := JsonListaPessoa.Items[index];
      if jsonPessoa is TJSONObject then
      begin
        Endereco:= TEndereco.Create();
        Pessoa := TPessoa.Create(Endereco);

        Pessoa.FlNatureza  := jsonPessoa.GetValue<SmallInt>('flnatureza');
        Pessoa.DsDocumento := jsonPessoa.GetValue<string>('dsdocumento');
        Pessoa.NmPrimeiro  := jsonPessoa.GetValue<string>('nmprimeiro');
        Pessoa.NmSegundo   := jsonPessoa.GetValue<string>('nmsegundo');
        Pessoa.DtRegistro  := jsonPessoa.GetValue<TDate>('dtregistro');
        Endereco.DsCep     := JsonPessoa.GetValue<string>('dscep');
        Pessoa.Endereco    := Endereco;
        ListaPessoa.Add(Pessoa);
      end;
    end;

    SalvarLotePessoa(ListaPessoa);
  finally
    ListaPessoa.Destroy;
  end;
end;

procedure InserirPessoa(const JsonPessoa: TJSONObject);
var
  Endereco: TEndereco;
  Pessoa: TPessoa;
begin
  Endereco := TEndereco.Create;
  Pessoa := TPessoa.Create(Endereco);
  try
    Pessoa.FlNatureza  := JsonPessoa.GetValue<SmallInt>('flnatureza');
    Pessoa.DsDocumento := JsonPessoa.GetValue<string>('dsdocumento');
    Pessoa.NmPrimeiro  := JsonPessoa.GetValue<string>('nmprimeiro');
    Pessoa.NmSegundo  := JsonPessoa.GetValue<string>('nmsegundo');
    Pessoa.DtRegistro := JsonPessoa.GetValue<TDate>('dtregistro');
    Endereco.DsCep  := JsonPessoa.GetValue<string>('dscep');
    Pessoa.Endereco := Endereco;

    SalvarPessoa(Pessoa);
  finally
    Endereco.Free;
    Pessoa.Free;
  end;
end;

function DeletarPessoa(const Id: Integer) : Boolean;
var
  FQuery: TFDQuery;
begin
  FQuery := TFDQuery.Create(nil);
  try
    FQuery.Connection := TUtils.GetConexao();
    FQuery.SQL.Text := 'DELETE FROM pessoa WHERE idpessoa = :idpessoa RETURNING 1 as qtde';
    FQuery.ParamByName('idpessoa').AsLargeInt := Id;
    FQuery.Open;
    Result := FQuery.FieldByName('qtde').AsInteger = 1;
  finally
    FQuery.Free;
  end;
end;

function ListarPessoas(const Id: Integer = 0) : TJSONArray;
var
  FQuery: TFDQuery;
begin
  FQuery := TFDQuery.Create(nil);
  try
    FQuery.Connection := TUtils.GetConexao();
    FQuery.SQL.Text := '''
      SELECT
      	p.idpessoa, p.flnatureza, p.dsdocumento, p.nmprimeiro, p.nmsegundo, p.dtregistro, e.dscep
      FROM
        pessoa as p
        inner join endereco as e on e.idpessoa = p.idpessoa
    ''';

    if Id > 0 then
    begin
      FQuery.SQL.Text := FQuery.SQL.Text + ' where p.idpessoa = :idpessoa';
      FQuery.ParamByName('idpessoa').AsLargeInt := Id;
    end;

    FQuery.SQL.Text := FQuery.SQL.Text + ' ORDER BY p.idpessoa';

    FQuery.Open;
    Result := FQuery.ToJSONArray;
  finally
    FQuery.Free;
  end;
end;

function AtualizarPessoa(const Id: Integer; const JsonObject: TJSONObject): TJSONArray;
var
  FQuery: TFDQuery;
  natureza, documento, primeiroNome, segundoNome, dataRegistro, cep: string;
begin
  FQuery := TFDQuery.Create(nil);
  try
    FQuery.Connection := TUtils.GetConexao();
    FQuery.SQL.Text := '''
        SELECT
          p.idpessoa, p.flnatureza, p.dsdocumento, p.nmprimeiro, p.nmsegundo, p.dtregistro
        FROM
          pessoa as p
          INNER JOIN endereco as e on e.idpessoa = p.idpessoa
        WHERE
          p.idpessoa = :idpessoa
    ''';
    FQuery.ParamByName('idpessoa').AsLargeInt := Id;
    FQuery.Open;

    if FQuery.RecordCount = 0 then
      raise Exception.Create('Pessoa não cadastrada!');

    natureza      := JsonObject.GetValue<string>('flnatureza', '');
    documento     := JsonObject.GetValue<string>('dsdocumento', '');
    primeiroNome  := JsonObject.GetValue<string>('nmprimeiro', '');
    segundoNome   := JsonObject.GetValue<string>('nmsegundo', '');
    dataRegistro  := JsonObject.GetValue<string>('dtregistro', '');
    cep           := JsonObject.GetValue<string>('dscep', '');

    FQuery.SQL.Text := BuildSqlUpdate(natureza, documento, primeiroNome, segundoNome, dataRegistro, cep, Id);
    FQuery.ExecSQL;

    TAtualizarEnderecoService.AtualizarEndereco(Id, cep, nil);

    Result := ListarPessoas(Id);
  finally
    FQuery.Free;
  end;
end;

end.
