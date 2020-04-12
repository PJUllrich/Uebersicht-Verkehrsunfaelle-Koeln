import mapboxgl from 'mapbox-gl';
import Supercluster from 'supercluster';
import { featureCollection } from '@turf/turf'

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

var cluster = new Supercluster({
  radius: 30,
  maxZoom: 18,
  map: (props) => ({ count: 1 }),
  reduce: function (accumulated, properties) {
    accumulated.max = Math.round(Math.max(accumulated.max, properties.count) * 100) / 100;
  }
});

cluster.load(features)
let currentZoom = map.getZoom();
let clusterData = featureCollection(cluster.getClusters([-180, -85, 180, 85], Math.floor(currentZoom)))

map.on('load', function () {
  map.addSource('accidents', {
    type: 'geojson',
    cluster: true,
    clusterMaxZoom: 18,
    clusterRadius: 30,
    data: clusterData
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
        0, 5,
        1, 25
      ]
    },
  });

  map.addLayer({
    id: 'cluster-count',
    type: 'symbol',
    source: 'accidents',
    filter: ['has', 'point_count'],
    layout: {
      'text-field': '{point_count}/ {max}',
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
})
