$(document).on("turbolinks:load", function() {
  $('.animated').each(function() {
    var item = $(this)
    var delay = $(this).data("delay")

    if (delay == null) {
      delay = 0;
    }

    if ($(this).data("scroll") == 0 || $(this).data("scroll") == null) {
      setTimeout(function() {
        item.addClass('in');
      }, delay);
    }
  });
});


$(window).scroll(function() {
  $('.animated').each(function() {
    var position = $(this).offset().top;
    var delay = $(this).data("delay")
    var item = $(this)

    if (delay == null) {
      delay = 0;
    }

    $.fn.scrollBottom = function() {
      return $(document).height() - this.scrollTop() - this.height();
    };

    var topOfWindow = $(window).scrollTop();
    var bottomOfWindow = $(window).scrollBottom();

    if ($(this).data("scroll") != 0 || $(this).data("scroll") != null) {
      if (position < topOfWindow + 700 || position == bottomOfWindow) {
        setTimeout(function() {
          item.addClass('in');
        }, delay);
      }
    }
  });
});

(function() {
  $('.multiple-item .item').each(function() {
    var itemToClone = $(this);

    for (var i = 1; i < 4; i++) {
      itemToClone = itemToClone.next();

      // wrap around if at end of item collection
      if (!itemToClone.length) {
        itemToClone = $(this).siblings(':first');
      }

      // grab item, clone, add marker class, add to collection
      itemToClone.children(':first-child').clone()
      .addClass("cloneditem-" + (i))
      .appendTo($(this));
    }
  });

  $('.carousel-testimonial').each(function(){
    $(this).carousel({interval: $(this).data("interval")}).on('slide.bs.carousel', function(e) {
      var nextH = $(e.relatedTarget).height();
      $(this).find('.item.active').parent().animate({
        height: nextH
      }, $(this).data("adjust"));
    });
  });
}());


$(".carousel").swipe({
  swipe: function(event, direction, distance, duration, fingerCount, fingerData) {

    if (direction == 'left') $(this).carousel('next');
    if (direction == 'right') $(this).carousel('prev');

  },
  allowPageScroll: "vertical"
});

$('body').on('hidden.bs.modal', '.modal', function () {
  $('video').trigger('pause');
});
