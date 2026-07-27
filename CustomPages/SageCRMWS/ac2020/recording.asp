<!-- #include file ="sagecrm.js" -->
<!-- #include file ="json2.js" -->
<!-- #include file ="_base_objects.js" -->
<!-- #include file ="io.js" -->
<!-- #include file ="configReader.js" -->
<!-- #include file ="helpers.js" -->
<!DOCTYPE html>
<head>
	<meta http-equiv='X-UA-Compatible' content='IE=edge' ><META http-equiv="Content-Type" content="text/html; charset=utf-8">
	<META HTTP-EQUIV="Expires" CONTENT="-1"><META HTTP-EQUIV="Pragma" CONTENT="no-cache">
	<META HTTP-EQUIV="Cache-Control" CONTENT="no-cache,no-Store">
   
    <script src="/<%=sInstallName%>/CustomPages/SageCRMWS/js/lib/jquery-1.8.2.min.js"></script>
	
	<link REL="stylesheet" href="/<%=sInstallName%>/CustomPages/SageCRMWS/ac2020/ctmobile.css"/>
	<script                 src="/<%=sInstallName%>/CustomPages/SageCRMWS/ac2020/ctmobile.js"></script>
</head>
<style>  body{      background-color: #EBEDEF !important;      color: black !important;  }  </style>
<%

var entity = new String(Request.QueryString("entity")).toLowerCase();
var entityId = Request.QueryString("id");


var user_userid = CRM.GetContextInfo("user", "user_userid");
CRM.Mode=1;
var block = Request.QueryString("block");
var _actionid = Request.QueryString("_actionid");
var newComm = CRM.CreateRecord("communication");
newComm.comm_datetime=(new Date()).getVarDate();
newComm.comm_todatetime=(new Date()).getVarDate();
newComm.comm_type="Task";
newComm.comm_status="Complete";
newComm.comm_priority="Normal";
//newComm.comm_secterr=getUser_PrimaryTerritory();//we get this from the getAssignmentObject call below
newComm.comm_channelid=getUser_PrimaryChannelId();
	
var assignmentObject=getAssignmentObject({"entity":entity, "entityid":entityId});
newComm.comm_secterr=assignmentObject.territory;
	
var commLink = CRM.CreateRecord("Comm_Link");

var entInfo = CRM.FindRecord("Custom_Tables", "bord_name='"+entity+"'");

if (Defined(Request.Form())) {
    if (entity=='company')
        commLink.cmli_comm_companyid= entityId;
    else if (entity == 'person')
        commLink.cmli_comm_personid= entityId;
    else if (entity == 'opportunity') {
        newComm.comm_opportunityid = entityId;
        oppo = CRM.FindRecord("Opportunity", "oppo_opportunityid=" + entityId);
        commLink.cmli_comm_companyid=oppo("oppo_primarycompanyid");
        commLink.cmli_comm_personid=oppo("oppo_primarypersonid");
    }
    else if (entity == 'cases') {
        newComm.comm_caseid = entityId;
        caseRecord = CRM.FindRecord("Cases", "case_caseid=" + entityId);
        commLink.cmli_comm_companyid=caseRecord("case_primarycompanyid");
        commLink.cmli_comm_personid=caseRecord("case_primarypersonid");
    }
    else if (entity == 'lead') {
        newComm.comm_leadid = entityId;
        commLink.cmli_comm_leadid=entityId;
        lead = CRM.FindRecord("Lead", "lead_leadid=" + entityId);
        commLink.cmli_comm_companyid=lead("lead_primarycompanyid");
        commLink.cmli_comm_personid=lead("lead_primarypersonid");
    }
    commLink.cmli_recordid=entityId;
    commLink.cmli_entityid=entInfo("bord_tableid");
    commLink.cmli_comm_userid=user_userid;
    CRM.Mode = Save;
} 
else { 
    
	CRM.Mode = Edit;
}
	
Container = CRM.GetBlock("container");
Container.DisplayForm=false;
Container.DisplayButton(Button_Default) = false;

//Entry=CRM.GetBlock("communicationofficeint");//communicationofficeint usually does not exist by default	
var Entry=CRM.GetBlock("entrygroup");
Entry.Title="New Commuication with File";
Entry.DisplayForm=false;

Entry.AddEntry("comm_action", 0, true);
Entry.AddEntry("comm_subject", 1, true);
Entry.AddEntry("comm_note", 2, true);

Container.AddBlock(Entry);

var s = '<div style="margin-left:5px"><form id="form2" enctype="multipart/form-data" method="post" action="">'+
    '<br/><div style="width: 90%">'+
	'<input type="file" id="file"  name="file" id="file" /></div>'+
	'</form>' +
    '<div id="audioRecordingWrapper" style="display:none;margin-top:20px;">' + 
	'---OR---<br/><br/>'+
    '<button id="startBtn"  >Start Recording</button><br/><br/>' +
    '<button class="er_buttonItem" id="stopBtn" disabled  >Stop Recording</button>'+   
    '<br/><br/>'+ 
    '<audio id="audioPlayback" controls style="display:none;"></audio>'+
    '<br/><div id="recordingLinks" style="display:none;">' + 
    //'<button id="downloadLink" href="#"  >Download Recording</button>'+
	//'<button id="clearLink" href="javascript:clearRecording()"  >Clear Recording</button></div>' +
    '</div></div>';

var formHtml = '<form id="form1" method="POST">' + Container.Execute(newComm) + '</form>';

if (CRM.Mode == Save) {
    
    commLink.cmli_comm_communicationid=newComm.RecordId;
    commLink.SaveChangesNoTls();
    Response.Clear();
    Response.Write(newComm.RecordId);
    Response.End();
}
else {
   formHtml =s+formHtml;
}

Response.Write(formHtml + '<div style="margin-left:40px"><br/>'+
'<input   type="button" value="Submit" onClick="sendComm()" /></div>');

%>

<script>
let audioBlob=null;
function sendComm() {

    //document.getElementById('form1').submit();

    const formData = new URLSearchParams(new FormData(document.getElementById('form1'))).toString();
    fetch('/<%=sInstallName%>/CustomPages/SageCRMWS/ac2020/recording.asp?SID=<%=Request.QueryString("SID")%>&sInstallName=<%=sInstallName%>&entity=<%=Request.QueryString("entity")%>&id=<%=Request.QueryString("id")%>', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: formData
      })
      .then(response => {       
        if (response.ok) return response.text();
        throw new Error('Network response was not ok.');
      })
      .then(commId => {
            console.log('commId', commId);
            //console.log(audioBlob);
            if (document.getElementById("file").value!="") {
                document.getElementById('form2').action = "/<%=sInstallName%>/Custompages/SageCRMWS/ac2020/clsUpload2002.asp?SID=<%=Request.QueryString('SID')%>&sInstallName=<%=sInstallName%>&commId=" + commId + "&entity=<%=Request.QueryString('entity')%>&id=<%=Request.QueryString('id')%>";
                document.getElementById('form2').submit();
            } else if (audioBlob != null) {
                //submit if we have an audio blob ----------------------
                const formDataAudio = new FormData();
                formDataAudio.append('file', audioBlob);          
                //console.log(formDataAudio);

                // Now send the FormData with both the input file and the audio blob
                fetch("/<%=sInstallName%>/CustomPages/SageCRMWS/ac2020/clsUpload2002.asp?SID=<%=Request.QueryString('SID')%>&sInstallName=<%=sInstallName%>&commId=" + commId + "&entity=<%=Request.QueryString('entity')%>&id=<%=Request.QueryString('id')%>", {
                    method: 'POST',
                    body: audioBlob,
                })
                .then(response => {
                    if (response.ok) return response.text();
                    throw new Error('Network response was not ok.');
                })
                .then(data => {
                    console.log('Form uploaded successfully:', data);
                    alert('Communication Created');
                    document.location.href=document.location.href;
                })
                .catch(error => {
                    console.error('Error uploading form:', error);
                    alert('Error uploading form. Please try again.');
                });
            } else {

                alert('Communication Created');
                document.location.href=document.location.href;
            }
        })
        .catch(error => {
            console.error('Error submitting form:', error);
            alert('Error submitting form. Please try again.');
        });
        //end submit the audio file
    }

    let mediaRecorder;
    let audioChunks = [];



    function clearRecording() {
        audioChunks = [];
		document.getElementById('audioPlayback').src = "";
		document.getElementById('audioPlayback').style.display = 'none';
    }

    // Get access to the microphone
    navigator.mediaDevices.getUserMedia({ audio: true })
        .then(stream => {
            document.getElementById("audioRecordingWrapper").style.display='block';
            mediaRecorder = new MediaRecorder(stream);

            // When data is available, push it to the audioChunks array
            mediaRecorder.ondataavailable = event => {
                audioChunks.push(event.data);
            };

            // When recording stops, create a Blob and provide a download link
            mediaRecorder.onstop = () => {
                audioBlob = new Blob(audioChunks, { type: 'audio/wav' });
                const audioUrl = URL.createObjectURL(audioBlob);
                const audioPlayback = document.getElementById('audioPlayback');
                audioPlayback.src = audioUrl;
                audioPlayback.style.display = 'block';
            };
        });

    // Start recording
    document.getElementById('startBtn').onclick = () => {
		clearRecording();
        audioChunks = []; // Reset audio chunks
        mediaRecorder.start();
        document.getElementById('startBtn').innerText='...recording in progress';
        document.getElementById('startBtn').disabled = true;        
        document.getElementById('stopBtn').disabled = false;
    };

    // Stop recording
    document.getElementById('stopBtn').onclick = () => {
        mediaRecorder.stop();
        document.getElementById('startBtn').innerText='Start Recording';
        document.getElementById('startBtn').disabled = false;        
        document.getElementById('stopBtn').disabled = true;
    };
</script>
</body>
</html>