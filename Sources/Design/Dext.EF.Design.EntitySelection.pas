unit Dext.EF.Design.EntitySelection;

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.Controls,
  Vcl.ExtCtrls;

type
  TEntitySelectionForm = class(TForm)
  private
    FEditSearch: TEdit;
    FListBoxEntities: TListBox;
    FBtnOK: TButton;
    FBtnCancel: TButton;
    FPanelBottom: TPanel;
    FAllEntities: TArray<string>;
    procedure EditSearchChange(Sender: TObject);
    procedure ListBoxEntitiesDblClick(Sender: TObject);
    procedure FilterEntities;
  public
    constructor Create(AOwner: TComponent; const AEntities: TArray<string>); reintroduce;
    function SelectedEntity: string;
  end;

function SelectEntity(const AEntities: TArray<string>; var ASelectedValue: string): Boolean;

implementation

function SelectEntity(const AEntities: TArray<string>; var ASelectedValue: string): Boolean;
var
  Form: TEntitySelectionForm;
begin
  Form := TEntitySelectionForm.Create(nil, AEntities);
  try
    if ASelectedValue <> '' then
      Form.FListBoxEntities.ItemIndex := Form.FListBoxEntities.Items.IndexOf(ASelectedValue);
      
    Result := Form.ShowModal = mrOk;
    if Result then
      ASelectedValue := Form.SelectedEntity;
  finally
    Form.Free;
  end;
end;

{ TEntitySelectionForm }

constructor TEntitySelectionForm.Create(AOwner: TComponent; const AEntities: TArray<string>);
begin
  inherited CreateNew(AOwner);
  FAllEntities := AEntities;
  
  Caption := 'Select Entity';
  Width := 400;
  Height := 500;
  Position := poScreenCenter;
  Constraints.MinWidth := 300;
  Constraints.MinHeight := 400;

  FEditSearch := TEdit.Create(Self);
  FEditSearch.Parent := Self;
  FEditSearch.Align := alTop;
  FEditSearch.Margins.Left := 8;
  FEditSearch.Margins.Top := 8;
  FEditSearch.Margins.Right := 8;
  FEditSearch.Margins.Bottom := 4;
  FEditSearch.AlignWithMargins := True;
  FEditSearch.OnChange := EditSearchChange;
  FEditSearch.TextHint := 'Search entity name...';

  FListBoxEntities := TListBox.Create(Self);
  FListBoxEntities.Parent := Self;
  FListBoxEntities.Align := alClient;
  FListBoxEntities.Margins.Left := 8;
  FListBoxEntities.Margins.Right := 8;
  FListBoxEntities.AlignWithMargins := True;
  FListBoxEntities.OnDblClick := ListBoxEntitiesDblClick;

  FPanelBottom := TPanel.Create(Self);
  FPanelBottom.Parent := Self;
  FPanelBottom.Align := alBottom;
  FPanelBottom.Height := 50;
  FPanelBottom.BevelOuter := bvNone;

  FBtnCancel := TButton.Create(Self);
  FBtnCancel.Parent := FPanelBottom;
  FBtnCancel.Caption := 'Cancel';
  FBtnCancel.ModalResult := mrCancel;
  FBtnCancel.Width := 85;
  FBtnCancel.Height := 30;
  FBtnCancel.Top := 10;
  FBtnCancel.Left := FPanelBottom.Width - FBtnCancel.Width - 10;
  FBtnCancel.Anchors := [akRight, akTop];

  FBtnOK := TButton.Create(Self);
  FBtnOK.Parent := FPanelBottom;
  FBtnOK.Caption := 'OK';
  FBtnOK.ModalResult := mrOk;
  FBtnOK.Default := True;
  FBtnOK.Width := 85;
  FBtnOK.Height := 30;
  FBtnOK.Top := 10;
  FBtnOK.Left := FBtnCancel.Left - FBtnOK.Width - 8;
  FBtnOK.Anchors := [akRight, akTop];

  FilterEntities;
end;

procedure TEntitySelectionForm.EditSearchChange(Sender: TObject);
begin
  FilterEntities;
end;

procedure TEntitySelectionForm.FilterEntities;
var
  Search: string;
  E: string;
begin
  Search := string
  (FEditSearch.Text).Trim.ToLower;
  FListBoxEntities.Items.BeginUpdate;
  try
    FListBoxEntities.Items.Clear;
    for E in FAllEntities do
    begin
      if (Search = '') or E.ToLower.Contains(Search) then
        FListBoxEntities.Items.Add(E);
    end;
  finally
    FListBoxEntities.Items.EndUpdate;
  end;
end;

procedure TEntitySelectionForm.ListBoxEntitiesDblClick(Sender: TObject);
begin
  if FListBoxEntities.ItemIndex >= 0 then
    ModalResult := mrOk;
end;

function TEntitySelectionForm.SelectedEntity: string;
begin
  if FListBoxEntities.ItemIndex >= 0 then
    Result := FListBoxEntities.Items[FListBoxEntities.ItemIndex]
  else
    Result := '';
end;

end.
