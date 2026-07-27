<!-- #include file ="sagecrm.js" -->

<!-- #include file ="_base_objects.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="configReader.js" -->
<!-- #include file ="helpers.js" -->
<!-- #include file ="mergefunctions.js" -->
<!-- #include file ="selectentity.js" -->
<!-- #include file ="emailtaggen.js" -->
<!-- #include file ="getFormMetadata.js" -->
<link rel="stylesheet" href="../css/bootstrap.min.css"/>
<%
////////////////
//custompages/sagecrmws/ac2020/mxtemplates.asp
////////////////

function formatDate(dt) {
    var d = new Date(dt);
    if (d.getFullYear() == 1899) {
        d=new Date();
    }
	//to do...use user date format
	//return    padLeft(d.getDate())  +"/" + padLeft(d.getMonth()+1) +"/" + d.getFullYear()  + " " + padLeft(d.getHours()) + ":" + padLeft(d.getMinutes());
	return     padLeft(d.getMonth()+1) +"/" +  padLeft(d.getDate()) +"/" + d.getFullYear()  + " " + padLeft(d.getHours()) + ":" + padLeft(d.getMinutes());	
}

function padLeft(n) {

	if (n<10) return "0"+n;
	return n;
}

function getTitle(s) {
    if (!Defined(s)) return "-";
    return new String(s);
}

function unDefinedToBlank(val){
  var res="";
  if (Defined(val))
    res=val;
  return res;
}

function fixupNewLine(strText){
  //%0D%0A  ..needed by mailto...html not supported
  var strText = strText.replace(/<\/p>/g, '%0D%0A');  
  return strText;
}

function RemoveHTML(strText)
{
  strText=fixupNewLine(strText);
	var regEx = /<[^>]*>/g;
  return strText.replace(regEx, "");
}


function __mergeEmail(entity,entityid,_emailobj)
{
	var tableNameView='';
	var table=getTableInfo(entity);
	if (entity+""!="undefined")
	{
	
		entity=new String(entity);
		var table=getTableInfo(entity);   
		//get the data
		entity=entity.toLowerCase();		
		if (entity=="cases")
		  entity="case";
		tableNameView=entity+",vsummary"+entity;

		var q=CRM.Findrecord(tableNameView,"8010=8010 and "+table.idfield+"="+entityid);
		
		entityres=_selectEntity(entity,entityid,q);
		
		if (entity.toLowerCase()=="lead")
			_emailobj.emailTo=q("lead_personemail");
		else	
		if ((entity.toLowerCase()=="company")&&(q("comp_emailaddress")))
			_emailobj.emailTo=q("comp_emailaddress");
		else
			_emailobj.emailTo=q("pers_emailaddress");		
		
		//merge the data now also!! to do !!!!!!!!!!!!!!!!!!!!!!!!!!!!
		hashFields = getHashFields(_emailobj.note);
		_emailobj.note  = doMerge(_emailobj.note, hashFields, q, table.prefix + "_", entity);	
		hashFields = getHashFields(_emailobj.note);
		_emailobj.note  = doMerge(_emailobj.note, hashFields, q, "pers_", "person");		
		hashFields = getHashFields(_emailobj.note);
		_emailobj.note  = doMerge(_emailobj.note, hashFields, q, "comp_", "company");	
		hashFields = getHashFields(_emailobj.note);
		_emailobj.note  = doMerge(_emailobj.note, hashFields, q, "addr_", "address");	
		hashFields = getHashFields(_emailobj.note);
		_emailobj.note  = doMerge(_emailobj.note, hashFields, q, "adli_", "address_link");	
		
		hashFields = getHashFields(_emailobj.email);
		_emailobj.email = doMerge(_emailobj.email, hashFields, q, table.prefix + "_", entity);		
		hashFields = getHashFields(_emailobj.email);
		_emailobj.email = doMerge(_emailobj.email, hashFields, q, "pers_", "person");	
		hashFields = getHashFields(_emailobj.email);
		_emailobj.email = doMerge(_emailobj.email, hashFields, q, "comp_", "company");	

		hashFields = getHashFields(_emailobj.email);
		_emailobj.email = doMerge(_emailobj.email, hashFields, q, "addr_", "address");	
		hashFields = getHashFields(_emailobj.email);
		_emailobj.email = doMerge(_emailobj.email, hashFields, q, "adli_", "address_link");		
		
	}

	//merge user data
	var user = CRM.FindRecord("Users", "4710=4710 and User_userid="  + CRM.GetContextInfo("user", "user_userid"));
	hashFields = getHashFields(_emailobj.note);
	_emailobj.note = doMerge(_emailobj.note, hashFields, user, 'user_','user');
	hashFields = getHashFields(_emailobj.email);
	_emailobj.email = doMerge(_emailobj.email, hashFields, user, 'user_','user');
	
	return _emailobj;
}

