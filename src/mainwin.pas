{
  Copyright 2011 Heiko Adams

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
}

unit mainwin;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, EditBtn,
  StdCtrls, Buttons;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    btnClose: TBitBtn;
    btnStart: TBitBtn;
    cbxFilter: TComboBox;
    edtPath: TDirectoryEdit;
    edtName: TEdit;
    lblPath: TLabel;
    lblFilter: TLabel;
    lblName: TLabel;
    procedure btnStartClick(Sender: TObject);
  private
    { private declarations }
    procedure BuildFileList(const aDir, aExt: string; var aList: TStringList);
  public
    { public declarations }
  end; 

var
  frmMain: TfrmMain;

implementation

uses LCLType;

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.BuildFileList(const aDir, aExt: string; var aList: TStringList);
var
  SearchRec: TSearchRec;
  sPath: string;
begin
  sPath := IncludeTrailingPathDelimiter(aDir);

  if (RightStr(sPath, 1) = '.') then
    Exit
  else
  begin
    if FindFirst(sPath + AllFilesMask, faAnyFile - faDirectory, SearchRec) = 0 then
    begin
      repeat
        if UpperCase(ExtractFileExt(sPath + SearchRec.Name)) = UpperCase(aExt) then
          aList.Add(sPath + SearchRec.Name);
      until FindNext(SearchRec) <> 0;

      aList.Sort;
    end;

    FindClose(SearchRec);
  end;

  if FindFirst(sPath + AllFilesMask, faDirectory, SearchRec) = 0 then
   try
     repeat
      if ((SearchRec.Attr and faDirectory) <> 0)  and (SearchRec.Name<>'.') and (SearchRec.Name<>'..') then
       BuildFileList(sPath + SearchRec.Name, aExt, aList);
     until FindNext(SearchRec) <> 0;
   finally
     FindClose(SearchRec);
   end;
end;

procedure TfrmMain.btnStartClick(Sender: TObject);
var
  sPath: string;
  sExtension: string;
  Files: TStringList;
  nCounter: Integer;
  List: TextFile;
  bAbort: boolean;
begin
  bAbort := (Trim(edtName.Text) = EmptyStr) or
    (Trim(edtPath.Text) = EmptyStr);

  if (Trim(edtName.Text) = EmptyStr) then
    edtName.SetFocus
  else if (Trim(edtPath.Text) = EmptyStr) then
    edtPath.SetFocus;

  if bAbort then
  begin
    Application.MessageBox('Bitte verfollständigen Sie die benötigten Angaben',
      'Unzureichende Angaben', MB_ICONERROR or MB_OK);
    Abort;
  end;

  Screen.Cursor := crHourGlass;
  Application.ProcessMessages;

  sPath := IncludeTrailingPathDelimiter(edtPath.Text);
  sExtension := cbxFilter.Items[cbxFilter.ItemIndex];
  Delete(sExtension, 1, 1);
  Files := TStringList.Create;

  BuildFileList(sPath, sExtension, Files);

  AssignFile(List, sPath + edtName.Text);
  Rewrite(List);
  WriteLn(List, '# xfce backdrop list');

  for nCounter :=0 to Files.Count -1 do
    WriteLn(List, Files.Strings[nCounter]);

  CloseFile(List);
  Screen.Cursor := crDefault;
  Application.ProcessMessages;
end;

end.

