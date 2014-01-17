$(function(){
  // sidebar Affix
  var topPosition     =   120;
  var bottomPosition  =   400;
  $('.bs-docs-sidenav').affix({
    offset: {
      top: topPosition
    , bottom: bottomPosition
    }
  });
  
});
