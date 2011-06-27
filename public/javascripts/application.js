///////////////////////
// AJAX JQuery setup 

function handleError(XMLHttpRequest, textStatus, errorThrown) {
  answer = confirm('An error ocurred while updating a post.  The page needs to be refreshed.  Click OK to refresh the page now, or Cancel if you wish to refresh the page manually.')
  if( answer )
    window.location.reload();
}

jQuery.ajaxSetup({ 
  'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")},
  timeout : 5000,
  error : handleError
});


jQuery.fn.submitWithAjax = function() {
  this.submit(function() {
    try
    {
      jQuery.post(this.action, $(this).serialize(), null, "script");
    }
    catch(e)
    {
      handleError( null, 'no_connection', e );
    }
    
    return false;
  })
  return this;
};
//
/////////////////////


jQuery(document).ready( function() {
  jQuery('.date_picker').AnyTime_picker( { format: "%m / %d / %z", firstDOW: 1 } );
});