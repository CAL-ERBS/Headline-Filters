<!-- #include file ="sagecrm.js" -->
<!-- #include file ="json2.js" -->
<!-- #include file ="_base_objects.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="configReader.js" -->
<!-- #include file ="helpers.js" -->
<!-- #include file ="globalsearch.js" -->
<style>
a, a:hover, a:focus, a:active, a:visited, a:link {
	text-decoration: none;
}

.refreshButton {
	left: 50%;
	top: 20%;
	cursor: pointer;
	display: flex;
	justify-content: center;
	align-items: center;
	box-shadow: 0 0 1.105vw 0.205vw rgb(35, 47, 62);
	background-color: #ffffff;
	width: 7vw;
	height: 3vw;
	border-left: 0.4vw solid #b60ee5;
	border-radius: 0.315vw;
	line-height: 3vw;
	text-align: center;
	transition: 0.7s ease-in-out transform, 0.7s ease-in-out;
}

.refreshButton:hover {
	color: green;
	transition: 0.7s ease-in-out transform, 0.7s ease-in-out;
}

*, *:before, *:after {
    -webkit-box-sizing: border-box;
       -moz-box-sizing: border-box;
            box-sizing: border-box;
}

body {
  background-color:#e9ebee;
}

.f-card {
  background-color:white;
  /*height:400px;*/
  /*width:502px;*/
  border: 1px solid #d0d1d5;
  border-radius:3px;
  margin: auto;
  margin-bottom:10px;
  padding: 12px; 
  
  box-shadow: 0 0 5px rgba(0, 0, 0, .30); /* Not original, just a test */
}

.header {
  margin-bottom:17px;
}

.co-logo {
  /*display:block;*/
  float:left;
  margin-right:8px;
  
  width:40px;
  height:40px;
}

.co-name > a {
  font-family: Helvetica;
  font-size:16px;
  font-weight: bold;
  line-height: 1.38;
  color: #365899;
  text-decoration:none;
  
  margin-bottom:2px;
}
	
.co-name > a:hover {
  text-decoration:underline;
}

.time {
  font-family: Helvetica;
  font-size:14px;
  color: #90949c;
}

.time > a {
  color: #90949c;
  text-decoration:none;
}

.time > a:hover {
  text-decoration:underline;
}

.options {
  font-family: Helvetica;
  font-size:12px;
  color: #e5e5e5;
  float:right;
}

.options:hover {
  color: black; /* Fallback */
  color: rgba(0, 0, 0, .30);
}

.content {
  clear:both;
  font-family: Helvetica, sans-serif;
  font-size:16px;
  line-height: 1.38;
}

.reference {
  /*width:476px;*/
}
.reference-thumb {
  display:block;
  width:476px;
  height:249px;
}

.reference-content {
  border: 2px solid black;
  border: 2px solid rgba(0, 0, 0, .1);
  border-top: 0;
  padding: 10px 12px 10px 12px;
}

.reference:hover .reference-content {
  border-color: black; /* Fallback */
  border-color: rgba(0, 0, 0, .15);
}

.reference-title {
  font-size: 18px;
  font-weight: 500;
  line-height: 22px;
  margin-bottom:5px;
}

.reference-subtitle {
  font-family: Helvetica;
  font-size:14px;
  line-height: 16px; 
}

.reference-font {
  color: #90949c;
  font-family: Helvetica;
  font-size: 11px;
  line-height: 11px;
  text-transform: uppercase;

  padding-top:9px; 
}

.social {
  margin-top:12px;
}
.social-buttons {
  color: #7f7f7f;
  font-family: Helvetica;
  font-size: 12px;
  font-weight:bold;
  line-height:14px;
  
  border-top:1px solid #e5e5e5;
  padding-top:4px;
  
}

.social-buttons span {
  font-size: 12px;
  margin-right:20px;
  padding:4px 4px 4px 0;
}

.social-buttons span:hover {
  text-decoration:underline;
  cursor:pointer;
}

.social-buttons span i {
  padding-right:4px;
}


</style>
<style type="text/css"> 
<!-- 
 
 #navbar ul { 
	margin: 5; 
	padding: 3px; 
	list-style-type: none; 
	text-align: left; 
	background-color: #e9ebee; 
	} 
 
li{
display: contents;
}
#navbar ul li a { 
	text-decoration: none; 
	padding: .2em 1em; 
	color: #000; 
	background-color: #fff; 
	} 
 
#navbar ul li a:hover { 
	color: #000; 
	background-color: #fff; 
	} 
 
--> 
</style> 

<%
//activitytoday.asp
var objar=new Array();

