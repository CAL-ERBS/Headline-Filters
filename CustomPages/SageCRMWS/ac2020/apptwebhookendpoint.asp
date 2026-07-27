<!-- #include file ="sagecrm.js" -->

<!-- #include file ="_base_objects.js" -->
<!-- #include file ="helpers.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="configReader.js" -->
<!-- #include file ="createNamedEntity.asp" -->
<!-- #include file ="emailtaggen.js" -->
<%
Glog("file:apptwebhookendpoint.asp");
var apptdevmode=false;
//example url
//http://demo.crmtogether.com/CRM2020/custompages/sagecrmws/ac2020/apptwebhookendpoint.asp?SID=11071536532121

function getCmLi_ExternalPersonID(_emailAddress)
{
  var psql="select Pers_PersonId from vPersonPE where 8001=8001 and Pers_EmailAddress='"+_emailAddress+"'";
  qpsql=CRM.CreateQueryObj(psql);
  qpsql.SelectSQL();
  if (!qpsql.eof)
	return qpsql("Pers_PersonId");
  return '';
}

function getcmli_status(val)
{
  var res=0;
  if ((val=="olResponseNone")||(val=="olResponseNotResponded"))
    res=0;
  else if (val=="olResponseNone")
    res=0;
  else if (val=="olResponseAccepted")
    res=3;
  else if (val=="olResponseDeclined")
    res=4;
  else if (val=="olResponseTentative")
    res=2;
  else if (val=="olResponseOrganized")
    res=6;

  return res;
}

function getApptStatus(apptStatus)
{
  return GetWebConfigValue("status_"+apptStatus);
}

function getApptDate(val)
{
  var res={date: val.getFullYear()+"-"+padDate(val.getMonth()+1)+"-"+padDate(val.getDate()),time:padDate(val.getHours())+":"+padDate(val.getMinutes())};
  return res;
}

function getUserFromEmail(emailAddress)
{
  var usql="select user_userid from users where 8002=8002 and user_emailaddress='"+emailAddress+"'";
  //Response.Write(usql);
  qu=CRM.CreateQueryObj(usql);
  qu.SelectSQL();
  if (!qu.eof)
  {
    return qu("user_userid");
  }
  if (emailAddress==null)
    emailAddress='';
  return emailAddress;
}

var CRMFlag="******Powered by CRMTogether.com******";
var guidlength=36;
function apptExists(_apptData)
{
  var res=0;//false
  var guid=getguid(_apptData)
  var sql="select comm_communicationid,comm_deleted from communication where 8003=8003 and comm_outlookEntryID='"+guid+"'";
  qpsql=CRM.CreateQueryObj(sql);
  qpsql.SelectSQL();
  if (!qpsql.eof)
  {
	if (qpsql("comm_deleted")==1)
	  res=2;//special flag to cope with outlook weirdness when item is deleted
	res=1;//true
  }
  return res;
}
function getCommId(_apptData)
{
  var res="-1";
  var guid=getguid(_apptData)
  var sql="select comm_communicationid from communication where 8004=8004 and comm_outlookEntryID='"+guid+"'";
  qpsql=CRM.CreateQueryObj(sql);
  qpsql.SelectSQL();
  if (!qpsql.eof)
  {
	res=qpsql("comm_communicationid");
  }
  return res;
}

function getguid(_apptData)
{
  var id="-1";
  var idx=_apptData.body.indexOf(CRMFlag);
  var bodypart1=_apptData.body.substring(idx+CRMFlag.length);
  var guid=bodypart1.substring(0,guidlength);
  return guid;
}

