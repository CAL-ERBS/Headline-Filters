<%

function useCompanyfullmatch(searchString)
{
	var bcompanyfullmatch=GetWebConfigValue("companyfullmatch")=="Y";	
	if ((searchString.indexOf("@gmail.")>0) || (searchString.indexOf("@hotmail.")>0)
			||(searchString.indexOf("@yahoo.")>0)||(searchString.indexOf("@live.")>0)
			||(searchString.indexOf("@msn.")>0)||(searchString.indexOf("@aol.")>0)
			||(searchString.indexOf("@outlook.")>0)
			)
			bcompanyfullmatch=true;	
	return bcompanyfullmatch;
}

function globalSearch(searchString)
{
    Glog("globalSearch START:"+searchString);
	searchString=escapeSQL(searchString);
	var searchmessage="";//this is returned with information on the search
	var _cachedObj=getCache("globalSearch_"+searchString);
	if (_cachedObj!=null)
	{
	  //return _cachedObj;
	}	
    var searchString=new String(searchString);
    //search on person email
	var timetick1= new Date().getTime();
    var personids=globalSearch_person1(searchString);
	var timetick2= new Date().getTime();
    var person_tableData=globalSearch_Findrecord(personids, "person","","Person", {matchconfidence:100,matchon:CRM.GetTrans("Accelerator","Email Address")});
	var timetick3= new Date().getTime();
    Glog("globalSearch person:");

	var bcompanyfullmatch=useCompanyfullmatch(searchString);	
	
    //search on company email	
    var companyids=globalSearch_company2(searchString, bcompanyfullmatch);
	var timetick4= new Date().getTime();
    var company_tableData=globalSearch_Findrecord(companyids, "company","","Company", {matchconfidence:90,matchon:CRM.GetTrans("Colnames","eWorldServiceDomain")});
	var timetick5= new Date().getTime();
    Glog("globalSearch company:");
    //search on company email	
    var leadids=globalSearch_lead1(searchString);
	var timetick6= new Date().getTime();	
    var lead_tableData=globalSearch_Findrecord(leadids, "lead","","Company", {matchconfidence:95,matchon:CRM.GetTrans("Accelerator","Email Address")+"/"+CRM.GetTrans("Colnames","eWorldServiceDomain")});
	var timetick7= new Date().getTime();
	
    Glog("globalSearch lead:");

	if ((person_tableData.length==0)&&(company_tableData.length==0)&&(lead_tableData.length==0))
	{
		//search on company email based on person
		var __searchmessage=CRM.GetTrans("GenCaptions","CompanyMatchOnPerson")
		if (__searchmessage=="CompanyMatchOnPerson")
			__searchmessage="Company matches found based on people";
		
		var companyids=globalSearch_company1(searchString,bcompanyfullmatch);
		var company_tableData=globalSearch_Findrecord(companyids, "company","","Company", {matchconfidence:80,matchon:__searchmessage});
		if (company_tableData.length>0)
		{
			searchmessage=__searchmessage;
		}
		Glog("globalSearch company:");
	}

    var _tableData=person_tableData.concat(company_tableData).concat(lead_tableData);
    var recordcount=_tableData.length;
    Glog("globalSearch recordcount:"+recordcount);

    //put all data together
    var tableColumns=[];
    tableColumns.push({
        "value": "__Select__",
        "text": "",
		"sortable": false
    },{
        "value": "entity",
        "text": CRM.GetTrans("Accelerator","Entity"),
		"fieldType": "MyFormInput",
		"sortable": false
    },{
        "value": "Details",
        "text": CRM.GetTrans("Accelerator","Details"),
		"fieldType": "MyFormInput",
		"sortable": false
    },{
        "value": "matchon",
        "text": CRM.GetTrans("GenCaptions","MatchesThisValue"),
		"fieldType": "MyFormInput",
		"sortable": false
    },{
        "value": "matchconfidence",
        "text": CRM.GetTrans("Accelerator","Confidence"),
		"fieldType": "MyFormInput",
		"sortable": false
    });
    var res={
        "screenMetadata": {
			"sender":"globalSearch.js",
            "lang": getUserLang(),
			"timetick1":timetick2-timetick1,
			"timetick2":timetick3-timetick2,
			"timetick3":timetick4-timetick3,
			"timetick4":timetick5-timetick4,
			"timetick5":timetick6-timetick5,
			"timetick6":timetick7-timetick6
        },
        "data": {
            "recordcount":recordcount,
			"message":searchmessage,
			"bcompanyfullmatch":bcompanyfullmatch,
            "entity":"all",
            "MaxNumberOfRecordsReturned":NumberOfRecordsReturned,
            "searchstring":searchString,
            "tableData": _tableData	,
            "tableColumns": tableColumns
        }
    }
    res=JSON.stringify(res);
	if (NumberOfRecordsReturned>0)
	{	
		setCache("globalSearch_"+searchString,res);
	}	
    Glog("globalSearch END:"+res);
    return res;	
	
}

