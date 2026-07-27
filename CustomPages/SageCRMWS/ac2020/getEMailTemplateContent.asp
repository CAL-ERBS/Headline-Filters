<!-- #include file ="sagecrm.js" -->
<!-- #include file ="_base_objects.js" -->

<!-- #include file ="io.js" -->
<!-- #include file ="helpers.js" -->
<!-- #include file ="mergefunctions.js" -->
<!-- #include file ="selectentity.js" -->
<!-- #include file ="emailtaggen.js" -->
<!-- #include file ="configReader.js" -->
<!-- #include file ="getFormMetadata.js" -->
<%
/*
This file is called when a user selects an email template
*/

function _inlibrary(arr, tofind)
{
	var res=false;
	for(var i = 0; i < arr.length; i++) {
		if (arr[i].actualfilename == tofind) {
			res = true;
			break;
		}
	}
	return res;
}

var emte_id=new String(Request.QueryString('templateid'));
if (!isNumeric(emte_id)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Template ID found, templateid is "+Request.Form('templateid'));
  throw "No valid Template ID found";
}

//get the data
var sql= "select emte_id, emte_name, emte_comm_from, emte_comm_replyto, emte_comm_note, " +
                "emte_comm_email, emte_to, emte_cc, emte_bcc from emailtemplates WITH (NOLOCK) " +
                "where emte_deleted is null and emte_id="+emte_id;
				
var q=CRM.CreateQueryObj(sql);
q.SelectSQL();
var _emailobj={}
if(!q.eof)
{
  _emailobj={
		"entityid": q("emte_id"),
        "name": undefinedToBlank(q("emte_name")),
        "from": undefinedToBlank(q("emte_comm_from")),
        "replyto": undefinedToBlank(q("emte_comm_replyto")),
        "note": undefinedToBlank(q("emte_comm_note")),
        "email": undefinedToBlank(q("emte_comm_email")),
        "to": undefinedToBlank(q("emte_to")),
        "cc": undefinedToBlank(q("emte_cc")),
        "bcc": undefinedToBlank(q("emte_bcc"))
  }
}
var emailTemplateFolder=getLibraryRootPath()+"\\EmailTemplates\\"+emte_id;
var _librarylist=[];
	
//get any document links from the db
var lib_sql="select Libr_LibraryId,Libr_FilePath,Libr_FileName from library where Libr_deleted is null and  Libr_EmailTemplateId="+emte_id;
var libq=CRM.CreateQueryObj(lib_sql);
libq.SelectSQL();
if (!libq.eof)
{

	var fnamearr=[];
	while(!libq.eof)
	{
		var Libr_FileName=new String(libq("Libr_FileName"));
		Libr_FileName=Libr_FileName.substr(1);//remove the A (attachment) or I (image embedded) in front of the document	  
		fnamearr.push(libq("Libr_FileName"));
		var __link=getCRMProtocol()+get_SERVER_NAME()
					+":"+get_SERVER_PORT()+
					CRM.Url("sagecrmws/ac2020/getLibraryDocument.asp");
        if (isPortalRequest) {
			__link+="?77=77&id="+libq("Libr_LibraryId");
		}else{
			__link+="&id="+libq("Libr_LibraryId");
		}		
		_libobj={
			"entityid": libq("Libr_LibraryId"),
			"actualfilename": libq("Libr_FileName"),	
			"filename": Libr_FileName,
			"fromdb":true,
			"link": __link
		}
		//check file is not an embedded image
		if (isEmbeddedImage(Libr_FileName,_emailobj.email))
		{
			var _fullpath=getLibraryRootPath()+libq("Libr_FilePath")+"\\"+libq("Libr_FileName");
			_emailobj.email=_emailobj.email.replace("src=\""+Libr_FileName+"\"",
			"src=\""+convertImageToBase64(_fullpath)+"\"");
		}else{
			_librarylist.push(_libobj);
		}
		libq.NextRecord();
	}

}
/////
//check for any OLD templates -this is an odd thing in CRM..not in the db..but sometimes are
var fs = Server.CreateObject("Scripting.FileSystemObject");
var emailTemplateFolderExists = fs.FolderExists(emailTemplateFolder);
if (emailTemplateFolderExists)
{
	emailTemplateFolder=getLibraryRootPath()+"\\EmailTemplates\\"+emte_id;
	emailTemplateFolder=emailTemplateFolder.replace(/\\\\/g,"\\");	
	if (emailTemplateFolder.indexOf("\\")==0)
	{
	  //unc path?..we need  to put back in a backslash
	  emailTemplateFolder="\\"+emailTemplateFolder;
	}
	var Folder = fs.GetFolder(emailTemplateFolder);
	var FileCollection = Folder.Files;
	var foundFile="";
	//loop through the folder
	for(var objEnum = new Enumerator(FileCollection); !objEnum.atEnd(); objEnum.moveNext()) {
	 var strFileName = objEnum.item();
	 foundFile=strFileName.name;
	 var _crm_version=new String(getSysParam("version"));
	var __link=getCRMProtocol()+get_SERVER_NAME()
					+":"+get_SERVER_PORT()+
					CRM.Url("sagecrmws/ac2020/getLibraryDocument.asp");
	if (isPortalRequest) {
		__link+="?78=78&id=0&fname=\\EmailTemplates\\"+emte_id+"\\"+foundFile;
	}else{
		__link+="&id=0&fname=\\EmailTemplates\\"+emte_id+"\\"+foundFile;
	}			 
	 if (foundFile!="")
	 {
		var _libobj2={
			"entityid": 0,
			"actualfilename": foundFile,	
			"filename": foundFile.substr(1),
			"fromdb":false,
			"link": __link
		}
		if (!_inlibrary(_librarylist, foundFile))
			_librarylist.push(_libobj2);	
	 }
	}
}
/////

