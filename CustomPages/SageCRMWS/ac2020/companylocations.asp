<!-- #include file ="sagecrm.js" -->
<script type="text/javascript" src="../js/lib/jquery-1.8.2.min.js"></script>

<%

/*
This plugin goes on company and shows all locations for a company

1. 
Add a menu item in companyint (this is a tab group in company) that points to "sagecrmws/ac2020/companylocations.asp"

*/

function readFile(fname){
	var fso = Server.CreateObject("Scripting.FilesystemObject");
	var txt = fso.OpenTextFile(Server.MapPath(fname));
	return txt.ReadAll();
}

//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

CurrentUser=CRM.GetContextInfo("selecteduser", "User_UserId");

container = CRM.GetBlock('container');
container.DisplayButton(Button_Default) = false;

customcontent = CRM.GetBlock("content");
customcontent.NewLine = false;
customcontent.contents="";

container.AddBlock( customcontent );

var compid=Request.QueryString("id");
if (!isNumeric(compid)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Company ID found, compid is "+Request.Form('id'));
  throw "No valid Company ID found";
}
var sql = "select * from vAddressCompany where AdLi_CompanyID="+compid+"";

var address=CRM.CreateQueryObj(sql);
address.SelectSQL();
	
customcontent.contents=readFile("customscreenheader.inc");
customcontent.contents=customcontent.contents.replace("__SCREENTITLE__","Locations");
customcontent.contents=customcontent.contents.replace("__CRMPATH__",sInstallName);

   
while (!address.eof)
{
	var itemtemplate=readFile("customscreenitem.inc");
	var tmpitemtemplate=itemtemplate;
	
	var searchaddress="";
	if (address.FieldValue("addr_address1"))
	{
		searchaddress=address.FieldValue("addr_address1");
	}
	if (address.FieldValue("addr_address2"))
	{
		if (searchaddress!="")
		  searchaddress+=",";
		searchaddress+=address.FieldValue("addr_address2");
	}	
	if (address.FieldValue("addr_address3"))
	{
		if (searchaddress!="")
		  searchaddress+=",";
		searchaddress+=address.FieldValue("addr_address3");
	}
	if (address.FieldValue("addr_address4"))
	{
		if (searchaddress!="")
		  searchaddress+=",";
		searchaddress+=address.FieldValue("addr_address4");
	}
	if (address.FieldValue("addr_address5"))
	{
		if (searchaddress!="")
		  searchaddress+=",";
		searchaddress+=address.FieldValue("addr_address5");
	}
	if (address.FieldValue("addr_city"))
	{
		if (searchaddress!="")
		  searchaddress+=",";
		searchaddress+=address.FieldValue("addr_city");
	}	
	if (address.FieldValue("addr_postcode"))
	{
		if (searchaddress!="")
		  searchaddress+=",";
		searchaddress+=address.FieldValue("addr_postcode");
	}
	if (address.FieldValue("addr_country"))
	{
		if (searchaddress!="")
		  searchaddress+=",";
		searchaddress+=CRM.GetTrans("addr_country",address.FieldValue("addr_country"));
	}	
	var _link='<a href="https://maps.google.com/?q='+searchaddress+'" target="blank"><img alt="View" src="/'+sInstallName+'/Themes/Img/Ergonomic/Icons/LandingPage.png" width="25px" hspace="0" border="0" align="TOP"></a>';
	tmpitemtemplate=tmpitemtemplate.replace("__FIELDNAME__","");
	tmpitemtemplate=tmpitemtemplate.replace("__FIELDCAPTION__",_link);
	tmpitemtemplate=tmpitemtemplate.replace("__FIELDDATA__","");
	customcontent.contents+=tmpitemtemplate;
	
	if (address.FieldValue("addr_address1"))
	{
		tmpitemtemplate=itemtemplate;
		tmpitemtemplate=tmpitemtemplate.replace("__FIELDNAME__","addr_address1");
		tmpitemtemplate=tmpitemtemplate.replace("__FIELDCAPTION__","Address1:");
		tmpitemtemplate=tmpitemtemplate.replace("__FIELDDATA__",address.FieldValue("addr_address1"));
		customcontent.contents+=tmpitemtemplate;
	}
	if (address.FieldValue("addr_address2"))
	{
		tmpitemtemplate=itemtemplate;
		tmpitemtemplate=tmpitemtemplate.replace("__FIELDNAME__","addr_address2");
		tmpitemtemplate=tmpitemtemplate.replace("__FIELDCAPTION__","Address2:");
		tmpitemtemplate=tmpitemtemplate.replace("__FIELDDATA__",address.FieldValue("addr_address2"));
		customcontent.contents+=tmpitemtemplate;
	}
	if (address.FieldValue("addr_address3"))
	{	
		tmpitemtemplate=itemtemplate;
		tmpitemtemplate=tmpitemtemplate.replace("__FIELDNAME__","addr_address3");
		tmpitemtemplate=tmpitemtemplate.replace("__FIELDCAPTION__","Address3:");
		tmpitemtemplate=tmpitemtemplate.replace("__FIELDDATA__",address.FieldValue("addr_address3"));
		customcontent.contents+=tmpitemtemplate; 
	}
	if (address.FieldValue("addr_address4"))
	{	
		tmpitemtemplate=itemtemplate;
		tmpitemtemplate=tmpitemtemplate.replace("__FIELDNAME__","addr_address4");
		tmpitemtemplate=tmpitemtemplate.replace("__FIELDCAPTION__","Address4:");
		tmpitemtemplate=tmpitemtemplate.replace("__FIELDDATA__",address.FieldValue("addr_address4"));
		customcontent.contents+=tmpitemtemplate;
	}
	if (address.FieldValue("addr_address5"))
	{	
		tmpitemtemplate=itemtemplate;
		tmpitemtemplate=tmpitemtemplate.replace("__FIELDNAME__","addr_address5");
		tmpitemtemplate=tmpitemtemplate.replace("__FIELDCAPTION__","Address5:");
		tmpitemtemplate=tmpitemtemplate.replace("__FIELDDATA__",address.FieldValue("addr_address5"));
		customcontent.contents+=tmpitemtemplate;
	}	
	if (address.FieldValue("Addr_City"))
	{	
		tmpitemtemplate=itemtemplate;
		tmpitemtemplate=tmpitemtemplate.replace("__FIELDNAME__","Addr_City");
		tmpitemtemplate=tmpitemtemplate.replace("__FIELDCAPTION__","City:");
		tmpitemtemplate=tmpitemtemplate.replace("__FIELDDATA__",address.FieldValue("Addr_City"));
		customcontent.contents+=tmpitemtemplate;
	}	
	if (address.FieldValue("Addr_State"))
	{	
		tmpitemtemplate=itemtemplate;
		tmpitemtemplate=tmpitemtemplate.replace("__FIELDNAME__","Addr_State");
		tmpitemtemplate=tmpitemtemplate.replace("__FIELDCAPTION__","State:");
		tmpitemtemplate=tmpitemtemplate.replace("__FIELDDATA__",address.FieldValue("Addr_State"));
		customcontent.contents+=tmpitemtemplate;
	}
	if (address.FieldValue("Addr_PostCode"))
	{	
		tmpitemtemplate=itemtemplate;
		tmpitemtemplate=tmpitemtemplate.replace("__FIELDNAME__","Addr_PostCode");
		tmpitemtemplate=tmpitemtemplate.replace("__FIELDCAPTION__","PostCode:");
		tmpitemtemplate=tmpitemtemplate.replace("__FIELDDATA__",address.FieldValue("Addr_PostCode"));
		customcontent.contents+=tmpitemtemplate;
	}	
	if (address.FieldValue("Addr_Country"))
	{	
		tmpitemtemplate=itemtemplate;
		tmpitemtemplate=tmpitemtemplate.replace("__FIELDNAME__","Addr_Country");
		tmpitemtemplate=tmpitemtemplate.replace("__FIELDCAPTION__","Country:");
		tmpitemtemplate=tmpitemtemplate.replace("__FIELDDATA__",CRM.GetTrans("addr_country",address.FieldValue("addr_country")));
		customcontent.contents+=tmpitemtemplate;
	}		
	address.NextRecord();
}
customcontent.contents+=readFile("customscreenfooter.inc");



Response.Write(container.Execute());
%>
<script>
 $("body").css("overflow", "scroll");
</script>
</script>