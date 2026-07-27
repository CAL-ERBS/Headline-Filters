<!-- #include file ="sagecrm.js" -->
<!-- #include file ="_base_objects.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="configReader.js" -->
<!-- #include file ="helpers.js" -->
<!-- #include file ="vcard.js" -->
<%
//qrbusinesscard.asp
//generates a users business card

function escapeDoubleQuotes(inputString) {
    // Replace double quotes with escaped double quotes
    return inputString.replace(/"/g, '\\"');
} 
function getUserValue(fieldname){
 return escapeDoubleQuotes(CRM.GetContextInfo('user',fieldname));
}
function getCompanyValue(fieldname){
 return escapeDoubleQuotes("");//to do
}
if (Request.Querystring("download")=="Y")
{
  var pcard=getUserVCARD();
  var pcardObj=JSON.parse(pcard);
  var strvcard="BEGIN:VCARD\n"+
	"VERSION:"+pcardObj.version+"\n"+
	"N:"+pcardObj.lastName+";"+pcardObj.firstName+"; ;;\n"+
	"FN:"+pcardObj.firstName+"  "+pcardObj.lastName+"\n"+
	"ORG:"+pcardObj.organisation+"\n"+
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
	Response.AddHeader("Content-Disposition", "attachment; filename="+getUserValue('user_userid')+".vcf" );
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
<div id="explainer" style="width:70%;margin:auto;padding:10px;font-family: -apple-system,system-ui,BlinkMacSystemFont,Segoe UI,Roboto,Ubuntu; font-size: .9375rem;" >
Point your phone camera here to download My vCard
</div>
<div id="codeContainer" style="" >
</div>
<div id="explainer2" style="width:70%;margin:auto;padding:10px;font-family: -apple-system,system-ui,BlinkMacSystemFont,Segoe UI,Roboto,Ubuntu; font-size: .9375rem;" >
<a href='#' onclick="downloadvcard()" >Or click here to download as a file</a>
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

	input.data = <%=getUserVCARD()%>

	var matrix = new qr.Matrix(input, code);

	var canvas = document.createElement('canvas');
	canvas.setAttribute('width', matrix.pixelWidth);
	canvas.setAttribute('height', matrix.pixelWidth);
	canvas.getContext('2d').fillStyle = 'rgb(0,0,0)';
	matrix.draw(canvas, 0, 0);
	var x=_codeContainer.appendChild(canvas);
	
	//WE RESIZE AS ITS TOO LARGE BY DEFAULT...clever..
	
      // Create a temporary canvas to save the current image
      const tempCanvas = document.createElement('canvas');
      const tempContext = tempCanvas.getContext('2d');
      tempCanvas.width = canvas.width;
      tempCanvas.height = canvas.height;
      
      // Copy the current canvas content to the temporary canvas
      tempContext.drawImage(canvas, 0, 0);
	  
	  let context = canvas.getContext('2d');
	  
	  let newWidth=300;
	  let newHeight=300;
	  // Resize the original canvas
      canvas.width = newWidth;
      canvas.height = newHeight;
	  
	   // Optionally fill the new canvas with a background color
      context.fillStyle = 'white';
      context.fillRect(0, 0, canvas.width, canvas.height);

      // Draw the content from the temporary canvas onto the resized canvas
      context.drawImage(tempCanvas, 0, 0, tempCanvas.width, tempCanvas.height, 0, 0, newWidth, newHeight);

}

var G_appPlatform="<%= G_appPlatform%>";
</script>
<% if (G_appPlatform=="ios")  { %>
<script>
	// Listen for click events in the iframe
	document.addEventListener('click', function (event) {
		const target = event.target;

		if (target.tagName === 'A' && target.href) {
			event.preventDefault(); // Prevent default link behavior
			const url = target.href;

			if (url.startsWith('http')) {
				// Send message to the parent window
				window.parent.postMessage({ type: 'externalLink', url }, '*');
			}
		}
	});
</script>
<% } %>