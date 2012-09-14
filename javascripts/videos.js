!function ($) {
  $(function(){
    var href=location.hash;
    if(href != "") {
      play(href.replace('#',''));
    }
  })
}(window.jQuery)

$(document).ready(function() {
  $('.videocontrol').click(function(e) {
    e.preventDefault(); //prevent href from actually loading
    var href = $(this).attr('href');
    location.hash = href;
    play(href);
  });
})


function play(videoId) {
  if(videoId != null) {
    var videoURL = "http://player.vimeo.com/video/" + videoId + "?portrait=0";
    $('#player').load(videoURL, function() {
      $('iframe').attr('src', videoURL);
    });
  }
  return;
}