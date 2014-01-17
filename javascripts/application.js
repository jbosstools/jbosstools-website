$(function(){
  // sidebar Affix

  var topPosition     =   120;
  var bottomPosition  =   40+371;
  // 40 is same value as bottom defined by .bs-docs-sidenav.affix-bottom selector
  // $('footer').outerHeight(true) + $('#companyfooter').outerHeight(true) should == 371. Delay call until document layout is done, because missing image causes invalid height value !!
  console.log("loading affix. " + 40 + "+" + $('footer').outerHeight(true) + "+" + $('#companyfooter').outerHeight(true))
  $('.bs-docs-sidenav').affix({
    offset: {
      top: topPosition
    , bottom: bottomPosition
    }
  });
  //$('.bs-docs-sidenav').addClass("affix-bottom");
  $('.span9').css('min-height', ($('.bs-docs-sidenav').outerHeight(true) + 100) + 'px');
  console.log("Affix loaded");
});
