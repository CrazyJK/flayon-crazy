/**
 * https://github.com/jongha/jquery-jsontotable
 */
(function($) {
	
	$.fn.jsontotable = function(data, options) {
		
		var opts = $.extend({}, {
			header: true,
			dateColumn: [],
			hideColumn: [],
			createdRow: null
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
					row.append(
							$("<" + rowTag + ">").addClass(key).html(cellValue)
					);
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
			return row;
		};

		return this.each(function() {
			var obj = data;
			if (typeof obj === "string") {
				obj = $.parseJSON(obj);
			}

			var $table = $(this);
			
			if (obj.length) {
				// for header show
				if (opts.header) {
					var headerObj = clone(obj[0]);
					if (headerObj.toString() === "[object Object]") { // data type is dictonary
						for (var key in headerObj) { 
							headerObj[key] = capitalize(key);
						}
					}
					appendTr($table, headerObj, true);
				}

				// for data
				for (var i = 0; i < obj.length; i++) { 
					var row = appendTr($table, obj[i], false);

					if (opts.createdRow) 
						opts.createdRow(row, obj[i], i);
				}
			}
			else { // data empty
				$table.append("<tfoot><tr><th>No data</th></tr></tfoot>");
			}
			
		});

	};
	
}(jQuery));