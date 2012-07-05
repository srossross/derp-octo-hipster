var styles = [{
    featureType : "landscape",
    stylers : [{
        color : "#808080"
    }]
}, {
    featureType : "administrative",
    stylers : [{
        visibility : "off"
    }]
}, {
    featureType : "poi",
    stylers : [{
        visibility : "off"
    }]
}, {
    featureType : "water",
    elementType : "labels",
    stylers : [{
        visibility : "off"
    }]
}, {
    featureType: "road",
    stylers: [
      { visibility: "off" }
    ]
},{
    featureType: "administrative.country",
    elementType: "geometry.stroke",
    stylers: [
      { visibility: "on" },
      { color: "#ffffff" }
    ]
  }]


var SimpleMap = new google.maps.StyledMapType(styles, {
    name : "Simple"
});

SimpleMap.ID = "Simple";

module.exports = SimpleMap; 