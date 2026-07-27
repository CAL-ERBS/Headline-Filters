
<%
//CustomPages/SageCRMWS/ac2020/emailtaggen.asp

var Key0 = new String(Request.Querystring("Key0"));
var key0 = Key0.toString();
var entityName = "";

var Tag = null;
var entityCode = "";
var splitter="X";
var convertTagId = "";

var ConvertTags = true;
var ReferenceId = null;
var NormalEntityName = "";

function getEntityTagID(entity,entityTag)
{
	var entity=new String(entity);
	var _subjectfields = new String(GetWebConfigValue(entity.toLowerCase()+"_subjectfields"));
	var _subjectfieldsarr=_subjectfields.split(",");
	searchObject.searchfilter={};
	searchObject.searchfilter.entity=_tagEntity.entity;
	searchObject.searchfilter.entityid=_tagEntity.entityTag;
	searchObject.searchfilter.whereclause=_subjectfieldsarr[1]+"='"+_tagEntity.entityTag+"'";  
}

function getEntityTag(_entityName, entityID)
{
	entityName=new String(_entityName);
	var entitySubjectfields = entityName.toLowerCase() + "_subjectfields";

	var entityCodetag = entityName.toLowerCase()  + "_codetag";
	var tagPrefixSuffix = "tagPrefixSuffix";

	ReferenceId=GetConfigValue(entitySubjectfields,entityCodetag,tagPrefixSuffix,entityName);
		
	if (ReferenceId==null)
	{
		var tabinfo=getTableInfo(_entityName);
		ReferenceId=tabinfo.idfield;
	}
	
	var table=getTableInfo(entityName);
	var tagID="";
	var sql="select "+ReferenceId+" from "+table.name+" where "+table.idfield+"="+entityID+"";
	var q1=null;
	try{
		q1=CRM.CreateQueryObj(sql);
		q1.SelectSQL();
	}catch(_esqlerr){
		Response.Write(sql);
		Response.End();
	}
	if (!q1.eof)
	{
		tagID=q1(ReferenceId);
	}
	if (ConvertTags)
	{
		entityCode=convertEntityName(entityName);
		for (var count = 0 ; count < tagID.length; count++)
		{		
			convertTagId = convertTagId + convertEntityId(tagID.charAt(count));		
		}
	}else{
		entityCode = NormalEntityName;
		convertTagId = tagID;
		splitter=",";
	}

	return Tag[0]+entityCode+splitter+convertTagId+Tag[1];

}

function GetConfigValue(entitySubjectfields,entityCodetag,tagPrefixSuffix,entityName) {
    var ReferenceId=null;

	var value1 = GetWebConfigValue(entitySubjectfields);
	
	if (!Defined(value1))
	{
		//reset the config
		Application("webconfig")=null;
		value1 = GetWebConfigValue(entitySubjectfields);
	}
		
	if (value1==null || (!Defined(value1)) )  
	{
		var tabinfo=getTableInfo(entityName);
		value1=tabinfo.idfield;
	}
	temp = value1.split(",");
	
	NormalEntityName = temp[0];
	ReferenceId = temp[1];

	var value2 = GetWebConfigValue(entityCodetag);
	if (!Defined(value2))
	{
		//reset the config
		Application("webconfig")=null;
		value2 = GetWebConfigValue(entityCodetag);
	}	
	if ( value2 == "true")
		ConvertTags = true
	else if (value2 == "false")
		ConvertTags = false		

	var value3 = GetWebConfigValue(tagPrefixSuffix);
	if (!Defined(value3))
	{
		//reset the config
		Application("webconfig")=null;
		value3 = GetWebConfigValue(tagPrefixSuffix);
	}		
	Tag = value3.split(",");	

	return ReferenceId;
}

