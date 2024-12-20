unit uUtils;

interface

uses
  FireDAC.Comp.Client, FireDAC.Phys.PG, FireDAC.Stan.Def, FireDAC.Stan.Param, FireDAC.DApt, System.SysUtils,
  BaseService;

type
  TUtils = class
  private

  public
    class function GetConexao() : TFDConnection; static;
    class function GetMaxId(): Integer; static;

  end;

implementation

{ TUtils }

class function TUtils.GetConexao(): TFDConnection;
var
  LConexao: TConfiguraBanco;
begin
  LConexao := TConfiguraBanco.Instancia;
  Result := LConexao.Conexao;
end;

class function TUtils.GetMaxId(): Integer;
var
  FQuery: TFDQuery;
begin
  FQuery := TFDQuery.Create(nil);
  try
    FQuery.Connection := TUtils.GetConexao();
    FQuery.SQL.Text := 'SELECT MAX(idpessoa) as idpessoa FROM pessoa;';
    FQuery.Open;
    Result := FQuery.Fields[0].AsLargeInt;
  finally
    FQuery.Free;
  end;
end;

initialization

finalization

end.

