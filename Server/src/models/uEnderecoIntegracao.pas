unit uEnderecoIntegracao;

interface

uses
  System.JSON;

type
  TEnderecoIntegracao = class
  private
    FIdEndereco: Integer;
    FDsUf: string;
    FNmCidade: string;
    FNmBairro: string;
    FNmLogradouro: string;
    FDsComplemento: string;
  public
    constructor Create(const Json: TJSONObject);

    property IdEndereco: Integer read FIdEndereco write FIdEndereco;
    property DsUf: string read FDsUf write FDsUf;
    property NmCidade: string read FNmCidade write FNmCidade;
    property NmBairro: string read FNmBairro write FNmBairro;
    property NmLogradouro: string read FNmLogradouro write FNmLogradouro;
    property DsComplemento: string read FDsComplemento write FDsComplemento;
  end;

implementation

{ TEnderecoIntegracao }

constructor TEnderecoIntegracao.Create(const Json: TJSONObject);
begin
  FDsUf     := Json.GetValue<string>('uf');
  FNmCidade := Json.GetValue<string>('localidade');
  FNmBairro := Json.GetValue<string>('bairro');
  FNmLogradouro  := Json.GetValue<string>('logradouro');
  FDsComplemento := Json.GetValue<string>('complemento');
end;

end.

