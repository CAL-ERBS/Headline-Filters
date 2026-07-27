<!-- #include file ="sagecrm.js" -->
<!-- #include file ="_base_objects.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="configReader.js" -->
<!-- #include file ="helpers.js" -->
<%
//qrscanner.asp

var uslang=[
		{"code":"NoQRcodedetected", "value":"No QR code detected"},
		{"code":"videostream", "value":"Unable to access video stream (please make sure you have a webcam enabled)"},
		{"code":"nativeAppSection", "value":" Click Choose File to select an image<br>or take a photo (video not supported)"},		
		{"code":"Chooseafile", "value":"Choose a file"},
		{"code":"ParsedQRCodeRawData", "value":"Parsed QR Code Raw Data:"},
		{"code":"CreateLead", "value":"Create Lead"},
		{"code":"CreateCompany", "value":"Create Company"},
		{"code":"CreateEvent", "value":"Create Event"},
		{"code":"RawData", "value":"Raw Data:"},
		{"code":"CopytoClipboard", "value":"Copy to Clipboard"},
		{"code":"Reset", "value":"Reset"},
		{"code":"Match found", "value":"Match found for email address:"},
		{"code":"Matchesfound", "value":"Matches found for email address:"},
		{"code":"ErrorCreatingLead", "value":"Error Creating Lead"},
		{"code":"ErrorCreatingCompany", "value":"Error Creating Company"},
		{"code":"matchesfoundforemail", "value":"Matches found for email address"},
		{"code":"nativeAppSectionExperimental", "value":"Experimental Feature"}	
		];
var frlang= [
		{"code":"NoQRcodedetected", "value":"Aucun code QR détecté"},
		{"code":"videostream", "value":"Impossible d'accéder au flux vidéo (assurez-vous d'avoir une webcam activée)"},
		{"code":"nativeAppSection", "value":" Cliquez sur 'Choisir un fichier' pour sélectionner une image<br>ou prendre une photo (la vidéo n'est pas prise en charge)"},        
		{"code":"Chooseafile", "value":"Choisir un fichier"},
		{"code":"ParsedQRCodeRawData", "value":"Données brutes du code QR analysées :"},
		{"code":"CreateLead", "value":"Créer un lead"},
		{"code":"CreateCompany", "value":"Créer une entreprise"},
		{"code":"CreateEvent", "value":"Créer un événement"},
		{"code":"RawData", "value":"Données brutes :"},
		{"code":"CopytoClipboard", "value":"Copier dans le presse-papiers"},
		{"code":"Reset", "value":"Réinitialiser"},
		{"code":"Match found", "value":"Correspondance trouvée pour l'adresse e-mail :"},
		{"code":"Matchesfound", "value":"Correspondances trouvées pour l'adresse e-mail :"},
		{"code":"ErrorCreatingLead", "value":"Erreur lors de la création du lead"},
		{"code":"ErrorCreatingCompany", "value":"Erreur lors de la création de l'entreprise"},
		{"code":"nativeAppSectionExperimental", "value":"Fonctionnalité expérimentale"}	
	];
var delang=[
			{"code":"NoQRcodedetected", "value":"Kein QR-Code erkannt"},
			{"code":"videostream", "value":"Zugriff auf Videostream nicht möglich (stellen Sie sicher, dass Ihre Webcam aktiviert ist)"},
			{"code":"nativeAppSection", "value":" Klicken Sie auf 'Datei auswählen', um ein Bild auszuwählen<br>oder ein Foto aufzunehmen (Video wird nicht unterstützt)"},        
			{"code":"ParsedQRCodeRawData", "value":"Analysierte Rohdaten des QR-Codes:"},
			{"code":"Chooseafile", "value":"Datei auswählen"},
			{"code":"CreateLead", "value":"Lead erstellen"},
			{"code":"CreateCompany", "value":"Unternehmen erstellen"},
			{"code":"CreateEvent", "value":"Veranstaltung erstellen"},
			{"code":"RawData", "value":"Rohdaten:"},
			{"code":"CopytoClipboard", "value":"In die Zwischenablage kopieren"},
			{"code":"Reset", "value":"Zurücksetzen"},
			{"code":"Match found", "value":"Übereinstimmung gefunden für die E-Mail-Adresse:"},
			{"code":"Matchesfound", "value":"Übereinstimmungen gefunden für die E-Mail-Adresse:"},
			{"code":"ErrorCreatingLead", "value":"Fehler beim Erstellen des Leads"},
			{"code":"ErrorCreatingCompany", "value":"Fehler beim Erstellen des Unternehmens"},
		{"code":"nativeAppSectionExperimental", "value":"Experimentelle Funktion"}	
		];
