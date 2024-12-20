program Server;

uses
  Vcl.Forms,
  Main.Form in 'src\Main.Form.pas' {FrmVCL},
  uEndereco in 'src\models\uEndereco.pas',
  uPessoa in 'src\models\uPessoa.pas',
  uEnderecoIntegracao in 'src\models\uEnderecoIntegracao.pas',
  uUtils in 'src\utils\uUtils.pas',
  PessoaController in 'src\controllers\PessoaController.pas',
  AtualizaEnderecoService.Thread in 'src\services\AtualizaEnderecoService.Thread.pas',
  BaseService in 'src\services\BaseService.pas',
  IntegracaoService in 'src\services\IntegracaoService.pas',
  PessoaService in 'src\services\PessoaService.pas',
  uLotePessoa in 'src\models\uLotePessoa.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmVCL, FrmVCL);
  Application.Run;
end.
