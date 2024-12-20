unit uPessoa;

interface

type
  TPessoa = class
  private
    FidPessoa: Int64;
    FflNatureza: SmallInt;
    FdsDocumento: string;
    FnmPrimeiro: string;
    FnmSegundo: string;
    FdtRegistro: TDate;
  public
    property IdPessoa: Int64 read FidPessoa write FidPessoa;
    property FlNatureza: SmallInt read FflNatureza write FflNatureza;
    property DsDocumento: string read FdsDocumento write FdsDocumento;
    property NmPrimeiro: string read FnmPrimeiro write FnmPrimeiro;
    property NmSegundo: string read FnmSegundo write FnmSegundo;
    property DtRegistro: TDate read FdtRegistro write FdtRegistro;
  end;

implementation

end.
