<!-- #include file ="sagecrm.js" -->
<!-- #include file ="_base_objects.js" -->

<!-- #include file ="helpers.js" -->
<!-- #include file ="globalsearch.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="fileemailSearch_utils.js" -->
<!-- #include file ="selectentity.js" -->
<!-- #include file ="emailtaggen.js" -->
<!-- #include file ="getFormMetadata.js" -->
<!-- #include file ="configReader.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="SearchHistory.js" -->
<!-- #include file ="createCompany.asp" -->
<%
Glog("file:filesentemail.asp");
var testurl=CRM.Url("sagecrmws/ac2020/fileemailsearch.asp");
Glog(testurl);
var filesentemaildbgmore=false;
if (!Defined(Request.Form))
{
	//this allows us to test parsing of the data..clever
	Response.Clear();
    Response.Addheader("Content-type", "text/html");
	Response.Write("No POST data found. Do you mean to debug?");
	
	Response.Write('<form method="POST" >');
	Response.Write('<label for="emaildata">emaildata:</label><br>');
	Response.Write('<textarea id="emaildata" name="emaildata" rows="20" cols="75">');
	Response.Write('</textarea><br>');
	Response.Write('<label for="Entity">Entity:</label><br>');
	Response.Write('<input type="text" id="Entity" name="Entity" value=""><br>');
	Response.Write('<label for="EntityId">EntityId:</label><br>');
	Response.Write('<input type="text" id="EntityId" name="EntityId" value=""><br>');
	Response.Write('<br><input type="submit" value="Submit">');
	Response.Write('<form>');
	
	Response.Write('<br><br><a href="'+testurl+'" >This url</a>');
	Response.End();
	//sample url
	//"http://win-qb6s2mb2d3i//CRM2021r1/CustomPages/sagecrmws/ac2020/filesentemail.asp?SID=164606665648145"
}
function boolSaveCommEmailToFile(){
  var val=GetWebConfigValue("SaveCommEmailToFile");
  var res=false;
  if (val=="Y")
    res=true;
  return res;
}

function boolParseEmailToText(){
  var val=GetWebConfigValue("ParseEmailToTextColumn");
  var res=false;
  if ((val!=null)&&(val!="")&&(val.length>6))
    res=true;
  return res;
}
function parseEmailToTextColumnName(){
  var val=GetWebConfigValue("ParseEmailToTextColumn");
  return new String(val);
}				   

function custom_escape(val)
{
  val=new String(val);
  val =val.replace(/</g, "%3C");
  val =val.replace(/>/g, "%3E");
  val =val.replace(/"/g, "%22");
  val =val.replace(/'/g, "%27");
  val =val.replace(/&/g, "%26");
  val =val.replace(/\+/g, "%2B");
  return val;
}

function getEmailDataEntity(EmaildataObj)
{
	Glog("getEmailDataEntity");
	var res={
		entity:"",
		entityid:""
	}
	var searchEmail=EmaildataObj.from.emailAddress;
	if (EmaildataObj.sentItem)
	{
		if (EmaildataObj.to.length>0)
			searchEmail=EmaildataObj.to[0].emailAddress;
		else if (EmaildataObj.cc.length>0)
			searchEmail=EmaildataObj.cc[0].emailAddress;
		else 
			searchEmail="noemail@noemail.com";
	}
	if ((searchEmail==null)||(searchEmail==""))
	  searchEmail="__NODATA__";
	var q=findPersonByEmail(searchEmail);
	if (EmaildataObj.to.length>0)
		Glog("getEmailDataEntity emailAddress:"+EmaildataObj.to[0].emailAddress);
	else
		Glog("getEmailDataEntity emailAddress: NO TO EMAIL");
	if (q.RecordCount>0)
	{
		Glog("getEmailDataEntity person");
		res.entity="person";
		res.entityid=q("pers_personid");
	}else{
		var q=findCompanyByEmail(searchEmail);
		if (q.RecordCount>0)
		{
			Glog("getEmailDataEntity company");
			res.entity="company";
			res.entityid=q("comp_companyid");
		}else{
			var q=findLeadByEmailExact(searchEmail);
			if (q.RecordCount>0)
			{	
				Glog("getEmailDataEntity lead");
				res.entity="lead";
				res.entityid=q("lead_leadid");
			}else{
				Glog("getEmailDataEntity user");
				res.entity="user";
				res.entityid=getUserId();
			}
		}
	}
	return res;
}

function getCompanyFolder(companyid)
{
	var res="";
	if ((companyid=="")||(!Defined(companyid)))
	  return res;
	  
	if (!isNumeric(companyid)){
	  //log to CRM's logs
	  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")-getCompanyFolder-No valid Company ID found, companyid is "+companyid);
	  throw "No valid Company ID found";
	}
	
	var _sql="select comp_librarydir from company where comp_companyid="+companyid;
	var q=CRM.CreateQueryObj(_sql);
	q.SelectSQL();
	if (!q.eof)
	{
		res=q("comp_librarydir");
	}
	if (!Defined(res))
	{
		//fix up?
		res=createLibrary2(companyid);
	}
	return res;
}

function getPersonFolder(personid)
{
	var res="";
	if ((personid=="")||(!Defined(personid)))
	  return res;
	  
	if (!isNumeric(personid)){
	  //log to CRM's logs
	  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")-getPersonFolder	-No valid Person ID found, personid is "+personid);
	  throw "No valid Person ID found";
	}
	  
	var _sql="select pers_librarydir from person where pers_personid="+personid;
	var q=CRM.CreateQueryObj(_sql);
	q.SelectSQL();
	if (!q.eof)
	{
		res=q("pers_librarydir");
	}
	if (!Defined(res))
	{
		//fix up?
		res=createLibrary2(null,personid);
	}
	return res;
}

