import 'regenerator-runtime'
import mapboxgl from 'mapbox-gl'

// Receive config parameter from the app.html layout template
const accidentsEndpoint = document.currentScript.getAttribute('endpoint')
const accessToken = document.currentScript.getAttribute('accesstoken')

// Some HTML identifiers to necessary elements
const accidentFilterId = 'accidentFilter'
const accidentFilterSubmitBtnId = 'accidentFilterSubmitBtn'

// The cluster-color values from small to large clusters
const clusterColors = ['#655fb6', '#cdcce1', '#5ea9f7', '#ef8633', '#e93223']

// The cluster-size values from small to large clusters (unit is px)
const clusterSizes = [6, 8, 10, 11, 15]

// Some config parameters for the MapBox GL JS map
const clusterDataSource = 'accidents-cluster'
const heatmapDataSource = 'accidents-heatmap'

const clusterLayerId = 'cluster-points'
const clusterLayerCounts = 'cluster-counts'
const clusterLayerUnclusteredPoints = 'unclustered-points'
const clusterLayerUnclusteredCount = 'unclustered-counts'

const heatmapLayerId = 'heatmap'
const heatmapLayerStreets = 'heatmap-streets'

// Since MapBox GL JS doesn't have a proper "Everything is loaded and rendered"-Event
// this is a workaround to track whether the map has reached the 'idle' state
// in which the map is fully loaded and the clusters can be resized and colored based on their
// point_count.
// Ref: https://github.com/mapbox/mapbox-gl-js/issues/1715
let isFullyRendered = false

let showHeatmap = false

const isAccidentFilterVisible = window.getComputedStyle(document.getElementById(accidentFilterId)).display !== 'none'

// Shows or hides a Spinner in the "Submit"-Button
const setButtonIsLoading = (isLoading) => {
  const button = document.getElementById(accidentFilterSubmitBtnId)
  if (isLoading) {
    button.classList.add('is-loading')
  } else {
    button.classList.remove('is-loading')
  }
}

/*
  Retrieves all currently rendered clusters (also out-of-viewport)
  and calculates the maximum point_count of all clusters.

  Eventually, sets the `circle-color` and `circle-radius` paint properties.

  If no clusters are rendered yet (initial = True), it sets the paint properties with a default maxCount.
*/
const setPaintSteps = () => {
  const clusters = map.queryRenderedFeatures({ layers: [clusterLayerId] })
  const maxCount = clusters.map(c => c.properties.point_count).reduce((a, b) => Math.max(a, b), 8)

  map.setPaintProperty(clusterLayerId, 'circle-color', circleColor(maxCount))
  map.setPaintProperty(clusterLayerId, 'circle-radius', circleRadius(maxCount))
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
    ['exponential', 0.06],
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
    ['exponential', 0.06],
    ['get', 'point_count'],
    -1, clusterSizes[0],
    Math.floor(maxCount / 4), clusterSizes[1],
    Math.floor(maxCount / 2), clusterSizes[2],
    Math.floor(maxCount / 4 * 3), clusterSizes[3],
    maxCount, clusterSizes[4]
  ]
}

const addClusterLayers = () => {
  map.addLayer({
    id: clusterLayerId,
    type: 'circle',
    source: clusterDataSource,
    filter: ['has', 'point_count'],
    layout: {
      visibility: 'visible'
    }
  })

  map.addLayer({
    id: clusterLayerCounts,
    type: 'symbol',
    source: clusterDataSource,
    filter: ['has', 'point_count'],
    layout: {
      'text-field': '{point_count}',
      'text-font': ['DIN Offc Pro Medium', 'Arial Unicode MS Bold'],
      'text-size': 12
    },
    paint: {
      'text-color': '#FFFFFF'
    }
  })

  map.addLayer({
    id: clusterLayerUnclusteredPoints,
    type: 'circle',
    source: clusterDataSource,
    filter: ['!', ['has', 'point_count']],
    paint: {
      'circle-color': clusterColors[1],
      'circle-radius': clusterSizes[1],
      'circle-stroke-width': 1,
      'circle-stroke-color': '#fff'
    }
  })

  map.addLayer({
    id: clusterLayerUnclusteredCount,
    type: 'symbol',
    source: clusterDataSource,
    filter: ['!', ['has', 'point_count']],
    layout: {
      'text-field': '1',
      'text-font': ['DIN Offc Pro Medium', 'Arial Unicode MS Bold'],
      'text-size': 12
    },
    paint: {
      'text-color': '#FFFFFF'
    }
  })

  setPaintSteps()
}

