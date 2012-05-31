%# RT::Extension::ReferenceIDoitObjects
%#
%# Copyright 2011-12 synetics GmbH, http://i-doit.org/
%#
%# This program is free software; you can redistribute it and/or modify it under
%# the same terms as Perl itself.
%#
%# Request Tracker (RT) is Copyright Best Practical Solutions, LLC.

(function($) {

    browser_preselection_field = $(browser_preselection_field);
	browser_mandator_field = $(browser_mandator_field);
	initialized = false;

	datatable_lang = {
		"sProcessing":   "<% loc('Loading...') %>",
		"sLengthMenu":   "<% loc('Show _MENU_ objects') %>",
		"sZeroRecords":  "<% loc('No objects has been selected yet.') %>",
		"sInfo":         "<% loc('_START_ to _END_ of _TOTAL_ objects') %>",
		"sInfoEmpty":    "<% loc('0 to 0 of 0 objects') %>",
		"sInfoFiltered": "<% loc('(filtered from _MAX_ objects)') %>",
		"sInfoPostFix":  "",
		"sSearch":       "<% loc('Filter') %>",
		"sUrl":          "",
		"oPaginate": {
			"sFirst":    "&laquo;",
			"sPrevious": "&lsaquo;",
			"sNext":     "&rsaquo;",
			"sLast":     "&raquo;"
		}
	};

    // Initialize the data table.
    var objectview_table = $('#i-doit-objectbrowser #tab-objectview table.object-table').dataTable({
			"bJQueryUI": true,
			"bAutoWidth": false,
			"bLengthChange": false,
			"iDisplayLength": 20,
			"sPaginationType": "full_numbers",
			"oLanguage": datatable_lang
		}),
		itemview_table = $('#i-doit-objectbrowser #tab-itemview table.object-table').dataTable({
			"bJQueryUI": true,
			"bAutoWidth": false,
			"bPaginate": false,
			"bLengthChange": false,
			"bSort": false,
			"oLanguage": datatable_lang
		});


    /**
     * This event will initialize the browser.
     *
     * @author  Leonard Fischer <lfischer@synetics.de>
     */
    window.init_browser = function() {
        window.error_notice('<% loc("Loading...") %>');

		// Here we get our preselection data and cast the ID's to integer.
		var data = {};

		data = {
			"method":"cmdb.object_types",
			"params":{
				"session":{
					"username":api_user,
					"password":api_password,
					"language":api_lang,
					"mandator":api_mandator
                },
                "order_by":"title",
                "filter":{
                    "enabled":"true"
                }
            },
			"id":"1",
			"jsonrpc":"2.0"
        };

		idoit_ajax(data, function(response) {
			if (response != null && response.error == null) {
				initialized = true;
				
				// We look if the preselection field is filled.
				window.load_preselection_data();

				// Here we load the requestor data (workplaces and assigned objects).
				window.load_requestor_data();
				
				$('#i-doit-browser-notice').css({display: 'none'});
				$('#i-doit-objectbrowser-content').css({display: 'block'});
				
				$('#i-doit-objectbrowser select.object-type').html('');
				$.each(response.result, function(i, e) {
					$('<option value="' + e.id + '">' + e.title + '</option>').appendTo('#i-doit-objectbrowser select.object-type');
				});

				// Trigger the event.
				$('#i-doit-objectbrowser select.object-type').change();
			} else {
				initialized = false;
				window.error_notice('<% loc("Error while loading object types") %>');
			}
		}, true);
    };


    /**
     * Callback function for selecting an object-type.
     *
     * @author  Leonard Fischer <lfischer@synetics.de>
     */
    $('#i-doit-objectbrowser select.object-type').change(function() {
		window.display_loading();
        var data = {
            "method":"cmdb.objects",
            "params":{
                "session":{
                    "username":api_user,
                    "password":api_password,
                    "language":api_lang,
                    "mandator":api_mandator},
                "filter":{
                    "type":parseInt(this.value)},
                "order_by":"title"},
            "id":"1",
            "jsonrpc":"2.0"};

        idoit_ajax(data, function(response) {
            if (response.error == null) {
				window.remove_loading();
                // Clear the table from our old entries.
                current_objectview_data = response.result;
                window.render_objectview();
            } else {
              window.error_notice('<% loc("Error while loading objects by object type") %>');
            }
        }, true);
    });


    /**
     * This event will store the added ID's from the object-view.
     *
     * @author  Leonard Fischer <lfischer@synetics.de>
     */
    $('input[name="i-doit-objectbrowser-obj[]"]').live('change', function() {
        if ($(this).attr('checked')) {
            var name = $(this).closest('tr').find('td:eq(2)').text(),
                type = $('#i-doit-objectbrowser select.object-type option:selected').text();

            window.add_object($(this).val(), name, type);
        } else {
            window.remove_object($(this).val());
        }
    });


    /**
     * This event will store the added ID's from the tree-view.
     *
     * @author  Leonard Fischer <lfischer@synetics.de>
     */
    $('input[name="i-doit-treebrowser-obj[]"]').live('change', function() {
        if ($(this).attr('checked')) {
            var name = $(this).next().text(),
                type = $(this).next().next().text();

            window.add_object($(this).val(), name, type);
        } else {
            window.remove_object($(this).val());
        }
    });


    /**
     * Function for loading the requestor - This can be used if a new requestor has been added to the "Requestor" field.
     *
     * @author  Leonard Fischer <lfischer@synetics.de>
     */
    $('#requestor-reload').click(function() {
        window.load_requestor_data();
    });


	/**
	 * Function for reloading the requestors - This will be fired when a new requestor is beeing added to the "Requestor" field.
	 *
	 * @author  Leonard Fischer <lfischer@synetics.de>
	 */
	$('#Requestors').live('change', function() {
		if (initialized) window.setTimeout(function() {window.load_requestor_data();}, 100);
	});


	/**
	 * Function for reloading the preselection - This will be fired when the preselection field is beeing changed.
	 *
	 * @author  Leonard Fischer <lfischer@synetics.de>
	 */
	browser_preselection_field.live('change', function() {
		if (initialized) window.load_preselection_data();
	});
	

    /**
     * Loads and displays the requestor-data (workplace, assigned objects, ...).
     *
     * @author  Leonard Fischer <lfischer@synetics.de>
     */
	window.load_requestor_data = function() {
		requestors = $('#Requestors').val();

		if (typeof requestors == 'string') {
			requestors = requestors.replace(/(\s)/g, '').split(',');
		}

		if (typeof requestors != 'undefined') {
			if (requestors.length > 0) {
				window.display_loading();
				data = {
					"method":"cmdb.workstation_components",
					"params":{
						"session":{
							"username":api_user,
							"password":api_password,
							"language":api_lang,
							"mandator":api_mandator},
						"filter":{
							"emails":requestors}},
					"id":"1",
					"jsonrpc":"2.0"};

				idoit_ajax(data, function(response) {
					// First we check for errors.
					window.remove_loading();

					if (response.error == null) {
						current_treeview_data = response.result;
						window.render_treeview();
					} else {
                      window.error_notice('<% loc("Error while loading objects by email") %>');
					}
                }, true);
			}
		}
	};


	/**
	 * Loads and displays the preselection-data.
	 *
	 * @author  Leonard Fischer <lfischer@synetics.de>
	 */
	window.load_preselection_data = function() {
		var preselection = browser_preselection_field.val();

		if (typeof preselection != 'undefined') {
			preselection = preselection.split("\n")

			if (preselection != '') {
				preselection = preselection.map(function(i) {
					return (!isNaN(parseInt(i)) ? parseInt(i) : 0);
				});

				if (preselection.length > 0) {
					window.display_loading();
					// We first request the preselected ID's so we can display them correctly inside the "selected objects" list (ID, Name, Type).
					data = {
						"method":"cmdb.objects",
						"params":{
							"session":{
								"username":api_user,
								"password":api_password,
								"language":api_lang,
								"mandator":api_mandator},
							"filter":{
								"ids":preselection}},
						"id":"1",
						"jsonrpc":"2.0"};

					idoit_ajax(data, function(response) {
                        window.remove_loading();
                        if (response.error == null) {
                            window.remove_all_objects();

                            $.each(response.result, function(i, e) {
                                window.add_object(e.id, e.title, e.type_title);
                            });
                        } else {
                            window.error_notice('<% loc("Error while loading pre-selecting objects") %>');
                        }
                    }, true);
				}
			}
        }
    };


	/**
	 * Event for initializing the object browser, when changing the mandator.
	 *
	 * @author  Leonard Fischer <lfischer@synetics.de>
	 */
	browser_mandator_field.live('change', function() {
		window.remove_all_objects();
        api_mandator = browser_mandator_field.val();
		window.init_browser();
	});


	/**
	 * This function is used to render the tree view. This is needed to update the selected ID's.
	 *
	 * @author  Leonard Fischer <lfischer@synetics.de>
	 */
    window.render_treeview = function() {
        $('#tab-treeview div').html('');

		if (current_treeview_data.length == 0) {
			$('#tab-treeview div').html('<% loc("Given requestor(s) could not be found in i-doit.") %>');
		}
		
		var workplaces = $('#tab-treeview div.workplaces');
		
        // We iterate through the first level (email-addresses).
        $.each(current_treeview_data, function(i, e) {
            workplaces.append('<a href="' + idoit_url + '?objID=' + i + '" target="_blank" style="font-weight:bold;">' + e.data.title + ' &lt;' + e.data.email + '&gt;</a><br />');

			if (e.children != false) {
				window.render_treeview_recursion(e.children, 1);
			}

            workplaces.append('<br />');
        });
    };


	/**
	 * This function is used to render the tree with it's recursions.
	 *
	 * @param   array    data  The data from the parents "children" array.
	 * @param   integer  level  With this variable, we can determine how "deep" inside recursion we are and display it with "level * 20px" margin.
	 * @author  Leonard Fischer <lfischer@synetics.de>
	 */
	window.render_treeview_recursion = function(data, level) {
		$.each(data, function(i, e) {
			var selected = false;
			if (typeof $('#data-store').data(i) != 'undefined') {
				selected = true;
			}

			var output = '<div><input type="checkbox" value="' + i + '" name="i-doit-treebrowser-obj[]" ' + ((selected) ? 'checked="checked"' : '') + ' style="margin-left:' + (level * 20) + 'px;"> ' +
                '<span class="obj-name"><a href="' + idoit_url + '?objID=' + i + '" target="_blank">' + e.data.title + '</a></span>' +
				' (<span class="obj-type">' + e.data.type_title + '</span>) &raquo; ' +
                '<span class="relation-button"><% loc("show installed software") %></span></div>';

			$('#tab-treeview div.workplaces').append(output);

			if (e.children != false) {
				window.render_treeview_recursion(e.children, (level + 1));
			}
		});
	};


	/**
	 * This event will call all the objects software-relations.
	 *
	 * @author  Leonard Fischer <lfischer@synetics.de>
	 */
	$('span.relation-button').live('click', function() {
		window.display_loading();

		id = $(this).prev().prev().prev().val();
		div = $(this).parent();
		span = parseInt($(this).prev().prev().prev().css('margin-left'));

		$(this).remove();

		data = {
			"method":"cmdb.objects_by_relation",
			"params":{
				"session":{
					"username":api_user,
					"password":api_password,
					"language":api_lang,
					"mandator":api_mandator},
				"id":id,
				"relation_type":"C__RELATION_TYPE__SOFTWARE"},
			"id":"1",
			"jsonrpc":"2.0"};

		idoit_ajax(data, function(response) {
            window.remove_loading();
            if (response.error == null) {
                $.each(response.result, function(i, e) {
                    var selected = false;

                    if (typeof $('#data-store').data(e.data.id) != 'undefined') {
                        selected = true;
                    }

                    div.append(
                        '<br /><input type="checkbox" style="margin-left:' +
                        (span + 20) +'px;" value="' + e.data.id +
                        '" name="i-doit-treebrowser-obj[]" ' +
                        ((selected) ? 'checked="checked"' : '') + '/> ' + 
                        '<span class="obj-name"><a href="' + idoit_url +
                        '?objID=' + e.data.id +
                        '" target="_blank" title="<% loc("Go to i-doit") %>">' +
                        e.data.related_title +
                        '</a></span> (<span class="obj-type">' +
                        e.data.related_type_title + '</span>)'
                    );
                });
            } else {
              window.error_notice('<% loc("Error while loading relation objects") %>');
            }
        }, true);
	});


    /**
     * Function for rendering the object-table.
     *
     * @author  Leonard Fischer <lfischer@synetics.de>
     */
    window.render_objectview = function() {
        var store = $('#data-store'),
            entities = [];
        objectview_table.fnClearTable();
        $.each(current_objectview_data, function(i, e) {
            var check,
                selected = false,
                link;

            if (typeof store.data(e.id) != 'undefined') {
                selected = true;
            }

            check = '<input type="checkbox" value="' + e.id + '" name="i-doit-objectbrowser-obj[]" ' + ((selected) ? 'checked="checked"' : '') + ' />';
            link = '<a href="' + idoit_url + '?objID=' + e.id + '" target="_blank" title="<% loc('Go to i-doit') %>">&raquo; i-doit</a>';

            entities.push([check, e.id, e.title, link]);
        });

        objectview_table.fnAddData(entities);
    };


    /**
     * Function for removing an item from the selected data.
     *
     * @param   integer  id  The object-id to remove from our selection.
     * @author  Leonard Fischer <lfischer@synetics.de>
     */
    window.remove_object = function(id) {
        $('#data-store').removeData(id);

        window.render_selected_items();

		// Instead of rendering the lists new, we can to something like this:
		$('input[name="i-doit-objectbrowser-obj[]"][value="' + id + '"]').attr('checked', false);
		$('input[name="i-doit-treebrowser-obj[]"][value="' + id + '"]').attr('checked', false);
	};


	/**
	 * Function for removing all items from the selected data.
	 *
	 * @author  Leonard Fischer <lfischer@synetics.de>
	 */
	window.remove_all_objects = function() {
		$('#data-store').removeData();

		window.render_selected_items();
        window.render_objectview();
        window.render_treeview();
    };


    /**
     * Function for removing an item from the selected data.
     *
     * @param   integer  id    The object-id.
     * @param   string   name  The object-title.
     * @param   integer  type  The object-type.
     * @author  Leonard Fischer <lfischer@synetics.de>
     */
    window.add_object = function(id, name, type) {
        $('#data-store').data(id, {"name": name, "type": type});

        window.render_selected_items();

			// Instead of rendering the tables new, we can to something like this:
			$('input[name="i-doit-objectbrowser-obj[]"][value="' + id + '"]').attr('checked', 'checked');
			$('input[name="i-doit-treebrowser-obj[]"][value="' + id + '"]').attr('checked', 'checked');
    };


    /**
     * Function for rendering the "selected objects" list. Will be used when adding or removing an object.
     *
     * @author  Leonard Fischer <lfischer@synetics.de>
     */
    window.render_selected_items = function() {
        var data_array = [],
            entities = [];

        itemview_table.fnClearTable();
        var data = $('#data-store').data();
        $.each(data, function(i, e) {
            var link = '<a href="' + idoit_url + '?objID=' + i + '" title="<% loc('Go to i-doit') %>">&raquo; i-doit</a>';

            entities.push(['<span class="i-doit-objectbrowser-remover" onclick="window.remove_object(' + i + ')"><% loc("Delete") %></span>', i, e.name, e.type, link]);
            data_array.push(i);
        });

        itemview_table.fnAddData(entities);

        browser_preselection_field.val(data_array.join("\n"));
    };


    /**
     * Logs added and/or removed objects.
     *
     * An AJAX request will be sent to i-doit to add a new logbook entry for new
     * selected objects or removed previous ones.
     *
     * @author Benjamin Heisig <bheisig@synetics.de>
     */
    window.log_changed_objects = function(edit) {
        var preselection = browser_preselection_field.val();

        if (typeof preselection != 'undefined') {
            preselection = preselection.split("\n")

            if (preselection != '') {
                preselection = preselection.map(function(i) {
                    return (!isNaN(parseInt(i)) ? parseInt(i) : 0);
                });

                if (preselection.length > 0) {
                    window.display_loading();

                    var subject = $('input[name="Subject"]').val();
                    var message;
                    var comment;

                    // Was ticket created or updated?
                    if (edit == true) {
                        message = '<% loc("Ticket was edited.") %>';
                        comment = $('input[name="id"]').val();
                    } else {
                        message = '<% loc("Ticket was created.") %>';
                        // comment is 'new'
                    }

                    data = {
                        "method":"cmdb.logbook.create",
                        "params":{
                            "session":{
                                "username":api_user,
                                "password":api_password,
                                "language":api_lang,
                                "mandator":api_mandator
                            },
                            "object_ids":preselection,
                            "message":message,
                            "source":'C__LOGBOOK_SOURCE__RT',
                            "comment":comment,
                            "description":subject
                        },
                        "id":1,
                        "jsonrpc":"2.0"
                    };

                    idoit_ajax(data, function(response) {
                        if (response.error != null) {
                            window.error_notice('<% loc("Error while creating i-doit logbook entry") %>');
                        }
                    }, false);
                }
            }
        }
    }


    /**
     * Function for sending requests to idoit.
     *
     * @param   json      data      A json-object with the data, you want to send with the request.
     * @param   function  callback  A callback to assign to the "success" of an request.
     * @author  Leonard Fischer <lfischer@synetics.de>
     */
    window.idoit_ajax = function(data, callback, async) {
        $.ajax({
            url: api_url,
            data: JSON.stringify(data),
            contentType: 'application/json',
            type: 'POST',
            dataType: 'json',
            success: callback,
            async: async
        });
    };


	/**
	 * You may implement an own method to display errors here.
	 *
	 * @param   string  msg  The error message.
	 * @author  Leonard Fischer <lfischer@synetics.de>
	 */
    window.error_notice = function(msg) {
		$('#i-doit-browser-notice').html(msg).fadeIn(500);
		$('#i-doit-objectbrowser-content').css({display: 'none'});
    }


	/**
	 * Function for displaying the "loading" screen.
	 *
	 * @author  Leonard Fischer <lfischer@synetics.de>
	 */
	window.display_loading = function() {
		$('#loading-screen').stop().fadeTo(0, 1);
		$('#i-doit-objectbrowser-content').stop().fadeTo(0, 0.3);
	}


	/**
	 * Function for removing the "loading" screen.
	 *
	 * @author  Leonard Fischer <lfischer@synetics.de>
	 */
	window.remove_loading = function() {
		$('#loading-screen').stop().fadeTo(300, 0);
		$('#i-doit-objectbrowser-content').stop().fadeTo(300, 1);
	}

})(jQuery);
