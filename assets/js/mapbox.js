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
  style: 'mapbox://styles/mapbox/streets-v11',
  center: [6.961, 50.937],
  zoom: 12
});

const setColorSteps = (initial = false) => {
  const clusters = map.queryRenderedFeatures({ layers: ["clusters"] });
  let max_count = 1000

  if (!initial) {
    max_count = clusters
      .map(c => c.properties.point_count)
      .reduce((a, b) => Math.max(a, b));
  }

  map.setPaintProperty('clusters', 'circle-color', [
    'interpolate',
    ["linear"],
    ['get', 'point_count'],
    0, "#b2ebf2",
    max_count, "#dd2c00"
  ]);

  map.setPaintProperty('clusters', 'circle-radius', [
    'interpolate',
    ["linear"],
    ['get', 'point_count'],
    0, 12,
    max_count, 17
  ])
}

map.on('load', function () {
  map.addSource('accidents', {
    type: 'geojson',
    cluster: true,
    clusterMaxZoom: 18,
    clusterRadius: 25,
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
    },
    paint: {
      'circle-color': [
        'interpolate',
        ["linear"],
        ['get', 'point_count'],
        0, "#b2ebf2",
        1, "#dd2c00"
      ],
      'circle-radius': [
        'interpolate',
        ["linear"],
        ['get', 'point_count'],
        0, 10,
        1, 17
      ]
    },
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
    }
  });

  map.addLayer({
    id: 'unclustered-point',
    type: 'circle',
    source: 'accidents',
    filter: ['!', ['has', 'point_count']],
    paint: {
      'circle-color': '#11b4da',
      'circle-radius': 4,
      'circle-stroke-width': 1,
      'circle-stroke-color': '#fff'
    }
  });

  setColorSteps(true);
})

map.on('move', (e) => setColorSteps())
map.on('zoomend', (e) => setColorSteps())