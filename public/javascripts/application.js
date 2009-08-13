// For the notices and timeouts hash
var noticeAndTimeout = new Hash();

/**
 * Global namespace for all our javascript.
 **/
var Insight = {
    /**
     * Hides all flashes on the screen after 10 seconds.
     **/
    hideFlashes: function() {
        var flashes = $$("div.flash");

        flashes.each(function(flash) {
            window.setTimeout(function() {
                new Effect.BlindUp(Insight.wrapInDiv(flash));
            }, 10000);
        });
    },

    /**
     * Wraps the given element in a div and returns the result.
     **/
    wrapInDiv: function(element) {
        var elt = Element.extend(element);
        var div = document.createElement('div');
        elt.insert({ before: div });
        div.appendChild(elt);
        return div;
    },
    
    /**
     * Focuses the first element of the first form on the page, if one exists.
     **/
    focusFirstFormElement: function() {
        var form = $('content').down('form');
        if (form && form.findFirstElement()) form.focusFirstElement();
    },
    
    /**
     * Delay fade an individual id/element.  Reset the timer if needed
     **/
    delayFade: function(noticeId, delay) {
        var timeout = noticeAndTimeout.get(noticeId);
            
        if (timeout) {
            window.clearTimeout(timeout);
        }
        
        var timeoutDelay = (delay) ? delay : 10;
        
        timeout = window.setTimeout(function() {
            new Effect.Fade(noticeId, { duration: 0.5 });
        }, timeoutDelay * 1000);
        
        noticeAndTimeout.set(noticeId, timeout);
    },

    /**
     * Parses the given string into HTML and returns the result.
     *
     * If the string contains a single parent element, the it will be returned,
     * otherwise an array of elements will be returned.
     **/
    parseHTML: function(text) {
        return (text) ? new Element('div').update(text).childElements() : Array();
    }
}

/**
 * Periodical requester that performs updates every so often
 **/
Insight.PeriodicalRequester = Class.create(Ajax.Base, {
    initialize: function($super, url, options) {
        options.method = (options.method || 'get');
        $super(options);

        var oldOnComplete = this.options.onComplete;
        if (oldOnComplete == null) {
            this.onComplete = this.requestComplete;
        } else {
            this.onComplete = function(response) {
                oldOnComplete(response);
                this.requestComplete(response);
            }.bind(this);
        }

        this.frequency = (this.options.frequency || 5);
        this.decay = (this.options.decay || 1);
        this.maxDelay = (this.options.maxDelay || 300);
        this.allowCaching = (this.options.allowCaching || false);

        this.requester = { };
        this.url = url;

        this.start();
    },

    start: function() {
        this.options.onComplete = this.onComplete.bind(this);
        this.onTimerEvent();
    },

    stop: function() {
        this.requester.options.onComplete = undefined;
        clearTimeout(this.timer);
    },

    requestComplete: function(response) {
        if (this.options.decay) {
            this.decay = (response.responseText == this.lastText ?
                this.decay * this.options.decay : 1);

            this.lastText = response.responseText;
        }
        this.timer = this.onTimerEvent.bind(this).delay(
            Math.min(this.decay * this.frequency, this.maxDelay)
        );
    },

    onTimerEvent: function() {
        if (!this.allowCaching && (this.options.method == 'get')) this.preventCaching();
        this.requester = new Ajax.Request(this.url, this.options);
    },

    /**
     * Prevents the request from being cached by the browser by appending a
     * meaningless query parameter with an ever increasing value to the url
     * before the request is made.
     **/
    preventCaching: function() {
        if (this.options.parameters) {
            if (Object.isString(this.options.parameters)) {
                this.options.parameters = this.options.parameters.toQueryParams();
            }
            this.options.parameters._random = (new Date()).getTime();
        } else {
            this.options.parameters = { _random: (new Date()).getTime() };
        }
    }
});

Insight.Updater = Class.create({
    /**
     * Set up the updater callback and options, then start the requester.
     **/
    initialize: function(container, url, options) {
        this.container = $(container);

        options = (options || {});
        options.onComplete = this.updateContent.bind(this);
        
        new Insight.PeriodicalRequester(url, options);
    },
    
    /**
     * Update the content of the container with the response.
     **/
    updateContent: function(response) {
        var content = response.responseJSON.content;
        if (content && !content.strip().empty()) this.container.update(content);
    }
});


/**
 * TabMenu
 *
 * Adds tabbed menu behavior to a tabs div and accompanying content divs.
 *
 * The tabs div should have a class of 'tabs' and should contain a UL who's
 * LI elements contain links which represent the tabs.
 *
 * Each link's href should be an anchor reference to the div that should be
 * displayed when the tab is activated.
 *
 * For example, if you had a div with id of "foo" then there should be a link
 * in the UL with an href="#foo", when that link is clicked the "foo" div will
 * appear.
 **/
Insight.TabMenu = Class.create({
    currentClass: "current",
    list: null,
    currentTab: null,

    /**
     * Creates a new TabMenu for the list inside the container indicated by
     * tabsId.
     **/
    initialize: function(tabsId) {
        this.container = $(tabsId);
        this.list = this.container.down('ul');
        this.tabs = this.list.select('a');

        var este = this;
        this.tabs.each(function(tab) {
            tab.observe('click', este.handleClick.bindAsEventListener(este));
            if (tab.hasClassName(este.currentClass)) este.currentTab = tab;
        });
    },

    /**
     * Activates the current tab, changing it's class to that of currentClass
     * and showing it's div while at the same time deactivating all other tabs
     * and hiding other divs.
     **/
    activateTab: function(tab) {
        this.currentTab.removeClassName(this.currentClass);
        this.toggleDivForTab(this.currentTab);

        tab.addClassName(this.currentClass);
        this.toggleDivForTab(tab);

        this.currentTab = tab;
    },

    /**
     * Returns the div referenced by the given tab.
     **/
    divForTab: function(tab) {
        var id = tab.href.substr(tab.href.indexOf('#') + 1);
        return $(id);
    },

    /**
     * Given a tab, "toggles" the visibility of it's cooresponding div.  If the
     * div is visible it will be hidden and vice-versa.
     **/
    toggleDivForTab: function(tab) {
        var div = this.divForTab(tab)
        new Effect.toggle(div, 'appear', { duration: 0.20, queue: 'end' });
    },

    /**
     * Event handler to activate/deactivate tabs when they are clicked.
     **/
    handleClick: function(e) {
        var tab = e.element();
        if (this.currentTab != tab) this.activateTab(tab);
        e.stop();
    }
});


document.observe("dom:loaded", Insight.hideFlashes);