function buildDataObj(_apptData)
{
	var start=new Date(_apptData.start.year, (_apptData.start.month-1), _apptData.start.day, _apptData.start.hour,_apptData.start.minute);
	var end=new Date(_apptData.end.year, (_apptData.end.month-1), _apptData.end.day, _apptData.end.hour,_apptData.end.minute);
	var status=getApptStatus(_apptData.status);
	var deleted=_apptData.deleted;
	var dataObj=[];
	if (deleted)
	{
		status="Cancelled";
		dataObj.push({"name":"comm_deleted","value": 1});
	}
	
	dataObj.push({"name":"comm_datetime","value": getApptDate(start)});
	dataObj.push({"name":"comm_todatetime","value":getApptDate(end)});
	dataObj.push({"name":"comm_outlookEntryID","value":getguid(_apptData)});
    dataObj.push({"name":"comm_location","value":_apptData.location});
	
	dataObj.push({"name":"comm_status","value":status});
	if (_apptData.recipients.length==0)
	{
		dataObj.push({"name":"comm_subject","value":"_"});
		dataObj.push({"name":"comm_description","value":"_"});	
		dataObj.push({"name":"comm_note","value":"_"});
		//dataObj.push({"name":"comm_private","value":"Y"});..time is blocked out so we want people to see this				
	}else{
		dataObj.push({"name":"comm_subject","value":_apptData.subject});
		dataObj.push({"name":"comm_description","value":_apptData.subject});	
		dataObj.push({"name":"comm_note","value":_apptData.body});	
		if (_apptData.attachments.length>0)
			dataObj.push({"name":"Comm_HasAttachments","value":"Y"});
	}

    if (_apptData.alldayevent)
		dataObj.push({"name":"Comm_IsAllDayEvent","value":"Y"});
		
	//check Comm_Organizer is a crm user..if so use the user id otherwise use the email address	
	dataObj.push({"name":"Comm_Organizer","value":getUserFromEmail(_apptData.organizer.emailAddress)});

	//recipients
	var Comm_TO="";
	for(var ee=0;ee<_apptData.recipients.length;ee++)
	{
		if (Comm_TO!="")
		  Comm_TO+=";";
		var _rec=_apptData.recipients[ee];
		Comm_TO+=_rec.displayName+"<"+_rec.emailAddress+">";
	}	
	dataObj.push({"name":"comm_to","value":Comm_TO});
	
	dataObj.push({"name":"comm_priority","value":"Normal"});
	//territory
	var comm_secterr_value="";
	comm_secterr_value=getUser_PrimaryTerritory();
	dataObj.push({"name":"comm_secterr","value":comm_secterr_value});

	dataObj.push({"name":"comm_type","value":"Appointment"});
	dataObj.push({"name":"comm_action","value":"Meeting"});
	
	dataObj.push({"name":"comm_channelid","value":getUser_PrimaryChannelId()});
	
	//any tags?
	var _appttagObject=extractTag(_apptData.body);
	if ((_appttagObject!=null)&&(_appttagObject.entity!="")&&(_appttagObject!="person")&&(_appttagObject!="company")&&(Defined(_appttagObject.entity)))
	{
		//get the entity field for communication
		var _commEnitytable=getTableInfo(_appttagObject.entity);
		if ((_commEnitytable.name.toLowerCase()!="person")&& (_commEnitytable.name.toLowerCase()!="company"))
		{
			var _entityval=_commEnitytable.name;
			if (_entityval=="cases")
			  _entityval="case";
			dataObj.push({"name":"comm_"+_entityval+"ID","value":_appttagObject.entityid});
		}
	}	
	return dataObj;
}

