<!-- #include file ="sagecrm.js" -->

<!-- #include file ="_base_objects.js" -->
<!-- #include file ="helpers.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="configReader.js" -->
<%
//////////////////////////////////////////////
//SageCRMWS\ac2020\getLibraryDocument.asp
//////////////////////////////////////////////
function streamFile(_fullpath, filename)
{
	//get the file
	Response.Buffer = false;
	var objStream = Server.CreateObject("ADODB.Stream");
	objStream.Type = 1;//adTypeBinary
	objStream.Open();
	objStream.LoadFromFile(_fullpath);
	Response.ContentType = "application/x-unknown";
	Response.Addheader("Content-Disposition", "attachment; filename=" + filename);
	Response.BinaryWrite(objStream.Read());
	objStream.Close();
	objStream = null;
}

//used to get library documents

var documentid=new String(Request.QueryString('id'));
if (!isNumeric(documentid)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity ID found, documentid is "+Request.Form('id'));
  throw "No valid documentid found";
}

//clever handling of crm's weird old style template storage
if (documentid==0)
{
  var _fullpath2=getLibraryRootPath()+Request.QueryString('fname');
  var myObject = new ActiveXObject("Scripting.FileSystemObject");
  var onlyFilename = myObject.GetFileName(_fullpath2);
  onlyFilename=onlyFilename.substr(1);
  streamFile(_fullpath2,onlyFilename);
  Response.End();
}
var entity=new String(Request.QueryString('entity'));
if (!Defined(entity))
  entity="";
if (Defined(entity) &&(entity!=""))
{  
	var testtable=getTableInfo(entity);  
	if ((entity!="")&&(!Defined(testtable.name))){
	  //log to CRM's logs
	  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity found, entity is "+Request.Form('entity'));
	  throw "No valid Entity found";
	}  
}
var entityid=new String(Request.QueryString('entityid'));
if (Defined(entityid) &&(entityid!=""))
{
	if (!isNumeric(entityid)){
	  //log to CRM's logs
	  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity ID found, entityid is "+Request.Form('entityid'));
	  throw "No valid Entity ID found";
	}
}

//get the document record
var libsql="select top 1 * from vlibrary where libr_libraryid="+documentid;
var qlib=CRM.CreateQueryObj(libsql);
qlib.SelectSQL();

//must check context so the user has permission?
if (Defined(entity)&&(entity!=""))
{
  var table=getTableInfo(entity);
  var qEnt=getEntityRecord(entity,entityid);
  if (qEnt.eof)
    throw "Security Violation on Entity";
}else{
  //check its in an email template OR a global document
  if ((qlib("Libr_EmailTemplateId")==null) && 
	((qlib("Libr_Global")!="Y")&&(qlib("Libr_Active")!="Y")))
  {
		throw "Security Violation";
  }
}
var Libr_FileName=qlib("Libr_FileName");

var _fullpath=getLibraryRootPath()+qlib("Libr_FilePath")+"\\"+Libr_FileName;
//Response.Write(_fullpath);

//get the file
streamFile(_fullpath,Libr_FileName);

%>