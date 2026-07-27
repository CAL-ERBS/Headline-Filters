<!-- #include file ="sagecrm.js" -->
<!-- #include file ="configreader.js" -->
<!-- #include file ="helpers.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="_base_objects.js" -->
<!-- #include file ="selectentity.js" -->
<!-- #include file ="emailtaggen.js" -->
<!-- #include file ="SearchHistory.js" -->
<!-- #include file ="getFormMetadata.js" -->
<!-- #include file ="mergefunctions.js" -->
<%
//selectComm.asp ...used to select communication emails

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

var entity=new String("communication");
var entityid=Request.QueryString('entityid');
entity=new String(entity);
var table=getTableInfo(entity);
if (!Defined(table.name)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity found, entity is communication");
  throw "No valid Entity found";
}
  
entityid=new Number(entityid);
if (!isNumeric(entityid)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity ID found, entityid is "+Request.QueryString('entityid'));
  throw "No valid Entity ID found";
}

var idfield=table.idfield;

var q=CRM.Findrecord("communication,vcommunication","90566=90566 and "+idfield+"="+entityid);
var isEmailComm=false;
if ((q.item("Comm_Action")=="EmailOut")||(q.item("Comm_Action")=="EmailIn"))
{
	isEmailComm=true;
}
if (q.eof)
{
	Glog("selectentity record not found:"+entity+"="+entityid);
	var fakesectionEntity=JSON.clone(_base_selectEntity);
	fakesectionEntity.screenMetadata.entityName=CRM.GetTrans("Errors","RecNotFoundNoSecuityPermission");
	
	var fakesection=JSON.clone(_section);
	fakesection.title="Cannot find communication record";
	fakesection.name="unknown";
	fakesection.closed=false;
	var _fakesectionitem=JSON.clone(_SectionDataItem);	
	_fakesectionitem.name="fake";
	_fakesectionitem.value="";
	_fakesectionitem.displayvalue="Check your data in full CRM";
	_fakesectionitem.caption="WARNING";	
	fakesectionEntity.screenMetadata.errormessage="Seach on '"+tableNameView+"' where "+table.idfield+"="+entityid;
	fakesection.data.push(_fakesectionitem);	 
	fakesectionEntity.data[0].sections[0]=fakesection;
	
	res=JSON.stringify(fakesectionEntity);
	Response.Write(res);
	Response.End();
}
///DEV NOTE...
var res=_selectEntity(entity,entityid,q,false,true);

if (res.data[0].sections[0]==null)
{
	var fakesection=JSON.clone(_section);
	fakesection.title="Missing Screen";
	fakesection.name="unknown";
	fakesection.closed=false;
	var _fakesectionitem=JSON.clone(_SectionDataItem);	
	_fakesectionitem.name="fake";
	_fakesectionitem.value="";
	_fakesectionitem.displayvalue="Create the screen in CRM to see the data";
	_fakesectionitem.caption="Missing screen "+entity+"OfficeInt";	
	fakesection.data.push(_fakesectionitem);	 
	res.data[0].sections[0]=fakesection;
}else{
	//get any library/attachments
	var	_librsql= "select libr_libraryid,Libr_Type, Libr_Category, Libr_FilePath, Libr_FileName, " +
			" SUBSTRING(Libr_Note,1, 200) as Libr_Note, Libr_Status  " +
			"from library WITH (NOLOCK) where libr_communicationid="+entityid+" and  " +
			"libr_deleted is null";
		_librsql+=" ORDER BY libr_libraryid";	
				
	var libq=CRM.CreateQueryObj(_librsql);
	libq.SelectSQL();
	var recordcount=libq.recordcount;
	var tableData=[];

	var rowCount=0;
	while(!libq.eof)
	{
		_tmpobj={
			"entityid": libq.FieldValue("libr_libraryid"),
			"type": CRM.GetTrans("Libr_Type",libq.FieldValue("Libr_Type")),
			"category": CRM.GetTrans("Libr_Category",libq.FieldValue("Libr_Category")),
			"filepath": libq.FieldValue("Libr_FilePath"),
			"filename": libq.FieldValue("Libr_FileName"),
			"note": libq.FieldValue("Libr_Note"),
			"status": CRM.GetTrans("Libr_Status",libq.FieldValue("Libr_Status")),
			"selected":false,			
			"link": getCRMProtocol()+get_SERVER_NAME()
					+":"+get_SERVER_PORT()+
					CRM.Url("sagecrmws/ac2020/getLibraryDocument.asp")+isportalcode()+"id="+libq.FieldValue("Libr_LibraryId")
		}
		tableData.push(_tmpobj);	 
		libq.NextRecord();
	}
    var atttableColumns= [
      {
        "value": "filename",
        "text": CRM.GetTrans("colnames","libr_filename")
      },{
        "value": "note",
        "text": CRM.GetTrans("colnames","Libr_Note")
      },
	  {
		"value": "__Select__",
		"text": "",
		"sortable": false
	  }
    ]	
	res.data[0].sections[0].attachments={};
	res.data[0].sections[0].attachments.tableData=tableData;
	res.data[0].sections[0].attachments.tableColumns=atttableColumns;
	res.data[0].sections[0].attachmentsCount=recordcount;
}

//check for external attendees
	var	_extsql= "select comp_name, Pers_FullName, cmli_recipient,CmLi_CommLinkId "+
					"from vExternalAttendees where 987=987 and CmLi_Comm_CommunicationId="+entityid+" order by Pers_FirstName,Pers_LastName";
				
	var extq=CRM.CreateQueryObj(_extsql);
	extq.SelectSQL();
	var extRecordcount=extq.recordcount;
	var extqtableData=[];

	var rowCount=0;
	while(!extq.eof)
	{
		_tmpobj={
			"entityid": extq.FieldValue("CmLi_CommLinkId"),
			"pers_fullname": extq.FieldValue("Pers_FullName"),
			"cmli_recipient": extq.FieldValue("cmli_recipient"),
			"comp_name": extq.FieldValue("comp_name")
		}
		extqtableData.push(_tmpobj);	 
		extq.NextRecord();
	}
    var externalAttendeesColumns= [
      {
        "value": "pers_fullname",
        "text": CRM.GetTrans("colnames","pers_fullname")
      },{
        "value": "cmli_recipient",
        "text": CRM.GetTrans("colnames","cmli_recipient")
      },{
        "value": "comp_name",
        "text": CRM.GetTrans("colnames","comp_name")
      },
	  {
		"value": "__Select__",
		"text": "",
		"sortable": false
	  }
    ]	
	res.data[0].sections[0].externalAttendees={};
	res.data[0].sections[0].externalAttendees.tableData=extqtableData;
	res.data[0].sections[0].externalAttendees.tableColumns=externalAttendeesColumns;
	res.data[0].sections[0].externalAttendeesCount=extqtableData.length;
	
	res.screenMetadata.showHeader=true;//used to show the header in the dialog

var GLOBAL_TIMEEND = new Date().getTime();
res.time = GLOBAL_TIMEEND - GLOBAL_TIMESTART;

res=JSON.stringify(res);
Response.Addheader("Content-type", "application/json");
Response.Write(res);
%>