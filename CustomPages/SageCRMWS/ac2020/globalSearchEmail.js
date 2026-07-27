<%

function globalSearchEmail(searchString)
{
    Glog("globalSearchEmail START:"+searchString);
	var searchmessage="";//this is returned with information on the search
	var _cachedObj=getCache("globalSearchEmail_"+searchString);
	if (_cachedObj!=null)
	{
	  //return _cachedObj;
	}	
    var searchStringOrigional=new String(searchString);
	searchString=searchStringOrigional.replace(/ /g, "");;
	searchString=escapeSQL(searchString);
    //search on person email
	var timetick1= new Date().getTime();
    var person_data=globalSearchEmail_person1(searchString);
	var timetick2= new Date().getTime();
    var person_tableData=globalSearchEmail_Findrecord(person_data, "person");
	var timetick3= new Date().getTime();
    Glog("globalSearch person:");

    //search on company email	
    var company_data=globalSearchEmail_company2(searchString);
	var timetick4= new Date().getTime();
    var company_tableData=[];
	if (Defined(company_data) && company_data.length>0)
		company_tableData=globalSearchEmail_Findrecord(company_data, "company");	
	var timetick5= new Date().getTime();
    Glog("globalSearch company:");
    //search on company email	
    var lead_data=globalSearchEmail_lead1(searchString);
	var timetick6= new Date().getTime();	
    var lead_tableData=globalSearchEmail_Findrecord(lead_data, "lead");
	var timetick7= new Date().getTime();
	
    Glog("globalSearchEmail lead:");

    var _tableData=person_tableData.concat(company_tableData).concat(lead_tableData);
    var recordcount=_tableData.length;
    Glog("globalSearchEmail recordcount:"+recordcount);

    //put all data together
    var tableColumns=[];
    tableColumns.push({
        "value": "__Select__",
        "text": "",
		"sortable": false
    },{
        "value": "Email",
        "text": CRM.GetTrans("Accelerator","Email"),
		"fieldType": "MyFormInput",
		"sortable": false
    },{
        "value": "Details",
        "text": CRM.GetTrans("Accelerator","Details"),
		"fieldType": "MyFormInput",
		"sortable": false
    });
    var res={
        "screenMetadata": {
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
            "entity":"email",
            "MaxNumberOfRecordsReturned":NumberOfRecordsReturned,
            "searchstring":searchStringOrigional,
			"searchstringused":searchString,
            "tableData": _tableData	,
            "tableColumns": tableColumns,
			"fallbacksearch":true
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

function globalSearchEmail_person1(searchString)
{
    //Response.Write("globalSearch_person1 START:"+searchString);  
	var _cachedObj=getCache("globalSearchEmail_person1_"+searchString);
	if (_cachedObj!=null)
	{
	  return _cachedObj;
	}
	var res={
		"ids":[],
		"Emailnos":[]
		};
    var sql="select distinct top "+_baseConfig.listlength+" view_RecordId, index_descriptor  "+
                    "from vEmailComposer where 43=43 and "+
					"view_EntityName='Person' and index_descriptor like '%"+ searchString + "%'"+
					" and index_descriptor is not null";
    //Response.Write("globalSearch_person1 SQL:"+sql);		

    var q1=CRM.CreateQueryObj(sql);	
    q1.SelectSQL();
    while (!q1.eof){
        if (res["ids"]!=""){
            res["ids"]+=",";
			res["Emailnos"]+=",";
		}
        res["ids"]+=q1.FieldValue("view_RecordId");
		res["Emailnos"]+=q1.FieldValue("index_descriptor");
        q1.NextRecord();
    }
    Glog("globalSearch_person1 END:");  	

	if (res!="")
	{	
		setCache("globalSearchEmail_person1_"+searchString,res);
	}
    return res;
}
//only searches on company email address
function globalSearchEmail_company2(searchString,fullmatch)
{
	var _cachedObj=getCache("globalSearchEmail_company2_"+searchString);
	if (_cachedObj!=null)
	{
	  return _cachedObj;
	}
	var res={
		"ids":[],
		"Emailnos":[]
		};
    searchString=new String(searchString);
	var origsearchString=searchString;
    var searchString_arr=searchString.split("@");
    if (searchString_arr.length>1)
        searchString=searchString_arr[1];	
	if (fullmatch===true)
	{
		searchString=origsearchString;
	}
    var sql="select distinct top "+_baseConfig.listlength+" view_RecordId, index_descriptor  "+
                    "from vEmailComposer where 49=49 and "+
					"view_EntityName='Company' and index_descriptor like '%"+ searchString + "%'"+
					" and index_descriptor is not null";
    Glog("globalSearch_person1 SQL:"+sql);		

    var q1=CRM.CreateQueryObj(sql);	
    q1.SelectSQL();
    while (!q1.eof){
        if (res["ids"]!=""){
            res["ids"]+=",";
			res["Emailnos"]+=",";
		}
        res["ids"]+=q1.FieldValue("view_RecordId");
		res["Emailnos"]+=q1.FieldValue("index_descriptor");
        q1.NextRecord();
    }
    Glog("globalSearch_company2 END:");  	

	if (res!="")
	{	
		setCache("globalSearchEmail_company2_"+searchString,res);
	}
    return res;
}
function globalSearchEmail_company1(searchString, fullmatch)
{
    Glog("globalSearch_company1 START:"+searchString);  
	var _cachedObj=getCache("globalSearchEmail_company1_"+searchString);
	if (_cachedObj!=null)
	{
	  return _cachedObj;
	}	
	var res={
		"ids":[],
		"Emailnos":[]
		};
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
	var sql="select distinct top 2 view_RecordId, index_descriptor "+
        "from vEmailComposer where 41=41 and "+
		"view_EntityName='Company' and index_descriptor like '%"+ searchString + "%'"+
					" and index_descriptor is not null";
    Glog("globalSearch_company1:"+sql);				
    var q1=CRM.CreateQueryObj(sql);
    q1.SelectSQL();
	if (q1.recordcount>1)
	{
		return res;
	}
    while (!q1.eof){
        if (res["ids"]!=""){
            res["ids"]+=",";
			res["Emailnos"]+=",";
		}
        res["ids"]+=q1.FieldValue("view_RecordId");
		res["Emailnos"]+=q1.FieldValue("index_descriptor");
        q1.NextRecord();
    }
    if (res!="")
	{	
		setCache("globalSearchEmail_company1_"+searchString,res);
	}	
    Glog("globalSearch_company1 END:");  
    return res;
}

function globalSearchEmail_lead1(searchString)
{
	var _cachedObj=getCache("globalSearchEmail_lead_"+searchString);
	if (_cachedObj!=null)
	{
	  //return _cachedObj;
	}
	var res={
		"ids":[],
		"Emailnos":[]
		};
    searchString=new String(searchString);
    var sql="select distinct top "+_baseConfig.listlength+" view_RecordId, index_descriptor  "+
                    "from vEmailComposer where 49=49 and "+
					"view_EntityName='Lead' and index_descriptor like '%"+ searchString + "%'"+
					" and index_descriptor is not null";
    //Response.Write("globalSearchEmail_lead1 SQL:"+sql);		

    var q1=CRM.CreateQueryObj(sql);	
    q1.SelectSQL();
    while (!q1.eof){
        if (res["ids"]!=""){
            res["ids"]+=",";
			res["Emailnos"]+=",";
		}
        res["ids"]+=q1.FieldValue("view_RecordId");
		res["Emailnos"]+=q1.FieldValue("index_descriptor");	
        q1.NextRecord();
    }
    Glog("globalSearchEmail_lead END:");  	

	if (res!="")
	{	
		setCache("globalSearchEmail_lead_"+searchString,res);
	}
    return res;
}

function globalSearchEmail_Findrecord(idvalues, entity,orderBy)
{	
    //idvalues should be comma seperated list of person ids
    if (idvalues["ids"]=="")
        return [];
	
	//Response.Write(JSON.stringify(idvalues));
    var timetick1= new Date().getTime();	
    var table=getTableInfo(entity);
    var fields=getSearchListFields(entity);
    var timetick2= new Date().getTime();	
    var qu=CRM.FindRecord(entity,"9230=9230 and "+table.idfield+" in ("+idvalues["ids"]+")");
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
	var qsql="select "+table.idfield+","+qfields +" from "+table.searchView +" where " + table.idfield+" in ("+qidvalues+")";
    if (orderBy=="")
        qsql+=" order by "+fields[0].name;
	//	Response.Write(qsql);
	var timetick4= new Date().getTime();
	var q=CRM.CreateQueryObj(qsql);
	q.SelectSQL();
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
            "entityid": q.FieldValue(table.idfield),
            "tilecolor":getTileColour(entity),
            "tileicon":getTileIcon(entity),
			"hasInternalLink":true,
			"externallink":{
				"url":getExternalLink(_xfield, q),
				"icon":_getTileIcon,
				"color":_getTileColour
			},
			"loadfielddatalinks":[]
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
		_tmpobj["Email"]=getSearchEmailFromArrays(q.FieldValue(table.idfield), idvalues);
        _tmpobj["Details"]=details;
        _tmpobj["__Select__"]=true;
        tableData.push(_tmpobj);
        if (rowCount>=NumberOfRecordsReturned)
            break;
        q.NextRecord();
    }		

    return tableData;
}
function getSearchEmailFromArrays(_id,_idvalues)
{
	var idsArray = _idvalues.ids.split(',');
	var EmailArray = _idvalues.Emailnos.split(',');
	// Find the index of the value "20" in the array
	// Initialize a variable to store the index
    var index = -1;
    // Loop through the array to find the index of the value "20"
    for (var i = 0; i < idsArray.length; i++) {
        if (idsArray[i] === _id) {
            index = i;
            break; // Exit the loop when the value is found
        }
    }

	return EmailArray[index];
}

%>