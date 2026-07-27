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
<!-- #include file ="tabcontentList.js" -->
<%
/*
This is used by the file email dialog to get the entity to save against
*/
Glog("file:fileemailglobalmatchesonly.asp");
var testurl=CRM.Url("sagecrmws/ac2020/fileemailglobalmatchesonly.asp");
Glog(testurl);
if ((!Defined(Request.Form)))
{	
	//this allows us to test parsing of the data..clever
	Response.Clear();
    Response.Addheader("Content-type", "text/html");
	Response.Write("No POST data found. Do you mean to debug?");
	
	Response.Write('<form method="POST" >');
	Response.Write('<label for="Emaildata">Emaildata:</label><br>');
	Response.Write('<textarea id="Emaildata" name="Emaildata" rows="20" cols="75">');
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
	//"http://win-qb6s2mb2d3i/CRM2021r1/CustomPages/sagecrmws/ac2020/fileemailsearch.asp?SID=164606665648145"
}
	var timetick1= new Date().getTime();
var NumberOfRecordsReturned=_baseConfig.listlength;
var res= JSON.clone(_base_selectEntity);

Glog("Emaildata START");
var Emaildata=Request.Form('Emaildata');
Emaildata=new String(Emaildata);
Glog("Emaildata END");
var Entity=Request.Form('Entity');
if (Request.Form.length==0)
  Entity="";
  
if (Entity!="")
{
	var table=getTableInfo(Entity);
	if (!Defined(table.name)){
	  //log to CRM's logs
	  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity found, entity is "+Request.Form('Entity'));
	  throw "No valid Entity found";
	}
}
  
Entity=new String(Entity);
var EntityId=Request.Form('EntityId');
if (Request.Form.length==0)
  EntityId="";
EntityId=new String(EntityId);
if (EntityId!="")
{
	if (!isNumeric(EntityId)){
	  //log to CRM's logs
	  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity ID found, entityid is "+Request.Form('EntityId'));
	  throw "No valid Entity ID found";
	}
}

Glog("Context #1:"+Entity+"="+EntityId);

var EmaildataObj=null;
//testling below
if (false)
{
	EmaildataObj={"from":{"displayName":"Marc Reidy","emailAddress":"marc@crmtogether.com","type":null},"replyto":null,"fullName":"Marc Reidy","phoneNumbers":[{"number":"3451908849","type":"business"}],"to":[{"displayName":"Marc Reidy","emailAddress":"marc@CRMTogetherDev.onmicrosoft.com","type":null}],"cc":[],"bcc":[],"subject":{"name":"subject","value":"FW: (Sage magazine) Product add-ons [4 pages]","caption":""},"body":"","htmlBody":null,"attachments":[],"entryid":"00000000071F3EDB3A0000","urls":[],"addresses":null,"sentItem":false,"receivedDateTime":{"year":2021,"month":2,"day":16,"hour":16,"minute":33,"second":46,"raw":"2021-02-16T16:33:46.611","rawutc":"2021-02-16T16:33:46.611Z","TZ":{"StandardName":"GMT Standard Time","DaylightName":"GMT Daylight Time"}},"sentDateTime":{"year":2021,"month":2,"day":16,"hour":16,"minute":33,"second":39,"raw":"2021-02-16T16:33:39","rawutc":"2021-02-16T16:33:39Z","TZ":{"StandardName":"GMT Standard Time","DaylightName":"GMT Daylight Time"}},"companies":null}

}else{
  EmaildataObj=JSON.parse(Emaildata);
}

 //EmaildataObj.sentItem=true;//test line only
 if (Defined(EmaildataObj)&& Defined(EmaildataObj.from))
 {  
	 if (Defined(EmaildataObj) && (EmaildataObj.from.emailAddress==null || EmaildataObj.from.emailAddress==""))
	 {
		EmaildataObj.from.emailAddress="noemailaddress@inthisemail.com";
		//so...we fix 2 issues here
		//internal systems sending emails with not emailAddress set (bad practice) so we flag this with that email address
		//also though...we treat these as sent emails
		EmaildataObj.sentItem=true;
	 }else{
	   var _user_emailaddress=new String(CRM.GetContextInfo('user','user_emailaddress'));
	   _user_emailaddress=_user_emailaddress.toLowerCase();
	   if (!EmaildataObj.sentItem && (EmaildataObj.from.emailAddress.toLowerCase()==_user_emailaddress))
		EmaildataObj.sentItem=true;//we assume its a sent email even
	 }
 }