function convertEntityName(entityName){
	var _entityName=new String(entityName);
	_entityName = _entityName.toLowerCase() 
	switch(_entityName) {
		case "communication":
			entityCode = "VV";
			break;
		case "lead":
			entityCode = "AA";
			break;
		case "case":
			entityCode =  "BB";
			break;
		case "cases":
			entityCode =  "BB";
			break;		
		case "company":
			entityCode =  "NN";
			break;
		case "person":
			entityCode =  "II";
			break;
		case "solution":
			entityCode =  "OO";
			break;
		case "opportunity":
			entityCode =  "YY";
			break;
		case "orders":
			entityCode =  "EE";
			break;
		case "quotes":
			entityCode =  "SS";
			break;
		default:
			entityCode = entityName;
			break;			
	}
	return entityCode;
}

function convertEntityId(c){ 
	switch(c)
	{
		case ",":
			return "X";
			break;
		case "1":
			return "M";
			break;
		case "2":
			return "D";
			break;
		case "3":
			return "Z";
			break;
		case "4":
			return "R";
			break;
		case "5":
			return "T";
			break;
		case "6":
			return "U";
			break;
		case "7":
			return "K";
			break;
		case "8":
			return "P";
			break;
		case "9":
			return "F";
			break;
		case "0":
			return "L";
			break;
		default:
			return c;
			break;
	}
}

function convertEntityNameBack(entityCode){
	var entityCode=new String(entityCode);
	entityCode = entityCode.toUpperCase();
	var entityName="";
	switch(entityCode) {
		case "VV":
			entityName = "communication";
			break;
		case "AA":
			entityName = "lead";
			break;
		case "BB":
			entityName =  "cases";
			break;	
		case "NN":
			entityName =  "company";
			break;
		case "II":
			entityName =  "person";
			break;
		case "YY":
			entityName =  "opportunity";
			break;
		case "EE":
			entityName =  "orders";
			break;
		case "SS":
			entityName =  "quotes";
			break;
		default:
			entityName = entityCode;
			break;			
	}
	return entityName;
}

function convertEntityIdBack(c){ 
	var res="";
	c=new String(c);
	var carr=c.split("");
	for (var i = 0; i < carr.length; i++) {
		switch(carr[i])
		{
			case "M":
				res+= "1";
				break;
			case "D":
				res+= "2";
				break;
			case "Z":
				res+= "3";
				break;
			case "R":
				res+= "4";
				break;
			case "T":
				res+= "5";
				break;
			case "U":
				res+= "6";
				break;
			case "K":
				res+= "7";
				break;
			case "P":
				res+= "8";
				break;
			case "F":
				res+= "9";
				break;
			case "L":
				res+= "0";
				break;
			default:
				res+= c;
				break;
		}
	}
	return res;
}

function parseTag(val,tagPrefixSuffix_arr)
{
	Glog("parseTag val:"+val);
	Glog("parseTag tag format:"+tagPrefixSuffix_arr);
	var val=new String(val);
	if (val.length==0)
	{
		return {
			entity:"",
			entityTag:""
		}
	}
	Glog("parseTag #1");

	val=val.substr(tagPrefixSuffix_arr[0].length);
	val=val.substr(0,val.length-tagPrefixSuffix_arr[1].length);
	Glog("parseTag #2:"+val);
	if (val=="")
	{
		return {
			entity:"",
			entityTag:""
		}
	}
	if (val.length>20)
	{
		//if we get here the parsing has gone wrong
		return {
			entity:"",
			entityTag:""
		}
	}	
	if (val.indexOf(",")>0)
	{
		//non-coded tags
		var valarr=val.split(",");
		var _entity=valarr[0];
		var _entityTag=valarr[1];
		return {
			entity:_entity,
			entityTag:_entityTag
		}
	}else{
		var valarr=val.split("X");
		Glog("parseTag #3:"+valarr);
		var _entity=convertEntityNameBack(valarr[0]);
		var _entityTag=convertEntityIdBack(valarr[1]);
		Glog("parseTag #4:"+_entity+"="+_entityTag);
		return {
			entity:_entity,
			entityTag:_entityTag
		}
	}
}

