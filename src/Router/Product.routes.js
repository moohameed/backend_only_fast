import { Router } from 'express';

import * as product from '../Controller/ProductController.js';
import { upLoadsProducts } from '../Lib/Multer.js';
import { verifyToken } from '../Middleware/ValidateToken.js';

const router = Router();


router.post('/add-new-products', [ verifyToken, upLoadsProducts.array('image') ], product.addNewProduct);
router.get('/get-products-top-home/:idRestaurant/:categoryId', verifyToken, product.getProductsTopHome);
router.get('/get-images-products/:id', verifyToken, product.getImagesProduct);
router.get('/get-ingredients/:id/:restoId', verifyToken, product.getIngredients );
router.get('/search-product-for-name/:nameProduct', verifyToken, product.searchProductForName );
router.get('/search-product-for-category/:idCategory', verifyToken, product.searchProductsForCategory );
router.get('/list-porducts-admin', verifyToken, product.listProductsAdmin );
router.put('/update-status-product', verifyToken, product.updateStatusProduct);
router.delete('/delete-product/:idProduct', verifyToken, product.deleteProduct);


export default router;