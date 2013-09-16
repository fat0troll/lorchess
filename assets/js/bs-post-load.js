/* Fix the position of chess board while scrolling */
$('#GameWrapper center').affix({
  offset: {
    top: function () {
      return $('#GameWrapper').offset().top -
        parseFloat($('body').css('paddingTop'))
    }
  }
});