//check the emailobject data
//
if (!validEmailAddress(EmaildataObj.from.emailAddress))
{
   LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid email address found, EmaildataObj.from.emailAddress is "+EmaildataObj.from.emailAddress);
   throw "No valid EmaildataObj.from.emailAddress found";
}

//dbgX("EmaildataObj: "+Emaildata);
//parse the data
var entObj=null;
var _searchedon="";
var _matchon="";
var _tagEntity=null;

var timetick2 = 0;
var timetick3 = 0;

//check for a tag here
if ((Entity+""=="undefined")||(Entity=="")||(Entity==null))
{
    timetick2= new Date().getTime();
	//check for a tag
	var tagPrefixSuffix = new String(GetWebConfigValue("tagPrefixSuffix"));
	var tagPrefixSuffix_arr=tagPrefixSuffix.split(",");
	var texttoSearch="";
	if ((EmaildataObj.subject.value)&&(EmaildataObj.subject.value.indexOf(tagPrefixSuffix_arr[0])>-1))
	{
		texttoSearch=EmaildataObj.subject.value;
	}else if ((EmaildataObj.body)&&(EmaildataObj.body.indexOf(tagPrefixSuffix_arr[0])>-1))
	{
		texttoSearch=EmaildataObj.body;
	}
	var bodypart1=texttoSearch.substr(texttoSearch.indexOf(tagPrefixSuffix_arr[0]));
	var bodypart2=bodypart1.substr(tagPrefixSuffix_arr[0].length);
	var endingPrefixIndex=bodypart2.indexOf(tagPrefixSuffix_arr[1]);
	var bodypart3=bodypart1.substr(0,tagPrefixSuffix_arr[1].length+endingPrefixIndex+tagPrefixSuffix_arr[0].length);
	_tagEntity=parseTag(bodypart3,tagPrefixSuffix_arr);
	if (_tagEntity.entity!="")
	{
		//example _tagEntity...{"entity":"Cases","entityTag":"0-11960"}
		var _subjectfields = new String(GetWebConfigValue(_tagEntity.entity.toLowerCase()+"_subjectfields"));
		var _subjectfieldsarr=_subjectfields.split(",");
		var tagq=CRM.Findrecord(_tagEntity.entity,_subjectfieldsarr[1]+"='"+_tagEntity.entityTag+"'");	
		if (!tagq.eof)
		{
			var tagqtable=getTableInfo(_tagEntity.entity); 
			Entity=_tagEntity.entity;
			EntityId=tagq(tagqtable.idfield);
			_tagEntity.entityid=EntityId;
		}
	}
	_matchon=CRM.GetTrans("Accelerator","TaggedPart");
	timetick3= new Date().getTime();
}

