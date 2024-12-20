unit IntegracaoService;

interface

uses
  System.SysUtils, System.JSON, FireDAC.Comp.Client, FireDAC.Stan.Param,
  FireDAC.Stan.Async, uEnderecoIntegracao, System.Net.HttpClient, uUtils;

procedure AtualizarEnderecoIntegracao(IdEndereco: Integer; const Cep: string);

implementation

procedure InserirDadosEnderecoIntegracao(const EnderecoIntegracao: TEnderecoIntegracao);
var
  FQuery: TFDQuery;
begin
  FQuery := TFDQuery.Create(nil);
  try
    FQuery.Connection := TUtils.GetConexao();
    FQuery.SQL.Text := '''
      INSERT INTO endereco_integracao (idendereco, dsuf, nmcidade, nmbairro, nmlogradouro, dscomplemento)
      VALUES (:idendereco, :dsuf, :nmcidade, :nmbairro, :nmlogradouro, :dscomplemento)
      ON CONFLICT (idendereco)
      DO UPDATE SET
        dsuf = EXCLUDED.dsuf,
        nmcidade = EXCLUDED.nmcidade,
        nmbairro = EXCLUDED.nmbairro,
        nmlogradouro = EXCLUDED.nmlogradouro,
        dscomplemento = EXCLUDED.dscomplemento;
    ''';

    FQuery.ParamByName('idendereco').AsLargeInt := EnderecoIntegracao.IdEndereco;
    FQuery.ParamByName('dsuf').AsString := EnderecoIntegracao.DsUf;
    FQuery.ParamByName('nmcidade').AsString := EnderecoIntegracao.NmCidade;
    FQuery.ParamByName('nmbairro').AsString := EnderecoIntegracao.NmBairro;
    FQuery.ParamByName('nmlogradouro').AsString := EnderecoIntegracao.NmLogradouro;
    FQuery.ParamByName('dscomplemento').AsString := EnderecoIntegracao.DsComplemento;

    FQuery.ExecSQL;
  finally
    FQuery.Free;
  end;
end;

procedure AtualizarEnderecoIntegracao(IdEndereco: Integer; const Cep: string);
var
  HttpClient: THTTPClient;
  Response: IHTTPResponse;
  JsonResponse: TJSONObject;
  EnderecoIntegracao: TEnderecoIntegracao;
begin
  HttpClient := THTTPClient.Create;
  HttpClient.ConnectionTimeout := Integer.MaxValue;
  HttpClient.SendTimeout := Integer.MaxValue;
  HttpClient.ResponseTimeout := Integer.MaxValue;
  try
    Response := HttpClient.Get('https://viacep.com.br/ws/' + Cep + '/json/');

    if Response.StatusCode <> 200 then
      raise Exception.Create('Erro ao buscar dados da API: ' + Response.StatusText);

    JsonResponse := TJSONObject.ParseJSONValue(Response.ContentAsString) as TJSONObject;
    try
      EnderecoIntegracao := TEnderecoIntegracao.Create(JsonResponse);
      try
        EnderecoIntegracao.IdEndereco := IdEndereco;

        InserirDadosEnderecoIntegracao(EnderecoIntegracao);
      finally
        EnderecoIntegracao.Free;
      end;
    finally
      JsonResponse.Free;
    end;
  finally
    HttpClient.Free;
  end;
end;

end.
