<!-- #include file ="../sagecrm.js" -->
<!-- #include file ="SQLReportfuncs.js" -->
<%

container = CRM.GetBlock('container');
container.DisplayButton(Button_Default) = false;
content = CRM.GetBlock('content');
container.AddBlock(content);

var _regexcode="";
var _subject="";
var _body="";
var _subjectMatch="";
var _bodyMatch="";
var _msg="";
var _regexcodeparam="";
var _mappedfield="";
var _Extract="";
var _Entity="";
var _Family="";
var _code="";
var _order="";

if (Defined(Request.Form("regexcode")))
  _regexcode=new String(Request.Form("regexcode"));
if (Defined(Request.Form("regexcodeparam")))
  _regexcodeparam=new String(Request.Form("regexcodeparam"));  
if (Defined(Request.Form("subject")))
  _subject=new String(Request.Form("subject"));
if (Defined(Request.Form("body")))
  _body=new String(Request.Form("body"));

/*
var _regexcode = "\\d+\\/[0-9]"
var re=new RegExp(_regexcode);
if (re.test(_subject))
{
  _msg="Reg ex is valid";
}else{
  _msg="INVALID REGEXP";
}*/
var _regexcodeOrig=_regexcode;

/************************
test with
      \d+\/[0-9]
and search string
       this is 143/1 an example
*************************/
var re=null;
//matches on email domain...crmtogether.com
//_regexcode="((?:[a-z0-9-]+\\.)*)([a-z0-9-]+\\.[a-z]+)($|\\s|\\:\\d{1,5})";

try{
    if (_regexcodeparam && _regexcodeparam!="")
		re=new RegExp(_regexcode,_regexcodeparam);
	else
		re=new RegExp(_regexcode);
}catch(e) { 
	_msg="INVALID REGULAR EXPRESSION";
}
var _colors="red";
var _colorb="red";
if (Defined(Request.Form("regexcode"))){
	var matched_subject = _subject.match(re);
	if (matched_subject != null) {
		_colors="green";
		_subjectMatch=matched_subject.length+" Match(es) in Subject found: <b>"+matched_subject+"</b>";
	}else
	  _subjectMatch="No Match on Subject for: "+_regexcodeOrig;
	var matched_body = _body.match(re);
	if (matched_body != null) {
		_colorb="green";
		_bodyMatch=matched_body.length+" Match(es) in Body found: <b>"+matched_body+"</b>";
	}else
		_bodyMatch="No Match on Body for: "+_regexcodeOrig;
}

_subjectMatch="<span style='color:"+_colors+"'  >"+_subjectMatch+"</span>";
_bodyMatch="<span style='color:"+_colorb+"'  >"+_bodyMatch+"</span>";

content.contents+=("<br><br>Utility screen to help manage regular expressions in Accelerator<br><br>");
content.contents+=('<form method="POST" >');
content.contents+=('<label for="regexcode">Regular Expression:</label><br>');
content.contents+=('<input type="text" id="regexcode" name="regexcode" value="'+_regexcodeOrig+'"  size="100"  ><br>');
content.contents+=('<label for="regexcodeparam">Regular Expression Options (EG gi):</label><br>');
content.contents+=('<input type="text" id="regexcodeparam" name="regexcodeparam" value="'+_regexcodeparam+'"  size="100"  ><br>');
content.contents+=('<br><br><input type="submit" value="Run Test">');
content.contents+=('<br><br><br>');
/*
content.contents+=('<label for="nothing"><b>Parse Fields:</b></label><br>');
content.contents+=('<label for="Family">Family:</label><br>');
content.contents+=('<input type="text" id="Family" name="Family" value="'+_Family+'"  size="30"  ><br>');
content.contents+=('<label for="code">Code:</label><br>');
content.contents+=('<input type="text" id="code" name="code" value="'+_code+'"  size="30"  ><br>');
content.contents+=('<label for="Entity">Entity:</label><br>');
content.contents+=('<input type="text" id="Entity" name="Entity" value="'+_Entity+'"  size="30"  ><br>');
content.contents+=('<label for="Extract">Extract Text from result:</label><br>');
content.contents+=('<input type="text" id="Extract" name="Extract" value="'+_Extract+'"  size="100"  ><br>');
content.contents+=('<label for="mappedfield">Mapped Field (for person name the value is "fullname"):</label><br>');
content.contents+=('<input type="text" id="mappedfield" name="mappedfield" value="'+_mappedfield+'"  size="100"  ><br>');
content.contents+=('<label for="order">Order:</label><br>');
content.contents+=('<input type="text" id="order" name="order" value="'+_order+'"  size="10"  ><br>');
*/
content.contents+=('<label for="subject">Subject:</label><br>');
content.contents+=('<input type="text" id="subject" name="subject" value="'+_subject+'" size="100" ><br>');	
content.contents+=('<label">Subject Matches: '+_subjectMatch+'</label><br><br><br>');
content.contents+=('<label for="body">Body:</label><br>');
content.contents+=('<textarea id="body" name="body" rows="20" cols="100" >'+_body);
content.contents+=('</textarea><br>');	
content.contents+=('<label">Body Matches: '+_bodyMatch+'</label><br><br><br>');
content.contents+=('<br><input type="submit" value="Run Test">');
content.contents+=('<br><br><label for="msg">'+_msg+'</label><br>');
content.contents+=('<form>');

