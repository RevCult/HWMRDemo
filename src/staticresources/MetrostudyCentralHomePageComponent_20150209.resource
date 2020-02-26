/*Determine what type of object is currently being displayed on the page. Only confident way to do this is get object prefix */
var objectPrefix = window.location.href.substring( window.location.href.indexOf('.com/') + 5, window.location.href.indexOf('.com/') + 8 );

var j$ = jQuery.noConflict();

j$(function() {

	var isAdministrator = false;
    var linkProvisionContact;
	var linkProvisionContacts;

	switch (SFDCSessionVars.uid) {
		case '00580000005WtMX':		// mpiehota
		case '00580000004SDRU':		// MB
		case '00580000001o89W':		// DH
		case '00580000005glQ2':		// atayl
		case '00580000007Albc': 	// PP
		case '00580000007zv2J': 	// dnyirenda
			isAdministrator = true;
			break;	
	}					
	
    j$('div.linksModule').find('.brandPrimaryFgr').each(function(i) {
        if (j$(this).text() == 'Metrostudy Central') {

			if (isAdministrator) {
				j$(this).closest('div.linksModule').show();
			}
            else {
				j$(this).closest('div.linksModule').hide();
            }
        }
    });

	switch (objectPrefix) {
		case '001':  // Account
			break;
			
		case '003':  // Contact
			
			/*
			if (!isAdministrator) {
				// hide password
				j$('#00N80000005Aprs_ilecell').hide();			
				j$('#00N80000005Aprs_ilecell').unbind('click');
				j$('#00N80000005Aprs_ilecell').unbind('dblclick');		
				
				j$('#00N80000005Aprs_ileinner').hide();
				j$('#00N80000005Aprs_ileinner').unbind('click');
				j$('#00N80000005Aprs_ileinner').empty();
				
				j$('#00N80000005Aprs_ilecell').prev().hide();
			}
			*/
			
			break;
	}

});