function createAppointment(_apptData)
{
	var dataObj=buildDataObj(_apptData);

	var commRes=createNamedEntity("communication",dataObj);
	commRes.dataObj=dataObj;

	//Create the comm link for the user
	var RecordComm_Link = CRM.CreateRecord("Comm_Link"); 
	RecordComm_Link.CmLi_Comm_CommunicationId=commRes.entityid;
	RecordComm_Link.cmli_status=6;//6=organizer
	RecordComm_Link.CmLi_Comm_UserId=getUserFromEmail(_apptData.organizer.emailAddress);
	var _appttagObject=extractTag(_apptData.body);
	_appttagObject.entityid=_appttagObject.entityid;
	var _AssignmentObject=null;

	if (_appttagObject.entity!="")
	{
		_AssignmentObject=getAssignmentObject(_appttagObject, "", "");
	}
	if (_AssignmentObject)
	{
		if (_AssignmentObject.companyid)
			RecordComm_Link.CmLi_Comm_companyId=_AssignmentObject.companyid;
		if (_AssignmentObject.personid)
			RecordComm_Link.CmLi_Comm_personId=_AssignmentObject.personid;
	}
	RecordComm_Link.SaveChanges();
	updateEntityByFields("Comm_Link", RecordComm_Link.RecordId);
	var dupcheckarray=[];
	for(var ee=0;ee<_apptData.recipients.length;ee++)
	{
		var _rec=_apptData.recipients[ee];
		if (checkShouldUseEmail(dupcheckarray,_rec.emailAddress, _apptData))
		{
			//is CRM user? or person? or nothing
			var RecordComm_Link = CRM.CreateRecord("Comm_Link"); 
			RecordComm_Link.CmLi_Comm_CommunicationId=commRes.entityid;
			var uid=new String(getUserFromEmail(_rec.emailAddress));
			//Response.Write("HERERuid="+uid);
			if (uid.indexOf("@")>0)
			{
				RecordComm_Link.cmLi_IsExternalAttendee="Y"; 
				RecordComm_Link.cmli_status=getcmli_status(_rec.meetingresponsestatus);			
				RecordComm_Link.CmLi_ExternalPersonID=getCmLi_ExternalPersonID(_rec.emailAddress); 
				RecordComm_Link.cmli_recipient=_rec.emailAddress;
			}
			else 
			{
				if (getUserFromEmail(_apptData.organizer.emailAddress)!=uid)
				{
					//otherwise the user has 2 comm records
					RecordComm_Link.CmLi_Comm_UserId=uid; 
					RecordComm_Link.cmli_status=6;		
					buserlinkcreated=true;
				}
			}		
			RecordComm_Link.CmLi_Comm_companyId=null;
			RecordComm_Link.CmLi_Comm_personId=null;
			if (_AssignmentObject)
			{
				if (_AssignmentObject.companyid)
					RecordComm_Link.CmLi_Comm_companyId=_AssignmentObject.companyid;
				if (_AssignmentObject.personid)	
					RecordComm_Link.CmLi_Comm_personId=_AssignmentObject.personid;
			}
			RecordComm_Link.SaveChanges(); 	
	updateEntityByFields("Comm_Link", RecordComm_Link.RecordId);
			dupcheckarray.push(_rec.emailAddress);
		}
	}	
	return commRes;
}
function checkShouldUseEmail(array, email, _apptData)
{
  if ((!email)||(email==null))
   return false;
  for (var i = 0; i < array.length; i++) {
		if (array[i] === email) {
			return false;
		}
  }
  if (_apptData.organizer.emailAddress==email)
    return false;
  return true;
}

