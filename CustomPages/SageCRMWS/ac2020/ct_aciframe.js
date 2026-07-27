
function __getBrowserXUrlCore() {
    console.log('__getBrowserXUrlCore');
    var __sid = crm.url({ arg: 'SID' });
    console.log('__getBrowserXUrlCore:' + __sid);
    var _installName = crm.installName();
    var _installUrl = crm.installUrl();
    var _http = crm.url(_installUrl, { parts: 's' });
    var _server = crm.url(_installUrl, { parts: 'a' });

    var __browserxurlcore = _http + _server + "/" + _installName + "/custompages/sagecrmws/webappmx/#/";

    console.log('__browserxurlcore:' + __browserxurlcore);
    return __browserxurlcore;
}

function OpenAccelerator(){
    console.log('__browserxOpenApp',aciframe.style.display);

	if (aciframe.style.display=='none')
		aciframe.style.display='initial';
    else
		aciframe.style.display='none';
	aciframe.width = "425";
	aciframe.height = "750";
	aciframe.frameBorder ="1";
	aciframe.scrolling = "0";
	aciframe.style.border= "none";
	aciframe.style.background = "white";
	aciframe.style.position='absolute';
	aciframe.style.right='150px';
	aciframe.style.bottom='100px';
	aciframe.style.zIndex = "9999999";
	
}

var aciframe
crm.ready(() => {
	
	const parentDiv = document.getElementById("new-list").parentNode;
	var _aciframecode='	<div class="er_new" id="er_new" style="right: 100px;top: 75px;">'+
	  '	<img id="new-accelerator" style="cursor:pointer;display=none;" src="/crm/CustomPages/SageCRMWs/js/lib/vue/css/atomlogo.svg" '+
	  'onclick="OpenAccelerator()" title="MobileX"></div>';
	
    parentDiv.insertAdjacentHTML("afterend",_aciframecode);

aciframe = document.createElement("iframe");
aciframe.src = __getBrowserXUrlCore();
aciframe.width = "425";
aciframe.height = "750";
aciframe.frameBorder ="1";
aciframe.scrolling = "0";
aciframe.style.border= "none";
aciframe.style.background = "white";
aciframe.style.position='absolute';
aciframe.style.right='150px';
aciframe.style.bottom='100px';
aciframe.style.display='none';
document.body.appendChild(aciframe);

});