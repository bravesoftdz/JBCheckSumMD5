unit Ucheck;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,IdHashMessageDigest, StdCtrls, pngimage, ExtCtrls, Vcl.WinXCtrls,
  IdBaseComponent, IdAntiFreezeBase, IdAntiFreeze;

type
  TFormVerificadorMd5 = class(TForm)
    editArquivo: TEdit;
    btnSelecionarArquivo: TButton;
    editResult: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    edtComparar: TEdit;
    OpenDialog1: TOpenDialog;
    lblValidor: TLabel;
    Label3: TLabel;
    Image1: TImage;
    lblhash: TLabel;
    shp1: TShape;
    lbl1: TLabel;
    pnlSobre: TPanel;
    mmo1: TMemo;
    btnFechar: TButton;
    actvtyndctr1: TActivityIndicator;
    ToggleSwitch1: TToggleSwitch;
    lblStatus: TLabel;
    IdAntiFreeze1: TIdAntiFreeze;
    procedure btnSelecionarArquivoClick(Sender: TObject);
    procedure edtCompararChange(Sender: TObject);
    procedure edtCompararExit(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure ToggleSwitch1Click(Sender: TObject);
    procedure editArquivoChange(Sender: TObject);
  private
    { Private declarations }
  procedure compare();
  function GerarHashMD5(const fileName : string) : string;

  public
    { Public declarations }


  end;

TMinhaThread = class(TThread)
   private

   protected
     procedure Execute; override;
   public
     constructor Create();
end;

var
  FormVerificadorMd5: TFormVerificadorMd5;

implementation

{$R *.dfm}

constructor TMinhaThread.Create();
begin
  inherited Create(True);

  { Chama o contrutor herdado. Ele ir� temporariamente colocar o
    thread em estado de espera para depois execut�-lo. }
  FreeOnTerminate := True; // Libera da memoria o objeto ap�s terminar.

  { Configura sua prioridade na lista de processos do Sistema operacional. }
  Priority := tpLower;
  //Start; // Inicia o Thread.
end;

procedure TMinhaThread.Execute;
begin
  inherited;
  Try
    FormVerificadorMd5.actvtyndctr1.Animate := True;
    FormVerificadorMd5.editResult.text:= FormVerificadorMd5.GerarHashMD5(
      FormVerificadorMd5.editArquivo.Text);
    FormVerificadorMd5.actvtyndctr1.Animate := False;
    FormVerificadorMd5.lblStatus.Caption := 'Verifica��o finalizada. ';
    FormVerificadorMd5.lblStatus.Refresh;
    Finally
    FormVerificadorMd5.lblStatus.Caption := '';
    FormVerificadorMd5.lblStatus.Refresh;
  End;
end;

procedure TFormVerificadorMd5.btnFecharClick(Sender: TObject);
begin
  pnlSobre.Visible := False;
end;

procedure TFormVerificadorMd5.btnSelecionarArquivoClick(Sender: TObject);
var
  vThread : TMinhaThread;
begin
  editArquivo.Text := '';
  actvtyndctr1.Animate := True;
  lblStatus.Caption := '';
  lblStatus.Refresh;

  if FormVerificadorMd5.OpenDialog1.Execute then
    FormVerificadorMd5.editArquivo.Text := FormVerificadorMd5.OpenDialog1.FileName;

  if FormVerificadorMd5.editArquivo.Text = EmptyStr then
  begin
    Application.MessageBox('O diretorio n�o foi informado ou o arquivo n�o foi selecionado!',
    'Diret�rio vazio', MB_ICONINFORMATION+MB_OK);
    actvtyndctr1.Animate := False;
    Exit;
  end  else
  begin
    if not FileExists(FormVerificadorMd5.editArquivo.Text) then
    begin
      Application.MessageBox('Diretorio Inv�lido',
      'Inv�lido', MB_ICONINFORMATION+MB_OK);
      actvtyndctr1.Animate := False;
      exit;
    end;
  end;

  lblStatus.Caption := 'Arquivo selecionado.';
  lblStatus.Refresh;

  actvtyndctr1.Animate := False;

  lblStatus.Caption := 'Iniciando Verifica��o MD5';
  lblStatus.Refresh;

  vThread := TMinhaThread.Create;
  vThread.Start;
end;

procedure TFormVerificadorMd5.compare;
begin
  if (editArquivo.Text = EmptyStr ) or (edtComparar.Text = EmptyStr) then
    exit
  else
  if UpperCase(Trim(editResult.Text)) = UpperCase(Trim(edtComparar.Text)) then
  begin
    lblValidor.Font.Color:= clGreen;
    lblValidor.Font.Style:= [fsBold];
    lblValidor.Caption   := 'O arquivo est� integro';
  end else
  begin
    lblValidor.Font.Color:= clred;
    lblValidor.Font.Style:= [fsBold];
    lblValidor.Caption   := 'O arquivo n�o est� integro';
  end;

  edtComparar.Text:= UpperCase(edtComparar.Text);
end;

procedure TFormVerificadorMd5.editArquivoChange(Sender: TObject);
var
  vThread : TMinhaThread;
begin
  actvtyndctr1.Animate := True;

  if Trim(FormVerificadorMd5.editArquivo.Text) = EmptyStr then
  begin
    actvtyndctr1.Animate := False;

    Exit;
  end  else
  begin
    if not FileExists(FormVerificadorMd5.editArquivo.Text) then
    begin
      actvtyndctr1.Animate := False;

      exit;
    end;
  end;

  actvtyndctr1.Animate := False;

  vThread := TMinhaThread.Create;
  vThread.Start;
end;

procedure TFormVerificadorMd5.edtCompararChange(Sender: TObject);
begin
  compare;
end;

procedure TFormVerificadorMd5.edtCompararExit(Sender: TObject);
begin
  compare;
end;

procedure TFormVerificadorMd5.Image1Click(Sender: TObject);
begin
  pnlSobre.Visible := True;
end;

function TFormVerificadorMd5.GerarHashMD5(const fileName : string) : string;
var
  idmd5 : TIdHashMessageDigest5;
  fs : TFileStream;
begin
  idmd5 := TIdHashMessageDigest5.Create;

  fs := TFileStream.Create(fileName, fmOpenRead OR fmShareDenyWrite) ;
  try
    result := idmd5.HashStreamAsHex(fs);
  finally
    fs.Free;
    idmd5.Free;
  end;
end;
procedure TFormVerificadorMd5.ToggleSwitch1Click(Sender: TObject);
begin
  if ToggleSwitch1.State =  tssOn then
  begin
    edtComparar.Visible:= true;
    lblhash.Visible := True;
    compare;
  end else
  if ToggleSwitch1.State =  tssOff then
  begin
    edtComparar.Visible  := false;
    lblValidor.Caption   := '';
    lblhash.Visible      := False;
  end;
end;

end.
