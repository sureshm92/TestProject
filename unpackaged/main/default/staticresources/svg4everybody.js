! function(a, b) {
    "function" == typeof define && define.amd ? define([], function() {
        return a.svg4everybody = b()
    }) : "object" == typeof module && module.exports ? module.exports = b() : a.svg4everybody = b()
}(this, function() {
    function a(a, b, c) {
        if (c) {
            var d = document.createDocumentFragment(),
                e = !b.hasAttribute("viewBox") && c.getAttribute("viewBox");
            e && b.setAttribute("viewBox", e);
            for (var f = c.cloneNode(!0); f.childNodes.length;) d.appendChild(f.firstChild);
            a.appendChild(d)
        }
    }

    function b(b) {
        b.onreadystatechange = function() {
            if (4 === b.readyState) {
                var c = b._cachedDocument;
                c || (c = b._cachedDocument = document.implementation.createHTMLDocument(""), c.body.innerHTML = b.responseText, b._cachedTarget = {}), b._embeds.splice(0).map(function(d) {
                    var e = b._cachedTarget[d.id];
                    e || (e = b._cachedTarget[d.id] = c.getElementById(d.id)), a(d.parent, d.svg, e)
                })
            }
        }, b.onreadystatechange()
    }

    function c(c) {
        function e() {
            for (var c = 0; c < o.length;) {
                var h = o[c],
                    i = h.parentNode,
                    j = d(i),
                    k = h.getAttribute("xlink:href") || h.getAttribute("href");
                if (!k && g.attributeName && (k = h.getAttribute(g.attributeName)), j && k) {
                    if (f)
                        if (!g.validate || g.validate(k, j, h)) {
                            i.removeChild(h);
                            var l = k.split("#"),
                                q = l.shift(),
                                r = l.join("#");
                            if (q.length) {
                                var s = m[q];
                                s || (s = m[q] = new XMLHttpRequest, s.open("GET", q), s.send(), s._embeds = []), s._embeds.push({
                                    parent: i,
                                    svg: j,
                                    id: r
                                }), b(s)
                            } else a(i, j, document.getElementById(r))
                        } else ++c, ++p
                } else ++c
            }(!o.length || o.length - p > 0) && n(e, 67)
        }
        var f, g = Object(c),
            h = /\bTrident\/[567]\b|\bMSIE (?:9|10)\.0\b/,
            i = /\bAppleWebKit\/(\d+)\b/,
            j = /\bEdge\/12\.(\d+)\b/,
            k = /\bEdge\/.(\d+)\b/,
            l = window.top !== window.self;
        f = "polyfill" in g ? g.polyfill : h.test(navigator.userAgent) || (navigator.userAgent.match(j) || [])[1] < 10547 || (navigator.userAgent.match(i) || [])[1] < 537 || k.test(navigator.userAgent) && l;
        var m = {},
            n = window.requestAnimationFrame || setTimeout,
            o = document.getElementsByTagName("use"),
            p = 0;
        f && e()
    }

    function d(a) {
        for (var b = a; b && b.nodeName && "svg" !== b.nodeName.toLowerCase() && (b = b.parentNode););
        return b
    }
    return c
});
/*
!function (a, b) {
    "function" == typeof define && define.amd ? define([], function () {
        return a.svg4everybody = b()
    }) : "object" == typeof exports ? module.exports = b() : a.svg4everybody = b()
}(this, function () {
    function a(a, b) {
        if (b) {
            var c = !a.getAttribute("viewBox") && b.getAttribute("viewBox"), d = document.createDocumentFragment(),
                e = b.cloneNode(!0);
            for (c && a.setAttribute("viewBox", c); e.childNodes.length;) d.appendChild(e.firstChild);
            a.appendChild(d)
        }
    }

    function b(b) {
        b.onreadystatechange = function () {
            if (4 === b.readyState) {
                var c = document.createElement("x");
                c.innerHTML = b.responseText, b.s.splice(0).map(function (b) {
                    a(b[0], c.querySelector("#" + b[1].replace(/(\W)/g, "\\$1")))
                })
            }
        }, b.onreadystatechange()
    }

    function c(c) {
        function d() {
            for (var c; c = e[0];) {
                var j = c.parentNode;
                if (j && /svg/i.test(j.nodeName)) {
                    var k = c.getAttribute("xlink:href");
                    if (f && (!g || g(k, j, c))) {
                        var l = k.split("#"), m = l[0], n = l[1];
                        if (j.removeChild(c), m.length) {
                            var o = i[m] = i[m] || new XMLHttpRequest;
                            o.s || (o.s = [], o.open("GET", m), o.send()), o.s.push([j, n]), b(o)
                        } else a(j, document.getElementById(n))
                    }
                }
            }
            h(d, 17)
        }

        c = c || {};
        var e = document.getElementsByTagName("use"),
            f = "shim" in c ? c.shim : /\bEdge\/12\b|\bTrident\/[567]\b|\bVersion\/7.0 Safari\b/.test(navigator.userAgent) || (navigator.userAgent.match(/AppleWebKit\/(\d+)/) || [])[1] < 537,
            g = c.validate, h = window.requestAnimationFrame || setTimeout, i = {};
        f && d()
    }

    return c
});
*/