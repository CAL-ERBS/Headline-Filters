//file to tidy up sage crm generated html for display in AC and MX
//file: ctmobile.js
//

document.addEventListener("DOMContentLoaded", function() {
  const paneleftcorner = document.querySelector('img[src*="paneleftcorner.jpg"]');
  if (paneleftcorner) {
    paneleftcorner.remove();
  }
  const panerightcorner = document.querySelector('img[src*="panerightcorner.gif"]');
  if (panerightcorner) {
    panerightcorner.remove();
  }
});
