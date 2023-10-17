import httpServer from './App.js';
import * as dotenv from 'dotenv'

dotenv.config()

process.env.APP_PORT = 3310

httpServer.listen( 3310 ,() => console.log('Server on port ' + process.env.APP_PORT + 'address' + process.env.address));