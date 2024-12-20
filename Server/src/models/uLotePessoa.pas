unit uLotePessoa;

interface

uses
  System.Generics.Collections, uPessoa;

type
  TLotePessoa = class
  private
    FPessoas: TList<TPessoa>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(Pessoa: TPessoa);
    procedure Remove(Pessoa: TPessoa);
    procedure Clear;

    function Index(Index: Integer): TPessoa;
    function Count: Integer;
  end;

implementation

uses
  System.SysUtils, PessoaService;

{ TLotePessoa }

constructor TLotePessoa.Create;
begin
  FPessoas := TList<TPessoa>.Create;
end;

destructor TLotePessoa.Destroy;
begin
  FPessoas.Free;
  inherited;
end;

procedure TLotePessoa.Add(Pessoa: TPessoa);
begin
  FPessoas.Add(Pessoa);
end;

procedure TLotePessoa.Remove(Pessoa: TPessoa);
begin
  FPessoas.Remove(Pessoa);
end;

procedure TLotePessoa.Clear;
begin
  FPessoas.Clear;
end;

function TLotePessoa.Index(Index: Integer): TPessoa;
begin
  Result := FPessoas[Index];
end;

function TLotePessoa.Count: Integer;
begin
  Result := FPessoas.Count;
end;

end.

