unit uPessoa;

interface

uses
  uEndereco, System.SysUtils;

type
  TPessoa = class
  private
    FidPessoa: Integer;
    FflNatureza: SmallInt;
    FdsDocumento: string;
    FnmPrimeiro: string;
    FnmSegundo: string;
    FdtRegistro: TDate;
    FEndereco: TEndereco;
  public
    constructor Create(AEndereco: TEndereco);

    property IdPessoa: Integer read FidPessoa write FidPessoa;
    property FlNatureza: SmallInt read FflNatureza write FflNatureza;
    property DsDocumento: string read FdsDocumento write FdsDocumento;
    property NmPrimeiro: string read FnmPrimeiro write FnmPrimeiro;
    property NmSegundo: string read FnmSegundo write FnmSegundo;
    property DtRegistro: TDate read FdtRegistro write FdtRegistro;
    property Endereco: TEndereco read FEndereco write FEndereco;
  end;

implementation

constructor TPessoa.Create(AEndereco: TEndereco);
begin
  if AEndereco = nil then
    raise Exception.Create('Endereço é obrigatório para criar uma pessoa');

  FEndereco := AEndereco;
end;

end.

