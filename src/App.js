import express from 'express';
import path from 'path';
import { config } from 'dotenv';
import { initializeApp } from 'firebase-admin/app';
import { createServer } from "http";
import Server from "socket.io";
import { socketOrderDelivery } from './Sockets/SocketOrderDelivery.js';
//import * as admin from 'firebase-admin';
import routeAuth from './Router/Auth.routes.js';
import routerUser from './Router/User.routes.js';
import routerProduct from './Router/Product.routes.js';
import routerRestaurant from './Router/Restaurant.routes.js'
import routerCategory from './Router/Category.routes.js';
import routerOrder from './Router/Order.routes.js';
import routerNotification from './Router/Notification.routes.js'
import { dirname } from 'path';
import { fileURLToPath } from 'url';
import { createRequire } from "module";
const require = createRequire(import.meta.url);

config();
export var admin = require("firebase-admin");

var serviceAccount = require("D:/Projects/Flutter/Only Fast/Backend-Delivery-App-Flutter-main/src/only-fast-fire-firebase.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  // other Firebase configuration options
});
const app = express();
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
console.log(__dirname);
// CONFIG SOCKET 
const httpServer = createServer(app);
const io = new Server(httpServer);
socketOrderDelivery(io);


app.use( express.json() );
app.use( express.urlencoded({ extended: false }));

app.use('/api', routeAuth);
app.use('/api', routerUser);
app.use('/api', routerProduct);
app.use('/api', routerRestaurant);
app.use('/api', routerCategory);
app.use('/api', routerOrder);
app.use('/api', routerNotification);


app.use( express.static( path.join( __dirname, 'Uploads/Profile' )));
app.use( express.static( path.join( __dirname, 'Uploads/Products' )));
app.use( express.static( path.join( __dirname, 'Uploads/Restaurants' )));




export default httpServer;