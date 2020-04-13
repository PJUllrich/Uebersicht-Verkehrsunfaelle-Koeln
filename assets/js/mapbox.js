import mapboxgl from 'mapbox-gl';

const raw_accidents = document.currentScript.getAttribute('accidents')
const json_accidents = JSON.parse(raw_accidents)
const features = json_accidents.map(acc => {
  return {
    'type': 'Feature',
    'geometry': {
      'type': 'Point',
      'coordinates': acc
    }
  }
})

mapboxgl.accessToken = document.currentScript.getAttribute('accesstoken');
const map = new mapboxgl.Map({
  container: 'map',
  style: 'mapbox://styles/mapbox/light-v10',
  center: [6.961, 50.937],
  zoom: 12
});

const circleColor = (max_count) => {
  return [
    'interpolate',
    ["exponential", 0.06],
    ['get', 'point_count'],
    0, "#655fb6",
    Math.floor(max_count / 3), "#5ea9f7",
    Math.floor(max_count / 2), "#efe433",
    Math.floor(max_count / 1.5), "#ef8633",
    max_count, "#e93223"
  ]
}

const circleRadius = (max_count) => {
  return [
    'interpolate',
    ["exponential", 0.05],
    ['get', 'point_count'],
    0, 6,
    Math.floor(max_count / 3), 8,
    Math.floor(max_count / 2), 11,
    Math.floor(max_count / 3 * 2), 12,
    max_count, 15
  ]
}

const setColorSteps = (initial = false) => {
  const clusters = map.queryRenderedFeatures({ layers: ["clusters"] });
  let max_count = 1000

  if (!initial) {
    max_count = clusters
      .map(c => c.properties.point_count)
      .reduce((a, b) => Math.max(a, b));
  }

  map.setPaintProperty('clusters', 'circle-color', circleColor(max_count));
  map.setPaintProperty('clusters', 'circle-radius', circleRadius(max_count));
}

map.on('load', () => {
  map.addSource('accidents', {
    type: 'geojson',
    cluster: true,
    clusterMaxZoom: 18,
    clusterRadius: 20,
    data: {
      type: 'FeatureCollection',
      features: features
    }
  });
  map.addLayer({
    id: 'clusters',
    type: 'circle',
    source: 'accidents',
    filter: ['has', 'point_count'],
    layout: {
      visibility: 'visible'
    }

  });

  map.addLayer({
    id: 'cluster-count',
    type: 'symbol',
    source: 'accidents',
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
    source: 'accidents',
    filter: ['!', ['has', 'point_count']],
    paint: {
      'circle-color': '#5ea9f7',
      'circle-radius': 3,
      'circle-stroke-width': 1,
      'circle-stroke-color': '#fff'
    }
  });

  setColorSteps(true);
})

map.on('idle', () => { setColorSteps(); })
