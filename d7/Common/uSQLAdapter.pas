unit uSQLAdapter;

interface

uses
   Windows, Classes, SysUtils, ExtCtrls, Db, DbTables, iniFiles;

type
   TColumnType = ( ct_string, ct_integer );
   TQueryResult = ( rt_none, rt_end, rt_next, rt_error );

   TSQLAdapter = class
   private
      FboSessionAlive : Boolean;
      
      FDataSourceName : String;
      FAliasName : String;
      FUserName : String;
      FPassword : String;

      FDatabase : TDatabase;
      FQuery : TQuery;

      RecordPos : Integer;
      FieldList : TStringList;
      RecordList : TStringList;

      timerCheck : TTimer;

      procedure timerCheckTimer (Sender : TObject);
   public
      constructor Create;
      destructor Destroy; override;

      function Init (aDSN, aAlias, aUser, aPass : String) : Boolean;
      function InitByIni (aFileName : String) : Boolean;

      function SimpleSelect (aTableName : String; aFieldList : TStringList; aKeyType : TColumnType; aKeyName : String; aKeyValue : String) : Integer;
      function GetQueryResult (var aQueryResult : TQueryResult) : String;

      property SessionAlive : Boolean read FboSessionAlive;
   end;

var
   SQLAdapter : TSQLAdapter;

implementation

constructor TSQLAdapter.Create;
begin
   FboSessionAlive := false;
   
   FDataSourceName := '';
   FAliasName := '';
   FUserName := '';
   FPassword := '';

   RecordPos := -1;

   FieldList := TStringList.Create;
   RecordList := TStringList.Create;

   FDatabase := TDatabase.Create (nil);
   FQuery := TQuery.Create (nil);

   timerCheck := TTimer.Create (nil);
   timerCheck.OnTimer := timerCheckTimer;
   timerCheck.Interval := 1000;
end;

destructor TSQLAdapter.Destroy;
begin
   timerCheck.Enabled := false;
   timerCheck.Free;

   FQuery.Free;
   FDatabase.Free;

   FieldList.Clear;
   FieldList.Free;

   RecordList.Clear;
   RecordList.Free;

   inherited Destroy;
end;

procedure TSQLAdapter.timerCheckTimer (Sender : TObject);
var
   Str : String;
begin
   timerCheck.Interval := 1000 * 60 * 10;

   if FDataSourceName = '' then exit;
   
   FQuery.Close;
   FQuery.SQL.Clear;

   try
      Str := 'SELECT GetDate() ';
      FQuery.SQL.Add (Str);
      FQuery.Open;
   except
      FboSessionAlive := false;
      exit;
   end;

   FboSessionAlive := true;
end;

function TSQLAdapter.Init (aDSN, aAlias, aUser, aPass : String) : Boolean;
begin
   Result := false;
   
   FDataSourceName := aDSN;
   FAliasName := aAlias;
   FUserName := aUser;
   FPassword := aPass;

   FDatabase.DataBaseName := FDataSourceName;
   FDatabase.AliasName := FAliasName;
   if FUserName <> '' then begin
      FDatabase.Params.Add ('USER NAME=' + FUserName);
      FDatabase.Params.Add ('PASSWORD=' + FPassword);
      FDatabase.LoginPrompt := False;
   end else begin
      FDatabase.LoginPrompt := True;
   end;

   try
      FDataBase.Connected := true;
   except
      exit;
   end;

   FQuery.DataBaseName := FDataSourceName;

   timerCheck.Enabled := true;
   timerCheckTimer (nil);

   Result := true;
end;

function TSQLAdapter.InitByIni (aFileName : String) : Boolean;
var
   DSN, Alias, User, Pass : String;
   iniFile : TIniFile;
begin
   Result := false;
   
   if not FileExists (aFileName) then exit;
   
   iniFile := TIniFile.Create (aFileName);
   DSN := iniFile.ReadString ('ODBC', 'DataSourceName', '');
   Alias := iniFile.ReadString ('ODBC', 'AliasName', '');
   User := iniFile.ReadString ('ODBC', 'UserName', '');
   Pass := iniFile.ReadString ('ODBC', 'Password', '');
   iniFile.Free;

   if DSN = '' then exit;

   Result := Init (DSN, Alias, User, Pass);
end;

function TSQLAdapter.SimpleSelect (aTableName : String; aFieldList : TStringList; aKeyType : TColumnType; aKeyName : String; aKeyValue : String) : Integer;
var
   i, iCount : Integer;
   Str, RecordStr : String;
begin
   Result := 0;

   FQuery.Close;
   FQuery.SQL.Clear;

   RecordPos := -1;
   FieldList.Clear;
   RecordList.Clear;

   Str := 'SELECT ';
   for i := 0 to aFieldList.Count - 1 do begin
      Str := Str + aFieldList.Strings [i];
      if i < aFieldList.Count - 1 then begin
         Str := Str + ', ';
      end else begin
         Str := Str + ' ';
      end;
   end;
   Str := Str + ' FROM ' + aTableName;
   if aKeyType = ct_string then begin
      Str := Str + ' WHERE ' + aKeyName + ' = ''' + aKeyValue + '''';
   end else if aKeyType = ct_integer then begin
      Str := Str + ' WHERE ' + aKeyName + ' = ' + aKeyValue;
   end;

   try
      FQuery.SQL.Add(Str);
      FQuery.Open;
   except
      Result := -1;
      exit;
   end;

   RecordPos := 0;

   if FQuery.RecordCount = 0 then exit;

   FQuery.First;

   while not (FQuery.Eof) do begin
      RecordStr := '';
      for i := 0 to FQuery.Fields.Count - 1 do begin
         RecordStr := RecordStr + FQuery.Fields[i].AsString;
         if i < FQuery.Fields.Count - 1 then RecordStr := RecordStr + ',';
      end;
      RecordList.Add (RecordStr);
      FQuery.Next;
   end;

   Result := RecordList.Count;
end;

function TSQLAdapter.GetQueryResult (var aQueryResult : TQueryResult) : String;
begin
   Result := '';

   if RecordPos = -1 then begin
      aQueryResult := rt_error;
   end;
   if (RecordPos = 0) and (RecordList.Count = 0) then begin
      aQueryResult := rt_none;
      exit;
   end;

   Result := RecordList.Strings [RecordPos];

   if RecordPos < RecordList.Count then begin
      aQueryResult := rt_next;
      Inc (RecordPos);
   end else begin
      RecordList.Clear;
      aQueryResult := rt_end;
      RecordPos := -1;
   end;
end;

end.
