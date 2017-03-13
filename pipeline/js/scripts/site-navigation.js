$(document).ready(function() {
    $('ul.menu').each(function(item, val) {
        console.log($(val).find('a.menu-item-link.open').length);
        if($('a.menu-item-link.open', $(val)).length) {
            $(val).show();
        }
    });
});
function activatelevelnav(level) {
  $('.menu-item-link-'+level+'.has-children').on('click', function(evt) {
    // evt.preventDefault();
    // evt.stopPropagation();
    var $ul = $(this).next('ul'),
    siblingLinks = $(
     '.menu-item-link-'+level+'.has-children.open'
    ).next('ul');
    siblingLinks.velocity('slideUp', { easing: 'easeOut', duration: 200 });
    var isOpen = $(this).hasClass('open'),
      slideDir = isOpen ? 'slideUp' : 'slideDown',
      dur = isOpen ? 200 : 400;
    $ul.velocity(slideDir, {
      easing: 'easeOut',
      duration: dur
    });
    siblingLinks.velocity('slideUp', { easing: 'easeOut', duration: 200 });
      console.log(isOpen);
    if (isOpen) {
      $(this).removeClass('open');
    } else {
      $(this).addClass('open');
    }
  });
}
for (var i = 1; i <= 10; i++) { activatelevelnav(i); }
$(document).ready(function() {
  $(".trigger").on("click", function(evt) {
    evt.preventDefault();
    evt.stopPropagation();
    $(".navbutton__wrapper").toggleClass("nav__wrapper--active");
    $('#site-navigation,.all-content-wrapper').toggleClass('navigation-open');
  });
});

// close navigation if body content is clicked when docs are open
$('#all-content-wrapper').on('click', function() {
  if ($('.site-navigation.navigation-open')) {
    $('.site-navigation.navigation-open,.all-content-wrapper.navigation-open').removeClass('navigation-open');
    $('.navbutton__wrapper.nav__wrapper--active').removeClass('nav__wrapper--active');
  }
});

