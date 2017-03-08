$(document).ready(function() {
  var isHome = document.getElementById('homepage') ? true : false;
  if (!isHome) {
    return;
  } else {
      console.log('Home sweet Home');
  }
});
