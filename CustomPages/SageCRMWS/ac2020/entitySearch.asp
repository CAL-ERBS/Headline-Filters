<!-- #include file ="sagecrm.js" -->
<!-- #include file ="_base_objects.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="configReader.js" -->
<!-- #include file ="helpers.js" -->
<!-- #include file ="globalsearch.js" -->
<!-- #include file ="emailtaggen.js" -->
<!-- #include file ="selectentity.js" -->
<!-- #include file ="SearchHistory.js" -->
<!-- #include file ="getFormMetadata.js" -->
<!-- #include file ="entrytype44.js" -->
<!-- #include file ="globalsearchPhone.js" -->
<!-- #include file ="globalsearchEmail.js" -->
<%

Glog("-----------------------file: entitySearch.asp");
var testurl=CRM.Url("sagecrmws/ac2020/entitySearch.asp");
Glog(testurl);
if (!Defined(Request.Form))
{
	//this allows us to test parsing of the data..clever
	Response.Clear();
	Response.Addheader("Content-type", "text/html");
	Response.Write("No POST data found. Do you mean to debug?");
	
	Response.Write('<form method="POST" >');
	Response.Write('<label for="Entity">Entity:</label><br>');
	Response.Write('<input type="text" id="Entity" name="Entity" value=""><br>');
	Response.Write('<label for="searchObject">searchObject:</label><br>');
	Response.Write('<textarea id="searchObject" name="searchObject" rows="20" cols="75">');
	Response.Write('</textarea><br>');	
	Response.Write('<br><input type="submit" value="Submit">');
	Response.Write('<form>');
	
	Response.Write('<br><br><a href="'+testurl+'" >This url</a>');
	Response.End();
	//sample url
	//"http://win-qb6s2mb2d3i//CRM2021r1/CustomPages/sagecrmws/ac2020/filesentemail.asp?SID=164606665648145"
}

var ignoreTags=false;//passed in by parseEmail

var NumberOfRecordsReturned=_baseConfig.listlength;
var itemsPerPage=Request.Form('itemsPerPage');
if (((itemsPerPage+"")=="undefined")||(itemsPerPage==null)||(itemsPerPage==""))
  itemsPerPage=_baseConfig.listlength;
if (!isNumeric(itemsPerPage)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid itemsPerPage found, page is "+Request.Form('itemsPerPage'));
  throw "No valid itemsPerPage found";
}  
NumberOfRecordsReturned=new Number(itemsPerPage);
if (isNaN(NumberOfRecordsReturned))
  NumberOfRecordsReturned=5;

///////////////////////page//////////////////////
var page=Request.Form('page');
if (((page+"")=="undefined")||(page==null)||(page==""))
  page=1;
page=new Number(page);
if (!isNumeric(page)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid page found, page is "+Request.Form('page'));
  throw "No valid page found";
}
///////////////////////sort by//////////////////////
var sortBy=Request.Form('sortBy');
if (((sortBy+"")=="undefined")||(sortBy==null)||(sortBy=="")||(sortBy=="[]"))
  sortBy="";
sortBy=new String(sortBy);

if (sortBy.indexOf('["')==0)
{
  sortBy=sortBy.substring(2,sortBy.length-2);
}
if ((sortBy!="")&&(!ValidDBColumn(sortBy)))
{
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid sortBy found, sortBy is "+Request.Form('sortBy'));
  throw "No valid sortBy found";
}
/////////////////////////////////////////////////////
var sortDesc=Request.Form('sortDesc');

if (((sortDesc+"")=="undefined")||(sortDesc==null)||(sortDesc=="")||(sortDesc=="[]"))
  sortDesc="";
sortDesc=new String(sortDesc);

if (sortDesc.indexOf('[')==0)
{
	sortDesc=sortDesc.substring(1,sortDesc.length-1);
	if (sortBy!="")
	{
	  if (sortDesc=="true")
		sortBy+=" desc";
	  else
		sortBy+=" asc";
	}
}
/////////////////////////////////////////////////////
/////////////////////////////////////////////////////
var entity=Request.Form('entity');

if (((entity+"")=="undefined")||(entity=="All")||(entity=="all"))
  entity="company";
entity=new String(entity);

if ((Defined(entity))&&(entity!="")&&(entity!="__email__"))
{
	var testtable=getTableInfo(entity);
	if (!Defined(testtable.name)){
	  //log to CRM's logs
	  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity found, entity is "+Request.Form('entity'));
	  throw "No valid Entity found";
	}
}

