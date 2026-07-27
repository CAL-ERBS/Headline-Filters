<!-- #include file ="sagecrm.js" -->
<!-- #include file ="_base_objects.js" -->

<!-- #include file ="configreader.js" -->
<!-- #include file ="xcommon.js" -->
<!-- #include file ="helpers.js" -->
<%
var entity=new String(Request.Querystring("ent"));
var _tableinfo=getTableInfo(entity);
KeyDescription="<b>Advanced</b> option to extend the Home Dashboard/Accordian";
BreadCrumb="Extend Home Section:";
 
var Container;
Container = CRM.GetBlock("Container");
Container.DisplayButton(Button_Default) = false;
var Content;
Content = CRM.GetBlock("Content");
Content.contents=getBreadCrumb(BreadCrumb)+getInfo(KeyDescription)+"<br>";

var existing="select * from Custom_ScreenObjects where CObj_deleted is null and 765=765 and CObj_Name='acdashboard'";
			
var existingq=CRM.CreateQueryObj(existing);
existingq.SelectSQL();
var foundacdashboard=false;
while (!existingq.eof)
{
  var CObj_Name=new String(existingq('CObj_Name'));
  var _uurl=CRM.url(846);
    _uurl+='&listname='+existingq('CObj_Name')+'&listId='+existingq('CObj_TableId')+'&Parent=System Menus&Device=1';
	Content.contents+=getInfo("<b>NEW</b> - ACNewMenuExt - Found In System Menus.<br>"+gethelplink("home"));
	foundacdashboard=true;

  Content.contents+='<a target="_blank" href="'+_uurl+'" >'+existingq('CObj_Name')+'</a><br><br>';
  existingq.NextRecord();
}

//items not found...
var _xcreatemeta=CRM.url("sagecrmws/ac2020/xcreatemeta.asp");
	
if (!foundacdashboard){  
  Content.contents+=getInfo("<b>DASHBOARD</b> - Extend Dashboard/Accordian (acdashboard).<br>"+gethelplink("home"));
  Content.contents+='<a class="er_buttonItem" href="'+_xcreatemeta+'&stype=TabGroup&sname=acdashboard&entity=System Menu" >Create Tabgroup</a><br><br>';	
}
else{
	//EXPERIMENTAL
	Content.contents+=getInfo("<b>EXPERIMENTAL: Todays Feed</b>");
	Content.contents+='<span class="CoachingCaptionBody2">Create an item with custom file "sagecrmws/ac2020/activitytoday.asp"</span>';	

	//EXPERIMENTAL
	Content.contents+=getInfo("<b>EXPERIMENTAL: Todays Report</b>");
	Content.contents+='<span class="CoachingCaptionBody2">Create an item with custom file "sagecrmws/ac2020/useractivityreport.asp"</span>';	

	//EXPERIMENTAL
	Content.contents+=getInfo("<b>EXPERIMENTAL: QR Business Card</b>");
	Content.contents+='<span class="CoachingCaptionBody2">Create an item with custom file "sagecrmws/ac2020/qrbusinesscard.asp"</span>';	

	//EXPERIMENTAL
	Content.contents+=getInfo("<b>EXPERIMENTAL: Download Appointments as ICS files</b>");
	Content.contents+='<span class="CoachingCaptionBody2">Download Appointments as ICS cards with details of CRM data embedded "sagecrmws/ac2020/icsappt.asp"</span>';	

	//EXPERIMENTAL
	Content.contents+=getInfo("<b>EXPERIMENTAL: QR Code Scanner</b>");
	Content.contents+='<span class="CoachingCaptionBody2">Scan QR codes with vCard contact data (VCF) or Event data (ISC) "sagecrmws/ac2020/qrscanner.asp"</span>';	

}

Container.AddBlock(Content);

Response.Write(Container.Execute());

%>
<!-- #include file ="xstylefooter.js" -->