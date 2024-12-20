unit uEndereco;

interface

type
  TEndereco = class
  private
    FidEndereco: Int64;
    FidPessoa: Int64;
    FdsCep: string;
  public
    property IdEndereco: Int64 read FidEndereco write FidEndereco;
    property IdPessoa: Int64 read FidPessoa write FidPessoa;
    property DsCep: string read FdsCep write FdsCep;
  end;

implementation

end.