Glog("entitySearch.asp entity:"+entity);
/////////////////////////////////////////////////////
var searchObject=Request.Form('searchObject');
	


if ((searchObject+"")=="undefined")
  searchObject="{}";

searchObject = new String(searchObject);

Glog("entitySearch.asp searchObject: " + searchObject );
searchObject=JSON.parse(searchObject);

 //searchObject.sentItem=true;//test line only
 if (Defined(searchObject)&& Defined(searchObject.from))
 {
	 if (searchObject.from.emailAddress==null || searchObject.from.emailAddress=="")
	 {
		searchObject.from.emailAddress="noemailaddress@inthisemail.com";
		//so...we fix 2 issues here
		//internal systems sending emails with not emailAddress set (bad practice) so we flag this with that email address
		//also though...we treat these as sent emails
		searchObject.sentItem=true;
	 }else{
	   var _user_emailaddress=new String(CRM.GetContextInfo('user','user_emailaddress'));
	   _user_emailaddress=_user_emailaddress.toLowerCase();
	   if (!searchObject.sentItem && (searchObject.from.emailAddress.toLowerCase()==_user_emailaddress))
		searchObject.sentItem=true;//we assume its a sent email even
	 }
 }

if (searchObject.ignoreTags)
  ignoreTags=searchObject.ignoreTags;

function checkifParseCommand(searchObject){
  var res=false;//true if we think this is a parse call
  var _from=searchObject.from.emailAddress;
  _from=_from.toLowerCase();
  for(var oo=0;oo<searchObject.to.length;oo++)
  {
	var _to=searchObject.to[oo].emailAddress;
	_to=_to.toLowerCase();
	if (_to==_from){
		res=true;
		break;
	}	
  }
  if (!res){
	  for(var oo=0;oo<searchObject.cc.length;oo++)
	  {
		var _to=searchObject.cc[oo].emailAddress;
		_to=_to.toLowerCase();
		if (_to==_from){
			res=true;
			break;
		}		  
	  }  
  }
  return res;
}

var searchString="";
if ((typeof searchObject)=="string")
{
  searchString=searchObject;
}else{
  if ((searchObject!=null)&&(searchObject.from!=null))
  {
	searchString=searchObject.from.emailAddress;
	if ((searchObject.sentItem)&&(searchObject.to.length>0))
	{
		//check here in case the FROM is in TO or CC as if so then it might be a parse 
		if (!checkifParseCommand(searchObject))
		{
			searchString=searchObject.to[0].emailAddress;
			//FALLBACK for their strange case where we have seen an empty first item
			if ((searchString=="")&&(searchObject.to.length>1))
				searchString=searchObject.to[1].emailAddress;
		}
	}
	if (!validEmailAddress(searchString) && (searchString!=null) && (searchString.indexOf("/O=")==-1) &&(searchString!=""))
	{
	  ////
	  ////mr 1 Feb 24 added in.... 
	  ////             && (searchString.indexOf("/O=")==-1)
	  ////until we fix issue in outlook add in ...this just stops it crashing and logging the user out
	  ////
	   LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid email address found, EmaildataObj.from.emailAddress is "+searchString);
	   throw "No valid EmaildataObj.from.emailAddress found";
	}
  }
  else if (searchObject!=null)
	searchString=searchObject.searchstring;
}
if ((!searchString)||(searchString==null))
	searchString=new String(searchString);

if (searchString.indexOf("@TAG_")==0)
{
	searchObject={
		"subject":searchString,
		"body":searchString
	}
}
if (containsRestrictedKeywords(searchObject.subject))
{
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")contains Restricted Keywords "+searchObject.subject);
  //throw "containsRestrictedKeywords";
}	

if (containsRestrictedKeywords(searchObject.body))
{
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")contains Restricted Keywords "+searchObject.body);
  //throw "containsRestrictedKeywords";
}	

if ((searchObject)&&(searchObject.subject)&&(searchObject.subject.indexOf("@TAG_")==0 )){
  searchObject.subject=searchObject.subject.substr(5);
}
if ((searchObject)&&(searchObject.body)&&(searchObject.body.indexOf("@TAG_")==0 )){
  searchObject.body=searchObject.body.substr(5);
}

