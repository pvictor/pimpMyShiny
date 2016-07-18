

// switch input binding
var switchInputBinding = new Shiny.InputBinding();
$.extend(switchInputBinding, {
  find: function(scope) {
    return $(scope).find('.switchInput');
  },
  getId: function(el) {
    return el.id;
  },
  getValue: function(el) {
    return el.checked;
  },
  setValue: function(el, value) {
    el.checked = value;
  },
  subscribe: function(el, callback) {
    $(el).on('switchChange.bootstrapSwitch', function(event) {
      callback(false);
    });
  },
  unsubscribe: function(el) {
    $(el).off('.switchInputBinding');
  },
  getState: function(el) {
    return {
      //label: $(el).parent().find('span').text(),
      value: el.checked
    };
  },
  receiveMessage: function(el, data) {
    
    if (data.hasOwnProperty('value'))
      el.checked = data.value;
      
    //if (data.hasOwnProperty('label'))
    //  $(el).parent().find('label[for="' + $escape(el.id) + '"]').text(data.label);
    
    $(el).trigger('change');
   }
});

Shiny.inputBindings.register(switchInputBinding, 'shiny.switchInput');