var __namedEntity=(Request.Querystring('entity'))+"";

var testtable=getTableInfo(__namedEntity);
if (!Defined(testtable.name)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity found, entity is "+Request.Form('entity'));
  throw "No valid Entity found";
}

var entityFilter=" and 11=11";

if (Defined(__namedEntity)){
	var entityFilter=" and 11=11";
	entityFilter="and (emte_entity='"+__namedEntity+"' or emte_entity is null)";
}

//get the data
var sql= "select emte_id, emte_name, emte_comm_from, emte_comm_replyto, emte_comm_note, " +
                "emte_comm_email, emte_to, emte_cc, emte_bcc from emailtemplates WITH (NOLOCK) " +
                "where emte_deleted is null "+entityFilter;

sql+=" order by emte_name";
				
var q=CRM.CreateQueryObj(sql);
q.SelectSQL();

var sHTML = "<div style='width:80%;margin:auto;padding:10px'><div style='float:left'><h5>"+
	CRM.GetTrans("Accelerator","EmailTemplates")
	+" for MobileX</h5></div><div style='float:right'><button type='button' class='btn btn-sm btn-link' onClick=\"document.location.reload()\"><img src='arrow-clockwise.png'/></button></div><br/>";
sHTML += "<br/><div style='clear: both;'><table width='100%' border=0>"

var entityid=Request.Querystring('id');
if (!isNumeric(entityid)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity ID found, entityid is "+Request.Form('entityid'));
  throw "No valid Entity ID found";
}

while(!q.eof)
{

	var _emailobj={
		"note":unDefinedToBlank(q("emte_comm_note")),
		"email":RemoveHTML(unDefinedToBlank(q("emte_comm_email")))
	}

	_emailobj=__mergeEmail(__namedEntity,entityid,_emailobj)
	var sUrl = "mailto:"+unDefinedToBlank(_emailobj.emailTo)+"?cc="+unDefinedToBlank(q("emte_cc"))+
		" &bcc="+unDefinedToBlank(q("emte_bcc"))+
		" &subject="+_emailobj.note+
		" &body="+_emailobj.email;
	
    sHTML += "<tr>";
    sHTML += "<td valign='top'><img src='calendar2-event.png'/>&nbsp;<span class='text-primary'>" + q("emte_name") +  
        "</span><br/><br/><span class='text-secondary'>"+ getTitle(q("emte_comm_note")) + "</span></td>" + 
        "<td valign='top' style='height: 41px;width: 41px;' >" + 
		"<a style='height: 41px;width: 41px;' target='_blank' href='"+ sUrl +"'><img src='envelope-plus.svg'/></a></div>" + 
		"</td>" + 
		"<td>&nbsp;&nbsp;&nbsp;</td>";
    sHTML += "</tr>";
    sHTML += "<tr colspan='2'><td><br/></td></tr>";

    q.NextRecord();    
}
sHTML += "</table></div></div>";
Response.Write(sHTML);
Response.End();

%>