var eslang= [
		{"code":"NoQRcodedetected", "value":"No se detectó código QR"},
		{"code":"videostream", "value":"No se puede acceder al flujo de video (asegúrese de tener una cámara web habilitada)"},
		{"code":"nativeAppSection", "value":" Haga clic en 'Elegir archivo' para seleccionar una imagen<br>o tomar una foto (el video no es compatible)"},        
		{"code":"ParsedQRCodeRawData", "value":"Datos sin procesar del código QR analizados:"},
		{"code":"Chooseafile", "value":"Elegir un archivo"},
		{"code":"CreateLead", "value":"Crear un prospecto"},
		{"code":"CreateCompany", "value":"Crear una empresa"},
		{"code":"CreateEvent", "value":"Crear un evento"},
		{"code":"RawData", "value":"Datos en bruto:"},
		{"code":"CopytoClipboard", "value":"Copiar al portapapeles"},
		{"code":"Reset", "value":"Reiniciar"},
		{"code":"Match found", "value":"Coincidencia encontrada para la dirección de correo electrónico:"},
		{"code":"Matchesfound", "value":"Coincidencias encontradas para la dirección de correo electrónico:"},
		{"code":"ErrorCreatingLead", "value":"Error al crear el prospecto"},
		{"code":"ErrorCreatingCompany", "value":"Error al crear la empresa"},
		{"code":"nativeAppSectionExperimental", "value":"Característica experimental"}	
	];

var userlanguage=CRM.GetContextInfo('user','user_language');
userlanguage=userlanguage.toLowerCase();
//userlanguage="de";///testing line
var userlanguageObj=uslang;//default
if (userlanguage=="uk"){
	userlanguageObj=uslang;
}else
if (userlanguage=="de"){
	userlanguageObj=delang;
}else
if (userlanguage=="es"){
	userlanguageObj=eslang;
}else
if (userlanguage=="fr"){
	userlanguageObj=frlang;
}

function getTrans(code){
    var i;
    for (i = 0; i < userlanguageObj.length; i++) {
        if (userlanguageObj[i].code === code) {
            return userlanguageObj[i].value;
        }
    }
    // Return the code if not found
    return code;
}	
%>
<meta name="viewport" content="width=device-width, initial-scale=1.0" />	
	
	<link REL="stylesheet" href="/<%=sInstallName%>/CustomPages/SageCRMWS/ac2020/ctmobile.css"/>
	<script                 src="/<%=sInstallName%>/CustomPages/SageCRMWS/ac2020/ctmobile.js"></script>
	
 <div id="loadingMessage"><%=getTrans('videostream')%><br><br>
</div>
<div id="nativeAppSectionExperimental"><b><%=getTrans("nativeAppSectionExperimental")%></b></div>
 <div id="nativeAppSection" hidden><br/>