if ((Entity+""=="undefined")||(Entity=="")||(Entity==null))
{
	//-----regex search here ? 
	var searchStringRegEx = "";
	var _regexpMsg="";
	var regEx_res_tableData = [];
		var _regexSearches=[];//all strings searched on
		var _regexSearchesRes=[];//all strings searched on that have a result
	if ((EmaildataObj != null)&&(EmaildataObj.sentItem==false)) {		
		var acregex_Records = CRM.FindRecord("Custom_Captions", "capt_code like 'acregex%'");
		acregex_Records.OrderBy="capt_order";
		var res_arr = [];
		var _regexSearchesRes=[];//all strings searched on that have a result
		while (!acregex_Records.eof) {
		
			var searchedAlready = [];
			var acregex = acregex_Records("capt_us");
			var acregex_entity = acregex_Records("capt_family");
			var acregex_params = acregex_Records("capt_de");
			searchStringRegEx += "RegExp:" + acregex + " " + CRM.GetTrans("Entities",acregex_entity);

			var runRegexSearch = true;
			var regex_from_email = acregex_Records("capt_uk");
			//if we have an email in capt_uk then only run regex if it is the same as email FROM
			if (regex_from_email != "" && regex_from_email!=null ) { 
		
				//searchStringRegEx += " reg exp from email:" + regex_from_email;
				Glog("regex_from_email:" + new String(regex_from_email).toLowerCase());
				Glog("searchobject email from address:" + new String(EmaildataObj.from.emailAddress).toLowerCase())		
				runRegexSearch = new String(regex_from_email).toLowerCase() == new String(EmaildataObj.from.emailAddress).toLowerCase();				
			}
			var _sregexObj=null;
			try{
				_sregexObj=new RegExp(acregex,acregex_params);
			}catch(exreg){
				_regexpMsg.push("-ERROR:"+exreg.message);
			}
			//search subject 
			if (EmaildataObj.subject.value != null && runRegexSearch) {
				var search_subject = new String(EmaildataObj.subject.value);				
				var matched_subject = null;		
				try {
					matched_subject = search_subject.match(_sregexObj);
					Glog("Regex "+acregex+" match result on subject '"+search_subject+"' : " + matched_subject);	
				} catch(e) {	
					searchStringRegEx += "-Error in regular expression " + acregex;
				}
				if (matched_subject != null) {
					_regexpMsg+="-Subject matches:"+matched_subject.length;
					_regexpMsg+="-"+matched_subject;
			
					for(var i=0; i < matched_subject.length;i++) {
						if ((matched_subject[i]!="") && (!contains(_regexSearches,matched_subject[i]))){
							Glog("...search subject for group " + matched_subject[i]);
							_regexSearches.push(matched_subject[i]);
							var regExpResult = doEntitySearch(acregex_entity, null,  "%"  +matched_subject[i] ,"","5","");
							if ((regExpResult.data != null) && (regExpResult.data.tableData.length>0)){
								regEx_res_tableData = regEx_res_tableData.concat(regExpResult.data.tableData);	
								_regexSearchesRes.push(matched_subject[i]);								
							}				
						}
					}
				} 
			}
			//search body 
			if (EmaildataObj.body != null && runRegexSearch) {
				var matched_body = null;
				var search_body = new String(EmaildataObj.body);
				try {
					matched_body = search_body.match(_sregexObj);
					Glog("Regex " + acregex + "  match result on subject '"+search_body+"' : " + matched_body);	
				} catch(e) {
					//
					searchStringRegEx += "-Error in regular expression " + acregex;
				}				
				if (matched_body != null) {
					_regexpMsg+="-Body matches:"+matched_body.length;
					_regexpMsg+="-"+matched_body;
					for(var i=0; i < matched_body.length;i++) {
						if ((matched_body[i]!="")&& (!contains(_regexSearches,matched_body[i]))){
							Glog("...search body for group " + matched_body[i]);
							_regexSearches.push(matched_body[i]);
							var regExpResult = doEntitySearch(acregex_entity, null, "%" + matched_body[i] ,"","","");	
							if ((regExpResult.data != null) && (regExpResult.data.tableData.length>0)){
								regEx_res_tableData = regEx_res_tableData.concat(regExpResult.data.tableData);
								_regexSearchesRes.push(matched_body[i]);		
							}
							if (validEmailAddress(matched_body[i]))
							{
							   var gresX=globalSearch(matched_body[i]);
							   gresX=JSON.parse(gresX);
							   if ((gresX)&& (gresX.data.tableData)&& (gresX.data.tableData.length>0))
							   {
									regEx_res_tableData = regEx_res_tableData.concat(gresX.data.tableData);
									if (!contains(_regexSearchesRes,matched_body[i]))
									   _regexSearchesRes.push(matched_body[i]);
								}
							}						
						}
					}
				}
			}
			
			acregex_Records.NextRecord();

		} //end while
	}
}
//------------------------

