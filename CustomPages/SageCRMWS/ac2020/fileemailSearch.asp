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
<!-- #include file ="SearchHistory.js" -->
<%
/*
This is used by the file email dialog to get the entity to save against
*/
Glog("file:fileemailsearch.asp");
var testurl=CRM.Url("sagecrmws/ac2020/fileemailsearch.asp");
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
var resFES=JSON.clone(_base_selectEntity);

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
   //MR 19 Dec 24 commented this out as sometimes outlook just does not set this value
   //throw "No valid EmaildataObj.from.emailAddress found";
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
		_matchon=CRM.GetTrans("Accelerator","TaggedPart");
	}	
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

	var CONTEXT_ENTITY;
	if ((Entity+""=="undefined")||(Entity=="")||(Entity==null))
	{
		//magic tags...? 
		var _magictags=checkMessageFileTo(EmaildataObj,null);
		if (_magictags){
			for (var tt=_magictags.length-1;tt>=0;tt--)
			{			
				var tagitem=_magictags[tt];
				if (tagitem.matchconfidence===100)
				{					
					Entity=tagitem.entity;
					EntityId=tagitem.entityid
				}
			}
		
			//if (_magictags.length>0){
			 // res.data.searchstring+=" & TAGS";
			 //_matchon=res.data.searchstring+=" & TAGS";
			 //}
		}
	}
	
	
if ((Entity+""!="undefined")&&(Entity!=""))
{

    timetick4= new Date().getTime();
	var tableNameView=getTableNameView(Entity);
	var table=getTableInfo(Entity);
	var CONTEXT_ENTITY=q=CRM.Findrecord(tableNameView,"8001=8001 and "+table.idfield+"="+EntityId);	
	_matchon+=Entity+"="+EntityId;
	resFES=_selectEntity(Entity,EntityId,q, false,true, true);
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
		resFES.screenMetadata.entity="person";
		resFES.screenMetadata.entityid=q("pers_personid");
		resFES.screenMetadata.entityName=q("pers_fullname");
		resFES.screenMetadata.entityIconColor=getTileColour('person');
		resFES.screenMetadata.entityName2=getEntityName(q,'company');
		resFES.screenMetadata.entityIcon2=getEntityIcon('company');	
		resFES.screenMetadata.entityIconColor2=getTileColour('company');				
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
			resFES.screenMetadata.entity="company";
			resFES.screenMetadata.entityid=q("comp_companyid");
			resFES.screenMetadata.entityName=q("comp_name");
			resFES.screenMetadata.entityIconColor=getTileColour('company');
			resFES.screenMetadata.entityName2=getEntityName(q,'person');
			resFES.screenMetadata.entityIcon2=getEntityIcon('person');		
			resFES.screenMetadata.entityIconColor2=getTileColour('person');
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
				resFES.screenMetadata.entity="lead";
				resFES.screenMetadata.entityid=q("lead_leadid");
				resFES.screenMetadata.entityName=q("lead_companyname");
				resFES.screenMetadata.entityIconColor=getTileColour('lead');
				resFES.screenMetadata.entityName2=q("lead_personfirstname")+" "+q("lead_personlastname");
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
					resFES.screenMetadata.emailaddress=_gsearchresultObj.data.searchstring;
					resFES.screenMetadata.entity=_gsearchresultObj.data.tableData[0].entity;
					//get the name...has to be company if we get here
					var qc=CRM.FindRecord("company","2380=2380 and comp_companyid="+_gsearchresultObj.data.tableData[0].entityid);
					resFES.screenMetadata.entityid=_gsearchresultObj.data.tableData[0].entityid;
					if (!qc.eof)
					{
						resFES.screenMetadata.entityName=qc("comp_name");
						resFES.screenMetadata.entityIcon=getEntityIcon('company');	
						resFES.screenMetadata.entityIconColor=getTileColour('company');
					}
				}else
				{
					_matchon=CRM.GetTrans("GenCaptions","User");
					resFES.screenMetadata.entity="user";
					resFES.screenMetadata.entityid=getUserId();
					resFES.screenMetadata.entityName=getUser_lastname()+" "+getUser_firstname();				
					resFES.screenMetadata.entityIconColor=getTileColour('user');
				}
			}
		}
	}
}
var timetick16= new Date().getTime();
Glog("Context #3:"+Entity+"="+EntityId);
resFES.screenMetadata.entityIcon=getEntityIcon(resFES.screenMetadata.entity);

if ((Entity!="communication")&&(Entity!="user")&&(Entity!="users"))
{
  addToSearchHistory(Entity,EntityId);
}