function updateAppointment(_apptData)
{
	var dataObj=buildDataObj(_apptData);
	_commid=getCommId(_apptData);
	
	var commRes=updateNamedEntity("communication",_commid, dataObj);
	commRes.entityid=_commid;
	commRes.dataObj=dataObj;
	
	var _appttagObject=extractTag(_apptData.body);
	_appttagObject.entityid=_appttagObject.entityid;
		
	var _AssignmentObject=null;
	if (_appttagObject.entity!="")
	{
		_AssignmentObject=getAssignmentObject(_appttagObject, "", "");
	}else{
	    _AssignmentObject={
				 companyid:null,
				 personid:null,
				 territory:null
			   }
	}
	
	var cl=CRM.FindRecord("Comm_Link","1230=1230 and cmli_comm_communicationid="+_commid); 
	var ucl_sql="";
	while(!cl.eof)
	{
		var recFound=false;
		for(var ee=0;ee<_apptData.recipients.length;ee++)
		{
			var _rec=_apptData.recipients[ee];
			//check if it exists...
			if ((cl("cmli_recipient")==_rec.emailAddress)||(!Defined(cl("cmli_recipient"))))
			{
				recFound=true;
				//to do ...update with response?
				//..RecordComm_Link.cmli_status=getcmli_status(_rec.meetingresponsestatus);
				var compstr="";
				var persstr="";
				if (_AssignmentObject.companyid!=null)
					compstr=",cmli_comm_companyid="+_AssignmentObject.companyid;
				if (_AssignmentObject.personid!=null)
					persstr=",cmli_comm_personid="+_AssignmentObject.personid;
				ucl_sql+="\n update comm_link set "+
					"cmli_status="+getcmli_status(_rec.meetingresponsestatus)+
					compstr+
					persstr+
					" where CmLi_CommLinkId="+cl("CmLi_CommLinkId");
			}
		}
		if (!recFound)
		{
			//fallback check
			var fallbacksql="select * from Comm_Link where 909=909 and CmLi_Comm_CommunicationId="+commRes.entityid;
			if (_AssignmentObject)
			{
				if (_AssignmentObject.companyid)
					fallbacksql+=" and CmLi_Comm_companyId="+_AssignmentObject.companyid;
				if (_AssignmentObject.personid)
					fallbacksql+=" and CmLi_Comm_personId="+_AssignmentObject.personid;
			}
			var fallbacksqlq=CRM.CreateQueryObj(fallbacksql);
			fallbacksqlq.SelectSQL();
			if (!fallbacksqlq.eof)
			{
				recFound=true;
			}
		}				
		if (!recFound)
		{
			var RecordComm_Link = CRM.CreateRecord("Comm_Link"); 
			RecordComm_Link.CmLi_Comm_CommunicationId=commRes.entityid;
			
			var uid=new String(getUserFromEmail(_rec.emailAddress));
			if (uid.indexOf("@")>0)
				RecordComm_Link.cmLi_IsExternalAttendee="Y"; 
			else 
				RecordComm_Link.CmLi_Comm_UserId=uid; 

			RecordComm_Link.cmli_status=getcmli_status(_rec.meetingresponsestatus);
			RecordComm_Link.cmli_recipient=_rec.emailAddress; 
			RecordComm_Link.CmLi_ExternalPersonID=getCmLi_ExternalPersonID(_rec.emailAddress); 
	
			if (_AssignmentObject)
			{
				if (_AssignmentObject.companyid)
					RecordComm_Link.CmLi_Comm_companyId=_AssignmentObject.companyid;
				if (_AssignmentObject.personid)	
					RecordComm_Link.CmLi_Comm_personId=_AssignmentObject.personid;
			}			
			
			RecordComm_Link.SaveChanges(); 	
	updateEntityByFields("Comm_Link", RecordComm_Link.RecordId);
		}
		cl.NextRecord();
	}
	if (ucl_sql!="")
	{
		CRM.ExecSQL(ucl_sql);
	}
	return commRes;
}

var data="";
var dataObj=null;
var testurl=CRM.Url("sagecrmws/ac2020/apptwebhookendpoint.asp");
if ((!Defined(Request.Form)))
{
	//this allows us to test parsing of the data..clever
	Response.Clear();
    Response.Addheader("Content-type", "text/html");
	Response.Write("No POST data found. Do you mean to debug?");
	
	Response.Write('<form method="POST" >');
	Response.Write('<label for="data">data:</label><br>');
	Response.Write('<textarea id="data" name="data" rows="20" cols="75">');
	Response.Write('</textarea><br>');
	Response.Write('<br><input type="submit" value="Submit">');
	Response.Write('<form>');
	
	Response.Write('<br><br><a href="'+testurl+'" >This url</a>');
	Response.End();
}

data=Request.Form("data");
dataObj=JSON.parse(data);

var companycode=getCompanyNameFlag();
  
var apptres=[];

for (var x=0;x<dataObj.length;x++)
{
  var val=dataObj[x];
  //check it has our code...so we dont pick up someone elses by mistake
  if (val.body.indexOf(companycode)!=-1)
  {
	  var apptCallBack=null;
	  Glog("Appointment data START");
	  Glog(JSON.stringify(val));
	  Glog("Appointment data END");
	  var _val_appexists=apptExists(val);
	  if (_val_appexists==0)
	  {
		 Glog("createAppointment");
		 apptCallBack=createAppointment(val);
		 apptCallBack.method="create";
	  }else if (_val_appexists==1)
	  {
		 Glog("updateAppointment");
		 apptCallBack=updateAppointment(val);  
		 apptCallBack.method="update";
	  }else{
		//_val_appexists==2...so we ignore
	  }
	  //any notes...for debug reasons
	  apptCallBack.notes="user:"+CRM.GetContextInfo("user","user_logon");
	  apptres.push(apptCallBack);
  }else{
    var apptCallBack={
		message: "company code does not match:"+companycode
	}
	apptres.push(apptCallBack);	  
  }
}
var res=JSON.stringify(apptres);
Response.Write(res);
Glog("Result START");
Glog(res);
Glog("Result END");
%>