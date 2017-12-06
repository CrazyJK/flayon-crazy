/**
 * https://github.com/jongha/jquery-jsontotable
 */
(function($) {
	
	$.fn.jsontotable = function(data, options) {
		
		var opts = $.extend({}, {
			header: true,
			className: null,
			dateColumn: [],
			hideColumn: [],
		}, options);

		var clone = function(obj) {
			if (obj == null || typeof(obj) !== "object")
				return obj;
			var temp = obj.constructor();
			for (var key in obj)
				if (obj.hasOwnProperty(key))
					temp[key] = clone(obj[key]);
			return temp;
		};
		
		var appendTr = function($table, rowData, isHeader) {
			var rowTag = isHeader ? "th" : "td";
			var row = $("<tr>");

			for (var key in rowData) {
				if (opts.hideColumn.includes(key)) {
					continue;
				}
	  
				var cellValue = rowData[key];
				if (typeof cellValue !== "function") {
					if (cellValue == null) {
						cellValue = "";
					}
					if (!isHeader) {
						if (opts.dateColumn.includes(key)) {
							cellValue = new Date(cellValue).format('yyyy.MM.dd HH:mm:ss');
						}
					}
					row.append("<" + rowTag + ">" + cellValue + "</" + rowTag + ">");
				}
			}

			if (isHeader) {
				$table.append($("<thead>").append(row));
			} 
			else {
				var tbody = $table.find("tbody");
				if (tbody.length == 0) {
					tbody = $table.append("<tbody>");
				}
				tbody.append(row);
			}
		};

		return this.each(function() {
			var obj = data;
			if (typeof obj === "string") {
				obj = $.parseJSON(obj);
			}

			if (obj.length) {
				var $table = $("<table>");
				opts.className && $table.addClass(opts.className);

				// for header show
				if (opts.header) {
					var headerObj = clone(obj[0]);
					if (headerObj.toString() === "[object Object]") { // data type is dictonary
						for (var key in headerObj) { 
							headerObj[key] = key; 
						}
					}
					appendTr($table, headerObj, true);
				}

				// for data
				for (var i = 0; i < obj.length; i++) { 
					appendTr($table, obj[i], false);
				}
				
				$(this).append($table);
			}
		});

	};
	
}(jQuery));