if ((regEx_res_tableData)&&(regEx_res_tableData.length>0))
{
	Entity=regEx_res_tableData[0].entity;
	EntityId=regEx_res_tableData[0].entityid;
	_matchon="RegExp";
}
Glog("Context #2:"+Entity+"="+EntityId);
var timetick4=0;
var timetick5=0;
var timetick6=0;
var timetick7=0;
var timetick8=0;
var timetick9=0;
var timetick10=0;
var timetick11=0;
var timetick12=0;
var timetick13=0;
var timetick14=0;
var timetick15=0;
var timetick16=0;
var timetick17=0;

var timetick18=0;
var timetick19=0;
var timetick20=0;
var timetick21=0;

if ((Entity+""!="undefined")&&(Entity!=""))
{
    timetick4= new Date().getTime();
	var tableNameView=getTableNameView(Entity);
	var table=getTableInfo(Entity);
	var CONTEXT_ENTITY=q=CRM.Findrecord(tableNameView,"8001=8001 and "+table.idfield+"="+EntityId);	
	res=_selectEntity(Entity,EntityId,q, false,true);
    timetick5= new Date().getTime();	
}else{
	var q=null;
	timetick6= new Date().getTime();
	if (EmaildataObj.sentItem==false)
	{
		_searchedon+="findPersonByEmail from: "+EmaildataObj.from.emailAddress;
		_matchon=EmaildataObj.from.emailAddress;
		q=findPersonByEmail(EmaildataObj.from.emailAddress);
		timetick7= new Date().getTime();
	}else if (EmaildataObj.to.length>0){
		_matchon=EmaildataObj.to[0].emailAddress;
		_searchedon+="findPersonByEmail to: "+EmaildataObj.to[0].emailAddress;
		q=findPersonByEmail(EmaildataObj.to[0].emailAddress);	
		timetick8= new Date().getTime();
	}else {
		_searchedon+="findPersonByEmail NOVALIDEMAILFOUND";
		q=findPersonByEmail("NOVALIDEMAILFOUND");	
		timetick8= new Date().getTime();
	}
	if (q.RecordCount>0)
	{
		res.screenMetadata.entity="person";
		res.screenMetadata.entityid=q("pers_personid");
		res.screenMetadata.entityName=q("pers_fullname");
		res.screenMetadata.entityIconColor=getTileColour('person');
		res.screenMetadata.entityName2=getEntityName(q,'company');
		res.screenMetadata.entityIcon2=getEntityIcon('company');	
		res.screenMetadata.entityIconColor2=getTileColour('company');				
	}else{
		var q=null;
		if (EmaildataObj.sentItem==false)
		{
			_searchedon+="findCompanyByEmail from:"+EmaildataObj.from.emailAddress;
			_matchon=EmaildataObj.from.emailAddress;
			q=findCompanyByEmail(EmaildataObj.from.emailAddress);
			timetick9= new Date().getTime();
		}else if (EmaildataObj.to.length>0){
			_searchedon+="findCompanyByEmail from:"+EmaildataObj.to[0].emailAddress;
			_matchon=EmaildataObj.to[0].emailAddress;
			q=findCompanyByEmail(EmaildataObj.to[0].emailAddress);	
			timetick10= new Date().getTime();
		}else {
			_searchedon+="findCompanyByEmail NOVALIDEMAILFOUND";
			q=findCompanyByEmail("NOVALIDEMAILFOUND");	
			timetick11= new Date().getTime();
		}
		if (q.RecordCount>0)
		{
			res.screenMetadata.entity="company";
			res.screenMetadata.entityid=q("comp_companyid");
			res.screenMetadata.entityName=q("comp_name");
			res.screenMetadata.entityIconColor=getTileColour('company');
			res.screenMetadata.entityName2=getEntityName(q,'person');
			res.screenMetadata.entityIcon2=getEntityIcon('person');		
			res.screenMetadata.entityIconColor2=getTileColour('person');
		}else{
			var q=null;
			if (EmaildataObj.sentItem==false)
			{
				_searchedon+="findLeadByEmailExact from:"+EmaildataObj.from.emailAddress;
				_matchon=EmaildataObj.from.emailAddress;
				q=findLeadByEmailExact(EmaildataObj.from.emailAddress);
				timetick12= new Date().getTime();
			}else if (EmaildataObj.to.length>0){
				_matchon=EmaildataObj.to[0].emailAddress;
				_searchedon+="findLeadByEmailExact from:"+EmaildataObj.to[0].emailAddress;
				q=findLeadByEmailExact(EmaildataObj.to[0].emailAddress);	
				timetick13= new Date().getTime();
			}else {
				gsearch="findLeadByEmailExact NOVALIDEMAILFOUND";
				q=findLeadByEmailExact("NOVALIDEMAILFOUND");	
				timetick14= new Date().getTime();
			}
			if (q.RecordCount>0)
			{	
				res.screenMetadata.entity="lead";
				res.screenMetadata.entityid=q("lead_leadid");
				res.screenMetadata.entityName=q("lead_companyname");
				res.screenMetadata.entityIconColor=getTileColour('lead');
				res.screenMetadata.entityName2=q("lead_personfirstname")+" "+q("lead_personlastname");
			}else{
			
				//try the global search
				var _gsearch="NOVALUE";
				
				if (EmaildataObj.to.length>0)
					_gsearch=EmaildataObj.to[0].emailAddress;
				if (EmaildataObj.sentItem==false)
				{
					_gsearch=EmaildataObj.from.emailAddress;
				}
				_searchedon+="globalSearch from:"+_gsearch;
				if ((_gsearch==null)||(_gsearch==""))
				  _gsearch="__NODATA__";
				var _gsearchresult=globalSearch(_gsearch);
				timetick15= new Date().getTime();
				var _gsearchresultObj=JSON.parse(_gsearchresult);
				if (_gsearchresultObj.data.recordcount>0)
				{
					_matchon=_gsearch;
					res.screenMetadata.emailaddress=_gsearchresultObj.data.searchstring;
					res.screenMetadata.entity=_gsearchresultObj.data.tableData[0].entity;
					//get the name...has to be company if we get here
					var qc=CRM.FindRecord("company","2380=2380 and comp_companyid="+_gsearchresultObj.data.tableData[0].entityid);
					res.screenMetadata.entityid=_gsearchresultObj.data.tableData[0].entityid;
					if (!qc.eof)
					{
						res.screenMetadata.entityName=qc("comp_name");
						res.screenMetadata.entityIcon=getEntityIcon('company');	
						res.screenMetadata.entityIconColor=getTileColour('company');
					}
				}else
				{
					_matchon=CRM.GetTrans("GenCaptions","User");
					res.screenMetadata.entity="user";
					res.screenMetadata.entityid=getUserId();
					res.screenMetadata.entityName=getUser_lastname()+" "+getUser_firstname();				
					res.screenMetadata.entityIconColor=getTileColour('user');
				}
			}
		}
	}
}
var timetick16= new Date().getTime();
Glog("Context #3:"+Entity+"="+EntityId);
res.screenMetadata.entityIcon=getEntityIcon(res.screenMetadata.entity);