function globalSearch_person1(searchString)
{
    //Response.Write("globalSearch_person1 START:"+searchString);  
	var _cachedObj=getCache("globalSearch_person1_"+searchString);
	if (_cachedObj!=null)
	{
	  return _cachedObj;
	}
	var res="";
    var sql="select distinct top "+_baseConfig.listlength+" ELink_RecordID  "+
                    "from vPersonEmail where 43=43 and Emai_EmailAddress = '"+ searchString + "'";
    Glog("globalSearch_person1 SQL:"+sql);		

    var q1=CRM.CreateQueryObj(sql);	
    q1.SelectSQL();
    while (!q1.eof){
        if (res!="")
            res+=",";
        res+=q1.FieldValue("ELink_RecordID");
        q1.NextRecord();
    }
    Glog("globalSearch_person1 END:");  	

	if (res!="")
	{	
		setCache("globalSearch_person1_"+searchString,res);
	}
    return res;
}
//only searches on company email address
function globalSearch_company2(searchString,fullmatch)
{
	var _cachedObj=getCache("globalSearch_company2_"+searchString);
	if (_cachedObj!=null)
	{
	  return _cachedObj;
	}
	var res="";
    searchString=new String(searchString);
	var origsearchString=searchString;
    var searchString_arr=searchString.split("@");
    if (searchString_arr.length>1)
        searchString=searchString_arr[1];	
	if (fullmatch===true)
	{
		searchString=origsearchString;
	}
    var sql="select distinct top "+_baseConfig.listlength+" ELink_RecordID  "+
                    "from vCompanyEmail where 49=49 and Emai_EmailAddress  like '%"+ searchString + "%'";
    Glog("globalSearch_person1 SQL:"+sql);		

    var q1=CRM.CreateQueryObj(sql);	
    q1.SelectSQL();
    while (!q1.eof){
        if (res!="")
            res+=",";
        res+=q1.FieldValue("ELink_RecordID");
        q1.NextRecord();
    }
    Glog("globalSearch_company2 END:");  	

	if (res!="")
	{	
		setCache("globalSearch_company2_"+searchString,res);
	}
    return res;
}
function globalSearch_company1(searchString, fullmatch)
{
    Glog("globalSearch_company1 START:"+searchString);  
	var _cachedObj=getCache("globalSearch_company1_"+searchString);
	if (_cachedObj!=null)
	{
	  return _cachedObj;
	}	
    var res="";
    searchString=new String(searchString);
	var origsearchString=searchString;
    var searchString_arr=searchString.split("@");
    if (searchString_arr.length>1)
        searchString=searchString_arr[1];
	if (fullmatch===true)
	{
		searchString=origsearchString;
	}
	//NOTE: we use vEmailCompanyAndPerson as we want to find company matches 
	//on persons with an address like that....companies dont always have email addresses
	var sql="select distinct top 2 comp_companyid as ELink_RecordID "+
        "from vEmailCompanyAndPerson where 41=41 and comp_companyid is not null and Emai_EmailAddress like '%"+ searchString + "%'";
    Glog("globalSearch_company1:"+sql);				
    var q1=CRM.CreateQueryObj(sql);
    q1.SelectSQL();
	if (q1.recordcount>1)
	{
		return res;
	}
    while (!q1.eof){
        if (res!="")
            res+=",";
        res+=q1.FieldValue("ELink_RecordID");
        q1.NextRecord();
    }
    if (res!="")
	{	
		setCache("globalSearch_company1_"+searchString,res);
	}	
    Glog("globalSearch_company1 END:");  
    return res;
}