//screens
var _allCommscreens=[];
//get the communication screen metadata
var _commscreen= getNewScreen("communication","AcceleratorCommunicationPicker", CONTEXT_ENTITY, Entity);
resFES.screenMetadata.comm_screen_metadata={};
resFES.screenMetadata.comm_screen_metadata.screenMetadata={};
_allCommscreens.push(_commscreen);
resFES.screenMetadata.comm_screen_metadata.screenMetadata.screens=_allCommscreens;
var timetick17= new Date().getTime();
//get the documents screen metadata
var _allLibrscreens=[];
var _librscreen= getNewScreen("library","AcceleratorDocumentPicker", CONTEXT_ENTITY, Entity);
resFES.screenMetadata.library_screen_metadata={};
resFES.screenMetadata.library_screen_metadata.screenMetadata={};
//fix up libr_type
for(var oo=0;oo<_librscreen.formElements.length;oo++)
{
  var _elmnt=_librscreen.formElements[oo];
  if (_elmnt.name.toLowerCase()=="libr_type")
  {
	_elmnt.value="EmailAttachment";
  }
}

_allLibrscreens.push(_librscreen);
resFES.screenMetadata.library_screen_metadata.screenMetadata.screens=_allLibrscreens;
resFES.screenMetadata.testurl=testurl;
resFES.screenMetadata.searchedOn=_searchedon;

if ((_regexSearchesRes)&&(_regexSearchesRes.length>0))
  _matchon=_regexSearchesRes;

if (_regexpMsg!="")
{
  resFES.screenMetadata.regexpMsg=_regexpMsg;
  resFES.screenMetadata.regexSearches=_regexSearches;
}	
	
resFES.screenMetadata.searchstring=_matchon;

var timetick18= new Date().getTime();
//branding start
getBranding(resFES.screenMetadata);
//branding end

//send back global match list..jan 2022 update
var _gsearch="NOVALUE";
if (EmaildataObj.to.length>0)
	_gsearch=EmaildataObj.to[0].emailAddress;
if (EmaildataObj.sentItem==false)
{
	_gsearch=EmaildataObj.from.emailAddress;
}
resFES.screenMetadata.globalmatches={recordcount:0};
var _comms_permission=hasPermissionInsert("communication");
resFES.screenMetadata.hasFileEmail=_comms_permission;

var __tagentity="";
var __tagentityid="";
var timetick20=null;
if ((_tagEntity!=null)&&(_tagEntity.entity!=""))
{
  __tagentity=_tagEntity.entity;
  __tagentityid=_tagEntity.entityid;
  var _tag_tableNameView=getTableNameView(_tagEntity.entity);
  var _tag_table=getTableInfo(_tagEntity.entity);
  try{
	  var _tag_q=CRM.Findrecord(_tag_tableNameView,"2390=2390 and "+_tag_table.idfield+"="+_tagEntity.entityid);		 
	  if (!_tag_q.eof)
	  {
		  timetick20= new Date().getTime();
		  var taggedItem=
		  {
			  "count": resFES.screenMetadata.globalmatches.recordcount,
			  "entity": _tagEntity.entity,
			  "entityid": _tagEntity.entityid,
			  "tilecolor": getTileColour(_tagEntity.entity),
			  "tileicon": getTileIcon(_tagEntity.entity),
			  "hasInternalLink": true,
			  "externallink": {},
			  "loadfielddatalinks": [],
			  "Entity": _tagEntity.entity,
			  "Details": getEntityName(_tag_q,_tagEntity.entity),
			  "__Select__": true
		  }
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
if (  ((Entity!=null)&&(EntityId!="")) && 
    ( (__tagentity!=Entity)&&(__tagentityid!=EntityId) ) )
{
  var _cntxt_tableNameView=getTableNameView(Entity);
  var _cntxt_table=getTableInfo(Entity);
  var _cntxt_q=CRM.Findrecord(_cntxt_tableNameView,"2391=2391 and "+_cntxt_table.idfield+"="+EntityId);	
  var ContextItem=
  {
	  "count": resFES.screenMetadata.globalmatches.recordcount,
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
}


	//is it already filed?
	var _msgstatus=checkMessage(EmaildataObj.entryid);//Filed to Sage CRM message is from here...or not
	//add on any links to the filed communication also...
	resFES.data.tableData=_msgstatus.tableData.concat(resFES.data.tableData);
	if (_tagEntity)
	{
		//this goes first!!!
		resFES.data.tableData=_msgstatus.tableData.concat(resFES.data.tableData);		
	}
	resFES.screenMetadata.message=_msgstatus.message;

var GLOBAL_TIMEEND = new Date().getTime();

resFES.screenMetadata.globalmatchesurl=getCRMProtocol()+get_SERVER_NAME()
				+":"+get_SERVER_PORT()+CRM.Url("sagecrmws/ac2020/fileemailglobalmatchesonly.asp");

resFES=JSON.stringify(resFES.screenMetadata);

Response.Write(resFES);

%>