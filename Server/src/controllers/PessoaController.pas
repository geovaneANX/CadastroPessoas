unit PessoaController;

interface

procedure ConfigRoutes;

implementation

uses
  Horse, Horse.Jhonson, Horse.HandleException, DataSet.Serialize, Data.DB,
  System.SysUtils, System.JSON, PessoaService;

procedure Post(Req: THorseRequest; Res: THorseResponse);
var
  jsonObject: TJSONObject;
begin
  jsonObject := TJSONObject.Create;
  try
    jsonObject := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;
    PessoaService.InserirPessoa(jsonObject);
  finally
    jsonObject.Free;
  end;
end;

procedure Delete(Req: THorseRequest; Res: THorseResponse);
var
  id: string;
begin
  if not Req.Params.TryGetValue('id', id) then
    raise Exception.Create('Id da pessoa não informado');

  if PessoaService.DeletarPessoa(id.ToInteger) then
    Res.Status(200)
  else
    Res.Send('Id não encontrado ou já deletado');
end;

procedure Put(Req: THorseRequest; Res: THorseResponse);
var
  id: string;
  jsonArray: TJSONArray;
begin
  jsonArray := TJSONArray.Create;
  try
    if not Req.Params.TryGetValue('id', id) then
      raise Exception.Create('Id da pessoa não informado');

    jsonArray := PessoaService.AtualizarPessoa(id.ToInteger, TJSONObject.ParseJSONValue(Req.Body) as TJSONObject);

    Res.Send(jsonArray.ToString);
  finally
    jsonArray.Free;
  end;
end;

procedure GetById(Req: THorseRequest; Res: THorseResponse);
var
  id: string;
  jsonArray: TJSONArray;
begin
  jsonArray := TJSONArray.Create;
  try
    if not Req.Params.TryGetValue('id', id) then
      raise Exception.Create('Informe o Id da Pessoa');

    jsonArray := PessoaService.ListarPessoas(id.ToInteger);

    Res.Send(jsonArray.ToString);
  finally
    jsonArray.Free;
  end;
end;

procedure GetAll(Req: THorseRequest; Res: THorseResponse);
var
  jsonArray: TJSONArray;
begin
  jsonArray := TJSONArray.Create;
  try
    jsonArray := PessoaService.ListarPessoas;
    Res.Send(jsonArray.ToString);
  finally
    jsonArray.Free;
  end;
end;

procedure PostLote(Req: THorseRequest; Res: THorseResponse);
var
  jsonArray: TJSONArray;
begin
  jsonArray := TJSONArray.Create;
  try
    jsonArray := TJSONArray.ParseJSONValue(Req.Body) as TJSONArray;
    PessoaService.InserirPessoaLote(jsonArray);
  finally
    jsonArray.Free;
  end;
end;

procedure ConfigRoutes;
begin
  THorse.Get('pessoas', GetAll);
  THorse.Get('pessoas/:id', GetById);
  THorse.Post('pessoas', Post);
  THorse.Put('pessoas/:id', Put);
  THorse.Delete('pessoas/:id', Delete);
  THorse.Post('pessoas/lote', PostLote);
end;

end.