function getCompanyidFromEntity(entity,entityid)
{
	var res="";
	if (entity=="company")
	  return entityid;
	if (entityid+""=="undefined")
	  return "";
	
	var testtable=getTableInfo(entity);
	if (!Defined(testtable.name)){
	  //log to CRM's logs
	  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")-getCompanyidFromEntity-No valid Entity found, entity is "+entity);
	  throw "No valid Entity found";
	}
	if (!isNumeric(entityid)){
	  //log to CRM's logs
	  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")-getCompanyidFromEntity-No valid Entity ID found, entityid is "+entity);
	  throw "No valid Entity ID found";
	}
	
	var idfield=getCompanyIdField(entity);
	var tableinfo=getTableInfo(entity);
	if (idfield)
	{
		var _sql="select "+idfield+" from "+entity+" where "+tableinfo.idfield+"="+entityid;
		var q=CRM.CreateQueryObj(_sql);
		q.SelectSQL();
		if (!q.eof)
		{
			res=q(idfield);
		}
	}
	return res;
}

function getCompanyIdField(entity)
{
  if ((entity.toLowerCase()=="cases")||(entity.toLowerCase()=="case"))
  {
    return "case_primarycompanyid";
  }
  if (entity.toLowerCase()=="opportunity")
  {
    return "oppo_primarycompanyid";
  }
  if (entity.toLowerCase()=="person")
  {
    return "pers_companyid";
  }
  var __xtableinfo=getTableInfo(entity);
  return __xtableinfo.CompanyField
}

function getOppoidFromQuote(quoteid)
{
	var res=null;
	
	if (!isNumeric(quoteid)){
	  //log to CRM's logs
	  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")-getOppoidFromQuote-No valid Entity ID found, quoteid is "+quoteid);
	  throw "No valid Quote ID found";
	}
	
	var _sql="select quot_opportunityid from quotes where Quot_OrderQuoteID="+quoteid;
	var q=CRM.CreateQueryObj(_sql);
	q.SelectSQL();
	if (!q.eof)
	{
		res=q("quot_opportunityid");
	}
	return res;
}
function getOppoidFromOrder(orderid)
{
	var res=null;

	if (!isNumeric(orderid)){
	  //log to CRM's logs
	  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")-getOppoidFromOrder-No valid Entity ID found, orderid is "+orderid);
	  throw "No valid Order ID found";
	}
	
	var _sql="select orde_opportunityid from orders where orde_OrderQuoteID="+orderid;
	var q=CRM.CreateQueryObj(_sql);
	q.SelectSQL();
	if (!q.eof)
	{
		res=q("orde_opportunityid");
	}
	return res;
}

