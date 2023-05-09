// We don't use tailwind and therefore need to instruct esbuild
// to bundle the app.css
import "../css/app.css";
import "phoenix_html";

import "./mapbox";
import "./info";
import "./dropdown";

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

// import { Socket } from "phoenix"
// import LiveSocket from "phoenix_live_view"

// let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
// let liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token: csrfToken } });
// liveSocket.connect()
