unit BaseService;

interface

uses
  System.SysUtils, System.JSON, FireDAC.Comp.Client, FireDAC.Stan.Param,
  FireDAC.Stan.Async, FireDAC.Phys.PG, FireDAC.Stan.Def, FireDAC.DApt;

type
  TConfiguraBanco = class
  private
    class var FInstancia: TConfiguraBanco;

  strict private
    FConexao: TFDConnection;

    class function GetInstancia: TConfiguraBanco; static;

    constructor Create();
    destructor Destroy(); override;

  public
    property Conexao: TFDConnection read FConexao;

    class property Instancia: TConfiguraBanco read GetInstancia;

  end;

implementation

{ TConfiguraBanco }

constructor TConfiguraBanco.Create;
begin
  FConexao := TFDConnection.Create(nil);

  with FConexao.Params do
  begin
    Clear;
    Add('DriverID=PG');
    Add('Server=localhost');
    Add('Port=5432');
    Add('Database=Teste');
    Add('User_Name=postgres');
    Add('Password=postgres');
    Add('Pooled=False');
  end;
end;

destructor TConfiguraBanco.Destroy;
begin
  if (Assigned(FConexao)) then
  begin
    if (Conexao.Connected) then
      Conexao.Close();

    FreeAndNil(FConexao);
  end;

  inherited;
end;

class function TConfiguraBanco.GetInstancia: TConfiguraBanco;
begin
  if (not(Assigned(FInstancia))) then
    FInstancia := TConfiguraBanco.Create();

  Result := FInstancia;
end;

initialization

finalization

if (Assigned(TConfiguraBanco.FInstancia)) then
  FreeAndNil(TConfiguraBanco.FInstancia);

end.