<%=getTrans('nativeAppSection')%>
 <br><br>
 
    <label for="fileInput" class="file-label">
        <span><%=getTrans('Chooseafile')%></span>
        <input type="file" id="fileInput" name="fileInput"  allow="camera" class="file-input">
    </label>
	
	<script>
	var userlanguage="<%=CRM.GetContextInfo('user','user_language') %>";
	
	function handleFileInputChange() {
		// Get the selected file(s)
		const fileInput = document.getElementById('fileInput');
		canvasElement.hidden = false;
		const selectedFile = fileInput.files[0];

		if (selectedFile) {
		  // Read the selected file as a data URL
		  const reader = new FileReader();

		  reader.onload = function (event) {
			// Create an image element
			const img = new Image();

			// Set the source of the image to the data URL
			img.src = event.target.result;

			// Get the canvas element
			//const canvas = document.getElementById('canvas');
			//const context = canvas.getContext('2d');

			// Draw the image onto the canvas
			img.onload = function () {
			  canvas.clearRect(0, 0, canvasElement.width, canvasElement.height);
			  canvas.drawImage(img, 0, 0, canvasElement.width, canvasElement.height);
			};
		  };
		  // Read the file as a data URL
		  reader.readAsDataURL(selectedFile);	
		  setTimeout(function(){
				console.log("runImageParse...");
				runImageParse();
			}, 500);
		}
	}
 // Get the file input element
  const fileInput = document.getElementById('fileInput');

  // Attach the onchange event listener
  fileInput.addEventListener('change', handleFileInputChange);  
  	</script>
 </div>


  <canvas id="canvas" width="200" height="200" style="border:1px solid" hidden></canvas>
  <div id="output" hidden>
    <div id="outputMessage"><%=getTrans('NoQRcodedetected')%></div>
  </div>
  
<div id="output" hidden>
    <div id="outputMessage"><%=getTrans('NoQRcodedetected')%></div>
    
  </div>  
  <br>  
  	<div hidden><b><%=getTrans('ParsedQRCodeRawData')%></b><br> <span id="outputDataParsed"></span></div>
	<br>  
  <div id="fetchCheckMessage"></div>
<br>
<br>
<div id="CreateSection" hidden>
      <button id="createLeadbtn" onclick="createLead()" style="width:200px;padding: 10px 20px; background-color: #FFA500; color: white; border: none;border-radius: 5px; font-size: 16px; cursor: pointer;"><%=getTrans('CreateLead')%></button> 
	    <br>  
		  <br>  
		        <button id="createCompanybtn" onclick="createCompany()" style="width:200px;padding: 10px 20px; background-color: #3498db; color: white; border: none;border-radius: 5px; font-size: 16px; cursor: pointer;"><%=getTrans('CreateCompany')%></button> 
	    <br>  
		  <br>  
<button id="createEventbtn" onclick="createEvent()" style="width:200px;padding: 10px 20px; background-color: #3498db; color: white; border: none;border-radius: 5px; font-size: 16px; cursor: pointer;" hidden><%=getTrans('CreateEvent')%></button> 
  </div>  
  
    <div id="rawData" hidden><b><%=getTrans('RawData')%></b><br> <span id="outputData"></span>
	<br>
 <button id="copyData" onclick="copyTextToClipboard('outputData')" style="width:200px;padding: 10px 20px; background-color: #00000; color: black; border: none;border-radius: 5px; font-size: 16px; cursor: pointer;"><%=getTrans('CopytoClipboard')%></button> 		
	</div>  
<br>  
  <button id="resetButton" onclick="resetScanner(this)" style="width:200px;padding: 10px 20px; background-color: #e74c3c; color: white; border: none;border-radius: 5px; font-size: 16px; cursor: pointer;" hidden><%=getTrans('Reset')%></button> 
  
  
<script src="jsqr.js"></script>
<script>
//test codes available at
//https://qrcode.meetheed.com/qrcode_examples.php

