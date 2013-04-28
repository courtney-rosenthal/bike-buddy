/**
 * Helper to define classes.
 */
function inherit(m) {
  var o = function() {};
  o.prototype = m;
  return new o();  
}

function markerImage(url) {
  return {  
    icon: new google.maps.MarkerImage(url,
      new google.maps.Size(32, 32),  // size
      new google.maps.Point(0,0),    // origin
      new google.maps.Point(16, 32)  // anchor
    ),    
    shadow: new google.maps.MarkerImage(
      "http://maps.google.com/mapfiles/ms/micons/msmarker.shadow.png",
      new google.maps.Size(59, 32),  // size
      new google.maps.Point(0,0),    // origin
      new google.maps.Point(16, 32)  // anchor
    ),    
  };  
}

BuddyMap.marker = {  
  'Me' : {  
    origination: markerImage("http://maps.google.com/mapfiles/ms/micons/yellow-dot.png"),
    destination: markerImage("http://maps.google.com/mapfiles/ms/micons/yellow-dot.png"),
  }, 
  'Experienced' : {  
    origination: markerImage("http://maps.google.com/mapfiles/ms/micons/blue-dot.png"),
    destination: markerImage("http://maps.google.com/mapfiles/ms/micons/blue-dot.png"),
  }, 
  'New' : {  
    origination: markerImage("http://maps.google.com/mapfiles/ms/micons/green-dot.png"),
    destination: markerImage("http://maps.google.com/mapfiles/ms/micons/green-dot.png"),
  },
};


function BuddyMap(map_id, opts) {
  var r = inherit(BuddyMap.methods);    
  
  r.current_user = opts.current_user;
  
  var start_lat = opts.start_lat || 30.261214068166684;
  
  var start_lng = opts.start_lng || -97.73637580871582;  
  
  r.map = new google.maps.Map($(map_id)[0], {
    zoom: 12,
    center: new google.maps.LatLng(start_lat, start_lng),
    mapTypeId: google.maps.MapTypeId.ROADMAP
  });  
  
  /* Place all the commuters onto the map. */
  for (var i = 0 ; i < opts.data.length ; ++i) {
  
    var user = opts.data[i];
    
    var is_me = (user.id == r.current_user);
    
    var marker = BuddyMap.marker[is_me ? 'Me' : user.commuter_type];
    
    var olocation = new google.maps.LatLng(user.origination.latitude, user.origination.longitude);
    
    var dlocation = new google.maps.LatLng(user.destination.latitude, user.destination.longitude);
  
    var omarker = new google.maps.Marker({
      map: r.map,
      position: olocation,      
      icon: marker.origination.icon,     
      shadow: marker.origination.shadow,
      title: is_me ? "You start here" : user.name + " starts here",
    });
    
    var dmarker = new google.maps.Marker({
      map: r.map,
      position: dlocation,        
      icon: marker.destination.icon,     
      shadow: marker.destination.shadow,   
      title: is_me ? "You finish here" : user.name + " finishes here",
    });
    
    var lineCoordinates = [olocation, dlocation];
    
    var lineSymbol = {
      path: google.maps.SymbolPath.FORWARD_CLOSED_ARROW
    };

    var line = new google.maps.Polyline({
      path: lineCoordinates,
      icons: [{
        icon: lineSymbol,
        offset: '100%'
      }],
      map: r.map
    });
    
    // TODO - add listener to pop up window
    
  }
  
  return r;
}

BuddyMap.methods = {
  
  dummy : function () {
  
  },

};
