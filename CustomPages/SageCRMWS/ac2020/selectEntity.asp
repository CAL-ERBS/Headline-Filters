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

if (!Defined(Request.Form))
{
	//this allows us to test parsing of the data..clever
	Response.Clear();
    Response.Addheader("Content-type", "text/html");
	Response.Write("No POST data found. Do you mean to debug?");
	
	Response.Write('<form method="POST" >');
	Response.Write('<label for="Entity">Entity:</label><br>');
	Response.Write('<input type="text" id="entity" name="entity" value=""><br>');
	Response.Write('<label for="EntityId">EntityId:</label><br>');
	Response.Write('<input type="text" id="entityid" name="entityid" value=""><br>');
	Response.Write('<br><input type="submit" value="Submit">');
	Response.Write('<form>');
	Response.End();
}

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


var entity=Request.Form('entity');
var entityid=Request.Form('entityid');
if (!Defined(entity)||(entity=='')|| !Defined(entityid))
{
  entity="users";
  entityid=getUserId();
}

entity=new String(entity);
var table=getTableInfo(entity);
if (!Defined(table.name)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity found, entity is "+Request.Form('entity'));
  throw "No valid Entity found";
}
if (entity=="address")
{
  //sql injection check here
  entityid=new String(entityid);
  var str_entityidArr=entityid.split(",");
  for (var zx=0;zx<str_entityidArr.length;zx++)
  {
   	var entityidtmp=new Number(str_entityidArr[zx]);
	if (!isNumeric(entityidtmp)){
	  //log to CRM's logs
	  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity ID found, entityid is "+Request.Form('entityid'));
	  throw "No valid Entity ID's found";
	}
  }
}else{	
	entityid=new Number(entityid);
	if (!isNumeric(entityid)){
	  //log to CRM's logs
	  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity ID found, entityid is "+Request.Form('entityid'));
	  throw "No valid Entity ID found";
	}
}
var idfield=table.idfield;
var tableNameView=getTableNameView(entity);

//clever as we work around the db limitations of the "address" data storage
var q=null;
if (entity.toLowerCase()=="address"){
  tableNameView="acTempAddress";
  q=CRM.Findrecord(tableNameView,"9056=9056 and addr_addressid = '"+entityid+"'");
}else{
  q=CRM.Findrecord(tableNameView,"9050=9050 and "+idfield+"="+entityid);
}

if (q.eof)
{
	//remove a bookmark if not found
	var delq=CRM.FindRecord("bookmarks","3370=3370 and book_userid=" + getUserId() + " and book_deleted is null and book_entityname='"+entity+"' and book_entityid="+entityid);
	if (!delq.eof)
	{
		delq.DeleteRecord = true;
		delq.SaveChangesNoTLS();
	}
	Glog("selectentity record not found:"+entity+"="+entityid);
	var fakesectionEntity=JSON.clone(_base_selectEntity);
	fakesectionEntity.screenMetadata.entityName=CRM.GetTrans("Errors","RecNotFoundNoSecuityPermission");
	
	var fakesection=JSON.clone(_section);
	fakesection.title="Cannot find record";
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
} else {
	CONTEXT_RECORD = q;
}

var res=_selectEntity(entity,entityid,q);

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
}

if ((entity.toLowerCase()!="address")&&(entity.toLowerCase()!="library")&&(entity.toLowerCase()!="communication")){
	if ((entity!="communication")&&(entity!="user"))
	{
	  addToSearchHistory(entity,entityid);
	}
}
var GLOBAL_TIMEEND = new Date().getTime();
res.time = GLOBAL_TIMEEND - GLOBAL_TIMESTART;

res=JSON.stringify(res);
Response.Write(res);
%>