var userAgent = navigator.userAgent;

  var video = document.createElement("video");
    var canvasElement = document.getElementById("canvas");
    var canvas = canvasElement.getContext("2d");

    var loadingMessage = document.getElementById("loadingMessage");
    var outputContainer = document.getElementById("output");
    var outputMessage = document.getElementById("outputMessage");
    var outputData = document.getElementById("outputData");
	var outputDataParsed = document.getElementById("outputDataParsed");
	var fetchCheckMessage= document.getElementById("fetchCheckMessage");
	var CreateSection= document.getElementById("CreateSection");
	var nativeAppSection= document.getElementById("nativeAppSection");
	var rawData= document.getElementById("rawData");
	var resetButton= document.getElementById("resetButton");
	
	var G_contact=null;
	var G_calendar=null;
	
	function resetScanner(sender){
		console.log("resetScanner...");
		video.hidden=true;
		canvas.hidden=true;		
		canvasElement.hidden=true;	
        outputData.parentElement.hidden = true;
		outputDataParsed.parentElement.hidden = true;
		outputDataParsed.innerText="";
		let fileInput = document.getElementById('fileInput');
		fileInput.value = '';
		fileInput.hidden=false;
		fetchCheckMessage.innerText='';
		CreateSection.hidden=true;		
		rawData.hidden = true;
		requestAnimationFrame(tick);
		console.log("resetScanner complete");
	}

    function drawLine(begin, end, color) {
      canvas.beginPath();
      canvas.moveTo(begin.x, begin.y);
      canvas.lineTo(end.x, end.y);
      canvas.lineWidth = 4;
      canvas.strokeStyle = color;
      canvas.stroke();
    }

	try{
		// Use facingMode: environment to attemt to get the front camera on phones
		navicgator.mediaDevices.getUserMedia({ video: { facingMode: "environment" } }).then(function(stream) {
		  video.srcObject = stream;
		  video.setAttribute("playsinline", true); // required to tell iOS safari we don't want fullscreen
		  video.play();
		});
	}catch(e){
		//fallback to file input
		
	}
    requestAnimationFrame(tick);

    function tick() {
      loadingMessage.innerText = "Loading video..."
	  //if (isWebView()||((video.readyState !== video.HAVE_ENOUGH_DATA))){
	  //if (!video || isWebView()) {
	  if (true){
		//ios or android versions
		nativeAppSection.hidden = false;
		loadingMessage.hidden = true;
        canvasElement.hidden = true;
        outputContainer.hidden = false;
		resetButton.hidden = false;
		outputMessage.hidden = true;
	  }else
      if (video.readyState === video.HAVE_ENOUGH_DATA) {
        loadingMessage.hidden = true;
        canvasElement.hidden = false;
        outputContainer.hidden = false;
		resetButton.hidden = false;

        canvasElement.height = 300;
        canvasElement.width = 300;
        canvas.drawImage(video, 0, 0, canvasElement.width, canvasElement.height);
        var imageData = canvas.getImageData(0, 0, canvasElement.width, canvasElement.height);
        var code = jsQR(imageData.data, imageData.width, imageData.height, {
          inversionAttempts: "dontInvert",
        });
		if (parseCodeValue(code)){
			//
        } else {
          outputMessage.hidden = false;
          outputData.parentElement.hidden = true;
		  //outputDataParsed.parentElement.hidden = true;
		  requestAnimationFrame(tick);
		  outputDataParsed.innerText="";
        }
      }else{
		requestAnimationFrame(tick);
	  }      
    }

function runImageParse(){
	loadingMessage.hidden = true;
	canvasElement.hidden = false;
	outputContainer.hidden = false;
	resetButton.hidden = false;
	
	var imageData = canvas.getImageData(0, 0, canvasElement.width, canvasElement.height);
		console.log(imageData.data);
	var code = jsQR(imageData.data, imageData.width, imageData.height, {
	  inversionAttempts: "dontInvert",
	});
	console.log("runImageParse",code);
	if (parseCodeValue(code)){
		console.log('parseCodeValue returned true');
	}else{
	  console.log('could not parse');
	  outputMessage.hidden = false;
	  outputData.parentElement.hidden = true;
	  //outputDataParsed.parentElement.hidden = true;
	  outputDataParsed.innerText=".";
	}
}

