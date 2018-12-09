var act;
function scroll_page(){

  if(window.innerWidth<768 && act>=768){
    $.scrollify.destroy();
  }

  else if(act<768 && window.innerWidth>=768){
    $(function(){
      $.scrollify({
        section : ".panel"
      });
    });
  }

  act = window.innerWidth;
}

window.addEventListener("resize", function(event){
  scroll_page();
});

var aux_dalay;

$(function(){
  act = window.innerWidth;
  $.scrollify({
    section:".panel",
    scrollbars:false,
    before:function(i,panels){
      var ref = panels[i].attr("data-section-name");

      $(".pagination .active").removeClass("active");

      $(".pagination").find("a[href=\"#" + ref + "\"]").addClass("active");
    },
    afterRender:function(){
      var pagination = "<ul class=\"pagination\">";
      var activeClass = "";
      $(".panel").each(function(i){
        activeClass = "";
        if(i===0){
          activeClass = "active";
        }
      });

      pagination += "</ul>";

      $(".home").append(pagination);
      $(".pagination a, a.scroll-to").on("click",$.scrollify.move);
    }
  });

  if(window.innerWidth < 768){
    $.scrollify.destroy();
  } else {
    $(".icon-2").data("delay", "200")
    $(".icon-3").data("delay", "400")
    $(".icon-4").data("delay", "600")
    $(".icon-5").data("delay", "800")
  }
});