var entity=Request.QueryString('entity');
var entityres={};
var tableNameView='';
if (entity+""!="undefined")
{
	entity=new String(entity);
	var table=getTableInfo(entity);   
	var entityid=Request.QueryString('entityid');
	entityid=new String(entityid);
	//get the data
	entity=entity.toLowerCase();
	if (entity=="cases")
	  entity="case";
	tableNameView=entity+",vsummary"+entity;
	if ((entity=="solutions")||(entity=="solution")){
		tableNameView="solutions";//there is no vsummarysolution(s)!!!
	}else
	if (entity=="orders"){
		tableNameView=entity+",vsummaryorder";
	}else
	if (entity=="quotes"){
		tableNameView=entity+",vsummaryquote";
	}	
	var _msql="8010=8010 and "+table.prefix+"_deleted is null and "+table.idfield+"="+entityid;
	var q=CRM.Findrecord(tableNameView,_msql);
	entityres=_selectEntity(entity,entityid,q);
	
	//merge the data now also!! to do !!!!!!!!!!!!!!!!!!!!!!!!!!!!
	hashFields = getHashFields(_emailobj.note);
	_emailobj.note  = doMerge(_emailobj.note, hashFields, q, table.prefix + "_", entity);	
	hashFields = getHashFields(_emailobj.note);
	_emailobj.note  = doMerge(_emailobj.note, hashFields, q, "pers_", "person");		
	hashFields = getHashFields(_emailobj.note);
	_emailobj.note  = doMerge(_emailobj.note, hashFields, q, "comp_", "company");	
	hashFields = getHashFields(_emailobj.note);
	_emailobj.note  = doMerge(_emailobj.note, hashFields, q, "addr_", "address");	
	hashFields = getHashFields(_emailobj.note);
	_emailobj.note  = doMerge(_emailobj.note, hashFields, q, "adli_", "address_link");	
	
	hashFields = getHashFields(_emailobj.email);
	_emailobj.email = doMerge(_emailobj.email, hashFields, q, table.prefix + "_", entity);		
	hashFields = getHashFields(_emailobj.email);
	_emailobj.email = doMerge(_emailobj.email, hashFields, q, "pers_", "person");	
	hashFields = getHashFields(_emailobj.email);
	_emailobj.email = doMerge(_emailobj.email, hashFields, q, "comp_", "company");	

	hashFields = getHashFields(_emailobj.email);
	_emailobj.email = doMerge(_emailobj.email, hashFields, q, "addr_", "address");	
	hashFields = getHashFields(_emailobj.email);
	_emailobj.email = doMerge(_emailobj.email, hashFields, q, "adli_", "address_link");		
	
}

//merge user data
var user = CRM.FindRecord("Users", "4710=4710 and User_userid="  + CRM.GetContextInfo("user", "user_userid"));
hashFields = getHashFields(_emailobj.note);
_emailobj.note = doMerge(_emailobj.note, hashFields, user, 'user_','user');
hashFields = getHashFields(_emailobj.email);
_emailobj.email = doMerge(_emailobj.email, hashFields, user, 'user_','user');

var res={
  "screenMetadata": { 
	"emailTemplateFolder":emailTemplateFolder,
	"email_sql":sql,
	"lib_sql":lib_sql
  },
  "data": {
    "entity": entityres,
    "emailtemplate": _emailobj,
	"documentlinks":_librarylist,
	"viewused": tableNameView,
	"entityid":entityid
  }
}
res=JSON.stringify(res);
Response.Write(res);
%>