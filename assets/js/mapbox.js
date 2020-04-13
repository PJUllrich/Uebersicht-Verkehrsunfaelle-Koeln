import mapboxgl from 'mapbox-gl';

// Receive config parameter from the app.html layout template
const accidentsEndpoint = document.currentScript.getAttribute('endpoint');
const accessToken = document.currentScript.getAttribute('accesstoken');

// Some HTML identifiers to necessary elements
const accidentFilterId = "accidentFilter";
const accidentFilterSubmitBtnId = "accidentFilterSubmitBtn";
const isAccidentFilterVisible = window.getComputedStyle(document.getElementById(accidentFilterId)).display !== "none";

// The cluster-color values from small to large clusters
const clusterColors = ["#655fb6", "#cdcce1", "#5ea9f7", "#ef8633", "#e93223"]

// The cluster-size values from small to large clusters (unit is px)
const clusterSizes = [6, 8, 10, 11, 15]

// Some config parameters for the MapBox GL JS map
const dataSourceName = "accidents";
const clusterLayerId = "clusters"

const toggleButtonLoadingState = (isLoading) => {
  const button = document.getElementById(accidentFilterSubmitBtnId)
  if (isLoading) {
    button.classList.add("is-loading")
  } else {
    button.classList.remove("is-loading")
  }
}

/*
  Sets steps for the circle-color paint property of the cluster
  marker based on the maximum point_count of all clusters.
  The scale starts at -1 since MapBox would throw an Error if
  Math.floor(maxCount / 4) is equal to 0, which would result
  in duplicate steps (2x "0").
*/
const circleColor = (maxCount) => {
  return [
    'interpolate',
    ["exponential", 0.06],
    ['get', 'point_count'],
    -1, clusterColors[0],
    Math.floor(maxCount / 4), clusterColors[1],
    Math.floor(maxCount / 2), clusterColors[2],
    Math.floor(maxCount / 4 * 3), clusterColors[3],
    maxCount, clusterColors[4]
  ]
}

/*
  Sets steps for the circle-radius paint property of the cluster 
  marker based on the maximum point_count of all clusters. 
  The scale starts at -1 since MapBox would throw an Error if 
  Math.floor(maxCount / 4) is equal to 0, which would result
  in duplicate steps (2x "0") .
*/
const circleRadius = (maxCount) => {
  return [
    'interpolate',
    ["exponential", 0.06],
    ['get', 'point_count'],
    -1, clusterSizes[0],
    Math.floor(maxCount / 4), clusterSizes[1],
    Math.floor(maxCount / 2), clusterSizes[2],
    Math.floor(maxCount / 4 * 3), clusterSizes[3],
    maxCount, clusterSizes[4],
  ]
}

/*
  Retrieves all currently rendered clusters (also out-of-viewport)
  and calculates the maximum point_count of all clusters.

  Eventually, sets the `circle-color` and `circle-radius` paint properties.

  If no clusters are rendered yet (initial = True), it sets the paint properties with a default maxCount.
*/
const setPaintSteps = () => {
  const clusters = map.queryRenderedFeatures({ layers: [clusterLayerId] });
  const maxCount = clusters.map(c => c.properties.point_count).reduce((a, b) => Math.max(a, b), 8);

  map.setPaintProperty(clusterLayerId, 'circle-color', circleColor(maxCount));
  map.setPaintProperty(clusterLayerId, 'circle-radius', circleRadius(maxCount));
}

// Sets up a new MapBox GL JS map centered on Cologne, Germany
mapboxgl.accessToken = accessToken
const map = new mapboxgl.Map({
  container: 'map',
  style: 'mapbox://styles/mapbox/light-v10',
  center: [6.961, 50.937],
  zoom: 12
});

/*
  A global function to show and hide the accident filter form.
  Is used by the navigation-burger in the navbar to show/hide the form
  on mobile devices.

  If the accident filter form was visible on page load and the user
  is therefore not on a mobile device, then make this function no-op.
*/
window.toggleFilter = () => {
  if (isAccidentFilterVisible) return;

  const el = document.getElementById(accidentFilterId)
  el.style.display = el.style.display === "block" ? "none" : "block";
}

/*
  Intercepts the accident filter form, extracts the query parameters
  and sets the request url as a new data source for the MapBox GL JS map,
  so that the map re-renders the data dynamically, making a page reload unnecessary.
*/
window.addEventListener("load", function () {
  document.getElementById(accidentFilterId).addEventListener("submit", (e) => {
    e.preventDefault();

    const form = document.getElementById(accidentFilterId);
    const reqUrl = form.action + "?" + Array.from(
      new FormData(form),
      e => e.map(encodeURIComponent).join('=')
    ).join('&')


    toggleButtonLoadingState(true);

    map.getSource(dataSourceName).setData(reqUrl)
  });
});

// Set the `color-radius` and `cluster-color` properties once all clusters are rendered
map.on('idle', () => { setPaintSteps(); toggleButtonLoadingState(false); })

// Setup the data-source and layers of the map
map.on('load', () => {
  map.addSource(dataSourceName, {
    type: 'geojson',
    cluster: true,
    clusterMaxZoom: 18,
    clusterRadius: 20,
    data: accidentsEndpoint
  });
  map.addLayer({
    id: clusterLayerId,
    type: 'circle',
    source: dataSourceName,
    filter: ['has', 'point_count'],
    layout: {
      visibility: 'visible'
    }
  });

  map.addLayer({
    id: 'cluster-count',
    type: 'symbol',
    source: dataSourceName,
    filter: ['has', 'point_count'],
    layout: {
      'text-field': '{point_count}',
      'text-font': ['DIN Offc Pro Medium', 'Arial Unicode MS Bold'],
      'text-size': 12
    },
    paint: {
      'text-color': "#FFFFFF"
    }
  });

  map.addLayer({
    id: 'unclustered-point',
    type: 'circle',
    source: dataSourceName,
    filter: ['!', ['has', 'point_count']],
    paint: {
      'circle-color': clusterColors[1],
      'circle-radius': clusterSizes[1],
      'circle-stroke-width': 1,
      'circle-stroke-color': '#fff'
    }
  });

  map.addLayer({
    id: 'unclustered-point-count',
    type: 'symbol',
    source: dataSourceName,
    filter: ['!', ['has', 'point_count']],
    layout: {
      'text-field': '1',
      'text-font': ['DIN Offc Pro Medium', 'Arial Unicode MS Bold'],
      'text-size': 12
    },
    paint: {
      'text-color': "#FFFFFF"
    }
  });

  setPaintSteps();
})
