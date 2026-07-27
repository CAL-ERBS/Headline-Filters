<!-- #include file ="sagecrm.js" -->
<!-- #include file ="_base_objects.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="configReader.js" -->
<!-- #include file ="helpers.js" -->
<!-- #include file ="vcard.js" -->
<%
//qrbusinesscardp.asp
//generates a persons business card

var entity=Request.Querystring('entity');
var entityid=Request.Querystring('id');
if (!Defined(entity)||(entity=='')||(entity!='person'))
{
	Response.Write("No valid Entity found: "+entity);
	throw "No valid Entity found";
}

entity=new String(entity);
var table=getTableInfo(entity);
if (!Defined(table.name)){
  //log to CRM's logs
  LogtoCRMsLogs("("+Request.ServerVariables("SCRIPT_NAME")+")No valid Entity found, entity is "+Request.Form('entity'));
  throw "No valid Entity found";
}

var pRec=CRM.FindRecord("person,vsummaryperson","pers_personid="+entityid);

if (Request.Querystring("download")=="Y")
{
  var pcard=getPersonVCARD();
  var pcardObj=JSON.parse(pcard);
  var strvcard="BEGIN:VCARD\n"+
	"VERSION:"+pcardObj.version+"\n"+
	"N:"+pcardObj.lastName+";"+pcardObj.firstName+"; ;;\n"+
	"FN:"+pcardObj.firstName+"  "+pcardObj.lastName+"\n"+
	"ORG:"+pcardObj.organization+"\n"+
	"TITLE:"+pcardObj.title+"\n"+
	"EMAIL;type=INTERNET;type=WORK:"+pcardObj.work.eMail+"\n"+
	"EMAIL;type=INTERNET;type=HOME:\n"+
	"TEL;type=CELL:"+pcardObj.mobilePhone+"\n"+
	"TEL;type=WORK:"+pcardObj.work.phone+"\n"+
	"TEL;type=HOME:\n"+
	"TEL;type=WORK,FAX:"+pcardObj.work.fax+"\n"+
	"ADR;type=WORK:;;"+pcardObj.work.street+";"+pcardObj.work.city+";"+pcardObj.work.state+";"+pcardObj.work.zip+";"+pcardObj.work.country+"\n"+
	"URL;type=WORK:"+pcardObj.work.url+".com\n"+
	"END:VCARD";

	Response.Clear();
	Response.AddHeader("Content-Disposition", "attachment; filename="+getPersonValue('pers_personid')+".vcf" );
	Response.ContentType = "text/vcard";
	Response.Write(strvcard);
	Response.End();
}
//example of vcard
/*
BEGIN:VCARD
VERSION:3.0
N:lname;fname;mname ;;
FN:fname mname lname
ORG:org
TITLE:title
EMAIL;type=INTERNET;type=WORK:emailwork@woks.com
EMAIL;type=INTERNET;type=HOME:email@home.com
TEL;type=CELL:111111111111
TEL;type=WORK:2222222222
TEL;type=HOME:444444444
TEL;type=WORK,FAX:33333333333
ADR;type=WORK:;;123 street;cityname;state;zipcode;country
URL;type=WORK:website.com
END:VCARD
*/
//library used
//https://www.jsqr.de/download.html

%>
<meta name="viewport" content="width=device-width, initial-scale=1.0" />	
<div id="explainer" style="width:90%;margin:auto;padding:10px;font-family: -apple-system,system-ui,BlinkMacSystemFont,Segoe UI,Roboto,Ubuntu; font-size: .9375rem;" >
Point your phone camera here to download the vCard
</div>
<div id="explainer2" style="width:90%;margin:auto;padding:10px;font-family: -apple-system,system-ui,BlinkMacSystemFont,Segoe UI,Roboto,Ubuntu; font-size: .9375rem;" >
<a href='#' onclick="downloadvcard()" >Or click here to download as a file</a>
</div>
<div id="codeContainer" style="width:90%;margin:auto;padding:10px;" >
</div>
<div id="explainer" style="width:90%;margin:auto;padding:10px;font-family: -apple-system,system-ui,BlinkMacSystemFont,Segoe UI,Roboto,Ubuntu; font-size: .9375rem;" >
Powered by
</div>
<div id="explainer" style="width:90%;margin:auto;padding:10px" >
<a href="https://crmtogether.com?utm_source=mobilex&utm_medium=mxapp&utm_id=qrcodescanner" target="BLANK" ><img width="20%"  src="../webappmx/assets/logo_alt_wide.png" /></a>
</div>

<script src="jsqr-1.0.2-min.js"></script>
<script>

window.addEventListener("load", (event) => {
  console.log("page is fully loaded");
  _generateQR();
});
function downloadvcard(){
	// Get the current URL
	const currentUrl = new URL(window.location.href);

	// Append a query parameter (e.g., ?key=value)
	currentUrl.searchParams.set('download', 'Y');
	window.open(currentUrl, "_SELF");

}
function _generateQR(){

    document.body.style.margin='unset';

	var _codeContainer=document.getElementById("codeContainer");

	var qr = new JSQR();

	var code = new qr.Code();
	code.encodeMode = code.ENCODE_MODE.BYTE;
	code.version = code.DEFAULT;
	code.errorCorrection = code.ERROR_CORRECTION.H;

	var input = new qr.Input();
	input.dataType = input.DATA_TYPE.VCARD;

	input.data = <%=getPersonVCARD()%>

	var matrix = new qr.Matrix(input, code);

	var canvas = document.createElement('canvas');
	canvas.setAttribute('width', matrix.pixelWidth);
	canvas.setAttribute('height', matrix.pixelWidth);
	canvas.getContext('2d').fillStyle = 'rgb(0,0,0)';
	matrix.draw(canvas, 0, 0);
	_codeContainer.appendChild(canvas);
}

</script>

