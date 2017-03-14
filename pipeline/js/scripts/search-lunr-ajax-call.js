// I will try and add more comments to this later...
/* Begin full-screen search overlay toggle*/
// Note that this requires the element.classList method,
// which is not supported in IE9. If you need IE9 support,
// use the classList.js polyfill (https://github.com/eligrey/classList.js/)
// Full-screen overlay opens via click/touch event or if the user hits "s' on the keyboard. When search is open, this is controlled for so that people can search words with "s" in them
var searchIndex          = document.getElementById('search-index');
var searchOverlay        = document.getElementById('search-form');
var searchButton         = document.getElementById('search-button');
var searchInput          = document.getElementById('search-input');
var searchResultsWrapper = document.getElementById('search-results-wrapper');
var searchResults        = document.getElementById('search-results');
var searchResultsCount   = document.getElementById('search-results-count');
try { var lunrjson_url = searchIndex.value; }
catch(e) {  }
if (!lunrjson_url) {
    console.log("Search url not found in body!");
    var lunrjson_url = "/site-index.json";
}

function resetdocsearchinputs(close) {
    if(close===null) close=true;
    searchInput.value = '';
    searchResults.innerHTML = '';
    searchResultsCount.innerHTML = '';
    if (close) {
        searchResultsWrapper.classList.remove('open');
    }
}

window.addEventListener('keyup', function(event) {
    var keyPressed = event.keyCode;
    if (keyPressed === 83 && searchOverlay.classList.contains('open')) {
        return;
    } else if (keyPressed === 83) {
        searchOverlay.classList.add('open');
        searchOverlay.classList.add('open');
        if (searchInput.value.length > 0) { resetdocsearchinputs(close=true); }
        searchInput.focus();
    } else if (keyPressed === 27 && searchOverlay.classList.contains('open')) {
        resetdocsearchinputs(close=true);
        searchOverlay.classList.remove('open');
        searchInput.classList.remove('open');
    }
}, true);

function activatesearch(event) {
    resetdocsearchinputs(close=true);
    searchOverlay.classList.add('open');
    searchInput.classList.add('open');
    searchInput.focus();
}

searchButton.addEventListener('click', activatesearch, true);
searchInput.addEventListener('click', activatesearch, true);
/*End search overlay toggle*/

/*Begin Lunr live search*/
//for more information on lunr.js, go to http://lunrjs.com/
var searchData;
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
searchReq.open('GET', lunrjson_url, true);
searchReq.onload = function() {
    if (this.status >= 200 && this.status < 400) {
        console.log("Got the site index");
        searchData = JSON.parse(this.response);
        searchData.forEach(function(obj, index) {
            obj['id'] = index;
            window.index.add(obj);
        });
    } else {
        console.log("Failed status for site-index.js. Check "+lunrjson_url);
    }
}
searchReq.onerror = function() {
    console.log("Error when attempting to load " + lunrjson_url);
}
searchReq.send();

function lunrSearch(event) {
    var query = document.querySelector("#search-input").value;
    if (query.length === 0) {
        resetdocsearchinputs(close=false);
    }
    if ((event.keyCode !== 9) && (query.length > 2)) {
        var matches = window.index.search(query);
        displayResults(matches);
    }
}

function displayResults(results) {
    var results2 = [];
    results.forEach(function(result) {
        var item = window.searchData[result.ref];
        if(item.url && !item.url.match(/^\/tags\//)) {
            results2.push(result);
        }
    });
    searchResultsWrapper.classList.add('open');
    searchResultsCount.innerHTML = results2.length + ' search results';
    var inputVal = searchInput.value;
    if (results2.length) {
        var appendString = '';
        results.forEach(function(result) {
            appendString += '<li class=\"search-result\">';
            var item = window.searchData[result.ref];
            var section = item.section.split('-').map(
                s => s.charAt(0).toUpperCase() + s.slice(1)
            ).join(' ');
            appendString += '<h5><a href=\"' + item.url + '\">' + item.title;
            if (section.length) {
                appendString += '<div class=\"in-section\">In: '+section+'</div>';
            }
            appendString += '</a>';
            appendString += '</h5>';
            appendString += '<p>' + item.description + '</p>';
            if(item.tags.length) {
                appendString += '<ul class=\"tags\">';
                for (var i = 0; i < item.tags.length; i++) {
                    appendString += '<li><a href=\"/tags/' + item.tags[i] + '\" class=\"tag\">' + item.tags[i] + '</a> ';
                }
                appendString += '</ul>'
            }
            appendString += '<div class="tagsspacer"/></li>';
        })
        searchResults.innerHTML = appendString;
    } else {
        searchResults.innerHTML = '<li class=\"search-result none\">No results found for <span class=\"input-value\">' + inputVal + '</span>.<br/>Please check spelling and spacing.</li>';
    }
}