function getEntityPath(fileentity, fileentityid, commid)
{
	//test our data
	var testtable=getTableInfo(fileentity);
	if (!Defined(testtable.name)){
	  //log to CRM's logs
	  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")-getEntityPath-No valid Entity found, fileentity is "+fileentity);
	  throw "No valid Entity found";
	}
	if (!isNumeric(fileentityid)){
	  //log to CRM's logs
	  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")-getEntityPath-No valid Entity ID found, fileentityid is "+fileentityid);
	  throw "No valid Entity ID found";
	}
	
	var libr_path="";
	if (fileentity.toLowerCase()=='person'){
		libr_path=getPersonFolder(fileentityid);	
	}else{
		var compid=getCompanyidFromEntity(fileentity,fileentityid);
		libr_path=getCompanyFolder(compid);
	}
	
	if (libr_path=="")
		libr_path=getUser_firstname()+" "+getUser_lastname();

	libr_path=replaceAll(libr_path,'/', ' ');//for bad data in the dbusing chars that are not allowed in folder names
	libr_path=replaceAll(libr_path,'?', ' ');		
	libr_path=replaceAll(libr_path,':', ' ');	
	libr_path=replaceAll(libr_path,'*', ' ');	
	libr_path=replaceAll(libr_path,'<', ' ');	
	libr_path=replaceAll(libr_path,'>', ' ');	
	libr_path=replaceAll(libr_path,'|', ' ');	
		
	//create a subfolder EG "Comm121"
	//we do this below as demo systems have the paths set but not existing in the library
	//EG H\\Harold inc....
	///so the folder H would be missing and cause a crash
	var _xpath=new String(getLibraryRootPath() +"\\" + libr_path);
	var _xpatharr=_xpath.split("\\");
	var _pathbuilder="";
	for(var tt=0;tt<_xpatharr.length;tt++)
	{
		if (_pathbuilder=="")
			_pathbuilder=_xpatharr[tt];
		else
			_pathbuilder+="\\"+_xpatharr[tt];
		createFolder(_pathbuilder);	
	}
	createFolder(getLibraryRootPath() +"\\" + libr_path);	
	createFolder(getLibraryRootPath() +"\\" + libr_path+"\\Comm"+commid);	
	return libr_path+"\\Comm"+commid;
}
var emaildataStr="";
var email=null;
var entity="";
var entityid="";

emaildataStr=new String(Request.Form("emaildata"));
Glog("filesentemail emaildataStr START:");
Glog(emaildataStr);
Glog("filesentemail emaildataStr END:");
var emaildataStrObj=JSON.parse(emaildataStr);
var emailMetadata=emaildataStrObj.screenMetadata;
email=emaildataStrObj.EmailList[0];
Glog("filesentemail email:");
entity=emailMetadata.entity;
entityid=emailMetadata.entityid;
Glog("filesentemail email #1 entity:"+entity);
Glog("filesentemail email #1 entityid:"+entityid);

//if no entity defined we parse the email
if ((!Defined(entity))||(entity==""))
{
	Glog("filesentemail parse the email subject:"+email.subject.value);
	//check for a tag
	var _sentemailtag=extractTag(email.subject.value);
	if ((_sentemailtag.entity=="")||(_sentemailtag.entity==null))
	{
		Glog("filesentemail parse the email body:"+email.body);
	  _sentemailtag=extractTag(email.body);
	}
	if ((_sentemailtag.entity=="")||(_sentemailtag.entity==null))
	{
		Glog("Nothing found..parsing email...");
		Glog(JSON.stringify(email));
	}
	Glog("filesentemail _sentemailtag:"+JSON.stringify(_sentemailtag));
	if ((_sentemailtag.entity=="")||(_sentemailtag.entity==null))
	{
		Glog("filesentemail no tag found");
		//search based on the email
		var ede=getEmailDataEntity(email);
		entity=ede.entity;
		entityid=ede.entityid;	
	}else{
		//set entity based on tag
		entity=_sentemailtag.entity;
		entityid=_sentemailtag.entityid;	
	}
	Glog("filesentemail #2 entity:"+entity);
	Glog("filesentemail #2 entityid:"+entityid);	
	Glog("filesentemail #2 entityTag:"+_sentemailtag.entityTag);	
}

var fileentity=entity;
var fileentityid=entityid;

