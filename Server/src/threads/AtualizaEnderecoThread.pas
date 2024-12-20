unit AtualizaEnderecoThread;

interface

uses
  System.SysUtils, System.Classes, IntegracaoService, System.Threading;

type
  TAtualizarEnderecoService = class
  public
    class procedure AtualizarEndereco(IdEndereco: Integer; const Cep: string; OnError: TProc<string>);
  end;

implementation

{ TAtualizarEnderecoService }

class procedure TAtualizarEnderecoService.AtualizarEndereco(IdEndereco: Integer; const Cep: string; OnError: TProc<string>);
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      try
        AtualizarEnderecoIntegracao(IdEndereco, Cep);
      except
        on E: Exception do
        begin
          if Assigned(OnError) then
          begin
            TThread.Synchronize(nil, procedure begin OnError(E.Message); end);
          end;
        end;
      end;
    end
  ).Start;
end;

end.
