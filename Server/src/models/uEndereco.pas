unit uEndereco;

interface

type
  TEndereco = class
  private
    FIdEndereco: Integer;
    FIdPessoa: Integer;
    FDsCep: string;
  public
    property IdEndereco: Integer read FIdEndereco write FIdEndereco;
    property IdPessoa: Integer read FIdPessoa write FIdPessoa;
    property DsCep: string read FDsCep write FDsCep;
  end;

implementation

end.
