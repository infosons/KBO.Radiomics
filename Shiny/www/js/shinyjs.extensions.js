var infosons = infosons || {};

infosons.getTab = function(id,tab) {
  var el=$('#'+id);
  return el.find('li a[data-value="' +tab + '"]');
}

shinyjs.showLoading =function() {
  $("#loading-spinner").css("z-index",1000)
}

shinyjs.hideLoading =function() {
  $("#loading-spinner").css("z-index",-1)
}

shinyjs.hideTab = function(params) {
  var defaultParams = {
    id : null,
    tab : ""  
  };
  params = shinyjs.getParams(params, defaultParams);
  infosons.getTab(params.id,params.tab).parent().css("display","none")
}

shinyjs.showTab = function(params) {
  var defaultParams = {
    id : null,
    tab : ""  
  };
  params = shinyjs.getParams(params, defaultParams);
  infosons.getTab(params.id,params.tab).parent().css("display","")
}

shinyjs.hideTabOnClick = function(params) {
  var defaultParams = {
    id : null,
    tabClick : "",
    tabHide : ""
  };
  params = shinyjs.getParams(params, defaultParams);
  var tabToClick=infosons.getTab(params.id,params.tabClick);
  tabToClick.bind('click.tab',function(e) {
    shinyjs.hideTab({id:params.id,tab:params.tabHide})
    return true
  })
}

shinyjs.disableTab = function(params) {
  var defaultParams = {
    id : null,
    tab : ""  
    
  };
  params = shinyjs.getParams(params, defaultParams);
  var el=$('#'+params.id).find('li a[data-value="' +params.tab + '"]').parent();
  el.bind('click.tab', function(e) {
    e.preventDefault();
    return false;
  });
  el.addClass('disabled');
}

shinyjs.enableTab = function(params) {
  var defaultParams = {
    id : null,
    tab : ""  
    
  };
  params = shinyjs.getParams(params, defaultParams);
  var el=$('#'+params.id).find('li a[data-value="' +params.tab + '"]').parent();
  el.unbind('click.tab');
  el.removeClass('disabled');
}

shinyjs.disableTabs = function(params) {
  var defaultParams = {
    id : null,
    tab : ""  
    
  };
  params = shinyjs.getParams(params, defaultParams);
  var el=$('#'+params.id);
  el.find('li a[data-value="' +params.tab + '"]').click();
  var tabs = el.find('li:not(.active)');
  tabs.bind('click.tab', function(e) {
    e.preventDefault();
    return false;
  });
  tabs.addClass('disabled');
}
shinyjs.enableTabs = function(id) {
  var tabs = $('#'+id).find('li.disabled');
  tabs.unbind('click.tab');
  tabs.removeClass('disabled');
}