const addHeatmapLayers = () => {
  map.addLayer({
    id: heatmapLayerStreets,
    type: 'line',
    source: 'mapbox-streets',
    'source-layer': 'road',
    layout: {
      'line-join': 'round',
      'line-cap': 'round'
    },
    paint: {
      'line-color': '#C6D2F6',
      'line-width': 1
    }
  })

  map.addLayer({
    id: heatmapLayerId,
    type: 'heatmap',
    source: heatmapDataSource,
    paint: {
      'heatmap-radius': 5,
      'heatmap-weight': 0.4,
      'heatmap-intensity': [
        'interpolate',
        ['linear'],
        ['zoom'],
        0, 1,
        9, 3
      ]
    }
  })
}

const removeClusterLayers = () => {
  map.removeLayer(clusterLayerId)
  map.removeLayer(clusterLayerCounts)
  map.removeLayer(clusterLayerUnclusteredPoints)
  map.removeLayer(clusterLayerUnclusteredCount)
}

const removeHeatmapLayers = () => {
  map.removeLayer(heatmapLayerId)
  map.removeLayer(heatmapLayerStreets)
}

// Sets up a new MapBox GL JS map centered on Cologne, Germany
mapboxgl.accessToken = accessToken
const map = new mapboxgl.Map({
  container: 'map',
  style: 'mapbox://styles/mapbox/light-v10',
  center: [6.961, 50.937],
  zoom: 12
})

// Set the `color-radius` and `cluster-color` properties once all clusters are rendered
map.on('idle', () => {
  if (isFullyRendered) return

  if (!showHeatmap) setPaintSteps()

  setButtonIsLoading(false)
  isFullyRendered = true
})

// Setup the data-source and layers of the map
map.on('load', async () => {
  const res = await fetch(accidentsEndpoint)
  const data = await res.json()

  map.addSource(clusterDataSource, {
    type: 'geojson',
    cluster: true,
    clusterMaxZoom: 18,
    clusterRadius: 20,
    data: data
  })

  map.addSource(heatmapDataSource, {
    type: 'geojson',
    data: data
  })

  map.addSource('mapbox-streets', {
    type: 'vector',
    url: 'mapbox://mapbox.mapbox-streets-v8'
  })

  if (showHeatmap) {
    addHeatmapLayers()
  } else {
    addClusterLayers()
  }
})

/*
  A global function to show and hide the accident filter form.
  Is used by the navigation-burger in the navbar to show/hide the form
  on mobile devices.

  If the accident filter form was visible on page load and the user
  is therefore not on a mobile device, then make this function no-op.
*/
window.toggleFilter = () => {
  if (isAccidentFilterVisible) return

  const el = document.getElementById(accidentFilterId)
  el.style.display = el.style.display === 'block' ? 'none' : 'block'
}

window.toggleHeatmap = () => {
  showHeatmap = !showHeatmap
  if (showHeatmap) {
    removeClusterLayers()
    addHeatmapLayers()
  } else {
    removeHeatmapLayers()
    addClusterLayers()
  }

  isFullyRendered = false
}

/*
  Intercepts the accident filter form, extracts the query parameters
  and sets the request url as a new data source for the MapBox GL JS map,
  so that the map re-renders the data dynamically, making a page reload unnecessary.
*/
window.fetchData = (e) => {
  e.preventDefault()

  const form = document.getElementById(accidentFilterId)
  const reqUrl = form.action + '?' + Array.from(
    new FormData(form),
    e => e.map(encodeURIComponent).join('=')
  ).join('&')

  setButtonIsLoading(true)

  map.getSource(clusterDataSource).setData(reqUrl)
  map.getSource(heatmapDataSource).setData(reqUrl)

  setButtonIsLoading(false)

  return false
}
