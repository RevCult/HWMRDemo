$j = jQuery.noConflict();
$j( ".datepicker" ).removeAttr("onfocus");
$j(function() {
	$j( ".datepicker" ).datepicker({
	changeMonth: true,
	changeYear: true,
	showButtonPanel: true
	});

});

$j( document ).tooltip({
      position: {
        //my: "center bottom",
        //at: "center top",
        my: "left top-10",
        at: "right",
        using: function( position, feedback ) {
          $j( this ).css( position );
          $j( this ).css( 'min-height', '20px' );
          $j( this ).css( 'font-size', '10px' );
          $j( this ).css( 'margin', '0px' );
          $j( this ).css( 'padding', '0px' );
          $j( "<div>" )
            .addClass( "arrow" )
            .addClass( feedback.vertical )
            .addClass( feedback.horizontal )
            .appendTo( this );
        }
      }
    });

$j(function() {
    $j('#dialog').dialog( {
        autoOpen: false,
        modal: true,
        width: 650,
        height: 500
    });
    
    $j('#dialog2').dialog( {
        autoOpen: false,
        modal: true,
        width: 650,
        height: 500
    });

    $j( "[id$=log-a-call]" ).on( "click", function() {
        $j("#dialog").dialog( "open" );
    });

    $j( "[id$=log-a-call2]" ).on( "click", function() {
        $j("#dialog2").dialog( "open" );
    });
});


$j(function() {
    $j( ".button" )
      .button()
      .click(function( event ) {
        event.preventDefault();
      });
  });

var builderObjects;
var queryTerm;
var activeName;
$j('[id$=builderTextBox]').autocomplete({
    minLength: 2,
    source: function(request, response) {
                queryTerm = request.term;
                BuilderProjectMgmtAutocompleteExt.searchBuilders(request.term, function(result, event){
                    if(event.type == 'exception') {
                          alert(event.message);
                    } else {
                         builderObjects = result;
                         response(builderObjects);
                    }
                });
           },
    focus: function( event, ui ) {
            activeName = ui.item.Name;
            activeName = activeName.replace('amp;','');
            
            $j('[id$=builderTextBox]').val( activeName );
            return false;
            },
    select: function( event, ui ) {
                $j('[id$=builderTextBox]').val( activeName );
                $j('[id$=selectedBuilder]').val( ui.item.Id );
                return false;
            },
 })
 .data( "ui-autocomplete" )._renderItem = function( ul, item ) {
    var entry = "<a>" + item.Name;
   
    entry = entry + "</a>";
    entry = entry.replace(queryTerm, "<b>" + queryTerm + "</b>");
    return $j( "<li></li>" )
        .data( "item.ui-autocomplete", item )
        .append( entry )
        .appendTo( ul );
};