var timetick17= new Date().getTime();
//get the documents screen metadata

res.screenMetadata.searchedOn=_searchedon;

if ((_regexSearchesRes)&&(_regexSearchesRes.length>0))
  _matchon=_regexSearchesRes;

if (_regexpMsg!="")
{
  res.screenMetadata.regexpMsg=_regexpMsg;
  res.screenMetadata.regexSearches=_regexSearches;
}	
	
res.screenMetadata.searchstring=_matchon;

timetick18= new Date().getTime();

//send back global match list..jan 2022 update
var _gsearch="NOVALUE";
if (EmaildataObj.to.length>0)
	_gsearch=EmaildataObj.to[0].emailAddress;
if (EmaildataObj.sentItem==false)
{
	_gsearch=EmaildataObj.from.emailAddress;
}
if ((_gsearch==null)||(_gsearch==""))
  _gsearch="__NODATA__";
var _gsearchresult=globalSearch(_gsearch);
timetick19= new Date().getTime();
var _gsearchresultObj=JSON.parse(_gsearchresult);
res.screenMetadata.globalmatches=_gsearchresultObj.data;
res.screenMetadata.globalmatches.screenMetadata=_gsearchresultObj.screenMetadata;
var __tagentity="";
var __tagentityid="";
if ((_tagEntity!=null)&&(_tagEntity.entity!=""))
{
  __tagentity=_tagEntity.entity;
  __tagentityid=_tagEntity.entityid;
  var _tag_tableNameView=getTableNameView(_tagEntity.entity);
  var _tag_table=getTableInfo(_tagEntity.entity);
  try{
	var tagWhere="2390=2390 and "+_tag_table.idfield+"="+_tagEntity.entityid;
	  var _tag_q=CRM.Findrecord(_tag_tableNameView,tagWhere);		 
	  if (!_tag_q.eof)
	  {
		  timetick20= new Date().getTime();
		  var taggedItem=
		  {
			  "count": res.screenMetadata.globalmatches.recordcount,
			  "entity": _tagEntity.entity,
			  "entityid": _tagEntity.entityid,
			  "tilecolor": getTileColour(_tagEntity.entity),
			  "tileicon": getTileIcon(_tagEntity.entity),
			  "hasInternalLink": true,
			  "externallink": {},
			  "loadfielddatalinks": [],
			  "Entity": _tagEntity.entity,
			  "Details": getEntityName(_tag_q,_tagEntity.entity),
			  "__Select__": true,
			  "tagWhere":tagWhere
		  }
		  res.screenMetadata.globalmatches.tableData.push(taggedItem);
		  res.screenMetadata.globalmatches.recordcount++;
	  }else{
		_tagEntity=null;
		__tagentity="";
		__tagentityid="";
	  }
  }catch(tagFileError){
	  _tagEntity=null;
	  __tagentity="";
	  __tagentityid="";
  }
 
}
//check for open oppos/cases?.. or other primary entities you might want to file against
//...code from getscreen setup
var searchEntities_sql= "select Bord_Name,Bord_Caption from Custom_Tables where Bord_PrimaryTable='Y' "+
						"order by Bord_Caption";
