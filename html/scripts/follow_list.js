var originalRows = [];

// Immediately report script initialization when DOM is loaded
if (window.addEventListener) {
	window.addEventListener('load', function() {
		var table = document.getElementById('follow_table');
		if (table) {
			var tbody = table.getElementsByTagName('tbody').item(0);
			var allTrs = tbody.getElementsByTagName('tr');
			for (var i = 0; i < allTrs.length; i++) {
				originalRows.push(allTrs.item(i));
			}
		}
	}, false);
} else if (window.attachEvent) {
	window.attachEvent('onload', function() {
		var table = document.getElementById('follow_table');
		if (table) {
			var tbody = table.getElementsByTagName('tbody').item(0);
			var allTrs = tbody.getElementsByTagName('tr');
			for (var i = 0; i < allTrs.length; i++) {
				originalRows.push(allTrs.item(i));
			}
		}
	});
}

window.filterTable = function() {
	try {
		var input = document.getElementById('search_input');
		if (!input) return;
		var filter = input.value.toLowerCase();
		var allTrs = document.getElementsByTagName('tr');
		for (var i = 0; i < allTrs.length; i++) {
			var row = allTrs.item(i);
			if (row && row.className && row.className.indexOf('follow-row') > -1) {
				var text = row.innerText || row.textContent || "";
				if (text.toLowerCase().indexOf(filter) > -1) {
					row.style.display = "";
				} else {
					row.style.display = "none";
				}
			}
		}
	} catch(err) {
		// Fail silently
	}
};

window.sortTable = function(n) {
	try {
		var table = document.getElementById('follow_table');
		var tbody = table.getElementsByTagName('tbody').item(0);
		var headers = table.getElementsByTagName('th');

		// Initialize state if not set
		if (!window.sortState) {
			window.sortState = { col: -1, dir: 'none' };
		}

		var nextDir = 'asc';
		if (window.sortState.col === n) {
			if (window.sortState.dir === 'asc') {
				nextDir = 'desc';
			} else if (window.sortState.dir === 'desc') {
				nextDir = 'none';
			} else {
				nextDir = 'asc';
			}
		}

		// Reset all headers text (remove arrows)
		for (var i = 0; i < headers.length; i++) {
			var th = headers[i];
			th.innerHTML = th.innerHTML.replace(' ▲', '').replace(' ▼', '');
		}

		window.sortState.col = n;
		window.sortState.dir = nextDir;

		if (nextDir === 'none') {
			// Restore default/original order
			while (tbody.firstChild) {
				tbody.removeChild(tbody.firstChild);
			}
			for (var i = 0; i < originalRows.length; i++) {
				tbody.appendChild(originalRows[i]);
			}
			window.filterTable();
			return;
		}

		var allTrs = tbody.getElementsByTagName('tr');
		var rowsArray = [];
		for (var i = 0; i < allTrs.length; i++) {
			var row = allTrs[i];
			if (row && row.className && row.className.indexOf('follow-row') > -1) {
				rowsArray.push(row);
			}
		}

		rowsArray.sort(function(a, b) {
			var cellsA = a.getElementsByTagName('td');
			var cellsB = b.getElementsByTagName('td');
			var cellA = cellsA.item(n);
			var cellB = cellsB.item(n);
			var A = (cellA ? (cellA.innerText || cellA.textContent || "") : "").toUpperCase();
			var B = (cellB ? (cellB.innerText || cellB.textContent || "") : "").toUpperCase();

			if (A < B) return nextDir === 'asc' ? -1 : 1;
			if (A > B) return nextDir === 'asc' ? 1 : -1;
			return 0;
		});

		while (rowsArray.length > 0) {
			tbody.appendChild(rowsArray.shift());
		}

		var activeTh = headers[n];
		activeTh.innerHTML += (nextDir === 'asc') ? ' ▼' : ' ▲';

		window.filterTable();
	} catch(err) {
		// Fail silently
	}
};
