//= require arctic_admin/base
//= require active_admin/searchable_select

$(document).ready(function() {
  $('.my-dairy-select').on('change', function() {
    var dairyId = $(this).val();
    if (dairyId) {
      $.ajax({
        url: '/admin/charts_by_dairy/' + dairyId,
        type: 'GET',
        success: function(data) {
          var chartSelect = $('.chart-select');
          chartSelect.empty().prop('disabled', false);
          chartSelect.append('<option value="">Select Chart</option>');
          data.forEach(function(chart) {
            chartSelect.append('<option value="' + chart.id + '">' + chart.name + '</option>');
          });
        }
      });
    } else {
      $('.chart-select').empty().prop('disabled', true);
    }
  });
});