var q=CRM.CreateQueryObj(searchEntities_sql);
q.SelectSQL();
var searchEntities_temp=[];
var searchEntities=[];
var configSearchEntities=new String(GetWebConfigValue("SearchEntities"));
	if (isPortalRequest) {
		configSearchEntities = Defined(CurrentPortalCRMUser("acpu_searchentities")) ?  CurrentPortalCRMUser("acpu_searchentities") :  "";
	}
configSearchEntities=configSearchEntities.toLowerCase();
var configSearchEntities_arr=configSearchEntities.split(",");
for(var xx=0;xx<configSearchEntities_arr.length;xx++)
{
	if (configSearchEntities_arr[xx].toLowerCase()=="case")
	{
	  configSearchEntities_arr[xx]="cases";
	  break;
	}
}
while(!q.eof)
{
  var _permission=hasPermissionView(q("Bord_Name"));
  if (_permission)
  {
		var Bord_Name=new String(q("Bord_Name"));
		Bord_Name=Bord_Name.toLowerCase();
		_tmpobj={
			"name": Bord_Name,
			"caption": CRM.GetTrans("TabNames",q("Bord_Caption"))
		}

		if (contains(configSearchEntities_arr,q("Bord_Name"))) //only add in entities that are in the config
		{
				//Response.Write("_permission:"+q("Bord_Name")+"::"+_permission);
			searchEntities_temp.push(_tmpobj);
		}
  }
  q.NextRecord();
}

