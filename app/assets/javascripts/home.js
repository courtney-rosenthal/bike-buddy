/**
 * Helper to define classes.
 */
function inherit(m) {
  var o = function() {};
  o.prototype = m;
  return new o();  
}

function markerImage(img) {
  return {  
    icon: new google.maps.MarkerImage(
      "http://maps.google.com/mapfiles/ms/micons/" + img,
      new google.maps.Size(32, 32),  // size
      new google.maps.Point(0, 0),   // origin
      new google.maps.Point(16, 32)  // anchor
    ),    
    shadow: new google.maps.MarkerImage(
      "http://maps.google.com/mapfiles/ms/micons/msmarker.shadow.png",
      new google.maps.Size(59, 32),  // size
      new google.maps.Point(0, 0),   // origin
      new google.maps.Point(16, 32)  // anchor
    ),    
  };  
}


function BuddyMap(mapId, opts) {
  var r = inherit(BuddyMap.methods);    
  
  r.current_user = opts.currentUser;  
  
  r.map = new google.maps.Map($(mapId)[0], {
    zoom: r.current_user ? 13 : 11,
    center: new google.maps.LatLng(opts.startLat, opts.startLng),
    mapTypeId: google.maps.MapTypeId.ROADMAP
  });
  
  r.buddies = [];
  
  for (var i = 0 ; i < opts.data.length ; ++i) {
	var user = opts.data[i];
	var buddy = new BuddyMapBuddy(r, user);
	r.buddies.push(buddy);  
  }
  
  // Currently selected buddy.
  r.selectedBuddy = null;
  
  return r;
}

BuddyMap.markerDef = {  
	'Me' : {  
		lineColor: "#FD7567",
		origination: markerImage("red-dot.png"),
		destination: markerImage("red-dot.png"),
	}, 
	'Experienced' : {  
		lineColor: "#6991FD",
		origination: markerImage("blue-dot.png"),
		destination: markerImage("blue-dot.png"),
	}, 
	'New' : { 
		lineColor: "#00E64D",
		origination: markerImage("green-dot.png"),
		destination: markerImage("green-dot.png"),
	},
};

BuddyMap.methods = {
		
  addListeners : function() {
	  this.buddies.forEach(function(buddy) {
		  buddy.addListeners();
	  });
  },
  
  selectBuddy : function(buddy, clickLatLng) {
	  if (this.selectedBuddy) {
		  this.selectedBuddy.infoWindow.close();
	  }
	  this.selectedBuddy = buddy;
	  buddy.infoWindow.setPosition(clickLatLng);
	  buddy.infoWindow.open(this.map);
  },
  
};

function BuddyMapBuddy(buddyMap, user) {
	var r = inherit(BuddyMapBuddy.methods);
	
	r.widget = buddyMap;
	
	r.originationLocation = new google.maps.LatLng(user.origination.latitude, user.origination.longitude);
	
	r.destinationLocation = new google.maps.LatLng(user.destination.latitude, user.destination.longitude);
	
	r.buddyType = (user.isMe ? 'Me' : user.commuterType);

    var marker = BuddyMap.markerDef[r.buddyType];
  
    r.originationMarker = new google.maps.Marker({
      map: buddyMap.map,
      position: r.originationLocation,      
      icon: marker.origination.icon,     
      shadow: marker.origination.shadow,
      title: user.isMe ? "You start here." : user.commuterType + " commuter " + user.name + " starts here.",
    });
    
    r.destinationMarker = new google.maps.Marker({
      map: buddyMap.map,
      position: r.destinationLocation,        
      icon: marker.destination.icon,     
      shadow: marker.destination.shadow,   
      title: user.isMe ? "You finish here." : user.commuterType + " commuter " + user.name + " finishes here.",
    });    
        
    r.path = new google.maps.Polyline({
      map: buddyMap.map,
      path: [r.originationLocation, r.destinationLocation],
      strokeColor: marker.lineColor,
      icons: [{
        icon: {path: google.maps.SymbolPath.FORWARD_CLOSED_ARROW},
        offset: '100%',
      }],
      clickable: true,
    });    
    
    var content = [];    
    content.push("<b>" + user.name.escapeHTML() + "</b>"); 
    if (!isEmpty(user.commuterType.address)) {
    	content.push(user.commuterType.escapeHTML() + " commuter");  
    }
    if (!isEmpty(user.origination.address)) {
    	content.push("Orig: " + user.origination.address.escapeHTML());    
    }
    if (!isEmpty(user.destination.address)) {
    	content.push("Dest: " + user.destination.address.escapeHTML());  
    }
    if (!isEmpty(user.schedule)) {
    	content.push("Sched: " + user.schedule.escapeHTML());    	
    }
    if (!isEmpty(user.note)) {
    	content.push("Note: " + user.note.escapeHTML());    	
    } 
    if (user.isMe) {
    	content.push("<i>This is me.</i>");
    } else {
	    content.push("<a href=\"" + user.contactURL + "\">Contact this person.</a>");
    }
    
    r.infoWindow = new google.maps.InfoWindow({
    	content : content.join("<br />\n"),
    });
    
    return r;	
}

BuddyMapBuddy.methods = {

	addListeners : function() {		
		var that = this;
		var clickCallBack = function(event) {
			that.widget.selectBuddy(that, event.latLng);
		}
		google.maps.event.addListener(this.path, 'click', clickCallBack);
		google.maps.event.addListener(this.originationMarker, 'click', clickCallBack);
		google.maps.event.addListener(this.destinationMarker, 'click', clickCallBack);
	},

};


function isEmpty(str) {
  return (!str || 0 === str.length);
}

function escapeHTML(str) {
  if (isEmpty(str)) {
    return "";
  } else {
    return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  }
}

String.prototype.capitalize = function() {
  return this.charAt(0).toUpperCase() + this.slice(1);
}

String.prototype.capitalizeWords = function() {
  return this.split(/\s+/).map(function(w) {return w.capitalize();}).join(' ');
}

String.prototype.escapeHTML = function() {
  return escapeHTML(this);
}

