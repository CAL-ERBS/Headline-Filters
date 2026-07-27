<!-- #include file ="sagecrm.js" -->

<!-- #include file ="io.js" -->
<!-- #include file ="configReader.js" -->
<!-- #include file ="helpers.js" -->
<%

DELETE THIS FILE????

var thisdata=Request.Form('data');

var dataObj=JSON.parse(thisdata).data;
var _RecordID=-1;

function getAssignmentObject(dataObj)
{
   var res={
     companyid:null,
	 personid:null,
	 territory:null
   }
   if (dataObj.entity=="person")
   {
     //get the company
	 var qc=CRM.FindRecord("person","pers_personid="+dataObj.entityid);
	 if (!qc.eof)
	 {
		res.companyid=qc("pers_companyid");
		res.territory=qc("pers_secterr");
	 }
	 res.personid=dataObj.entityid; 
   }else if (dataObj.entity=="company")
   {
	 var qc=CRM.FindRecord("company","comp_companyid="+dataObj.entityid);
	 if (!qc.eof)
	 {
		res.personid=qc("comp_primarypersonid");   
		res.territory=qc("comp_secterr");
	 }
	 res.companyid=dataObj.entityid;   
   }
   return res;
}

function setEntityField(recordObj,dataObj)
{
  var res="";
  //here we get the comm field for the given entity...
  var sql="select ColP_ColName from Custom_Edits where colp_lookupfamily='"+dataObj.entity+"' and ColP_EntryType=56 "+
          "and ColP_Entity='communication'";
  var q=CRM.CreateQueryObj(sql);
  
  q.SelectSQL();
  if (!q.eof)
  {
    res=q("ColP_ColName");
	recordObj(res)=dataObj.entityid;
  }else{
	//missing metadata
	var setEntityField_ent=new String(dataObj.entity);
	setEntityField_ent=setEntityField_ent.toLowerCase()
	if (setEntityField_ent=="lead")
	  res="comm_leadid";
	recordObj(res)=dataObj.entityid;
  }
  return res;
}
function setTerritory(recordObj,dataObj,assignmentObject)
{
	if (assignmentObject.territory!=null)
	  return assignmentObject;
	  
	var tersql="select ColP_ColName from Custom_Edits where ColP_EntryType=53 and colp_entity='"+dataObj.entity+"'";
	var qtersql=CRM.CreateQueryObj(tersql);
	qtersql.SelectSQL();
	if (!qtersql.eof)
	{
		//get the data
		var tableobj=getTableInfo(dataObj.entity);
		var entobj=CRM.FindRecord(dataObj.entity,tableobj.idfield+"="+dataObj.entityid);
		if (!entobj.eof)
		{
			assignmentObject.territory!=entobj(qtersql("ColP_ColName"));
		}
	}
	return assignmentObject;
}

var assignmentObject=getAssignmentObject(dataObj);

if (dataObj.entity=='communication')	
{
   var _comm_action=dataObj.action;
   var _comm_status=dataObj.status;   
   var _actiondatetime=new Date();
   if (dataObj.actiondatetime)
		_actiondatetime=new Date(dataObj.actiondatetime);

   var RecordComm = CRM.CreateRecord("Communication"); 
   RecordComm.comm_action=_comm_action; 
   RecordComm.comm_status=_comm_status; 
   RecordComm.comm_priority="Normal"; 
   RecordComm.comm_type="Task";  
   RecordComm.comm_subject=dataObj.subject; 
   RecordComm.comm_note=dataObj.details; 
   RecordComm.comm_datetime=_actiondatetime.getVarDate();
   //case//opportunity...custom entities?
   setEntityField(RecordComm,dataObj);
   setTerritory(RecordComm,dataObj,assignmentObject);
   RecordComm.comm_secterr=assignmentObject.territory;    
   
   RecordComm.SaveChanges(); 
   _RecordID=RecordComm.comm_communicationid;
   updateEntityByFields("Communication", _RecordID);
   var RecordComm_Link = CRM.CreateRecord("Comm_Link"); 
   RecordComm_Link.CmLi_Comm_CommunicationId=RecordComm.comm_communicationid; 
   RecordComm_Link.CmLi_Comm_UserId=getUserId(); 
   //person and company
   RecordComm_Link.CmLi_Comm_PersonId=assignmentObject.personid; 
   RecordComm_Link.cmli_comm_companyid=assignmentObject.companyid; 
   RecordComm_Link.SaveChanges(); 
	updateEntityByFields("Comm_Link", RecordComm_Link.RecordId);
} else{ 
   _RecordID="ERROR: no action found";
} 
  
var res={
  "screenMetadata": {
    "lang": getUserLang()
  },
  "data": {
	"recordid":_RecordID,
	"data":dataObj
  }
}
res=JSON.stringify(res);
Response.Write(res);
	
%>