//res.screenMetadata.aa=searchEntities_temp;
//res.screenMetadata.xxxx="";
//loop entities we access
var timetick21= new Date().getTime();
for(var yy=0;yy<searchEntities_temp.length;yy++)
{
	//get table info
	var _tmptable=getTableInfo(searchEntities_temp[yy].name);
	//res.screenMetadata.xxxx+=searchEntities_temp[yy].name+"="+_tmptable.hascommunications;
	if (_tmptable.hascommunications===true && res.screenMetadata)
	{
		var assignObj={
			entity:Entity,
			entityid:EntityId
		}
		var assignmentObject=getAssignmentObject(assignObj,res.screenMetadata.entity, res.screenMetadata.entityid);
		//run query on those updated in last month or open?
		var _tableNameView=getTableNameView(_tmptable.name);
		var _sqlWhereFilter=" 76123=76123 and ";//our sql tracer
		//var _sqlWhereFilter=" and 1=2";//V1 ONLY WORKING FOR PERSON AND COMPANY CONTEXT...
		if (Defined(assignmentObject.personid)){
			_sqlWhereFilter="and "+_tmptable.PersonField+"="+assignmentObject.personid;
		}
		if (Defined(assignmentObject.companyid)){
			_sqlWhereFilter="and "+_tmptable.CompanyField+"="+assignmentObject.companyid;
		}
		var _whereclause="2396=2396 and "+_tmptable.prefix+"_updateddate>getdate()-30 "+_sqlWhereFilter;
		//res.screenMetadata.xxxx+="____Entity="+Entity+EntityId+"_____"+_whereclause;
		//res.screenMetadata.assignmentObject=assignmentObject;
		var _qm=CRM.Findrecord(_tableNameView,_whereclause);
        try{
			if (!_qm.eof)
			{
				  var taggedItem=
				  {
					  "count": res.screenMetadata.globalmatches.recordcount,
					  "entity": _tmptable.name,
					  "entityid": _qm(_tmptable.idfield),
					  "tilecolor": getTileColour(_tmptable.name),
					  "tileicon": getTileIcon(_tmptable.name),
					  "hasInternalLink": true,
					  "externallink": {},
					  "loadfielddatalinks": [],
					  "Entity": _tmptable.name,
					  "Details": getEntityName(_qm,_tmptable.name),
					  "__Select__": true,
					  "_whereclause":_whereclause
				  }
				  //add to list
				  res.screenMetadata.globalmatches.tableData.push(taggedItem);
				  res.screenMetadata.globalmatches.recordcount++;
				  _qm.NextRecord();
			}
		}catch(eSQL){
			res.screenMetadata.sqlerror=_tableNameView+"where:"+_whereclause;
		}
	}
}
var timetick22= new Date().getTime();

if (  ((Entity!=null)&&(EntityId!="")) && 
    ( (__tagentity!=Entity)&&(__tagentityid!=EntityId) ) )
{
  var _cntxt_tableNameView=getTableNameView(Entity);
  var _cntxt_table=getTableInfo(Entity);
  var _cntxt_q=CRM.Findrecord(_cntxt_tableNameView,"2391=2391 and "+_cntxt_table.idfield+"="+EntityId);	
  var _count=0;
  if (res.screenMetadata&& res.screenMetadata.globalmatches && res.screenMetadata.globalmatches.recordcount){
	_count=res.screenMetadata.globalmatches.recordcount.length;
	  var ContextItem=
	  {
		  "count": _count,
		  "entity": Entity,
		  "entityid": EntityId,
		  "tilecolor": getTileColour(Entity),
		  "tileicon": getTileIcon(Entity),
		  "hasInternalLink": true,
		  "externallink": {},
		  "loadfielddatalinks": [],
		  "Entity": Entity,
		  "Details": getEntityName(_cntxt_q,Entity),
		  "__Select__": true
	  }
	  res.screenMetadata.globalmatches.tableData.push(ContextItem);
	  res.screenMetadata.globalmatches.recordcount++;}
}

