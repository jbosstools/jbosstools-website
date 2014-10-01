$(document).ready(function () {
  $('#installation_tabs li:not(.disabled):first>a').tab('show');
});  

$(function(){
  var hash = window.location.hash;
  hash && $('ul.nav a[href="' + hash + '"]').tab('show');

  $('.nav-tabs a').click(function (e) {
    //$(this).tab('show');
    var scrollmem = $('body').offset().top - $(document).scrollTop();
    window.location.hash = this.hash;
    $('body').offset(scrollmem, 0);
  });
});