function isValidTable(tablename)
{
	var _cachekey="isValidTable_"+tablename;
	var _cachedObj=getCache(_cachekey);
	if (_cachedObj!=null)
	{
	  return _cachedObj;
	}	

	var res=false;
	var sql="select bord_tableid, bord_name,bord_idfield,Bord_RecDescriptor,Bord_Prefix,bord_DescriptionField,"+
					" Bord_HasCommunication,Bord_HasLibrary"+
        " from custom_tables where bord_name='" + tablename + "'";
	var q1=CRM.CreateQueryObj(sql);	
	try{
		q1.SelectSQL();
	}catch(e)
	{
		//7.3 ?-we dont support it strictly speaking
		sql="select bord_tableid, bord_name,bord_idfield,'' as Bord_RecDescriptor,Bord_Prefix,bord_DescriptionField,"+
					" Bord_HasCommunication,Bord_HasLibrary"+
        " from custom_tables where bord_name='" + tablename + "'";
		q1=CRM.CreateQueryObj(sql);	
	}
	if (!q1.eof)
	{	
		res=true;
		setCache(_cachekey,res);
	}
	return res;
}

function extractTag(texttoSearch)
{
	Glog("extractTag");
	if (!Defined(texttoSearch))
	  return '';
	//check for a tag
	var tagPrefixSuffix = new String(GetWebConfigValue("tagPrefixSuffix"));
	var tagPrefixSuffix_arr=tagPrefixSuffix.split(",");
	var bodypart1=texttoSearch.substr(texttoSearch.indexOf(tagPrefixSuffix_arr[0]));
	var bodypart2=bodypart1.substr(tagPrefixSuffix_arr[0].length);
	var endingPrefixIndex=bodypart2.indexOf(tagPrefixSuffix_arr[1]);
	var bodypart3=bodypart1.substr(0,tagPrefixSuffix_arr[1].length+endingPrefixIndex+tagPrefixSuffix_arr[0].length);
	Glog("extractTag #1");
	bodypart3=bodypart3.trim();
	Glog(bodypart3);
	var _tagEntity=parseTag(bodypart3,tagPrefixSuffix_arr);
	Glog("_tagEntity="+JSON.stringify(_tagEntity));
	_tagEntity.entityid=_tagEntity.entityTag;
	if(!isValidTable(_tagEntity.entity))
	{
		_tagEntity.entity="";
		_tagEntity.entityTag="";
	}
	if (_tagEntity.entity!="")
	{
		Glog("extractTag entity:"+_tagEntity.entity);
		//example _tagEntity...{"entity":"Cases","entityTag":"0-11960"}
		var _subjectfields = new String(GetWebConfigValue(_tagEntity.entity.toLowerCase()+"_subjectfields"));
		Glog("extractTag _subjectfields:"+_subjectfields);
		var _subjectfieldsarr=_subjectfields.split(",");
		
var testtable=getTableInfo(_tagEntity.entity);
if (!Defined(testtable.name)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity found in tag, entity is "+_tagEntity.entity);
  throw "No valid Entity found in tag";
}		

		var tagq=CRM.Findrecord(_tagEntity.entity,_subjectfieldsarr[1]+"='"+escapeSQL(_tagEntity.entityTag)+"'");	
		Glog("extractTag #8:"+_tagEntity.entity,_subjectfieldsarr[1]+"='"+escapeSQL(_tagEntity.entityTag)+"'");
		if (!tagq.eof)
		{
			Glog("extractTag found data:");
			var tagqtable=getTableInfo(_tagEntity.entity); 
			Entity=_tagEntity.entity;
			EntityId=tagq(tagqtable.idfield);
			_tagEntity.entityid=EntityId;
		}
	}
	return _tagEntity;
}
%>