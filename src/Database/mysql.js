import mysql from 'mysql';
import { promisify } from 'util';

const pool = mysql.createPool({
    host: 'localhost',
    user: 'mohamed',
    password: "Mohamed@1476957",
    database: 'frave_food',
    port: 3306,
});

pool.getConnection((err, connection) => {

    if( err ){
        if( err.code === 'PROTOCOL_CONNECTION_LOST' ) console.log('DATABASE CONNECTION WAS CLOSED');
        if( err.code === 'ER_CON_COUNT_ERROR' ) console.log('DATABASE HAS TO MANY CONNECTIONS');
        if( err.code === 'ECONNREFUSED' ) console.log('DATABASE CONNECTION WAS REFUSED');
        console.log(err)
        
    }

    if( connection ) connection.release();

    console.log('DataBase is connected to '+ process.env.DB_DATABASE);
    
    return;
});

pool.query = promisify( pool.query );


export default pool;