function parseCodeValue(code){
	if (code) {
	  drawLine(code.location.topLeftCorner, code.location.topRightCorner, "#FF3B58");
	  drawLine(code.location.topRightCorner, code.location.bottomRightCorner, "#FF3B58");
	  drawLine(code.location.bottomRightCorner, code.location.bottomLeftCorner, "#FF3B58");
	  drawLine(code.location.bottomLeftCorner, code.location.topLeftCorner, "#FF3B58");
	  outputMessage.hidden = true;
	  outputData.parentElement.hidden = false;
	  rawData.hidden = false;
	  //outputDataParsed.parentElement.hidden = false;//set to false to debug
	  outputData.innerText = code.data;
	  //outputData.innerText ="=" +JSON.stringify(code)+"=";
	  if (code.data.toLowerCase().indexOf(":vcard")>-1)
	  {		  
	  outputDataParsed.innerText="vcard";
		G_contact=parseVCard(code.data);
		video.hidden=true;
		canvas.hidden=true;
		canvasElement.hidden=true;
		nativeAppSection.hidden=true;
		checkcontact(G_contact);
	  }else if (code.data.toLowerCase().indexOf("mecard:")>-1)
	  {
	  outputDataParsed.innerText="me";
		G_contact=parseMECard(code.data);			
		video.hidden=true;
		canvas.hidden=true;		
		canvasElement.hidden=true;	
		nativeAppSection.hidden=true;
		checkcontact(G_contact);
	  }else if (code.data.toLowerCase().indexOf(":vevent")>-1)
	  {
	  outputDataParsed.innerText="vevent";
		G_calendar=parseVCalendarEvent(code.data);			
		video.hidden=true;
		canvas.hidden=true;		
		canvasElement.hidden=true;	
	  }else if (code.data.toLowerCase().indexOf("http")==0)
	  {
	    outputDataParsed.innerText="hyperlink";
		//G_calendar=parseVCalendarEvent(code.data);			
		video.hidden=true;
		canvas.hidden=true;		
		canvasElement.hidden=true;	
	  }
	  //outputData.innerText =code.data.toLowerCase().indexOf("mecard:")+"=" +JSON.stringify(G_contact)+"=";
	  return true;
	}
	return false;
}

function parseVCard(vCardString) {
    // Split vCard into lines
    const lines = vCardString.split('\n');

    // Initialize variables
    let contact = {};
    let currentProperty = '';

    // Iterate through each line
    for (const line of lines) {
        // Skip empty lines
        if (line.trim() === '') continue;

        // Check if the line starts with a property name
        if (line.includes(':')) {
            const [propertyName, propertyValue] = line.split(':');
            currentProperty = propertyName.trim().toLowerCase();

            // Add property to contact object
            if (contact[currentProperty]) {
                // If the property already exists, convert it to an array
                if (!Array.isArray(contact[currentProperty])) {
                    contact[currentProperty] = [contact[currentProperty]];
                }
                contact[currentProperty].push(propertyValue.trim());
            } else {
                contact[currentProperty] = propertyValue.trim();
            }
        } else if (currentProperty) {
            // If the line doesn't start with a property name, add it to the current property
            contact[currentProperty] += line.trim();
        }
    }

    return contact;
}	

function parseVCalendarEvent(vCalendarText) {
    // Split the vCalendar text into lines
    const lines = vCalendarText.split(/\r?\n/);

    // Initialize variables to store event details
    let event = {};
    let inEvent = false;

    // Iterate through each line in the vCalendar text
    for (const line of lines) {
        // Check for the beginning of an event
        if (line.startsWith('BEGIN:VEVENT')) {
            inEvent = true;
        }

        // Check for the end of an event
        if (line.startsWith('END:VEVENT')) {
            inEvent = false;
        }

        // Parse event details if inside an event
        if (inEvent) {
            // Split each line into key and value
            const [key, value] = line.split(':');

            // Store relevant information in the event object
            if (key && value) {
                event[key] = value;
            }
        }
    }

    return event;
}

