import { Router } from 'express';
import * as category from '../Controller/CategoryController.js';
import { getAllDelivery } from '../Controller/DeliveryController.js';
import { verifyToken } from '../Middleware/ValidateToken.js';

const router = Router();


router.post('/add-categories', verifyToken, category.addCategories);
router.get('/get-all-categories', verifyToken, category.getAllCategories );
router.get('/get-all-delivery', verifyToken, getAllDelivery);

export default router;