///tag parsing start
if ((!ignoreTags)&&(searchObject)&&(searchObject.subject!=null))
{
	Glog("entitySearch.asp tag parsing start:"+searchObject.subject);
	//check for a tag
	var tagPrefixSuffix = new String(GetWebConfigValue("tagPrefixSuffix"));
	var tagPrefixSuffix_arr=tagPrefixSuffix.split(",");
	var texttoSearch="";
	Glog("entitySearch.asp tag parsing index check:");
	if (searchObject.subject.indexOf(tagPrefixSuffix_arr[0])>-1)
	{
		texttoSearch=searchObject.subject;
	}else if ((searchObject.body)&&(searchObject.body.indexOf(tagPrefixSuffix_arr[0])>-1))
	{
		texttoSearch=searchObject.body;
	}
	Glog("entitySearch.asp texttoSearch:"+texttoSearch);
	var bodypart1=texttoSearch.substr(texttoSearch.indexOf(tagPrefixSuffix_arr[0]));
	var bodypart2=bodypart1.substr(tagPrefixSuffix_arr[0].length);
	var endingPrefixIndex=bodypart2.indexOf(tagPrefixSuffix_arr[1]);
	var bodypart3=bodypart1.substr(0,tagPrefixSuffix_arr[1].length+endingPrefixIndex+tagPrefixSuffix_arr[0].length);
			
	var _tagEntity=parseTag(bodypart3,tagPrefixSuffix_arr);
	Glog("entitySearch.asp _tagEntity:"+JSON.stringify(_tagEntity));
	var prev_entity=entity;
	entity=_tagEntity.entity;
	
	var _subjectfields = new String(GetWebConfigValue(_tagEntity.entity.toLowerCase()+"_subjectfields"));
	var _subjectfieldsarr=_subjectfields.split(",");
	if (_subjectfieldsarr.length<2)
	{
		//fallback when no config
		var _subjectfieldsarrENT=getTableInfo(entity);		
	    _subjectfieldsarr=[_subjectfieldsarrENT.name,_subjectfieldsarrENT.idfield];		
	}
	searchObject.searchfilter={};
	searchObject.searchfilter.entity=_tagEntity.entity;
	searchObject.searchfilter.entityid=_tagEntity.entityid;
	searchObject.searchfilter.whereclause=_subjectfieldsarr[1]+"='"+_tagEntity.entityTag+"'";  
	
		
	//test entity actually exists...mr put back in
	var _enttest=getTableInfo(searchObject.searchfilter.entity);		
	
	if (!_enttest.name)
	{
		//not a valid tag so reset the data..this can happen from another system using AC
		entity=prev_entity;
		//searchObject=null; 
	}

}
//tag parsing end

	//------------------------------NEW regexp data Part I start
	//check reg exp
    var searchStringRegEx = "";
	var _regexpMsg=[];
	var _regexSearches=[];//all strings searched on
	var _regexSearchesRes=[];//all strings searched on that have a result
	var bHasRegexSearch=false;
	if ((searchObject != null) && (typeof searchObject == "object")){		
		var acregex_Records = CRM.FindRecord("Custom_Captions", "capt_code like 'acregex%'");
		acregex_Records.OrderBy="capt_order";
		var res_arr = [];
		var res_tableData = [];
		while (!acregex_Records.eof) {
			
			var searchedAlready = [];
			var acregex = acregex_Records("capt_us");
			var acregex_entity = acregex_Records("capt_family");
			var acregex_params = acregex_Records("capt_de");
			var acregex_subjectcontains= acregex_Records("capt_es");
			_regexpMsg.push("-REGEX:"+acregex+"-ENTITY:"+acregex_entity);
			//_regexpMsg.push("-REGEX 2:"+acregex_subjectcontains);
			searchStringRegEx += "RegExp:" + acregex + " " + CRM.GetTrans("Entities",acregex_entity);
			var runRegexSearch = true;
			var regex_from_email = acregex_Records("capt_uk");
			_regexpMsg.push("-REGEX regex_from_email:"+regex_from_email);
			//if we have an email in capt_uk then only run regex if it is the same as email FROM
			if ((Defined(regex_from_email) && regex_from_email != "" && regex_from_email!=null ) || (regex_from_email=="*")) { 
				//searchStringRegEx += " reg exp from email:" + regex_from_email;					
				Glog("regex_from_email:" + new String(regex_from_email).toLowerCase());
                if (searchObject.sentItem)
				{
					if ((searchObject.sentItem)&&(searchObject.to.length>0))
					{
						Glog("searchobject email from address:" + new String(searchObject.to[0].emailAddress).toLowerCase())			
						runRegexSearch = (new String(regex_from_email).toLowerCase()) == (new String(searchObject.to[0].emailAddress).toLowerCase());				
						_regexpMsg.push("-FROM:"+regex_from_email+"=?="+searchObject.to[0].emailAddress+"="+runRegexSearch);
					}
				}
				else
				if (searchObject.from)
				{
					Glog("searchobject email from address:" + new String(searchObject.from.emailAddress).toLowerCase())			
					runRegexSearch = (new String(regex_from_email).toLowerCase()) == (new String(searchObject.from.emailAddress).toLowerCase());				
					_regexpMsg.push("-FROM:"+regex_from_email+"=?="+searchObject.from.emailAddress+"="+runRegexSearch);
				}
			}
			//flag used to only search using regex and not ALSO do normal email search
			if (regex_from_email=="*")
				runRegexSearch=true;
				
			if (runRegexSearch===true)
				bHasRegexSearch=true;
				
			if (regex_from_email=="*")
				bHasRegexSearch=false;				
			
			Glog("Run RegExp:" + acregex + " " + CRM.GetTrans("Entities",acregex_entity) + ":"+ runRegexSearch);
			var _sregexObj=null;
			try{
				_sregexObj=new RegExp(acregex,acregex_params);
			}catch(exreg){
				_regexpMsg.push("-ERROR:"+exreg.message);
			}
			//search subject 
			if ((searchObject.subject != null && runRegexSearch) &&
			   (!Defined(acregex_subjectcontains) || searchObject.subject.indexOf(acregex_subjectcontains)>-1)) { 
				var search_subject = new String(searchObject.subject);				
				var matched_subject = null;		
				try {					
					matched_subject = search_subject.match(_sregexObj);
					Glog("Regex "+acregex+" match result on subject '"+search_subject+"' : " + matched_subject);	
				} catch(e) {	
					searchStringRegEx += "-Error in regular expression " + acregex;
				}
				if (matched_subject != null) {
					_regexpMsg.push("-Subject matches:"+matched_subject.length);
					_regexpMsg.push("-"+matched_subject);
					for(var i=0; i < matched_subject.length;i++) {
						if (matched_subject[i]!="")
						{
							if (!contains(_regexSearches,matched_subject[i]))
							{
								Glog("...search subject for group " + matched_subject[i]);
								_regexSearches.push(matched_subject[i]);
								var regExpResult = doEntitySearch(acregex_entity, {},  "%" +matched_subject[i] ,"","","");	
								if ((regExpResult.data != null) && (regExpResult.data.tableData.length>0)){
									res_tableData = res_tableData.concat(regExpResult.data.tableData);	
									_regexSearchesRes.push(matched_subject[i]);								
								}
								if (validEmailAddress(matched_subject[i]))
								{
								   var gresY=globalSearch(matched_subject[i]);
								   gresY=JSON.parse(gresY);
								   if ((gresY)&& (gresY.data.tableData)&& (gresY.data.tableData.length>0))
								   {
										res_tableData = res_tableData.concat(gresY.data.tableData);
										if (!contains(_regexSearchesRes,matched_subject[i]))
										   _regexSearchesRes.push(matched_subject[i]);
								   }
								}								
							}
						}
					}
				} 
			}
		
			if ((searchObject.body != null && runRegexSearch) && 
			   (!Defined(acregex_subjectcontains) || (searchObject.subject!=null && searchObject.subject.indexOf(acregex_subjectcontains)>-1))) { 
					_regexpMsg.push("-Body search");
					//search body 
					if (searchObject.body != null) {
						var matched_body = null;
						var search_body = new String(searchObject.body);
						
						try {														
							matched_body = search_body.match(_sregexObj);
							Glog("Regex " + acregex + "  match result on body '"+search_body+"' : " + matched_body);	
						} catch(e) {
							//
							searchStringRegEx += "-Error in regular expression " + acregex;
						}				
						if (matched_body != null) {
							_regexpMsg.push("-Body matches:"+matched_body.length);
							_regexpMsg.push("-"+matched_body);
							for(var i=0; i < matched_body.length;i++) {
								if (matched_body[i]!="")
								{
									if (!contains(_regexSearches,matched_body[i]))
									{
										Glog("...search body for group " + matched_body[i]);
										_regexSearches.push(matched_body[i]);
										var regExpResult = doEntitySearch(acregex_entity, {}, "%" + matched_body[i] ,"","","");		
										if ((regExpResult.data != null) && (regExpResult.data.tableData.length>0)){
											res_tableData = res_tableData.concat(regExpResult.data.tableData);
											_regexSearchesRes.push(matched_body[i]);
										}
										if (validEmailAddress(matched_body[i]))
										{
										   var gresX=globalSearch(matched_body[i]);
										   gresX=JSON.parse(gresX);
										   if ((gresX)&& (gresX.data.tableData)&& (gresX.data.tableData.length>0))
										   {
												res_tableData = res_tableData.concat(gresX.data.tableData);
												if (!contains(_regexSearchesRes,matched_body[i]))
												   _regexSearchesRes.push(matched_body[i]);
											}
										}
									}
								}
							}
						}
					}
			}
			acregex_Records.NextRecord();
		} //end while
		
		//remove duplicates
		res_tableData=removeArrayDuplicates(res_tableData,"entity","entityid");
		
		var _gFormattedTableData=null;
		for(var pp=0;pp<res_tableData.length;pp++)
		{
			var _res_tableData_arr=globalSearch_Findrecord(res_tableData[pp].entityid, res_tableData[pp].entity,"","RegEx");
			if(_gFormattedTableData==null)
			  _gFormattedTableData=_res_tableData_arr
			else
			  _gFormattedTableData=_gFormattedTableData.concat(_res_tableData_arr);
		}
	}
	

	//------------------------------NEW regexp data Part I end