function parseMECard(mecardString) {

/*
examples
const mecardString = 'MECARD:N:Joe;EMAIL:Joe@bloggs.com;;';
const mecardString22 = 'N:Smith,John;TEL:123456789;EMAIL:john.smith@example.com;NOTE:This is a note';

*/

    // Remove the leading "MECARD:"
    mecardString = mecardString.replace(/^MECARD:/, '');

    const mecardProperties = mecardString.split(';');
    let contact = {};

    for (const property of mecardProperties) {
        const [key, ...values] = property.split(':');
        const trimmedKey = key.trim().toLowerCase();
        const trimmedValue = values.join(':').trim();

        if (trimmedKey && trimmedValue) {
            if (contact[trimmedKey]) {
                // If the property already exists, convert it to an array
                if (!Array.isArray(contact[trimmedKey])) {
                    contact[trimmedKey] = [contact[trimmedKey]];
                }
                contact[trimmedKey].push(trimmedValue);
            } else {
                contact[trimmedKey] = trimmedValue;
            }
        }
    }

    return contact;
}

function checkcontact(ContactObj){
  outputDataParsed.innerText=JSON.stringify(ContactObj);
  var _email=getContactEmail(G_contact);
  var checkurl="<%= CRM.Url('sagecrmws/ac2020/emailsearch.asp')%>&email="+_email;
  makeFetchRequest(checkurl,ContactObj);
  let fileInput = document.getElementById('fileInput');
  fileInput.value = '';
  fileInput.hidden=true;
}
function getContactItemByKey(keytoCheck){

/*
example G_contact
{
    "begin": "VCARD",
    "version": "3.0",
    "n": "Blogs;Joe;G;;",
    "fn": "Joe G Blogs",
    "org": "companyx",
    "title": "CEO",
    "email;type=internet;type=work": "work@test.com",
    "email;type=internet;type=home": "home@test.com",
    "tel;type=cell": "mob9999999",
    "tel;type=work": "wok8879797",
    "tel;type=home": "home86867868768",
    "tel;type=work,fax": "fax9798798789",
    "adr;type=work": ";;3015 Lake Dirve;Dublin 86876;state123;768768;uSA",
    "adr;type=home": ";;20 somewhere;kildare;state897;987987;ireland",
    "url;type=work": "crmtogeher.com",
    "url;type=home": "home.com",
    "end": "VCARD"
}
*/

  var res="";
  console.log('getContactItemByKey',keytoCheck);
  console.log('G_contact',G_contact);
  for (const key in G_contact) {
	if (G_contact.hasOwnProperty(key)) {
		const value = new String(G_contact[key]);
		console.log(`${key}: ${Array.isArray(value) ? value.join(', ') : value}`);
		if (key.indexOf(keytoCheck)>-1)
		{
		  res=value;		
		  break;
		}
	}
  }
  console.log('getContactItemByKey result',res);
  return res;
}
function getContactEmail(){
  return getContactItemByKey('email');
}
function getContactPhone(){
  return getContactItemByKey('tel');
}
function getContactCompany(){
  return getContactItemByKey('org');
}
function getLeadDescription(){
  if (getContactCompany()!="")
  {
	return getContactCompany();
  }else if (getContactItemByKey('fn')!=""){
    return getContactItemByKey('fn');
  }else{
	return getContactEmail();
  }
}

//returns array
function getContactName(){
	var res=[];
	var fullname="";
	var fullname1=new String(G_contact["n"]);
	var fullname2=new String(G_contact["fn"]);
	fullname=fullname1;
	if (fullname2.length>fullname1.length)
	{
	    fullname=fullname2;
	    res=fullname.split(" ");
	}else{
		res=fullname.split(";");
	}
	return res;
}
function getContactAddress(){
	var workaddress=new String(getContactItemByKey('adr'));
	var workaddressarr=workaddress.split(";");	
	
	return workaddressarr;
}
function getContactURL(){
	 return new String(getContactItemByKey('url'));
}