function globalSearch_lead1(searchString)
{
    Glog("globalSearch_lead1 START:"+searchString); 
    var res="";
	//check is lead in our search
	var _SearchEntityDefault=new String(GetWebConfigValue("SearchEntityDefault"));
	if (_SearchEntityDefault.indexOf("Lead")>-1)
		return res;
	
    searchString=new String(searchString);
    var searchString_arr=searchString.split("@");
    var domain="-";	
    if (searchString_arr.length>1)
        domain=searchString_arr[1];
	var wherec="733=733 and (lead_personemail='"+searchString+"' or lead_personemail like '%"+domain+"')";
	if (useCompanyfullmatch(searchString))
	{	
		wherec="73=73 and lead_personemail='"+searchString+"'";	
	}
    Glog("globalSearch_lead1:"+wherec);				
    var q1=CRM.FindRecord("lead,vsummarylead",wherec);	
    while (!q1.eof){
        if (res!="")
            res+=",";
        res+=q1("lead_leadid");
        q1.NextRecord();
    }
    Glog("globalSearch_lead1 END:");  
    return res;
}

//tagObject is used in magc search
function globalSearch_Findrecord(idvalues, entity,orderBy,dataMarker, tagObject)
{
	//dataMarker is used to flag where data came from
	if (!Defined(dataMarker))
		dataMarker="";
    //idvalues should be comma seperated list of person ids
    if (idvalues=="")
        return [];
    var timetick1= new Date().getTime();	
    var table=getTableInfo(entity);
    var fields=getSearchListFields(entity);
    var timetick2= new Date().getTime();	
    var qu=CRM.FindRecord(entity,"7230=7230 and "+table.idfield+" in ("+idvalues+")");
    var timetick3= new Date().getTime();	
	
	var qidvalues="-1";
	while(!qu.eof)
    {
		if (qidvalues!="")
			qidvalues+=",";
	  qidvalues+=qu.RecordID;
	  qu.NextRecord();
	}
	var qfields="";
	for(var c=0;c<fields.length;c++)
	{
		if (qfields!="")
			qfields+=",";
		qfields+=fields[c].name;
	}
	var qsql="select "+table.idfield+","+qfields +" from "+table.searchView +" where 44477=44477 and " + table.idfield+" in ("+qidvalues+")";
	if (qfields.toLowerCase().indexOf(table.idfield.toLowerCase())>-1)
		qsql="select "+qfields +" from "+table.searchView +" where 44477=44477 and " + table.idfield+" in ("+qidvalues+")";
    if (orderBy=="")
        qsql+=" order by "+fields[0].name;
	//Response.Write(qsql);
	var timetick4= new Date().getTime();
	var q=null
	try{
		q=CRM.CreateQueryObj(qsql);
		q.SelectSQL();
	}catch(err){
		Response.Write(qsql);
		Response.End();
	}
	var timetick5= new Date().getTime();
	
    var recordcount=q.recordcount;
    var tableData=[];
    var rowCount=0;
    while(!q.eof)
    {
        rowCount++;
		var _getTileIcon=getTileIcon(entity);
		var _getTileColour=getTileColour(entity);	
		var _tabtable=getTableInfo(entity);
		var _xfield={
				type:"31",
				name:_tabtable.idfield,
				lookup:entity
		}		
        _tmpobj={
            "count":rowCount,
            "entity":entity,
			"dataMarker":dataMarker,
            "entityid": q.FieldValue(table.idfield),
            "tilecolor":getTileColour(entity),
            "tileicon":getTileIcon(entity),
			"hasInternalLink":true,
			"externallink":{
				"url":getExternalLink(_xfield, q),
				"icon":_getTileIcon,
				"color":_getTileColour
			},
			"loadfielddatalinks":[],
			"matchconfidence":0,
			"matchon":""
        }
		if (tagObject)
		{
			_tmpobj.matchconfidence=tagObject.matchconfidence;
			_tmpobj.matchon=tagObject.matchon;
		}
        var details="";
        for(var c=0;c<fields.length;c++)
        {
            if (details!="")
                details+=",";
			try{
				var fvalue=q.FieldValue(fields[c].name);//using FieldValue is quicker!!!much quicker!!
				details+=getSearchListFieldsData(entity, fields[c], fvalue, true);
			}catch(erry){}
        }		
        _tmpobj["Entity"]=CRM.GetTrans("Entities",entity);
        _tmpobj["Details"]=details;
        _tmpobj["__Select__"]=true;
        tableData.push(_tmpobj);
        if (rowCount>=NumberOfRecordsReturned)
            break;
        q.NextRecord();
    }		

    return tableData;
}

%>