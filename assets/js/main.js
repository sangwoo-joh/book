---
exclude_in_search: true
layout: null
---
(function($) {
    'use strict';
    $(function() {
        $('[data-toggle="tooltip"]').tooltip();
        $('[data-toggle="popover"]').popover();
        $('.popover-dismiss').popover({
            trigger: 'focus'
        })
    });

    function bottomPos(element) {
        return element.offset().top + element.outerHeight();
    }
    $(function() {
        var promo = $(".js-td-cover");
        if (!promo.length) {
            return
        }
        var promoOffset = bottomPos(promo);
        var navbarOffset = $('.js-navbar-scroll').offset().top;
        var threshold = Math.ceil($('.js-navbar-scroll').outerHeight());
        if ((promoOffset - navbarOffset) < threshold) {
            $('.js-navbar-scroll').addClass('navbar-bg-onscroll');
        }
        $(window).on('scroll', function() {
            var navtop = $('.js-navbar-scroll').offset().top - $(window).scrollTop();
            var promoOffset = bottomPos($('.js-td-cover'));
            var navbarOffset = $('.js-navbar-scroll').offset().top;
            if ((promoOffset - navbarOffset) < threshold) {
                $('.js-navbar-scroll').addClass('navbar-bg-onscroll');
            } else {
                $('.js-navbar-scroll').removeClass('navbar-bg-onscroll');
                $('.js-navbar-scroll').addClass('navbar-bg-onscroll--fade');
            }
        });
    });
}(jQuery));
(function($) {
    'use strict';
    var Search = {
        init: function() {
            $(document).ready(function() {
                $(document).on('keypress', '.td-search-input', function(e) {
                    if (e.keyCode !== 13) {
                        return
                    }
                    var query = $(this).val();
                    var searchPage = "{{ site.url }}{{ site.baseurl }}/search/?q=" + query;
                    document.location = searchPage;
                    return false;
                });
            });
        },
    };
    Search.init();
}(jQuery));

$(document).ready( () => {
    var tags = document.getElementsByTagName("button");
    for (let tag of tags) {
        updateTagCounts(tag.dataset.tag);
    }
    let currentTag = "";
    const queryTag = getQuery().tag;

    if (queryTag) {
        filterByTagName(queryTag);
    } else {
        clear();
    }

    $("button").on("click", (e) => {
        currentTag = e.target.dataset.tag;
        if (currentTag != "clear"){
            filterByTagName(currentTag);
        } else {
            clear();
        }
    });
});

function updateTagCounts(tagName) {
    if (tagName == "clear"){
        return;
    }
    var counter = 0;
    $('.post-wrapper').each((index, elt) => {
        if (elt.hasAttribute(`data-${tagName}`)) {
            counter += 1;
        }
    });

    var updated = $(`.btn[data-tag=${tagName}]`).text() + " (" + counter + ")";
    console.log(updated);
    $(`.btn[data-tag=${tagName}]`).html(updated);
}

function getQuery() {
    var params = {};
    window.location.search.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(str, key, value) {

        params[key] = value;
    });

    return params;
}

function filterByTagName(tagName) {
    var counter = 0;
    $('.hidden').removeClass('hidden');
    $('.post-wrapper').each((index, elt) => {
        if (!elt.hasAttribute(`data-${tagName}`)) {
            $(elt).addClass('hidden');
        } else {
            counter += 1;
        }
    });

    $(`.btn`).removeClass('selected');
    $(`.btn[data-tag=${tagName}]`).addClass('selected');
    $(".count").text(counter);
}

function clear() {
    $('.post-wrapper').addClass('hidden');
    $(`.btn`).removeClass('selected');
    $(`.btn[data-tag=clear]`).addClass('selected');
    $('.count').text("Tag unset");
}