var Comm_From=email.from.displayName+"<"+email.from.emailAddress+">";
var Comm_HasAttachments="";
if (email.attachments.length>0)
{
  Comm_HasAttachments="Y";
}
var Comm_TO="";
if (email.to)
{
	for(var ee=0;ee<email.to.length;ee++)
	{
		if (Comm_TO!="")
		  Comm_TO+=";";
		var _rec=email.to[ee];
		Comm_TO+=_rec.displayName+"<"+_rec.emailAddress+">";
	}
}
var Comm_CC="";
if (email.cc)
{
	for(var ee=0;ee<email.cc.length;ee++)
	{
		if (Comm_CC!="")
		  Comm_CC+=";";
		var _rec=email.cc[ee];
		Comm_CC+=_rec.displayName+"<"+_rec.emailAddress+">";
	}
}
var Comm_BCC="";
if (email.bcc)
{
	for(var ee=0;ee<email.bcc.length;ee++)
	{
		if (Comm_BCC!="")
		  Comm_BCC+=";";
		var _rec=email.bcc[ee];
		Comm_BCC+=_rec.displayName+"<"+_rec.emailAddress+">";
	}
}
var Comm_Description=email.subject.value;
var Comm_Subject=email.subject.value;
var comm_outlookEntryID=email.entryid; 
Glog("filesentemail comm_outlookEntryID:"+comm_outlookEntryID);
var Comm_Note="";
if (email.body){
	Comm_Note=stripHTML(email.body);//added in stripHTML as outlook just seems to be adding in html
}
var Comm_Email="";
var Comm_IsHtml="";
if ((email.htmlBody)&&(email.htmlBody.value)&&(email.htmlBody.value.html))
{
	Comm_Email=email.htmlBody.value.html;
	Comm_IsHtml="Y";
}
var parseEmailToTextColumnValue="";
if (boolSaveCommEmailToFile()){
	Comm_Email="";//email.htmlBody.value.html
	if (boolParseEmailToText()){
		parseEmailToTextColumnValue=stripHTML(email.htmlBody.value.html);//we use parseEmailToTextColumnValue later
	}
}

//defaults
if ((fileentity!="communication")&&(fileentity!="users")&&(fileentity!="user"))
{
  addToSearchHistory(fileentity,fileentityid);
}
var dataObj={entity:fileentity, entityid:fileentityid}
Glog("filesentemail dataObj :"+JSON.stringify(dataObj));
var assignmentObject=getAssignmentObject(dataObj);
Glog("filesentemail assignmentObject :"+JSON.stringify(assignmentObject));
var cdate = new Date(email.receivedDateTime.year, email.receivedDateTime.month-1, email.receivedDateTime.day, email.receivedDateTime.hour, email.receivedDateTime.minute, email.receivedDateTime.second);

var Comm_ChannelId=getUser_PrimaryChannelId();
var Comm_Type = "Email";
var Comm_Action	= "EmailOut";
if (email.sentItem==false)
  Comm_Action	= "EmailIn";
var Comm_Status	= "Complete";
var Comm_Priority = "Normal";	
				cdate=adjustUserDateToServerDate(cdate,-1);
var Comm_DateTime =cdate.getVarDate();
var Comm_Private="";
var Comm_SecTerr=assignmentObject.territory;
	
var CmLi_Comm_UserID=getUserId();

//create communication
var cdate = new Date();
var new_comm = CRM.CreateRecord("Communication");
new_comm("Comm_From") = Comm_From;
new_comm("Comm_TO") = Comm_TO;
new_comm("Comm_CC") = Comm_CC;
new_comm("Comm_BCC") = Comm_BCC;
new_comm("Comm_Type") = Comm_Type;
new_comm("Comm_Action") = Comm_Action;
if (Comm_Subject==null)
  Comm_Subject="";
new_comm("Comm_Subject") = Comm_Subject;		
new_comm("comm_outlookEntryID") = comm_outlookEntryID;	
if (Comm_Description==null)
  Comm_Description="";
new_comm("Comm_description") = Comm_Description;
new_comm("Comm_note") = Comm_Note;	
new_comm("Comm_Email") = Comm_Email;	
new_comm("Comm_IsHtml") = Comm_IsHtml;	
new_comm("Comm_Status") = Comm_Status;	
new_comm("Comm_datetime") = Comm_DateTime;
new_comm("Comm_Priority") = Comm_Priority;
new_comm("Comm_Private") = Comm_Private;
new_comm("Comm_ChannelId") = Comm_ChannelId;
new_comm("Comm_SecTerr") = Comm_SecTerr;
if (email.attachments.length>0){
	new_comm("Comm_HasAttachments") = "Y";
}