function readFile(fname){
	var fso = Server.CreateObject("Scripting.FilesystemObject");	
	var txt = fso.OpenTextFile(Server.MapPath(fname));
	return txt.ReadAll();
}
function doMerge(str, _record) {	
	s = str;	
	eQueryFields = new Enumerator(_record);
	while (!eQueryFields.atEnd()) {
		var fieldx=eQueryFields.item();
		if (Defined(_record.FieldValue(fieldx)))
		{
			fieldx=fieldx.toLowerCase();
			fieldx=fieldx.replace(/\s/g, "");
			s = s.replace("#" + fieldx + "#", _record.FieldValue(fieldx));		
		}else{
			s = s.replace("#" + fieldx + "#",'');		
		}
		eQueryFields.moveNext();
	}	
	return s;
}
function getDescFields(entity){
   var table = getTableInfo(entity);
   if ((entity.toLowerCase()=='cases')||(entity.toLowerCase()=='case'))
     return "case_referenceid+' '+case_description";//clever
   return table.DescField;
}
function getIDField(entity){
   var table = getTableInfo(entity);
   return table.idfield;
}

function getView(entity){
   var table = getTableInfo(entity);
   return table.searchView;
}
function getUserImage(username, userid){

  var defaultimage="https://crm.crmtogether.com/crm/Themes/img/ergonomic/Icons/person.png";
  
  return defaultimage;
}

function checkViewExists(viewname){
	var qq=CRM.CreateQueryObj("SELECT 1 FROM sysobjects WHERE name = '"+viewname+"' AND xtype = 'V'");
	qq.SelectSQL();
	if (qq.eof)
	  return false;
	return true;
}
var _commsql=readFile("xtodaysql.js");
if (!checkViewExists("ctUserToday"))
{
  CRM.ExecSQL("create view ctUserToday as "+_commsql);
}

_commsql="select top 30 *, CONVERT(VARCHAR(20), updateddate, 113)  as displayupdateddate from ctUserToday";

//ref...from https://codepen.io/eMineiro/pen/vKZdya
var _template=readFile("xcardtemplate.html");

var _userid=new String(Request.Form("user"));
if (!Defined(_userid)||(_userid=='')||(_userid==null)){
	_userid='';
}else{
  _commsql+=" where userid="+_userid;
}


_commsql+=" order by UpdatedDate desc";

//Response.Write(_commsql);Response.End();
 
var qq=CRM.CreateQueryObj(_commsql);
qq.SelectSQL();

Container=eWare.GetBlock("container");
Container.DisplayForm=true;
Container.DisplayButton(Button_Default) = false;

var content = eWare.GetBlock("content");
Container.AddBlock(content);	

var updatedate=new Date();

var userssql="select user_userid, user_fullname from vusers where user_userid in (select comm_updatedby from vSearchListCommunication "+
" where (CONVERT(DATE, comm_UpdatedDate) = CONVERT(DATE, GETDATE()))) and user_deleted is null and user_fullname <>'' order by user_fullname";
var usersqry=CRM.CreateQueryObj(userssql);
usersqry.SelectSQL();
var _options="";
while (!usersqry.eof){
  var _selectedtext="";
  if (_userid.toLowerCase()==usersqry('user_userid').toLowerCase())
	_selectedtext=' selected="selected" ';
  _options+='<option value="'+usersqry('user_userid')+'" '+_selectedtext+' >'+usersqry('user_fullname')+'</option>'+
  usersqry.NextRecord();
}
if (_userid!=''){
  _options='<option value="" >'+CRM.GetTrans('PerLevelToDo','3')+'</option>'+_options;
}else{
  _options='<option value=""  selected="selected" >'+CRM.GetTrans('PerLevelToDo','3')+'</option>'+_options;
}
var _usermarkup='<select class="content" id="user" name="user" onchange="document.forms[0].submit()" value="'+_userid+'" >';
_usermarkup+=_options;
_usermarkup+='</select>';

	
content.contents+='<div id="navbar"> '+
  '<a class="content" href="https://crmtogether.com?utm_source=mobilex&utm_medium=mxapp&utm_id=feedpage" target="BLANK" >'+
	  '<img width="15%"  src="../webappmx/assets/logo_alt_wide.png" /></a>'+
  '<ul class="content">  '+
	'<li>'+CRM.GetTrans('ColNames','Note_UpdatedDate')+' <span id="output" class="content" ></span></li>  '+
	'<li>'+_usermarkup+'</li>  '+
	'<li><a onclick="location.reload()" style="cursor:pointer">'+CRM.GetTrans('Captions','Refresh')+'</a></li>  '+
  '</ul>  '+

'</div>  ';

