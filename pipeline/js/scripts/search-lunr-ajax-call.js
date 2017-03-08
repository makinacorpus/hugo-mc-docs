//I will try and add more comments to this later...
/*Begin full-screen search overlay toggle*/
//Note that this requires the element.classList method, which is not supported in IE9. If you need IE9 support, use the classList.js polyfill (https://github.com/eligrey/classList.js/)
//Full-screen overlay opens via click/touch event or if the user hits "s' on the keyboard. When search is open, this is controlled for so that people can search words with "s" in them
var searchOverlay = document.querySelector('.search-form');
var searchButton = document.getElementById('search-button');
var searchInput = document.getElementById('search-input');
var closeSearch = document.getElementById('close-search');
closeSearch.onclick = function() {
    if (searchOverlay.classList.contains('open')) {
        searchOverlay.classList.remove('open');
    }
}
window.addEventListener('keyup', function(event) {
    var keyPressed = event.keyCode;
    if (keyPressed === 83 && searchOverlay.classList.contains('open')) {
        return;
    } else if (keyPressed === 83) {
        searchOverlay.classList.add('open');
        if (searchInput.value.length > 0) {
            searchInput.value = '';
        }
        searchInput.focus();
    } else if (keyPressed === 27 && searchOverlay.classList.contains('open')) {
        searchOverlay.classList.remove('open');
    }
}, true);
searchButton.addEventListener('click', function(event) {
    searchOverlay.classList.toggle('open');
    searchInput.focus();
}, true);
/*End search overlay toggle*/

/*Begin Lunr live search*/
//for more information on lunr.js, go to http://lunrjs.com/
var searchData;
var searchInput = document.getElementById('search-input');
searchInput.addEventListener('keyup', lunrSearch, true);
window.index = lunr(function() {
    this.field('id');
    this.field('url');
    this.field('title', { boost: 50 });
    this.field('subtitle');
    this.field('description');
    this.field('tags',{ boost: 30});
    this.field('content', { boost: 10 });
//boosting for relevancy is up to you.
});

var searchReq = new XMLHttpRequest();
searchReq.open('GET', '/site-index.json', true);
searchReq.onload = function() {
    if (this.status >= 200 && this.status < 400) {
        console.log("Got the site index");
        searchData = JSON.parse(this.response);
        searchData.forEach(function(obj, index) {
            obj['id'] = index;
            window.index.add(obj);
        });
    } else {
        console.log("Failed status for site-index.js. Check /static/site-index.json");
    }
}
searchReq.onerror = function() {
    console.log("Error when attempting to load site-index.json.");
}
searchReq.send();

function lunrSearch(event) {
    var query = document.querySelector("#search-input").value;
    var searchResults = document.querySelector('#search-results');
    if (query.length === 0) {
        searchResults.innerHTML = '';
    }
    if ((event.keyCode !== 9) && (query.length > 2)) {
        var matches = window.index.search(query);
        displayResults(matches);
    }
}

function displayResults(results) {
    var searchResults = document.querySelector('#search-results');
    var inputVal = document.querySelector('#search-input').value;
    if (results.length) {
        searchResults.innerHTML = '';
        results.forEach(function(result) {
            var item = window.searchData[result.ref];
            var section = item.section.split('-').map(s => s.charAt(0).toUpperCase() + s.slice(1)).join(' ');
            var appendString = '<li class=\"search-result\"><a href=\"' + item.url + '\"><h5>' + item.title + '</h5></a><p>' + item.description + '</p><div class=\"in-section\">In: ' + section + '</div><ul class=\"tags\"><li><i class=\"icon-tags\"></i></li>';
            // var tags = '';
            for (var i = 0; i < item.tags.length; i++) {
                appendString += '<li><a href=\"/tags/' + item.tags[i] + '\" class=\"tag\">' + item.tags[i] + '</a> ';
            }
            appendString += '</ul></li>';
            searchResults.innerHTML += appendString;
        })
    } else {
        searchResults.innerHTML = '<li class=\"search-result none\">No results found for <span class=\"input-value\">' + inputVal + '</span>.<br/>Please check spelling and spacing.</li>';
    }
}