var objar=new Array();

var _obj=new Object();
_obj.sql="select * from Custom_Captions where capt_deleted is null and capt_code like 'acregex%' order by Capt_Order";

_obj.title="Parse and Search Settings";
_obj.columns=new Array();
_obj.columnsX=new Array();

_obj.columnsX.push({"name":"Capt_code", "title":"Code"});
_obj.columnsX.push({"name":"Capt_Family", "title":"Entity"});
_obj.columnsX.push({"name":"Capt_uk", "title":"Email Address"});
_obj.columnsX.push({"name":"Capt_FR", "title":"Description"});
_obj.columnsX.push({"name":"Capt_US", "title":"Regular expression"});
_obj.columnsX.push({"name":"Capt_DE", "title":"options"});
_obj.columnsX.push({"name":"Capt_Order", "title":"Order"});

//	_obj.columnsX.push({"name":"prsu_accmgr_partner", "title":"Account Manager Email","email":getEmailLink,"linkparams":["prsu_accmgr_partner"]});

_obj.showRowCount=true;
objar.push(_obj);

//select * from Custom_Captions where capt_family = 'EmailParse'
var sqlEmailParse="select * from Custom_Captions where capt_deleted is null and capt_family = 'EmailParse'";
var qEmailParse=CRM.CreateQueryObj(sqlEmailParse);
qEmailParse.SelectSQL();
while (!qEmailParse.eof)
{
  var _objx=new Object();
  _objx.sql="select * from Custom_Captions where capt_deleted is null and capt_family = '"+qEmailParse("capt_uk")+"' order by Capt_Order";

	_objx.title="Parse Data when NEW screen opened (Parent Record capt_family=EmailParse, Parse Group='"+qEmailParse("capt_uk")+"')";
	if (Defined(qEmailParse("capt_us")))
		_objx.title+= "for FROM email address: "+qEmailParse("capt_us");
	_objx.columns=new Array();
	_objx.columnsX=new Array();

	_objx.columnsX.push({"name":"Capt_family", "title":"Parse Group"});
	_objx.columnsX.push({"name":"Capt_Code", "title":"Code"});
	_objx.columnsX.push({"name":"Capt_US", "title":"Entity"});
	_objx.columnsX.push({"name":"Capt_UK", "title":"Regular expression"});
	_objx.columnsX.push({"name":"Capt_DE", "title":"Extract Text from result"});
	_objx.columnsX.push({"name":"Capt_fr", "title":"options"});	
	_objx.columnsX.push({"name":"Capt_es", "title":"Mapped Field"});
	_objx.columnsX.push({"name":"Capt_Order", "title":"Order"});
    _objx.showRowCount=true;
    objar.push(_objx); 
	
  qEmailParse.NextRecord();
}

content.contents+=createReportGrid(objar,CRM,true);

CRM.AddContent(container.Execute());
Response.Write(CRM.GetPage('acceleratortab'));

%>