if (qq.eof){
	content.contents='<div id="navbar"> '+
	 '<a class="content" href="https://crmtogether.com?utm_source=mobilex&utm_medium=mxapp&utm_id=feedpage" target="BLANK" >'+
		  '<img width="15%"  src="../webappmx/assets/logo_alt_wide.png" /></a>'+
	  '<ul class="content">  '+
		'<li>'+CRM.GetTrans('ColNames','Note_UpdatedDate')+' <span id="output" class="content" ></span></li>  '+
		'<li><a onclick="location.reload()" style="cursor:pointer">'+CRM.GetTrans('Captions','Refresh')+'</a></li>  '+
	  '</ul>  '+	 
'<span id="noactivity" class="content" >'+CRM.GetTrans('LandingPage','SearchableTreeEmpty')+'</span>'+
	'</div>  ';
}

while (!qq.eof){
		
    var mergeddata=doMerge(_template,qq);
	
	mergeddata=mergeddata.replace("#userimage#", getUserImage(qq.FieldValue("username"), qq.FieldValue("userid")));		
	if (qq.FieldValue("entity")=="Communication")
	{
		var pe_sql="select TOP 10 SUBSTRING(convert(nvarchar(max),comm_note),1,CHARINDEX(' ', convert(nvarchar(max),comm_note) + ' ', 1 + CHARINDEX(' ', convert(nvarchar(max),comm_note) + ' ', 1) + CHARINDEX(' ',"+
					"convert(nvarchar(max),comm_note) + ' ', 1 + CHARINDEX(' ', convert(nvarchar(max),comm_note) + ' ', 1)))) +'...'  as details1 from Communication "+
					"where comm_communicationid=" + qq.FieldValue("entityid")+" order by comm_UpdatedDate desc";
		var pe_q=CRM.CreateQueryObj(pe_sql);
		//Response.Write(pe_sql);Response.End();
		pe_q.SelectSQL();		
		if (!pe_q.eof){
		  mergeddata=doMerge(mergeddata,pe_q);
		}	
		if (qq.FieldValue("primaryentity")!="Communication")
		{
		
			var pe_sql2="select "+getDescFields(qq.FieldValue("primaryentity")) + " as details2 from "+getView(qq.FieldValue("primaryentity"))+" where "+getIDField(qq.FieldValue("primaryentity"))+"=" +qq.FieldValue("primaryentityid");			
			//Response.Write(pe_sql2);Response.End();
			try{			
				var pe_q2=CRM.CreateQueryObj(pe_sql2);
				pe_q2.SelectSQL();
			if (!pe_q2.eof){
			  mergeddata=doMerge(mergeddata,pe_q2);
			}
			}catch(e2){
				Response.Write(pe_sql2);Response.End();
			}
		}		
	}else if (Defined(qq.FieldValue("primaryentity")))
	{
	//Response.Write('xxxx'+qq("primaryentity"));Response.End();
		var pe_sql3="select "+getDescFields(qq.FieldValue("primaryentity")) + " as details2 from "+getView(qq.FieldValue("primaryentity"))+" where "+getIDField(qq.FieldValue("primaryentity"))+"=" +qq.FieldValue("primaryentityid");
		//Response.Write(pe_sql3);Response.End();
		var pe_q3=CRM.CreateQueryObj(pe_sql3);
		pe_q3.SelectSQL();
		if (!pe_q3.eof){
		  mergeddata=doMerge(mergeddata,pe_q3);
		}
	}	
		
    var updatedate=new Date(qq.FieldValue("updateddate"));
		
	//clear up any non-merged data
	mergeddata=mergeddata.replace("#details1#", "");
	mergeddata=mergeddata.replace("#details2#", "");

	content.contents+=mergeddata;
	qq.NextRecord();
}
Response.Write(Container.Execute());

%>

<script>

  function formatDate() {
    // Get the current date
    var currentDate = new Date();

    // Extract date components
    var day = currentDate.getDate();
    var month = currentDate.toLocaleString('default', { month: 'short' }); // Get short month name
    var year = currentDate.getFullYear();
    var hours = currentDate.getHours();
    var minutes = currentDate.getMinutes();

    // Add leading zeros if needed
    day = day < 10 ? '0' + day : day;
    hours = hours < 10 ? '0' + hours : hours;
    minutes = minutes < 10 ? '0' + minutes : minutes;

    // Construct the formatted date string
    var formattedDate = day + ' ' + month + ' ' + year + ' ' + hours + ':' + minutes;

    // Display the formatted date
    document.getElementById('output').innerHTML = '<b>'+formattedDate+'</b>';
  }
  formatDate();
</script>