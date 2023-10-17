import { response } from 'express';
import pool from '../Database/mysql.js';


export const getRestaurantsHome = async (req, res = response) => {

    try {
        const restaurantsdb = await pool.query(`CALL SP_GET_Restaurants(?);`, req.params.client_id.slice(1));
        return res.json({
            resp: true,
            msg : 'Restaurants',
            restaurantsdb: restaurantsdb[0] 
        });

        
    } catch (e) {
        return res.status(500).json({
            resp: false,
            msg : e
        });
    }
}

export const getRestaurantsAdmin = async (req, res = response) => {

    try {
        const restaurantsdb = await pool.query(`CALL SP_GET_Restaurants_Admin();`);
        console.log(restaurantsdb[0])
        return res.json({
            resp: true,
            msg : 'Restaurants Admin',
            restaurantsdb: restaurantsdb[0] 
        });

        
    } catch (e) {
        return res.status(500).json({
            resp: false,
            msg : e
        });
    }
}

export const getRestaurantsFavorite = async (req, res = response) => {

    try {
        const restaurantsdb = await pool.query(`SP_GET_RESTAURANTS_FAV(?);`, req.params.client_id.slice(1));
        console.log(restaurantsdb[0] )
        return res.json({
            resp: true,
            msg : 'Restaurants',
            restaurantsdb: restaurantsdb[0] 
        });

        
    } catch (e) {
        return res.status(500).json({
            resp: false,
            msg : e
        });
    }
}

export const getRestaurantsByCategorie = async (req, res = response) => {
    try {
        console.log(req.params.category_id.slice(1))
        console.log(req.params.client_id.slice(1))
        const restaurantsdb = await pool.query(`CALL SP_GET_RESTAURANTS_CAT(?,?)`, [req.params.category_id.slice(1), req.params.client_id.slice(1)]);
       
        return res.json({
            resp: true,
            msg : 'Restaurants',
            restaurantsdb: restaurantsdb[0]
        });

        
    } catch (e) {
        return res.status(500).json({
            resp: false,
            msg : e
        });
    }
}

export const getImagesRestaurants = async ( req, res = response ) => {

    try {
        const imageRestaurantdb = await pool.query('SELECT * FROM imagerestaurant WHERE restaurant_id = ?',req.params.id.slice(1));
        console.log(imageRestaurantdb);
        return res.json({
            resp: true,
            msg : 'Get Images Restaurantsssss',
            imageRestaurantdb: imageRestaurantdb
        });
        
    } catch (e) {
        console.log('no')
        return res.status(500).json({
            resp: false,
            msg : e
        });
    }

}

export const addFavorite = async (req, res = response) => {

    try {

        const { restaurantId, clientId } = req.body;

        await pool.query('INSERT INTO `client_resto_fav` VALUES (null,?,?)', [ parseInt(clientId), parseInt(restaurantId) ]);
    
        res.json({
            resp: true,
            msg : 'Favorite added'
        });
        
    } catch (e) {
        return res.status(500).json({
            resp: false,
            msg : e
        });
    }

}

export const updateState = async (req, res = response) => {

    try {

        const { restaurantId, newState } = req.body;

        await pool.query('update restaurants set state = ? where id = ? ', [ parseInt(newState), parseInt(restaurantId) ]);
    
        res.json({
            resp: true,
            msg : 'State updated'
        });
        
    } catch (e) {
        return res.status(500).json({
            resp: false,
            msg : e
        });
    }

}


export const deleteFavorite = async (req, res = response) => {

    try {

        const { restaurantId, clientId } = req.body;

        await pool.query('DELETE FROM `client_resto_fav` WHERE restaurantId = ? and clientId = ?', [ parseInt(restaurantId), parseInt(clientId) ]);
    
        res.json({
            resp: true,
            msg : 'Favorite deleted'
        });
        
    } catch (e) {
        return res.status(500).json({
            resp: false,
            msg : e
        });
    }

}


