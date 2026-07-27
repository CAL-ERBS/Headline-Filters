////////////////////////////////////////
//Author: CRM Together crmtogether.com
//filename: ct_commemail.js
//Location should be WWWRoot\js\custom
//This file is used in the Accelerator and MobileX products to allow us store emails as files instead of comm_email but to still be seemless to the user
//by loading the email.html file should it exist
////////////////////////////////////////
function cleverForward(){
	
}
crm.ready(() => {

	var _act= crm.url({ arg: 'Act' });
	console.log("_act",_act);
	//1500=forward email
	if ((_act!=363)&&(_act!=374)&&(_act!=1500))
		return;

	// Iterate over the NodeList of anchor elements
	var _foundlink="";
    const anchorElements = document.querySelectorAll('a');
	for (let i = 0; i < anchorElements.length; i++) {
		const anchor = anchorElements[i];
		console.log(anchor.href);

		if (anchor.href.includes('email.html')) {
			console.log('Found email link, breaking the loop.');
			_foundlink=anchor.href;
			console.log("_foundlink",_foundlink);
			console.log("=",anchor.style);
			if ((_act==363)||(_act==374)){
				const iframe = document.querySelector('iframe');
				if (iframe) {
					iframe.src = _foundlink;
				}
			}else if (_act==1500){
				fetch(anchor.href)
				  .then(response => {
					if (!response.ok) {
					  throw new Error('Network response was not ok ' + response.statusText);
					}
					return response.text();
				  })
				  .then(data => {
					const textarea = document.getElementById('edit');
					textarea.value +=data;
				  })
				  .catch(error => {
					console.error('There was a problem with the fetch operation:', error);
				  });				
			}
			break;
		}
	}		

                   
});