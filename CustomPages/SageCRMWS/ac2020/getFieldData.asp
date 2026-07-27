<!-- #include file ="sagecrm.js" -->
<!-- #include file ="_base_objects.js" -->
<!-- #include file ="helpers.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="configReader.js" -->
<%

//File: getFieldData.asp
//used to load large fields...things like notes and email body data
function readFile(fname){
	var res="";
	var fso = Server.CreateObject("Scripting.FilesystemObject");
	var txt = fso.OpenTextFile(fname, 1, false);
	
	var fileContent = txt.ReadAll();
	txt.Close();

	// Create an ADODB.Stream
	var stream = new ActiveXObject("ADODB.Stream");
	stream.Type = 2; // adTypeText
	stream.Mode = 3; // adModeReadWrite
	stream.Charset = "utf-8";
	stream.Open();

	// Write the content read by FileSystemObject
	stream.WriteText(fileContent);
	stream.Position = 0;

	// Read the content again correctly as UTF-8
	var utf8Content = stream.ReadText(-1); // -1 = adReadAll
	stream.Close();

	// Clean up
	stream = null;	
	txt = null;
	fso = null;
	return utf8Content;
}
function FileExists(path) 
{
	var res=false;
	var myObject = new ActiveXObject("Scripting.FileSystemObject");
	if(myObject.FileExists(path))
	{	
		res=true;
	}
	myObject=null;
	return res;
}
var _entity=new String(Request.QueryString('entity'));
var table=getTableInfo(_entity);
if (!Defined(table.name)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity found, entity is "+Request.QueryString('entity'));
  throw "No valid Entity found";
}
var _entityid=new String(Request.QueryString('entityid'));
if (!isNumeric(_entityid)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity ID found, entityid is "+Request.QueryString('entityid'));
  throw "No valid Entity ID found";
}

var _fieldname=new String(Request.QueryString('field'));
if (!ValidDBColumn(_fieldname))
{
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid fieldname found, _fieldname is "+Request.QueryString('field'));
  throw "No valid fieldname found";
}
//must check context so the user has permission?
if (Defined(_entity)&&(_entity!=""))
{
  var table=getTableInfo(_entity);
  var qEnt=null;
  if (_entity=="communication")
  {
	qEnt=getEntityRecord("comm_link",_entityid);
  }else
	qEnt=getEntityRecord(_entity,_entityid);
  
  if (qEnt.eof){
	throw "Security Violation on Entity:"+_entity+"="+_entityid;	
  }
}
var _resultasjson=new String(Request.QueryString('asjson'));

var _tableinfo=getTableInfo(_entity);
var _qq=null;
if (_entity=="communication")
{
	_qq=CRM.FindRecord("communication,vcommunication","Comm_CommunicationId="+_entityid);
	if (_fieldname.toLowerCase()=="comm_email")
	{
		Response.CodePage = 65001;
        Response.CharSet = "UTF-8";
	}
}else{
	_qq=CRM.FindRecord(_tableinfo.name,"7120=7120 and "+_tableinfo.idfield+"="+_entityid);
}
var res={
  "entity":_entity,
  "entityid":_entityid,
  "fieldname":_fieldname,
  "value":""
};
if (!_qq.eof)
{
	if (_qq.item(_fieldname)!=null)
		res.value=_qq.item(_fieldname);
	if (_fieldname.toLowerCase()=="comm_email")
	{
		// Remove BOM if present..utf 8 code
		if (res.value && res.value.charCodeAt(0) === 239) {
			res.value = res.value.substring(3);
		}
	}	
}
//********************************************
//23 May 24-check the library for a file
//********************************************
if ((_entity=="communication")&&(_fieldname=="comm_email"))
{
	var libsql="select top 1 Libr_FileName,Libr_FilePath from vlibrary where Libr_FileName='email.html' and libr_communicationid="+_qq.item("comm_communicationid");
	var qlib=CRM.CreateQueryObj(libsql);
	qlib.SelectSQL();
	if (!qlib.eof){
		var Libr_FileName=qlib.FieldValue("Libr_FileName");

		var _fullpath=getLibraryRootPath()+qlib.FieldValue("Libr_FilePath")+"\\"+Libr_FileName;

		//get the file
		if (FileExists(_fullpath)){
		  res.value=readFile(_fullpath);  
		}else
		  res.value="File does not exist at: "+_fullpath;
	}
}
//********************************************
//********************************************

// Remove BOM if present..utf 8 code
if (res.value.charCodeAt(0) === 239) {
	res.value = res.value.substring(3);
}											  

//change this 
if (_resultasjson!="y")
{
	Response.ContentType = "text/html;charset=UTF-8";
	res.value=new String(res.value);
	//res.value=res.value.replace(/\n/g, '<br/>');  //removed this 24 oct 24 as it made the comm_emails unreadable
	Response.Write(res.value);
}else{
	res=JSON.stringify(res);
	Response.Write(res);
}

%>