Glog("entitySearch.asp orderBy:"+sortBy);
if ((entity=="email"))
{
	if (bHasRegexSearch)
	{
		searchString="NOMATCHSTRING";
	}
	var gres=globalSearchEmail(searchString);

	gres=JSON.parse(gres);
	var GLOBAL_TIMEEND2 = new Date().getTime();
	var time = GLOBAL_TIMEEND2 - GLOBAL_TIMESTART;
	gres.screenMetadata.time=time;
	//------------------------------NEW regexp data Part II start
	if (_regexpMsg!="")
	{
	  gres.screenMetadata.regexpMsg=_regexpMsg;
	  gres.screenMetadata.regexSearches=_regexSearches;
	}	
	if(_gFormattedTableData!=null)
	{
	  gres.data.tableData=_gFormattedTableData.concat(gres.data.tableData);
	  gres.data.searchstring=_regexSearchesRes;
	}else
	if (bHasRegexSearch)
	{
		//no match so we show what was searched on
		gres.data.searchstring=_regexSearches;
	}
	if (!ignoreTags)
	{
		//is it already filed?
		var _msgstatus=checkMessage(searchObject.entryid);//Filed to Sage CRM message is from here...or not
		//add on any links to the filed communication also...
		//gres.data.tableData=_msgstatus.tableData.concat(gres.data.tableData);
		gres.data.tableData=gres.data.tableData.concat(_msgstatus.tableData);//append
		gres.screenMetadata.message=_msgstatus.message;
	}
	gres.data.recordcount=gres.data.tableData.length;
	
	gres=JSON.stringify(gres);

	Response.Write(gres);
	Response.End();
}else
if ((entity=="phone"))
{
	if (bHasRegexSearch)
	{
		searchString="NOMATCHSTRING";
	}
	Glog("entitySearchPhone.asp globalSearch:"+searchString);
	//removed this as users will search on blank....if ((searchString==null)||(searchString==""))
	  //searchString="__NODATA__";
	var gres=globalSearchPhone(searchString);

	gres=JSON.parse(gres);
	var GLOBAL_TIMEEND2 = new Date().getTime();
	var time = GLOBAL_TIMEEND2 - GLOBAL_TIMESTART;
	gres.screenMetadata.time=time;
	//------------------------------NEW regexp data Part II start
	if (_regexpMsg!="")
	{
	  gres.screenMetadata.regexpMsg=_regexpMsg;
	  gres.screenMetadata.regexSearches=_regexSearches;
	}	
	if(_gFormattedTableData!=null)
	{
	  gres.data.tableData=_gFormattedTableData.concat(gres.data.tableData);
	  gres.data.searchstring=_regexSearchesRes;
	}else
	if (bHasRegexSearch)
	{
		//no match so we show what was searched on
		gres.data.searchstring=_regexSearches;
	}
	//------------------------------NEW regexp data Part II end
	if (!ignoreTags)
	{
		//is it already filed?
		var _msgstatus=checkMessage(searchObject.entryid);//Filed to Sage CRM message is from here...or not
		//add on any links to the filed communication also...
		//gres.data.tableData=_msgstatus.tableData.concat(gres.data.tableData);
		gres.data.tableData=gres.data.tableData.concat(_msgstatus.tableData);//append
		gres.screenMetadata.message=_msgstatus.message;	
	}
	  gres.data.recordcount=gres.data.tableData.length;
	gres=JSON.stringify(gres);

	Response.Write(gres);
	Response.End();
}else
if ((entity=="")||(entity=="__email__"))
{
	if (bHasRegexSearch)
	{
		searchString="NOMATCHSTRING";
	}
	Glog("entitySearch.asp globalSearch:"+searchString);
	if (((searchString==null)||(searchString==""))&&((entity=="")||(entity=="__email__")))
	  searchString="__NODATA__";
	var gres=globalSearch(searchString);
	
	gres=JSON.parse(gres);
	var GLOBAL_TIMEEND2 = new Date().getTime();
	var time = GLOBAL_TIMEEND2 - GLOBAL_TIMESTART;
	gres.screenMetadata.time=time;
	//------------------------------NEW regexp data Part II start
	if (_regexpMsg!="")
	{
	  gres.screenMetadata.regexpMsg=_regexpMsg;
	  gres.screenMetadata.regexSearches=_regexSearches;
	}	
	if(_gFormattedTableData!=null)
	{
	  gres.data.tableData=_gFormattedTableData.concat(gres.data.tableData);
	  gres.data.searchstring=_regexSearchesRes;
	}else
	if (bHasRegexSearch)
	{
		//no match so we show what was searched on
		gres.data.searchstring=_regexSearches;
	}
	//------------------------------NEW regexp data Part II end
	if (!ignoreTags)
	{
		//is it already filed?
		var _msgstatus=checkMessage(searchObject.entryid);//Filed to Sage CRM message is from here...or not
		//add on any links to the filed communication also...
		//gres.data.tableData=_msgstatus.tableData.concat(gres.data.tableData);
		gres.data.tableData=gres.data.tableData.concat(_msgstatus.tableData);//append
		gres.screenMetadata.message=_msgstatus.message;
	}
	//magic tags...? 
	if (!ignoreTags)
	{
	
		var _magictags=checkMessageFileTo(searchObject);
		
		//Response.Write(JSON.stringify(_magictags));
		//Response.End();
		
		if (_magictags){
			var has100percentMatchConfidence=false;
			for (var tt=_magictags.length-1;tt>=0;tt--)
			{
				has100percentMatchConfidence=false;
				var tagitem=_magictags[tt];
				if (tagitem.matchconfidence==100)
					has100percentMatchConfidence=true;//note === did not work
					//Response.Write(tagitem.entity+"="+tagitem.entityid);
				var _magictags_tableData_arr=globalSearch_Findrecord(tagitem.entityid, tagitem.entity,"","SmartTags",tagitem);
				if (_magictags_tableData_arr && _magictags_tableData_arr.length>0){
					_magictags_tableData_arr[0].MatchConfidence=tagitem.matchconfidence;
					if (has100percentMatchConfidence){
						gres.data.tableData.unshift(_magictags_tableData_arr[0]);
					}else{
						gres.data.tableData=gres.data.tableData.concat(_magictags_tableData_arr);//lower scoring go down					
					}
				}
			}
			//remove any duplicates from the total response
			gres.data.tableData=removeArrayDuplicates(gres.data.tableData,"entity","entityid");
		
			if (_magictags.length>0)
			  gres.data.searchstring+=" & TAGS";
		}
	}
	
	gres.data.recordcount=gres.data.tableData.length;

	gres=JSON.stringify(gres);

	Response.Write(gres);
	Response.End();
}

Glog("entitySearch.asp doEntitySearch start:");
var resdoES=doEntitySearch(entity,searchObject,searchString,sortBy,NumberOfRecordsReturned,page);

	if (!ignoreTags)
	{
		//is it already filed?
		var _msgstatus=checkMessage(searchObject.entryid);//Filed to Sage CRM message is from here...or not
		//add on any links to the filed communication also...	
		//REMOVED THIS AS DOESNT MAKE SENSE IN THE UI ....resdoES.data.tableData=_msgstatus.tableData.concat(res.data.tableData);
		resdoES.screenMetadata.message=_msgstatus.message;
	}

var GLOBAL_TIMEEND = new Date().getTime();
var time = GLOBAL_TIMEEND - GLOBAL_TIMESTART;
resdoES.screenMetadata.time=time;

resdoES=JSON.stringify(resdoES);
Response.Write(resdoES);
Glog(resdoES);
Glog("entitySearch.asp doEntitySearch end:");
%>	