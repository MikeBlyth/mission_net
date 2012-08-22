//$(function() {
//  $("td.wife-column").click(function(e){
//      e.preventDefault();
//      // set the choices if we are NOT clicking inside the select control
//      sel = $(e.target).closest('select')
//      if (sel.length == 0 || sel[0].name != 'inplace_value') {
//        set_spouse_choices($(this))
//      }      
//    })
//});

$(function() {
  $("#as_members-active-scaffold").on('click', "td.wife-column", function(e){
      e.preventDefault();
      // set the choices if we are NOT clicking inside the select control
      sel = $(e.target).closest('select')
      if (sel.length == 0 || sel[0].name != 'inplace_value') {
        set_spouse_choices($(this))
      }      
    })
});


function set_spouse_choices (cell){
//  var select_control = $('select.spouse-input',as_form);
  var id = /[0-9]+/.exec(cell.closest('tr').attr('id'));
  var head = $('#record_wife_'); /* This is where AS puts the choices */
    $("#record_wife_ option").remove();
    $.ajax({
      async: false,
      type: 'GET',
      cache: false,
      url: "members/wife_select.js",
      data: 'id='+id,
      dataType: "json",
      success: function(data) {
        head.append(data.options);
        }
    });
    id = 1
}; 

