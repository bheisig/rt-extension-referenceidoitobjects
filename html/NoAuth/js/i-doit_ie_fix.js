%# RT::Extension::ReferenceIDoitObjects
%#
%# Copyright 2011-12 synetics GmbH, http://i-doit.org/
%#
%# This program is free software; you can redistribute it and/or modify it under
%# the same terms as Perl itself.
%#
%# Request Tracker (RT) is Copyright Best Practical Solutions, LLC.

/**
 * JSON object is missing in IE <= 8.
 */
var JSON = JSON || {};

/**
 * Implements JSON.stringify serialization.
 */
JSON.stringify = JSON.stringify || function(obj) {
    var t = typeof (obj);
    if (t != "object" || obj === null) {
        // simple data type
        if (t == "string")
            obj = '"' + obj + '"';
        return String(obj);
    } else {
        // recurse array or object
        var n, v, json = [], arr = (obj && obj.constructor == Array);
        for (n in obj) {
            v = obj[n];
            t = typeof (v);
            if (t == "string")
                v = '"' + v + '"';
            else if (t == "object" && v !== null)
                v = JSON.stringify(v);
            json.push((arr ? "" : '"' + n + '":') + String(v));
        }
        return (arr ? "[" : "{") + String(json) + (arr ? "]" : "}");
    }
};