//crm primary entity
var contextfield=getCommContextField(fileentity);
if (contextfield!="")
{
	new_comm(contextfield) = fileentityid;
	if (contextfield.toLowerCase()=="comm_quoteid")
	{
		new_comm("comm_opportunityid") = getOppoidFromQuote(fileentityid);
	}else if (contextfield.toLowerCase()=="comm_orderid")
	{
		new_comm("comm_opportunityid") = getOppoidFromOrder(fileentityid);
	}

}
Glog("filesentemail comm_screen_metadata:");

if (emailMetadata.screensetup)
{
	//now we grab any "custom" fields..only coming in from prompt screen
	var comm_screen_metadata=emailMetadata.screensetup.comm_screen_metadata.screenMetadata.screens[0].formElements;
		
	if (comm_screen_metadata)
	{
	  for(var j=0;j<comm_screen_metadata.length;j++)
	  {
		new_comm(comm_screen_metadata[j].name) = getCreateFieldValue(comm_screen_metadata[j]);
	  }
	}
}
//clever...we set the column value here..useful for searching email data and avoiding markup tags
if (boolParseEmailToText()){
  var _fieldtoUse=parseEmailToTextColumnName();
  new_comm(_fieldtoUse) = parseEmailToTextColumnValue;
}
var errormessage="";
try{
  new_comm.SaveChanges();	
}catch(saveerr)
{
	errormessage=CRM.getTrans("Accelerator","Error Message")+": "+ saveerr.message;
	var res={
	"screenMetadata": {
		"errormessage":errormessage
	},
		"data": null
	}
	res=JSON.stringify(res);
	Response.Write(res);  
	Response.End();
}
Glog("filesentemail new communication :"+new_comm.RecordId);
	updateEntityByFields("communication", new_comm.RecordId);
var ede_entity="";
var ede_entityId="";

//create comm link 
var new_link = CRM.CreateRecord( "Comm_Link" );	   
new_link("CmLi_Comm_userId" ) = CmLi_Comm_UserID;
//person and company
if (fileentity=="person")
{
   new_link("CmLi_Comm_PersonId")=assignmentObject.personid; 
}else{
    if ((GetWebConfigValue("alwayssettodefaultperson")=="Y")&&((fileentity=="opportunity")||(fileentity=="cases")))
	{
		new_link("CmLi_Comm_PersonId")=assignmentObject.personid; 	 
	}else{
		//check is the email from or sent to a person in the company
		var ede=getEmailDataEntity(email);
		ede_entity=ede.entity;
		ede_entityId=ede.entityid;	
		if (ede_entity=="person") 
		  new_link("CmLi_Comm_PersonId")=ede_entityId; 	  
	}
}
//save emails as files? sql express? then yes!!!!
if (boolSaveCommEmailToFile()){
	var new_docEmail= CRM.CreateRecord("Library");
	var _entitypathE=getEntityPath(fileentity,fileentityid,new_comm.RecordId);
	new_docEmail("Libr_FilePath" ) = _entitypathE;
	new_docEmail("Libr_FileName" ) = "email.html";
	new_docEmail("Libr_type" ) = "FileEmail";
	new_docEmail("libr_communicationId" ) = new_comm.RecordId;
	new_docEmail.SaveChangesNoTLS();
	//now we create the file in _entitypathE
	var __femailname=getLibraryRootPath()+"\\"+_entitypathE+"\\email.html";
	var _createFileFullPathres = createFileFullPath(__femailname,"");
	var fso = new ActiveXObject("Scripting.FileSystemObject");
	thefile=fso.CreateTextFile(__femailname,"true");
	thefile.Close();
	
	// Use ADODB.Stream to write UTF-8 content
	var stream = new ActiveXObject("ADODB.Stream");
	stream.Type = 2; // Specify stream type - we want to write text
	stream.Charset = "utf-8"; // Specify charset - we want UTF-8

	// Open the stream
	stream.Open();

	// Write some content to the stream
	stream.WriteText(email.htmlBody.value.html);

	// Save the stream content to the file
	stream.SaveToFile(__femailname, 2); // 2 = overwrite

	// Clean up
	stream.Close();
	stream = null;
	thefile = null;
	fso = null;

}

if (fileentity=="lead")
{
  new_link("cmli_comm_leadid")=fileentityid; 
}
new_link("cmli_comm_companyid")=assignmentObject.companyid; 