//--------fix up the data
var _gFormattedTableData=null;
if (regEx_res_tableData)
{
	for(var pp=0;pp<regEx_res_tableData.length;pp++)
	{
		var _res_tableData_arr=globalSearch_Findrecord(regEx_res_tableData[pp].entityid, regEx_res_tableData[pp].entity,"");
		if(_gFormattedTableData==null)
		  _gFormattedTableData=_res_tableData_arr
		else
		  _gFormattedTableData=_gFormattedTableData.concat(_res_tableData_arr);
	}
	if(_gFormattedTableData!=null)
	{
	  res.screenMetadata.globalmatches.tableData=_gFormattedTableData;
	  res.screenMetadata.globalmatches.recordcount=_gFormattedTableData.length;
	}	
}
//------------------------------------------------
var timetick23= new Date().getTime();
	//magic tags...? 
	var _magictags=checkMessageFileTo(EmaildataObj);
	if (_magictags){
		for (var tt=_magictags.length-1;tt>=0;tt--)
		{
			var tagitem=_magictags[tt];
			var _magictags_tableData_arr=globalSearch_Findrecord(tagitem.entityid, tagitem.entity,"");
			res.screenMetadata.globalmatches.tableData=_magictags_tableData_arr.concat(res.screenMetadata.globalmatches.tableData);//this way we get the oppo etc first
			//gres.data.tableData=gres.data.tableData.concat(_magictags_tableData_arr);//this way we get the comm record
		}
		//remove any duplicates from the total response
		res.screenMetadata.globalmatches.tableData=removeArrayDuplicates(res.screenMetadata.globalmatches.tableData,"entity","entityid");
		//res.screenMetadata.magictags=_magictags;
		if (_magictags.length>0)
		  res.screenMetadata.searchstring+=" & TAGS";
	}
	res.screenMetadata.globalmatches.recordcount=res.screenMetadata.globalmatches.tableData.length;
var timetick24= new Date().getTime();
//------------------------------------------------

//---------------ANY RECENTLY UPDATES OPPOS ETC---------------------------------
//check each primary entity for updates

//check any comms added recently?

//------------------------------------------------------------------------------
//for now lets remove match confidence from This

var tableColumnsXX = res.screenMetadata.globalmatches.tableColumns;

// Remove the last two items
tableColumnsXX.splice(-2, 2);

// Optional: reassign if needed
res.screenMetadata.globalmatches.tableColumns = tableColumnsXX;
//-------------------

var GLOBAL_TIMEEND = new Date().getTime();
res.screenMetadata.time = GLOBAL_TIMEEND - GLOBAL_TIMESTART;
res.screenMetadata.sender="fileemailglobalmatchesonly";

res.screenMetadata.timers=[{
			"timetick1":timetick2-timetick1,
			"timetick2":timetick3-timetick2,
			"timetick3":timetick4-timetick3,
			"timetick4":timetick5-timetick4,
			"timetick5":timetick6-timetick5,
			"timetick6":timetick7-timetick6,
			"timetick7":timetick8-timetick7,
			"timetick8":timetick9-timetick8,
			"timetick9":timetick10-timetick9,
			"timetick10":timetick11-timetick10,
			"timetick11":timetick12-timetick11,	
			"timetick12":timetick13-timetick12,
			"timetick13":timetick14-timetick13,
			"timetick14":timetick15-timetick14,
			"timetick15":timetick16-timetick15,
			"timetick16":timetick17-timetick16,
			"timetick17":timetick18-timetick17,
			"timetick18":timetick19-timetick18,
			"timetick19":timetick20-timetick19,
			"timetick20":timetick21-timetick20,
			"timetick21":timetick22-timetick21,
			"timetick22":timetick23-timetick22,
			"timetick23":timetick24-timetick23
        }];
		
res=JSON.stringify(res.screenMetadata);

Response.Write(res);

%>