function makeFetchRequest(_url, ContactObj) {
    // Make a GET request to the URL /example
    fetch(_url)
        .then(response => {
            // Check if the request was successful
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            // Parse the response as JSON or text	
            return response.json(); // or response.text() for plain text
        })
        .then(data => {
            // Process the data
            
			data=JSON.parse(data);
			console.log("xx",data);
			if (data.data.recordcount==1)
			{
				fetchCheckMessage.innerHTML="Match found for email address:<br>"+
					"<a href=\"mailto:"+data.data.searchstring+"\" >"+data.data.searchstring+"</a>";
				CreateSection.hidden=false;		
			}else if (data.data.recordcount>1)
			{
				fetchCheckMessage.innerHTML="<b><%=getTrans('matchesfoundforemail')%>:<b><br>"+
					"<a href=\"mailto:"+data.data.searchstring+"\" >"+data.data.searchstring+"</a>";
				CreateSection.hidden=false;		
			}else{
				//option
				CreateSection.hidden=false;		
			}			
        })
        .catch(error => {
            // Handle errors
            console.error('Fetch error:', error);
        });
}

function createEvent(){

}

function createCompany(){
	var fullnamearr=getContactName(G_contact);
	var workaddressarr=getContactAddress()
  // Get form data
    const formData = new URLSearchParams();
	formData.append('username', '<%=CRM.getContextInfo('user','user_logon')%>');
	formData.append('entity', 'company');

var data=[{"name":"comp_name","value":getLeadDescription()},
			{"name":"comp_website","value":getContactURL()},
			{"name":"comp_source","value":"Tradeshow"},
			{"name":"comp_status","value":"Active"},
			{"name":"comp_type","value":"Prospect"},
			{"name":"comp_channelid","value":"<%=CRM.getContextInfo('user','user_primarychannelid')%>"},
			{"name":"addr_address1","value":workaddressarr[2]},
			{"name":"addr_city","value":workaddressarr[3]},
			{"name":"addr_postcode","value":workaddressarr[5]},
			{"name":"addr_state","value":workaddressarr[4]},
			{"name":"addr_country","value":workaddressarr[6]},
			{"name":"pers_firstname","value":fullnamearr[1]},
			{"name":"pers_lastname","value":fullnamearr[0]},
			{"name":"phonefield_Business","value":{"countrycode_value":"","areacode_value":"","phonenumber_value":getContactPhone(),"type":"Business"}},
			{"name":"emailfield_Business","value":{"emailaddress":getContactEmail(),"type":"Business"}}
			]			
	formData.append('data', JSON.stringify(data));
    // Make a POST request using the Fetch API
	var _url='<%=CRM.Url("sagecrmws/ac2020/createEntity.asp")%>';
	console.log(_url);	
    fetch(_url, {
        method: 'POST', 
		headers: {
			'Content-Type': 'application/x-www-form-urlencoded',
		  },
        body: formData,
    })
    .then(response => {
        // Check if the request was successful
        if (!response.ok) {
			fetchCheckMessage.innerText='Network response was not ok';
            throw new Error('Network response was not ok');
        }		
        // Parse the response as JSON or text		
        return response.json(); // or response.text() for plain text
    })
    .then(data => {
        // Process the data
        console.log('createEntity', data);
		//hide everything bar resat and created message 
		resetScanner(null);	
		fetchCheckMessage.innerHTML="<%=CRM.GetTrans("GenCaptions","Created")%><br><b>"+
		getLeadDescription()+"</b><br>"+
		"<a href=\"mailto:"+getContactEmail()+"\" >"+getContactEmail()+"</a>";
    })
    .catch(error => {
        // Handle errors
        console.error('Fetch error:', error);
		fetchCheckMessage.innerText="-<%=getTrans("ErrorCreatingCompany")%>-";
		fetchCheckMessage.innerText+=JSON.stringify(error);
    });
	
}