if (assignmentObject.companyid==null)
{
  //is it a custom entity?...set the company and person if setup
  var _tblfileentity=getTableInfo(fileentity);
  var __x_entq_=CRM.FindRecord(fileentity, _tblfileentity.idfield+"="+fileentityid);
  if (_tblfileentity.CompanyField)
	new_link("cmli_comm_companyid")=__x_entq_.item(_tblfileentity.CompanyField); 
  if (_tblfileentity.PersonField)
	new_link("cmli_comm_personid")=__x_entq_.item(_tblfileentity.PersonField);  
}
new_link("CmLi_Comm_CommunicationId" ) = new_comm.RecordId;
//24 Oct 24-workaround for sage filter bug on comms--filter added in is the issue ="and ((CmLi_Comm_PersonId is not null) OR (CmLi_IsExternalAttendee = 'Y'))"
if (new_link("CmLi_Comm_PersonId")==null)
  new_link("CmLi_IsExternalAttendee")="Y";
new_link.SaveChanges();
	updateEntityByFields("Comm_Link", new_link.RecordId);
Glog("filesentemail new comm_link :"+new_link.RecordId);

//attachments...create library record...
var attachmentlinks=[];

if (email.attachments.length>0)
{
	/*
	--removing these..we should not use these for attachments
    var libr_category=GetWebConfigValue("libr_category");
    var libr_status=GetWebConfigValue("libr_status");
    var libr_type=GetWebConfigValue("libr_type");
	*/

    var libr_category="";
    var libr_status="Final";
    var libr_type="EmailAttachment";

	var cEmaildate = new Date(email.receivedDateTime.year, email.receivedDateTime.month-1, email.receivedDateTime.day, email.receivedDateTime.hour, email.receivedDateTime.minute, email.receivedDateTime.second);
	var libr_emailDate=new String(cEmaildate.getVarDate());

	//Check for duplicate file names
		// Create an object to track used names
		var attachmentNames = {};

		function getUniqueName(baseName) {
			var newName = baseName;
			var dotIndex = baseName.lastIndexOf(".");
			var nameOnly = baseName;
			var ext = "";

			// Split name and extension
			if (dotIndex != -1) {
				nameOnly = baseName.substring(0, dotIndex);
				ext = baseName.substring(dotIndex); // includes the "."
			}

			var counter = 1;
			while (attachmentNames[newName]) {
				newName = nameOnly + "(" + counter + ")" + ext;
				counter++;
			}
			return newName;
		}

		// Main loop
		for (var ll = 0; ll < email.attachments.length; ll++) {
			var att = email.attachments[ll];
			var attName = att.name;
			att.uploadName = att.name;

			if (attachmentNames[attName]) {
				// Duplicate found - create a new unique name
				var uniqueName = getUniqueName(attName);
				att.uploadName = uniqueName; // Update the attachment name
			}			
			// Mark the name as used
			attachmentNames[att.uploadName] = true;
			attachmentNames[att.name] = true;
		}

	
	for (var ll=0;ll<email.attachments.length;ll++)
	{
		var _att=email.attachments[ll];		
		if (_att.value)
		{
			var new_doc= CRM.CreateRecord("Library");
			//set defaults
			new_doc("libr_category" ) = libr_category;
			new_doc("libr_status" ) = libr_status;
			new_doc("libr_type" ) = libr_type;
			
			var librentityfield="";
			if (librentityfield=="")
			{
				librentityfield="libr_"+fileentity+"id";
				if (fileentity.toLowerCase()=="cases")
				  librentityfield="libr_caseid";
				if (fileentity.toLowerCase()=="quotes")
				  librentityfield="libr_quoteid";
				if (fileentity.toLowerCase()=="orders")
				  librentityfield="libr_orderid";
				if (fileentity.toLowerCase()=="solutions")
				  librentityfield="libr_solutionid";
			}
			if (librentityfield!="")
			{
			  new_doc(librentityfield)=fileentityid;
			  var _personField="libr_personid";
			  var _companyField="libr_companyid";
			  if (fileentity=="person")
			  {
				  if (assignmentObject.personid)
					new_doc(_personField)=assignmentObject.personid;
			  }else{
			    //is the person in the email?
				if (ede_entity=="person")
					new_doc(_personField)=ede_entityId; 
			  }
			  if (assignmentObject.companyid)
			    new_doc(_companyField)=assignmentObject.companyid;
			}
			var _entitypath=getEntityPath(fileentity,fileentityid,new_comm.RecordId);
		
			new_doc("Libr_FilePath" ) = _entitypath;
			new_doc("Libr_FileName" ) = _att.uploadName;
			new_doc("Libr_Entity" ) = fileentity;
			new_doc("Libr_FileSize" ) = _att.size;
			new_doc("libr_communicationId" ) = new_comm.RecordId;
			if (emailMetadata.screensetup)
			{
				//custom values..only coming in from prompt screen
				Glog("filesentemail library_screen_metadata:");
				var library_screen_metadata=emailMetadata.screensetup.library_screen_metadata.screenMetadata.screens[0].formElements;
				if (library_screen_metadata)
				{
				  for(var j=0;j<library_screen_metadata.length;j++)
				  {
					new_doc(library_screen_metadata[j].name) = getCreateFieldValue(library_screen_metadata[j]);
				  }
				}
			}
			//new_doc.SaveChangesNoTLS();
			new_doc.SaveChanges();
			updateEntityByFields("Library", new_doc.RecordId);

			//update the dates to reflect the email date
			var notNew_doc=CRM.FindRecord("Library","libr_libraryid="+new_doc.RecordId);
			notNew_doc("libr_createddate")=cEmaildate.getVarDate();
			//notNew_doc("libr_updateddate")=cEmaildate.getVarDate();//cannot set this here as the crm object updates it
			notNew_doc.SaveChangesNoTLS();
			
			CRM.ExecSQL("update library set libr_updateddate=libr_createddate where libr_libraryid="+new_doc.RecordId);

			var uploadlink=getCRMProtocol()+get_SERVER_NAME()
				+":"+get_SERVER_PORT()+
				CRM.Url("sagecrmws/ac2020fupload.aspx");
			if (isPortalRequest) {
				uploadlink+="?88=88&id="+new_doc.RecordId+"&path="+getLibraryRootPath()+"\\"+encodeURIComponent(replaceAll(custom_escape(_entitypath),'\\', '\\\\'))
				+"&type="+_att.type;			 
			 }else{
				uploadlink+="&id="+new_doc.RecordId+"&path="+getLibraryRootPath()+"\\"+encodeURIComponent(replaceAll(custom_escape(_entitypath),'\\', '\\\\'))
				+"&type="+_att.type;
			}
			//holding file..used on actual upload
			var _createFolderres = createFolder(getLibraryRootPath()+"\\"+_entitypath);
			Glog("Library createFolder: OK");
			var _createFileFullPathres = createFileFullPath(getLibraryRootPath()+"\\"+_entitypath+"\\"+new_doc.RecordId,"");
			Glog("Library createFileFullPath: OK");
			var _internalres={
			  createFolder:_createFolderres,
			  createFileFullPath:_createFileFullPathres
			}
			
			//DEV LINE....DO NOT LEAVE AS TRUE....SHOULD BE FALSE!!!!!!
			if (false){
			  uploadlink="http://localhost:1898/ac2020fupload.aspx?"+
				"&id="+new_doc.RecordId+"&path="+getLibraryRootPath()+"\\"+replaceAll(custom_escape(_entitypath),'\\', '\\\\')+"&type="+_att.type;
			}
			attachmentlinks.push({senderid:_att.id, name:_att.name, 
					id:new_doc.RecordId,
					link:uploadlink, 
					type:_att.type, 
					internal:_internalres,
					attIndex:_att.attIndex});
			
		}
	}
}

var __crmstatus="CRM Status";
var __crmfiledto="CRM Filed To";
var __crmfiledentity="CRM Filed Entity";
var __crmcommid="CRM Comm ID";
var __crmfiledby="CRM Filed By";
var __Filed=CRM.GetTrans("Accelerator","Filed");

var res={
  "screenMetadata": {
	"boolParseEmailToText":boolParseEmailToText(),
	"ParseEmailToTextColumn":parseEmailToTextColumnName()
  },
  "data": {
	"attachmentlinks":attachmentlinks,
	"lockedsystem":GetWebConfigValue("lockedsystem"),
	"EmailAsFile":boolSaveCommEmailToFile(),	
	"customproperties":[{
		name:__crmstatus,
		value:__Filed},
		{name:__crmfiledto,
		value:getEntityDesc(fileentity,fileentityid)},
		{name:__crmfiledentity,
		value:fileentity},
		{name:__crmcommid,
		value:new_comm.RecordId},
		{name:__crmfiledby,
		value:getUser_firstname()+" "+getUser_lastname()}
	]
  }
}
res=JSON.stringify(res);
Response.Write(res);
Glog("filesentemail res:"+res);
%>