import { Router } from 'express';

import * as restaurant from '../Controller/RestaurantController.js';
import { upLoadsProducts } from '../Lib/Multer.js';
import { verifyToken } from '../Middleware/ValidateToken.js';


const router = Router();


router.get('/get-restaurants-home/:client_id', verifyToken, restaurant.getRestaurantsHome);
router.get('/get-restaurants-favorite/:client_id', verifyToken, restaurant.getRestaurantsHome);
router.get('/get-images-restaurant/:id', restaurant.getImagesRestaurants);
router.get('/get-restaurants-admin', restaurant.getRestaurantsAdmin);
router.get('/get-restaurants-by-category/:category_id/:client_id', restaurant.getRestaurantsByCategorie);
router.put('/add-restaurant-favorite',verifyToken, restaurant.addFavorite)
router.put('/update-restaurant-status',verifyToken, restaurant.updateState)
router.delete('/delete-restaurant-favorite',verifyToken, restaurant.deleteFavorite)

export default router;