function createLead(){

	var fullnamearr=getContactName(G_contact);
	var workaddressarr=getContactAddress()
  // Get form data
    const formData = new URLSearchParams();
	formData.append('username', '<%=CRM.getContextInfo('user','user_logon')%>');
	formData.append('entity', 'lead');
	
var data= [{"name":"lead_description","value":getLeadDescription()},
			{"name":"lead_details","value":outputData.innerText},
			{"name":"lead_companyname","value":getContactCompany()},
			{"name":"lead_personfirstname","value":fullnamearr[1]},
			{"name":"lead_personlastname","value":fullnamearr[0]},
			{"name":"lead_personemail","value":getContactEmail()},
			{"name":"lead_personphonenumber","value":getContactPhone()},
			{"name":"lead_companywebsite","value":getContactURL()},
			{"name":"Lead_PersonTitle","value":getContactItemByKey('title')},
			{"name":"Lead_CompanyAddress1","value":workaddressarr[2]},
			{"name":"Lead_CompanyCity","value":workaddressarr[3]},
			{"name":"Lead_CompanyState","value":workaddressarr[4]},
			{"name":"Lead_companyPostCode","value":workaddressarr[5]},
			{"name":"lead_companycountry","value":workaddressarr[6]},
			]
	formData.append('data', JSON.stringify(data));
    // Make a POST request using the Fetch API
	  var _url='<%=CRM.Url("sagecrmws/ac2020/createEntity.asp")%>';
	  console.log(_url);	
    fetch(_url, {
        method: 'POST', 
		headers: {
			'Content-Type': 'application/x-www-form-urlencoded',
		  },
        body: formData,
    })
    .then(response => {
        // Check if the request was successful
        if (!response.ok) {
			fetchCheckMessage.innerText='Network response was not ok';
            throw new Error('Network response was not ok');
        }		
        // Parse the response as JSON or text		
        return response.json(); // or response.text() for plain text
    })
    .then(data => {
        // Process the data
        console.log('createEntity', data);
		//hide everything bar resat and created message 
		resetScanner(null);
		fetchCheckMessage.innerHTML="<%=CRM.GetTrans("GenCaptions","Created")%><br><b>"+
		data.data.data.lead_description+"<br></b>"+
		"<a href=\"mailto:"+data.data.data.lead_personemail+"\" >"+data.data.data.lead_personemail+"</a>";

    })
    .catch(error => {
        // Handle errors
        console.error('Fetch error:', error);
		fetchCheckMessage.innerText="-<% getTrans("ErrorCreatingLead")%>-";
		fetchCheckMessage.innerText+=JSON.stringify(error);
    });
}

function isWebView() {

 return true;//testing
 
 
  var userAgent = navigator.userAgent;

  // Check for iOS WebView
  if (/iPhone|iPad|iPod/i.test(userAgent) && !window.MSStream) {
    return true;
  }

  // Check for Android WebView
  if (/Android/i.test(userAgent) && userAgent.includes('wv')) {
    return true;
  }

  return false;
}

</script>
<script>
  function copyTextToClipboard(elementToUse) {
    // Get the span element
    const spanElement = document.getElementById(elementToUse);

    // Create a range and select the text inside the span
    const range = document.createRange();
    range.selectNode(spanElement);

    // Create a selection and add the range to it
    const selection = window.getSelection();
    selection.removeAllRanges();
    selection.addRange(range);

    // Copy the selected text to the clipboard
    document.execCommand('copy');

    // Clear the selection
    selection.removeAllRanges();

    // Alert the user or perform any other action to indicate that the text has been copied
    console.log('Text has been copied to the clipboard!');
  }
</script>