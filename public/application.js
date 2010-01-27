$().ready(function() {
  
  $('#acapp #submit_form').attr("disabled", "disabled");
  $('#acapp #attending').attr("disabled", "disabled");
  $('#acapp #code').attr("disabled", "disabled");

  ///Check for Name
  $('#acapp #cadet_id').change(function() {
    if($(this).val() != "nil") {
      $('#acapp #attending').attr("disabled", false);
    } else {
      $('#acapp #attending').attr("disabled", "disabled");
      $('#acapp #submit_form').attr("disabled", "disabled");
    }
  });
  
  //Check for Radio Buttons
  $('#acapp #attending').change(function() {
    
    $('#acapp.allocate p').show();
    if ($(this).val() == true) {
      $('#not_be').hide();
    } else {
      $('#not_be').show();
    }
    
    $('#acapp #code').attr("disabled", false);
    
  });
  
  
  //Check for code
  $('#acapp #code').keyup(function() {
    if ($(this).val().length < 3) {
      $('#acapp #code').css("background-color", "#FFBABA");
      $('#acapp #submit_form').attr("disabled", "disabled");
    } else {
      $('#acapp #code').css("background-color", "#DFF2BF");
      $('#acapp #submit_form').attr("disabled", false);
    }
  });

  
  
  $('textarea.tinymce').tinymce({
    // Location of TinyMCE script
    script_url : '/tiny_mce/tiny_mce.js',
    theme : "simple"
  });
  
});