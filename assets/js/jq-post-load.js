/* Add class 'fixed' to a '#getFixed' block in order to fix its
 * position while scrolling
 */
$(document).ready(function () {
  var top = $('#getFixed').offset().top -
    parseFloat($('#getFixed').css('marginTop').replace(/auto/, 0)) -
    parseFloat($('body').css('paddingTop'));

  $(window).scroll(function (event) {
    // what the y position of the scroll is
    var y = $(this).scrollTop();

    // whether that's below the form
    if (y >= top) {
      // if so, ad the fixed class
      $('#getFixed').addClass('fixed');
    } else {
      // otherwise remove it
      $('#getFixed').removeClass('fixed');
    }
  });
});
